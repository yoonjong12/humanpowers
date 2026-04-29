# humanpowers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generalize humanpowers from scaffold-only to problem-first abstraction. Dispatcher detects cwd context (in-repo / external), creates `.humanpowers/` workspace skeleton, hands off to brainstorming. scaffold skill removed.

**Architecture:** Markdown-only Claude Code plugin. No compiled code. "Tests" = grep-based content assertions for skill files plus a manual E2E pass at the end.

**Tech Stack:** Bash + jq + markdown. SKILL.md frontmatter (`name`, `description`). state.json schema enforced by check-state.sh / update-state.sh.

---

## File Structure

### Created

- `references/templates/problem.md` — problem definition template for brainstorming output
- `references/templates/state.json` — canonical state.json skeleton

### Modified

- `skills/humanpowers/SKILL.md` — dispatcher rewrite (context detection, skeleton creation, simplified routing)
- `skills/brainstorming/SKILL.md` — emit problem.md when state.json is empty, transition phase
- `skills/quiz/SKILL.md` — drop tfs_brainstormed reference, align to new schema
- `skills/operate/SKILL.md` — drop `~/humanpowers/{project}/` assumption, read target_repo from state.json
- `skills/review/SKILL.md` — workspace path resolution via state.json
- `skills/verification-before-completion/SKILL.md` — workspace path resolution via state.json
- `skills/finishing-a-development-branch/SKILL.md` — workspace path resolution via state.json
- `skills/using-humanpowers/SKILL.md` — problem-first abstraction docs
- `scripts/check-state.sh` — drop `project` / `tfs_brainstormed`, add `target_repo` / `workspace_kind`
- `scripts/update-state.sh` — no schema-aware change, but verify still works
- `README.md` — problem-first workflow, scaffold-free entry, Subcommands vocabulary
- `.claude-plugin/plugin.json` — description rewrite (no "boss" / "lazy boss" / "Forks superpowers")
- `.claude-plugin/marketplace.json` — description rewrite
- `.gitignore` — add `.humanpowers/shelves/`
- `references/templates/quiz-template.md` — replace "boss" with "developer"
- `references/templates/discussion-template.md` — replace "boss" with "developer"
- `references/templates/critique-axes.md` — replace "boss" with "developer"
- `references/examples/d2-discussion-example.md` — replace "boss" with "developer"
- `references/examples/README.md` — replace "boss" with "developer"

### Deleted

- `skills/scaffold/` — entire directory (absorbed into dispatcher)
- `skills/systematic-debugging/CREATION-LOG.md` — orphan
- `skills/systematic-debugging/test-academic.md` — orphan
- `skills/systematic-debugging/test-pressure-1.md` — orphan
- `skills/systematic-debugging/test-pressure-2.md` — orphan
- `skills/systematic-debugging/test-pressure-3.md` — orphan

### Renamed

- `docs/E2E-self-test-2026-04-28.md` → `docs/E2E-self-test.md`
- `docs/plans/2026-04-28-humanpowers-phase1.md` → archived into `docs/plans/legacy/` or removed (superseded by this plan)

---

## Verification model

Skill files have no unit tests. Per-task verification is one of:

1. **grep assertion** — `grep -c "<pattern>" <file>` returns expected count.
2. **jq assertion** — `jq '<query>' <file>` returns expected value.
3. **filesystem assertion** — file exists / does not exist (ls / test).
4. **manual E2E** — final integration test, Task 14.

Verify-before-commit means running the assertion and checking the exact expected output before staging.

---

## Task 1: Define canonical state.json schema and update scripts

**Files:**
- Create: `references/templates/state.json`
- Modify: `scripts/check-state.sh`

- [ ] **Step 1: Write canonical state.json template**

Write `references/templates/state.json`:

```json
{
  "phase": "",
  "target_repo": null,
  "workspace_kind": "",
  "tfs_total": 0,
  "tfs_quiz_done": 0,
  "tfs_built": 0,
  "tfs_verified": 0
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
for field in phase target_repo workspace_kind tfs_total tfs_quiz_done tfs_built tfs_verified; do
  if ! jq -e "has(\"$field\")" "$STATE" >/dev/null 2>&1; then
    echo "ERROR: state.json missing required field '$field'. v0.1.x workspace detected. Delete .humanpowers/ and re-init with /humanpowers." >&2
    exit 1
  fi
done

PHASE=$(jq -r .phase "$STATE")
TARGET=$(jq -r .target_repo "$STATE")
KIND=$(jq -r .workspace_kind "$STATE")
TFS_TOTAL=$(jq -r .tfs_total "$STATE")
TFS_QUIZ=$(jq -r .tfs_quiz_done "$STATE")
TFS_BUILT=$(jq -r .tfs_built "$STATE")
TFS_VER=$(jq -r .tfs_verified "$STATE")

cat <<EOF
phase: $PHASE
target_repo: $TARGET
workspace_kind: $KIND
tfs:
  total: $TFS_TOTAL
  quiz-done: $TFS_QUIZ
  built: $TFS_BUILT
  verified: $TFS_VER
EOF
```

