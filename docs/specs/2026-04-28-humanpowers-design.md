# humanpowers Plugin — Design Spec v0.2

**Status**: SPEC (post-brainstorming, pre-implementation)
**Date**: 2026-04-28
**Author**: yoonjong (boss) + Claude Code (brainstorming session)
**License**: MIT (open as possible)
**Repo**: https://github.com/yoonjong12/humanpowers
**Local clone path**: `/Users/jay/code/user/humanpowers/`
**Upstream**: `github.com/obra/superpowers` (MIT, © 2025 Jesse Vincent) — Path B heavy fork (independent repo + content baseline + heavy modify + rebrand)

---

## 1. Identity

```
superpowers = AI 가 도와줌 (인간 부담 ↓)
humanpowers = 인간이 active 참여 강제 (인간 부담 ↑, 결과 정확 ↑)
```

**Naming**: 이름 자체가 차용 명시. `super` ↔ `human` 치환. 정체성 = "AI 가 알아서" 단계를 "보스 explicit confirm + articulation" 으로 전환.

**일관 원칙** (모든 fork skill 변경에 적용):
- "AI 가 알아서 진행" → "보스 explicit confirm 강제"
- "Implicit 합의" → "explicit demo / signoff"
- "코드 검증" → "결과 검증 (보스 가시성)"
- "Agent drafts, user nods" → "Boss articulates, agent critiques"

---

## 2. Goal

게으른 보스 (사용자) 를 **설계 + 검증 + 수락 단계 모두에서 강제 노동** 시켜, 보스 의도와 구현이 어긋날 가능성 사전 제거.

**가치 hierarchy**:
1. 보스↔비서 realtime brainstorm (코어)
2. Quiz 메커니즘 — 보스 articulation 강제 (차별 가치)
3. 검증 가능한 acceptance spec (산출)
4. TF 모듈 분해 + 진행 + 검증 (실행)
5. TF lead 페르소나 + 자동 signaling (Phase 2/3)

---

## 3. Fork Strategy — Level C (Full Fork) + Path B (Independent Repo)

### 3.1 Scope

