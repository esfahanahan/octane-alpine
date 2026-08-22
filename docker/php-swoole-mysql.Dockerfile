# values: 8.2, 8.3, 8.4, 8.5
ARG PHP_VERSION=8.5

FROM ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-mysql

LABEL org.opencontainers.image.title="PHP ${PHP_VERSION} with Swoole, MySQL, and Supervisor"
LABEL org.opencontainers.image.description="PHP ${PHP_VERSION} with Swoole, MySQL, and Supervisor including extensions: (bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_mysql, redis, soap, sockets, swoole, xml, zip) based on ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-mysql"

ENV OCTANE_SERVER=swoole

USER root

RUN --mount=type=bind,source=fs/common,target=/mnt/fs apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
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
    apk del --no-network .build-deps && \
    cp -v -R /mnt/fs/* /

USER www-data
