import os

import psycopg
from flask import Flask, jsonify, request

app = Flask(__name__)


def get_connection():
    return psycopg.connect(
        host=os.environ["DB_HOST"],
        port=os.environ.get("DB_PORT", "5432"),
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
    )


def init_db():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS equipment (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    status VARCHAR(50) NOT NULL
                )
            """)
        conn.commit()


@app.get("/health")
def health():
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        return jsonify({"status": "ok", "database": "ok"}), 200
    except Exception:
        return jsonify({"status": "error", "database": "unavailable"}), 503


@app.get("/")
def list_equipment():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT id, name, status FROM equipment ORDER BY id")
            rows = cur.fetchall()

    return jsonify([
        {"id": row[0], "name": row[1], "status": row[2]}
        for row in rows
    ])


@app.post("/equipment")
def add_equipment():
    data = request.get_json()

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO equipment (name, status)
                VALUES (%s, %s)
                RETURNING id, name, status
                """,
                (data["name"], data.get("status", "running")),
            )
            row = cur.fetchone()
        conn.commit()

    return jsonify({
        "id": row[0],
        "name": row[1],
        "status": row[2],
    }), 201


@app.patch("/equipment/<int:item_id>")
def update_equipment(item_id):
    data = request.get_json()

    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE equipment
                SET status = %s
                WHERE id = %s
                RETURNING id, name, status
                """,
                (data["status"], item_id),
            )
            row = cur.fetchone()
        conn.commit()

    if row is None:
        return jsonify({"error": "not found"}), 404

    return jsonify({
        "id": row[0],
        "name": row[1],
        "status": row[2],
    })


init_db()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)