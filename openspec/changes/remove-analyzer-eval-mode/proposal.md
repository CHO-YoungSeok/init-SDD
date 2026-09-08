## Why

`.claude/agents/analyzer.md`는 지금 자기 일을 **두 모드**로 쪼개 놓았다.
① 방안 제시 모드(기본)와 ② 사용자 안 평가 모드(프롬프트에 `평가할 안:`이 있을 때).
그런데 이 둘은 실제로 **같은 일**이다 — "정리된 요구사항 + 현재 코드베이스 → 실현 가능한
방안들 + 각각의 장단점 + 내 의견"을 만드는 것. 사용자가 낸 아이디어를 검토하는 것도
결국 이 절차 그대로이고, 다만 후보가 하나 늘어날 뿐이다.

별도 모드로 쪼개 둔 대가가 있다: `analyzer.md`에 절 하나(20여 줄)와 조건부 RESULT 필드
(`feasible=<평가 모드일 때만>`)가 붙고, `orchestra/SKILL.md`에 왕복 분기가 하나 더 생기고,
사용자가 3안 대신 자기 안을 낼 때마다 opus 에이전트를 한 번 더 호출하게 된다.
쓸데없는 것을 걷어내고, 실제로 동작에 영향을 주는 지시만 남긴다.

다만 이 모드를 없애면 빈 자리가 하나 생긴다: 지금 `orchestra/SKILL.md`는
*"검증 안 된 안을 설계하면 worker가 벽에 부딪힌다"*는 이유로 사용자가 자기 안을 낼 때
analyzer를 평가 모드로 재호출하게 되어 있다. 그 검증 기능 자체를 없앨 수는 없고,
**무엇으로 대신할지**가 이번 change의 핵심 질문이다. 이 답은 analyzer 단계의 방안
분석에서 나온다 — proposal은 답을 정하지 않고, "그 공백을 무엇으로 메웠는지가
`orchestra/SKILL.md`에 글로 적혀 있어야 한다"는 조건만 못박는다.

## What Changes

- `.claude/agents/analyzer.md`
  - frontmatter `description`에서 "사용자가 낸 안을 평가하는 일도 한다"는 문구를 없앤다.
  - `## 두 가지 모드` 절을 없앤다 (모드 분기 자체가 사라진다).
  - `## 사용자 안 평가` 절을 없앤다.
  - RESULT 형식의 조건부 필드 `feasible=<평가 모드일 때만: 예/부분/아니오>`를 없앤다.
  - 위 네 곳을 없애면서, "사용자가 낸 아이디어도 검토 대상에 들어올 수 있다"는 사실 자체가
    통째로 사라지지 않도록 — 기존 방안 생성 절차(요구사항+코드→방안 N개+장단점+의견) 안에서
    그 입력을 어떻게 다루는지는 **analyzer가 방안으로 제시**한다 (design 결정 아님).
- `.claude/skills/orchestra/SKILL.md`
  - 파이프라인 그림의 화살표 `사용자가 자기 안을 내면 → analyzer 재호출(평가 모드) →
    다시 고르게 한다`를 없애거나 새 절차에 맞게 바꾼다.
  - `### 사용자가 목록에 없는 자기 안을 냈을 때` 절과 그 안의 `Agent(subagent_type:
    "analyzer", ...)` 예시(`평가할 안:` 프롬프트)를 없애거나 새 절차로 바꾼다.
  - **무엇으로 바꾸든, "검증 안 된 안으로 설계에 들어가지 않는다"는 안전장치는 문서에
    남아 있어야 한다.** 이 지점이 이번 change의 핵심 요구사항이다.
- `docs/example-run.md`
  - "목록에 없는 자기 안을 내도 된다. 그러면 analyzer가 **평가 모드**로 다시 돌아서..."
    문단을 새 절차에 맞게 갱신한다. (참고: `docs/`는 `.git/info/exclude`로 git 추적
    제외 대상이라 커밋되지는 않지만, 실제 파일이므로 낡은 채로 남겨두지 않는다.)
- `README.md`
  - 확인 결과 에이전트 표의 analyzer 설명은 이미 "코드베이스 분석, 방안 최소 3가지 + 의견과
    근거"로만 되어 있어 평가 모드를 언급하지 않는다. **손댈 필요 없음** — 손대지 않는다.

**BREAKING**: 없음. 에이전트 지침 문서와 스킬 문서만 수정하며, OpenSpec 산출물 형식이나
외부 인터페이스는 바뀌지 않는다.

## Capabilities

### New Capabilities
- `agent-instructions/analyzer-option-generation`: analyzer 에이전트가 방안을
  제시하는 절차가 "사용자 프롬프트 자체를 평가하는 것"이 아니라 "요구사항 + 코드베이스를
  바탕으로 방안 최소 3가지 + 장단점 + 의견을 내는 것" 하나로 통일되어야 한다는 요구사항,
  그리고 사용자가 목록에 없는 자기 안을 냈을 때도 이 절차 안에서 다뤄지되 "검증 안 된 안으로
  설계 단계에 들어가지 않는다"는 안전장치가 지침 문서에 남아 있어야 한다는 요구사항을
  문서화한다.