- [ ] **Step 4: Verify check-state.sh against template**

Run:
```bash
mkdir -p /tmp/hp-test/.humanpowers
cp references/templates/state.json /tmp/hp-test/.humanpowers/state.json
bash scripts/check-state.sh /tmp/hp-test
```
Expected output starts with `phase:` line and lists all fields. Exit 0.

Run with old-schema state.json to confirm error:
```bash
echo '{"phase":"x","project":"y"}' > /tmp/hp-test/.humanpowers/state.json
bash scripts/check-state.sh /tmp/hp-test
```
Expected: `ERROR: ... missing required field 'target_repo'`. Exit 1.

Cleanup: `rm -rf /tmp/hp-test`

- [ ] **Step 5: Commit**

```bash
git add references/templates/state.json scripts/check-state.sh
git commit -m "state: canonical schema with target_repo + workspace_kind"
```

---

## Task 2: Add problem.md template

**Files:**
- Create: `references/templates/problem.md`

- [ ] **Step 1: Write problem.md template**

Write `references/templates/problem.md`:

```markdown
# Problem Definition

> Output of `humanpowers:brainstorming`. Drives TF decomposition and per-TF quizzes downstream. Treat as living: refine as design clarifies.

## What

One paragraph: what is the developer trying to solve? State the user-facing outcome, not the technical mechanism.

## Why

One paragraph: why does this matter? Constraint, deadline, business motivation, or technical debt being addressed.

## Success criteria

Bulleted list of observable conditions that, when met, mean the work is done. Each criterion must be checkable without reading code (e.g., "command X returns Y", "file Z contains Q", "user can do W").

## Out of scope

Bulleted list of things this work explicitly does NOT do. Documenting non-goals prevents scope drift.

## Open questions

Bulleted list of unresolved decisions. Each question must be answerable; vague philosophy questions belong elsewhere.

## TF outline (preliminary)

Numbered list. Each TF has: short name, files it touches (new or existing), why it exists. This is preliminary — `humanpowers:writing-plans` finalizes the TF list with action_type and depends_on graph.

1. **TF-1: <name>** — files: `<paths>`. <rationale>
2. **TF-2: <name>** — files: `<paths>`. <rationale>
```

- [ ] **Step 2: Verify file**

Run: `test -f references/templates/problem.md && grep -c "^## " references/templates/problem.md`
Expected: 6 (six H2 sections).

- [ ] **Step 3: Commit**

```bash
git add references/templates/problem.md
git commit -m "templates: add problem.md for brainstorming output"
```

---

## Task 3: Rewrite dispatcher SKILL.md

**Files:**
- Modify: `skills/humanpowers/SKILL.md` (full rewrite, replace contents)

- [ ] **Step 1: Replace skills/humanpowers/SKILL.md**

Write new contents:

````markdown
---
name: humanpowers
description: Single entry point for humanpowers. Detects cwd context (in-repo or external), creates .humanpowers/ workspace skeleton when absent, then routes by phase. Developer types `/humanpowers` (optionally with a Subcommand) and the dispatcher determines the next skill. Use whenever the developer wants to start or resume design-first work.
---

# humanpowers Dispatcher

## Behavior

Single entry to humanpowers. Two responsibilities:

1. **Workspace structure** — locate or create `.humanpowers/` and seed `state.json`.
2. **Phase routing** — read `state.json` and hand off to the next skill.

The dispatcher does not author content. brainstorming owns problem definition; quiz / writing-plans / operate / verification / review own per-TF work.

## Step 1: Locate workspace

```bash
# Search upward from cwd for .humanpowers/state.json (closest wins)
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
# Decide workspace_kind and target_repo from cwd context
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

mkdir -p "$WS_DIR/tfs" "$WS_DIR/views" "$WS_DIR/shelves"

# Seed state.json from template (target_repo as JSON null when external)
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
  "tfs_total": 0,
  "tfs_quiz_done": 0,
  "tfs_built": 0,
  "tfs_verified": 0
}
EOF
```

Output to user:

```
Workspace created: <WS_DIR>
workspace_kind: <KIND>
target_repo: <TARGET>

Invoking humanpowers:brainstorming to define the problem.
```

