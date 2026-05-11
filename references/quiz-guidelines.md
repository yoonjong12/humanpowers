# Quiz Authoring Guidelines

The agent reads this before drafting any quiz. The developer never sees it. The guidelines define the 9 perception-gap dimensions, how decision points are sourced from design items, and the rules each question must obey.

## What a quiz is for

A quiz narrows the perception gap between the developer (who already has a mental model) and the agent (who is reconstructing it from the design artifacts). The quiz surfaces points where the developer must choose between alternatives and forces them to commit. Once the quiz is locked, the agent is forbidden from guessing on the cited items.

### The core principle

**Facts are the agent's job. Decisions are the developer's job.**

The agent can read code, run grep, check types, trace call sites. Anything the agent can determine by inspecting the codebase is NOT a quiz question — it is the agent's homework.

The quiz exists to extract what the agent CANNOT determine: the developer's judgment on tradeoffs, preferences, risk tolerance, and boundary placement.

### What is a decision

A valid quiz question meets ALL three conditions:

1. **Human judgment required** — the answer involves a tradeoff, preference, or risk tolerance call
2. **Multiple valid paths exist** — if only one path is correct, it is not a decision
3. **Cannot be answered by reading code** — if grep/test/read resolves it, the agent should do it, not ask

What is NOT a decision:

| Pattern | Example | Why not | Agent should instead |
|---------|---------|---------|---------------------|
| **Verification** | "Is `_find_review` only called from here?" | Deterministic fact | `grep -rn _find_review` |
| **Confirmation** | "PatternStep에만 추가되는 거 맞지?" | Rubber-stamp request | Read the model definition |
| **Restatement** | "이 가정이 맞는지?" | Echoing the design doc | Check evidence, then either confirm silently or surface a conflict |

## The 9 dimensions

Dimensions are work-agnostic. They apply to software features, research questions, data analyses, algorithm designs — any task expressible as a `tasks.md` entry.

| Dimension | What the question elicits | Decision looks like | Agent verifies (not quiz) |
|-----------|---------------------------|---------------------|--------------------------|
| **Intent** | What this task produces, where its boundary stops. | "Should this also cover X, or is X out of scope?" | Read task spec to confirm stated scope. |
| **Observable** | What an outside reader sees once done. | "Which format/shape should the output take?" | Check existing code for current output format. |
| **Acceptance** | The exact condition that means done. | "Where to set the threshold — strict or lenient?" | Run existing tests to see what currently passes. |
| **Constraint** | A bound, invariant, or prohibition. | "Which bound applies, and what's the tradeoff at the boundary?" | Read config/code for current bounds. |
| **Assumption** | A verified precondition the task builds on. Must have evidence. | "If this assumption breaks, which fallback?" | Check assumption with evidence (grep, query, code read). Confirmed → not a quiz Q. Unconfirmed → open question, kick back. |
| **Dependency** | Where inputs come from. | "Which of N ways to satisfy this input?" | Check if dependency exists (import, config, API call). |
| **Edge** | Empty / null / extreme / out-of-range handling. | "How to handle empty: skip, error, or default?" | Run code with edge inputs to observe current behavior. |
| **Failure** | What "wrong" looks like, detection, response. | "Fail silently, log, or raise? At what granularity?" | Read existing error handling code. |
| **Decision** | Multiple valid paths; pick one with rationale. | Always a decision by definition. | N/A. |

A single task usually activates 5–7 dimensions, sometimes all 9. Trivial config changes may activate only Intent and Observable.

**Reading the table:** For each dimension, the agent first does the work in the "Agent verifies" column. If the verification reveals a fork (multiple valid paths), THAT fork becomes a quiz question in the "Decision looks like" form. If verification resolves to a single answer, no quiz question is needed — the agent records the fact and moves on.

## Decision point sources

The agent identifies decision points by citing existing design items. There are six sources, each with a different trust level. The agent labels each cell with the source:

