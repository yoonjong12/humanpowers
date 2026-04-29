# Task {X} Generic Determinism — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: cross-cutting

## Q1: Determinism scope

Which paths must be deterministic (same input → same output)?

**Developer answer**:
- All LLM calls in workflow X = temperature 0 + top_p 1
- All DB queries with sort = explicit ORDER BY (no implicit ordering)
- All UUID generation in tests = seeded random (e.g., uuid5 with namespace)
- Floating point aggregation = use `decimal.Decimal` for $ amounts (not float)

## Q2: Composite VERIFY

How does this task "pass"?

**Developer answer**:
- cross-cutting = composite — passes when:
  - 1a + 1b + 2a + 2b all run their VERIFY 3x in sequence
  - All 3 runs produce identical results (byte-equal for JSON, row-equal for SQL output)
- Failure mode: 1 of 3 runs differs → cross-cutting fail → impacted tasks revert to `built` (not `verified`)

## Q3: Exceptions allowed

Where determinism MAY relax?

**Developer answer**:
- Logging: timestamps OK to differ (don't compare in VERIFY)
- Trace IDs: random per request OK (don't compare)
- Cache: if cache miss vs hit changes timing but not value, OK

## Q4: Detection mechanism

How catch non-determinism?

**Developer answer**:
- CI runs each impacted task VERIFY 3x with same seed
- diff outputs (excluding timestamp/trace_id fields)
- Any non-empty diff = build fails
