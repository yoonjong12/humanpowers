# humanpowers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement v0.3 design — vocabulary sweep, ADR digest commit policy, hook/shelf/view removal, executing-plans merge into operate, all anchored on the spec at `docs/specs/humanpowers-design.md`.

**Architecture:** Markdown-only Claude Code plugin. No compiled code. "Tests" = grep-based content assertions for skill files plus a manual E2E pass at the end.

**Tech Stack:** Bash + jq + markdown. SKILL.md frontmatter (`name`, `description`). state.json schema enforced by `scripts/check-state.sh`.

---

## File Structure

### Modified

- `references/templates/state.json` — field rename `tfs_*` → `tasks_*`
- `references/templates/problem.md` — add `## Project invariants` section
- `scripts/check-state.sh` — validate v0.3 fields
- `skills/humanpowers/SKILL.md` — dispatcher vocab sweep, drop views/shelves directory creation
- `skills/brainstorming/SKILL.md` — vocab sweep, Project invariants in problem.md output
- `skills/quiz/SKILL.md` — vocab + D1/D2 → round1/round2
- `skills/writing-plans/SKILL.md` — vocab
- `skills/operate/SKILL.md` — vocab + absorb executing-plans batch mode (`--batch`)
- `skills/verification-before-completion/SKILL.md` — vocab
- `skills/review/SKILL.md` — vocab
- `skills/finishing-a-development-branch/SKILL.md` — vocab + ADR digest writing
- `skills/using-humanpowers/SKILL.md` — vocab + privacy-model explanation
- `skills/systematic-debugging/SKILL.md` — vocab (Layer 1-4 defense terminology preserved)
- `skills/test-driven-development/SKILL.md` — vocab
- `skills/requesting-code-review/SKILL.md` — vocab
- `skills/receiving-code-review/SKILL.md` — vocab
- `skills/using-git-worktrees/SKILL.md` — vocab
- `skills/writing-skills/SKILL.md` — vocab
- `skills/dispatching-parallel-agents/SKILL.md` — vocab
- `skills/subagent-driven-development/SKILL.md` — vocab
- All `references/templates/*.md` — vocab
- All `references/examples/*.md` — vocab
- `README.md` — privacy model + vocab + skill count (17)
- `.claude-plugin/plugin.json` — description for v0.3
- `.claude-plugin/marketplace.json` — description for v0.3
- `.gitignore` — replace partial rules with `.humanpowers/`
- `docs/E2E-self-test.md` — update to reflect ADR digest verification

### Renamed

- `references/examples/d2-discussion-example.md` → `references/examples/round2-discussion-example.md`
- `references/templates/response-d1-template.md` → `references/templates/response-round1-template.md`
- `references/templates/response-d2-template.md` → `references/templates/response-round2-template.md`

### Deleted

- `skills/executing-plans/` — merged into `operate` with `--batch`
- `hooks/hooks.json` — hook surface emptied
- `scripts/shelf-truncate.sh` — shelves removed
- `scripts/render-views.sh` (if present) — views removed

---

## Verification model

Skill files have no unit tests. Per-task verification is one of:

1. **grep assertion** — `grep -c "<pattern>" <file>` returns expected count.
2. **jq assertion** — `jq '<query>' <file>` returns expected value.
3. **filesystem assertion** — file exists / does not exist.
4. **manual E2E** — Task 20.

---

## Task 1: Update state.json schema and check-state.sh

**Files:**
- Modify: `references/templates/state.json`
- Modify: `scripts/check-state.sh`

- [ ] **Step 1: Rewrite state.json template**

Replace contents of `references/templates/state.json`:

```json
{
  "phase": "",
  "target_repo": null,
  "workspace_kind": "",
  "tasks_total": 0,
  "tasks_quiz_done": 0,
  "tasks_built": 0,
  "tasks_verified": 0
}
```

- [ ] **Step 2: Verify template parses**

Run: `jq -e . references/templates/state.json`
Expected: full JSON echoed, exit 0.

- [ ] **Step 3: Rewrite scripts/check-state.sh**

Replace contents of `scripts/check-state.sh`:

```bash
#!/usr/bin/env bash
# Usage: scripts/check-state.sh [workspace-path]
# Echoes current phase + target_repo + counts. Exit 0 if valid, 1 if missing/invalid.

set -euo pipefail

WS="${1:-$(pwd)}"
STATE="$WS/.humanpowers/state.json"

if [ ! -f "$STATE" ]; then
  echo "ERROR: No state.json at $STATE" >&2
  exit 1
fi

# Required fields per humanpowers-design.md
for field in phase target_repo workspace_kind tasks_total tasks_quiz_done tasks_built tasks_verified; do
  if ! jq -e "has(\"$field\")" "$STATE" >/dev/null 2>&1; then
    echo "ERROR: state.json missing required field '$field'. Workspace from a prior plugin version detected. Delete .humanpowers/ and re-init with /humanpowers." >&2
    exit 1
  fi
done

PHASE=$(jq -r .phase "$STATE")
TARGET=$(jq -r .target_repo "$STATE")
KIND=$(jq -r .workspace_kind "$STATE")
TASKS_TOTAL=$(jq -r .tasks_total "$STATE")
TASKS_QUIZ=$(jq -r .tasks_quiz_done "$STATE")
TASKS_BUILT=$(jq -r .tasks_built "$STATE")
TASKS_VER=$(jq -r .tasks_verified "$STATE")

cat <<EOF
phase: $PHASE
target_repo: $TARGET
workspace_kind: $KIND
tasks:
  total: $TASKS_TOTAL
  quiz-done: $TASKS_QUIZ
  built: $TASKS_BUILT
  verified: $TASKS_VER
EOF
```

- [ ] **Step 4: Verify script behavior**

Run smoke tests:

```bash
mkdir -p /tmp/hp-test/.humanpowers
cp references/templates/state.json /tmp/hp-test/.humanpowers/state.json
bash scripts/check-state.sh /tmp/hp-test
```
Expected: exit 0, output begins with `phase:` line, lists all 7 fields and 4 task counters.

```bash
echo '{"phase":"x","tfs_total":0}' > /tmp/hp-test/.humanpowers/state.json
bash scripts/check-state.sh /tmp/hp-test 2>&1
```
Expected: exit 1, error message contains "missing required field" and "prior plugin version".

```bash
rm -rf /tmp/hp-test
```

- [ ] **Step 5: Commit**

```bash
git add references/templates/state.json scripts/check-state.sh
git commit -m "state: rename tfs_* to tasks_* and update v0.3 error message"
```

---

