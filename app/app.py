from flask import Flask, render_template, request, jsonify
import os, pymysql, datetime

app = Flask(__name__)

DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_USER = os.getenv('DB_USER', 'admin')
DB_PASS = os.getenv('DB_PASSWORD', 'password123')
DB_NAME = os.getenv('DB_NAME', 'secops_db')

mock_logs = [
    {"timestamp": "2026-08-12 11:30:00", "source": "192.168.1.45", "event": "SSH Failed Auth", "severity": "HIGH"},
    {"timestamp": "2026-08-12 11:42:15", "source": "10.0.1.12", "event": "ALB Rate Limit Exceeded", "severity": "MEDIUM"},
    {"timestamp": "2026-08-12 12:00:05", "source": "172.16.0.8", "event": "IAM Access Key Rotation", "severity": "LOW"}
]

@app.route('/health')
def health():
    return jsonify(status="healthy", timestamp=str(datetime.datetime.now())), 200

@app.route('/')
def index():
    return render_template('index.html', logs=mock_logs)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)