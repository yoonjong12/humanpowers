# Verification Before Completion Learnings

Default learnings for `humanpowers:verification-before-completion`. This file ships with the plugin and serves as the starting point. The retrospective skill evolves a user-local copy at `~/.humanpowers/learnings/verification-before-completion.md` over time.

---

### Debrief in plain language, not quiz IDs

**Guideline:** During the debrief, describe issues in terms of what the developer intended vs what happened — never cite Q IDs, dimension labels, or internal matrix terminology.

**Case:** An agent opened the debrief with "Q-Edge.task-2.constraint-3 has a deviation: the edge case handling doesn't match the locked matrix." The developer had no idea what that meant and asked for clarification, adding a full round-trip. Restating as "When the input list is empty, the function returns null instead of an empty array — which did you intend?" got an immediate answer.

**When to apply:** Every debrief. The developer made decisions in natural language during the quiz. Verification should surface issues in the same language.

---

### Show running behavior, not analysis

**Guideline:** For each action_type, show the actual system output — not your interpretation of it. Let the developer judge.

**Case:** An API task's debrief said "the response structure looks correct." The developer asked to see the actual curl output. The response had correct structure but wrong HTTP status (200 instead of 201 for resource creation). The agent's analysis missed the status code because it focused on body shape. Showing the raw output would have caught it instantly.

**When to apply:** Always. Demo form table in the skill defines what to show per action_type. Agent shows; developer judges. Never reversed.

---

### Fix-needed issues return to operate, not to a quick patch

**Guideline:** When verification finds an issue that needs code changes, return to `humanpowers:operate` for that task rather than applying a quick fix during verification.

**Case:** Verification found a missing input validation. The agent applied a "quick fix" inline during the debrief. The fix introduced a new edge case (rejecting valid Unicode input) that wasn't caught because verification doesn't run TDD. Returning to operate would have required a failing test first, catching the Unicode issue.

**When to apply:** Any issue that requires more than a typo fix. If the fix needs a test, it needs operate.
