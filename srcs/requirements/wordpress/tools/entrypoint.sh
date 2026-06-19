#!/bin/bash
set -e

if [ -f "/run/secrets/db_password" ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f "/run/secrets/credentials" ]; then
    WP_ADMIN_PASSWORD=$(sed -n '1p' /run/secrets/credentials)
    WP_USER_PASSWORD=$(sed -n '2p' /run/secrets/credentials)
fi

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
    wp core download --allow-root --force

    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306"

    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    wp user create --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}"
fi

exec php-fpm7.4 -F
