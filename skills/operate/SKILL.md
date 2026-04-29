---
name: operate
description: Use to invoke a task lead role and execute work for a specific task. Routes from /humanpowers operate {id}. Loads task context (spec + expected-outputs + plan + scratchpad), assumes the lead persona for that task, executes pending work, updates status. Generic — no domain identity. Same agent can lead different tasks.
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

Read in this order:
1. `tasks.md` — extract just task `{id}` 5-field row
2. `tasks/{id}/expected-outputs.md` — signed_off VERIFY
3. `tasks/{id}/plan.md` — current plan (if exists)
4. `library/scratchpads/{id}.md` — accumulated notes (if exists)
5. `problem.md` — project invariants section
6. Any `threads/*.md` post tagged with `{id}` — recent decisions

DO NOT load: other tasks' specs, other tasks' plans (out of scope).

### Step 3: Assume task lead persona

```
You are task lead for {id} ({name}).
Scope: ONLY this task. Other tasks = out of scope unless thread-tagged.
Action type: {action_type}
Identity: ad-hoc (no domain). Same agent may lead different tasks in different sessions.
Project invariants (from problem.md): [list]
Task-local NFR (from tasks.md per-task entry): [list]
Expected outputs (signed_off): [summary from expected-outputs.md]
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

Read `tasks/{id}/plan.md`. Find first unchecked task.

Execute task using TDD:
- Write failing test
- Verify failure
- Implement minimal code
- Verify pass
- Commit (small commit per task)
- Mark `[x]` in plan.md

If task references unclear behavior → re-check expected-outputs.md. If still unclear → halt + thread post.

After all plan tasks complete: set tasks.md status = `built`. Hand off to verification.

### Step 6: Update scratchpad (≤30 lines)

After session, write/update `library/scratchpads/{id}.md`:

```markdown
# Task {id} Scratchpad — lead notes

## Session 2026-04-28
- Completed Tasks 3, 4
- Blocker: depends_on task 2b (status: designed) — wait
- Next session: continue from Task 5

(keep under 30 lines — auto-truncated by hook)
```

### Step 7: Boundaries

- **Don't** modify problem.md (project invariants)
- **Don't** modify other tasks' files
- **Don't** invoke quiz module from operate (separate phase)
- **Don't** auto-promote NFR — flag only, agent must thread post for developer confirm

### Step 8: Terminal state

After session ends:
- All plan tasks done → invoke humanpowers:verification-before-completion
- Some tasks done → update scratchpad, hand back to dispatcher (`/humanpowers continue`)
- Blocked → write `threads/blocker-{id}.md`, hand back

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
