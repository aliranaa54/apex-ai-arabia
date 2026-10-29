#!/usr/bin/env bash
# Runs the full deploy -> release -> rollback demo and prints what happens.
cd "$(dirname "$0")/.."
echo '$ scripts/release.sh 1.0.0'; scripts/release.sh 1.0.0 2>&1 | tail -3
echo; echo '$ create a record'; curl -s -XPOST localhost:8000/operations -H 'content-type: application/json' -d '{"title":"restart cache","owner":"ali"}'
echo; echo '$ scripts/release.sh 1.1.0'; scripts/release.sh 1.1.0 2>&1 | tail -2
echo '$ data survived the release:'; curl -s localhost:8000/operations
echo; echo '$ scripts/rollback.sh'; scripts/rollback.sh 2>&1 | tail -2
echo '$ docker compose ps'; docker compose ps --format '{{.Service}} {{.Image}} {{.Status}}'
echo; echo '$ user inside the container'; docker compose exec api id
echo; echo '$ down + up, is the data still there?'; docker compose down >/dev/null 2>&1; docker compose up -d --wait >/dev/null 2>&1; scripts/wait_healthy.sh; curl -s localhost:8000/operations
