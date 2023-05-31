FROM alpine:3.17
LABEL Maintainer="Maarten den Braber <m@mdbraber.com>" \
      Description="Lightweight WordPress container with Nginx 1.22 & PHP-FPM 8.0 & SQLite support based on Alpine Linux."

# WordPress
ENV WORDPRESS_VERSION=6.2.2
ENV WORDPRESS_SHA1=a355d1b975405a391c4a78f988d656b375683fb2
ENV SQLITE_INTEGRATION_VERSION=2.1.1 
ENV WP_SUPERCACHE_VERSION=1.9.4
ENV WORDPRESS_DB_HOST=localhost
ENV WORDPRESS_DB_USER=not-used
ENV WORDPRESS_DB_PASSWORD=not-used
ENV WORDPRESS_DB_NAME=not-used

# Install packages
RUN apk --no-cache add \
  php81 \
  php81-fpm \
  php81-pdo \
  php81-pdo_sqlite \
  php81-sqlite3 \
  php81-json \
  php81-openssl \
  php81-curl \
  php81-zlib \
  php81-xml \
  php81-phar \
  php81-intl \
  php81-dom \
  php81-xmlreader \
  php81-xmlwriter \
  php81-exif \
  php81-fileinfo \
  php81-sodium \
  php81-gd \
  php81-simplexml \
  php81-ctype \
  php81-mbstring \
  php81-zip \
  php81-opcache \
  php81-iconv \
  php81-pecl-imagick \
  nginx \
  supervisor \
  sqlite \
  curl \
  unzip \
  bash \
  less

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php81/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# wp-content volume
VOLUME /var/www/wp-content
WORKDIR /var/www/wp-content
RUN chown -R nobody.nobody /var/www

# Upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN mkdir -p /usr/src \
    && curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
    && echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
    && tar -xzf wordpress.tar.gz -C /usr/src/ \
    && rm wordpress.tar.gz 

# Add sqlite-database-integration plugin
RUN curl -L -o sqlite-database-integration.tar.gz https://github.com/WordPress/sqlite-database-integration/archive/refs/tags/v${SQLITE_INTEGRATION_VERSION}.tar.gz \
    && mkdir /usr/src/wordpress/wp-content/plugins/sqlite-database-integration \
    && tar -xzf sqlite-database-integration.tar.gz -C /usr/src/wordpress/wp-content/plugins/sqlite-database-integration --strip-components=1 \
    && cp /usr/src/wordpress/wp-content/plugins/sqlite-database-integration/db.copy /usr/src/wordpress/wp-content/db.php \
    && rm sqlite-database-integration.tar.gz \
    && sed -i 's#{SQLITE_IMPLEMENTATION_FOLDER_PATH}#/var/www/wp-content/plugins/sqlite-database-integration#' /usr/src/wordpress/wp-content/db.php \
    && sed -i 's#{SQLITE_PLUGIN}#sqlite-database-integration/load.php#' /usr/src/wordpress/wp-content/db.php \
    && mkdir /usr/src/wordpress/wp-content/database \
    && touch /usr/src/wordpress/wp-content/database/.ht.sqlite \
    && chmod 640 /usr/src/wordpress/wp-content/database/.ht.sqlite

RUN curl -L -o mysql2sqlite https://raw.githubusercontent.com/dumblob/mysql2sqlite/master/mysql2sqlite \
    && mv mysql2sqlite /usr/local/bin \
    && chmod 755 /usr/local/bin/mysql2sqlite

# Add WP Super Cache plugin
RUN curl -L -o wp-super-cache.zip https://downloads.wordpress.org/plugin/wp-super-cache.${WP_SUPERCACHE_VERSION}.zip \
    && unzip wp-super-cache.zip -d /usr/src/wordpress/wp-content/plugins/ \
    && cp /usr/src/wordpress/wp-content/plugins/wp-super-cache/wp-cache-config-sample.php /usr/src/wordpress/wp-content/wp-cache-config.php \
    && cp /usr/src/wordpress/wp-content/plugins/wp-super-cache/advanced-cache.php /usr/src/wordpress/wp-content

# Setup wp-config
COPY wp-config.php /usr/src/wordpress
RUN chmod 640 /usr/src/wordpress/wp-config.php

# Add WP CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Append WP secrets
COPY wp-secrets.php /usr/src/wordpress
RUN chmod 640 /usr/src/wordpress/wp-secrets.php

# Set ownership
RUN chown -R nobody.nobody /usr/src/wordpress

# Entrypoint to copy wp-content
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/wp-login.php
