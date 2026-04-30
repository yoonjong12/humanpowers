---
name: review
description: Use after multiple tasks are verified to perform a project-level review of the workspace state and identify next priorities. Distinct from per-task verification (humanpowers:verification-before-completion). This is project-level review with cascade decisions.
---

# Review Skill

## When to invoke

- After at least 2 tasks reach `status: verified`
- Or developer explicitly requests `/humanpowers review`
- Before finishing-a-development-branch (final wrap)

## Steps

### Step 1: Aggregate state

Resolve workspace via upward search from cwd:

```bash
DIR="$(pwd)"; WS=""
while [ "$DIR" != "/" ]; do
  [ -f "$DIR/.humanpowers/state.json" ] && WS="$DIR" && break
  DIR="$(dirname "$DIR")"
done
[ -z "$WS" ] && { echo "no humanpowers workspace"; exit 1; }
```

Read:
- `<WS>/.humanpowers/state.json` — phase + task counts
- `<WS>/.humanpowers/problem.md` — project invariants
- `<WS>/.humanpowers/tasks.md` — per-task status

### Step 2: Show the developer the review summary

Display:

```
Workspace: <WS>/.humanpowers/
Phase: {state.phase}

Tasks: {tasks_total} total
  problem-defined: {x}
  quiz-done:       {x}
  designed:        {x}
  built:           {x}
  verified:        {x}

Project invariants (from problem.md): {N invariants}

Project invariant violations (auto-detect): {none | list}
```

Pull invariant violations by scanning recent commits and `tasks.md` changes — if a task's behavior or NFR contradicts a project invariant, flag it.

### Step 3: AskUserQuestion — review options

```
Q: Project review summary above. Next action?
options:
  - 1. Decide next task priority (continue building)
  - 2. Cascade — re-quiz a specific task (reset its status to problem-defined)
  - 3. Finalize (humanpowers:finishing-a-development-branch)
```

### Step 4a: Option 1 — Priority decision

Compute the `depends_on` frontier — tasks whose dependencies are all `verified`.

```
AskUserQuestion:
  Q: Next task candidates (frontier): task-X / task-Y / task-Z. Which one first?
  options: [task-X, task-Y, task-Z, parallel-all, custom]
```

Hand off: `/humanpowers operate {chosen-task}`.

### Step 4b: Option 2 — Cascade re-quiz

```
AskUserQuestion:
  Q: Which task's expected behavior do you want to re-examine?
  free text: task-id
```

Reset that task's `status` to `problem-defined` in `tasks.md`. Hand off to humanpowers:quiz.

### Step 4c: Option 3 — Finalize

Hand off to humanpowers:finishing-a-development-branch.

### Step 5: Update state.json

Set `last_review` timestamp. Persist any chosen next phase.

```bash
bash scripts/update-state.sh "$WS" last_review "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

## Boundaries

- Don't auto-reset task status — the developer must choose the cascade target
- Don't cascade re-quiz on multiple tasks at once — one at a time
- Don't modify project invariants from this skill — that's brainstorming's job
