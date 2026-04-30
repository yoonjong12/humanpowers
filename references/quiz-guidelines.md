# Quiz Authoring Guidelines

The agent reads this before drafting any quiz. The developer never sees it. The guidelines define the 9 perception-gap dimensions, how decision points are sourced from design items, and the rules each question must obey.

## What a quiz is for

A quiz narrows the perception gap between the developer (who already has a mental model) and the agent (who is reconstructing it from the design artifacts). Every place the agent could guess is a decision point. The quiz surfaces those points so the developer makes the call explicitly. Once the quiz is locked, the agent is forbidden from guessing on the cited items.

## The 9 dimensions

Dimensions are work-agnostic. They apply to software features, research questions, data analyses, algorithm designs — any task expressible as a `tasks.md` entry.

| Dimension | What the question elicits |
|-----------|---------------------------|
| **Intent** | What this task is trying to produce, and where its boundary stops. |
| **Observable** | What an outside reader sees once the task is done — the artifact, the API shape, the data, the visible signal. |
| **Acceptance** | The exact condition that means done — pass criterion, threshold, success statistic. |
| **Constraint** | A quantitative bound (cap, latency, count), a qualitative invariant, or a prohibition. |
| **Assumption** | What the task takes as given — input definition, prior data state, environmental precondition. |
| **Dependency** | Where inputs come from — another task, an external service, a config value, an upstream artifact. |
| **Edge** | Empty / null / extreme / out-of-range input handling. |
| **Failure** | What "wrong" looks like, how it is detected, what the system does when it happens. |
| **Decision** | A point where multiple valid paths exist; the developer must pick one and say why. |

A single task usually activates 5–7 dimensions, sometimes all 9. Trivial config changes may activate only Intent and Observable.

## Decision point sources

The agent identifies decision points by citing existing design items. There are five sources, each with a different trust level. The agent labels each cell with the source:

| Source | Where to look | Trust |
|--------|---------------|-------|
| **design (problem.md)** | `criterion-N`, `invariant-N`, `out-of-scope-N`, `open-question-N` | high — explicit |
| **design (tasks.md)** | `task-N.observable-N`, `task-N.verify-condition-N`, `task-N.constraint-N`, `task-N.assumption-N`, `task-N.dependency-N` | high — explicit |
| **prior lock** | a previously locked quiz on a depended-upon task | high — already settled |
| **code read** | an inspection of existing code that surfaced an unspecified branch | medium — agent interpretation |
| **agent library** | universal patterns the agent applies (token cap, cache invalidation, deterministic order) | low — agent guess; flag for developer scrutiny |

Cells from low-trust sources should be reviewed first by the developer. If a cell needs a dimension activated but no item supports it, the agent does not invent. It surfaces the gap and routes back to the upstream skill.

## Authoring rules

### Rule 1 — One question, one decision

Each question elicits one decision. If a draft asks "where, how, and how much," split it into three.

### Rule 2 — Cite item IDs, do not invent

Every cell cites at least one item ID. If a decision point has no supporting item, the agent surfaces the gap (see Loop kick-back below). Cells without citation are not allowed.

### Rule 3 — Answer shape required

Every Q body specifies the shape of the answer the developer is expected to give:

- `pick one of [A/B/C]`
- `write number (with unit)`
- `yes/no`
- `free text (≤ N words)`

If the shape is `pick one`, list 3–5 mutually exclusive options and end with `other (write own)` so the developer is not forced into an artificial set.

### Rule 4 — Evidence anchor required

Every developer answer carries a source. The source can be a design item ID, a code line (`path/to/file.py:142`), a referenced doc, or `guess (no source)`. A `guess` answer is not invalid, but the agent flags it in the critique log so it gets extra scrutiny.

### Rule 5 — Activation log first, cells second

Before drafting any cell, the agent fills the activation log: which dimensions are active, why, and how many decision points each is expected to yield. The developer can challenge a skipped dimension (e.g., "Edge — really nothing to consider?"). Only after activation is acknowledged does the agent draft cells.

### Rule 6 — Internal drill axes stay internal

The dimensions are visible in the matrix because they help the developer scan coverage. Older internal drill axes (Vagueness / Consistency / Completeness / Specificity) are subsumed by the dimensions and are not exposed in the quiz file.

### Rule 7 — Critique loop until clean

For each Q, after the developer answers, the agent runs a critique pass. Any remaining ambiguity, contradiction with another cell, or invariant violation is logged. The developer refines. Repeat until the critique log is clean.

### Rule 8 — Lock is explicit

After every active cell has an answer (or `deferred` mark) and every critique log is clean, the agent proposes a lock candidate. The developer confirms (`lock` or equivalent). After lock, the matrix is frozen as the test spec for `humanpowers:operate` and `humanpowers:verification-before-completion`.

## Loop kick-back

The brainstorm → writing-plans → quiz sequence is not linear. The quiz is the place where mismatches between the developer's mental model and the agent's reading of the artifacts surface. When that happens, returning to an earlier skill is the right move, not a regression.

Typical kick-back triggers (illustrative, not exhaustive):

- An active dimension has no item to cite. The agent flags the gap and routes back. Missing observables / constraints / assumptions / dependencies → `humanpowers:writing-plans`. Missing criterion / invariant / open-question → `humanpowers:brainstorming`.
- A developer answer contradicts a cited invariant. The agent surfaces the conflict; the developer either revises the answer or revises the invariant in `problem.md` (which kicks back to brainstorming).
- An open-question turns out to imply a task split or a new task. Both `problem.md` and `tasks.md` get updated; the quiz re-cites the new IDs.

There is no formal trigger machine. Kick-back is the natural consequence of the agent or developer noticing "we're talking past each other." After the upstream artifact is updated and a new item ID exists, the quiz re-derives the relevant cells.

## Cross-task cascade

A locked quiz on task A may turn out to constrain task B. The agent records the cascade in `task-A` quiz's notes and flags it for `humanpowers:review`. The flag is informational only — `humanpowers:review` (not the quiz skill itself) decides whether to re-quiz task B.

## What the quiz is not

- Not a school exam. The developer already knows the answers; the quiz forces the developer to externalize them.
- Not a place to add new design content. New content belongs in `problem.md` or `tasks.md`. The quiz only cites.
- Not a substitute for the developer reading the code. If a cited code line is wrong, fix the cite first.
- Not optional for non-trivial tasks. Small tasks may get a quiz with 4–5 cells across 2–3 active dimensions, but the activation log is always present.