Hand off to `humanpowers:brainstorming`. brainstorming will produce `problem.md` and set `phase = problem-defined`.

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
| `planned` | humanpowers:operate (per remaining TF) |
| `built` | humanpowers:verification-before-completion |
| `verified` (some TFs) | humanpowers:review or humanpowers:operate (next TF) |
| `verified` (all TFs) | humanpowers:finishing-a-development-branch |

Echo current state before routing:

```
Workspace: <WS>
Phase: <PHASE>
TFs: <verified>/<total> verified, <built>/<total> built, <quiz_done>/<total> quiz-done
```

If a Subcommand was passed (e.g., `/humanpowers jump quiz`), apply the override after the echo.

## Step 4: Subcommands

| Command | Action |
|---------|--------|
| `/humanpowers continue` | resume current phase (default behavior) |
| `/humanpowers jump <phase>` | force jump to phase; warn if skipping a gate |
| `/humanpowers operate <TF-id>` | invoke humanpowers:operate with a specific TF |
| `/humanpowers review` | invoke humanpowers:review for cross-TF cascade |
| `/humanpowers abort` | mark workspace aborted in state.json + stop |

`abort` sets `phase = "aborted"` via `scripts/update-state.sh "$WS" phase aborted`.

## Notes for skill authors

Skills downstream of the dispatcher must:

- Read workspace location from cwd or upward search (same logic as Step 1). Do NOT assume `~/humanpowers/{project}/`.
- Read `target_repo` from `state.json` when they need the code repo (operate, verification, finishing).
- Update phase via `scripts/update-state.sh` rather than manual jq edits.
````

- [ ] **Step 2: Verify dispatcher rewrite**

Run all of:

```bash
grep -c "^name: humanpowers$" skills/humanpowers/SKILL.md            # 1
grep -c "scaffold" skills/humanpowers/SKILL.md                        # 0
grep -c "workspace_kind" skills/humanpowers/SKILL.md                  # >=2
grep -c "target_repo" skills/humanpowers/SKILL.md                     # >=2
grep -c "Subcommand" skills/humanpowers/SKILL.md                      # >=2
grep -c "boss" skills/humanpowers/SKILL.md                            # 0
grep -c "~/humanpowers/" skills/humanpowers/SKILL.md                  # 0
```

All assertions must hold.

- [ ] **Step 3: Commit**

```bash
git add skills/humanpowers/SKILL.md
git commit -m "dispatcher: rewrite to context-detect + skeleton-create, drop scaffold branch"
```

---

## Task 4: Augment brainstorming SKILL.md

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

The brainstorming skill currently inherits superpowers' generic brainstorming. We need to add:

1. A Pre-step: when invoked from the dispatcher with an empty `state.json`, produce `problem.md` from the template and set phase to `problem-defined`.
2. Save location: `.humanpowers/problem.md` (replacing the superpowers `docs/superpowers/specs/...` default).
3. Phase transition at the end.

- [ ] **Step 1: Read current brainstorming/SKILL.md to identify the "Save the spec" section**

Run: `grep -n "Save\|spec\|docs/" skills/brainstorming/SKILL.md | head -20`

Expected: lines referencing `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`.

- [ ] **Step 2: Replace save-location and add Pre-step**

Edit `skills/brainstorming/SKILL.md`:

- Add a new H2 section near the top, after the description frontmatter and intro:

```markdown
## humanpowers context

When invoked by `humanpowers:humanpowers` (the dispatcher), the workspace `.humanpowers/state.json` exists with `phase = ""`. Treat the brainstorm output as `problem.md`, NOT the generic superpowers spec.

**Save location:** `<workspace>/.humanpowers/problem.md` (use template at `references/templates/problem.md` from this plugin).

**Phase transition:** After the developer signs off on `problem.md`, run:

```bash
WS="$(dirname "$(find . -maxdepth 3 -name state.json -path '*/.humanpowers/*' | head -1)")"
WS="$(dirname "$WS")"
bash scripts/update-state.sh "$WS" phase problem-defined
```

Then hand off to `humanpowers:quiz`. Do NOT invoke writing-plans here; quiz comes first in humanpowers.
```

- Replace the existing "Save the validated design (spec) to `docs/superpowers/specs/...`" instruction so it points to `<workspace>/.humanpowers/problem.md` instead.

- Replace the terminal-state instruction at the end of the skill: change `writing-plans` to `humanpowers:quiz` for the humanpowers context. Keep the generic superpowers handoff (writing-plans) noted as the fallback when there is no humanpowers workspace.

- [ ] **Step 3: Verify**

Run:

```bash
grep -c "problem.md" skills/brainstorming/SKILL.md            # >=2
grep -c "humanpowers:quiz" skills/brainstorming/SKILL.md      # >=1
grep -c "problem-defined" skills/brainstorming/SKILL.md       # >=1
grep -c "boss" skills/brainstorming/SKILL.md                  # 0
```

