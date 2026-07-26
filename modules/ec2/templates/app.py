import json
import os

import boto3
import psycopg2
import requests
from flask import Flask, jsonify

app = Flask(__name__)

# Injected via the systemd unit in user_data.sh.tpl — set by Terraform from RDS module outputs.
DB_HOST = os.environ["DB_HOST"]
DB_PORT = os.environ["DB_PORT"]
DB_NAME = os.environ["DB_NAME"]
DB_SECRET_ARN = os.environ["DB_SECRET_ARN"]

IMDS_BASE_URL = "http://169.254.169.254/latest"


# Reads the region from EC2 instance metadata (IMDSv2) instead of a Terraform variable, so the
# module stays region-agnostic — region is configured once, at the provider level, nowhere else.
# The token step (vs. plain IMDSv1 GETs) is required because IMDSv1 is vulnerable to SSRF: an
# unrelated bug that tricks the app into fetching an arbitrary URL could leak the instance's IAM
# credentials. IMDSv2's PUT-then-GET handshake closes that off.
def get_region_from_imds():
    token = requests.put(
        f"{IMDS_BASE_URL}/api/token",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
        timeout=2,
    ).text
    return requests.get(
        f"{IMDS_BASE_URL}/meta-data/placement/region",
        headers={"X-aws-ec2-metadata-token": token},
        timeout=2,
    ).text


AWS_REGION = get_region_from_imds()

# Resolved once at process start (boot), per the CLAUDE.md decision — the master password is never
# passed through user-data in plaintext, and we avoid re-hitting Secrets Manager on every request.
_secrets_client = boto3.client("secretsmanager", region_name=AWS_REGION)
_secret = json.loads(_secrets_client.get_secret_value(SecretId=DB_SECRET_ARN)["SecretString"])
DB_USER = _secret["username"]
DB_PASSWORD = _secret["password"]


def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5,
    )


# Creates the demo table on first run so /db-check has something to read and write —
# there is no separate migration step for a smoke-test database.
def ensure_smoketest_table(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS smoketest_checks (
                id SERIAL PRIMARY KEY,
                checked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
                source_host TEXT NOT NULL
            )
            """
        )
    conn.commit()


# Liveness probe for the app process itself — does not touch the database.
@app.route("/health")
def health():
    return jsonify(status="ok")


# End-to-end proof that this instance can reach RDS: writes a row recording the check, then
# reads back recent rows so the response actually shows live database contents, not just a ping.
@app.route("/db-check")
def db_check():
    try:
        conn = get_db_connection()
        ensure_smoketest_table(conn)
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO smoketest_checks (source_host) VALUES (%s)",
                (os.uname().nodename,),
            )
            cur.execute(
                "SELECT id, checked_at, source_host FROM smoketest_checks ORDER BY id DESC LIMIT 10"
            )
            rows = cur.fetchall()
        conn.commit()
        conn.close()
        return jsonify(
            status="ok",
            db="reachable",
            recent_checks=[
                {"id": row[0], "checked_at": row[1].isoformat(), "source_host": row[2]}
                for row in rows
            ],
        )
    except Exception as exc:
        return jsonify(status="error", db="unreachable", detail=str(exc)), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ["APP_PORT"]))
