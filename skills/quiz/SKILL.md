---
name: quiz
description: Use after humanpowers:writing-plans when tasks.md item IDs exist but per-task round1.md is not yet locked. Produces a 9-dimension perception-gap matrix per task by citing item IDs from problem.md and tasks.md (no invention). Locks the matrix as the test spec for downstream operate / verify. Hands off to humanpowers:operate next.
---

# Quiz Module

The quiz narrows the perception gap between the developer (who already has a mental model) and the agent (who is reconstructing it from `problem.md` and `tasks.md`). Every place the agent could guess is a decision point. The quiz surfaces those points so the developer makes the call explicitly. After lock, the matrix is the test spec for `humanpowers:operate` and `humanpowers:verification-before-completion`.

The quiz does not invent design content. It cites item IDs. If a needed decision point has no supporting item, the quiz routes back to `humanpowers:brainstorming` (for problem-level items) or `humanpowers:writing-plans` (for task-level items) — see Loop kick-back below.

See `references/quiz-guidelines.md` for the dimension definitions, decision-point sources, and authoring rules.

## Position in the workflow

```
brainstorming    → problem.md (criterion / invariant / out-of-scope / open-question)
writing-plans    → tasks.md (per-task item IDs) + plan.md per task
QUIZ (this)      → tasks/{id}/round1.md (matrix + Q bodies, locked)
operate          → reads round1.md as test spec, executes plan.md
verification     → developer demo signoff against round1.md
```

## Inputs

Resolve workspace from cwd via upward search:

```bash
DIR="$(pwd)"; WS=""
while [ "$DIR" != "/" ]; do
  [ -f "$DIR/.humanpowers/state.json" ] && WS="$DIR" && break
  DIR="$(dirname "$DIR")"
done
```

Required upstream artifacts:
- `<WS>/.humanpowers/problem.md` — criteria, invariants, out-of-scope items, open questions
- `<WS>/.humanpowers/tasks.md` — per-task item IDs (observable / verify-condition / constraint / assumption / dependency)
- `<WS>/.humanpowers/state.json` — phase should be `designed`. If `problem-defined`, route to writing-plans first.

Per-task artifacts produced:
- `tasks/{id}/round1.md` — quiz matrix + Q bodies. Mandatory.
- `tasks/{id}/round2.md` — optional second pass (developer-led). See round 2 section.
- `tasks/{id}/discussion.md` — agent appends discrepancies surfaced in round 2.

## The 9 dimensions

Rows of the matrix. Fixed.

| Dimension | What the question elicits |
|-----------|---------------------------|
| Intent | What this task is trying to produce, where its boundary stops. |
| Observable | What an outside reader sees once the task is done. |
| Acceptance | The condition that means done — pass criterion, threshold. |
| Constraint | A bound, invariant, or prohibition. |
| Assumption | What the task takes as given — input, prior state, environment. |
| Dependency | Where inputs come from. |
| Edge | Empty / null / extreme / out-of-range handling. |
| Failure | What "wrong" looks like, detection, response. |
| Decision | A point where multiple valid paths exist; pick one and say why. |

## round 1 (mandatory, agent-led)

### Step 1: Activation log

For the task, fill the activation log: which dimensions are active, why, and how many decision points each is expected to yield. Skipped dimensions get an explicit reason. The developer can challenge skips before any cell is drafted.

| Dimension | Active? | Reason | Predicted decision points |
|-----------|---------|--------|---------------------------|

After the developer acknowledges activation, proceed to Step 2.

### Step 2: Draft the coverage matrix

For each active dimension, identify decision points by citing item IDs:

- `criterion-N`, `invariant-N`, `out-of-scope-N`, `open-question-N` from `problem.md`
- `task-N.observable-N`, `task-N.verify-condition-N`, `task-N.constraint-N`, `task-N.assumption-N`, `task-N.dependency-N` from `tasks.md`
- A locked round1.md from a depended-upon task (cross-task cascade)
- A specific code line (`path/to/file.py:142`) if the existing codebase surfaces an unspecified branch
- An agent-library universal pattern (token cap, cache invalidation, deterministic order) — flag these as low-trust; the developer should review them first

Each cell holds one question. ID it `Q-{Dim}.{cited-item-id}` and state the decision in one line. Empty cells are explicit skips, not omissions.

If a dimension is active but no item supports a decision point, do NOT invent. Halt and route back — see Loop kick-back below.

### Step 3: Q body authoring

For each cell, expand into a Q body in `tasks/{id}/round1.md` using the structure in `references/templates/quiz-template.md`. Each Q body specifies:

- **Cited item** — the ID being referenced
- **Context** — 1-2 paragraphs; code excerpts ≤ 5 lines or use anchors like `path/to/file.py:142`
- **Expected answer shape** — one of: `pick one of [A/B/C]` / `write number (with unit)` / `yes/no` / `free text (≤ N words)`
- **Options** (when shape is `pick one`) — 3-5 mutually exclusive options ending with `other (write own)`
- **Developer answer** — blank for the developer to fill
- **Source (evidence anchor)** — design item ID / code line / external doc URL / `guess (no source)` (low trust)
- **Critique log** — agent fills during review
- **Test spec (auto-derived after lock)** — agent fills after lock

DO NOT pre-fill the developer's answer. The developer must articulate from blank.

### Step 4: Developer answers

Show the developer the path:

```
Edit <workspace>/.humanpowers/tasks/{id}/round1.md
Save when done.
```

Use AskUserQuestion to wait:

```
Q: Have you completed round1.md for task-{id}? options: Done / Skip task / Abort
```

### Step 5: Per-Q critique loop (one AskUserQuestion at a time)

Read the developer's answer for each Q. Run a critique pass:

