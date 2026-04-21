#!/bin/bash
set -e

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx python3 python3-pip

pip3 install flask pymysql cryptography

mkdir -p /opt/webapp

# Terraform replaces ${db_host} and ${mysql_app_password} before this script
# reaches the VM, so the actual values are baked into the Python source file.
cat > /opt/webapp/app.py <<'PYEOF'
from flask import Flask
import pymysql
import socket

app = Flask(__name__)

DB_HOST = "${db_host}"
DB_USER = "webuser"
DB_PASS = "${mysql_app_password}"
DB_NAME = "webapp"

@app.route("/")
def index():
    try:
        conn = pymysql.connect(
            host=DB_HOST, user=DB_USER, password=DB_PASS,
            database=DB_NAME, connect_timeout=5
        )
        cursor = conn.cursor()
        cursor.execute("SELECT message, db_host, created_at FROM messages")
        rows = cursor.fetchall()
        conn.close()

        rows_html = ""
        for msg, db_host, ts in rows:
            rows_html += (
                "<tr><td>" + str(msg) +
                "</td><td>" + str(db_host) +
                "</td><td>" + str(ts) + "</td></tr>"
            )

        return (
            "<html><body>"
            "<h1>Web server: " + socket.gethostname() + "</h1>"
            "<h2>Data from database (" + DB_HOST + "):</h2>"
            "<table border='1'>"
            "<tr><th>Message</th><th>DB Host</th><th>Timestamp</th></tr>"
            + rows_html +
            "</table></body></html>"
        )
    except Exception as e:
        return "<h1>Database connection error</h1><pre>" + str(e) + "</pre>", 500

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
PYEOF

# Run Flask as a background service
cat > /etc/systemd/system/webapp.service <<'SVCEOF'
[Unit]
Description=Flask Web App
After=network.target

[Service]
User=root
WorkingDirectory=/opt/webapp
ExecStart=/usr/bin/python3 /opt/webapp/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable webapp
systemctl start webapp

# Configure nginx as a reverse proxy in front of Flask
rm -f /etc/nginx/sites-enabled/default

cat > /etc/nginx/sites-available/webapp <<'NGINXEOF'
server {
    listen 80;

    location / {
        proxy_pass         http://127.0.0.1:5000;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
    }
}
NGINXEOF

ln -s /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/webapp

systemctl restart nginx
systemctl enable nginx
