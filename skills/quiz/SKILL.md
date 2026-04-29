---
name: quiz
description: Use after humanpowers:brainstorming when TF specs exist but expected-outputs aren't signed off. Forces developer to articulate expected behavior per TF via mandatory D1 quiz (agent asks, developer answers, agent critiques) and optional D2 self-response (developer writes own answers, agent compares, discrepancies trigger discussion + cascade refinement). Output = signed_off expected-outputs.md per TF, used directly as test spec by TDD/SDD downstream.
---

# Quiz Module

## Position in workflow

```
brainstorming (TF specs drafted)
  ↓
QUIZ (this skill)
  ├─ D1 mandatory: Agent → Developer
  └─ D2 optional: Developer → Agent
  ↓
writing-plans (TF-unit build plans)
  ↓
test-driven-development (uses expected-outputs.md as test spec)
  ↓
operate per TF (or executing-plans for batch)
  ↓
verification-before-completion (developer demo signoff)
```

## Inputs

- Workspace resolved via upward search from cwd:
  ```bash
  DIR="$(pwd)"; WS=""
  while [ "$DIR" != "/" ]; do
    [ -f "$DIR/.humanpowers/state.json" ] && WS="$DIR" && break
    DIR="$(dirname "$DIR")"
  done
  ```
- `tfs.md` exists with at least 1 TF spec
- For each TF (specified arg or default to all `status: problem-defined`):
  - `tfs/{TF-id}/quiz.md` — agent generates if missing
  - `tfs/{TF-id}/response-d1-developer.md` — developer writes (mandatory)
  - `tfs/{TF-id}/response-d2-developer.md` — developer optionally provides
  - `tfs/{TF-id}/response-d2-agent.md` — agent writes (D2 only)
  - `tfs/{TF-id}/discussion.md` — agent appends discrepancies
  - `tfs/{TF-id}/expected-outputs.md` — final signed_off output

## D1 Mandatory — Agent → Boss

### Step 1: Generate quiz.md per TF

Read `tfs.md#TF-{id}` for 5 fields + `action_type`.

Generate quiz.md from `references/templates/quiz-template.md` baseline. Add 5-10 questions per TF, distributed across 4 axes:

- **Vagueness**: at least 1 Q targeting any vague term in WHAT/VERIFY
- **Consistency**: at least 1 Q tying to NFR or developer invariants
- **Completeness**: at least 1 Q on error/edge cases (e.g., "What if input is empty? What if N=0?")
- **Specificity**: at least 1 Q forcing concrete value (e.g., "What is 'fast'? Quantify in ms.")

Use action_type-specific question templates (see references/examples/quiz-{type}-example.md).

DO NOT pre-fill agent's own answers. Boss must articulate from blank.

### Step 2: Developer writes response-d1-developer.md

Use `references/templates/response-d1-template.md` as starting skeleton. Developer fills each Q answer.

humanpowers waits for developer to commit (or save) the file before proceeding.

Show developer the path:
```
Edit <workspace>/tfs/{TF-id}/response-d1-developer.md
Save when done.
```

Use AskUserQuestion to wait:
```
Q: Have you completed response-d1-developer.md for TF-{id}? options: Done / Skip TF / Abort
```

### Step 3: Per-Q critique loop (AUQ ONE question at a time)

Read response-d1-developer.md for TF.

For each question (Q1, Q2, ...):

```
critiques = []
for axis in [Vagueness, Consistency, Completeness, Specificity]:
    issues = check_axis(developer_answer, axis, references/templates/critique-axes.md)
    critiques.extend(issues)

while critiques:
    critique = critiques.pop(0)  # ONE at a time
    new_answer = AskUserQuestion(
        question=critique.question_text,
        options=critique.options if critique.has_options else None,
        # else: free text
    )
    update_response_md(developer_answer, Q, new_answer)
    # re-evaluate THIS Q only
    critiques = [c for c in re_check(...)]

# Q locked when no more critiques
mark Q as locked in response-d1-developer.md
```

