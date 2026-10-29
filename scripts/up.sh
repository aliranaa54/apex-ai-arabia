#!/usr/bin/env bash
# One command to start everything: ./scripts/up.sh
# First run creates .env with a random database password (never committed), then runs docker compose.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -f .env ]; then
  cp .env.example .env
  sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$(head -c 24 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 20)/" .env
  echo "Created .env with a random database password."
fi
docker compose up -d --build --wait
echo
echo "Up. Try:"
echo "  curl localhost:8000/healthz"
echo "  curl localhost:8000/readyz"
echo "  curl localhost:8000/version"
echo "  curl localhost:8000/operations"
