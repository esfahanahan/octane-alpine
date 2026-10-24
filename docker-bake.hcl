// Shared build for the Octane variant Dockerfiles.
// Tags, labels, and annotations come from docker/metadata-action,
// which fills the docker-metadata-action target in CI.
// CI selects docker/<line>-<base>.Dockerfile. These defaults build PHP 8.5.

target "docker-metadata-action" {}

target "_common" {
  inherits  = ["docker-metadata-action"]
  context   = "."
  // The php-alpine base image is published as linux/amd64.
  platforms = ["linux/amd64"]
}

target "swoole-mysql" {
  inherits   = ["_common"]
  dockerfile = "docker/8.5-mysql.Dockerfile"
  target     = "swoole-mysql"
}

target "swoole-mysql-dev" {
  inherits   = ["_common"]
  dockerfile = "docker/8.5-mysql.Dockerfile"
  target     = "swoole-mysql-dev"
}

target "swoole-pgsql" {
  inherits   = ["_common"]
  dockerfile = "docker/8.5-pgsql.Dockerfile"
  target     = "swoole-pgsql"
}

target "swoole-pgsql-dev" {
  inherits   = ["_common"]
  dockerfile = "docker/8.5-pgsql.Dockerfile"
  target     = "swoole-pgsql-dev"
}

group "default" {
  targets = ["swoole-mysql", "swoole-mysql-dev", "swoole-pgsql", "swoole-pgsql-dev"]
}