| Source | Where to look | Trust |
|--------|---------------|-------|
| **design (problem.md)** | `criterion-N`, `invariant-N`, `out-of-scope-N`, `open-question-N` | high — explicit |
| **design (tasks.md)** | `task-N.observable-N`, `task-N.verify-condition-N`, `task-N.constraint-N`, `task-N.assumption-N`, `task-N.dependency-N` | high — explicit |
| **prior lock** | a previously locked quiz on a depended-upon task | high — already settled |
| **code read** | an inspection of existing code that surfaced an unspecified branch | medium — agent interpretation |
| **personal learnings** | `~/.humanpowers/learnings/quiz.md` — accumulated guidelines from past projects via retrospective | medium — past experience |
| **agent library** | universal patterns the agent applies (token cap, cache invalidation, deterministic order) | low — agent guess; flag for developer scrutiny |

Cells from low-trust sources should be reviewed first by the developer. If a cell needs a dimension activated but no item supports it, the agent does not invent. It surfaces the gap and routes back to the upstream skill.

## Authoring rules

### Rule 1 — One question, one decision

Each question elicits one decision. If a draft asks "where, how, and how much," split it into three.

A "decision" must satisfy all three conditions from "What is a decision" above. Before writing any Q body, classify: is this a Decision, a Verification, or a Confirmation? Only Decisions become Q bodies. Verifications are the agent's homework. Confirmations are not questions.

### Rule 2 — Cite item IDs, do not invent

Every cell cites at least one item ID. If a decision point has no supporting item, the agent surfaces the gap (see Loop kick-back below). Cells without citation are not allowed.

### Rule 3 — Answer shape required

Every Q body specifies the shape of the answer the developer is expected to give:

- `pick one of [A/B/C]`
- `write number (with unit)`
- `yes/no`
- `free text (≤ N words)`

If the shape is `pick one`, list 3–5 mutually exclusive options and end with `other (write own)` so the developer is not forced into an artificial set.

### Rule 3b — Consequence-bearing options

Each `pick one` option must include a `→ Result:` line describing what changes in behavior, coverage, or risk if chosen. The developer decides based on outcome differences, not label alone.

The Q body also requires a `**Why this decision matters**` field before the options — a 1-2 sentence explanation of the tradeoff, not a restatement of the cited item.

Bad (label only):
```
- A. model_dump/model_validate만 (dict roundtrip)
- B. 둘 다 (dict + JSON)
```

Good (consequence visible):
```
**Why this decision matters**: dict 직렬화와 JSON 직렬화는 다른 코드 경로를 탄다.
custom serializer 버그는 JSON roundtrip에서만 발현.

- A. model_dump/model_validate만 (dict roundtrip)
  → Result: Python 타입 보존 확인. JSON serializer 버그 미검출.
- B. 둘 다 (dict + JSON)
  → Result: custom type 변환 오류 조기 발견. 테스트 ~2배.
```

`other (write own)` option does not need a `→ Result:` line.

### Rule 10 — Type gate before Q body authoring

Before writing each Q body, the agent classifies the candidate:

| Type | Test | Action |
|------|------|--------|
| **Decision** | Human judgment required + multiple valid paths + code can't resolve | → Write Q body |
| **Verification** | Agent can determine the answer by reading code / running grep / running test | → Agent does it. Record the finding. No Q body. |
| **Confirmation** | Agent is asking developer to rubber-stamp its analysis | → Not a question. Remove. |

