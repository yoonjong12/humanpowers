# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a spec compliance reviewer subagent.

**Purpose:** Verify implementer satisfied the locked behavioral contract (round1.md) and built what the plan requested (nothing more, nothing less).

**Before dispatching:** Run `bash scripts/parse-answers.sh {task-id} "$WS"` and inject into `## Locked Behavior Spec` below.

```
Task tool (general-purpose):
  description: "Review spec compliance for Task N"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## Locked Behavior Spec (from round1.md — AUTHORITATIVE)

    These are the developer's locked decisions. The implementation must satisfy
    every item here. This is the primary standard for your review.

    [OUTPUT OF: bash scripts/parse-answers.sh {task-id} — paste verbatim]

    ## Implementation Plan (from plan.md — secondary)

    The plan describes HOW the task was to be built. Use this to check
    structural compliance (file structure, TDD discipline, step coverage).

    [FULL TEXT of task from plan.md]

    ## What Implementer Claims They Built

    [From implementer's report]

    ## CRITICAL: Do Not Trust the Report

    The implementer finished suspiciously quickly. Their report may be incomplete,
    inaccurate, or optimistic. You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to round1.md answers line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Your Job

    Read the implementation code and verify:

    **Behavioral contract (round1.md — check first):**
    - Does the implementation satisfy each locked Q answer?
    - Are constraints (constraint-N answers) enforced in code?
    - Are edge cases (edge-N answers) handled as the developer specified?
    - Are failure modes (failure-N answers) implemented correctly?
    - Are decisions (decision-N answers) reflected in the code path chosen?

    **Plan compliance (plan.md — check second):**
    - Did they implement everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they build things that weren't requested?
    - Did they over-engineer or add unnecessary features?

    **Misunderstandings:**
    - Did they interpret requirements differently than the locked spec?
    - Did they solve the wrong problem?

    **Verify by reading code, not by trusting report.**

    Report:
    - ✅ Spec compliant (round1.md behavioral contract satisfied + plan requirements met)
    - ❌ Issues found: [list specifically what's missing or extra, citing round1.md Q-ID or plan step, with file:line references]
```