- Is the answer ambiguous (still vague after attempt)?
- Does it contradict another cell's answer or a cited invariant?
- Does it leave any active dimension unaddressed?
- Is the evidence anchor weak (`guess`)?

For each issue found, ask ONE AskUserQuestion. Free text or options as appropriate. Update the answer. Re-evaluate that Q only.

```
critiques = []
for ambiguity in scan(developer_answer):
    critiques.append(ambiguity)

while critiques:
    critique = critiques.pop(0)  # ONE at a time
    new_answer = AskUserQuestion(question=critique.question_text, options=critique.options if critique.has_options else None)
    update_round1_md(developer_answer, Q, new_answer)
    critiques = [c for c in re_check(...)]

# Q locked when critiques empty
mark Q as locked in round1.md
```

**ANTI-PATTERN (banned)**: Bulk dump multiple critiques in one message ending "What do you think?" This is irresponsible delegation.

**REQUIRED**: One AskUserQuestion call per critique. Loop until the critique log is clean for that Q.

### Step 6: Lock the matrix

After every active cell has an answer (or `deferred` mark) and every critique log is clean, propose lock:

```
AskUserQuestion:
  Q: All active cells answered, all critiques clean. Lock round1.md for task-{id}?
  options: Lock / Re-review one cell / Abort
```

On `Lock`:
- Mark `tasks.md#task-{id}` `STATUS: quiz-done`.
- Auto-derive a `Test spec` block per Q (developer answer → executable test or demo step).
- Increment `tasks_quiz_done` in state.json.

## round 2 (optional, developer-led)

After round 1 lock, offer round 2:

### Step A: Offer round 2

```
AskUserQuestion:
  Q: Round 2 — write your own answers independently and let the agent compare? (Surfaces hidden mismatches.)
  options:
    - Yes — start with the round 2 template
    - Yes — free format (developer handles)
    - Pass (skip round 2)
```

If `Yes — start with the round 2 template`, copy `references/templates/response-round2-template.md` to `tasks/{id}/round2.md`.

### Step B: Map developer's freeform answers (if free format)

After developer provides `round2.md`:

Read it. Attempt to map content to round1.md cells.

```
AskUserQuestion:
  Q: Mapping result: Q-X.Y = ... / Q-A.B = (no answer) / Q-C.D = ... — correct?
  options: [Correct, Revise (free text)]
```

Loop until mapping confirmed.

### Step C: Agent's parallel pass

For each cell, agent writes its own answer (independent of developer round 1 + developer round 2). Append to `tasks/{id}/round2.md` under an "Agent's parallel pass" section.

### Step D: Discrepancy detection

For each cell, compare developer round 2 answer (if provided) vs agent answer.

If different (semantic, not just wording), append to `tasks/{id}/discussion.md` per `references/templates/discussion-template.md`.

### Step E: Per-cell decision via AskUserQuestion

For each unresolved discrepancy:

```
AskUserQuestion:
  Q: Cell {Q-id} mismatch — how to resolve?
  options:
    - 1. Discuss further
    - 2. Adopt agent answer (developer answer revised)
    - 3. Keep developer answer (agent answer archived)
```

### Step F: Discuss further → discussion loop

If `1. Discuss further`:
- Re-read `discussion.md` + developer additional comments.
- Agent responds with rebuttal or refinement.
- Possibly multiple turns.
- Final cascade decision (checkboxes in discussion.md):
  - [ ] Update task's round1.md
  - [ ] Update task's tasks.md entry (item ID content)
  - [ ] Update problem.md invariants (project invariants 갱신)
  - [ ] Other tasks affected (flag only — developer explicitly invokes)

### round 2 lock

All discrepancies resolved (option 1 final / 2 / 3) → round 2 done. Update `round1.md` if cascade required.

## Loop kick-back

The brainstorm → writing-plans → quiz sequence is a loop, not a one-way pipeline. When the quiz finds a gap or contradiction, route back to the upstream skill rather than inventing content.

Typical kick-back triggers (illustrative, not exhaustive):

- An active dimension has no item to cite → route back.
  - Missing observable / verify-condition / constraint / assumption / dependency → `humanpowers:writing-plans` (append a new `task-N.<category>-N` ID).
  - Missing criterion / invariant / out-of-scope / open-question → `humanpowers:brainstorming` (append a new `<category>-N` ID).
- A developer answer contradicts a cited invariant → surface the conflict; the developer either revises the answer or the invariant.
- An open question's answer implies a task split or new task → both `problem.md` and `tasks.md` get updated; the quiz re-cites the new IDs.

There is no formal trigger machine. Kick-back is the natural consequence of "we're talking past each other." After the upstream artifact gains a new ID, the quiz re-derives the relevant cells.

## Cross-task cascade

A locked round1.md on task A may turn out to constrain task B. Record the cascade in task A's round1.md notes and flag it for `humanpowers:review`. The flag is informational — `humanpowers:review` (not the quiz skill) decides whether to re-quiz task B.

## Phase transition

After all selected tasks reach `quiz-done`:

```bash
bash scripts/update-state.sh "$WS" phase quiz-done
```

Hand off to `humanpowers:operate`.

> "Quiz phase complete for {N} tasks. Phase = `quiz-done`. Next: `humanpowers:operate` (per task) or `humanpowers:operate --batch` (remaining tasks)."

## Boundaries

- **Don't** pre-fill the developer's answer in round 1.
- **Don't** invent decision points without a citable item — kick back instead.
- **Don't** bulk-dump critiques. One AskUserQuestion per critique.
- **Don't** auto-cascade to other tasks. Flag only — developer explicitly invokes.
- **Don't** skip tasks with `STATUS: brainstorm-done` or earlier. All selected tasks must reach `quiz-done` before operate.
