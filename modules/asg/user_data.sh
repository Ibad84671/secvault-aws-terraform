#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/secvault-bootstrap.log | logger -t secvault-bootstrap -s 2>/dev/console) 2>&1

echo "[SecVault] Starting secure application bootstrap"

dnf update -y
dnf install -y git python3 python3-pip jq

rm -rf /opt/secvault
mkdir -p /opt/secvault
chown ec2-user:ec2-user /opt/secvault

sudo -u ec2-user git clone --depth 1 --branch '${app_git_ref}' '${app_repository}' /opt/secvault/app

python3 -m pip install --upgrade pip
python3 -m pip install -r /opt/secvault/app/app/requirements.txt

SECRET_JSON="$$(aws secretsmanager get-secret-value --secret-id '${db_secret_arn}' --query SecretString --output text)"
DB_HOST="$$(jq -r '.host' <<<"$$SECRET_JSON")"
DB_USER="$$(jq -r '.username' <<<"$$SECRET_JSON")"
DB_PASSWORD="$$(jq -r '.password' <<<"$$SECRET_JSON")"

export DB_HOST DB_USER DB_PASSWORD DB_NAME='${db_name}'
python3 - <<'PY'
import os
from pathlib import Path
import pymysql

schema = Path('/opt/secvault/app/app/schema.sql').read_text(encoding='utf-8')
connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASSWORD'],
    database=os.environ['DB_NAME'],
    connect_timeout=10,
    autocommit=True,
)
try:
    with connection.cursor() as cursor:
        for statement in schema.split(';'):
            statement = statement.strip()
            if statement:
                cursor.execute(statement)
finally:
    connection.close()
PY

install -d -o root -g root -m 0750 /etc/secvault
cat > /etc/secvault/secvault.env <<EOF
DB_HOST=$${DB_HOST}
DB_USER=$${DB_USER}
DB_PASSWORD=$${DB_PASSWORD}
DB_NAME=${db_name}
MOCK_MODE=false
EOF
chmod 0600 /etc/secvault/secvault.env
unset SECRET_JSON DB_HOST DB_USER DB_PASSWORD DB_NAME

cat > /etc/systemd/system/secvault.service <<'EOF'
[Unit]
Description=SecVault Flask application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
WorkingDirectory=/opt/secvault/app
EnvironmentFile=/etc/secvault/secvault.env
ExecStart=/usr/local/bin/gunicorn --bind 0.0.0.0:5000 --workers 2 --access-logfile - --error-logfile - app.app:app
Restart=always
RestartSec=10
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/secvault

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now secvault

for attempt in {1..12}; do
  if curl --fail --silent http://127.0.0.1:5000/health >/dev/null; then
    echo "[SecVault] Application health check passed"
    exit 0
  fi
  sleep 5
done

echo "[SecVault] Application failed health check"
systemctl status secvault --no-pager || true
exit 1
