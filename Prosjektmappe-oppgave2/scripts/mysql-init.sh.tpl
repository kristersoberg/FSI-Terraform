#!/bin/bash
set -e

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

# Allow MySQL to accept connections from any interface, not just localhost.
# The NSG restricts who can actually reach port 3306, so this is safe.
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
# skip-name-resolve makes MySQL match users by IP instead of hostname.
echo "skip-name-resolve = ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql
systemctl enable mysql

# Wait until MySQL is accepting connections before running setup queries.
until mysql -u root -e "SELECT 1" &>/dev/null; do
  sleep 2
done

# webuser is created with mysql_native_password to avoid caching_sha2_password
# compatibility issues with mysql-connector-python over non-SSL connections.
mysql -u root <<SQL
CREATE DATABASE IF NOT EXISTS webapp;
USE webapp;
CREATE TABLE IF NOT EXISTS messages (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  message    VARCHAR(255) NOT NULL,
  db_host    VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO messages (message, db_host) VALUES
  ('Hello from the database!', @@hostname),
  ('High availability is working.', @@hostname);
CREATE USER IF NOT EXISTS 'webuser'@'10.0.1.%' IDENTIFIED BY '${mysql_app_password}';
GRANT SELECT ON webapp.* TO 'webuser'@'10.0.1.%';
FLUSH PRIVILEGES;
SQL