## Task 2: Simplify .gitignore for privacy model

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Read current gitignore**

The current `.gitignore` contains partial commit rules from v0.2 (state.json + shelves explicit, problem.md / tasks.md committed implicitly). v0.3 makes `.humanpowers/` entirely local.

- [ ] **Step 2: Replace partial rules with directory rule**

Edit `.gitignore`:

- Remove the lines `.humanpowers/state.json` and `.humanpowers/shelves/` and `.humanpowers/invocation-log.jsonl`.
- Add a single line: `.humanpowers/`.

Final relevant section:

```
.DS_Store
.humanpowers/
node_modules/
*.swp
*.swo
```

- [ ] **Step 3: Verify**

Run:

```bash
grep -c "^\.humanpowers/$" .gitignore         # 1
grep -c "^\.humanpowers/state\.json$" .gitignore     # 0
grep -c "^\.humanpowers/shelves/$" .gitignore        # 0
grep -c "invocation-log" .gitignore                  # 0
```

- [ ] **Step 4: Commit**

```bash
git add .gitignore
git commit -m "gitignore: ignore entire .humanpowers/ for v0.3 privacy model"
```

---

## Task 3: Delete hook infrastructure

**Files:**
- Delete: `hooks/hooks.json`
- Delete: `scripts/shelf-truncate.sh`

- [ ] **Step 1: Verify no other files reference these**

```bash
grep -rln "hooks/hooks\.json\|shelf-truncate" --include="*.md" --include="*.json" --include="*.sh" --exclude-dir=.git . | grep -v "docs/specs/\|docs/plans/legacy"
```

Expected: only `docs/plans/humanpowers-plan.md` (this plan, naming the deletions).

If real references appear elsewhere, fix them before proceeding.

- [ ] **Step 2: Delete files**

```bash
git rm hooks/hooks.json scripts/shelf-truncate.sh
rmdir hooks 2>/dev/null || true
```

- [ ] **Step 3: Verify**

```bash
test ! -f hooks/hooks.json && echo OK
test ! -f scripts/shelf-truncate.sh && echo OK
test ! -d hooks && echo "hooks dir gone"
```

- [ ] **Step 4: Commit**

```bash
git commit -m "hooks: drop hook surface for v0.3 (shelves removed)"
```

---

## Task 4: Delete views infrastructure

**Files:**
- Delete: `scripts/render-views.sh` (if exists)

- [ ] **Step 1: Check whether render-views.sh exists**

```bash
test -f scripts/render-views.sh && echo "exists" || echo "absent"
```

If absent, skip this task.

- [ ] **Step 2: Verify no other files reference render-views**

```bash
grep -rln "render-views\|views/" --include="*.md" --include="*.sh" --exclude-dir=.git . | grep -v "docs/specs/\|docs/plans/"
```

Expected output may include skills that mention `views/` directory creation. Note the references for cleanup in later tasks (dispatcher, brainstorming, operate, etc.).

- [ ] **Step 3: Delete render-views.sh**

```bash
git rm scripts/render-views.sh
```

- [ ] **Step 4: Verify and commit**

```bash
test ! -f scripts/render-views.sh && echo OK
git commit -m "views: drop render-views.sh for v0.3 (views removed)"
```

---

## Task 5: Update problem.md template — add Project invariants section

**Files:**
- Modify: `references/templates/problem.md`

- [ ] **Step 1: Read current template**

Confirm the existing template has six H2 sections: What, Why, Success criteria, Out of scope, Open questions, TF outline (preliminary).

- [ ] **Step 2: Replace contents**

Replace `references/templates/problem.md` with:

```markdown
# Problem Definition

> Output of `humanpowers:brainstorming`. Drives task decomposition and per-task quizzes downstream. Treat as living: refine as design clarifies.

## What

One paragraph: what is the developer trying to solve? State the user-facing outcome, not the technical mechanism.

## Why

One paragraph: why does this matter? Constraint, deadline, business motivation, or technical debt being addressed.

## Success criteria

Bulleted list of observable conditions that, when met, mean the work is done. Each criterion must be checkable without reading code (e.g., "command X returns Y", "file Z contains Q", "user can do W").

## Project invariants

Bulleted list of properties that must hold across the entire feature regardless of which task is being worked on. Examples: security (no PII in logs), data integrity (cap of 5 items maintained), determinism (LLM merge results stable across runs), compliance (alignment with a referenced design doc). Each invariant applies project-wide, not to a specific task.

## Out of scope

Bulleted list of things this work explicitly does NOT do.

## Open questions

Bulleted list of unresolved decisions. Each question must be answerable; vague philosophy questions belong elsewhere.

## Task outline (preliminary)

Numbered list. Each task has: short name, files it touches (new or existing), why it exists. This is preliminary — `humanpowers:writing-plans` finalizes the task list with action_type and depends_on graph.

1. **Task 1: <name>** — files: `<paths>`. <rationale>
2. **Task 2: <name>** — files: `<paths>`. <rationale>
```

- [ ] **Step 3: Verify**

```bash
grep -c "^## " references/templates/problem.md       # 7
grep -c "Project invariants" references/templates/problem.md   # 1
grep -c "Task outline" references/templates/problem.md         # 1
grep -c "TF outline" references/templates/problem.md           # 0
```

- [ ] **Step 4: Commit**

```bash
git add references/templates/problem.md
git commit -m "templates: problem.md adds Project invariants section, renames TF→task"
```

---

## Task 6: Rewrite dispatcher SKILL.md

**Files:**
- Modify: `skills/humanpowers/SKILL.md`

- [ ] **Step 1: Replace contents**

Write the following exact contents to `skills/humanpowers/SKILL.md`:

````markdown
---
name: humanpowers
description: Single entry point for humanpowers. Detects cwd context (in-repo or external), creates .humanpowers/ workspace skeleton when absent, then routes by phase. Developer types `/humanpowers` (optionally with a subcommand) and the dispatcher determines the next skill. Use whenever the developer wants to start or resume design-first work.
---

# humanpowers Dispatcher

## Behavior

Single entry to humanpowers. Two responsibilities:

1. **Workspace structure** — locate or create `.humanpowers/` and seed `state.json`.
2. **Phase routing** — read `state.json` and hand off to the next skill.

The dispatcher does not author content. brainstorming owns problem definition; quiz / writing-plans / operate / verification / review own per-task work.

## Step 1: Locate workspace

```bash
WS=""
DIR="$(pwd)"
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/.humanpowers/state.json" ]; then
    WS="$DIR"
    break
  fi
  DIR="$(dirname "$DIR")"
done
```

