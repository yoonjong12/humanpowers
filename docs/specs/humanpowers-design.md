# humanpowers Design

## Goal

Design-first AI-assisted development. Generalizes vocabulary, commit policy, and skill surface so the workflow is transferable to any developer (not just internal users) and any unit of work (greenfield or adapter, single feature or larger).

## Core Invariant

The developer's articulated problem definition is load-bearing. The agent + superpowers discipline + humanpowers-specific augmentation (per-task quiz, per-task plan, per-task verify, cross-task cascade) is the executor.

Three things are essential, in this order:

1. **Problem definition** — what the developer is trying to solve. Output of brainstorming, stored as `problem.md`.
2. **Task decomposition** — atomic units derived from the problem. Each task lists its files (new or existing), action_type, dependencies, and task-local NFR. Stored as `tasks.md`.
3. **Per-task loop** — quiz round 1 (mandatory) → optional quiz round 2 → plan → operate → verify, identical regardless of greenfield or adapter.

## Workspace

### Privacy model

The entire `.humanpowers/` workspace is local-only. The repo's root `.gitignore` excludes it. Working artifacts (problem.md, tasks.md, per-task quiz / plan / verify, scratchpads) live on the developer's machine and never enter the PR or main branch.

The decision artifact is created at the `finish` phase as `docs/decisions/<slug>.md` and committed. This file is the single durable record of the design — its rationale, key decisions, and verify outcomes — without exposing personal working memos.

### Location

Determined by cwd context, unchanged from prior version:

- **cwd inside a git repo** → `<repo-root>/.humanpowers/`. workspace_kind = `in-repo`. target_repo = repo root.
- **cwd outside a git repo** → `<cwd>/.humanpowers/`. workspace_kind = `external`. target_repo = null until operate phase.
- **`.humanpowers/state.json` found upward from cwd** → resume that session.

### Structure

```
.humanpowers/
├── state.json           # phase, target_repo, workspace_kind, task counts
├── problem.md           # problem definition (with Project invariants section)
├── tasks.md             # task list with action_type, depends_on, task-local NFR
└── tasks/
    └── {id}/            # numeric ID — 1, 2, 3 …
        ├── round1.md    # mandatory quiz (agent-led)
        ├── round2.md    # optional quiz (developer-led)
        ├── plan.md      # implementation plan
        └── verify.md    # verification log
```

The `views/` auto-rendered matrices and `shelves/` rolling scratchpads from prior versions are removed. `views/` were never reviewed in practice; `shelves/` are made redundant by structured artifacts (state.json + per-task files + git log) and would require a hook to maintain.

### state.json schema

```json
{
  "phase": "problem-defined | quiz-done | planned | built | verified | aborted",
  "target_repo": "/abs/path or null",
  "workspace_kind": "in-repo | external",
  "tasks_total": 0,
  "tasks_quiz_done": 0,
  "tasks_built": 0,
  "tasks_verified": 0
}
```

No schema_version field. Compatibility checked by required-field presence; missing required field → dispatcher fails fast with re-init instruction.

### Gitignore policy

The repo's `.gitignore` excludes the entire `.humanpowers/` directory. There is no partial commit. `state.json`, `problem.md`, `tasks.md`, and per-task files all stay local.

## Commit policy

### Working phase

`.humanpowers/` is local. Code changes that the developer makes during the operate phase commit as normal — the implementation goes onto the feature branch via the developer's regular git workflow (independent of humanpowers).

### Finish phase

When all tasks reach `verified` and the developer runs `/humanpowers continue` or `/humanpowers review`, the dispatcher hands off to `humanpowers:finishing-a-development-branch`. That skill:

1. Reads `problem.md`, `tasks.md`, and per-task `verify.md` files.
2. Asks the developer for a short slug (e.g., `pcr-curator-review-injection`).
3. Writes `docs/decisions/<slug>.md` using the ADR template below.
4. Adds and commits the ADR file (the only artifact added by humanpowers to the repo).
5. Optionally prompts for version bump and release if the project uses semver.

