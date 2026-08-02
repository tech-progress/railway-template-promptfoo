#!/bin/sh
set -eu

config_dir="${PROMPTFOO_CONFIG_DIR:-/home/promptfoo/.promptfoo}"
mkdir -p "${config_dir}"
chown -R promptfoo:promptfoo "${config_dir}"

exec su -s /bin/sh promptfoo -c 'exec "$@"' sh docker-entrypoint.sh "$@"
