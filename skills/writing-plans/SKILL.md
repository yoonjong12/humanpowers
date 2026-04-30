---
name: writing-plans
description: Use after humanpowers:brainstorming to expand the preliminary task outline in problem.md into tasks.md (with full per-task item IDs) and a per-task plan.md (TDD steps). Hands off to humanpowers:quiz next.
---

# Writing Plans

## Overview

Writing-plans is the design step in the humanpowers loop (brainstorm → writing-plans → quiz → operate). It reads `problem.md` (produced by `humanpowers:brainstorming`) and produces:

1. `tasks.md` — full per-task design with stable item IDs that the quiz cites.
2. `tasks/{id}/plan.md` — implementation plan per task, broken into bite-sized TDD steps.

The plan assumes the engineer has zero context for the codebase and questionable taste. Document everything they need: which files to touch, the actual code, expected test output, exact commands. DRY. YAGNI. TDD. Frequent commits.

**Announce at start:** "I'm using the writing-plans skill to expand the task outline."

**Context:** This should be run in a dedicated worktree (created by `humanpowers:using-git-worktrees`).

## Inputs

- `<workspace>/.humanpowers/problem.md` — read criteria, invariants, out-of-scope, open questions, preliminary task outline.
- `<workspace>/.humanpowers/state.json` — phase should be `problem-defined`. If not, halt and ask the developer to confirm `problem.md` is signed off.

## Outputs

- `<workspace>/.humanpowers/tasks.md` — one section per task, with full item IDs. Use template at `references/templates/tasks.md`.
- `<workspace>/.humanpowers/tasks/{id}/plan.md` — TDD steps per task.

## Item ID enforcement

Each task in `tasks.md` carries top-level metadata (`WHO`, `WHY`, `ACTION_TYPE`, `DEPENDS_ON`, `STATUS`) plus five categories of cited items, each with stable IDs. The quiz cites these IDs; downstream artifacts (plan.md, verify.md, ADR digest) trace decisions to them. IDs are append-only.

| Category | ID format | What goes here |
|----------|-----------|----------------|
| Observables | `task-N.observable-N` | What an outside reader sees once the task is done — file path, API shape, DB column, UI element. |
| Verify conditions | `task-N.verify-condition-N` | Concrete pass criterion — curl response shape, SQL row count, Gherkin scenario, checklist item. |
| Constraints | `task-N.constraint-N` | Task-local quantitative bound (latency, cap, count), qualitative invariant, prohibition. |
| Assumptions | `task-N.assumption-N` | Input shape, prior data state, environment configuration, upstream behavior taken as given. |
| Dependencies | `task-N.dependency-N` | Inputs and preconditions sourced from elsewhere — another task's output, an external service, a config value. |

Do NOT skip any of the five categories. If a category is empty for a task, write `(none for this task)` rather than omitting the section — empty is a legitimate signal, omission is not.

## File Structure

Before defining tasks, map out which files will be created or modified and what each is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure — but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

## Bite-Sized Step Granularity (per-task plan.md)

Each step in `plan.md` is one action (2-5 minutes):
- "Write the failing test" — step
- "Run it to make sure it fails" — step
- "Implement the minimal code to make the test pass" — step
- "Run the tests and make sure they pass" — step
- "Commit" — step

## tasks.md Document Header

```markdown
# Tasks

> Tasks for <feature name>. Item IDs are append-only. Quiz cites these IDs.

**Source**: problem.md (criteria + invariants + preliminary task outline)
```

## Per-task structure (tasks.md)

```markdown
## task-1: <short descriptive name>

**WHO**: <persona>
**WHY**: <value hypothesis — one line>
**ACTION_TYPE**: ui | api | data | infra | cross-cutting
**DEPENDS_ON**: []
**STATUS**: brainstorm-done

### Observables
- task-1.observable-1: <observable change>

### Verify conditions
- task-1.verify-condition-1: <pass criterion>

### Constraints
- task-1.constraint-1: <bound or prohibition>

### Assumptions
- task-1.assumption-1: <precondition>

### Dependencies
- task-1.dependency-1: <input source>
```

