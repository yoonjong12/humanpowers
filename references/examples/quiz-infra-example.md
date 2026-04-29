# TF-{X} Generic Service Deployment — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: infra

## Q1: Deployment readiness

Service "X" deployable to staging when?

**Developer answer (checklist)**:
- [x] Docker image built + tagged with git SHA
- [x] Image pushed to registry (ECR / GCR / DockerHub)
- [x] Helm chart values rendered for staging env
- [x] Health endpoint `/healthz` returns 200 within 30s of pod start
- [x] Readiness endpoint `/ready` returns 200 once all dependencies confirmed
- [x] Migration: `python manage.py migrate --check` passes (no pending unapplied)
- [x] Required env vars set in k8s secret (DATABASE_URL, REDIS_URL, API_KEY)
- [x] Logging level INFO, output JSON-formatted to stdout
- [x] Metrics endpoint `/metrics` exposes Prometheus-compatible

## Q2: Health check details

`/healthz` and `/ready` semantics?

**Developer answer**:
- `/healthz`: process alive. Returns 200 + `{"status": "ok"}` always (unless deadlocked).
- `/ready`: dependency check. Returns 200 only if DB ping + Redis ping succeed within 1s. Otherwise 503 + `{"status": "unready", "failed": ["db" | "redis"]}`.
- k8s liveness probe = `/healthz` every 10s, fail 3 in row = restart.
- k8s readiness probe = `/ready` every 5s, fail 2 in row = remove from service.

## Q3: Rollback

Bad deploy?

**Developer answer**:
- `helm rollback {release} {prev-revision}` — atomic
- Rollback within 5 min of deploy = automatic if `/ready` < 50% in 3 min window
- Beyond 5 min = manual decision (data migration may have run, rollback risky)

## Q4: Secrets

How handled?

**Developer answer**:
- k8s sealed-secrets (or AWS Secrets Manager / Vault)
- Never in env vars in plain helm values
- Rotation: 90 days, runbook documented
