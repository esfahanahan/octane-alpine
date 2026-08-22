# values: 8.2, 8.3, 8.4, 8.5
ARG PHP_VERSION=8.5

FROM ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-pgsql

LABEL org.opencontainers.image.title="PHP ${PHP_VERSION} with Swoole, PostgreSQL, and Supervisor"
LABEL org.opencontainers.image.description="PHP ${PHP_VERSION} with Swoole, PostgreSQL, and Supervisor including extensions: (bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_pgsql, redis, soap, sockets, swoole, xml, zip) based on ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-pgsql"

ENV OCTANE_SERVER=swoole

USER root

RUN --mount=type=bind,source=fs/dev,target=/mnt/fs apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
        brotli-dev \
        curl-dev \
        linux-headers \
        openssl-dev \
        postgresql-dev \
        sqlite-dev \
        zstd-dev && \
    pecl install --configureoptions \
        "enable-brotli='yes' enable-openssl='yes' enable-sockets='yes' enable-swoole-curl='yes' enable-swoole-pgsql='yes' enable-swoole-sqlite='yes' enable-zstd='yes'" \
        swoole && \
    docker-php-ext-enable swoole && \
    apk del --no-network .build-deps && \
    cp -v -R /mnt/fs/* /

RUN apk add --no-cache \
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
