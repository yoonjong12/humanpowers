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

Personal learnings (if exists):
- `~/.humanpowers/learnings/quiz.md` — accumulated guidelines from past projects. Treat as a 6th decision point source (personal learnings, medium trust). Read before filling the activation log.

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
| Assumption | A verified precondition — confirmed with evidence, assumed to remain true. Unverified = open question, not assumption. |
| Dependency | Where inputs come from. |
| Edge | Empty / null / extreme / out-of-range handling. |
| Failure | What "wrong" looks like, detection, response. |
| Decision | A point where multiple valid paths exist; pick one and say why. |

## round 1 (mandatory, agent-led)

### Step 1: Activation log

Before filling the activation log, read the existing code to identify decision points (code read source, medium trust). If this research surfaces a conflict between the existing implementation and a task design item, annotate the affected dimension row with `⚠ CONFLICT:` inline — see Rule 9 in `references/quiz-guidelines.md`.

Fill the activation log: which dimensions are active, why, and what fork the developer decides. Skipped dimensions get an explicit reason. Dimensions where agent verification resolved all questions (no fork remains) are marked active but with `Fork: —` and `Qs: 0`.

| Dimension | Active? | Reason | Fork (what the developer decides) | Qs |
|-----------|---------|--------|-----------------------------------|-----|

At acknowledgment, the developer must resolve any `⚠ CONFLICT:` annotations (Proceed / Pause / Dismiss) before proceeding to Step 2. If unresolved, do not draft cells.

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
- **Why this decision matters** — 1-2 sentences on the tradeoff (not a restatement of the cited item)
- **Context** — optional code excerpts ≤ 5 lines or anchors like `path/to/file.py:142`
- **Expected answer shape** — one of: `pick one of [A/B/C]` / `write number (with unit)` / `yes/no` / `free text (≤ N words)`
- **Options** (when shape is `pick one`) — 3-5 mutually exclusive options, each with `→ Result:` showing outcome difference. End with `other (write own)`. See Rule 3b in `references/quiz-guidelines.md`.
- **Developer answer** — agent writes from AUQ response (Step 4)
- **Source (evidence anchor)** — design item ID / code line / external doc URL / `guess (no source)` (low trust)
- **Critique log** — agent fills during review
- **Test spec (auto-derived after lock)** — agent fills after lock

DO NOT pre-fill the developer's answer during Q body authoring. The developer answers via AUQ in Step 4; the agent writes the response back to round1.md.

**Type gate per Q body (mandatory before writing):** Classify each candidate as Decision, Verification, or Confirmation per Rule 10 in `references/quiz-guidelines.md`.

- **Decision** → write Q body. The fork must match what was named in the activation log.
- **Verification** → agent resolves it (grep/read/test). Record finding. No Q body.
- **Confirmation** → not a question. Remove.

`yes/no` shape is only for genuine binary decisions (do it / don't do it), not confirmation requests.

### Step 4: Per-Q inline presentation + critique

Developer does NOT edit round1.md directly. Agent presents each Q inline, developer decides via AUQ, agent writes answer back to round1.md. Critique runs per-Q before moving to next.

For each Q body (activation log order):

#### 4A. Chat preamble — co-locate decision context

Show the decision context inline. Developer must have everything needed to decide **in the same screen**.

```
## Q-{Dim}.{cited-item-id}: <one-line decision>

**Why**: <tradeoff from Q body — what changes depending on choice>

```<language>
<actual code from the file, NOT an anchor. Read the file, paste the lines.>
```
```

If the Q has no code context (pure design decision), skip the code block. But for any Q that references a code path or existing implementation, **read the file and show the actual lines**.

#### 4B. AskUserQuestion — one call per Q

For `pick one` shape:

```
AskUserQuestion:
  question: "<decision in plain language>?"
  header: "<Dim>" (max 12 chars — abbreviate dimension name)
  options:
    - label: "A. <option name>"
      description: "<→ Result: consequence difference>"
      preview: |
        <multiline markdown: code/config/test shape this option produces>
        <what the implementation looks like if chosen>
    - label: "B. <option name>"
      description: "<→ Result: consequence difference>"
      preview: |
        <what this option produces — concrete diff from A>
    - label: "C. <option name>"
      description: "<→ Result: consequence difference>"
      preview: |
        <what this option produces>
```

`preview` = code fences, diffs, config snippets, test outlines. Rendered in sidebar when option focused. This is where the developer sees what each choice **actually produces** — not abstract descriptions.

For `yes/no` shape: 2 options, each with `preview` showing the yes-path vs no-path implementation.

For `free text` / `write number` shape: present as chat question (no AUQ). Developer types answer directly.

#### 4C. Write answer to round1.md

After developer selects:
1. Write selection to `**Developer answer**:` field in round1.md
2. Write evidence to `**Source**:` field (cited item + any code line shown in preamble)

#### 4D. Per-Q critique (immediate, before next Q)

Run critique on this Q's answer NOW:

- Ambiguous (vague after attempt)?
- Contradicts another cell's answer or cited invariant?
- Leaves active dimension unaddressed?
- Evidence anchor weak (`guess`)?

If issue found → ONE AskUserQuestion per critique. Loop until critique log clean for this Q. Then move to next Q.

```
for Q in Qs_in_activation_log_order:
    show_preamble(Q)           # 4A
    answer = ask_user(Q)       # 4B
    write_to_round1(Q, answer) # 4C
    critique_loop(Q)           # 4D — loop until clean
    # Q done. Next Q.
```

**ANTI-PATTERN (banned)**: Bulk dump multiple critiques. One AUQ per critique, one Q at a time.

After all Qs answered + critiqued → proceed to Step 5 (lock).

### Step 5: Lock the matrix

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

Execute the 3-step handoff protocol (see humanpowers dispatcher, Notes for skill authors):

1. Phase already set to `quiz-done` above.
2. Report: "Phase → quiz-done. {N} tasks ready. Invoking humanpowers:operate."
3. Ask developer which mode, then invoke immediately:

```
AskUserQuestion:
  Q: All quizzes locked. How to proceed with operate?
  options:
    - Batch (all tasks sequentially)
    - Single task (pick one)
```

On Batch → invoke `humanpowers:operate --batch` via Skill tool **now**.
On Single → ask which task, then invoke `humanpowers:operate {id}` via Skill tool **now**.

## Boundaries

- **Don't** pre-fill the developer's answer in round 1.
- **Don't** invent decision points without a citable item — kick back instead.
- **Don't** bulk-dump critiques. One AskUserQuestion per critique.
- **Don't** auto-cascade to other tasks. Flag only — developer explicitly invokes.
- **Don't** skip tasks with `STATUS: brainstorm-done` or earlier. All selected tasks must reach `quiz-done` before operate.
