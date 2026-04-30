# humanpowers

> A Claude Code plugin where the developer's own design work is the load-bearing element of AI-assisted development.
> Inspired by [superpowers](https://github.com/obra/superpowers).

## What it does

humanpowers does not replace your design work — it **structures it**. The plugin treats the developer's articulated intent as the load-bearing element of the workflow, and the agent as a structured executor bounded by that intent.

The contrast with a passive AI workflow:

- **superpowers**: AI does more, developer does less.
- **humanpowers**: the developer's own design power is exercised actively, and the agent is held to what the developer wrote down.

The result is a workflow where output predictability is a function of how much the developer engaged at the design phase — not of how clever the agent is at guessing.

## When to use it

Use humanpowers when you need:

- A design phase that surfaces ambiguity before code is written.
- Per-task requirement specs that double as test specs.
- Explicit gates between design → build → verification, with the developer signing off at each transition.

If you want the agent to move fast on a well-understood task, plain superpowers (or no plugin at all) is the better fit.

## Installation

Inside Claude Code:

```
/plugin marketplace add yoonjong12/humanpowers
/plugin install humanpowers@humanpowers-marketplace
```

## Prerequisites

**Claude Code** is required (the only hard dependency).

**Node.js** is optional — needed only for the visual companion feature in brainstorming (mockups and diagrams in your browser). The rest of the workflow works without it.

| OS | Install |
|----|---------|
| macOS | `brew install node` |
| Windows | `winget install OpenJS.NodeJS` |
| Linux | `sudo apt install nodejs` / `sudo dnf install nodejs` / `sudo pacman -S nodejs` |

## Quick start

After install, restart the session, then in any directory:

```
/humanpowers
```

The dispatcher detects whether a workspace exists at or above cwd and routes accordingly:

- No workspace → creates `.humanpowers/` (gitignored — local only) at the appropriate location (repo root if cwd is inside a git repo, else cwd) and starts brainstorming the problem.
- Workspace exists → resumes the current phase (brainstorm / quiz / plan / operate / verify / review / finish).

## Core concepts

| Concept | What it means |
|---------|---------------|
| **Workspace** | A `.humanpowers/` directory holding `problem.md`, `tasks.md`, and per-task artifacts. Lives in your repo root (in-repo mode) or cwd (external mode), determined automatically from cwd context. |
| **Privacy** | The entire `.humanpowers/` directory is gitignored. Working artifacts stay on the developer's machine. The decision digest at `docs/decisions/<slug>.md` is the only artifact committed to the repo. |
| **Task** | An atomic slice of work with five fields: who, what, why, how to verify, task-local non-functional requirements. Tasks have an `action_type` (ui / api / data / infra / cross-cutting) and a `depends_on` graph. |
| **Quiz** | A required step between brainstorming and planning. The agent drills the developer per task on vague terms, edge cases, and quantitative thresholds, one question at a time. The signed-off output is the test spec. |
| **Dispatcher** | A single entry point (`/humanpowers`) that auto-routes to the next phase based on workspace state. |

## Workflow

```
brainstorm  →  quiz  →  plan  →  operate  →  verify  →  review  →  finish
    │           │        │         │           │          │           │
    │           │        │         │           │          │           └─ write docs/decisions/<slug>.md ADR digest, commit, optionally bump version
    │           │        │         │           │          └─ aggregate state + cascade decisions across tasks
    │           │        │         │           └─ developer-watched demo per task, signed acceptance
    │           │        │         └─ implement per-task plan (TDD); --batch iterates remaining unbuilt tasks
    │           │        └─ task-by-task plan with explicit pre-build gate
    │           └─ per-task, per-question elicitation; output is the task's test spec
    └─ articulate the problem (problem.md) and decompose into tasks
```

Each phase has a corresponding skill; the dispatcher invokes the right one. The developer can take manual control at any point:

```
/humanpowers continue            # resume current phase
/humanpowers jump <phase>        # skip ahead (warns if skipping a gate)
/humanpowers operate <task-id>   # work on one specific task
/humanpowers operate --batch     # work on all remaining unbuilt tasks
/humanpowers review              # project-level review
/humanpowers abort               # mark workspace aborted
```

## Documentation

- `docs/specs/` — design specifications.
- `docs/plans/` — implementation breakdown.
- `docs/decisions/` — ADR digests written by the finish phase.

## License

MIT. See LICENSE.