`superpowers` 14 skill 콘텐츠 baseline 으로 사용. 추가 4 skill 신규 작성. **독립 git repo** (https://github.com/yoonjong12/humanpowers) — superpowers 와 git 관계 X.

**Path B 핵심**:
- 독립 repo (own commit history, own README, own LICENSE)
- 모든 명령어 = `/humanpowers:*` (superpowers prefix 종속 X)
- skill 이름 / 트리거 / cross-reference 전부 `humanpowers` 네임스페이스
- superpowers 텍스트 = baseline copy + heavy modify (LICENSE 의무 = MIT verbatim 복사 + README 1줄 attribution)

### 3.2 Skill 분류 + 수정 강도

| Skill | 수정 강도 | 변경 요약 |
|-------|---------|---------|
| `brainstorming` | Heavy | 비서 페르소나 + TF 추출 + matrix view + type-aware VERIFY + NFR 두 레이어 |
| `quiz` (NEW) | New | D1 mandatory + D2 optional 메커니즘. 4 axis critique. cascade 보강. |
| `writing-plans` | Heavy | TF 단위 plan + boss confirm gate + depends_on 기반 build 순서 |
| `executing-plans` | Medium | 체크포인트마다 보스 demo verification 강제 |
| `verification-before-completion` | Heavy | 코드 통과 → 보스 demo signoff. action_type 별 demo 형태 |
| `finishing-a-development-branch` | Medium | 보스 final acceptance + boss.md version bump |
| `subagent-driven-development` | Light | TF lead 패턴 가이드 |
| `dispatching-parallel-agents` | Light | TF-aware dispatch (depends_on graph 기반) |
| `test-driven-development` | As-is | 텍스트 그대로 fork |
| `using-git-worktrees` | As-is | 그대로 |
| `systematic-debugging` | As-is | 그대로 |
| `requesting-code-review` | As-is | 그대로 |
| `receiving-code-review` | As-is | 그대로 |
| `writing-skills` | Light | Triggers/text rebrand — humanpowers skill creation guide |
| `using-superpowers` | Rename + Meta | `using-humanpowers` 로 rename + 정체성 문구 갱신 |
| `scaffold` (NEW) | New | Workspace 트리 생성 |
| `operate` (NEW) | New | TF lead invocation 라우터 |
| `review` (NEW) | New | 보스 검증 + version bump |

### 3.3 LICENSE Attribution

- `LICENSE` = MIT verbatim 복사 (lines 1-21 from upstream).
- `README.md` 첫 단락:
  > Forked from [superpowers](https://github.com/obra/superpowers) (MIT, © 2025 Jesse Vincent). humanpowers extends the design with boss-articulation enforcement, TF model, and matrix views.

### 3.4 Upstream Sync

- 분기 1회 upstream changelog 검토.
- Major change = 수동 cherry-pick + humanpowers 수정 재적용.
- 발산 의도적 = sync 부담 감수. Upstream 가 모든 humanpowers 가치 흡수 시까지 fork 유지.

---

## 4. Workspace Model

> 두 종류 path 구분:
> - **Plugin code**: `/Users/jay/code/user/humanpowers/` (humanpowers 자체 소스)
> - **User project workspace**: `~/humanpowers/{project-name}/` (보스가 humanpowers 사용해 작업하는 각 프로젝트)

### 4.1 User project 위치

```
~/humanpowers/{project-name}/
```

`{project-name}` = brainstorming 시작 시 보스가 명명. snake_case 또는 kebab-case.

### 4.2 트리

```
~/humanpowers/{project-name}/
├── boss.md                       # Charter + 불변식 + 페르소나 (보스 단독 편집)
├── tfs.md                        # TF 5필드 SSOT (1 SSOT, 다중 view 도출 source)
├── views/
│   ├── macro.md                  # Concern × action_type 매트릭스 (자동 렌더)
│   ├── spec.md                   # TF × 5필드 (자동 렌더)
│   └── progress.md               # TF × stage (자동 렌더)
├── tfs/
│   └── {TF-id}/
│       ├── quiz.md               # Agent 작성 질문 only
│       ├── response-d1-boss.md   # 보스 D1 응답 (mandatory)
│       ├── response-d2-boss.md   # 보스 D2 자체 응답지 (optional)
│       ├── response-d2-agent.md  # Agent D2 본인 답
│       ├── discussion.md         # 불일치 Q 논의 로그
│       ├── expected-outputs.md   # signed_off 최종 spec (test 명세 source)
│       └── build-plan.md         # writing-plans 출력 (TF 단위)
├── threads/                      # Cross-TF 논의 (append-only)
│   └── {topic}.md
├── library/                      # 공유 reference + scratchpad
│   ├── INDEX.md
│   └── scratchpads/{lead-id}.md  # TF lead 누적 노트 (≤30줄, 자동 truncate)
└── .humanpowers/
    ├── state.json                # phase 추적 (brainstorm-done / design-done / ...)
    ├── version                   # boss.md version (예: v1.0)
    └── invocation-log.jsonl      # quiz turn count / 시간 가드
```

### 4.3 SSOT 원칙

- `tfs.md` = TF 정의의 단 하나 source.
- `views/*.md` = `tfs.md` 에서 자동 렌더 (`scripts/render-views.sh`).
- 보스가 view 수정 = 무시 (다음 렌더 시 덮어씀). 수정은 `tfs.md` 직접.

### 4.4 보스 가시성

- 모든 파일 = git-friendly markdown. 보스가 `cat` / 에디터로 직접 read.
- "Boss 가 코드 안 봄" = convention only (enforcement X). `tfs/{TF-id}/build-plan.md` 도 보스 read 가능. 명시 in `boss.md` Charter.

---

## 5. TF Data Model

### 5.1 5-Field Spec (`tfs.md` 행)

```yaml
- id: TF-1a
  name: 검색 UI
  concern: 검색→구매      # 보스 관심사 (행 그룹)
  action_type: ui         # ui | api | data | infra | cross-cutting
  who: 로그인된 회원
  what: 검색바 텍스트 입력 → 결과 list 노출
  why: 구매 시작점
  verify_form: gherkin    # ui = gherkin / api = curl / data = sql / infra = checklist / cross-cutting = composite
  nfr_local:
    - 응답 < 500ms
    - 검색어 trim + 소문자
  depends_on: []
  status: brainstorm-done | quiz-done | designed | built | verified
  mode: independent       # independent | facilitating | collaboration
```

### 5.2 NFR 두 레이어

- **Layer 0 (보스 불변식)**: `boss.md` 의 `## 핵심 불변식` 섹션. 4 카테고리 default = 보안 / 데이터 무결성 / 결정성 / 컴플라이언스.
- **Layer 1 (TF-local NFR)**: TF 5필드의 `nfr_local`.
- **Promote 룰**: 동일 NFR 가 **2 TF 이상**에 등장 시, agent 가 thread post 로 boss 에게 promote 제안. 보스 confirm = Layer 0 으로 이동.

### 5.3 Action Type ≠ 직책

- `ui` / `api` / `data` / `infra` / `cross-cutting` = **행위 분류**. 도메인 팀 X.
- TF lead = ad-hoc per TF. 같은 사람/agent 가 다른 TF 의 다른 action_type 도 lead 가능.

---

## 6. Matrix Views (3개, 자동 렌더)

### 6.1 Macro view (`views/macro.md`)

```markdown
| Concern | UI | API | Data | Infra |
|---------|-----|-----|------|-------|
| 검색→구매 | TF-1a | TF-1b, TF-3b | TF-3c | — |
| 결제 | TF-2a | TF-2b | TF-2c | — |
| 인프라 | — | — | — | TF-4 |
```

행 = boss concern, 열 = action_type, 셀 = TF reference. 보스 한눈 view.

### 6.2 Spec view (`views/spec.md`)

```markdown
| TF | WHO | WHAT | VERIFY | NFR-local | STATUS |
|-----|-----|------|--------|-----------|--------|
| TF-1a | 회원 | 검색 결과 list | Gherkin | <500ms | brainstorm-done |
| TF-1b | server | /search API | cURL | rate 5/min | quiz-done |
```

### 6.3 Progress view (`views/progress.md`)

```markdown
| TF | brainstorm | quiz | designed | built | verified |
|-----|-----------|------|---------|-------|----------|
| TF-1a | ✓ | ✓ | ✓ | — | — |
| TF-1b | ✓ | — | — | — | — |
```

### 6.4 Dependency 표현

`tfs.md` 의 `depends_on` 필드만 사용. 별도 매트릭스 X. 자동 Mermaid render (옵션) — 보스가 `/humanpowers view-deps` 호출 시.

---

## 7. Quiz Module

### 7.1 위치

```
brainstorming (acceptance spec draft)
  ↓
quiz module (NEW)
  ├─ D1 mandatory: Agent → Boss
  └─ D2 optional: Boss → Agent
  ↓
writing-plans (implementation plan)
  ↓
test-driven-development (Quiz output = test 명세 직접 사용)
  ↓
executing-plans (build)
  ↓
verification-before-completion (Quiz output 으로 demo signoff)
```

→ Quiz output = TDD/SDD test 명세 SSOT. alignment 사전 lock.

### 7.2 D1 Mandatory — Agent → Boss

```
[Step 1] Agent 답안지 생성
  - TF spec 5필드 read
  - action_type 별 quiz 질문 N개 생성
  - 4 axis (Vagueness / Consistency / Completeness / Specificity) 최소 1개씩 cover
  - 답 placeholder 만 (agent 답 적지 X — 보스 nodding 함정 회피)
  - 저장: tfs/{TF-id}/quiz.md

[Step 2] 보스 응답지 작성
  - 보스가 response-d1-boss.md 자유 마크다운 채움
  - humanpowers 가 보스 commit 까지 다음 단계 X

[Step 3] Agent 비판 토론 (AUQ per-Q loop)
  - Agent read response
  - Q1 부터 순차 (bulk dump 금지):
    - AUQ: "Q1 답 = '...'. Vagueness: '5개' 정확? 5개 이상?"
    - 보스 답
    - AUQ 다음 critique
    - ...
    - agent critique X = Q1 lock
  - Q2 동일 절차
  - 모든 Q lock = expected-outputs.md final + signed_off=true
```

### 7.3 D2 Optional — Boss → Agent

```
[Step A] Agent AUQ:
  "방향 2 응답지 작성하시겠어요?"
  옵션:
    1. 작성 (filename 입력 — 자유 형식 OK / 템플릿 받음)
    2. Pass

[Step B] 보스 응답지 제공 (filename)
  - response-d2-boss.md
  - 자유 형식 OK. 한 Q 만 답해도 OK.

[Step B-1] Agent 매핑 confirm
  - response-d2-boss.md → quiz.md Q 단위 매핑 시도
  - AUQ: "보스 응답 매핑: Q1=... / Q2=... / Q5=... / 나머지 미응답. 맞나요?"
  - 옵션: 맞음 / 수정 (자유 텍스트로 매핑 보정)

[Step C] Agent 본인 답 작성
  - response-d2-agent.md
  - quiz 의 각 Q 마다 agent 직접 답
  - 보스 응답지와 비교

[Step D] 불일치 Q 마다 discussion.md 에 append
  - Boss answer
  - Agent answer
  - Difference (field / boss / agent / 추측 근거)

[Step E] Agent AUQ per-Q (불일치 Q 마다):
  "Q{N} 불일치 — 옵션:
    1. 논의 필요
    2. Agent 답 채택 (보스 답 변경)
    3. Boss 답 유지 (agent 답 archive)"

[Step F] "논의 필요" 선택 시:
  - Agent 다시 read
  - 보스 추가 코멘트 read
  - 서로 논의
  - cascade 영향 범위 결정 (checkbox):
    [x] 해당 TF expected-outputs 갱신
    [x] 해당 TF 5필드 spec (tfs.md) 갱신
    [x] boss.md 불변식 / 페르소나 갱신
    [ ] 다른 TF 영향 (flag only — 보스 명시 invoke)
  - Final lock

[Lock] 모든 불일치 Q = 옵션 2 또는 3 선택 = D2 종료
```

### 7.4 4 Critique Axes

#### Axis 1 — Vagueness (모호)
- 정량 부족 ("빠르다" / "5개")
- 주체 불명 ("사용자")
- 처리 방식 불명 ("에러")

#### Axis 2 — Consistency (일관성)
- TF spec NFR 와 충돌
- 다른 TF 답안과 충돌
- boss.md 불변식 위반

#### Axis 3 — Completeness (완결성)
- Happy path 만 (error / edge / 0 / overflow / 동시성 / 권한 X 미고려)
- Input variant (한글 / 영문 / 특수문자 / Emoji / 빈값)
- Timeout / 네트워크 실패

#### Axis 4 — Specificity (구체성)
- 정의 부재 ("인기순" — 인기 정의?)
- Timezone / window 부재 ("30일" — KST? Rolling?)
- 동작 모호 ("더보기" — append vs 교체?)

### 7.5 Cascade 영향 범위

D2 논의 → boss.md / tfs.md 갱신:

| 범위 | 적용 |
|------|------|
| (i) 해당 TF expected-outputs | 항상 |
| (ii) 해당 TF 5필드 spec (tfs.md) | 자주 |
| (iii) boss.md 불변식 / 페르소나 | 가끔 |
| (iv) 다른 TF expected-outputs | flag only (보스 명시 invoke) |

(iv) cross-TF impact = loop 위험 → 자동 cascade 금지. agent 가 의심 flag 만, 보스가 명시 invoke 시 처리.

---

## 8. Templates + Examples (`references/`)

### 8.1 Templates (5개)

```
references/templates/
├── quiz-template.md              # 빈 quiz (Q slot, action_type tag, status)
├── response-d1-template.md       # D1 보스 응답 skeleton
├── response-d2-template.md       # D2 보스 freeform 안내
├── discussion-template.md        # 논의 + cascade checkbox
└── critique-axes.md              # 4 axis 체크리스트 (agent 내부)
```

### 8.2 Examples (6개, generic 도메인)

```
references/examples/
├── quiz-ui-example.md            # signed_off UI TF
├── quiz-api-example.md           # signed_off API TF
├── quiz-data-example.md          # signed_off Data TF
├── quiz-infra-example.md         # signed_off Infra TF
├── quiz-crosscut-example.md      # signed_off Cross-cutting TF
├── d2-discussion-example.md      # D2 cascade 논의 사례
└── README.md                     # examples 사용법 (보스 onboarding)
```

도메인 = 특정 X (홈쇼핑/CRUD 등 X). 보스가 패턴 학습용.

---

## 9. Plugin UX

### 9.1 단일 진입점

```
$ /humanpowers
```

dispatcher skill (`humanpowers/skills/humanpowers/SKILL.md`) 가 `.humanpowers/state.json` 읽어 phase 라우팅.

mega-optimize 패턴 차용 (`!`bash check-state.sh\`` 로 state 감지 → output 으로 Claude 가 sub-skill invoke 유도).

### 9.2 명시 phase jump

```
$ /humanpowers brainstorm
$ /humanpowers quiz {TF-id}
$ /humanpowers design
$ /humanpowers operate {TF-id}
$ /humanpowers review
$ /humanpowers abort
```

### 9.3 State echo (advisor 권장)

매 invocation = 현 state 에코 강제:
```
Currently: quiz phase, TF-1a Q5/8 (2 critique rounds done)
Next: /humanpowers continue | /humanpowers jump design | /humanpowers abort
```

### 9.4 첫 호출 시나리오

```
$ /humanpowers

🤖 비서: humanpowers 첫 호출. 워크스페이스 미감지 → brainstorm 진입.
        프로젝트 이름? (snake_case 또는 kebab-case)

> 보스: shopping-search-buy

🤖 비서: ~/humanpowers/shopping-search-buy/ 생성. brainstorm 시작.
        무엇을 만들고 싶나요? 한 줄.

(... 진행 ...)
```

---

## 10. Phase Rollout

### 10.1 Phase 1 — MVP (코어 가치)

**Ships**:
- 13 fork skill + 4 신규 (`quiz` / `scaffold` / `operate` / `review`)
- Dispatcher skill + state.json
- Templates + examples
- 자동 view 렌더 스크립트 (`scripts/render-views.sh`)
- Shelf 자동 truncate hook (≤30줄 강제, PostToolUse on Edit `library/scratchpads/*.md`)
- 수동 thread relay (보스가 다른 세션에 알림)

**미포함**:
- 자동 inter-agent signaling
- TF lead persistent persona
- MCP server

**Phase 1 Gate**: 위 모든 것 동작. 보스가 1 프로젝트 E2E (brainstorm → quiz → design → build → verify → finish) 1회 완주 가능.

### 10.2 Phase 2 — Auto signaling

**Ships**:
- SubagentStop hook + `additionalContext` 주입 (advisor R1 발견)
- Marker file 메커니즘 (caveman 식 cross-session flag)
- Thread post → 자동 next-turn 컨텍스트 추가

**제약**: agent ↔ agent 직접 sync X. Boss/orchestrator turn 1회 경유.

**Phase 2 Gate**: 보스 수동 relay 0회로 1 프로젝트 완주.

### 10.3 Phase 3 — True sync (보류 가능)

**Ships**:
- MCP server (TF lead = persistent process)
- agent ↔ agent direct invocation

**조건**: Phase 2 의 1-turn 경유 모델로 부족 시. Phase 2 만으로 충분하면 영원 보류.

---

## 11. Open Issues / Design Risks

### 11.1 Skill chaining 미문서화 (R2 발견)
- Skill → Skill via Skill tool = 비공식.
- 우리 fork = 단일 plugin 안에서 Skill tool 호출 시도. POC 필요.
- Fallback: dispatcher skill 의 output 으로 Claude 가 sub-skill invoke 유도 (mega-optimize 패턴).

### 11.2 Time/turn 가드 미지원 (R3 발견)
- Skill 안에서 native turn count X.
- `.humanpowers/invocation-log.jsonl` 에 외부 카운터 + agent 가 시작 시 read.
- 30 turn 또는 60 min 초과 = "강제 요약 commit" 권유 (보스 옵션).

### 11.3 메모리 dir 자동 관리 X (L1 발견)
- `~/.claude/projects/{cwd}/memory/` = claude-code 자체 관리, per-project not per-team.
- TF lead 누적 노트 = 별도 메커니즘 (`workspace/library/scratchpads/{lead-id}.md`).
- 자동 truncate hook 으로 ≤30줄 강제 (L4 학습 — 룰만으론 안 지켜짐).

### 11.4 보스 가시성 vs Build Plan
- `tfs/{TF-id}/build-plan.md` = boss 가 cat 가능.
- "Boss 가 코드 안 봄" = convention only. enforcement X.
- 명시 in `boss.md` Charter.

### 11.5 Per-project skill bloat 회피
- N projects × M TF lead = skills 폭발 위험.
- 해결: TF lead = generic skill (`operate`) + workspace 의 TF spec 인자로 받음. per-project skill 생성 X.

---

## 12. Implementation Phases (writing-plans 단계 입력)

```
Phase 0 — Repo bootstrap (사용자 행위):
  Step 0.1 github.com/yoonjong12/humanpowers 생성 (사용자 완료 후 진행)
  Step 0.2 git clone https://github.com/yoonjong12/humanpowers /Users/jay/code/user/humanpowers
  Step 0.3 claude code 에서 cd /Users/jay/code/user/humanpowers

Phase 1 — MVP (claude 작업):
  Step 1.  Plugin scaffold (.claude-plugin/plugin.json with name="humanpowers" + LICENSE MIT + README with attribution)
  Step 2.  Copy 13 skill content from superpowers as baseline (rebrand all references to humanpowers)
  Step 3.  Modify Heavy skills (brainstorming / writing-plans / verification-before-completion)
  Step 4.  Modify Medium skills (executing-plans / finishing-a-development-branch)
  Step 5.  Modify Light skills (subagent-driven-development / dispatching-parallel-agents)
  Step 6.  Rename meta skill (using-superpowers → using-humanpowers)
  Step 7.  New skills (quiz / scaffold / operate / review)
  Step 8.  Templates + Examples (5 + 6)
  Step 9.  Dispatcher skill + state.json schema
  Step 10. Render scripts (render-views.sh)
  Step 11. Shelf truncate hook
  Step 12. Self-test E2E (1 generic project, brainstorm → finish)

Phase 2 (post-Phase-1):
  Step 13. SubagentStop hook + additionalContext
  Step 14. Marker file + auto next-turn 컨텍스트
  Step 15. Self-test 2-agent flow

Phase 3 (보류):
  Step 16+. MCP server (조건 충족 시)
```

---

## 13. Decision Log

| # | Decision | Rationale |
|---|---------|-----------|
| 1 | Plugin name = `humanpowers` | superpowers 와 1:1 mirror, 정체성 명시 |
| 2 | Full fork (Level C) | E2E 보스 인볼브 단계 모두 포함 |
| 3 | TF model (직책 폐지) | 도메인 팀 = WAO-372 학습으로 폐기 |
| 4 | Matrix 부활 (action_type 열) | 보스 (사람) UX = Excel 친화. 직책 X |
| 5 | NFR 2 layer + N=2 promote | 보스 불변식 vs TF-local 분리 |
| 6 | VERIFY type-aware | UI/API/Data/Infra/Cross 별 form |
| 7 | Quiz module D1 mandatory + D2 optional | 보스 articulation 강제 + cascade 보강 |
| 8 | 4 critique axes | Vagueness / Consistency / Completeness / Specificity |
| 9 | Templates + Examples generic | 보스 onboarding 마찰 ↓ |
| 10 | Single endpoint dispatcher skill | mega-optimize 패턴 차용 |
| 11 | Phase 2 = SubagentStop + additionalContext | hook → Agent direct dispatch 불가 (R1) |
| 12 | Per-project workspace at `~/humanpowers/{project}/` | git-friendly, 보스 가시성 |
| 13 | Shelf 자동 truncate hook | 룰만으론 안 지켜짐 (L4) |
| 14 | AUQ per-question loop | bulk dump 회피 (User 명시) |
| 15 | Cascade scope (i)-(iii) auto, (iv) flag only | Loop 위험 회피 |
| 16 | 90% upfront → reframe | 변경 절차 1급 워크플로 (advisor #4) |
| 17 | Path B (independent repo + heavy fork) | superpowers prefix 종속 X / 검증된 micro pattern 보존 |
| 18 | Repo = github.com/yoonjong12/humanpowers | 사용자 결정 |
| 19 | Local path = `/Users/jay/code/user/humanpowers/` | 사용자 결정 |
| 20 | License = MIT | 최대한 개방적, superpowers 와 호환 |

---

## 14. Next Step (writing-plans handoff)

이 spec → `humanpowers` 가 자체 dogfood:
1. 이 spec 자체 = humanpowers brainstorming 출력으로 간주.
2. 다음 = `superpowers:writing-plans` 호출 (humanpowers 아직 미구현).
3. Phase 1 Step 1-12 = implementation plan 으로 분해.
4. TDD 로 진행 (자체 quiz 모듈로 자기 자신 quiz — meta).

> Note: humanpowers 가 superpowers fork 라 self-bootstrap 가능. Phase 1 완성 후엔 humanpowers 자체로 다음 prj brainstorm 가능.
