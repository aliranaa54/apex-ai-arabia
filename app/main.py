"""Small Apex Operations API: log operational tasks (e.g. 'restart cache') and list them."""
import json
import logging
import os
import sys
import time

from flask import Flask, Response, g, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

VERSION = os.getenv("APP_VERSION", "dev")

REQUESTS = Counter("http_requests_total", "HTTP requests", ["method", "path", "status"])
LATENCY = Histogram("http_request_seconds", "Request latency", ["path"])


class JsonFormatter(logging.Formatter):
    def format(self, record):
        data = {"time": self.formatTime(record), "level": record.levelname, "msg": record.getMessage()}
        data.update(getattr(record, "extra", {}))
        return json.dumps(data)


def setup_logging():
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    log = logging.getLogger("apex")
    log.handlers = [handler]
    log.setLevel(os.getenv("LOG_LEVEL", "INFO"))
    return log


class MemoryStore:
    """Used in tests so they don't need a database."""

    def __init__(self):
        self.rows = []

    def ping(self):
        return True

    def add(self, title, owner):
        row = {"id": len(self.rows) + 1, "title": title, "owner": owner}
        self.rows.append(row)
        return row

    def all(self):
        return list(self.rows)


class PostgresStore:
    def __init__(self, dsn):
        import psycopg

        self.psycopg = psycopg
        self.dsn = dsn
        with self._conn() as c:
            c.execute(
                "CREATE TABLE IF NOT EXISTS operations ("
                "id SERIAL PRIMARY KEY, title TEXT NOT NULL, owner TEXT NOT NULL, "
                "created_at TIMESTAMPTZ DEFAULT now())"
            )

    def _conn(self):
        return self.psycopg.connect(self.dsn, connect_timeout=3)

    def ping(self):
        try:
            with self._conn() as c:
                c.execute("SELECT 1")
            return True
        except Exception:
            return False

    def add(self, title, owner):
        with self._conn() as c:
            row = c.execute(
                "INSERT INTO operations (title, owner) VALUES (%s, %s) RETURNING id", (title, owner)
            ).fetchone()
        return {"id": row[0], "title": title, "owner": owner}

    def all(self):
        with self._conn() as c:
            rows = c.execute("SELECT id, title, owner FROM operations ORDER BY id").fetchall()
        return [{"id": r[0], "title": r[1], "owner": r[2]} for r in rows]


def create_app(store=None):
    app = Flask(__name__)
    log = setup_logging()
    if store is None:
        store = PostgresStore(os.environ["DATABASE_URL"])

    @app.before_request
    def start_timer():
        g.start = time.time()

    @app.after_request
    def record(resp):
        path = request.url_rule.rule if request.url_rule else "unmatched"
        REQUESTS.labels(request.method, path, resp.status_code).inc()
        LATENCY.labels(path).observe(time.time() - g.start)
        if path not in ("/healthz", "/metrics"):
            log.info("request", extra={"extra": {
                "method": request.method, "path": request.path, "status": resp.status_code}})
        return resp

    @app.get("/healthz")
    def healthz():
        return jsonify(status="ok")  # liveness: the process is up

    @app.get("/readyz")
    def readyz():
        if store.ping():  # readiness: we can reach the database
            return jsonify(status="ready")
        log.error("database unreachable")
        return jsonify(status="not ready"), 503

    @app.get("/version")
    def version():
        return jsonify(version=VERSION)

    @app.get("/metrics")
    def metrics():
        return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

    @app.post("/operations")
    def add_operation():
        body = request.get_json(silent=True) or {}
        title, owner = str(body.get("title", "")).strip(), str(body.get("owner", "")).strip()
        if not title or not owner:
            return jsonify(error="title and owner are required"), 400
        return jsonify(store.add(title, owner)), 201

    @app.get("/operations")
    def list_operations():
        return jsonify(store.all())

    return app