### ADR template

```markdown
# <feature title>

## Status

Accepted (or: Superseded by `docs/decisions/<other>.md`)

## Problem

<one-paragraph summary derived from problem.md>

## Project invariants

- <each invariant as a bullet>

## Decisions

For each task, summarize the key decisions made during quiz and plan. One sentence per task is enough; reference the file paths the task touched.

## Alternatives considered

- <alternatives surfaced during brainstorming or quiz round 2>

## Consequences

- <what changed in the repo, what is now possible, what new constraints>

## Verify outcomes

For each task, one line on what was verified and how (test pass, demo signoff, etc.).
```

## Dispatcher

Behavior identical to prior version with field renames (`tfs_*` → `tasks_*`) and the new commit policy reflected in the workspace creation step.

`/humanpowers` runs:

1. Search upward from cwd for `.humanpowers/state.json`.
2. If found → validate schema with `scripts/check-state.sh`, route by phase.
3. If not found → determine workspace location, create `.humanpowers/` skeleton (mkdir + state.json), hand off to brainstorming.

### Phase routing

| phase | Next skill |
|-------|-----------|
| `""` (empty) | brainstorming |
| `problem-defined` | quiz |
| `quiz-done` | writing-plans |
| `planned` | operate (per remaining task; supports `--batch` for multi-task) |
| `built` | verification-before-completion |
| `verified` (some tasks) | review or operate (next task) |
| `verified` (all tasks) | finishing-a-development-branch |

### Subcommands

`/humanpowers continue | jump <phase> | operate <task-id> | review | abort`

Same semantics as prior version. `operate <task-id>` works on a single task; `operate --batch` works on all remaining unbuilt tasks. The plain `continue` form auto-selects per the routing table.

### Responsibility split

- **Dispatcher** owns workspace structure (creating `.humanpowers/`, state.json, deciding workspace_kind).
- **Brainstorming** owns problem definition (writing `problem.md` with the Project invariants section, transitioning phase).
- **Quiz** owns per-task expected behavior (writing `round1.md` mandatory, `round2.md` optional).
- **Writing-plans** owns per-task implementation plan (writing `plan.md`, including the depends_on graph in `tasks.md`).
- **Operate** owns implementation. Per-task by default; `--batch` mode for multiple tasks at once.
- **Verification-before-completion** owns per-task acceptance.
- **Review** owns cross-task cascade decisions.
- **Finishing-a-development-branch** owns ADR digest + release.

## Skills

Total: 17 (down from 18 in prior version). `executing-plans` is removed; its batch mode is absorbed into `operate`.

### humanpowers-specific (5)

`quiz`, `writing-plans`, `operate`, `verification-before-completion`, `review`. All updated for v0.3 vocabulary and the merged batch mode.

### Pipeline entry/exit (4)

`humanpowers` (dispatcher), `brainstorming`, `using-humanpowers`, `finishing-a-development-branch`. The finish skill now writes the ADR digest.

### Generic superpowers-inherited discipline (7)

`systematic-debugging`, `test-driven-development`, `requesting-code-review`, `receiving-code-review`, `using-git-worktrees`, `writing-skills`, `dispatching-parallel-agents`. Unchanged in behavior; vocabulary swept (e.g., "TF" → "task").

### Subagent wrapper (1)

`subagent-driven-development`. Used by `writing-plans` and (optionally) by `operate` for parallel-eligible tasks.

### Removed

- `executing-plans` — merged into `operate` with `--batch`.

## Vocabulary

The plugin replaces internal abbreviations and persona slang with full, agreed-upon words. Indexing uses plain numbers; communication uses agreed terms.

