# Problem Definition

> Output of `humanpowers:brainstorming`. Drives task decomposition and per-task quizzes downstream. Treat as living: refine as design clarifies.

## What

One paragraph: what is the developer trying to solve? State the user-facing outcome, not the technical mechanism.

## Why

One paragraph: why does this matter? Constraint, deadline, business motivation, or technical debt being addressed.

## Success criteria

Bulleted list of observable conditions that, when met, mean the work is done. Each criterion must be checkable without reading code (e.g., "command X returns Y", "file Z contains Q", "user can do W").

## Project invariants

Bulleted list of properties that must hold across the entire feature regardless of which task is being worked on. Examples: security (no PII in logs), data integrity (cap of 5 items maintained), determinism (LLM merge results stable across runs), compliance (alignment with a referenced design doc). Each invariant applies project-wide, not to a specific task.

## Out of scope

Bulleted list of things this work explicitly does NOT do.

## Open questions

Bulleted list of unresolved decisions. Each question must be answerable; vague philosophy questions belong elsewhere.

## Task outline (preliminary)

Numbered list. Each task has: short name, files it touches (new or existing), why it exists. This is preliminary — `humanpowers:writing-plans` finalizes the task list with action_type and depends_on graph.

1. **Task 1: <name>** — files: `<paths>`. <rationale>
2. **Task 2: <name>** — files: `<paths>`. <rationale>
