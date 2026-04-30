# Examples — humanpowers Quiz

Generic illustrative examples in the v0.3 9-dimension matrix format. Use these to understand the pattern, then apply to your project's domain.

## Files

| File | Action type | Highlights |
|------|-------------|------------|
| `quiz-ui-example.md` | ui | layout / error display / a11y invariant / API failure handling |
| `quiz-api-example.md` | api | request shape / latency invariant / partial-update decision / 401 vs 404 trade-off |
| `quiz-data-example.md` | data | DAU definition / freshness invariant / UTC-vs-local-day decision |
| `quiz-infra-example.md` | infra | replica purpose / replication lag SLO / sync-vs-async decision |
| `quiz-crosscut-example.md` | cross-cutting | LLM determinism / invariant promotion / cache-and-validate flow |
| `round2-discussion-example.md` | — | round 2 developer-vs-agent discrepancy → discussion → cascade |

## How to use

When the agent generates a new `tasks/{id}/round1.md`, it consults the appropriate example for cell patterns and Q-body shape. The developer can also use these to see what a locked quiz looks like before answering one.

These are NOT prescriptive — your domain may need different cell patterns. Adapt. The activation log + cite-only rule (see `references/quiz-guidelines.md`) is what stays constant.
