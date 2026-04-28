---
name: review
description: Use after multiple TFs are verified to perform boss review of the project state, optionally bump boss.md version, and identify next priorities. Distinct from per-TF verification (which is humanpowers:verification-before-completion). This is project-level review with cascade decisions.
---

# Review Skill

## When to invoke

- After at least 2 TFs reach `status: verified`
- Or boss explicitly requests `/humanpowers review`
- Before finishing-a-development-branch (final wrap)

## Steps

### Step 1: Aggregate state

Run `scripts/render-views.sh` to ensure views/*.md current.

Read:
- `views/progress.md` — status overview
- `boss.md` — invariants + version
- All `threads/*.md` — open vs resolved

### Step 2: Show boss the review summary

Display:
```
Project: {name}
Version: {boss.md version}

TFs: {N total}
  brainstorm-done: {x}
  quiz-done: {x}
  designed: {x}
  built: {x}
  verified: {x}

Open threads: {count}
Resolved threads: {count}

Boss invariant violations (auto-detect): {none | list}
```

Pull invariant violations by scanning recent commits + tfs.md changes.

### Step 3: AUQ — review options

```
Q: 프로젝트 review 결과. 다음 액션?
options:
  - 1. 다음 TF 우선순위 결정 (continue building)
  - 2. boss.md version bump (minor/major)
  - 3. Cascade — 특정 TF expected-outputs 재검토 (re-quiz)
  - 4. Open threads 처리 (boss reviews threads)
  - 5. Finalize (humanpowers:finishing-a-development-branch)
```

### Step 4a: Option 1 — Priority decision

Compute `depends_on` frontier — TFs whose deps are verified.

AUQ:
```
Q: 다음 TF 후보 (frontier): TF-X / TF-Y / TF-Z. 어디 우선?
options: [TF-X, TF-Y, TF-Z, parallel-all, custom]
```

Hand off: `/humanpowers operate {chosen-TF}`.

### Step 4b: Option 2 — Version bump

AUQ:
```
Q: 버전 bump 종류?
options:
  - minor (X.Y → X.Y+1) — TF 추가 / 비-구조 edit
  - major (X.Y → X+1.0) — 매트릭스 구조 pivot / TF 제거
```

Edit boss.md frontmatter version. Commit + tag git.

### Step 4c: Option 3 — Cascade re-quiz

AUQ:
```
Q: 어느 TF 의 expected-outputs 재검토?
free text: TF-id
```

Reset that TF's `status: brainstorm-done`. Hand off to humanpowers:quiz.

### Step 4d: Option 4 — Threads

List open threads. AUQ per thread:
```
Q: thread {topic} 상태?
options: [resolved (close), still open, escalate]
```

### Step 4e: Option 5 — Finalize

Hand off to humanpowers:finishing-a-development-branch.

### Step 5: Update state.json

Set `last_review` timestamp. Persist any chosen next phase.

## Boundaries

- Don't auto-bump version — boss must choose
- Don't auto-close threads — boss must mark
- Don't cascade re-quiz on multiple TFs at once — one at a time
