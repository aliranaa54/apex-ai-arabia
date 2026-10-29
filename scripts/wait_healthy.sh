#!/usr/bin/env bash
# Waits up to 60s for /readyz to return 200.
for i in $(seq 1 30); do
  curl -fs http://localhost:8000/readyz >/dev/null && { echo "healthy: $(curl -s localhost:8000/version)"; exit 0; }
  sleep 2
done
echo "not healthy after 60s"; exit 1
