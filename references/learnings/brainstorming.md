# Brainstorming Learnings

Default learnings for `humanpowers:brainstorming`. This file ships with the plugin and serves as the starting point. The retrospective skill evolves a user-local copy at `~/.humanpowers/learnings/brainstorming.md` over time.

---

### Invariants must be testable

**Guideline:** Every invariant in problem.md must have a concrete verification method — a command, query, or observable behavior. If you can't describe how to check it, it's an aspiration, not an invariant.

**Case:** A problem.md included "invariant-3: system must be performant." During quiz, no cell could cite this invariant because there was no threshold, no measurement, no baseline. It was rewritten as "invariant-3: API p95 latency < 200ms under 100 concurrent users (measured via k6 load test)." The quiz then produced a concrete Constraint cell citing it.

**When to apply:** When writing or reviewing invariants in problem.md. Each invariant should answer: "How would I check this in CI or during verification?"

---

### Out-of-scope items prevent scope creep during quiz

**Guideline:** Explicitly listing what is NOT in scope in problem.md prevents the quiz from generating decision points for features the developer doesn't intend to build.

**Case:** A project to add CSV export had no out-of-scope items. During quiz, the agent generated cells for Excel export, PDF export, and scheduled exports — all reasonable extensions but not what the developer wanted. Adding "out-of-scope-1: non-CSV formats", "out-of-scope-2: scheduled/automated exports" eliminated 4 unnecessary quiz cells.

**When to apply:** Every brainstorming session. Especially important for features that have obvious "while you're at it" extensions.
