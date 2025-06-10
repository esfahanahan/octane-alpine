# Laravel Octane Alpine
High-performance PHP Docker image optimized for **Laravel Octane** with **Swoole** on **Alpine** Linux 🚀


![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/esfahanahan/octane-alpine/build-docker.yml?style=for-the-badge)
[![LICENSE](https://img.shields.io/github/license/esfahanahan/octane-alpine.svg?style=for-the-badge)](https://github.com/esfahanahan/octane-alpine/blob/master/LICENSE)
[![Stars Count](https://img.shields.io/github/stars/esfahanahan/octane-alpine.svg?style=for-the-badge)](https://github.com/esfahanahan/octane-alpine/stargazers)
[![Forks Count](https://img.shields.io/github/forks/esfahanahan/octane-alpine.svg?style=for-the-badge)](https://github.com/esfahanahan/octane-alpine/network/members)
[![Watchers Count](https://img.shields.io/github/watchers/esfahanahan/octane-alpine.svg?style=for-the-badge)](https://github.com/esfahanahan/octane-alpine/watchers)
[![Issues Count](https://img.shields.io/github/issues/esfahanahan/octane-alpine.svg?style=for-the-badge)](https://github.com/esfahanahan/octane-alpine/issues)
[![Pull Request Count](https://img.shields.io/github/issues-pr/esfahanahan/octane-alpine.svg?style=for-the-badge)](https://github.com/esfahanahan/octane-alpine/pulls)
[![Follow](https://img.shields.io/github/followers/esfahanahan.svg?style=for-the-badge&label=Follow&maxAge=2592000)](https://github.com/esfahanahan)


## About
This Docker image is specifically designed for running Laravel Octane with Swoole on Alpine Linux. Swoole acts as a high-performance web server and application runtime, eliminating the need for traditional web servers like Nginx or process managers like PHP-FPM. This results in significantly improved performance for Laravel applications.

## Available Variants
- PHP 8.2 with Swoole (**MySQL** / **PostgreSQL**)
  ```bash
  docker pull ghcr.io/esfahanahan/octane-alpine:8.2-swoole-mysql
  docker pull ghcr.io/esfahanahan/octane-alpine:8.2-swoole-pgsql
  ```
- PHP 8.3 with Swoole (**MySQL** / **PostgreSQL**)
  ```bash
  docker pull ghcr.io/esfahanahan/octane-alpine:8.3-swoole-mysql
  docker pull ghcr.io/esfahanahan/octane-alpine:8.3-swoole-pgsql
  ```

## Usage
To run from current dir:
```bash
docker run --rm -v $(pwd):/var/www -p 8000:8000 ghcr.io/esfahanahan/octane-alpine:8.3-swoole-mysql
```

Note: The container exposes port 8000 by default, which is the standard port for Laravel Octane with Swoole.

Note: The `--rm` flag automatically removes the container when it exits, preventing the accumulation of stopped containers on your system.

## What's Included
 - [Composer](https://getcomposer.org/) (v2 - updated)
 - [Laravel Octane](https://laravel.com/docs/octane) with Swoole Server
 - [Go-Supervisor](https://github.com/QPod/supervisord) for process management
 - Node.js & NPM for watch files (development)
 - Swoole Extension with the following features:
   - Sockets
   - OpenSSL
   - Brotli compression
   - Zstd compression
   - MySQL/PostgreSQL support
   - SQLite support
   - cURL support

## PHP Extension
- bcmath
- bz2
- exif
- gd
- gmp
- intl
- mysqli/pgsql (depending on variant)
- opcache
- pcntl
- pdo
- pdo_mysql/pdo_pgsql (depending on variant)
- sockets
- swoole
- xml
- zip


## Adding other PHP Extension
You can add additional PHP Extensions by running `docker-php-ext-install` command. Don't forget to install necessary dependencies for required extension.
```dockerfile
FROM ghcr.io/esfahanahan/octane-alpine:8.3-swoole-mysql
RUN docker-php-ext-install xdebug
```

## Adding a cronjob
```dockerfile
FROM ghcr.io/esfahanahan/octane-alpine:8.3-swoole-mysql

RUN echo '* * * * * /usr/local/bin/php /var/www/artisan schedule:run >> /dev/null 2>&1' >> /etc/crontab
```
 
## Adding custom Supervisor config
You can add your own Supervisor config inside `/etc/supervisor.d/`. File extension needs to be `*.conf`. By default, this image only runs the Swoole server process via supervisor.

Example for a custom service:
```ini
[program:my-service]
process_name=%(program_name)s
command=php /var/www/artisan my-service:start
autostart=true
autorestart=true
redirect_stderr=true
```

On your Docker image:
```dockerfile
FROM ghcr.io/esfahanahan/octane-alpine:8.3-swoole-mysql
ADD my-service.conf /etc/supervisor.d/
```
For more details please refrer to [QPod/supervisord](https://github.com/QPod/supervisord/blob/main/doc/doc-config.md) documentions.

## Supervisor Configuration
By default, this image runs Laravel Octane with Swoole using the following supervisor configuration:
```ini
[program:swoole]
command=php -d variables_order=EGPCS artisan octane:start --server=swoole --workers=4 --max-requests=250
user=www-data
autostart=true
autorestart=true
```

## Bug Reporting

If you find any bugs, please report it by submitting an issue on our [issue page](https://github.com/esfahanahan/octane-alpine/issues) with a detailed explanation. Giving some screenshots would also be very helpful.

## Feature Request

You can also submit a feature request on our [issue page](https://github.com/esfahanahan/octane-alpine) or [discussions](https://github.com/esfahanahan/octane-alpine/discussions) and we will try to implement it as soon as possible.

