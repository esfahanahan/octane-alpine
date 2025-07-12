# values: 8.2, 8.3
ARG PHP_VERSION=8.3

FROM ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-mysql

LABEL org.opencontainers.image.title="PHP ${PHP_VERSION} with Swoole, MySQL, and Supervisor"
LABEL org.opencontainers.image.description="PHP ${PHP_VERSION} with Swoole, MySQL, and Supervisor including extensions: (bcmath, bz2, exif, gd, gmp, intl, mysqli, opcache, pcntl, pdo, pdo_mysql, sockets, xml, zip, inotify, exif, memcached, redis) based on ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-mysql"

ENV OCTANE_SERVER=swoole

USER root

RUN --mount=type=bind,source=fs/dev,target=/mnt/fs apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
        curl-dev \
        brotli-dev && \
    pecl install --configureoptions \
        "enable-sockets='yes' enable-openssl='yes' enable-brotli='yes' enable-zstd='yes' enable-mysqlnd='yes' enable-swool-sqlite='yes' enable-swoole-curl='yes'" \
        swoole && \
    docker-php-ext-enable swoole && \
    apk del --no-network .build-deps && \
    cp -v -R /mnt/fs/* /

RUN apk add --no-cache \
        nodejs \
        npm \
        git \
        zsh && \
    git config --global --add safe.directory /var/www

USER www-data

RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/omz-install.sh && \
    chmod +x /tmp/omz-install.sh && \
    /tmp/omz-install.sh --unattended && \
    sed -i 's/^plugins=(git)$/plugins=(git laravel)/' /home/www-data/.zshrc && \
    rm -f /tmp/omz-install.sh