- [ ] **Step 4: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "brainstorming: emit problem.md, transition phase to problem-defined"
```

---

## Task 5: Update quiz SKILL.md state references

**Files:**
- Modify: `skills/quiz/SKILL.md`

- [ ] **Step 1: Find stale references**

Run:

```bash
grep -n "tfs_brainstormed\|~/humanpowers/\|jq -r .project\|boss\|brainstorm-done" skills/quiz/SKILL.md
```

Expected: a small number of lines referencing dropped fields and old assumptions.

- [ ] **Step 2: Apply fixes**

For each line found:

- `tfs_brainstormed` → remove the field (it doesn't exist in v0.2 schema). Quiz progress is tracked via `tfs_quiz_done` only.
- `~/humanpowers/{project}/` → replace with `<workspace>/` (workspace resolved via upward search from cwd, see dispatcher Step 1).
- `jq -r .project ...` → remove. Use `target_repo` if needed; otherwise just `<workspace>` paths.
- `boss` → `developer`.
- `brainstorm-done` → `problem-defined` (phase rename).

- [ ] **Step 3: Verify**

Run:

```bash
grep -c "tfs_brainstormed" skills/quiz/SKILL.md       # 0
grep -c "brainstorm-done" skills/quiz/SKILL.md        # 0
grep -c "~/humanpowers/" skills/quiz/SKILL.md         # 0
grep -c "boss" skills/quiz/SKILL.md                   # 0
grep -c "problem-defined" skills/quiz/SKILL.md        # >=1
```

- [ ] **Step 4: Commit**

```bash
git add skills/quiz/SKILL.md
git commit -m "quiz: align to v0.2 state schema, drop tfs_brainstormed and ~/humanpowers assumption"
```

---

## Task 6: Update operate / review / verification / finishing skills

**Files:**
- Modify: `skills/operate/SKILL.md`
- Modify: `skills/review/SKILL.md`
- Modify: `skills/verification-before-completion/SKILL.md`
- Modify: `skills/finishing-a-development-branch/SKILL.md`

These four skills all assume `~/humanpowers/{project}/` and reference `state.json` directly. Each needs the same change set.

- [ ] **Step 1: Find stale references**

Run for each file (list returned per file):

```bash
for f in skills/operate/SKILL.md skills/review/SKILL.md skills/verification-before-completion/SKILL.md skills/finishing-a-development-branch/SKILL.md; do
  echo "=== $f ==="
  grep -n "~/humanpowers/\|jq -r .project\|brainstorm-done\|boss" "$f"
done
```

- [ ] **Step 2: Apply fixes per file**

For each of the four files:

- Replace `~/humanpowers/{project}/` with `<workspace>/`. Add a small bash helper at the top of the skill's "Workspace location" section:

```bash
# Resolve workspace from cwd (upward search)
DIR="$(pwd)"; WS=""
while [ "$DIR" != "/" ]; do
  [ -f "$DIR/.humanpowers/state.json" ] && WS="$DIR" && break
  DIR="$(dirname "$DIR")"
done
[ -z "$WS" ] && { echo "no humanpowers workspace"; exit 1; }
TARGET=$(jq -r .target_repo "$WS/.humanpowers/state.json")
```

- Code that operates on the actual repo (operate / verification) uses `$TARGET`. Code that operates on workspace artifacts (state, tfs.md) uses `$WS`.
- `jq -r .project` → drop entirely (no project field).
- `brainstorm-done` → `problem-defined`.
- `boss` → `developer`.

- [ ] **Step 3: Verify**

Run:

```bash
for f in skills/operate/SKILL.md skills/review/SKILL.md skills/verification-before-completion/SKILL.md skills/finishing-a-development-branch/SKILL.md; do
  echo "=== $f ==="
  grep -c "~/humanpowers/" "$f"             # 0
  grep -c ".project" "$f"                   # 0 (no .project field references)
  grep -c "brainstorm-done" "$f"            # 0
  grep -c "boss" "$f"                       # 0
