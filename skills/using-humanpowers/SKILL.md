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
