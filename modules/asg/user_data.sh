#!/bin/bash -xe

# ─── UPDATE SYSTEM ───
yum update -y

# ─── INSTALL DEPENDENCIES ───
yum install -y git python3 python3-pip

# ─── CLONE APPLICATION ───
cd /home/ec2-user
git clone https://github.com/Ibad84671/secvault-aws-terraform.git app
cd app

# ─── INSTALL PYTHON PACKAGES ───
pip3 install -r app/requirements.txt

# ─── CREATE SYSTEMD SERVICE ───
cat > /etc/systemd/system/secvault.service << 'EOF'
[Unit]
Description=SecVault Flask App
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app
Environment=DB_HOST=${db_host}
Environment=DB_USER=${db_user}
Environment=DB_PASSWORD=${db_password}
Environment=DB_NAME=${db_name}
ExecStart=/usr/local/bin/gunicorn --bind 0.0.0.0:5000 app.app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# ─── START SERVICE ───
systemctl daemon-reload
systemctl enable --now secvault

# ─── VERIFY ───
systemctl is-active --quiet secvault && echo "✅ SecVault started successfully" || echo "⚠️ Service failed to start"