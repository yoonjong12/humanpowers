# task-7 Postgres Read Replica — Expected Behavior Quiz (EXAMPLE, locked)

> Status: locked
> action_type: infra
> Developer articulation: 5 cells / 11 turns
> Linked task spec: tasks.md#task-7

## Activation log

| Dimension | Active? | Reason | Predicted points |
|-----------|---------|--------|---------------------------|
| Intent | yes | replica purpose (read scaling vs HA failover) | 1 |
| Observable | yes | replica endpoint surface, monitoring signal | 2 |
| Acceptance | yes | replication lag SLO | 1 |
| Constraint | yes | network/cost invariants | 1 |
| Assumption | yes | primary configuration | 1 |
| Dependency | yes | DNS / connection-pooler change | 1 |
| Edge | no | no edge handling required at infra level | 0 |
| Failure | yes | replication lag exceeds SLO | 1 |
| Decision | yes | sync vs async replication | 1 |

## Coverage matrix

|  | P1 | P2 | P3 |
|---|---|---|---|
| Intent | Q-Intent.task-7.observable-1: replica purpose | – | – |
| Observable | Q-Obs.task-7.observable-1: replica endpoint surface | Q-Obs.task-7.observable-2: monitoring signal | – |
| Acceptance | Q-Acc.task-7.verify-condition-1: replication lag SLO | – | – |
| Constraint | Q-Cons.invariant-5: cross-AZ network cost | – | – |
| Assumption | Q-Assume.task-7.assumption-1: primary WAL config | – | – |
| Dependency | Q-Dep.task-7.dependency-1: pgbouncer routing change | – | – |
| Failure | Q-Fail.task-7.verify-condition-1: SLO breach behavior | – | – |
| Decision | Q-Dec.task-7.observable-1: sync vs async | – | – |

## Q bodies

### Q-Intent.task-7.observable-1: replica purpose

**Cited item**: `task-7.observable-1` (`tasks.md`)

A read replica can serve read scaling, hot-standby for HA failover, or analytics queries. The primary use determines the consistency expectations and the monitoring focus.

**Expected answer shape**: pick one of [A/B/C/D]
**Options**:
- A. Read scaling (route SELECT-only traffic from app)
- B. HA failover hot standby
- C. Analytics queries (long-running, isolated from primary)
- D. other (write own)

**Developer answer**: A
**Source**: `problem.md#criterion-4` ("read traffic spikes saturate primary at peak"), discussion turn 3
**Critique log**:
- Turn 4 — agent: "any analytics queries planned to use it?" → developer added `out-of-scope-4` ("analytics traffic stays on dedicated warehouse")

**Test spec (auto-derived)**:
- App connection string for read endpoints points to replica
- Primary CPU drops by ≥30% at peak after rollout (measured 7-day average vs prior week)

---

### Q-Acc.task-7.verify-condition-1: replication lag SLO

**Cited item**: `task-7.verify-condition-1` (`tasks.md`)

**Expected answer shape**: write number (with unit)

**Developer answer**: replication lag p99 ≤ 500ms over rolling 5-minute window. Lag > 500ms triggers alert; lag > 5s triggers automatic write-traffic isolation (replica removed from rotation).
**Source**: `problem.md#invariant-5` ("read-after-write surfaces — list pages — must reflect writes within 1s"), discussion turn 7
**Critique log**:
- Turn 8 — agent: "what about read-after-write within the same session?" → developer scoped to "best-effort across replica; session-level reads route to primary via app hint"

**Test spec (auto-derived)**:
- Synthetic load: 10k writes/min on primary → measure `pg_replication_slots.lag` on replica → p99 ≤ 500ms
- Inject 1s artificial lag → replica auto-removed within 30s

---

### Q-Dec.task-7.observable-1: sync vs async replication

**Cited item**: `task-7.observable-1`

**Expected answer shape**: pick one of [A/B/C]
**Options**:
- A. Async (default Postgres streaming replication; possible data loss on failover)
- B. Synchronous (write commits only after replica ack; primary throughput penalty)
- C. other (write own)

**Developer answer**: A
**Source**: `problem.md#out-of-scope-5` ("durable write commits already handled by WAL archive to S3"), discussion turn 10

**Test spec (auto-derived)**:
- `SHOW synchronous_standby_names;` on primary → empty
- Kill replica process during write load → primary continues accepting writes without blocking

---

### Q-Cons.invariant-5: cross-AZ network cost

**Cited item**: `invariant-5` (`problem.md` — "monthly cross-AZ data transfer ≤ $200")

**Expected answer shape**: yes/no (does this task introduce cross-AZ traffic that risks the invariant?)

**Developer answer**: yes — replica placed in same AZ as primary (us-east-1a). Falls back to us-east-1b only on AZ outage; in steady state, cross-AZ replication = 0 bytes.
**Source**: `problem.md#invariant-5`, AWS RDS placement docs URL
**Critique log**:
- Turn 11 — agent: "what about app-to-replica reads if app is in 1b?" → developer added pgbouncer rule (1b app instances go to a separate 1b replica added in v2)

**Test spec (auto-derived)**:
- Cost Explorer cross-AZ transfer for `database` tag ≤ $200/mo (measured monthly)
