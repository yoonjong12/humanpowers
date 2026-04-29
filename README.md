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
- Per-unit requirement specs that double as test specs.
- Explicit gates between design → build → verification, with the developer signing off at each transition.

If you want the agent to move fast on a well-understood task, plain superpowers (or no plugin at all) is the better fit.

## Installation

Inside Claude Code:

```
/plugin marketplace add yoonjong12/humanpowers
/plugin install humanpowers@humanpowers-marketplace
```

## Quick start

After install, restart the session, then in any directory:

```
/humanpowers
```

The dispatcher detects whether a workspace exists at or above cwd and routes accordingly:

- No workspace → creates `.humanpowers/` at the appropriate location (repo root if cwd is inside a git repo, else cwd) and starts brainstorming the problem.
- Workspace exists → resumes the current phase (brainstorm / quiz / plan / operate / verify / review / finish).

## Core concepts

| Concept | What it means |
|---------|---------------|
| **Workspace** | A `.humanpowers/` directory holding `problem.md`, `tfs.md`, and per-TF artifacts. Lives in your repo root (in-repo mode) or cwd (external mode), determined automatically from cwd context. |
| **Unit (TF)** | An atomic slice of work with five fields: who, what, why, how to verify, local non-functional requirements. Units have an `action_type` (ui / api / data / infra / cross-cutting) and a `depends_on` graph. |
| **Views** | Auto-rendered matrices over the unit registry — concern × action_type, units × fields, units × stage. Read-only; regenerate from the registry. |
| **Quiz** | A required step between brainstorming and planning. The agent drills the developer per unit on vague terms, edge cases, and quantitative thresholds, one question at a time. The signed-off output is the test spec. |
| **Dispatcher** | A single entry point (`/humanpowers`) that auto-routes to the next phase based on workspace state. |

## Workflow

```
brainstorm  →  quiz  →  plan  →  operate  →  verify  →  review  →  finish
    │           │        │         │           │          │           │
    │           │        │         │           │          │           └─ developer signs off, version bump, optional release
    │           │        │         │           │          └─ aggregate state + cascade decisions across units
    │           │        │         │           └─ developer-watched demo per unit, signed acceptance
    │           │        │         └─ implement per-unit plan (TDD)
    │           │        └─ unit-by-unit plan with explicit pre-build gate
    │           └─ per-unit, per-question elicitation; output is the unit's test spec
    └─ articulate the problem (problem.md) and decompose into units
```

Each phase has a corresponding skill; the dispatcher invokes the right one. The developer can take manual control at any point:

```
/humanpowers continue            # resume current phase
/humanpowers jump <phase>        # skip ahead (warns if skipping a gate)
/humanpowers operate <unit-id>   # work on one specific unit
/humanpowers review              # project-level review
/humanpowers abort               # mark workspace aborted
```

## Documentation

- `docs/specs/` — design specifications.
- `docs/plans/` — implementation breakdown.

## License

MIT. See LICENSE.
