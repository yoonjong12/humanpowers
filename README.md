# humanpowers

> Forked from [superpowers](https://github.com/obra/superpowers) (MIT, © 2025 Jesse Vincent). humanpowers extends the design with boss-articulation enforcement, TF (Task Force) model, matrix views, and Quiz module.

## Identity

```
superpowers = AI 가 도와줌 (인간 부담 ↓)
humanpowers = 인간이 active 참여 강제 (인간 부담 ↑, 결과 정확 ↑)
```

## Goal

Force lazy boss to actively participate in design + verification + acceptance, preventing intent/implementation drift.

## Quick start

```
$ /humanpowers
```

Single entry point auto-routes by workspace state. See `docs/specs/` for full design.

## Phases

- **Phase 1 (current)**: 14 fork skills + 4 new (quiz/scaffold/operate/review) + dispatcher + Quiz module + matrix views.
- **Phase 2 (future)**: Auto signaling via SubagentStop hook + additionalContext.
- **Phase 3 (deferred)**: MCP server for true sync agent ↔ agent.

## License

MIT. See LICENSE.
