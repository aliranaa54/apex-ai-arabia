# AI Use Disclosure

## AI tool used

**Claude Code** (Anthropic's AI coding assistant, running in the terminal, model Claude Sonnet 5.5).
No other AI tool was used for this submission.

## How AI was used

- **Implementation:** Claude Code generated the first version of the Flask API, the Dockerfile, the Docker
  Compose file, the release/rollback shell scripts and the GitHub Actions workflow.
- **Testing:** it wrote the pytest tests (including the intentional failure) and ran them, the deployment demo,
  the rollback and the Trivy scan, and saved the real output in `evidence/`.
- **Troubleshooting:** while running the deployment it found two bugs and fixed them:
  1. the API crashed because of `read_only: true` with no `/tmp` (fixed with a `tmpfs`);
  2. the first deploy did not start the database (fixed in `scripts/release.sh`).
- **Documentation:** it drafted the README, RUNBOOK, DECISIONS and this file.

## What I did myself

I reviewed the code and documents, set up the GitHub repository and pushed it, and I am responsible for
everything submitted. The evidence logs are real command output from my machine. The GitHub Actions
result is described in the README exactly as it happened (see "Evidence").

I can explain the design, run the demo and discuss limitations and improvements in the review.

## Technologies and tools

| Area | What I used |
|---|---|
| Language / framework | Python 3.12, Flask, Gunicorn |
| Database | PostgreSQL 16 (alpine), psycopg 3 |
| Containers | Docker, Docker Compose (non-root user, read-only filesystem, dropped capabilities) |
| CI/CD | GitHub Actions (test, build, scan, deploy-gate) |
| Testing / lint | pytest, ruff |
| Security scanning | Trivy (image vulnerability scan) |
| Observability | JSON structured logs, `/healthz` and `/readyz`, Prometheus metrics, proposed alert rules |
| Scripts | Bash (`release.sh`, `rollback.sh`, `wait_healthy.sh`, `test.sh`, `demo.sh`) |
| Source control | Git, GitHub |
