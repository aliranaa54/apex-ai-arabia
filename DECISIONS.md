# Decisions and trade-offs

**Stack.** Flask + Postgres because they are simple and I can explain every line. Tests use an in-memory
store so they run in under a second with no database.

**Secrets.** Nothing secret is in git. `.env` is ignored; `.env.example` has a placeholder. In the cloud
I would use AWS Secrets Manager / SSM Parameter Store and inject at runtime. CI needs no secrets for now.

**Least privilege.** Container runs as uid 10001, read-only filesystem, all capabilities dropped,
`no-new-privileges`. CI token has `contents: read` only. The database is not published to the host.

**Scanning.** Trivy scans the image in CI and fails on fixable HIGH/CRITICAL (clean locally). With more time:
Dependabot, `pip-audit`, and pinning the base image by digest.

**Releases.** Versioned tags, health-checked deploy, automatic rollback on failure. Trade-off: single host
means a few seconds of downtime on restart; no blue/green.

**Observability.** JSON logs, health/readiness, Prometheus metrics, alert rules written but not deployed -
I chose not to add Prometheus/Grafana to the compose file to keep the exercise reviewable.

**Cost-aware cloud path.** Start small: one `t4g.small` EC2 (or Lightsail) running this same compose file,
image in ECR, Postgres on the same box with EBS snapshots (roughly $15-20/month). When uptime matters,
move the DB to RDS and the api to ECS Fargate behind an ALB. Don't start with EKS - too much cost and
operating effort for one small service. Nothing in the cloud was created for this assessment.

**Known gaps / what I'd improve.**
- CI workflow not yet run on GitHub, so no run evidence.
- When the DB is down `/operations` returns 500; it should return 503 with a clear message.
- No DB migrations tool (table is created at startup). Would add Alembic.
- Rollback goes back one version only.