If `WS` is non-empty → existing workspace, jump to Step 3.

If `WS` is empty → no workspace, go to Step 2.

## Step 2: Create workspace skeleton

```bash
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  WS_DIR="$REPO_ROOT/.humanpowers"
  KIND="in-repo"
  TARGET="$REPO_ROOT"
else
  WS_DIR="$(pwd)/.humanpowers"
  KIND="external"
  TARGET="null"
fi

mkdir -p "$WS_DIR/tasks"

if [ "$TARGET" = "null" ]; then
  TARGET_JSON="null"
else
  TARGET_JSON="\"$TARGET\""
fi

cat > "$WS_DIR/state.json" <<EOF
{
  "phase": "",
  "target_repo": $TARGET_JSON,
  "workspace_kind": "$KIND",
  "tasks_total": 0,
  "tasks_quiz_done": 0,
  "tasks_built": 0,
  "tasks_verified": 0
}
EOF
```

Output to user:

```
Workspace created: <WS_DIR>
workspace_kind: <KIND>
target_repo: <TARGET>

Note: this workspace is local-only. The repo's .gitignore excludes .humanpowers/ entirely.
The decision artifact is created at the finish phase as docs/decisions/<slug>.md and committed.

Invoking humanpowers:brainstorming to define the problem.
```

Hand off to `humanpowers:brainstorming`.

## Step 3: Existing workspace — validate + route

Validate schema with `scripts/check-state.sh "$WS"`. If exit code 1, propagate the error message verbatim and stop.

Read phase:

```bash
PHASE=$(jq -r .phase "$WS/.humanpowers/state.json")
```

Route:

| phase | Next skill |
|-------|-----------|
| `""` (empty) | humanpowers:brainstorming |
| `problem-defined` | humanpowers:quiz |
| `quiz-done` | humanpowers:writing-plans |
| `planned` | humanpowers:operate (per remaining task; supports `--batch`) |
| `built` | humanpowers:verification-before-completion |
| `verified` (some tasks) | humanpowers:review or humanpowers:operate (next task) |
| `verified` (all tasks) | humanpowers:finishing-a-development-branch |

Echo current state before routing:

```
Workspace: <WS>
Phase: <PHASE>
Tasks: <verified>/<total> verified, <built>/<total> built, <quiz_done>/<total> quiz-done
```

If a subcommand was passed, apply the override after the echo.

## Step 4: Subcommands

| Command | Action |
|---------|--------|
| `/humanpowers continue` | resume current phase (default behavior) |
| `/humanpowers jump <phase>` | force jump to phase; warn if skipping a gate |
| `/humanpowers operate <task-id>` | invoke humanpowers:operate with a specific task |
| `/humanpowers operate --batch` | invoke humanpowers:operate over all remaining unbuilt tasks |
| `/humanpowers review` | invoke humanpowers:review for cross-task cascade |
| `/humanpowers abort` | mark workspace aborted in state.json + stop |

`abort` sets `phase = "aborted"` via `scripts/update-state.sh "$WS" phase aborted`.

## Notes for skill authors

Skills downstream of the dispatcher must:

- Read workspace location via upward search from cwd (same logic as Step 1). Do not hard-code a fixed home-relative path.
- Read `target_repo` from `state.json` when they need the code repo (operate, verification, finishing).
- Update phase via `scripts/update-state.sh` rather than manual jq edits.
````

- [ ] **Step 2: Verify**

```bash
grep -c "^name: humanpowers$" skills/humanpowers/SKILL.md      # 1
grep -c "scaffold" skills/humanpowers/SKILL.md                  # 0
grep -c "TF\b\|TF-" skills/humanpowers/SKILL.md                # 0
grep -c "tasks_" skills/humanpowers/SKILL.md                    # >=4
grep -c "boss" skills/humanpowers/SKILL.md                      # 0
grep -c "shelves\|views/" skills/humanpowers/SKILL.md           # 0
grep -c "subcommand" skills/humanpowers/SKILL.md                # >=2 (lowercase per v0.3 vocab)
grep -c "docs/decisions" skills/humanpowers/SKILL.md            # >=1
```

- [ ] **Step 3: Commit**

```bash
git add skills/humanpowers/SKILL.md
git commit -m "dispatcher: v0.3 vocab sweep, drop views/shelves directory creation, ADR digest note"
```

---

## Task 7: Update brainstorming SKILL.md

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

- [ ] **Step 1: Find stale tokens**

```bash
grep -nE "TF\b|TF-|AUQ|D1|D2|SDD|Layer 0|Layer 1|tfs\.md|response-d[12]|boss\b|Boss\b|shelves|views/" skills/brainstorming/SKILL.md
```

Expected: a number of hits referencing v0.2 vocabulary and the dropped views/shelves.

- [ ] **Step 2: Apply replacements**

Word replacements (preserve case where applicable):

- `TF` → `task` / `Task` / `TASK` (per case)
- `TF-{N}` → `Task {N}` (in narrative) or `{N}` (in path/identifier)
- `AUQ` → `AskUserQuestion`
- `D1` → `round 1`
- `D2` → `round 2`
- `SDD` → `subagent-driven development`
- `Layer 0` → `project invariants`
- `Layer 1` → `task-local NFR`
- `tfs.md` → `tasks.md`
- `response-d1-` → `response-round1-`
- `response-d2-` → `response-round2-`
- `boss` → `developer` / `Boss` → `Developer`

Structural changes:

- The brainstorming output is `<workspace>/.humanpowers/problem.md`. The template file is `references/templates/problem.md`. Both are unchanged in location.
- The instruction to write `views/` outputs (any reference like "render views") must be removed. The `views/` directory no longer exists.
- The instruction to update shelves must be removed. Shelves no longer exist.
- The terminal handoff at the end: `humanpowers:quiz` (unchanged).

- [ ] **Step 3: Verify**

```bash
grep -c "TF\b\|TF-" skills/brainstorming/SKILL.md           # 0
grep -c "AUQ" skills/brainstorming/SKILL.md                  # 0
grep -c "D1\|D2" skills/brainstorming/SKILL.md               # 0
grep -c "Layer 0\|Layer 1" skills/brainstorming/SKILL.md     # 0
grep -c "tfs\.md" skills/brainstorming/SKILL.md              # 0
grep -c "boss\|Boss" skills/brainstorming/SKILL.md           # 0
grep -c "views/\|shelves" skills/brainstorming/SKILL.md      # 0
grep -c "problem.md" skills/brainstorming/SKILL.md           # >=2
grep -c "humanpowers:quiz" skills/brainstorming/SKILL.md     # >=1
grep -c "Project invariants" skills/brainstorming/SKILL.md   # >=1
grep -c "task-local NFR" skills/brainstorming/SKILL.md       # >=1
```

