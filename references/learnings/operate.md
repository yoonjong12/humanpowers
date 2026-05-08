# Operate Learnings

Default learnings for `humanpowers:operate`. This file ships with the plugin and serves as the starting point. The retrospective skill evolves a user-local copy at `~/.humanpowers/learnings/operate.md` over time.

---

### Plan deviation = halt, not improvise

**Guideline:** When the plan step doesn't match code reality (file moved, API changed, dependency upgraded), halt and surface the discrepancy rather than improvising a workaround.

**Case:** A plan step referenced `src/auth/middleware.ts:42` for modification. The file had been moved to `src/middleware/auth.ts` by a dependency task that ran earlier. The agent improvised the edit at the new path, but the improvised change missed a type guard that the plan step assumed existed at line 42. Verification caught a runtime crash. Halting and re-reading the plan with the new path would have taken 30 seconds; the improvised fix cost a full verify-rework cycle.

**When to apply:** Any plan step that references a specific file path or line number. If the reference is stale, the plan's assumptions about surrounding code are likely stale too.

---

### Commit granularity matches plan steps

**Guideline:** One commit per plan step (or per logical TDD cycle: test + implementation). Never batch multiple plan steps into one commit.

**Case:** Three plan steps were batched into one commit "for efficiency." Verification found a regression in step 2, but the fix required reverting all three steps because the changes were interleaved. Separate commits would have allowed a targeted revert of step 2 only.

**When to apply:** Always. The overhead of small commits is negligible; the cost of debugging a batched commit is not.

---

### Round1.md is the test spec, not the plan

**Guideline:** When plan.md and round1.md disagree on expected behavior, round1.md wins. The plan describes *how* to build; round1.md describes *what* to build.

**Case:** A plan step said "return 404 for missing resources." Round1.md (locked after quiz) specified "return 204 with empty body for missing resources — the frontend expects this." The agent followed the plan. Verification caught the mismatch. The plan was wrong; the quiz-locked behavior was the developer's explicit decision.

**When to apply:** Any ambiguity during operate where plan.md and round1.md could be read differently. Round1.md is the signed-off contract.