done
```

- [ ] **Step 4: Commit**

```bash
git add skills/operate/SKILL.md skills/review/SKILL.md skills/verification-before-completion/SKILL.md skills/finishing-a-development-branch/SKILL.md
git commit -m "skills: workspace path via upward search, drop ~/humanpowers + .project assumptions"
```

---

## Task 7: Delete scaffold skill

**Files:**
- Delete: `skills/scaffold/`

- [ ] **Step 1: Verify nothing else references scaffold**

Run:

```bash
grep -rln "humanpowers:scaffold\|skills/scaffold" --include="*.md" --include="*.json" --include="*.sh" --exclude-dir=.git
```

Expected: only files we are editing (dispatcher already updated in Task 3 to remove these references). If the dispatcher rewrite was complete, no remaining refs outside docs/specs/humanpowers-design.md (which retains historical context).

If references remain in active files, fix them before proceeding.

- [ ] **Step 2: Delete directory**

```bash
git rm -r skills/scaffold/
```

- [ ] **Step 3: Verify**

```bash
test ! -d skills/scaffold && echo OK
grep -rln "humanpowers:scaffold" skills/ scripts/ README.md     # empty
```

- [ ] **Step 4: Commit**

```bash
git commit -m "scaffold: delete (absorbed into dispatcher workspace creation)"
```

---

## Task 8: Delete orphan superpowers test artifacts

**Files:**
- Delete: `skills/systematic-debugging/CREATION-LOG.md`
- Delete: `skills/systematic-debugging/test-academic.md`
- Delete: `skills/systematic-debugging/test-pressure-1.md`
- Delete: `skills/systematic-debugging/test-pressure-2.md`
- Delete: `skills/systematic-debugging/test-pressure-3.md`

- [ ] **Step 1: Final reference check**

```bash
grep -rln "test-pressure\|test-academic\|CREATION-LOG" --include="*.md" --include="*.json" --include="*.sh" --exclude-dir=.git
```

Expected: empty (zero references — already verified in spec, recheck before delete).

- [ ] **Step 2: Delete**

```bash
git rm skills/systematic-debugging/CREATION-LOG.md \
       skills/systematic-debugging/test-academic.md \
       skills/systematic-debugging/test-pressure-1.md \
       skills/systematic-debugging/test-pressure-2.md \
       skills/systematic-debugging/test-pressure-3.md
```

- [ ] **Step 3: Verify**

```bash
ls skills/systematic-debugging/   # only SKILL.md + 3 reference docs (root-cause / defense / condition) + find-polluter.sh
```

Expected listing: `SKILL.md`, `condition-based-waiting.md`, `defense-in-depth.md`, `find-polluter.sh`, `root-cause-tracing.md`. Five entries.

- [ ] **Step 4: Commit**

```bash
git commit -m "systematic-debugging: delete orphan superpowers skill-development artifacts"
```

---

## Task 9: Rewrite using-humanpowers SKILL.md

**Files:**
- Modify: `skills/using-humanpowers/SKILL.md` (full rewrite)

- [ ] **Step 1: Replace contents**

Write `skills/using-humanpowers/SKILL.md`:

```markdown
---
name: using-humanpowers
description: Use when starting any conversation in a humanpowers context — establishes how to find and use humanpowers skills and the problem-first workflow. Auto-loads at session start when humanpowers plugin is active.
---

# Using humanpowers

## What humanpowers is

A Claude Code plugin that structures the developer's design work as the load-bearing element of AI-assisted development. The agent is a structured executor bounded by what the developer wrote down.

The contract: the developer articulates a problem definition, decomposes it into atomic units (TFs), signs off on per-TF expected behavior (quiz), and only then is implementation invited.

## Single entry

`/humanpowers`. The dispatcher detects whether a workspace exists at or above cwd and routes accordingly.

- No workspace → create `.humanpowers/` skeleton, hand off to brainstorming.
- Workspace exists → read phase, route to next skill.

The dispatcher determines workspace location from cwd context. cwd inside a git repo → `.humanpowers/` lives at repo root. cwd outside a git repo → `.humanpowers/` lives at cwd.

## Workflow

```
brainstorm → quiz → plan → operate → verify → review → finish
```

- **brainstorm** — produce `problem.md` (what / why / success criteria / out-of-scope / open Qs / preliminary TF outline)
- **quiz** — drill expected behavior per TF; output is the test spec
- **plan** — finalize TFs in `tfs.md` with action_type and depends_on; per-TF `plan.md`
- **operate** — implement per TF; TDD where applicable
- **verify** — per-TF acceptance demo
- **review** — cross-TF cascade decisions
- **finish** — version bump and release

## Subcommands

