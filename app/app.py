#!/usr/bin/env python3
import os
from datetime import datetime, timezone

import pymysql
from flask import Flask, jsonify, render_template
from pymysql import MySQLError

app = Flask(__name__)
app.config.update(
    JSON_SORT_KEYS=False,
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE="Lax",
)

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_USER = os.environ.get("DB_USER", "secvault")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "")
DB_NAME = os.environ.get("DB_NAME", "secvault")
MOCK_MODE = os.environ.get("MOCK_MODE", "false").lower() == "true"

MOCK_EVENTS = [
    {
        "id": 1,
        "event_id": "SEC-MOCK-1",
        "severity": "High",
        "source": "demo",
        "type": "ExampleFinding",
        "title": "Demo finding (MOCK_MODE only)",
        "description": "Synthetic data is enabled explicitly for local UI development.",
        "source_ip": "203.0.113.10",
        "username": "demo-user",
        "created_at": "2026-01-01T12:00:00Z",
    }
]


def utc_now():
    return datetime.now(timezone.utc).isoformat()


def get_db_connection():
    try:
        return pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            charset="utf8mb4",
            connect_timeout=5,
            autocommit=True,
            cursorclass=pymysql.cursors.DictCursor,
        )
    except MySQLError as exc:
        app.logger.error("Database connection failed: %s", exc)
        return None


@app.after_request
def add_security_headers(response):
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com; "
        "script-src 'self' 'unsafe-inline' https://cdn.tailwindcss.com https://cdn.jsdelivr.net; "
        "font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; "
        "img-src 'self' data:; "
        "connect-src 'self' https://cdn.jsdelivr.net; "
        "object-src 'none'; base-uri 'self'; frame-ancestors 'none'"
    )
    return response


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "tier": "application",
        "timestamp": utc_now(),
    }), 200


@app.route("/", methods=["GET"])
def index():
    return render_template("index.html", mock_mode=MOCK_MODE)


@app.route("/api/events", methods=["GET"])
def events():
    conn = get_db_connection()
    if conn is None:
        if MOCK_MODE:
            return jsonify({"source": "mock", "count": len(MOCK_EVENTS), "events": MOCK_EVENTS}), 200
        return jsonify({"error": "Security event store unavailable"}), 503

    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, event_id, severity, source, type, title,
                       description, source_ip, username, created_at
                FROM security_events
                ORDER BY created_at DESC
                LIMIT 100
                """
            )
            rows = cur.fetchall()
        response = jsonify({"source": "rds", "count": len(rows), "events": rows})
        response.headers["Cache-Control"] = "no-store"
        return response, 200
    except MySQLError as exc:
        app.logger.error("Database read failed: %s", exc)
        return jsonify({"error": "Security event store unavailable"}), 503
    finally:
        conn.close()


@app.errorhandler(404)
def not_found(_error):
    return jsonify({"error": "Not found"}), 404


@app.errorhandler(500)
def internal_error(_error):
    app.logger.exception("Unhandled application error")
    return jsonify({"error": "Internal server error"}), 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=False)