### Modified Capabilities
(없음 — 이 저장소에 analyzer 절차를 다루는 기존 메인 spec이 없다. `openspec list --specs`
결과 `agent-instructions/openspec-metadata-marker-safety` 하나뿐이고 겹치지 않는다.)

## Impact

- 영향 파일 (3개 실질 수정 + 1개 확인만, 코드 수정 없음 — 지침 문서만 수정):
  - `.claude/agents/analyzer.md` (frontmatter description, 두 가지 모드 절,
    사용자 안 평가 절, RESULT 형식의 `feasible=` 필드 — 4곳)
  - `.claude/skills/orchestra/SKILL.md` (파이프라인 그림의 화살표, "사용자가 목록에
    없는 자기 안을 냈을 때" 절, 그 절의 Agent 호출 예시 — 3곳)
  - `docs/example-run.md` ("평가 모드로 다시 돌아서" 문단 — 1곳, git 추적 제외 파일)
  - `README.md` — 확인만 함. 수정 불필요로 확인됨.
- 영향 범위: 이 change 이후로 시작되는 모든 파이프라인 실행에서, 사용자가 자기 안을 낼 때
  orchestra가 부르는 절차가 바뀐다. 진행 중인 다른 change(`fix-openspec-yaml-metadata-loss`,
  완료 상태·미아카이브)는 `preparer.md`·`designer.md`·`README.md`만 건드려서 이번 change의
  대상 파일(`analyzer.md`, `orchestra/SKILL.md`)과 겹치지 않는다.
- 받아들일 조건 (승인 기준):
  - [ ] `.claude/agents/analyzer.md`의 frontmatter `description`에 "사용자가 낸 안을
        평가하는 일도 한다"는 취지의 문구가 없다.
  - [ ] `.claude/agents/analyzer.md`에 `## 두 가지 모드` 절, `## 사용자 안 평가` 절,
        `feasible=` RESULT 필드가 모두 사라졌다 (`grep -n` 확인).
  - [ ] `.claude/skills/orchestra/SKILL.md`의 "사용자가 자기 안을 내면 →
        analyzer 재호출(평가 모드)" 화살표와 `### 사용자가 목록에 없는 자기 안을 냈을 때`
        절, 그 안의 `평가할 안:` Agent 호출 예시가 사라지거나 새 절차로 교체됐다.
  - [ ] **위를 없애도 사용자가 자기 안을 냈을 때 "실현 가능한지 검증하는 절차"가 문서에서
        완전히 사라지지 않는다.** `orchestra/SKILL.md`를 읽었을 때 "사용자가 자기 안을
        냈을 때 무엇을 하는지"에 대한 답이 여전히 있어야 한다 (구체적 방법은 designer가
        고를 것 — analyzer의 방안 분석 단계에서 최소 3가지로 제시한다).
  - [ ] `docs/example-run.md`의 "평가 모드로 다시 돌아서" 문단이 새 절차와 맞게 갱신됐다.
  - [ ] `README.md`는 다시 확인해서, 위 수정과 어긋나는 문구가 새로 생기지 않았음을
        재확인한다 (현재는 수정 불필요로 확인됨).
  - [ ] `openspec validate "remove-analyzer-eval-mode" --strict` exit=0.
  - [ ] `bash -n install.sh` exit=0 (이 change는 install.sh를 건드리지 않지만,
        이 저장소에 실행 테스트 스위트가 없어 회귀 없음을 보여줄 표준 확인 수단이다).
- 가정: `analyzer.md`와 `orchestra/SKILL.md`가 이 change의 핵심 대상이고,
  `designer.md`·`worker.md`·`reviewer.md`·`regression-verifier.md`·`finalizer.md`는
  이번 요청과 무관해 손대지 않는다. "3단계 방안 선택" 관문 자체(사용자가 반드시 안을
  고르게 하는 절차)는 그대로 유지하고, 오직 "사용자가 그 목록에 없는 자기 안을 냈을 때"의
  하위 절차만 바뀐다.
- 정량 요구사항 아님(문서 간결화·구조 정리). 측정 절차 대신 위 승인 기준(존재/부재 확인,
  `grep`, `openspec validate`)으로 판정한다.
- 사용자에게 물어야 할 것: "사용자가 자기 안을 냈을 때 실현 가능성을 무엇으로 검증할지"는
  이 proposal이 답을 정하지 않는다. analyzer가 코드베이스 분석 단계에서 최소 3가지 대안으로
  제시하고, 그중 하나를 **사용자가 이 파이프라인의 3단계(★ 방안 선택)에서 직접 고른다.**
