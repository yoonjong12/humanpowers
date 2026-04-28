# humanpowers

> Forked from [superpowers](https://github.com/obra/superpowers) (MIT, © 2025 Jesse Vincent). humanpowers extends the design with boss-articulation enforcement, TF (Task Force) model, matrix views, and Quiz module.

## Identity

```
superpowers = AI 가 도와줌 (인간 부담 ↓)
humanpowers = 인간이 active 참여 강제 (인간 부담 ↑, 결과 정확 ↑)
```

## Goal

Force lazy boss to actively participate in design + verification + acceptance, preventing intent/implementation drift.

## Installation

Inside Claude Code:

```
/plugin marketplace add yoonjong12/humanpowers
/plugin install humanpowers@humanpowers-marketplace
```

### Update

```
/plugin update humanpowers@humanpowers-marketplace
```

### Uninstall

```
/plugin uninstall humanpowers@humanpowers-marketplace
/plugin marketplace remove humanpowers-marketplace
```

### Local development install (from cloned repo)

```bash
git clone https://github.com/yoonjong12/humanpowers ~/.local/share/humanpowers
```

```
/plugin marketplace add ~/.local/share/humanpowers
/plugin install humanpowers@humanpowers-marketplace
```

To pull updates locally:

```bash
git -C ~/.local/share/humanpowers pull
```

```
/plugin update humanpowers@humanpowers-marketplace
```

## Quick start

After install, restart Claude Code session, then:

```
/humanpowers
```

Single entry point. Auto-detects workspace state:

- No workspace → invokes `humanpowers:scaffold` to create `~/humanpowers/{project-name}/`
- Workspace exists → routes to current phase (brainstorm / quiz / writing-plans / operate / verification / review / finishing)

Workspace lives at `~/humanpowers/{project-name}/`, separate from this plugin code.

## Boss override commands

| Command | Action |
|---------|--------|
| `/humanpowers` | resume current phase (auto-route) |
| `/humanpowers continue` | same as above |
| `/humanpowers jump {phase}` | force jump (warns if skipping) |
| `/humanpowers operate {TF-id}` | run as TF Lead for one TF |
| `/humanpowers review` | aggregate state + cascade decisions |
| `/humanpowers abort` | mark workspace aborted |

## Phases

- **Phase 1 (current)**: 14 fork skills + 4 new (quiz / scaffold / operate / review) + dispatcher + Quiz module + matrix views + workspace scaffolding + shelf-truncate hook.
- **Phase 2 (future)**: Auto signaling via SubagentStop hook + additionalContext.
- **Phase 3 (deferred)**: MCP server for true sync agent ↔ agent.

See `docs/specs/` for full design.

## License

MIT. See LICENSE.