All assertions must hold.

- [ ] **Step 4: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "brainstorming: v0.3 vocab + Project invariants in problem.md, drop views/shelves refs"
```

---

## Task 8: Update quiz SKILL.md

**Files:**
- Modify: `skills/quiz/SKILL.md`

- [ ] **Step 1: Find stale tokens**

```bash
grep -nE "TF\b|TF-|AUQ|D1|D2|SDD|Layer 0|Layer 1|tfs\.md|response-d[12]|boss\b|Boss\b|brainstorm-done" skills/quiz/SKILL.md
```

- [ ] **Step 2: Apply replacements**

Same word table as Task 7. Quiz-specific:

- "D1 mandatory" → "round 1 (mandatory, agent-led)"
- "D2 optional" → "round 2 (optional, developer-led)"
- File path `tasks/TF-{id}/response-d1-developer.md` → `tasks/{id}/round1.md`
- File path `tasks/TF-{id}/response-d2-{role}.md` → `tasks/{id}/round2.md`
- `expected-outputs.md` (per-task quiz output) — same file. The new convention is `round1.md` for the agent-led pass output and `round2.md` for the developer-led pass.

The quiz skill's behavior is unchanged: D1 mandatory + D2 optional + 4 critique axes. Only naming and path conventions change.

- [ ] **Step 3: Verify**

```bash
grep -c "TF\b\|TF-" skills/quiz/SKILL.md                     # 0
grep -c "AUQ" skills/quiz/SKILL.md                            # 0
grep -c "\bD1\b\|\bD2\b" skills/quiz/SKILL.md                # 0
grep -c "Layer 0\|Layer 1" skills/quiz/SKILL.md               # 0
grep -c "boss\|Boss" skills/quiz/SKILL.md                     # 0
grep -c "round 1\|round 2" skills/quiz/SKILL.md               # >=2
grep -c "task-local NFR\|project invariants" skills/quiz/SKILL.md  # >=1
grep -c "round1\.md\|round2\.md" skills/quiz/SKILL.md         # >=2
grep -c "tasks/{id}/" skills/quiz/SKILL.md                    # >=1
```

- [ ] **Step 4: Commit**

```bash
git add skills/quiz/SKILL.md
git commit -m "quiz: v0.3 vocab + round1/round2 path convention"
```

---

## Task 9: Update writing-plans SKILL.md

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Find stale tokens**

```bash
grep -nE "TF\b|TF-|tfs\.md|tasks/TF-|boss\b|Boss\b|Layer 0|Layer 1" skills/writing-plans/SKILL.md
```

- [ ] **Step 2: Apply replacements**

Same word table as Task 7. writing-plans-specific:

- "TF decomposition" → "task decomposition"
- "TF-1, TF-2..." → "Task 1, Task 2..." or numbered list
- Path `tasks/TF-{id}/plan.md` → `tasks/{id}/plan.md`
- "executing-plans" mentions stay (skill rename happens to operate; references in writing-plans pointing at executing-plans should redirect to `operate --batch`)

Concrete: replace any line that recommends "use executing-plans for batch execution" with "use operate --batch for batch execution over all remaining tasks".

- [ ] **Step 3: Verify**

```bash
grep -c "TF\b\|TF-" skills/writing-plans/SKILL.md             # 0
grep -c "boss\|Boss" skills/writing-plans/SKILL.md             # 0
grep -c "tfs\.md" skills/writing-plans/SKILL.md                # 0
grep -c "humanpowers:executing-plans" skills/writing-plans/SKILL.md   # 0
grep -c "operate --batch\|operate batch" skills/writing-plans/SKILL.md  # >=1
grep -c "task decomposition" skills/writing-plans/SKILL.md     # >=1
```

- [ ] **Step 4: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "writing-plans: v0.3 vocab, redirect executing-plans → operate --batch"
```

---

## Task 10: Update operate SKILL.md — vocab + absorb executing-plans

**Files:**
- Modify: `skills/operate/SKILL.md`

- [ ] **Step 1: Read current operate SKILL.md to identify the existing per-task flow**

`grep -n "scope\|per-task\|batch\|task" skills/operate/SKILL.md | head -20`

- [ ] **Step 2: Apply vocab replacements**

Word table from Task 7. operate-specific:

- "TF" → "task"
- "tasks/TF-{id}/" → "tasks/{id}/"
- "Layer 0" → "project invariants"
- "Layer 1" → "task-local NFR"
- `developer.md` (file) → no equivalent in v0.3; project invariants live in `problem.md`. Replace any reference to "developer.md (Layer 0 invariants)" with "problem.md (project invariants section)".
- `boss` → `developer`

- [ ] **Step 3: Add `--batch` mode section**

Append a new H2 section near the end of the skill, before any "Notes" or "References" section:

```markdown
## Batch mode

By default, `humanpowers:operate` works on a single task. Pass `--batch` (or invoke via `/humanpowers operate --batch`) to iterate over all remaining tasks whose plan exists and whose code is not yet built.

Behavior in batch mode:

- Read `tasks.md` to enumerate tasks with `phase: planned` or `phase: built` (per task entry).
- For each task with `planned` (no code yet):
  - Read `tasks/{id}/plan.md`.
  - Implement the task per the plan, applying TDD discipline.
  - On completion, update `tasks/{id}/` with any test artifacts and mark progress.
  - Move to the next task only after the current one's tests pass.
- After all eligible tasks are built, run `scripts/update-state.sh "$WS" tasks_built <count>` and transition the workspace phase to `built`.

Batch mode does not skip the per-task verification gate; verification still runs separately via `humanpowers:verification-before-completion`. Batch mode only fast-paths the build phase.

Use single-task mode (`/humanpowers operate <id>`) when:

- The next task is uncertain and you want to inspect the plan first.
- A specific task needs targeted attention (failing test, scope question).
- You want to interleave operate with verify in a tight feedback loop.

Use batch mode when:

- All tasks are well-specified after writing-plans.
- You prefer continuous build over per-task review.
- The set of remaining tasks is small enough to fit in one session's context.
```

- [ ] **Step 4: Verify**

```bash
grep -c "TF\b\|TF-" skills/operate/SKILL.md                   # 0
grep -c "Layer 0\|Layer 1" skills/operate/SKILL.md             # 0
grep -c "boss\|Boss" skills/operate/SKILL.md                   # 0
grep -c "developer\.md" skills/operate/SKILL.md                # 0
grep -c "Batch mode\|--batch" skills/operate/SKILL.md          # >=2
grep -c "project invariants\|task-local NFR" skills/operate/SKILL.md  # >=1
grep -c "tasks/{id}/" skills/operate/SKILL.md                  # >=1
```

