# humanpowers

> Developer's design = load-bearing element. Agent = bounded executor.
> Inspired by [superpowers](https://github.com/obra/superpowers).

## What

Developer articulates intent first. Agent executes within that boundary.

- **superpowers**: AI does more, dev does less.
- **humanpowers**: dev designs actively, agent held to written spec.

Output predictability = f(developer design effort), not agent cleverness.

## When

- Need design phase surfacing ambiguity before code.
- Per-task specs doubling as test specs.
- Explicit gates: design → build → verify, dev signs off each.

Well-understood fast tasks → plain superpowers or no plugin.

## Install

```
/plugin marketplace add yoonjong12/humanpowers
/plugin install humanpowers@humanpowers-marketplace
```

## Prerequisites

**Claude Code** required.

**Node.js** optional — visual companion only (browser mockups/diagrams).

| OS | Install |
|----|---------|
| macOS | `brew install node` |
| Windows | `winget install OpenJS.NodeJS` |
| Linux | `sudo apt install nodejs` / `dnf` / `pacman` |

## Quick start

```
/humanpowers
```

- No workspace → creates `.humanpowers/` (gitignored, local only) at repo root or cwd. Starts brainstorming.
- Workspace exists → resumes current phase.

## Concepts

| Concept | Meaning |
|---------|---------|
| **Workspace** | `.humanpowers/` dir holding `problem.md`, `tasks.md`, per-task artifacts. Repo root (in-repo) or cwd (external). |
| **Privacy** | `.humanpowers/` gitignored. Only `docs/decisions/<slug>.md` committed. |
| **Task** | Atomic work slice: who, what, why, verify-how, NFRs. Has `action_type` + `depends_on` graph. |
| **Quiz** | Required step between brainstorm and plan. Agent drills dev on vague terms, edges, thresholds. Signed output = test spec. |
| **Dispatcher** | Single `/humanpowers` entry → auto-routes by workspace state. |

## Workflow

```
brainstorm → quiz → plan → operate → verify → review → finish
```

| Phase | Does |
|-------|------|
| brainstorm | Articulate problem, decompose into tasks |
| quiz | Per-task elicitation → test spec |
| plan | Task-by-task plan + pre-build gate |
| operate | Implement (TDD); `--batch` for remaining tasks |
| verify | Dev-watched demo per task, signed acceptance |
| review | Aggregate state, cascade decisions |
| finish | Write ADR digest, commit, optionally bump version |

Manual control:

```
/humanpowers-help                 # show command + phase reference
/humanpowers continue            # resume current phase
/humanpowers jump <phase>        # skip ahead (warns if skipping a gate)
/humanpowers operate <task-id>   # work on one specific task
/humanpowers operate --batch     # work on all remaining unbuilt tasks
/humanpowers review              # project-level review
/humanpowers abort               # mark workspace aborted
```

## Docs

- `docs/specs/` — design specs.
- `docs/plans/` — implementation breakdown.
- `docs/decisions/` — ADR digests (finish phase).

## License

MIT
