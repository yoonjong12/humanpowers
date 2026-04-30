---
name: operate
description: Use to invoke a task lead role and execute work for a specific task. Routes from /humanpowers operate {id}. Loads task context (spec + round1.md + plan), assumes the task lead role, executes pending work, updates status. Generic — no domain identity. Same agent can lead different tasks.
---

# Operate Skill

## Inputs

- `id` (e.g., `1a`) — required
- Workspace resolved via upward search from cwd

## Steps

### Step 1: Validate task exists

```bash
# Resolve workspace from cwd (upward search)
DIR="$(pwd)"; WS=""
while [ "$DIR" != "/" ]; do
  [ -f "$DIR/.humanpowers/state.json" ] && WS="$DIR" && break
  DIR="$(dirname "$DIR")"
done
[ -z "$WS" ] && { echo "no humanpowers workspace"; exit 1; }
TARGET=$(jq -r .target_repo "$WS/.humanpowers/state.json")

grep -q "id: $ID" "$WS/tasks.md" || { echo "Task $ID not found"; exit 1; }
```

### Step 2: Load task context

Load in this order — use scripts to avoid reading full files:

1. Task spec: `bash scripts/get-task.sh {id} "$WS"` — extracts task-{id} section only
2. `tasks/{id}/round1.md` — signed_off expected behavior (full read; it is the test spec)
3. `tasks/{id}/round2.md` — if exists (developer-led answers)
4. Plan header only: `head -30 tasks/{id}/plan.md` — goal + files touched
5. Invariants: `bash scripts/get-invariant.sh invariant-N "$WS"` for each relevant invariant

DO NOT read full tasks.md or full problem.md — use scripts above.
DO NOT load: other tasks' specs, other tasks' plans (out of scope).

### Step 3: Assume task lead role

```
You are task lead for {id} ({name}).
Scope: ONLY this task. Other tasks = out of scope unless thread-tagged.
Action type: {action_type}
Identity: ad-hoc (no domain). Same agent may lead different tasks in different sessions.
Project invariants (from problem.md): [list]
Task-local NFR (from tasks.md per-task entry): [list]
Expected behavior (signed_off): [summary from round1.md]
```

### Step 4: Determine work mode

Check `tasks.md#{id}` status:

| status | Action |
|--------|--------|
| problem-defined | invoke humanpowers:quiz (not operate) — abort |
| quiz-done | invoke humanpowers:writing-plans for this task — produce plan.md |
| designed | execute plan.md tasks (this is operate's main flow) |
| built | invoke humanpowers:verification-before-completion |
| verified | nothing to do — abort |

### Step 5: Execute plan tasks (status=designed)

Find the first unchecked step. Load only that step — do NOT read full plan.md:

```bash
bash scripts/get-step.sh {id} {step-n} "$WS"
```

Execute task using TDD:
- Write failing test
- Verify failure
- Implement minimal code
- Verify pass
- Commit (small commit per task)
- Mark `[x]` in plan.md

If task references unclear behavior → re-check round1.md. If still unclear → halt and surface the ambiguity to the developer.

After all plan tasks complete: set tasks.md status = `built`. Hand off to verification.

### Step 6: Boundaries

- **Don't** modify problem.md (project invariants)
- **Don't** modify other tasks' files
- **Don't** invoke quiz module from operate (separate phase)
- **Don't** auto-promote a constraint to project invariants — flag inline, developer confirms before promotion

### Step 7: Terminal state

After session ends:
- All plan tasks done → invoke humanpowers:verification-before-completion
- Some tasks done → hand back to dispatcher (`/humanpowers continue`)
- Blocked → halt and report the blocker (which task / state) to the developer

Tell developer next step explicitly.

## Batch mode

By default, `humanpowers:operate` works on a single task. Pass `--batch` (or invoke via `/humanpowers operate --batch`) to iterate over all remaining tasks whose plan exists and whose code is not yet built.

Behavior in batch mode:

- Read `tasks.md` to enumerate tasks with `phase: planned` or `phase: built` (per task entry).
- For each task with `planned` (no code yet):
  - Read `tasks/{id}/plan.md`.
  - Implement the task per the plan, applying TDD discipline.
  - On completion, update `tasks/{id}/` with any test artifacts and mark progress.
  - Move to the next task only after the current one's tests pass.
- After all eligible tasks are built, run `scripts/update-state.sh "$WS" tasks_built <count>` and transition the workspace phase to `built`.

Batch mode does not skip the per-task verification gate; verification still runs separately via `humanpowers:verification-before-completion`. Batch mode only fast-paths the build phase.

Use single-task mode (`/humanpowers operate <id>`) when:

- The next task is uncertain and you want to inspect the plan first.
- A specific task needs targeted attention (failing test, scope question).
- You want to interleave operate with verify in a tight feedback loop.

Use batch mode when:

- All tasks are well-specified after writing-plans.
- You prefer continuous build over per-task review.
- The set of remaining tasks is small enough to fit in one session's context.
