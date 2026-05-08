# Quiz Learnings

Default learnings for `humanpowers:quiz`. This file ships with the plugin and serves as the starting point. The retrospective skill evolves a user-local copy at `~/.humanpowers/learnings/quiz.md` over time.

---

### Assumption cells need hard evidence

**Guideline:** Never accept `guess (no source)` as evidence for an Assumption dimension cell — route back until the developer provides a verifiable anchor.

**Case:** A data pipeline task assumed the upstream table had a `created_at` column. The quiz accepted "I think it's there" as evidence. During operate, the column was missing — the entire plan had to be rewritten. A 30-second `SELECT column_name FROM information_schema.columns` query would have caught it.

**When to apply:** Any Assumption cell, especially for `action_type: data` and `action_type: infra` tasks.

---

### Activation log conflicts surface early, save late

**Guideline:** When code research during activation log prep surfaces a conflict between existing implementation and a design item, annotate inline with `CONFLICT:` — don't defer to Q body drafting.

**Case:** A task referenced a foreign key constraint across schemas. Code research showed the schema-swap migration would break the FK cascade. The conflict was noted in the activation log. The developer chose "Pause" and revised the task design before any Q bodies were drafted — saving an entire quiz-operate-verify cycle.

**When to apply:** Always run code research before filling the activation log. Any discrepancy between code reality and design items = conflict annotation.

---

### Round 2 catches hidden mental model drift

**Guideline:** Offer round 2 for tasks where the developer's domain knowledge significantly exceeds what the design artifacts capture — the independent parallel pass catches assumptions the developer didn't know they were making.

**Case:** A cross-cutting task touched authentication middleware. Round 1 passed cleanly, but round 2 revealed the developer assumed session tokens were stored in Redis (their previous project), while the current project used JWT. The discrepancy was invisible in round 1 because the quiz questions didn't probe token storage — the developer's answers were internally consistent but based on the wrong premise.

**When to apply:** Tasks where the developer has deep prior experience in the domain (risk of "obvious to me" assumptions). Less useful for greenfield tasks where the developer is exploring alongside the agent.
