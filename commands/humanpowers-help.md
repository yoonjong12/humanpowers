---
description: Show humanpowers commands, phases, and workspace reference
---

Print the following verbatim, then stop. Do not route to any phase or invoke any skill.

```
humanpowers — design-first AI-assisted development

Commands:
  /humanpowers                     start or resume (auto-routes by phase)
  /humanpowers continue            resume current phase
  /humanpowers jump <phase>        skip to phase (warns if skipping a gate)
  /humanpowers operate <task-id>   work on one specific task
  /humanpowers operate --batch     work on all remaining unbuilt tasks
  /humanpowers review              cross-task cascade review
  /humanpowers abort               mark workspace aborted
  /humanpowers-help                show this reference

Phases:
  brainstorm   Articulate problem, decompose into tasks        → problem.md
  quiz         Per-task elicitation → test spec                → tasks/{id}/round1.md
  plan         Task-by-task plan + pre-build gate              → tasks.md + tasks/{id}/plan.md
  operate      Implement per task (TDD); --batch for all       → code changes
  verify       Developer-watched demo, signed acceptance       → tasks/{id}/verify.md
  review       Aggregate state, cascade decisions              → review notes
  finish       Write ADR digest, commit, optionally bump       → docs/decisions/<slug>.md

Workspace:
  Location     .humanpowers/ at repo root (in-repo) or cwd (external)
  Privacy      entire .humanpowers/ gitignored; only docs/decisions/ committed
  State        .humanpowers/state.json tracks phase + progress
```
