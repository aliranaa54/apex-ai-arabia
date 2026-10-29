#!/usr/bin/env bash
# Lint + tests in a throwaway container, so nothing needs installing on the host.
set -euo pipefail
cd "$(dirname "$0")/.."
docker run --rm -v "$PWD":/w -w /w -e INTENTIONAL_FAILURE="${INTENTIONAL_FAILURE:-0}" python:3.12-slim \
  sh -c "pip install -q -r requirements-dev.txt 2>&1 | tail -1; ruff check app tests && pytest -v -p no:cacheprovider"
