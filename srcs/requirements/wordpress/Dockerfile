FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-xml \
    php7.4-mbstring \
    php7.4-gd \
    ca-certificates \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN mkdir -p /run/php && chown www-data:www-data /run/php
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
