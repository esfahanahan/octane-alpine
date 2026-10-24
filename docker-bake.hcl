// Shared build for the four Octane variant Dockerfiles.
// Tags, labels, and annotations come from docker/metadata-action,
// which fills the docker-metadata-action target in CI.

variable "PHP_VERSION" {
  default = "8.5"
}

variable "ALPINE_VERSION" {
  default = "3.24"
}

target "docker-metadata-action" {}

target "_common" {
  inherits   = ["docker-metadata-action"]
  context    = "."
  // The php-alpine base image is published as linux/amd64.
  platforms  = ["linux/amd64"]
  args = {
    PHP_VERSION    = PHP_VERSION
    ALPINE_VERSION = ALPINE_VERSION
  }
}

target "swoole-mysql" {
  inherits   = ["_common"]
  dockerfile = "docker/php-swoole-mysql.Dockerfile"
}

target "swoole-mysql-dev" {
  inherits   = ["_common"]
  dockerfile = "docker/php-swoole-mysql-dev.Dockerfile"
}

target "swoole-pgsql" {
  inherits   = ["_common"]
  dockerfile = "docker/php-swoole-pgsql.Dockerfile"
}

target "swoole-pgsql-dev" {
  inherits   = ["_common"]
  dockerfile = "docker/php-swoole-pgsql-dev.Dockerfile"
}

group "default" {
  targets = ["swoole-mysql", "swoole-mysql-dev", "swoole-pgsql", "swoole-pgsql-dev"]
}