- [ ] **Step 5: Commit**

```bash
git add skills/operate/SKILL.md
git commit -m "operate: v0.3 vocab + absorb executing-plans batch mode"
```

---

## Task 11: Delete executing-plans skill

**Files:**
- Delete: `skills/executing-plans/`

- [ ] **Step 1: Verify no remaining references**

```bash
grep -rln "humanpowers:executing-plans\|skills/executing-plans" --include="*.md" --include="*.json" --include="*.sh" --exclude-dir=.git . | grep -v "docs/specs/\|docs/plans/legacy"
```

Expected: only `docs/plans/humanpowers-plan.md` (this plan, listing the deletion).

- [ ] **Step 2: Delete directory**

```bash
git rm -r skills/executing-plans/
```

- [ ] **Step 3: Verify**

```bash
test ! -d skills/executing-plans && echo OK
ls skills/ | wc -l   # 17
```

- [ ] **Step 4: Commit**

```bash
git commit -m "executing-plans: delete (merged into operate --batch)"
```

---

## Task 12: Update verification-before-completion SKILL.md

**Files:**
- Modify: `skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: Apply vocab replacements**

Word table from Task 7. Specific:

- "TF" → "task"
- "boss" → "developer"
- Path `tasks/TF-{id}/verify.md` → `tasks/{id}/verify.md`

- [ ] **Step 2: Verify**

```bash
grep -c "TF\b\|TF-" skills/verification-before-completion/SKILL.md   # 0
grep -c "boss\|Boss" skills/verification-before-completion/SKILL.md   # 0
grep -c "tasks/{id}/" skills/verification-before-completion/SKILL.md  # >=1
```

- [ ] **Step 3: Commit**

```bash
git add skills/verification-before-completion/SKILL.md
git commit -m "verification-before-completion: v0.3 vocab"
```

---

## Task 13: Update review SKILL.md

**Files:**
- Modify: `skills/review/SKILL.md`

- [ ] **Step 1: Apply vocab replacements**

Word table from Task 7. Specific:

- "TF" → "task"
- "Boss invariant violations" → "project invariant violations"
- "boss" → "developer"

- [ ] **Step 2: Verify**

```bash
grep -c "TF\b\|TF-" skills/review/SKILL.md                    # 0
grep -c "boss\|Boss" skills/review/SKILL.md                    # 0
grep -c "Boss invariant\|Layer 0" skills/review/SKILL.md       # 0
grep -c "project invariant" skills/review/SKILL.md             # >=1
```

- [ ] **Step 3: Commit**

```bash
git add skills/review/SKILL.md
git commit -m "review: v0.3 vocab including Boss invariant → project invariant"
```

---

## Task 14: Rewrite finishing-a-development-branch SKILL.md — ADR digest

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Apply vocab replacements first**

Word table from Task 7.

- [ ] **Step 2: Add new ADR digest section**

Add a new H2 section near the top of the skill (after the description and intro):

````markdown
## ADR digest at finish

humanpowers workspaces are local-only. The decision artifact is the only thing the plugin commits to the repo. At finish time, this skill writes `docs/decisions/<slug>.md` summarizing the design.

### Step 1: Confirm all tasks verified

Read `<workspace>/.humanpowers/state.json`. Confirm `tasks_verified == tasks_total`. If not, error: "Not all tasks verified. Cannot write ADR." and stop.

### Step 2: Ask the developer for a slug

Ask one question via AskUserQuestion: "What's the slug for this feature?" — short kebab-case identifier (e.g., `pcr-curator-review-injection`). The slug becomes the ADR filename.

### Step 3: Read source artifacts

Read in order:
- `<workspace>/.humanpowers/problem.md` (for problem summary, project invariants)
- `<workspace>/.humanpowers/tasks.md` (for task list, action_types, depends_on)
- For each task `{id}`: `<workspace>/.humanpowers/tasks/{id}/round1.md`, `round2.md` if present, `plan.md`, `verify.md`

### Step 4: Write ADR

Write to `<target_repo>/docs/decisions/<slug>.md` (create directory if absent):

```markdown
# <feature title from problem.md "What" section>

## Status

Accepted

## Problem

<one-paragraph summary derived from problem.md "What" + "Why">

## Project invariants

<bulleted list copied from problem.md "Project invariants" section>

## Decisions

<for each task, one or two sentences summarizing the key decisions made. Reference the file paths the task touched. Format:>

### Task <id>: <task name>

<key decisions from quiz round 1 + round 2 if present, plus any plan-level choices>. Touches: `<paths>`.

## Alternatives considered

<bullets surfaced during brainstorming or quiz round 2 — explicit alternatives the developer rejected>

## Consequences

<what changed in the repo, what is now possible, what new constraints exist>

## Verify outcomes

<for each task, one line: what was verified and how — test pass, demo signoff, etc.>
```

### Step 5: Commit ADR

```bash
cd <target_repo>
git add docs/decisions/<slug>.md
git commit -m "design: <feature title>"
```

### Step 6: Optionally bump version + release

If the project uses semver and the developer wants a release, prompt for `major / minor / patch` and run the project's release flow (out of scope for humanpowers; the developer's existing release process applies).

### Step 7: Update workspace phase

```bash
bash scripts/update-state.sh "$WS" phase finished
```

The workspace remains local. The developer can delete `.humanpowers/` at this point if they don't need to resume; the ADR is the durable record.
````

- [ ] **Step 3: Verify**

```bash
grep -c "ADR digest\|docs/decisions" skills/finishing-a-development-branch/SKILL.md   # >=2
grep -c "TF\b\|TF-" skills/finishing-a-development-branch/SKILL.md                     # 0
grep -c "boss\|Boss" skills/finishing-a-development-branch/SKILL.md                    # 0
grep -c "AskUserQuestion" skills/finishing-a-development-branch/SKILL.md               # >=1
```

- [ ] **Step 4: Commit**

```bash
git add skills/finishing-a-development-branch/SKILL.md
git commit -m "finishing-a-development-branch: v0.3 ADR digest writer + vocab sweep"
```

---

## Task 15: Update using-humanpowers SKILL.md

**Files:**
- Modify: `skills/using-humanpowers/SKILL.md`

- [ ] **Step 1: Replace contents**

Write to `skills/using-humanpowers/SKILL.md`:

```markdown
---
name: using-humanpowers
description: Use when starting any conversation in a humanpowers context — establishes how to find and use humanpowers skills, the problem-first workflow, and the local-only privacy model. Auto-loads at session start when humanpowers plugin is active.
---