## plan.md Document Header

```markdown
# task-{id} {name} Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `humanpowers:subagent-driven-development` (recommended) or `humanpowers:operate` to execute this plan task-by-task. Pre-execution gate: locked round1.md (from `humanpowers:quiz`). Post-execution gate: `humanpowers:verification-before-completion`.

**Goal:** <one sentence>

**Files touched:**
- Create: `<paths>`
- Modify: `<paths>`
- Test: `<paths>`

---
```

## Step structure (plan.md)

````markdown
- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Build Order from depends_on

Read `tasks.md`. Compute topological order from `DEPENDS_ON`:

1. Tasks with `DEPENDS_ON: []` → can start immediately, parallel-eligible.
2. Tasks with deps → wait until all deps `STATUS: verified`.
3. Cycle in deps = abort, ask developer to break cycle.

Use `humanpowers:dispatching-parallel-agents` for parallel-eligible tasks during operate.

## No Placeholders

Every step must contain the actual content the engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Self-Review

After writing `tasks.md` and all `tasks/{id}/plan.md` files, look at them with fresh eyes:

1. **problem.md coverage:** Does each `criterion-N` map to at least one task's observable or verify-condition? Does each `invariant-N` apply to at least one task's constraint? List gaps.
2. **Item ID hygiene:** Does every `task-N` have all five categories present (even if empty)? Are IDs sequential and unique?
3. **Placeholder scan:** Search for the patterns above. Fix them.
4. **Type consistency:** Do types, signatures, and property names used in later tasks match those defined in earlier tasks? `clearLayers()` in task-3 but `clearFullLayers()` in task-7 is a bug.
5. **TDD discipline:** Does every plan.md step alternate failing-test → implementation → passing-test → commit?

Fix issues inline. No need to re-review — just fix and move on.

## Phase transition

After tasks.md and all plan.md files are written and self-reviewed, set the phase:

```bash
WS="$(dirname "$(find . -maxdepth 3 -name state.json -path '*/.humanpowers/*' | head -1)")"
WS="$(dirname "$WS")"
bash scripts/update-state.sh "$WS" phase designed
bash scripts/update-state.sh "$WS" tasks_total <count>
```

## Hand off to quiz

Terminal state of writing-plans: invoke `humanpowers:quiz`. The quiz reads `tasks.md` and produces a 9-row × N-column matrix per task in `tasks/{id}/round1.md`, citing item IDs from `problem.md` and `tasks.md`. Operate runs only after the relevant tasks' quizzes are locked.

> "tasks.md and plan.md files written and committed. Phase = `designed`. Next: `humanpowers:quiz` to populate the per-task quiz matrix and lock expected behavior."

## Loop kick-back

If the quiz reveals a missing item or a contradiction, return here:

- **Missing observable / verify-condition / constraint / assumption / dependency** → append a new ID to `tasks.md`. The quiz re-cites.
- **Task split needed** → add a new `task-N`, update `DEPENDS_ON` of dependent tasks, re-derive `plan.md` for affected tasks.
- **Plan step contradicts a locked round1.md answer** → revise `plan.md` for that task. The locked round1.md takes precedence.

If the gap is at the problem level (criterion / invariant / out-of-scope / open-question), the kick-back goes to `humanpowers:brainstorming` instead. Writing-plans does not author `problem.md` items.

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- Item IDs are append-only; never reuse a removed ID
- DRY, YAGNI, TDD, frequent commits

## Integration

**Called by:**
- `humanpowers:brainstorming` — after problem.md is signed off

**Hands off to:**
- `humanpowers:quiz` — produces `tasks/{id}/round1.md` per task

**Pairs with:**
- `humanpowers:using-git-worktrees` — isolated workspace setup
