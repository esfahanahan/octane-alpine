# values: 8.2, 8.3
ARG PHP_VERSION=8.3

FROM ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-mysql

LABEL org.opencontainers.image.title="PHP ${PHP_VERSION} with Swoole, MySQL, and Supervisor"
LABEL org.opencontainers.image.description="PHP ${PHP_VERSION} with Swoole, MySQL, and Supervisor including extensions: (bcmath, bz2, exif, gd, gmp, intl, mysqli, opcache, pcntl, pdo, pdo_mysql, sockets, xml, zip, inotify, exif, memcached, redis) based on ghcr.io/esfahanahan/php-alpine:${PHP_VERSION}-mysql"

ENV OCTANE_SERVER=swoole

USER root

RUN --mount=type=bind,source=fs,target=/mnt/fs apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
        curl-dev \
        brotli-dev && \
    pecl install --configureoptions \
        "enable-sockets='yes' enable-openssl='yes' enable-brotli='yes' enable-zstd='yes' enable-mysqlnd='yes' enable-swool-sqlite='yes' enable-swoole-curl='yes'" \
        swoole && \
    docker-php-ext-enable swoole && \
    apk del --no-network .build-deps && \
    cp -v -R /mnt/fs/* /

USER www-data
