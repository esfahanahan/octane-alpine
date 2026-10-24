#!/usr/bin/env python3
"""Expand docker/pins into the image build matrix."""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PIN_DIR = ROOT / "docker" / "pins"
PIN_RE = re.compile(
    r"^FROM ghcr\.io/esfahanahan/php-alpine:"
    r"(?P<patch>\d+\.\d+\.\d+)-(?P<base>mysql|pgsql)-alpine(?P<alpine>\d+\.\d+)\s*$"
)

VARIANTS = {
    "mysql": [
        {
            "name": "swoole-mysql",
            "base": "mysql",
            "stack": "Swoole, MySQL, and Supervisor",
            "extensions": "bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_mysql, redis, soap, sockets, swoole, xml, zip",
        },
        {
            "name": "swoole-mysql-dev",
            "base": "mysql",
            "stack": "Swoole, MySQL, Supervisor, and development tools",
            "extensions": "bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_mysql, redis, soap, sockets, swoole, xml, zip",
        },
    ],
    "pgsql": [
        {
            "name": "swoole-pgsql",
            "base": "pgsql",
            "stack": "Swoole, PostgreSQL, and Supervisor",
            "extensions": "bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_pgsql, redis, soap, sockets, swoole, xml, zip",
        },
        {
            "name": "swoole-pgsql-dev",
            "base": "pgsql",
            "stack": "Swoole, PostgreSQL, Supervisor, and development tools",
            "extensions": "bcmath, exif, gd, intl, opcache, pcntl, pdo, pdo_pgsql, redis, soap, sockets, swoole, xml, zip",
        },
    ],
}


def pin_from(path: Path) -> dict:
    lines = [
        line.strip()
        for line in path.read_text().splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    if len(lines) != 1:
        raise SystemExit(f"{path} must contain one FROM line")

    match = PIN_RE.match(lines[0])
    if match is None:
        raise SystemExit(f"{path} has an unrecognized FROM line: {lines[0]}")

    patch = match.group("patch")
    minor = ".".join(patch.split(".")[:2])
    base = match.group("base")
    expected = f"{minor}-{base}.Dockerfile"
    if path.name != expected:
        raise SystemExit(f"{path.name} should be named {expected}")

    return {
        "minor": minor,
        "patch": patch,
        "base": base,
        "alpine": match.group("alpine"),
    }


def main() -> None:
    paths = sorted(PIN_DIR.glob("*.Dockerfile"))
    if not paths:
        raise SystemExit(f"no image pins in {PIN_DIR}")

    pins = [pin_from(path) for path in paths]
    alpine_for_minor = {}
    seen = set()
    for pin in pins:
        key = (pin["minor"], pin["base"])
        if key in seen:
            raise SystemExit(f"duplicate pin for PHP {pin['minor']} {pin['base']}")
        seen.add(key)
        previous = alpine_for_minor.setdefault(pin["minor"], pin["alpine"])
        if previous != pin["alpine"]:
            raise SystemExit(
                f"PHP {pin['minor']} pins more than one Alpine release: "
                f"{previous} and {pin['alpine']}"
            )

    pins.sort(key=lambda pin: [int(part) for part in pin["patch"].split(".")], reverse=True)

    include = []
    for pin in pins:
        for variant in VARIANTS[pin["base"]]:
            include.append(
                {
                    "php": {"version": pin["minor"], "patch": pin["patch"]},
                    "alpine": pin["alpine"],
                    "variant": variant,
                }
            )

    json.dump(include, sys.stdout, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
