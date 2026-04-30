---
name: review
description: Use after multiple tasks are verified to perform developer review of the project state, optionally bump developer.md version, and identify next priorities. Distinct from per-task verification (which is humanpowers:verification-before-completion). This is project-level review with cascade decisions.
---

# Review Skill

## When to invoke

- After at least 2 tasks reach `status: verified`
- Or developer explicitly requests `/humanpowers review`
- Before finishing-a-development-branch (final wrap)

## Steps

### Step 1: Aggregate state

Run `scripts/render-views.sh` to ensure views/*.md current.

Read:
- `views/progress.md` — status overview
- `developer.md` — invariants + version
- All `threads/*.md` — open vs resolved

### Step 2: Show developer the review summary

Display:
```
Project: {name}
Version: {developer.md version}

Tasks: {N total}
  problem-defined: {x}
  quiz-done: {x}
  designed: {x}
  built: {x}
  verified: {x}

Open threads: {count}
Resolved threads: {count}

project invariant violations (auto-detect): {none | list}
```

Pull invariant violations by scanning recent commits + tasks.md changes.

### Step 3: AskUserQuestion — review options

```
Q: 프로젝트 review 결과. 다음 액션?
options:
  - 1. 다음 task 우선순위 결정 (continue building)
  - 2. developer.md version bump (minor/major)
  - 3. Cascade — 특정 task expected-outputs 재검토 (re-quiz)
  - 4. Open threads 처리 (developer reviews threads)
  - 5. Finalize (humanpowers:finishing-a-development-branch)
```

### Step 4a: Option 1 — Priority decision

Compute `depends_on` frontier — tasks whose deps are verified.

AskUserQuestion:
```
Q: 다음 task 후보 (frontier): task-X / task-Y / task-Z. 어디 우선?
options: [task-X, task-Y, task-Z, parallel-all, custom]
```

Hand off: `/humanpowers operate {chosen-task}`.

### Step 4b: Option 2 — Version bump

AskUserQuestion:
```
Q: 버전 bump 종류?
options:
  - minor (X.Y → X.Y+1) — task 추가 / 비-구조 edit
  - major (X.Y → X+1.0) — 매트릭스 구조 pivot / task 제거
```

Edit developer.md frontmatter version. Commit + tag git.

### Step 4c: Option 3 — Cascade re-quiz

AskUserQuestion:
```
Q: 어느 task 의 expected-outputs 재검토?
free text: task-id
```

Reset that task's `status: problem-defined`. Hand off to humanpowers:quiz.

### Step 4d: Option 4 — Threads

List open threads. AskUserQuestion per thread:
```
Q: thread {topic} 상태?
options: [resolved (close), still open, escalate]
```

### Step 4e: Option 5 — Finalize

Hand off to humanpowers:finishing-a-development-branch.

### Step 5: Update state.json

Set `last_review` timestamp. Persist any chosen next phase.

## Boundaries

- Don't auto-bump version — developer must choose
- Don't auto-close threads — developer must mark
- Don't cascade re-quiz on multiple TFs at once — one at a time