**ANTI-PATTERN (banned)**: Bulk dump multiple critiques in one message ending "What do you think?" This is irresponsible delegation.

**REQUIRED**: One AUQ call per critique. Loop until agent has zero critiques for a Q.

### Step 4: All Qs locked → write expected-outputs.md

Aggregate all locked Q answers into `tfs/{TF-id}/expected-outputs.md`. Auto-derive test spec block per Q (see template).

Set `tfs.md#TF-{id}` `status: quiz-done` (Phase 1 marker).

## D2 Optional — Developer → Agent

After D1 complete (per TF), offer D2:

### Step A: Offer D2

```
AskUserQuestion:
  Q: D2 응답지 작성하시겠어요? (Developer provides own answers, agent compares)
  options:
    - Yes, write my own response sheet (specify filename)
    - Pass (skip D2)
```

If "Yes":

```
AskUserQuestion:
  Q: 템플릿 받으시겠어요? 또는 자유 형식?
  options:
    - 템플릿 (response-d2-template.md copied)
    - 자유 형식 (developer handles)
  + free text: filename for response-d2-developer.md (default = standard path)
```

### Step B-1: Agent maps freeform to Qs

After developer provides response-d2-developer.md:

Read it. Attempt to map content to quiz.md Q1, Q2, ...

```
AskUserQuestion:
  Q: 보스 응답 매핑 결과: Q1=... / Q2=(미응답) / Q3=... 맞나요?
  options:
    - 맞음
    - 수정 (free text: provide corrections)
```

Loop until mapping confirmed.

### Step C: Agent writes response-d2-agent.md

For EACH Q in quiz, agent writes its own answer (independent of developer D1 + developer D2). Save to `tfs/{TF-id}/response-d2-agent.md`.

### Step D: Discrepancy detection

For each Q, compare developer D2 answer (if provided) vs agent answer.

If different (semantic, not just wording):
- Append to `tfs/{TF-id}/discussion.md` per `references/templates/discussion-template.md`:

```markdown
## Q{N} 불일치

**Developer D2 answer**: ...
**Agent answer**: ...
**Difference**:
**Agent reasoning**: ...
**Decision**: pending
```

### Step E: Per-Q decision via AUQ

For each unresolved discrepancy:

```
AskUserQuestion:
  Q: Q{N} 불일치 — 어떻게 처리?
  options:
    - 1. 논의 필요
    - 2. Agent 답 채택 (developer 답 변경)
    - 3. Developer 답 유지 (agent 답 archive)
```

### Step F: 논의 필요 → discussion loop

If "1. 논의 필요":
- Re-read discussion.md + developer additional comments
- Agent responds with rebuttal/refinement
- Possibly multiple turns
- Final cascade decision (checkbox in discussion.md):
  - [ ] 해당 TF expected-outputs 갱신
  - [ ] 해당 TF 5필드 spec (tfs.md) 갱신
  - [ ] developer invariants / 페르소나 갱신
  - [ ] 다른 TF 영향 (flag only — developer 명시 invoke)

### Lock

All discrepancies resolved (option 1 final / 2 / 3) = D2 done. Update expected-outputs.md if cascade required.

Set `tfs.md#TF-{id}` `status: quiz-done`.

## Termination

After all selected TFs complete D1 (and optionally D2):

- All `tfs.md` rows have `status: quiz-done` for the selected TFs
- Update `.humanpowers/state.json` phase = `quiz-done`
- Next phase = `writing-plans`

Tell developer:
```
Quiz phase complete for {N} TFs. Next: humanpowers:writing-plans (TF-unit build plans).
Or: /humanpowers continue
```

## Boundaries

- **Don't** generate developer's answers in D1. Developer must write blank.
- **Don't** bulk-dump critiques. Per-Q AUQ only.
- **Don't** auto-cascade to (iv) other TFs. Flag only — developer explicitly invokes.
- **Don't** skip TFs with `status: problem-defined`. All must reach `quiz-done` before any builds.
