#!/usr/bin/env bash
# Usage: scripts/release.sh 1.1.0  -> builds apex-ops-api:1.1.0, deploys it, checks health.
# The version that was running before is saved in .previous_version so rollback.sh knows where to go.
set -euo pipefail
cd "$(dirname "$0")/.."
NEW="${1:?usage: release.sh <version>}"
CURRENT=$(grep -E '^APP_VERSION=' .env | cut -d= -f2 || true)

echo "Building apex-ops-api:$NEW"
APP_VERSION="$NEW" docker compose build api
[ -n "$CURRENT" ] && echo "$CURRENT" > .previous_version
sed -i "s/^APP_VERSION=.*/APP_VERSION=$NEW/" .env

echo "Deploying $NEW (was: ${CURRENT:-none})"
docker compose up -d --wait db   # make sure the database is running first
docker compose up -d --no-deps api
scripts/wait_healthy.sh || { echo "Release $NEW is unhealthy -> rolling back"; scripts/rollback.sh; exit 1; }
echo "Release $NEW is live."
