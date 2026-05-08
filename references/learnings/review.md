# Review Learnings

Default learnings for `humanpowers:review`. This file ships with the plugin and serves as the starting point. The retrospective skill evolves a user-local copy at `~/.humanpowers/learnings/review.md` over time.

---

### Cross-task cascade flags are informational, not blocking

**Guideline:** When a locked quiz on task A constrains task B, flag it — but don't block task B's progress. The flag is for the developer to decide whether re-quiz is needed.

**Case:** Task-1's quiz locked a database schema decision. Task-3 referenced the same table. The review flagged the cascade. The developer reviewed and said "Task-3's usage is compatible, no re-quiz needed." If the flag had been a blocker, Task-3 would have waited unnecessarily for a re-quiz that wasn't needed.

**When to apply:** Any cross-task cascade detected during review. Flag informational; developer decides action.
