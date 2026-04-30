# task-{N} {task-name} — Expected Behavior Quiz

> Status: draft | reviewing | locked
> action_type: ui | api | data | infra | cross-cutting
> Generated: {date}
> Linked task spec: tasks.md#task-{N}

The quiz is a 9-row × N-column matrix. Rows are perception-gap dimensions (fixed). Columns are decision points the agent identified by citing item IDs from `problem.md` and `tasks.md`. Cells hold one question each — `Q-{Dim}.{cite}` — and bodies follow below the matrix. Empty rows are explicit skips, not omissions; the agent records the justification in the activation log.

See `references/quiz-guidelines.md` for the dimension definitions and authoring rules. Items are cited by ID — the agent must not invent decision points that no design item supports.

## Activation log

Before drafting cells, the agent records which dimensions are active and why, so the developer can challenge skipped rows.

| Dimension | Active? | Reason | Predicted decision points |
|-----------|---------|--------|---------------------------|
| Intent | yes/no | <why> | <count> |
| Observable | yes/no | <why> | <count> |
| Acceptance | yes/no | <why> | <count> |
| Constraint | yes/no | <why> | <count> |
| Assumption | yes/no | <why> | <count> |
| Dependency | yes/no | <why> | <count> |
| Edge | yes/no | <why> | <count> |
| Failure | yes/no | <why> | <count> |
| Decision | yes/no | <why> | <count> |

## Coverage matrix

Cells: `Q-{Dim}.{cited-item-id}: <one-line decision>`. Use `–` for skipped slots. Item IDs come from `problem.md` (`criterion-N`, `invariant-N`, `out-of-scope-N`, `open-question-N`) or `tasks.md` (`task-{N}.observable-N`, `task-{N}.verify-condition-N`, `task-{N}.constraint-N`, `task-{N}.assumption-N`, `task-{N}.dependency-N`).

|  | P1 | P2 | P3 |
|---|---|---|---|
| Intent | – | – | – |
| Observable | – | – | – |
| Acceptance | – | – | – |
| Constraint | – | – | – |
| Assumption | – | – | – |
| Dependency | – | – | – |
| Edge | – | – | – |
| Failure | – | – | – |
| Decision | – | – | – |

## Q bodies

Each cell expands into a Q body. One Q = one decision. The Q heading repeats the cell ID and the cited item.

### Q-{Dim}.{cited-item-id}: <one-line decision restated>

**Cited item**: `<item-id>` (`<problem.md or tasks.md path>`)

<1-2 paragraph context if needed; keep code excerpts ≤ 5 lines, prefer anchors like `path/to/file.py:142`>

**Expected answer shape**: pick one of [A/B/C] | write number (with unit) | yes/no | free text (≤ N words)

**Options** (if shape is `pick one`):
- A. <option>
- B. <option>
- C. other (write own)

**Developer answer**:
<!-- 자유 기술. 한 줄도 OK. 빈 칸 = deferred (agent re-prompts on lock attempt). -->

**Source (evidence anchor)**:
<!-- e.g., `tasks.md#task-1.constraint-1` / `curator.py:142` / `problem.md#invariant-2` / `external doc URL` / `guess (no source)`. `guess` flags this answer as weak — agent will surface it in critique. -->

**Critique log**:
<!-- agent fills. ambiguity flagged here; loops until clean. -->

**Test spec (auto-derived after lock)**:
<!-- after lock, agent fills: developer answer → executable test (or demo step). -->

---

### Q-{Dim}.{cited-item-id}: ...

(Repeat per cell.)

## Lock

Lock condition: every active cell has an answer or explicit `deferred` mark, and every critique log is clean. Agent confirms lock candidate, developer types `lock` (or equivalent confirmation). After lock, the matrix is the test spec — `humanpowers:operate` and `humanpowers:verification-before-completion` consume it as-is.

If the agent finds a missing item during cell drafting (a dimension is active but no design item supports the decision point), the agent does not invent the item. It surfaces the gap to the developer and routes back to `humanpowers:brainstorming` (for `problem.md` items) or `humanpowers:writing-plans` (for `tasks.md` items). After the upstream artifact gains a new ID, the quiz re-cites it.