# Using humanpowers

## What humanpowers is

A Claude Code plugin that structures the developer's design work as the load-bearing element of AI-assisted development. The agent is a structured executor bounded by what the developer wrote down.

The contract: the developer articulates a problem definition, decomposes it into atomic tasks, signs off on per-task expected behavior (quiz), and only then is implementation invited.

## Privacy model

humanpowers workspaces are local-only. The repo's `.gitignore` excludes the entire `.humanpowers/` directory. Working artifacts (problem.md, tasks.md, per-task quiz / plan / verify, etc.) live on the developer's machine and never enter PRs or main branches.

The decision artifact is created at the `finish` phase as `docs/decisions/<slug>.md` and committed. This file is the single durable record of the design — its rationale, key decisions, alternatives considered, and verify outcomes.

## Single entry

`/humanpowers`. The dispatcher detects whether a workspace exists at or above cwd and routes accordingly.

- No workspace → create `.humanpowers/` skeleton, hand off to brainstorming.
- Workspace exists → read phase, route to next skill.

The dispatcher determines workspace location from cwd context. cwd inside a git repo → `.humanpowers/` lives at repo root. cwd outside a git repo → `.humanpowers/` lives at cwd.

## Workflow

```
brainstorm → quiz → plan → operate → verify → review → finish
```

- **brainstorm** — produce `problem.md` (what / why / success criteria / project invariants / out-of-scope / open Qs / preliminary task outline)
- **quiz** — drill expected behavior per task; round 1 mandatory (agent-led), round 2 optional (developer-led); output is the test spec
- **plan** — finalize tasks in `tasks.md` with action_type and depends_on; per-task `plan.md`
- **operate** — implement per task (TDD); `--batch` mode iterates all remaining unbuilt tasks
- **verify** — per-task acceptance demo
- **review** — cross-task cascade decisions
- **finish** — write `docs/decisions/<slug>.md` ADR digest, commit, optionally bump version

## Subcommands

| Command | Action |
|---------|--------|
| `/humanpowers continue` | resume current phase |
| `/humanpowers jump <phase>` | jump to phase, warn if skipping a gate |
| `/humanpowers operate <task-id>` | work on one task |
| `/humanpowers operate --batch` | work on all remaining unbuilt tasks |
| `/humanpowers review` | cross-task review |
| `/humanpowers abort` | mark workspace aborted |

## When NOT to use humanpowers

humanpowers is design-first. For work that does not warrant a design phase — single-line config edits, emergency hotfixes, pure debugging, or pure code review — invoke superpowers skills directly:

- `superpowers:systematic-debugging` for any bug or test failure
- `superpowers:requesting-code-review` for code review on existing changes
- `superpowers:test-driven-development` for adding tests to existing code

humanpowers does not wrap or block these flows.

## Skill access

Skills are listed in the system reminder. Invoke via the `Skill` tool with the fully qualified name `humanpowers:<skill-name>`.

When the developer types `/<skill-name>`, the platform resolves it to the corresponding Skill invocation. Do not guess skill names.
```

- [ ] **Step 2: Verify**

```bash
grep -c "^name: using-humanpowers$" skills/using-humanpowers/SKILL.md      # 1
grep -c "Privacy model" skills/using-humanpowers/SKILL.md                  # 1
grep -c "docs/decisions" skills/using-humanpowers/SKILL.md                 # >=1
grep -c "round 1\|round 2" skills/using-humanpowers/SKILL.md               # >=1
grep -c "operate --batch" skills/using-humanpowers/SKILL.md                # >=1
grep -c "TF\b\|TF-" skills/using-humanpowers/SKILL.md                       # 0
grep -c "boss\|Boss" skills/using-humanpowers/SKILL.md                       # 0
```

- [ ] **Step 3: Commit**

```bash
git add skills/using-humanpowers/SKILL.md
git commit -m "using-humanpowers: v0.3 privacy model section + vocab"
```

---

## Task 16: Vocab sweep on superpowers-inherited skills

**Files:**
- Modify: `skills/systematic-debugging/SKILL.md`
- Modify: `skills/test-driven-development/SKILL.md`
- Modify: `skills/requesting-code-review/SKILL.md`
- Modify: `skills/receiving-code-review/SKILL.md`
- Modify: `skills/using-git-worktrees/SKILL.md`
- Modify: `skills/writing-skills/SKILL.md`
- Modify: `skills/dispatching-parallel-agents/SKILL.md`
- Modify: `skills/subagent-driven-development/SKILL.md`

- [ ] **Step 1: Find stale tokens across all 8 files**

```bash
for f in skills/systematic-debugging/SKILL.md skills/test-driven-development/SKILL.md skills/requesting-code-review/SKILL.md skills/receiving-code-review/SKILL.md skills/using-git-worktrees/SKILL.md skills/writing-skills/SKILL.md skills/dispatching-parallel-agents/SKILL.md skills/subagent-driven-development/SKILL.md; do
  echo "=== $f ==="
  grep -nE "TF\b|TF-|AUQ|D1|D2|SDD|Layer 0|tfs\.md|response-d[12]|boss\b|Boss\b|CSO" "$f"
done
```

Note: in `systematic-debugging/defense-in-depth.md` (and any references in SKILL.md to the defense layers), "Layer 1-4" refers to defense-in-depth architecture (industry usage), not NFR layers. Do NOT replace those occurrences. Manually inspect each "Layer N" hit to determine context.

- [ ] **Step 2: Apply replacements per file**

Word table from Task 7. Per-file specifics:

- `systematic-debugging/SKILL.md`: replace any "Layer 0/1 NFR" references but preserve "Layer 1/2/3/4" defense-architecture references.
- `subagent-driven-development/SKILL.md`: any TF references (likely none after Tasks 6-15) → task. SDD self-references: SKILL.md may say "use SDD" — leave unchanged where it's the proper noun for the skill name; replace where it's used as an abbreviation in narrative.
- Others: standard sweep.

- [ ] **Step 3: Verify per-file**

```bash
for f in skills/systematic-debugging/SKILL.md skills/test-driven-development/SKILL.md skills/requesting-code-review/SKILL.md skills/receiving-code-review/SKILL.md skills/using-git-worktrees/SKILL.md skills/writing-skills/SKILL.md skills/dispatching-parallel-agents/SKILL.md skills/subagent-driven-development/SKILL.md; do
  c1=$(grep -c "TF\b\|TF-" "$f")
  c2=$(grep -c "AUQ\b" "$f")
  c3=$(grep -cE "\bD[12]\b" "$f")
  c4=$(grep -c "boss\|Boss" "$f")
  c5=$(grep -c "tfs\.md" "$f")
  echo "$f: TF=$c1 AUQ=$c2 D1/D2=$c3 boss=$c4 tfs.md=$c5"
