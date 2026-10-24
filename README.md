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
`octane-alpine` is the image name. It does not include the Alpine release, so that release is a suffix on the tag, the same place the official PHP image puts it (`8.5.12-cli-alpine3.24`).

One build is pushed to four tags. `8.5-swoole-mysql` and `8.5.12-swoole-mysql` are the same image: the minor tag follows the newest patch, and the patch tag is the one to pin when a deploy must include a specific PHP security release. Variants are `swoole-mysql`, `swoole-pgsql`, `swoole-mysql-dev`, and `swoole-pgsql-dev`.

| Tag | Example | When it moves |
| --- | --- | --- |
| `<minor>-<variant>` | `8.5-swoole-mysql` | Next PHP patch, or the next Alpine version in the build matrix |
| `<patch>-<variant>` | `8.5.12-swoole-mysql` | Rebuilds of this PHP patch. Stops moving once that Dockerfile leaves 8.5.12 |
| `<minor>-<variant>-alpine<version>` | `8.5-swoole-mysql-alpine3.24` | Next PHP patch, while this Alpine release is still the one being built |
| `<patch>-<variant>-alpine<version>` | `8.5.12-swoole-mysql-alpine3.24` | Same rebuilds. The name stays on Alpine 3.24 after a later Alpine bump |

```bash
docker pull ghcr.io/esfahanahan/octane-alpine:8.5-swoole-mysql
docker pull ghcr.io/esfahanahan/octane-alpine:8.5.12-swoole-mysql
docker pull ghcr.io/esfahanahan/octane-alpine:8.5.12-swoole-mysql-alpine3.24
```

PHP lines currently built, including the fixes for CVE-2026-109618 and CVE-2026-109619: `8.2.35`, `8.3.36`, `8.4.27`, `8.5.12` on Alpine 3.24. There is no `latest` tag. Pin a digest when a deploy must not change on rebuild.

Each release is the `FROM` image in its Dockerfile, such as `docker/8.5-mysql.Dockerfile`. Dependabot checks those tags daily and opens a pull request when a newer patch of the same PHP line and Alpine release is published. A new minor line, such as 8.6, needs its own Dockerfile.

The `-dev` variants add git, Node.js, npm, zsh, and start Octane with `--watch`. They use the same tag pattern, for example `8.5.12-swoole-mysql-dev`.

## Usage
To run from current dir:
```bash
docker run --rm -v $(pwd):/var/www -p 8000:8000 ghcr.io/esfahanahan/octane-alpine:8.5-swoole-mysql
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
- exif
- gd
- intl
- opcache
- pcntl
- pdo
- pdo_mysql/pdo_pgsql (depending on variant)
- redis
- soap
- sockets
- swoole
- xml
- zip


## Adding other PHP Extension
You can add additional PHP Extensions by running `docker-php-ext-install` command. Don't forget to install necessary dependencies for required extension.
```dockerfile
FROM ghcr.io/esfahanahan/octane-alpine:8.5-swoole-mysql
RUN docker-php-ext-install xdebug
```

## Adding a cronjob
```dockerfile
FROM ghcr.io/esfahanahan/octane-alpine:8.5-swoole-mysql

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
FROM ghcr.io/esfahanahan/octane-alpine:8.5-swoole-mysql
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

