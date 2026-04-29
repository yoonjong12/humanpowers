# Task {X} Round 2 Discussion — Cascade Refinement (EXAMPLE)

> Linked: response-round2-developer.md / response-round2-agent.md

## Q5: Search index infrastructure

**Developer round 2 answer**:
- Postgres tsvector + GIN index
- 한글 형태소 분석기 = mecab-ko

**Agent answer**:
- ElasticSearch separate cluster
- 한글 = nori analyzer

**Difference**:
- Field: search infrastructure
- Developer: Postgres tsvector (single DB)
- Agent: ES separate cluster

**Agent reasoning**: "검색 latency / 확장성. 1만 SKU+ 시 Postgres FTS 가 GIN 인덱스로도 부하 큼."

**Decision**: 1. 논의 필요

---

## 논의

**Developer 추가 의견**:
- ES = overkill at current scale.
- Concurrent users ≤ 100 / SKU count ≤ 1000.
- Operational cost (cluster management, monitoring) too high for current value.
- Postgres tsvector benchmark on 10k rows showed <50ms p99 → sufficient.

**Agent 응답**:
- 동의. 현 규모에서 Postgres tsvector 충분.
- 단, 향후 SKU 1만 도달 시 재검토 trigger 필요 (problem.md invariant 추가 권장).

**Cascade 영향 범위**:
- [x] 해당 task expected-outputs 갱신 — Q5 lock with "Postgres tsvector + GIN, mecab-ko"
- [x] 해당 task 5필드 spec (tasks.md) 갱신 — `nfr_local: ["검색 latency p99 < 50ms"]`
- [x] problem.md 불변식 / 페르소나 갱신 — Add invariant: "검색 인프라 = Postgres-only. SKU > 10000 도달 시 재설계 trigger."
- [ ] 다른 task 영향 (flag only — developer 명시 invoke 필요)
  - Flagged: Task 2 상품 상세 (검색 결과 click) might share index — needs explicit re-quiz

**Final**: Postgres tsvector + GIN index + mecab-ko. Locked. problem.md version → v1.1.
