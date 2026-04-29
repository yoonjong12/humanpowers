# humanpowers Design

## Goal

Generalize humanpowers from a scaffold-only framework into a problem-first, transferable framework that handles greenfield scaffolding, existing-codebase adaptation, and any other unit of work — without forcing the developer into a single shape of session.

## Core Invariant

The developer's articulated problem definition is load-bearing. The agent + superpowers discipline + humanpowers-specific augmentation (TF model, quiz, cascade, AUQ) is the executor.

Three things are essential, in this order:

1. **Problem definition** — what the developer is trying to solve. Output of brainstorming + quiz, stored as `problem.md`.
2. **TF decomposition** — atomic units derived from the problem. Each TF lists its files (new or existing), action_type, and dependencies. Stored as `tfs.md`.
3. **Per-TF loop** — quiz → plan → operate → verify, identical regardless of whether the TF creates new code or modifies existing code.

Mode-switching ("scaffold mode vs adapter mode") is rejected. The dispatcher treats new-vs-existing as a property of the workspace and the TF, not as a choice the user makes upfront.

## Workspace

### Location

Determined by cwd context, not by user prompt:

- **cwd is inside a git repo** → `<repo-root>/.humanpowers/`. workspace_kind = `in-repo`. target_repo = repo root.
- **cwd is outside a git repo** → `<cwd>/.humanpowers/`. workspace_kind = `external`. target_repo = null until operate phase decides.
- **`.humanpowers/state.json` found upward from cwd** → resume that session.

### Structure

```
.humanpowers/
├── state.json          # phase, target_repo, workspace_kind, TF counts
├── problem.md          # problem definition (brainstorm output)
├── tfs.md              # TF list with action_type / files / depends_on
├── tfs/
│   └── TF-NN/
│       ├── quiz.md     # signed-off expected-outputs (test spec)
│       ├── plan.md     # per-TF build plan
│       └── verify.md   # verification log
├── views/              # auto-rendered matrices
└── shelves/            # rolling 1-session scratchpads
```

### state.json schema

```json
{
  "phase": "problem-defined | quiz-done | planned | built | verified",
  "target_repo": "/abs/path or null",
  "workspace_kind": "in-repo | external",
  "tfs_total": 0,
  "tfs_quiz_done": 0,
  "tfs_built": 0,
  "tfs_verified": 0
}
```

No schema_version field. Compatibility checked by required-field presence; missing field → dispatcher errors with re-init instruction.

### Git-ignore policy (in-repo workspaces)

`.humanpowers/state.json` and `.humanpowers/shelves/` are git-ignored. `problem.md`, `tfs.md`, per-TF `quiz.md`, `plan.md`, `verify.md`, and `views/` are committed — they are the design artifact.

## Dispatcher

### Behavior

`/humanpowers` runs the following:

1. Search upward from cwd for `.humanpowers/state.json`.
2. If found → read `phase`, route to next skill.
3. If not found → determine workspace location (rules above), create empty `.humanpowers/state.json` skeleton, hand off to humanpowers:brainstorming.

### Phase routing

| phase | Next skill | Output |
|-------|-----------|--------|
| (empty) | brainstorming | `problem.md`, phase = `problem-defined` |
| `problem-defined` | quiz | per-TF `quiz.md`, phase = `quiz-done` (when all TFs quiz-done) |
| `quiz-done` | writing-plans | per-TF `plan.md`, phase = `planned` |
| `planned` | operate | per-TF code, phase = `built` (when all TFs built) |
| `built` | verification-before-completion | per-TF `verify.md`, phase = `verified` |
| `verified` | review or finishing-a-development-branch | cascade decisions / release |

### Subcommands

`/humanpowers continue | jump <phase> | operate <TF-id> | review | abort`

`continue` resumes auto-routing. `jump` warns when skipping a gate. `operate <TF-id>` works on a single TF regardless of phase. `review` enters cross-TF review. `abort` marks workspace aborted.

### Responsibility split

- **dispatcher** owns workspace structure (creating `.humanpowers/`, state.json, deciding workspace_kind).
- **brainstorming** owns problem definition (writing `problem.md`, transitioning phase).

