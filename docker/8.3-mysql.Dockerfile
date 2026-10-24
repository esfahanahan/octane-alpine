FROM ghcr.io/esfahanahan/php-alpine:8.3.36-mysql-alpine3.24 AS swoole

ENV OCTANE_SERVER=swoole

USER root

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
        brotli-dev \
        curl-dev \
        linux-headers \
        openssl-dev \
        sqlite-dev \
        zstd-dev && \
    pecl install --configureoptions \
        "enable-brotli='yes' enable-mysqlnd='yes' enable-openssl='yes' enable-sockets='yes' enable-swoole-curl='yes' enable-swoole-sqlite='yes' enable-zstd='yes'" \
        swoole && \
    docker-php-ext-enable swoole && \
    apk del --no-network .build-deps

FROM swoole AS swoole-mysql-dev

LABEL org.opencontainers.image.title="PHP 8.3.36 with Swoole, MySQL, Supervisor, and development tools"
LABEL org.opencontainers.image.description="PHP 8.3.36 with Swoole, MySQL, Supervisor, and development tools including extensions: (bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_mysql, redis, soap, sockets, swoole, xml, zip) based on ghcr.io/esfahanahan/php-alpine:8.3.36-mysql-alpine3.24"

USER root

RUN --mount=type=bind,source=fs/dev,target=/mnt/fs \
    cp -v -R /mnt/fs/* / && \
    apk add --no-cache \
        git \
        nodejs \
        npm \
        zsh && \
    git config --global --add safe.directory /var/www

USER www-data

RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/omz-install.sh && \
    chmod +x /tmp/omz-install.sh && \
    /tmp/omz-install.sh --unattended && \
    sed -i 's/^plugins=(git)$/plugins=(git laravel)/' /home/www-data/.zshrc && \
    rm -f /tmp/omz-install.sh

FROM swoole AS swoole-mysql

LABEL org.opencontainers.image.title="PHP 8.3.36 with Swoole, MySQL, and Supervisor"
LABEL org.opencontainers.image.description="PHP 8.3.36 with Swoole, MySQL, and Supervisor including extensions: (bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_mysql, redis, soap, sockets, swoole, xml, zip) based on ghcr.io/esfahanahan/php-alpine:8.3.36-mysql-alpine3.24"

USER root

RUN --mount=type=bind,source=fs/common,target=/mnt/fs cp -v -R /mnt/fs/* /

USER www-data
