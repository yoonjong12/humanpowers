# Problem Definition

> Output of `humanpowers:brainstorming`. Drives task decomposition and per-task quizzes downstream. Treat as living: refine as design clarifies. Items get stable IDs (`criterion-N`, `invariant-N`, `out-of-scope-N`, `open-question-N`) so quizzes and downstream artifacts can cite them.

## What

One paragraph: what is the developer trying to solve? State the user-facing outcome, not the technical mechanism.

## Why

One paragraph: why does this matter? Constraint, deadline, business motivation, or technical debt being addressed.

## Success criteria

Each criterion gets an ID. A criterion must be checkable without reading code (e.g., "command X returns Y", "file Z contains Q", "user can do W").

- criterion-1: <observable condition>
- criterion-2: <observable condition>

## Project invariants

Properties that must hold across the entire feature regardless of which task is being worked on. Examples: security (no PII in logs), data integrity (cap of 5 items maintained), determinism (LLM merge results stable across runs), compliance (alignment with a referenced design doc). Each invariant applies project-wide, not to a specific task.

- invariant-1: <project-wide property>
- invariant-2: <project-wide property>

## Out of scope

Things this work explicitly does NOT do.

- out-of-scope-1: <excluded behavior or surface>
- out-of-scope-2: <excluded behavior or surface>

## Open questions

Unresolved decisions. Each question must be answerable; vague philosophy questions belong elsewhere. Each open question carries a status — `open` while unresolved, `answered` once decided (with the answer inline), or `deferred` if resolution is postponed (with a reason).

- open-question-1 [open]: <question>
- open-question-2 [answered]: <question> — <answer>
- open-question-3 [deferred]: <question> — reason: <why postponed>

## Task outline (preliminary)

Numbered list. Each task has a short name, the files it touches (new or existing), and a one-line rationale. This is preliminary — `humanpowers:writing-plans` finalizes the task list with `action_type`, `depends_on`, and the per-task item IDs (`task-N.observable-N`, `task-N.constraint-N`, etc.).

1. **task-1: <name>** — files: `<paths>`. <rationale>
2. **task-2: <name>** — files: `<paths>`. <rationale>