| Command | Action |
|---------|--------|
| `/humanpowers continue` | resume current phase |
| `/humanpowers jump <phase>` | jump to phase, warn if skipping a gate |
| `/humanpowers operate <TF-id>` | work on one TF |
| `/humanpowers review` | cross-TF review |
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
grep -c "^name: using-humanpowers$" skills/using-humanpowers/SKILL.md          # 1
grep -c "boss" skills/using-humanpowers/SKILL.md                                # 0
grep -c "scaffold" skills/using-humanpowers/SKILL.md                            # 0
grep -c "problem.md" skills/using-humanpowers/SKILL.md                          # >=1
grep -c "Subcommand" skills/using-humanpowers/SKILL.md                          # >=1
```

- [ ] **Step 3: Commit**

```bash
git add skills/using-humanpowers/SKILL.md
git commit -m "using-humanpowers: rewrite for problem-first abstraction"
```

---

## Task 10: Replace "boss" vocabulary across remaining files

**Files:**
- Modify: every file containing the word `boss` outside docs/specs/ and docs/plans/legacy/

Tasks 3, 4, 5, 6, 9 already removed `boss` from individual skills. Remaining: templates, examples, README, plugin.json, marketplace.json, miscellaneous.

- [ ] **Step 1: Find remaining occurrences**

```bash
grep -rln "boss\|Boss\|BOSS" --include="*.md" --include="*.json" --include="*.sh" --exclude-dir=.git --exclude-dir=docs/specs --exclude-dir=docs/plans/legacy
```

- [ ] **Step 2: Replace word-by-word, preserving case**

For each file in the list:

- `boss` → `developer`
- `Boss` → `Developer`
- `BOSS` → `DEVELOPER`

Use targeted edits per file rather than blind sed; some occurrences may be inside code samples or quoted user text where preservation matters. Read each file, apply Edit per occurrence, verify the result reads naturally.

Specific replacement nuance:
- "lazy boss" framing → drop entirely (delete the phrase, rewrite the sentence). Reason: the "lazy boss" mental model is the scaffold-centric framing being retired.
- Plugin.json description currently mentions "Forks superpowers..." and "boss". Rewrite to: `humanpowers structures the developer's design work as the load-bearing element. Problem definition, TF decomposition, per-TF quiz/plan/operate/verify/review.`
- marketplace.json description: same rewrite.

- [ ] **Step 3: Verify**

```bash
grep -rln "\bboss\b\|Boss\|BOSS\|lazy boss" --include="*.md" --include="*.json" --include="*.sh" --exclude-dir=.git --exclude-dir=docs/specs --exclude-dir=docs/plans/legacy
```

Expected: empty.

Spec doc and legacy plan doc retain historical "boss" — this is intentional (frozen past records).

- [ ] **Step 4: Commit**

```bash
git add -u
git commit -m "vocab: replace 'boss' with 'developer' across active files"
```

---

## Task 11: Rename or archive date-stamped doc files

**Files:**
- Rename: `docs/E2E-self-test-2026-04-28.md` → `docs/E2E-self-test.md`
- Archive: `docs/plans/2026-04-28-humanpowers-phase1.md` → `docs/plans/legacy/humanpowers-phase1.md`

The current date-stamped E2E doc is a template that will be reused. The phase1 plan is superseded by this plan; archive into `legacy/` for historical reference rather than overwrite.

- [ ] **Step 1: Rename E2E test doc**

```bash
git mv docs/E2E-self-test-2026-04-28.md docs/E2E-self-test.md
```

- [ ] **Step 2: Archive old plan**

```bash
mkdir -p docs/plans/legacy
git mv docs/plans/2026-04-28-humanpowers-phase1.md docs/plans/legacy/humanpowers-phase1.md
```

- [ ] **Step 3: Update E2E-self-test.md content for new flow**

Edit `docs/E2E-self-test.md`:

- Remove date from title (was: `# Phase 1 E2E Self-Test (2026-04-28)`)
- Update scenarios to reflect: no scaffold prompt, dispatcher creates `.humanpowers/` automatically
- Add greenfield scenario AND in-repo (adapter) scenario as two top-level test cases
- Skill list: 18 (was 19) — remove scaffold from the checklist
- Section per skill: PASS/FAIL toggle, observed behavior

Concrete sections required (each with PASS/FAIL placeholder):

1. Greenfield E2E (cwd outside any git repo)
2. In-repo E2E (cwd inside a fresh git repo)
3. Per-skill behavior verification (18 skills)
4. Subcommand verification (`continue`, `jump`, `operate`, `review`, `abort`)
5. Old workspace error path (state.json with v0.1.x schema → expected error)

- [ ] **Step 4: Verify**

```bash
test -f docs/E2E-self-test.md && echo OK
test ! -f docs/E2E-self-test-2026-04-28.md && echo OK
test -f docs/plans/legacy/humanpowers-phase1.md && echo OK
test ! -f docs/plans/2026-04-28-humanpowers-phase1.md && echo OK
grep -c "scaffold" docs/E2E-self-test.md       # 0 (no scaffold scenarios)
grep -c "Greenfield\|In-repo" docs/E2E-self-test.md   # >=2
```

- [ ] **Step 5: Commit**

```bash
git add docs/
git commit -m "docs: drop date-stamped filenames, archive legacy phase1 plan"
```

---

