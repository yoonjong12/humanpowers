---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Core principle (humanpowers replacement of superpowers verification)

**superpowers**: "All tests pass + types check + linter clean = verified."
**humanpowers**: "Developer heard the debrief, asked their questions, made the calls = verified. Code passes are necessary but NOT sufficient."

VERIFY = developer made each decision in their own words, from their own intent.

## Personal learnings

Before starting, read `~/.humanpowers/learnings/verification-before-completion.md` if it exists. These are accumulated guidelines from past projects — treat as medium-trust additional context for the debrief.

## Signoff process (debrief pattern)

**Phase 1 — Automated baseline:**
Run ai-check. All must pass before debrief. If not, fix first.

**Phase 2 — Debrief:**

Agent opens with a single summary:
> "X tasks completed as designed: [list]. Y tasks have issues: [list]. Walk through?"

Per issue, agent explains in plain language:
- What the task was trying to do
- What actually happened / what deviated
- Agent's honest read: "simple fix" or "may need redesign"

Agent MUST NOT:
- Cite round1.md Q IDs or dimension labels to the developer
- Offer pre-baked options (REWORK / PASS / DEFER)
- Pre-judge the disposition ("I recommend...")
- Present analysis grids or deviation tables

Developer drives:
- Asks follow-up questions based on their original intent
- Agent provides evidence ONLY when asked (code snippet, test output, diff)
- Developer makes the call in their own words ("fix it", "leave it", "rethink")

**Phase 3 — Record:**

After each issue is resolved in conversation:
- Agent records what was decided and what action follows
- All issues resolved → mark task `status: verified` in `tasks.md`
- Any fix needed → return to operate; any intent unclear → return to quiz

## Demo form by action_type

Show actual running behavior — not analysis of it.

| action_type | What to show |
|-------------|--------------|
| ui | Live click-through. Developer watches screen. |
| api | Live cURL with response. Developer sees HTTP code + body. |
| data | SQL query with row count + sample row. Developer sees actual vs expected. |
| infra | Health curl + checklist run. Developer sees each result. |
| cross-cutting | All impacted tasks' demos run. Developer sees aggregate. |

Agent shows. Developer judges. Never reversed.

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
