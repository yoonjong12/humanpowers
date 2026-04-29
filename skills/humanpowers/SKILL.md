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