| Replaced | New |
|----------|-----|
| TF (Task Force) | task |
| TF-{id} | task {id} (in references); plain `{id}` in paths |
| TF-CC | cross-cutting task |
| AUQ | AskUserQuestion (Claude Code tool name, written out) |
| D1 (mandatory quiz round) | round 1 (agent-led) |
| D2 (optional quiz round) | round 2 (developer-led) |
| SDD | subagent-driven development |
| Boss (persona) | developer |
| Boss invariant | project invariant |
| Layer 0 | project invariants |
| Layer 1 (NFR) | task-local NFR |
| WS (in prose) | workspace (`WS` retained as a shell variable) |
| CSO | Claude Search Optimization |
| `tfs.md` | `tasks.md` |
| `tfs/TF-{id}/` | `tasks/{id}/` |
| `response-d1-*.md` | `round1.md` (or `response-round1-*.md` for templates) |
| `response-d2-*.md` | `round2.md` (or `response-round2-*.md` for templates) |

Industry-standard abbreviations are kept: TDD, NFR, SSOT, RACI, HITL, YAGNI, DRY, VCS, MCP, LLM, API, UI, data, infra. The "Layer 1-4" terminology in `systematic-debugging/defense-in-depth.md` refers to defense-architecture layers (industry usage) and is unrelated to the NFR layer terminology being retired.

## Hooks

The plugin no longer ships any hooks. Earlier versions had a `PostToolUse` hook on Edit/Write that truncated `.humanpowers/shelves/` files. With shelves removed, the hook is unnecessary.

`hooks/hooks.json` and `scripts/shelf-truncate.sh` are deleted in this design pass. Future hook needs (e.g., automatic phase validation, ADR-required gating) can be added if real friction emerges, but the current design has no candidate that justifies the maintenance overhead.

## Cleanup tasks

This design pass requires the following cleanup. All are mechanical once vocabulary is agreed.

- Vocabulary sweep across all `skills/`, `references/`, `README.md`, manifests, and scripts. Excludes `docs/specs/` and `docs/plans/legacy/` (frozen historical records).
- Filename renames: `tfs.md` → `tasks.md`, `tfs/TF-{id}/` → `tasks/{id}/`, `response-d{1,2}-*` → `response-round{1,2}-*` or `round{1,2}.md`.
- Skill removals and merges per Skills section.
- Hook and shelf removal per Hooks section.
- `views/` directory removal (no longer auto-rendered).
- `.gitignore` simplification: replace partial-commit rules with `.humanpowers/` only.
- The 4-file "Boss invariants / Layer 0" leak found during audit (skills/review/SKILL.md, skills/operate/SKILL.md, skills/brainstorming/SKILL.md, references/templates/critique-axes.md) is subsumed by the vocabulary sweep.

## Migration

Hard cutover. No backward compatibility for v0.2 workspaces.

If `.humanpowers/state.json` from a prior version is found (with `tfs_*` fields or no `target_repo` field), the dispatcher errors with: "Workspace from a prior plugin version detected. Delete `.humanpowers/` and re-init with `/humanpowers`."

The check-state.sh script enforces this via required-field presence. v0.3 fields: `phase`, `target_repo`, `workspace_kind`, `tasks_total`, `tasks_quiz_done`, `tasks_built`, `tasks_verified`.

Versioning is kept only where required by external systems: `plugin.json` `version`, git tags, and release notes. No version strings in code, doc bodies, or filenames.

## Out of scope

- **Vibe coding** (no design phase, free exploration). Use superpowers skills directly without invoking `/humanpowers`.
- **Pure debugging or pure code review** with no design phase. Use `superpowers:systematic-debugging` or `superpowers:requesting-code-review` directly.
- **Multi-developer concurrent sessions** on the same workspace. Single-developer-per-workspace assumed.
- **Cross-repo tasks** (a single task spanning multiple repos). One workspace per repo.
- **Automatic raw-artifact backup** (e.g., to a personal repo or cloud). The privacy model assumes raw artifacts are local-only and the developer accepts that they vanish if the machine is lost. The ADR digest is the only durable record.

## Out of workflow

The dispatcher provides one canonical flow. For work that does not fit (single-line config edits, emergency hotfixes), the developer invokes the relevant skill directly without going through `/humanpowers`. humanpowers does not block or interpose; it simply does not start.
