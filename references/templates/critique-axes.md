# Critique 4 Axes (Agent Internal Checklist)

Use this when reading developer's quiz answer. Check each axis. ANY hit = additional critique.

## Axis 1 — Vagueness (모호)

- 정량 부족 ("빠르다" / "5개")
- 주체 불명 ("사용자" — 누구?)
- 처리 방식 불명 ("에러" — 어떤 에러? 어떤 처리?)
- 경계 불명 ("많다" / "적다")

## Axis 2 — Consistency (일관성)

- TF spec NFR (Layer 1) 와 모순
- 다른 TF 답안 (다른 expected-outputs.md) 와 모순
- problem.md 불변식 (Layer 0) 위반

## Axis 3 — Completeness (완결성)

- Happy path 만? Error / edge / 0 / overflow / 동시성 / 권한 X 처리?
- Input variant (한글 / 영문 / 특수문자 / Emoji / 빈값)?
- Timeout / 네트워크 실패?
- Race condition / 동시 입력?

## Axis 4 — Specificity (구체성)

- 정의 부재 ("인기순" — 인기 정의?)
- Timezone / window 부재 ("30일" — KST? Rolling?)
- 동작 모호 ("더보기" — append vs 교체?)
- "권장" — 강제? 옵션? 둘 다?

## Termination rule

Critique ends when ALL 4 axes return 0 issues for the current Q.

## Anti-pattern

NEVER bulk-dump all axes' issues in one AUQ message ending "Thoughts?". One AUQ call per critique.
