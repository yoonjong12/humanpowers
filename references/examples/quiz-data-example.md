# Task {X} Generic Aggregation — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: data

## Q1: Aggregation behavior

Daily aggregation job: input = events table, output = daily_metrics. What exactly?

**Developer answer**:
- Input: `events(timestamp UTC, user_id, event_type, value DECIMAL)`
- Output: `daily_metrics(date DATE, event_type, count INT, sum_value DECIMAL, distinct_users INT)`
- Partitioning: input by HOUR (24 partitions/day), aggregate scans only previous day's partitions
- Output upsert: ON CONFLICT (date, event_type) DO UPDATE
- Run schedule: daily at 02:00 UTC for previous 24h

**SQL assertion (auto-derived)**:
```sql
-- After job for 2026-04-27, expect:
SELECT count(*) FROM daily_metrics WHERE date = '2026-04-27';
-- Expected: count > 0 AND count = (SELECT count(DISTINCT event_type) FROM events WHERE date_trunc('day', timestamp) = '2026-04-27')

SELECT sum(count) FROM daily_metrics WHERE date = '2026-04-27';
-- Expected: equal to (SELECT count(*) FROM events WHERE date_trunc('day', timestamp) = '2026-04-27')

SELECT sum_value FROM daily_metrics WHERE date = '2026-04-27' AND event_type = 'X';
-- Expected: equal to (SELECT sum(value) FROM events WHERE event_type = 'X' AND ...)
```

## Q2: Late arrivals

Events with timestamp = 2026-04-27 arriving after job ran?

**Developer answer**:
- Re-run job with `--reprocess-date 2026-04-27` flag (manual trigger)
- Auto-detect window: 7 days lookback nightly job re-aggregates
- Late arrivals after 7d = ignored, logged to `late_events_orphan` table

## Q3: Idempotency

Re-run for same date — overwrites or appends?

**Developer answer**:
- Overwrite (UPSERT). Source of truth = always latest run.
- Audit log captures every run with run_id + duration + rows_processed.

## Q4: Failure handling

Job fails midway?

**Developer answer**:
- Transaction rollback (no partial daily_metrics rows for that date)
- Re-trigger via runbook (scripts/rerun-aggregation.sh)
- Alert sent if not retried within 4 hours
