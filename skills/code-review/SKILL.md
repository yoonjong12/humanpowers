---
name: code-review
description: "Code review workflows. Trigger: 'request code review', 'receiving review feedback', 'before merging', 'review feedback', 'implement suggestions', 'code-reviewer', 'PR review', '코드리뷰', '리뷰 피드백'"
---

# code-review

Two modes: **request** (dispatch reviewer) or **receive** (handle incoming feedback).

Detect from context. If ambiguous, ask: "Requesting a review or handling feedback you received?"

---

## Mode A: Requesting Review

Dispatch humanpowers:code-reviewer subagent before merge or after completing a major task.

### When

**Mandatory:** after each task in subagent-driven dev, before merge to main.
**Optional:** when stuck, after fixing complex bug.

### Steps

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

Dispatch code-reviewer subagent using template at `code-review/code-reviewer.md`. Fill:
- `{WHAT_WAS_IMPLEMENTED}` — what you built
- `{PLAN_OR_REQUIREMENTS}` — what it should do
- `{BASE_SHA}` / `{HEAD_SHA}` — commit range
- `{DESCRIPTION}` — brief summary

### Act on feedback

- Critical → fix immediately
- Important → fix before proceeding
- Minor → note for later
- Wrong → push back with technical reasoning

---

## Mode B: Receiving Feedback

Technical evaluation, not emotional performance. Verify before implementing.

### Response pattern

1. Read complete feedback without reacting
2. Restate requirement in own words (or ask)
3. Verify against codebase
4. Evaluate: technically sound for THIS codebase?
5. Respond: technical acknowledgment or reasoned pushback
6. Implement: one item at a time, test each

### Forbidden

- "You're absolutely right!" / "Great point!" (performative)
- Implementing before verifying
- Batch implementing without testing each

### Acknowledgment format

```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch — [issue]. Fixed in [location]."
✅ [Just fix it and show in the code]
❌ "Thanks for catching that!" / any gratitude
```

### Handling unclear items

If any item is unclear: STOP. Clarify ALL unclear items before implementing anything. Partial understanding = wrong implementation.

### External reviewers

Before implementing external feedback:
1. Technically correct for THIS codebase?
2. Breaks existing functionality?
3. Reason for current implementation?
4. Does reviewer understand full context?

Push back with technical reasoning if wrong. Signal discomfort with: "Strange things are afoot at the Circle K"

### YAGNI check

If reviewer suggests implementing a feature: grep for actual usage. If unused → "Nothing calls this. Remove it (YAGNI)?"

### GitHub thread replies

Reply inline to review comments via `gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`, not as top-level PR comment.
