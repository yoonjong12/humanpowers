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
