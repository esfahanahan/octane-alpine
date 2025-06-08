FROM ghcr.io/esfahanahan/php-alpine:8.3-mysql

LABEL org.opencontainers.image.title="PHP 8.3 with Swoole, MySQL, and Supervisor"
LABEL org.opencontainers.image.description="PHP 8.3 with Swoole, MySQL, and Supervisor including extensions: (bcmath, bz2, exif, gd, gmp, intl, mysqli, opcache, pcntl, pdo, pdo_mysql, sockets, xml, zip, inotify, exif, memcached, redis) based on ghcr.io/esfahanahan/php-alpine:8.3-mysql"

ENV OCTANE_SERVER=swoole

RUN --mount=type=bind,source=fs,target=/mnt apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
        curl-dev \
        brotli-dev && \
    pecl install --configureoptions \
        "enable-sockets='yes' enable-openssl='yes' enable-brotli='yes' enable-zstd='yes' enable-mysqlnd='yes' enable-swool-sqlite='yes' enable-swoole-curl='yes'" \
        swoole && \
    docker-php-ext-enable swoole && \
    apk del --no-network .build-deps && \
    cp -v /mnt/etc/supervisor/conf.d/20-octane-swoole.conf /etc/supervisor/conf.d/20-swool.conf
