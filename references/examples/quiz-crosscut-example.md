# task-9 LLM Output Determinism — Expected Behavior Quiz (EXAMPLE, locked)

> Status: locked
> action_type: cross-cutting
> Developer articulation: 4 cells / 9 turns
> Linked task spec: tasks.md#task-9

## Activation log

| Dimension | Active? | Reason | Predicted points |
|-----------|---------|--------|---------------------------|
| Intent | yes | "deterministic" definition (byte-exact vs semantic) | 1 |
| Observable | yes | how determinism is measured across calls | 1 |
| Acceptance | no | acceptance is the determinism check itself (covered by Observable) | 0 |
| Constraint | yes | invariant promotion candidate (touches multiple tasks) | 1 |
| Assumption | no | model identifier already locked in `task-9.assumption-1` | 0 |
| Dependency | yes | LLM provider SDK behavior | 1 |
| Edge | yes | provider returns retry-able error mid-batch | 1 |
| Failure | yes | non-deterministic output detected at runtime | 1 |
| Decision | yes | re-run vs cache vs fail-fast on mismatch | 1 |

## Coverage matrix

|  | P1 | P2 | P3 |
|---|---|---|---|
| Intent | Q-Intent.task-9.observable-1: determinism definition | – | – |
| Observable | Q-Obs.task-9.observable-1: determinism measurement | – | – |
| Constraint | Q-Cons.invariant-6: cross-task determinism scope | – | – |
| Dependency | Q-Dep.task-9.dependency-1: provider SDK config | – | – |
| Edge | Q-Edge.task-9.dependency-1: provider mid-batch retry | – | – |
| Failure | Q-Fail.task-9.observable-1: non-deterministic output detected | – | – |
| Decision | Q-Dec.task-9.observable-1: re-run vs cache vs fail-fast | – | – |

## Q bodies

### Q-Intent.task-9.observable-1: determinism definition

**Cited item**: `task-9.observable-1` (`tasks.md`)

"Deterministic LLM output" can mean (a) byte-exact output for the same input, (b) semantic equivalence (different wording, same structured fields), or (c) cache-hit equivalence (cached responses returned bit-exact, fresh responses validated semantically).

**Expected answer shape**: pick one of [A/B/C/D]
**Options**:
- A. Byte-exact for same input + same model + same params
- B. Semantic equivalence on parsed structured output
- C. Cache-hit byte-exact + fresh-call semantic
- D. other (write own)

**Developer answer**: C
**Source**: `problem.md#criterion-5` ("repeated runs of the same workflow yield equivalent decisions"), discussion turn 2
**Critique log**:
- Turn 3 — agent: "byte-exact across regions / time?" → developer scoped: cache layer ensures byte-exact on hit; misses go through structured-output validator that compares parsed fields, not raw bytes

**Test spec (auto-derived)**:
- Run pipeline twice with same input → cache hit on second run → response bytes identical
- Cache miss → both runs produce structured output with identical decision fields

---

### Q-Cons.invariant-6: cross-task determinism scope

**Cited item**: `invariant-6` (`problem.md` — "all LLM-touching tasks must produce equivalent decisions on repeated runs")

This task is the cross-cutting enforcer of invariant-6. Confirming whether other tasks (task-2, task-4, task-6) inherit this contract or each implements its own determinism layer.

**Expected answer shape**: pick one of [A/B/C]
**Options**:
- A. This task provides a shared utility (cache + validator); other tasks call it
- B. Each task implements its own layer (more freedom, more risk of drift)
- C. other (write own)

**Developer answer**: A
**Source**: `problem.md#invariant-6`, `tasks.md#task-2.dependency-2` (already cites task-9 as dependency)
**Critique log**:
- Turn 6 — agent: "If shared, every other LLM task inherits the cache key shape — confirmed in task-2/4/6 dependencies?" → developer added explicit dependency rows in tasks.md (kick-back to writing-plans)

**Test spec (auto-derived)**:
- task-2/4/6 each import the shared `deterministic_call(prompt, schema)` helper
- Removing the helper from task-2 → its tests fail (proves dependency)

---

### Q-Edge.task-9.dependency-1: provider mid-batch retry

**Cited item**: `task-9.dependency-1`

LLM provider SDKs may auto-retry on 429/5xx. Retries can produce different outputs even with `temperature=0`. The cache must ensure a given input maps to one output regardless of retry history.

**Expected answer shape**: free text (≤ 50 words)

**Developer answer**: cache key = `hash(prompt + model + params)`. First successful response written to cache atomically. Retries that complete after the first success see the cache and return cached output. Retries that completed before cache write are discarded by the cache's compare-and-swap.
**Source**: discussion turn 8, existing cache implementation at `cache/llm.py:47`

**Test spec (auto-derived)**:
- Inject 2 concurrent calls with same input → exactly one hits provider → both callers get the same bytes

---

### Q-Dec.task-9.observable-1: re-run vs cache vs fail-fast

**Cited item**: `task-9.observable-1`

When a fresh call (cache miss) returns output that fails the structured-output validator (e.g., schema violation), the policy can re-run with stricter prompt, return last-known-good from cache, or fail-fast.

**Expected answer shape**: pick one of [A/B/C/D]
**Options**:
- A. Re-run up to 3 times with the validator's error message appended to the prompt
- B. Return last-known-good (cached) result if any; else fail
- C. Fail-fast (raise; caller decides)
- D. other (write own)

**Developer answer**: A
**Source**: `problem.md#criterion-5`, LiteLLM adapter convention (retry-with-error-feedback)
**Critique log**:
- Turn 10 — agent: "what if all 3 retries fail?" → developer: "raise `DeterminismError` with last validator output; caller logs and continues with degraded mode"

**Test spec (auto-derived)**:
- Mock provider returns invalid JSON 3x in a row → `DeterminismError` raised
- Mock provider returns invalid JSON 2x then valid → 3rd call validated → success returned to caller
