# Apex Operations API - DevOps assessment

A small API where you log operational tasks ("restart cache", owner "ali") and list them.
Flask + Postgres, packaged in Docker, run with Docker Compose, tested and built by GitHub Actions.

```
 git push --> GitHub Actions: lint + tests --> build image + Trivy scan + smoke test --> deploy (main only)
                                                                                              |
 you / server:  scripts/release.sh <version>  -->  docker compose  -->  [ api :8000 ] --> [ postgres + volume ]
```

## Run it (needs Docker + Compose only)

```bash
git clone git@github.com:aliranaa54/apex-ai-arabia.git && cd apex-ai-arabia
./scripts/up.sh                 # creates .env with a random DB password, then: docker compose up -d --build --wait
```

If you already have a `.env` (copy of `.env.example`), plain `docker compose up --build` works too.
The API is on **http://localhost:8000**.

```bash
curl localhost:8000/readyz
curl -XPOST localhost:8000/operations -H 'content-type: application/json' \
     -d '{"title":"restart cache","owner":"ali"}'
curl localhost:8000/operations
./scripts/test.sh               # lint + tests, inside a container
docker compose down             # stop (data stays in the volume); add -v to wipe it
```

Endpoints: `/healthz` (alive), `/readyz` (alive + database reachable), `/version`, `/metrics`, `/operations`.

## Release and rollback

```bash
./scripts/release.sh 1.1.0      # build new tag, deploy, health check. If unhealthy it rolls back by itself.
./scripts/rollback.sh           # go back to the previous version (old image is still local, no rebuild)
```

Every image is tagged with its version, never `latest`, so "what is running" is always clear.
`./scripts/demo.sh` runs the whole story; output is in `evidence/03-deploy-and-rollback.log`.

## Tests

8 tests in `tests/test_api.py` (7 normal + 1 intentional failure). The intentional one only runs with
`INTENTIONAL_FAILURE=1 ./scripts/test.sh` and proves the pipeline stops: in CI the `build` job needs `test`,
and `deploy` needs `build`, so a red test means no image and no deploy.

## Evidence (all from my own machine)

| File | What it shows |
|---|---|
| `evidence/01-tests-pass.log` | lint + 7 passed |
| `evidence/02-tests-intentional-failure.log` | 1 failed, exit code 1 |
| `evidence/03-deploy-and-rollback.log` | deploy 1.0.0, release 1.1.0, rollback, non-root user, data survives restart |
| `evidence/04-failure-investigation.log` | database stopped, how I found it, fix |
| `evidence/05-trivy-scan.log` | image scan: 0 HIGH/CRITICAL |
| `evidence/06-fresh-clone.log` | fresh `git clone` + `./scripts/up.sh` works, all endpoints answer |

**Not done:** I did not run the GitHub Actions workflow on GitHub (no repo pushed), so there is no CI run
screenshot. The workflow is written, but the same steps were run locally. I would not claim more than that.

## Other docs
`RUNBOOK.md` (deploy, rollback, incidents) - `DECISIONS.md` (trade-offs, security, cloud cost) - `AI_USE.md` (disclosure)
