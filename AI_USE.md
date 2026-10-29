# AI Use Disclosure

## AI tools used

Claude Code (Anthropic) was used as an AI coding assistant during implementation, testing, troubleshooting, and documentation.

The model used was Claude Sonnet 5.5.

## How AI assistance was used

- **Implementation:** Assisted with generating the initial Flask API, Dockerfile, Docker Compose configuration, release and rollback scripts, and GitHub Actions workflow.
- **Testing and validation:** Assisted in writing pytest tests, including a separate intentional-failure demonstration, and running validation commands. The evidence directory contains command output collected during the actual verification process.
- **Troubleshooting:** Assisted in identifying and resolving two deployment issues:
  1. The API required a writable temporary directory when running with a read-only filesystem. This was addressed using a `tmpfs` mount.
  2. The initial release procedure did not start the database service. The release script was updated to address this issue.
- **Documentation:** Assisted in drafting the README, runbook, decision memo, and this disclosure.

## Candidate responsibilities

I used AI-generated suggestions as part of the development process and remain responsible for the submitted work. I reviewed the implementation and documentation, configured the GitHub repository, and pushed the project.

Test results, deployment outcomes, security scan results, and CI status are reported according to the evidence actually collected. Any limitations or unverified steps are documented rather than presented as successful.

I will explain the architecture, technical decisions, security controls, testing strategy, rollback procedure, and known limitations during the assessment review.

## Technologies and tools

| Area | Technology |
|---|---|
| Language and framework | Python 3.12, Flask, Gunicorn |
| Database | PostgreSQL 16, psycopg 3 |
| Containers | Docker, Docker Compose |
| CI/CD | GitHub Actions |
| Testing and linting | pytest, Ruff |
| Security scanning | Trivy |
| Observability | Structured JSON logs, health/readiness endpoints, Prometheus metrics, proposed alert rules |
| Automation | Bash release, rollback, health-check, test, and demo scripts |
| Source control | Git and GitHub |