## Task 12: Update .gitignore

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add .humanpowers/shelves/ entry**

Append to `.gitignore`:

```
.humanpowers/shelves/
```

The shelves directory is per-session scratchpad; not part of the design artifact.

- [ ] **Step 2: Verify**

```bash
grep -c "^.humanpowers/shelves/$" .gitignore        # 1
grep -c "^.humanpowers/state.json$" .gitignore      # 1 (already there)
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "gitignore: exclude .humanpowers/shelves/"
```

---

## Task 13: Update README.md

**Files:**
- Modify: `README.md`

The current README already reflects most of the v0.2 stance from a recent rewrite. Verify alignment with v0.2 design and patch any remaining v0.1 assumptions.

- [ ] **Step 1: Audit README for stale content**

Check each of:

```bash
grep -n "scaffold\|boss\|~/humanpowers/\|forked from superpowers" README.md
```

Expected stale matches: any reference to scaffold as an explicit step, boss vocabulary, `~/humanpowers/{project}/` paths, "forked from superpowers" (if present — should already be "inspired by").

- [ ] **Step 2: Update Workflow diagram**

The current README workflow shows: `design → quiz → plan → build → verify → review → finish`. Update to v0.2 phase names: `brainstorm → quiz → plan → operate → verify → review → finish`. Replace the labels.

- [ ] **Step 3: Update Core concepts table**

The Quick start currently says "asks for project name" when no workspace exists. Replace with: "creates `.humanpowers/` workspace at the appropriate location (repo root if inside a git repo, else cwd) and starts brainstorming the problem."

The Workspace row in the Core concepts table currently says `~/humanpowers/{project-name}/`. Replace with: `.humanpowers/ — workspace directory. Lives in your repo root (in-repo mode) or cwd (external mode), determined automatically. Holds problem.md, tfs.md, and per-TF artifacts.`

- [ ] **Step 4: Verify**

```bash
grep -c "scaffold" README.md             # 0
grep -c "boss" README.md                 # 0
grep -c "~/humanpowers/" README.md       # 0
grep -c "problem.md" README.md           # >=1
grep -c "brainstorm" README.md           # >=1
```

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "readme: align with v0.2 problem-first abstraction"
```

---

## Task 14: Update plugin.json + marketplace.json descriptions

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Read current descriptions**

```bash
jq -r .description .claude-plugin/plugin.json
jq -r .plugins[0].description .claude-plugin/marketplace.json
```

Expected: both contain v0.1 framing (boss / scaffold / forked).

- [ ] **Step 2: Replace plugin.json description**

Set `description` in `.claude-plugin/plugin.json` to:

```
humanpowers structures the developer's design work as the load-bearing element of AI-assisted development. Problem-first workflow with TF decomposition, per-TF quiz, plan, operate, verify, review, finish.
```

- [ ] **Step 3: Replace marketplace.json description**

Set `plugins[0].description` in `.claude-plugin/marketplace.json` to the same string.

- [ ] **Step 4: Verify**

```bash
jq -r .description .claude-plugin/plugin.json | grep -c "boss\|scaffold\|Forks\|lazy"        # 0
jq -r .plugins[0].description .claude-plugin/marketplace.json | grep -c "boss\|scaffold\|Forks\|lazy"   # 0
jq -r .description .claude-plugin/plugin.json | grep -c "problem-first\|Problem-first"        # 1
```

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "manifest: rewrite descriptions for v0.2 problem-first framing"
```

---

## Task 15: Manual E2E retest

**Files:**
- Update: `docs/E2E-self-test.md` (fill PASS/FAIL per skill)

This is human-driven. Run two full sessions in fresh Claude Code processes.

- [ ] **Step 1: Greenfield E2E**

In a fresh shell:

```bash
mkdir /tmp/hp-greenfield && cd /tmp/hp-greenfield
# Open Claude Code in this dir
# Type: /humanpowers
```

Expected:
- Dispatcher creates `.humanpowers/` in `/tmp/hp-greenfield/`
- workspace_kind = `external`, target_repo = null
- Hands off to brainstorming
- brainstorming asks one clarifying question at a time
- Output saved to `.humanpowers/problem.md`
- phase transitions to `problem-defined`
- `/humanpowers continue` advances to quiz

Stop after `quiz-done`. Record observed behavior in `docs/E2E-self-test.md`.

- [ ] **Step 2: In-repo E2E**

```bash
mkdir /tmp/hp-inrepo && cd /tmp/hp-inrepo && git init
# Open Claude Code
# Type: /humanpowers
```

Expected:
- Dispatcher creates `.humanpowers/` at repo root
- workspace_kind = `in-repo`, target_repo = `/tmp/hp-inrepo`
- Same handoff flow

