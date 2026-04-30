# task-5 Daily Active Users Aggregate — Expected Behavior Quiz (EXAMPLE, locked)

> Status: locked
> action_type: data
> Developer articulation: 6 cells / 12 turns
> Linked task spec: tasks.md#task-5

## Activation log

| Dimension | Active? | Reason | Predicted points |
|-----------|---------|--------|---------------------------|
| Intent | yes | DAU definition (event vs session vs login) | 1 |
| Observable | yes | output table shape, refresh cadence | 2 |
| Acceptance | yes | reconciliation against source-of-truth | 1 |
| Constraint | yes | data-freshness invariant | 1 |
| Assumption | yes | event log schema, timezone convention | 2 |
| Dependency | yes | event log table from upstream pipeline | 1 |
| Edge | yes | days with zero events | 1 |
| Failure | yes | partial day data (pipeline lag) | 1 |
| Decision | yes | UTC vs local-day window | 1 |

## Coverage matrix

|  | P1 | P2 | P3 |
|---|---|---|---|
| Intent | Q-Intent.task-5.observable-1: DAU definition | – | – |
| Observable | Q-Obs.task-5.observable-1: aggregate table schema | Q-Obs.task-5.observable-2: refresh cadence | – |
| Acceptance | Q-Acc.task-5.verify-condition-1: reconciliation rule | – | – |
| Constraint | Q-Cons.invariant-4: data freshness | – | – |
| Assumption | Q-Assume.task-5.assumption-1: event log schema | Q-Assume.task-5.assumption-2: timezone convention | – |
| Dependency | Q-Dep.task-5.dependency-1: upstream event log table | – | – |
| Edge | Q-Edge.task-5.observable-1: zero-event day | – | – |
| Failure | Q-Fail.task-5.dependency-1: pipeline lag | – | – |
| Decision | Q-Dec.task-5.assumption-2: window definition | – | – |

## Q bodies

### Q-Intent.task-5.observable-1: DAU definition

**Cited item**: `task-5.observable-1` (`tasks.md`)

The metric "Daily Active Users" can mean (a) anyone who fired a tracked event that day, (b) anyone who logged in that day, (c) anyone with at least one session of ≥30s. The choice changes the aggregation logic and the downstream chart.

**Expected answer shape**: pick one of [A/B/C/D]
**Options**:
- A. Any user with ≥1 tracked event that day (`events` table, all event types)
- B. Any user who logged in that day (`auth_events` where `event_type = "login"`)
- C. Any user with a session of ≥30s that day
- D. other (write own)

**Developer answer**: A
**Source**: `problem.md#criterion-3` ("DAU = unique users with any tracked event"), discussion turn 4
**Critique log**:
- Turn 5 — agent: "any tracked event includes background pings?" → developer scoped to `event_type IN ('page_view', 'action')`

**Test spec (auto-derived)**:
- Reconciliation: `SELECT COUNT(DISTINCT user_id) FROM events WHERE event_type IN ('page_view', 'action') AND ts::date = '2026-04-29'` should match `SELECT dau FROM dau_daily WHERE day = '2026-04-29'`.

---

### Q-Cons.invariant-4: data freshness

**Cited item**: `invariant-4` (`problem.md` — "All daily aggregates available by 02:00 UTC for the prior day")

**Expected answer shape**: yes/no (does this task meet the freshness invariant on its own, or does it require an upstream change?)

**Developer answer**: yes — upstream event log lands by 01:00 UTC; this aggregation runs at 01:30 UTC and finishes within 10 minutes per existing benchmark.
**Source**: `problem.md#invariant-4`, `tasks.md#task-5.dependency-1`, ETL benchmark report URL
**Critique log**: clean

**Test spec (auto-derived)**:
- Cron job timestamp ≤ 01:30 UTC daily
- Job exit timestamp ≤ 01:40 UTC for ≥99% of runs over 30 days

---

### Q-Dec.task-5.assumption-2: window definition

**Cited item**: `task-5.assumption-2` (`tasks.md`)

The "day" boundary changes interpretation. UTC days simplify reconciliation; local days match user expectations but require timezone tracking.

**Expected answer shape**: pick one of [A/B/C]
**Options**:
- A. UTC day (`ts::date AT TIME ZONE 'UTC'`)
- B. User's local timezone day (joins user profile `tz` column)
- C. other (write own)

**Developer answer**: A
**Source**: `problem.md#out-of-scope-1` ("per-user-timezone reporting deferred to v2"), discussion turn 9
**Critique log**:
- Turn 10 — agent: "downstream charts will show UTC labels?" → developer confirmed; chart titles will read "DAU (UTC)"

**Test spec (auto-derived)**:
- Event at 2026-04-29T23:30:00-08:00 → counted on UTC day 2026-04-30
- Event at 2026-04-30T00:30:00+09:00 → counted on UTC day 2026-04-29

---

### Q-Edge.task-5.observable-1: zero-event day

**Cited item**: `task-5.observable-1`

**Expected answer shape**: pick one of [A/B/C]
**Options**:
- A. Insert a row with `dau = 0` for that day (densified series)
- B. Skip the row (chart shows gap)
- C. other (write own)

**Developer answer**: A
**Source**: `tasks.md#task-5.assumption-1` (downstream chart expects dense series), discussion turn 12

**Test spec (auto-derived)**:
- Drop all events for 2026-04-15 in test fixture → run aggregation → row exists for 2026-04-15 with `dau = 0`
