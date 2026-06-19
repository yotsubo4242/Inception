#!/bin/bash
set -e

if [ -f "/run/secrets/db_root_password" ]; then
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f "/run/secrets/db_password" ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mysqld --user=mysql &
    pid=$!

    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done

    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $pid
fi

exec mysqld --user=mysql
