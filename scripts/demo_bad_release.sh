#!/usr/bin/env bash
# Shows automatic rollback: releases a deliberately broken version (/readyz always 503)
# from a throwaway copy of the repo and lets release.sh roll it back by itself.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
tar -C "$ROOT" --exclude=.git --exclude=.ruff_cache --exclude=__pycache__ -cf - . | tar -C "$TMP" -xf -
export COMPOSE_PROJECT_NAME="$(basename "$ROOT")"      # same containers/network/volume as the real stack
sed -i 's|if store.ping():  # readiness.*|if False:  # BROKEN ON PURPOSE (demo)|' "$TMP/app/main.py"
grep -n "BROKEN ON PURPOSE" "$TMP/app/main.py"
echo "Running version before: $(curl -s localhost:8000/version)"
echo '$ scripts/release.sh 2.0.0-bad'
(cd "$TMP" && ./scripts/release.sh 2.0.0-bad)
echo "exit code of release.sh: $?"
echo "Running version after:  $(curl -s localhost:8000/version)"
docker compose -f "$ROOT/docker-compose.yml" --project-directory "$ROOT" ps --format '{{.Service}} {{.Image}} {{.Status}}'
