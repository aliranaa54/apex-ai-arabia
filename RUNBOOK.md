# Runbook

## Deploy
1. `./scripts/test.sh` - must be green.
2. `./scripts/release.sh <new-version>`
3. Check: `curl localhost:8000/version` shows the new version, `docker compose ps` shows api healthy.

## Rollback
`./scripts/rollback.sh`. It reads `.previous_version`, switches `.env` back and restarts only the api.
Database data is not touched. Limit: it goes back one version only, and if a release ever changes the
DB schema it must stay backward compatible (add columns, don't drop them) or rollback is not safe.

## Incident: where do I look?
| Symptom | Check | Likely cause / fix |
|---|---|---|
| `/readyz` returns 503 | `docker compose ps`, `docker compose logs db` | Database down. `docker compose start db`. Api recovers on its own. |
| `/operations` returns 500, `/healthz` ok | `docker compose logs api` (JSON lines, errors have a traceback) | Usually DB. Same as above. |
| Api container restarting | `docker compose logs api --tail 30` | Bad config or code. Roll back, then investigate. |
| Release says "unhealthy" | script already rolled back | Read the api logs of the failed version before retrying. |
| Disk filling up | `docker system df` | Prune old images, but keep the last 2 versions for rollback. |

Real example from this project: after adding `read_only: true`, the api crash-looped with
"No usable temporary directory". Logs showed it straight away; the fix was `tmpfs: [/tmp]`.
The database drill is in `evidence/04-failure-investigation.log`.

## Metrics / alerts
Metrics at `/metrics`. Proposed alerts in `observability/alerts.yml` (not deployed): not ready 2m,
5xx rate above 5%, p95 above 1s.