Stop after `quiz-done`. Record.

- [ ] **Step 3: Old-workspace error path**

```bash
mkdir /tmp/hp-old && cd /tmp/hp-old
mkdir .humanpowers
echo '{"phase":"brainstorm","project":"old"}' > .humanpowers/state.json
# Type: /humanpowers
```

Expected: error message about missing required fields, instructing to delete `.humanpowers/` and re-init.

Record.

- [ ] **Step 4: Subcommand verification**

In one of the test workspaces:
- `/humanpowers continue` — resumes current phase
- `/humanpowers jump quiz` — jumps phase with warning if skipping
- `/humanpowers operate TF-1` — only after a TF-1 exists
- `/humanpowers review` — invokes review skill
- `/humanpowers abort` — sets phase = aborted

Record each.

- [ ] **Step 5: Fill PASS/FAIL in docs/E2E-self-test.md**

Mark each scenario and each skill PASS or FAIL with one-line observed-vs-expected note. Commit.

```bash
git add docs/E2E-self-test.md
git commit -m "e2e: record manual retest results for v0.2"
```

---

## Task 16: Publish v0.2.0

**Pre-condition:** All tasks above committed; E2E PASS for both greenfield and in-repo.

- [ ] **Step 1: Run /publish minor**

In Claude Code, from the marketplace directory:

```
/publish minor
```

Expected: version bumped to 0.2.0 in `plugin.json` and `marketplace.json`, commit created with "Release v0.2.0", tag pushed to GitHub origin, marketplace cache + installed_plugins.json synced.

- [ ] **Step 2: Verify tag**

```bash
git tag --list | grep v0.2.0       # exists
git ls-remote origin refs/tags/v0.2.0    # exists on remote
```

- [ ] **Step 3: Draft release notes**

In `gh release create` or via the GitHub web UI, post release notes:

```markdown
# v0.2.0 — Problem-first abstraction

## Breaking changes

- v0.1.x workspaces are not compatible. Delete `.humanpowers/` and re-init with `/humanpowers`.
- `scaffold` skill removed; dispatcher creates the workspace skeleton automatically.
- state.json schema changed: dropped `project` and `tfs_brainstormed`; added `target_repo` and `workspace_kind`.

## What's new

- Single entry: `/humanpowers` works in any cwd context (in-repo or external)
- Problem-first workflow: brainstorm produces `problem.md`, drives TF decomposition
- 18 skills (down from 19)
- Internal "boss" vocabulary replaced with "developer" across all user-facing content

## Migration

Old workspaces are not auto-migrated. The dispatcher fails fast with a clear instruction. Re-running `/humanpowers` in any directory creates a fresh v0.2 workspace.
```

- [ ] **Step 4: Reload plugin in Claude Code**

```
/reload-plugins
```

Verify the dispatcher behaves per v0.2 in the user's actual environment.

---

## Self-review checklist (run after writing this plan)

Spec coverage:

- [x] S2 Core Invariant → reflected in Tasks 3, 4 (problem.md, TF decomposition, per-TF loop)
- [x] S3 Workspace location + structure → Tasks 1, 3, 12
- [x] S3.4 state.json schema → Task 1
- [x] S3.5 gitignore → Task 12
- [x] S4 Dispatcher behavior + routing + Subcommands + responsibility split → Task 3
- [x] S5 Skills modified (3) → Tasks 3, 4, 9
- [x] S5 Skill deleted (scaffold) → Task 7
- [x] S5 Other skills' state-ref updates → Tasks 5, 6
- [x] S6 Cleanup orphans → Task 8
- [x] S6 Cleanup date-stamped filenames → Task 11
- [x] S6 Cleanup boss vocab → Tasks 3-9 inline + Task 10 sweep
- [x] S7 Migration hard-cutover error → Task 1 (check-state.sh) + Task 3 (dispatcher Step 3)
- [x] S7 Versioning policy → Task 14 (no version strings in body) + Task 16 (publish bumps)
- [x] S8/S9 Out-of-scope / Out-of-workflow → Task 9 (using-humanpowers documents this)
- [x] Manual E2E → Task 15
- [x] Release → Task 16

Placeholder scan: no TODO / TBD / "implement later" / "similar to Task N" patterns. Each task has explicit file paths, full content where new, and exact verify commands.

Type consistency: phase values (`""`, `problem-defined`, `quiz-done`, `planned`, `built`, `verified`, `aborted`) consistent across Tasks 1, 3, 4, 5, 6. Field names (`target_repo`, `workspace_kind`, `tfs_total`, `tfs_quiz_done`, `tfs_built`, `tfs_verified`) consistent across Tasks 1, 3, 5, 6.

Scope: single design pass. No sub-project decomposition needed.
