# AI-use disclosure

I used Claude Code (Anthropic) during this assessment. Specifically it:
- wrote the first version of the app, tests, Dockerfile, compose file, scripts, CI workflow and docs, which I reviewed;
- ran the tests, deploy, rollback and scan, and found two bugs along the way (read-only filesystem needing `/tmp`;
  database not started on a first deploy) and fixed them.

I'm responsible for everything submitted and can explain it in the review. Evidence logs are real command output.
