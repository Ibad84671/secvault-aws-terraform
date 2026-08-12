#!/usr/bin/env python3
import os
import json
import uuid
from datetime import datetime
from flask import Flask, request, jsonify, render_template_string
import pymysql
from pymysql import MySQLError

app = Flask(__name__)

# ─── Environment ──────────────────────────────────────────────────────────────
DB_HOST     = os.environ.get('DB_HOST', 'localhost')
DB_USER     = os.environ.get('DB_USER', 'admin')
DB_PASSWORD = os.environ.get('DB_PASSWORD', '')
DB_NAME     = os.environ.get('DB_NAME', 'secvault')
MOCK_MODE   = os.environ.get('MOCK_MODE', 'false').lower() == 'true'

# ─── Database helpers ─────────────────────────────────────────────────────────
def get_db_connection():
    try:
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset='utf8mb4',
            connect_timeout=5,
            autocommit=True,
            cursorclass=pymysql.cursors.DictCursor
        )
    except MySQLError as e:
        app.logger.error(f"DB connection failed: {e}")
        return None

def init_db():
    conn = get_db_connection()
    if not conn:
        return
    try:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS security_events (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    event_id VARCHAR(36) NOT NULL,
                    severity VARCHAR(20) NOT NULL,
                    source VARCHAR(50),
                    type VARCHAR(50),
                    title VARCHAR(255),
                    description TEXT,
                    source_ip VARCHAR(45),
                    username VARCHAR(50),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
        conn.close()
        print("✅ Database table verified/created.")
    except MySQLError as e:
        print(f"❌ Table init failed: {e}")

# ─── Mock fallback data ──────────────────────────────────────────────────────
MOCK_EVENTS = [
    {"id": 1, "event_id": "SEC-MOCK-1", "severity": "Critical", "source": "web",
     "type": "SSH_Brute", "title": "Brute force from 10.0.0.5", "source_ip": "10.0.0.5",
     "username": "root", "created_at": "2025-01-01T12:00:00Z"},
    {"id": 2, "event_id": "SEC-MOCK-2", "severity": "High", "source": "api",
     "type": "SQL_Injection", "title": "Possible SQLi in /login", "source_ip": "192.168.1.20",
     "username": "api_user", "created_at": "2025-01-01T11:30:00Z"},
]

# ─── Routes ──────────────────────────────────────────────────────────────────
@app.route('/health')
def health():
    return jsonify({"status": "healthy", "tier": "app", "timestamp": datetime.utcnow().isoformat() + "Z"}), 200

@app.route('/')
def index():
    # Minimal dark dashboard – you can expand with Chart.js later
    return render_template_string("""
    <!DOCTYPE html>
    <html><head><title>SecVault</title>
    <style>body{background:#0d1117;color:#e6edf3;font-family:monospace;padding:20px;}
    h1{color:#3fb950;}</style></head>
    <body>
        <h1>🔐 SecVault – SOC Dashboard</h1>
        <p>RDS connected: {{ "✅" if db_ok else "❌ (using mock data)" }}</p>
        <p><a href="/api/events">View all events (JSON)</a></p>
    </body></html>
    """, db_ok=not MOCK_MODE)

@app.route('/api/events', methods=['GET', 'POST'])
def handle_events():
    if request.method == 'GET':
        # Try RDS first
        conn = get_db_connection()
        if conn and not MOCK_MODE:
            try:
                with conn.cursor() as cur:
                    cur.execute("SELECT * FROM security_events ORDER BY created_at DESC LIMIT 100")
                    rows = cur.fetchall()
                conn.close()
                return jsonify({"source": "rds", "count": len(rows), "events": rows}), 200
            except MySQLError as e:
                app.logger.error(f"DB read error: {e}")
        # Fallback to mock
        return jsonify({"source": "mock", "count": len(MOCK_EVENTS), "events": MOCK_EVENTS}), 200

    # POST – insert new event
    data = request.get_json() or {}
    # Validate / sanitize
    severity = data.get('severity', 'Low')
    if severity not in ('Critical', 'High', 'Medium', 'Low'):
        severity = 'Low'

    event_id = f"SEC-{uuid.uuid4().hex[:8].upper()}"

    # Try RDS insert
    conn = get_db_connection()
    if conn and not MOCK_MODE:
        try:
            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO security_events
                    (event_id, severity, source, type, title, description, source_ip, username)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    event_id,
                    severity,
                    data.get('source', 'api'),
                    data.get('type', 'Generic'),
                    data.get('title', 'No title'),
                    data.get('description', ''),
                    data.get('source_ip', '0.0.0.0'),
                    data.get('username', 'unknown')
                ))
            conn.close()
            return jsonify({"status": "ok", "source": "rds", "event_id": event_id}), 201
        except MySQLError as e:
            app.logger.error(f"DB insert failed: {e}")

    # Fallback insert to mock
    mock_event = {
        "id": len(MOCK_EVENTS) + 1,
        "event_id": event_id,
        "severity": severity,
        "source": data.get('source', 'api'),
        "type": data.get('type', 'Generic'),
        "title": data.get('title', 'No title'),
        "description": data.get('description', ''),
        "source_ip": data.get('source_ip', '0.0.0.0'),
        "username": data.get('username', 'unknown'),
        "created_at": datetime.utcnow().isoformat() + 'Z'
    }
    MOCK_EVENTS.insert(0, mock_event)
    return jsonify({"status": "ok", "source": "mock", "event_id": event_id}), 201

# ─── Startup ──────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=False)