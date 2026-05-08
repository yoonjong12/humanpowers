# Writing Plans Learnings

Default learnings for `humanpowers:writing-plans`. This file ships with the plugin and serves as the starting point. The retrospective skill evolves a user-local copy at `~/.humanpowers/learnings/writing-plans.md` over time.

---

### Task dependency order must respect data flow

**Guideline:** When ordering tasks, trace the data flow — a task that produces data another consumes must be built first, regardless of perceived complexity or size.

**Case:** Task-2 (API endpoint) was scheduled before Task-1 (database migration) because it seemed simpler. During operate, the API endpoint couldn't be tested because the table didn't exist. The plan was reordered, but the agent had already written tests against a mocked schema that diverged from the actual migration. Two tasks' worth of rework.

**When to apply:** When setting `DEPENDS_ON` fields in tasks.md. Trace: where does this task's input come from? If from another task's output, that task goes first.

---

### Action type determines verify strategy

**Guideline:** Set `ACTION_TYPE` accurately — it determines what demo form verification uses. A task that touches both API and UI should be classified by its primary verification surface, not its implementation surface.

**Case:** A task was classified as `api` because implementation was mostly backend. But the user-facing change was a UI toggle. Verification prepared curl-based demos. The developer wanted to see the toggle work in the browser. Reclassifying as `ui` aligned the verify demo with what the developer actually needed to judge.

**When to apply:** When writing tasks.md entries. Ask: "How will the developer verify this is correct?" The answer determines action_type.
