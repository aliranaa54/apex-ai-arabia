#!/usr/bin/env bash
# Goes back to the version in .previous_version. Old images are still on the machine, so no rebuild is needed.
set -euo pipefail
cd "$(dirname "$0")/.."
PREV=$(cat .previous_version 2>/dev/null) || { echo "No previous version recorded"; exit 1; }
docker image inspect "apex-ops-api:$PREV" >/dev/null || { echo "Image apex-ops-api:$PREV not found"; exit 1; }
echo "Rolling back to $PREV"
sed -i "s/^APP_VERSION=.*/APP_VERSION=$PREV/" .env
docker compose up -d --no-deps --no-build api
scripts/wait_healthy.sh && echo "Rollback to $PREV done."
