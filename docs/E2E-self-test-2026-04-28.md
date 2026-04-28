# Phase 1 E2E Self-Test — 2026-04-28

## Pass/Fail per skill

| Skill | Pass? | Notes |
|-------|-------|-------|
| dispatcher | ⏳ | Manual: `/humanpowers` from empty `~/humanpowers/` should invoke scaffold |
| scaffold | ⏳ | Manual: full tree under `~/humanpowers/{name}/` (boss.md, tfs.md, views/, tfs/, threads/, library/, .humanpowers/state.json) |
| brainstorming | ⏳ | Manual: 비서 persona refuses vague answers, produces 2-3 TFs |
| quiz | ⏳ | Manual: per-Q AUQ loop, no bulk dump, expected-outputs.md signed_off |
| writing-plans | ⏳ | Manual: per-TF build-plan.md, TDD format |
| verification-before-completion | ⏳ | Manual: boss demo signoff prompt, action_type-specific demo form |
| review | ⏳ | Manual: `/humanpowers review` — aggregate + 5 options |
| finishing-a-development-branch | ⏳ | Manual: final acceptance + version bump prompt |
| render-views.sh | ⏳ | Manual: 3 view files render correctly from tfs.md |
| **shelf-truncate.sh** | ✅ | Autonomous: 50→30 lines verified; kept last 30 (lines 21-50) |

## Autonomous validations completed

- Plugin scaffold (plugin.json, LICENSE, README, .gitignore) — Task 1
- 14 superpowers skills copied + sed-rebranded — Task 2
- 5 heavy/medium/light skill modifications — Tasks 3-10
- 4 NEW skills (quiz, scaffold, operate, review) — Tasks 11-14
- 1 light modification (writing-skills) — Task 15
- 5 templates + 6 examples — Tasks 16-17
- Dispatcher skill (skills/humanpowers/SKILL.md) — Task 18
- 4 scripts (check-state, update-state, render-views, shelf-truncate) with `chmod +x` + `bash -n` syntax check — Task 19
- Hooks config (`hooks/hooks.json`) JSON-validated — Task 20
- Stale-ref sweep — 4 files patched (`docs/superpowers/` paths replaced; dispatcher routing adds operate)
- shelf-truncate.sh hook end-to-end (50→30 truncation verified)

## Manual validations required

The following require live Claude Code session with user as boss:

1. **Plugin install**: `~/.claude/plugins/humanpowers/` (symlink or copy from `/Users/jay/code/user/humanpowers/`). User decision; may affect existing Claude Code config.
2. **Boss interaction flow**: scaffold → brainstorming → quiz → writing-plans → operate/executing-plans → verification → review → finishing
3. **AUQ behavior**: confirm one-question-at-a-time, no bulk dump
4. **Cascade behavior** (D2 optional): discrepancy → discussion → cascade scope (i)/(ii)/(iii) auto, (iv) flag-only
5. **Hook firing**: PostToolUse on Edit of `library/scratchpads/*.md` actually invokes shelf-truncate.sh during a real session

## Issues found

None during autonomous validation. Script logic for shelf-truncate.sh works as designed; sandbox false-positive on mktemp ruled out by re-run.

## Phase 1 Gate

- [ ] **PASS** — all skills work, ready for use (after manual E2E)
- [ ] **PARTIAL** — autonomous parts pass; manual run needed before declaring full pass
- [ ] **FAIL** — major rework needed

**Current state**: PARTIAL — autonomous parts ✅. Manual validation pending boss session.

## Next actions for boss

1. Decide install path (symlink vs copy vs marketplace).
2. Run `/humanpowers` flow on a generic test project (e.g., `selftest-todo`).
3. Update this doc with manual results per row.
4. Decide on `git tag v0.1.0` after manual pass.