done
```

All counts must be 0. ("Layer 1-4" defense references in systematic-debugging are not flagged because the regex above doesn't match them.)

- [ ] **Step 4: Commit**

```bash
git add skills/systematic-debugging/SKILL.md skills/test-driven-development/SKILL.md skills/requesting-code-review/SKILL.md skills/receiving-code-review/SKILL.md skills/using-git-worktrees/SKILL.md skills/writing-skills/SKILL.md skills/dispatching-parallel-agents/SKILL.md skills/subagent-driven-development/SKILL.md
git commit -m "skills: v0.3 vocab sweep on superpowers-inherited 8 skills"
```

---

## Task 17: Vocab sweep on references (templates + examples)

**Files:**
- Modify: `references/templates/quiz-template.md`
- Modify: `references/templates/discussion-template.md`
- Modify: `references/templates/critique-axes.md`
- Rename + modify: `references/templates/response-d1-template.md` → `references/templates/response-round1-template.md`
- Rename + modify: `references/templates/response-d2-template.md` → `references/templates/response-round2-template.md`
- Modify: `references/examples/quiz-api-example.md`
- Modify: `references/examples/quiz-data-example.md`
- Modify: `references/examples/quiz-infra-example.md`
- Modify: `references/examples/quiz-ui-example.md`
- Modify: `references/examples/quiz-crosscut-example.md`
- Rename + modify: `references/examples/d2-discussion-example.md` → `references/examples/round2-discussion-example.md`
- Modify: `references/examples/README.md`

- [ ] **Step 1: Rename files**

```bash
git mv references/templates/response-d1-template.md references/templates/response-round1-template.md
git mv references/templates/response-d2-template.md references/templates/response-round2-template.md
git mv references/examples/d2-discussion-example.md references/examples/round2-discussion-example.md
```

- [ ] **Step 2: Find stale tokens across all template + example files**

```bash
for f in references/templates/*.md references/examples/*.md; do
  c=$(grep -cE "TF\b|TF-|AUQ|\\bD1\\b|\\bD2\\b|Layer 0|Layer 1|tfs\\.md|response-d[12]|boss|Boss" "$f")
  if [ "$c" != "0" ]; then echo "$f: $c hits"; fi
done
```

- [ ] **Step 3: Apply replacements**

Word table from Task 7. References-specific:

- `tasks/TF-CC-{id}/` (cross-cutting task path) → `tasks/{id}/` (the action_type field in `tasks.md` already records `cross-cutting`; no special path prefix needed)
- Any reference to old filenames (`response-d1-developer.md`) → new (`round1.md`)

- [ ] **Step 4: Verify**

```bash
for f in references/templates/*.md references/examples/*.md; do
  c=$(grep -cE "TF\b|TF-|AUQ|\\bD1\\b|\\bD2\\b|Layer 0|tfs\\.md|response-d[12]|boss|Boss" "$f")
  if [ "$c" != "0" ]; then echo "FAIL: $f still has $c hits"; fi
done
echo "(done)"
```

Expected: only the "(done)" line printed.

- [ ] **Step 5: Commit**

```bash
git add references/
git commit -m "references: v0.3 vocab sweep, rename d1/d2 → round1/round2"
```

---

## Task 18: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Audit README**

```bash
grep -nE "TF\b|TF-|AUQ|\\bD1\\b|\\bD2\\b|Layer 0|tfs\\.md|response-d[12]|boss|Boss|shelves|views/" README.md
```

Plus check the Workflow diagram and Core concepts table for any v0.2-era assumptions.

- [ ] **Step 2: Apply replacements + add Privacy model section**

Word table from Task 7. README-specific:

- "scaffold a new one" / "asks for project name" — already removed in v0.2; verify still gone.
- Any reference to `views/` directory in Core concepts → remove that row.
- Update Quick start to mention privacy: "creates `.humanpowers/` (gitignored — local only) and starts brainstorming the problem."
- Add or update Core concepts:
  - "Privacy" row: ".humanpowers/ is gitignored. The decision digest at docs/decisions/<slug>.md is the only artifact committed."
  - Remove "Views" row.
- Update Workflow ASCII diagram to: `brainstorm → quiz → plan → operate → verify → review → finish` (already done in v0.2; verify).
- Update Subcommands list to include `operate --batch`.

- [ ] **Step 3: Verify**

```bash
grep -c "TF\b\|TF-" README.md                              # 0
grep -c "boss\|Boss" README.md                              # 0
grep -c "shelves\|views/" README.md                         # 0
grep -c "Privacy" README.md                                 # >=1
grep -c "docs/decisions" README.md                          # >=1
grep -c "operate --batch\|operate batch" README.md          # >=1
grep -c "round 1\|round 2" README.md                        # 0 (README is high-level; round1/2 lives in skill docs, not README)
```

The `round 1/round 2` count of 0 is intentional for README — concept-level docs need not detail quiz internals. Adjust if you decide to mention them.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "readme: v0.3 privacy model + vocab + operate --batch"
```

---

## Task 19: Update plugin/marketplace.json descriptions

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Read current descriptions**

```bash
jq -r .description .claude-plugin/plugin.json
jq -r '.plugins[0].description' .claude-plugin/marketplace.json
```

Current (from v0.2): "humanpowers structures the developer's design work as the load-bearing element of AI-assisted development. Problem-first workflow with TF decomposition, per-TF quiz, plan, operate, verify, review, finish."

- [ ] **Step 2: Replace descriptions**

Replace `description` in `.claude-plugin/plugin.json` and `plugins[0].description` in `.claude-plugin/marketplace.json` with:

```
humanpowers structures the developer's design work as the load-bearing element of AI-assisted development. Problem-first workflow with task decomposition, per-task quiz / plan / operate / verify / review / finish. Workspace is local-only; the decision digest is the only artifact committed.
```

- [ ] **Step 3: Verify**

```bash
jq -r .description .claude-plugin/plugin.json | grep -c "TF\|boss"           # 0
jq -r .description .claude-plugin/plugin.json | grep -c "task decomposition"  # 1
jq -r '.plugins[0].description' .claude-plugin/marketplace.json | grep -c "TF\|boss"  # 0
jq -r '.plugins[0].description' .claude-plugin/marketplace.json | grep -c "decision digest"  # 1
```

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "manifest: v0.3 description with task vocabulary and privacy note"
```

---

## Task 20: Manual E2E and Publish v0.3.0

**Pre-condition:** All tasks 1-19 committed. Working tree clean.

This task is user-driven. Steps 1-4 are manual verification; Step 5 publishes.

- [ ] **Step 1: Greenfield E2E**

In a fresh shell (with the new plugin already cached after publish, or test pre-publish from cache):

```bash
rm -rf /tmp/hp-greenfield && mkdir /tmp/hp-greenfield && cd /tmp/hp-greenfield
# Open Claude Code, type /humanpowers
```

Expected:
- Dispatcher creates `.humanpowers/` in `/tmp/hp-greenfield/`.
- workspace_kind = `external`, target_repo = `null`.
- Output mentions "this workspace is local-only" + "docs/decisions/<slug>.md".
- Hands off to brainstorming.

Continue through brainstorm → quiz → plan → operate → verify → review → finish. At finish:
- Skill asks for slug.
- ADR written to `docs/decisions/<slug>.md`. (For greenfield, target_repo is null; finish prompts the developer to specify a target repo first or skip ADR.)

- [ ] **Step 2: In-repo E2E**

```bash
rm -rf /tmp/hp-inrepo && mkdir /tmp/hp-inrepo && cd /tmp/hp-inrepo && git init
# Open Claude Code, type /humanpowers
```

Expected:
- `.humanpowers/` at repo root, workspace_kind = `in-repo`, target_repo = `/tmp/hp-inrepo`.
- `git status` shows `.humanpowers/` ignored entirely (no partial visibility).

Run a small problem through the full flow (1-2 small tasks). At finish, ADR appears at `docs/decisions/<slug>.md` and is committed.

- [ ] **Step 3: Old-workspace error path**

```bash
rm -rf /tmp/hp-old && mkdir -p /tmp/hp-old/.humanpowers
echo '{"phase":"brainstorm","tfs_total":0}' > /tmp/hp-old/.humanpowers/state.json
cd /tmp/hp-old
# Open Claude Code, type /humanpowers
```

Expected: dispatcher errors with "Workspace from a prior plugin version detected. Delete `.humanpowers/` and re-init with `/humanpowers`." — exit, no skills invoked.

- [ ] **Step 4: Subcommand verification**

In the in-repo workspace:
- `/humanpowers continue` — resumes current phase
- `/humanpowers jump quiz` — jumps with warning
- `/humanpowers operate --batch` — iterates remaining unbuilt tasks
- `/humanpowers operate 1` — works on task 1
- `/humanpowers review` — invokes review
- `/humanpowers abort` — sets aborted

Record observed behavior in `docs/E2E-self-test.md`. Update PASS/FAIL columns. Commit if E2E passes.

- [ ] **Step 5: Publish v0.3.0**

In Claude Code, from the marketplace directory:

```
/publish minor
```

Expected: version bumped to `0.3.0` in `plugin.json` and `marketplace.json`, commit "Release v0.3.0", tag pushed to origin, cache + installed_plugins.json synced.

- [ ] **Step 6: Draft release notes**

Via `gh release create v0.3.0` or the GitHub web UI:

```markdown
# v0.3.0 — Vocabulary cleanup, privacy model, ADR digest

## Breaking changes

- v0.2.x workspaces are not compatible. Delete `.humanpowers/` and re-init with `/humanpowers`.
- `state.json` schema renamed `tfs_*` fields to `tasks_*`.
- `executing-plans` skill removed; merged into `operate --batch`.
- `hooks/hooks.json` and `scripts/shelf-truncate.sh` removed; shelves are no longer part of the workspace.
- `views/` directory removed from workspace structure.

## What's new

- **Privacy model**: the entire `.humanpowers/` directory is now gitignored. Working artifacts stay on the developer's machine.
- **ADR digest**: at the `finish` phase, the plugin writes `docs/decisions/<slug>.md` summarizing the design (problem, project invariants, decisions, alternatives, consequences, verify outcomes). This is the only artifact the plugin commits to the repo.
- **Vocabulary**: internal abbreviations replaced with full agreed words. `TF` → `task`, `D1/D2` → `round 1/round 2`, `AUQ` → `AskUserQuestion`, `Layer 0/1` → `project invariants` / `task-local NFR`, `boss` → `developer`. Industry-standard abbreviations (TDD, NFR, SSOT, RACI, MCP, etc.) retained.
- **17 skills** (down from 18). `executing-plans` merged into `operate --batch`.

## Migration

Old workspaces are not auto-migrated. The dispatcher fails fast with a clear instruction. Re-running `/humanpowers` in any directory creates a fresh v0.3 workspace.
```

- [ ] **Step 7: Reload + smoke test**

```
/reload-plugins
```

Verify dispatcher behaves per v0.3 in the user's actual environment.

---

## Self-review checklist (run after writing this plan)

Spec coverage:

- [x] Privacy model (`.humanpowers/` fully gitignored) → Task 2
- [x] ADR digest at finish (docs/decisions/<slug>.md) → Task 14
- [x] state.json schema rename → Task 1
- [x] check-state.sh validation + error msg → Task 1
- [x] Hook removal → Task 3
- [x] Views removal → Task 4 + Task 6 (dispatcher) + Task 7 (brainstorming) + Task 18 (README)
- [x] Shelves removal → covered by Tasks 3, 6, 7
- [x] problem.md "Project invariants" section → Task 5
- [x] Dispatcher rewrite → Task 6
- [x] All skill vocab updates → Tasks 7-15
- [x] executing-plans removal + operate --batch → Tasks 10, 11
- [x] ADR digest writer in finishing → Task 14
- [x] superpowers-inherited 8 skills sweep → Task 16
- [x] Templates + examples sweep + renames → Task 17
- [x] README → Task 18
- [x] Manifest descriptions → Task 19
- [x] Manual E2E + publish → Task 20
- [x] "Layer 1-4" defense-in-depth preservation in systematic-debugging → noted in Task 16

Placeholder scan: no TODO / TBD patterns. Each step has explicit file paths, full content where new, and exact verify commands.

Type consistency: phase values (`""`, `problem-defined`, `quiz-done`, `planned`, `built`, `verified`, `aborted`, `finished`) consistent across Tasks 1, 6, 14. Field names (`target_repo`, `workspace_kind`, `tasks_total`, `tasks_quiz_done`, `tasks_built`, `tasks_verified`) consistent across Tasks 1, 6.

Scope: single design pass. No sub-project decomposition needed.
