---
name: quiz
description: Use after humanpowers:brainstorming when task specs exist but round1.md isn't signed off. Forces developer to articulate expected behavior per task via mandatory round 1 (agent-led, agent asks, developer answers, agent critiques) and optional round 2 (developer-led, developer writes own answers, agent compares, discrepancies trigger discussion + cascade refinement). Output = signed_off round1.md per task, used directly as test spec by TDD downstream.
---

# Quiz Module

## Position in workflow

```
brainstorming (task specs drafted)
  ↓
QUIZ (this skill)
  ├─ round 1 (mandatory, agent-led)
  └─ round 2 (optional, developer-led)
  ↓
writing-plans (task-unit build plans)
  ↓
test-driven-development (uses round1.md as test spec)
  ↓
operate per task (or executing-plans for batch)
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
- `tasks.md` exists with at least 1 task spec
- For each task (specified arg or default to all `status: problem-defined`):
  - `tasks/{id}/quiz.md` — agent generates if missing
  - `tasks/{id}/round1.md` — developer writes (mandatory)
  - `tasks/{id}/round2.md` — developer optionally provides (developer-led) or agent writes (agent pass)
  - `tasks/{id}/discussion.md` — agent appends discrepancies

## round 1 (mandatory, agent-led)

### Step 1: Generate quiz.md per task

Read `tasks.md#{id}` for 5 fields + `action_type`.

Generate quiz.md from `references/templates/quiz-template.md` baseline. Add 5-10 questions per task, distributed across 4 axes:

- **Vagueness**: at least 1 Q targeting any vague term in WHAT/VERIFY
- **Consistency**: at least 1 Q tying to task-local NFR or project invariants
- **Completeness**: at least 1 Q on error/edge cases (e.g., "What if input is empty? What if N=0?")
- **Specificity**: at least 1 Q forcing concrete value (e.g., "What is 'fast'? Quantify in ms.")

Use action_type-specific question templates (see references/examples/quiz-{type}-example.md).

DO NOT pre-fill agent's own answers. Developer must articulate from blank.

### Step 2: Developer writes round1.md

Use `references/templates/response-d1-template.md` as starting skeleton. Developer fills each Q answer.

humanpowers waits for developer to commit (or save) the file before proceeding.

Show developer the path:
```
Edit <workspace>/tasks/{id}/round1.md
Save when done.
```

Use AskUserQuestion to wait:
```
Q: Have you completed round1.md for task {id}? options: Done / Skip task / Abort
```

### Step 3: Per-Q critique loop (AskUserQuestion ONE question at a time)

Read round1.md for task.

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
mark Q as locked in round1.md
```

**ANTI-PATTERN (banned)**: Bulk dump multiple critiques in one message ending "What do you think?" This is irresponsible delegation.

**REQUIRED**: One AskUserQuestion call per critique. Loop until agent has zero critiques for a Q.

### Step 4: All Qs locked → write round1.md

Aggregate all locked Q answers into `tasks/{id}/round1.md`. Auto-derive test spec block per Q (see template).

Set `tasks.md#{id}` `status: quiz-done` (Phase 1 marker).

## round 2 (optional, developer-led)

After round 1 complete (per task), offer round 2:

### Step A: Offer round 2

```
AskUserQuestion:
  Q: round 2 응답지 작성하시겠어요? (Developer provides own answers, agent compares)
  options:
    - Yes, write my own response sheet (specify filename)
    - Pass (skip round 2)
```

If "Yes":

```
AskUserQuestion:
  Q: 템플릿 받으시겠어요? 또는 자유 형식?
  options:
    - 템플릿 (response-d2-template.md copied)
    - 자유 형식 (developer handles)
  + free text: filename for round2.md (default = standard path)
```

### Step B-1: Agent maps freeform to Qs

After developer provides round2.md:

Read it. Attempt to map content to quiz.md Q1, Q2, ...

```
AskUserQuestion:
  Q: 개발자 응답 매핑 결과: Q1=... / Q2=(미응답) / Q3=... 맞나요?
  options:
    - 맞음
    - 수정 (free text: provide corrections)
```

Loop until mapping confirmed.

### Step C: Agent writes round2.md (agent pass)

For EACH Q in quiz, agent writes its own answer (independent of developer round 1 + developer round 2). Save to `tasks/{id}/round2.md`.

### Step D: Discrepancy detection

For each Q, compare developer round 2 answer (if provided) vs agent answer.

If different (semantic, not just wording):
- Append to `tasks/{id}/discussion.md` per `references/templates/discussion-template.md`:

```markdown
## Q{N} 불일치

**Developer round 2 answer**: ...
**Agent answer**: ...
**Difference**:
**Agent reasoning**: ...
**Decision**: pending
```

### Step E: Per-Q decision via AskUserQuestion

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
  - [ ] 해당 task round1.md 갱신
  - [ ] 해당 task 5필드 spec (tasks.md) 갱신
  - [ ] project invariants / 페르소나 갱신
  - [ ] 다른 task 영향 (flag only — developer 명시 invoke)

### Lock

All discrepancies resolved (option 1 final / 2 / 3) = round 2 done. Update round1.md if cascade required.

Set `tasks.md#{id}` `status: quiz-done`.

## Termination

After all selected tasks complete round 1 (and optionally round 2):

- All `tasks.md` rows have `status: quiz-done` for the selected tasks
- Update `.humanpowers/state.json` phase = `quiz-done`
- Next phase = `writing-plans`

Tell developer:
```
Quiz phase complete for {N} tasks. Next: humanpowers:writing-plans (task-unit build plans).
Or: /humanpowers continue
```

## Boundaries

- **Don't** generate developer's answers in round 1. Developer must write blank.
- **Don't** bulk-dump critiques. Per-Q AskUserQuestion only.
- **Don't** auto-cascade to (iv) other tasks. Flag only — developer explicitly invokes.
- **Don't** skip tasks with `status: problem-defined`. All must reach `quiz-done` before any builds.