If a candidate fails the Decision test, it does not become a Q body — even if a dimension is active and an item ID supports it. The dimension stays active (it contributed to the agent's research) but the Q body count drops.

**`yes/no` shape restriction:** Use only for genuine binary decisions (do it / don't do it). If the real question is "which of several approaches," use `pick one`. A `yes/no` that is really "does my analysis sound right?" is always a Confirmation, never a Decision.

**Example — converting a Verification into a Decision (or dropping it):**

Verification (banned):
```
### Q-Assumption.task-3.assumption-1: _find_review 유일 호출자 확인
**Expected answer shape**: yes/no
```
↑ Agent can `grep -rn _find_review` to answer this. Not a quiz question.

If the verification reveals a fork, the fork becomes the Q body:
```
### Q-Decision.task-3.assumption-1: _find_review 제거 전략
**Why this decision matters**: _find_review는 1곳에서만 호출. 
제거 시 dead code 정리, 유지 시 future-proof.

**Options**:
- A. 삭제 (YAGNI)
  → Result: 코드 깔끔. 필요 시 git history 복원.
- B. 유지
  → Result: dead code 잔류. linter warning 가능.
- C. other (write own)
```

If verification reveals no fork (single correct path), no Q body needed — the agent records the fact and proceeds.

### Rule 4 — Evidence anchor required

Every developer answer carries a source. The source can be a design item ID, a code line (`path/to/file.py:142`), a referenced doc, or `guess (no source)`. A `guess` answer is not invalid, but the agent flags it in the critique log so it gets extra scrutiny.

**Exception — Assumption dimension:** `guess (no source)` is NOT acceptable for Assumption cells. An assumption must be backed by verifiable evidence: a query result, a code read, a doc reference, or a prior lock. If the developer cannot provide evidence, the item is not an assumption — it is an open question and must route back to brainstorming as `open-question-N`. The agent must challenge any assumption cell where the evidence is missing or weak:

> "You stated this as an assumption. What evidence confirms it holds today? (query output, code path, doc link)"

This is especially critical for `action_type: data` and `action_type: infra` tasks where assumptions about data state, schema shape, or service availability are the primary failure mode.

### Rule 5 — Activation log first, cells second

Before drafting any cell, the agent fills the activation log: which dimensions are active, why, and what fork the developer will decide. The developer can challenge a skipped dimension (e.g., "Edge — really nothing to consider?"). Only after activation is acknowledged does the agent draft cells.

The activation log must articulate the fork, not just a count. "Predicted decision points: 2" without naming the forks is insufficient — the agent commits to asking vague questions later. Name the fork: "A vs B: which source for description data?"

### Rule 6 — Internal drill axes stay internal

The dimensions are visible in the matrix because they help the developer scan coverage. Older internal drill axes (Vagueness / Consistency / Completeness / Specificity) are subsumed by the dimensions and are not exposed in the quiz file.

### Rule 7 — Critique loop until clean

For each Q, after the developer answers, the agent runs a critique pass. Any remaining ambiguity, contradiction with another cell, or invariant violation is logged. The developer refines. Repeat until the critique log is clean.

### Rule 8 — Lock is explicit

After every active cell has an answer (or `deferred` mark) and every critique log is clean, the agent proposes a lock candidate. The developer confirms (`lock` or equivalent). After lock, the matrix is frozen as the test spec for `humanpowers:operate` and `humanpowers:verification-before-completion`.

### Rule 9 — Research conflicts surface in the activation log

When code research during activation log preparation surfaces a conflict between existing implementation and a task design item (a constraint, assumption, observable, or dependency), the agent annotates the affected dimension row with a `⚠ CONFLICT:` note — not just in Q body context.

Format: add the conflict inline to the activation log Reason column:

```
| Decision | ✓ | constraint-1 → FK strategy | ⚠ CONFLICT: swap-schema renames graph schema; cross-schema FK survives rename but cascade won't fire on new graph.wisdoms; pcr drop-schema graph_old may fail on FK dep | 2 |
```

At activation acknowledgment, the developer picks one of three responses:

- **Proceed** — "Aware, will address in Q answer." No action on the activation log; Q body drafting continues.
- **Pause** — "Need to revise task design first." Loop kick-back to `humanpowers:writing-plans` (if task-level item) or `humanpowers:brainstorming` (if problem-level item) before Q body drafting resumes.
- **Dismiss** — "Not a conflict, here's why." Agent removes the annotation and proceeds.

Conflict annotations carry medium trust (code read source). The annotation is not a diagnosis — it is the agent saying "I found something that might matter." The developer rules on it.

If no response is given at acknowledgment, the agent treats the conflict as unresolved and does not proceed to Q body drafting.

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
