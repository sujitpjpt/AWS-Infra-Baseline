#!/bin/bash
set -euo pipefail

# AL2023 ships Python 3 but not pip — needed to install the app's dependencies below.
dnf install -y python3-pip

# Terraform's templatefile() has already substituted $${app_py} with the full contents of app.py before this script ever reaches the instance, so this just writes the rendered source to disk.
mkdir -p /opt/app
cat > /opt/app/app.py << 'PYEOF'
${app_py}
PYEOF

# psycopg2-binary bundles its own libpq, so no separate Postgres client package is needed.
# requests is used only for the IMDSv2 region lookup in app.py.
pip3 install flask boto3 psycopg2-binary requests

# Run the app under systemd (not a bare background process) so it restarts on crash and on reboot.
# DB connection details and the Secrets Manager ARN are injected as env vars, never hardcoded or
# passed through user-data in plaintext credentials — the app fetches the actual password itself.
# Region is not passed here at all — app.py resolves it from instance metadata at boot.
cat > /etc/systemd/system/smoketest-app.service << 'UNITEOF'
[Unit]
Description=Smoke-test Flask app querying RDS
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/app/app.py
Restart=on-failure
Environment=DB_HOST=${db_host}
Environment=DB_PORT=${db_port}
Environment=DB_NAME=${db_name}
Environment=DB_SECRET_ARN=${db_secret_arn}
Environment=APP_PORT=${app_port}

[Install]
WantedBy=multi-user.target
UNITEOF

systemctl daemon-reload
systemctl enable --now smoketest-app.service