This separates concerns: dispatcher knows about filesystem layout, brainstorming knows about problem elicitation.

## Skills

Total: 18 skills (down from 19 in v0.1.x).

### humanpowers-specific (5)

`quiz`, `writing-plans`, `operate`, `verification-before-completion`, `review`. Behavior unchanged from v0.1.x.

### superpowers-inherited generic discipline (8)

`systematic-debugging`, `test-driven-development`, `requesting-code-review`, `receiving-code-review`, `using-git-worktrees`, `writing-skills`, `subagent-driven-development`, `dispatching-parallel-agents`. Unchanged.

### Alternate flow (1)

`executing-plans` — batch alternative to per-TF operate. Unchanged.

### Finish (1)

`finishing-a-development-branch`. Unchanged.

### Modified (3)

- **`humanpowers` (dispatcher)** — context detection (in-repo vs external), workspace skeleton creation, simplified phase routing. No scaffold branch.
- **`brainstorming`** — when invoked with empty state.json, produces `problem.md` and transitions phase to `problem-defined`. Inherits superpowers brainstorming discipline.
- **`using-humanpowers`** — docs reflect problem-first abstraction, scaffold-free entry, Subcommands vocabulary.

### Deleted (1)

- **`scaffold`** — absorbed into dispatcher's workspace-creation step.

## Cleanup

The following are removed in this design pass:

- **scaffold skill** — replaced by dispatcher inline logic.
- **Orphan superpowers-internal skill-development artifacts** in `skills/systematic-debugging/`: `CREATION-LOG.md`, `test-academic.md`, `test-pressure-1.md`, `test-pressure-2.md`, `test-pressure-3.md`. Zero references; pure dev artifacts.
- **Date-stamped doc filenames** — `docs/specs/`, `docs/plans/`, `docs/E2E-self-test-*` use topic-only names. Git history preserves chronology.
- **"boss" vocabulary** — replaced with "developer" or "user" across skills, README, and docs. Reason: "boss" was internal humanpowers slang from the original scaffold-centric framing; the generalized abstraction is developer-facing.

The following were initially flagged but are kept after reference-graph verification:

- `writing-skills/anthropic-best-practices.md`, `persuasion-principles.md`, `testing-skills-with-subagents.md` — JIT-loaded by `writing-skills/SKILL.md`.
- `brainstorming/visual-companion.md` — JIT-loaded by `brainstorming/SKILL.md`.
- `systematic-debugging/root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md` — JIT-loaded by `systematic-debugging/SKILL.md`.
- `dispatching-parallel-agents/SKILL.md` — referenced by `writing-plans/SKILL.md` for parallel-eligible TFs.

## Migration

Hard cutover. No backward compatibility for v0.1.x workspaces.

If an old workspace is found (state.json missing required fields `target_repo` or `workspace_kind`), the dispatcher fails fast with: "v0.1.x workspace detected. Delete `.humanpowers/` and re-init with `/humanpowers`."

Versioning is kept only where required by external systems: `plugin.json` `version`, git tags, and release notes. No version strings in code, doc bodies, or filenames.

## Out of Scope

This design does not address:

- **Vibe coding** (no design phase, free exploration). Users who want this should not invoke `/humanpowers`. The plugin's value proposition is design-first; bypassing the design phase would defeat its purpose.
- **Pure debugging or pure code review** with no design phase. Use superpowers' `systematic-debugging` or `requesting-code-review` skills directly. humanpowers does not wrap them.
- **Multi-developer concurrent sessions** on the same workspace. Single-developer-per-workspace assumed.
- **Cross-repo TFs** (a single TF spanning multiple repos). Each TF lives in one workspace; multi-repo work uses one workspace per repo with thread-style cross-references.

## Out of Workflow

The dispatcher provides one canonical flow (problem → quiz → plan → operate → verify → review → finish). For work that does not fit this shape (a single-line config edit, an emergency hotfix), the developer invokes the relevant skill directly without going through `/humanpowers`. humanpowers does not block or interpose; it simply does not start.
