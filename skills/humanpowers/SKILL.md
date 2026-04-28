---
name: humanpowers
description: Single entry point for humanpowers projects. Auto-detects current phase from .humanpowers/state.json and routes to brainstorming / quiz / writing-plans / operate (or executing-plans) / verification / review / finishing. Boss types `/humanpowers` and dispatcher figures out next step. Use this when boss says "I want to start" or "continue" or just types /humanpowers.
---

# humanpowers Dispatcher

## Behavior

Single entry to humanpowers workflow. Detects state, dispatches to appropriate skill.

## State detection

```bash
# Check if cwd is inside ~/humanpowers/{project}/
WS=""
if [[ "$(pwd)" == "$HOME/humanpowers/"* ]]; then
  WS=$(echo "$(pwd)" | sed -E "s|($HOME/humanpowers/[^/]+).*|\1|")
fi

# Or check if state.json exists in any cd-able subdir
if [ -z "$WS" ] && [ -f ./.humanpowers/state.json ]; then
  WS="$(pwd)"
fi
```

If no workspace → invoke humanpowers:scaffold (Step 1 below).

If workspace exists → read `state.json` field `phase` and dispatch (Step 2).

## Step 1: No workspace → scaffold

Output to Claude:
```
No humanpowers workspace detected.
Invoking humanpowers:scaffold to initialize a new project.
```

Hand off to humanpowers:scaffold.

## Step 2: Workspace exists → state echo + dispatch

Read `.humanpowers/state.json`:

```bash
PHASE=$(jq -r .phase ~/humanpowers/{project}/.humanpowers/state.json)
TFS_TOTAL=$(jq -r .tfs_total ...)
TFS_QUIZ_DONE=$(jq -r .tfs_quiz_done ...)
TFS_BUILT=$(jq -r .tfs_built ...)
TFS_VERIFIED=$(jq -r .tfs_verified ...)
```

Output state echo:
```
Currently in: ~/humanpowers/{project}/
Phase: {PHASE}
TFs: {VERIFIED}/{TOTAL} verified, {BUILT}/{TOTAL} built, {QUIZ_DONE}/{TOTAL} quiz-done
```

## Step 3: Phase routing

| phase | Next skill |
|-------|-----------|
| `brainstorm` | humanpowers:brainstorming |
| `brainstorm-done` | humanpowers:quiz |
| `quiz-done` | humanpowers:writing-plans |
| `designed` | humanpowers:operate per TF (or humanpowers:executing-plans for batch) |
| `built` | humanpowers:verification-before-completion |
| `verified` (some) | humanpowers:review or continue per TF |
| `verified` (all) | humanpowers:finishing-a-development-branch |

If user passed explicit phase arg (`/humanpowers quiz` etc.), override auto-routing.

## Step 4: Boss override commands

| Command | Action |
|---------|--------|
| `/humanpowers continue` | resume current phase |
| `/humanpowers jump {phase}` | force jump to phase (warn if skipping) |
| `/humanpowers operate {TF-id}` | invoke humanpowers:operate with TF-id |
| `/humanpowers review` | invoke humanpowers:review |
| `/humanpowers abort` | mark workspace as aborted in state.json + STOP |

## Step 5: Always state-echo before action

Before invoking next skill, show:
```
Currently: {phase}
Next: humanpowers:{skill}
Or override: /humanpowers continue | jump {phase} | operate {TF} | review | abort
```

Boss may interrupt to use override.

## Boundaries

- Don't auto-progress past phase boundaries without boss involvement.
- Don't skip quiz when going from brainstorm-done to writing-plans.
- Don't claim verified without verification skill.
