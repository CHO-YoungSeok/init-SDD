## Why

이 저장소의 SDD 파이프라인을 실제로 한 바퀴 돌리면서, 에이전트가 서로 넘겨주는
정보(파일 경로, 상태값, 프롬프트 문구)를 다음 에이전트가 어떻게 해석하는지
실측과 문서 대조로 짝을 맞춰 봤다. 그 결과 **에이전트 간 짝이 어긋난 자리 8건**이
나왔다. 방치하면 다음과 같은 일이 생긴다.

- **무한 왕복**: `openspec instructions apply`의 `state: "blocked"`는 두 상황
  (산출물 파일 없음 / 파일은 있는데 체크박스 0개)에서 똑같이 나오는데(실측),
  `worker.md`는 한 가지로만 해석해 보고한다. 두 번째 경우를 첫 번째처럼 보고하면
  오케스트레이터가 designer를 다시 불러도 designer는 "이미 다 있다"고 답해
  왕복이 끝나지 않는다.
- **고아 브랜치를 아무도 모름**: 브랜치는 4단계에서, change는 5단계에서 만드는데
  5단계 이름 충돌(`Error: Change '...' already exists`, 실측)로 멈추면 브랜치는
  이미 생겼는데 중단 보고서에 `branch=` 필드가 없어 오케스트레이터가 그 존재를
  알 수 없다.
- **판정 기준의 증발**: `skip_specs: true`는 이 저장소가 정식으로 지원하는 경로
  (preparer/designer/finalizer가 반복 언급)인데, reviewer는 그 존재를 한 번도
  언급하지 않고 `artifactPaths.specs.existingOutputPaths`를 "최종 기준"으로
  못 박아 둔다. `skip_specs` change에서는 이 값이 빈 배열이라 판정 기준이 사라진다.
- **방안 선택 관문의 조용한 증발** (가장 중요): 에이전트 사이를 파일이 아니라
  프롬프트로만 오가는 정보 4가지 중, `review.md`와 회귀 판정은 finalizer가
  "없으면 멈춘다"는 방어를 갖고 있지만, `만진 파일`(reviewer/regression-verifier가
  받는 쪽)과 **`사용자가 고른 안`**(designer가 받는 쪽)은 방어가 없다. designer의
  중단 사유에는 "고른 안이 프롬프트에 아예 없을 때"가 없어서, 오케스트레이터가
  그 줄을 빠뜨리면 designer가 analyzer의 추천안을 "사용자가 고른 안"으로 조용히
  대체하고 reviewer는 decision.md를 기준으로 삼으라고 배웠으니 그대로 통과시킨다.
  이 저장소가 막으려고 만들어진 바로 그 실패(방안 선택을 건너뛰기)가 문서 결함으로
  재현될 수 있다.
- **보고서와 파일의 불일치를 아무도 대조하지 않음**: 이번 사이클에서 실제로
  analyzer가 `analysis.md`의 표를 보고서용으로 옮겨 적다 한 칸을 틀렸고, 그 값이
  designer의 산출물에 그대로 박혔다가 worker의 재측정에서 겨우 잡혔다.
  "프롬프트의 요약보다 파일이 맞다"는 방어는 지금 `finalizer.md` 한 곳에만 있다.
- **정책은 맞는데 근거 3개 중 2개가 실측과 다름**: `finalizer.md`는 "archive CLI를
  직접 돌리지 마라"는 옳은 정책을, "손으로 sync 후 돌리면 이중 적용된다"
  "validate가 막는 change도 archive는 그냥 한다" 는 실측과 반대되는 근거로
  뒷받침하고 있다. 실측: 손으로 sync 후 돌리면 `Specs already in sync; no files
  changed.`로 안전하게 넘어가고, validate가 막는 change는 archive도 거부한다
  (`Validation failed. Please fix the errors before archiving.`). stdin 문제
  근거만 맞다.
- **"Skill 도구가 없을 수 있다"는 이 환경에서 사실이 아님**: 현재 환경에서
  preparer/designer/worker/finalizer는 `Skill` 도구를 갖고 있다(실측). 스킬을
  직접 부르지 말라는 결론은 옳지만 진짜 이유는 6개 openspec 스킬이 전부
  `allowed-tools: Bash(openspec:*)`를 선언해서, 부르는 순간 그 스킬이 도는 동안
  다른 도구(파일 쓰기 등)를 못 쓰게 되기 때문이다.
- **이 저장소 자신의 `context:`가 비어 있음**: README와 install.sh가 "context는
  프로젝트 사정을 전달하는 유일한 통로"라고 강조하는데 정작 자기 저장소의
  `openspec/config.yaml`은 `context:` 밑이 전부 주석이다(실측: `openspec
  instructions proposal --json`에 `context` 키 자체가 없음). 이번 사이클에서
  그 대가로 모든 에이전트 프롬프트에 스택 정보를 손으로 적어 보내야 했다.

## What Changes

- `.claude/agents/worker.md`: `state: "blocked"`를 `missingArtifacts`가 있는
  경우(산출물 없음)와 없는 경우(파일은 있는데 체크박스 0개)로 나눠 보고하도록
  고친다. 두 번째 경우를 "산출물이 빠졌다"로 보고하지 않게 한다.
- `.claude/agents/preparer.md`:
  - 중단 RESULT 형식(`RESULT: 준비중단 | ...`)에 `branch=<브랜치 또는 none>`
    필드를 추가한다.
  - "Skill 도구가 없을 수 있다" 블록인용 문단의 근거를, 실제 이유
    (openspec 스킬의 `allowed-tools: Bash(openspec:*)` 제약)로 바꾼다.
    "스킬을 못 부른다는 이유로 멈추지 마라"는 결론은 유지한다.
- `.claude/agents/designer.md`:
  - 중단 사유에 `채택안 없음`을 추가한다: 프롬프트에 `사용자가 고른 안:`도
    `analyzer 생략: 예`도 없으면 진행하지 말고 멈춘다.
  - 1단계(입력 다시 읽기)에 우선순위 규칙을 추가한다: 프롬프트에 실려 온
    숫자·표와 `analysis.md`의 내용이 다르면 파일이 맞다는 것.
  - "Skill 도구가 없을 수 있다" 블록인용 문단의 근거를 실제 이유로 바꾼다.
- `.claude/agents/reviewer.md`:
  - `skip_specs`가 있는 change에서 `artifactPaths.specs.existingOutputPaths`가
    비었을 때의 대체 판정 기준(proposal의 받아들일 조건 + tasks 머리말)을 명시한다.
  - 프롬프트에 `만진 파일` 목록이 없을 때의 처리를 명시한다.
- `.claude/agents/regression-verifier.md`: 프롬프트에 `만진 파일` 목록이 없을 때의
  처리를 명시한다.
- `.claude/agents/finalizer.md`:
  - archive CLI를 직접 돌리지 말라는 5번 절의 근거 2·3을 실측대로 고친다
    (근거1 stdin 문제는 그대로 둔다). 정책 자체(사용자 확인 없이 archive하지
    않는다)는 바꾸지 않고, 앞세우는 이유를 "되돌릴 수 없어서 사용자가 정한다"로
    바꾼다.
  - "Skill 도구가 없을 수 있다" 블록인용 문단의 근거를 실제 이유로 바꾼다.
- `.claude/agents/analyzer.md`: "Skill 도구가 없을 수 있다" 블록인용 문단의 근거를
  실제 이유로 바꾼다. 다른 네 파일과 **글자 단위로 같은** 한 벌을 쓴다.
  (2026-09-09 범위 추가 — 아래 "범위 변경" 참고)
- `openspec/config.yaml`: `context:` 키를 채운다. 담을 내용은 실행 코드가 없는
  지시문 저장소라는 것, 테스트·빌드·CI가 없고 검증 수단은 `bash -n install.sh`
  / `bash install.sh --dry-run` / OpenSpec CLI 실측 / grep 대조뿐이라는 것,
  문서는 한국어이며 쉬운 말을 쓴다는 것, 에이전트 파일은 Edit 부분 수정만
  한다는 것. YAML이 깨지지 않도록 줄 맨 앞에서 시작해야 한다.

**BREAKING**: 없음. 에이전트 지침 문서와 `openspec/config.yaml`만 수정하며,
파이프라인이 만드는 산출물의 파일 형식이나 외부 인터페이스는 바뀌지 않는다.

**범위 밖**: `.claude/skills/orchestra/SKILL.md`, `docs/example-run.md`
(다른 change `remove-analyzer-eval-mode` 소관이고 이번 8건과 관계없다).

**범위 변경 (2026-09-09)**: `.claude/agents/analyzer.md`를 범위에 **더했다** (7개 → 8개 파일).
처음엔 다른 change `remove-analyzer-eval-mode`가 같은 파일을 동시에 고치고 있어서 뺐는데,
그 change가 끝나 커밋(`6946374`, 32/32)되면서 충돌이 사라졌다. 지금은 네 파일만 새 F2 문구를
갖고 `analyzer.md` 하나만 옛 문구("`Skill` 도구가 없을 수 있다 (실측으로 확인됨)")를 달고 있다.
같은 저장소 안에서 같은 자리가 두 가지 말을 하고, 그중 하나는 사실이 아니다
(다섯 에이전트 모두 frontmatter `tools:`에 `Skill`이 있다 — 실측).
`.claude/settings.json`의 `permissions.allow` 확대. `README.md`.
오케스트레이터 쪽 규칙(archive 누적, 병렬 worker 만진 파일 합집합) —
`orchestra/SKILL.md` 소관이라 이번엔 제외.

## Capabilities

### New Capabilities
- `agent-instructions/worker-blocked-state-disambiguation`: worker가
  `state: "blocked"`를 "산출물 없음"과 "체크박스 0개"로 구분해 보고해야 한다는
  요구사항.
- `agent-instructions/preparer-orphan-branch-reporting`: preparer의 중단 보고에
  브랜치 생성 여부가 항상 드러나야 한다는 요구사항.
- `agent-instructions/reviewer-skip-specs-fallback`: reviewer가 `skip_specs`
  change에서 specs가 비었을 때 쓸 대체 판정 기준을 알아야 한다는 요구사항.
- `agent-instructions/prompt-only-handoff-defense`: 파일이 아니라 프롬프트로만
  전달되는 정보(사용자가 고른 안, 만진 파일 목록)가 빠졌을 때 받는 쪽
  (designer, reviewer, regression-verifier)이 조용히 대체하지 않고 멈추거나
  명시적으로 처리해야 한다는 요구사항.
- `agent-instructions/artifact-file-precedence-over-prompt`: designer가 프롬프트에
  손으로 옮겨 적힌 숫자·표보다 원본 파일(analysis.md 등)을 우선해야 한다는
  요구사항.
- `agent-instructions/finalizer-archive-rationale-accuracy`: finalizer가
  archive CLI를 직접 돌리지 말라는 정책의 근거로 실측과 맞는 사실만 들어야
  한다는 요구사항.
- `agent-instructions/skill-tool-invocation-rationale`: 에이전트 지침이
  "스킬을 직접 부르지 마라"의 근거로 openspec 스킬의 `allowed-tools` 제약을
  들어야 한다는 요구사항.
- `agent-instructions/project-context-completeness`: 이 저장소의
  `openspec/config.yaml`이 프로젝트 사정(스택, 검증 수단, 문서 언어, 편집 방식)을
  `context:`에 채워 둬야 한다는 요구사항.

### Modified Capabilities
(없음 — 기존 capability `agent-instructions/openspec-metadata-marker-safety`는
이번 변경과 겹치지 않는다.)

## Impact

- 영향 파일 (8개, 전부 지시문/설정 문구 수정 — 실행 코드 없음):
  - `.claude/agents/worker.md`
  - `.claude/agents/preparer.md`
  - `.claude/agents/designer.md`
  - `.claude/agents/reviewer.md`
  - `.claude/agents/regression-verifier.md`
  - `.claude/agents/finalizer.md`
  - `.claude/agents/analyzer.md`  ← 2026-09-09 범위 추가
  - `openspec/config.yaml`
- 영향 범위: 이 저장소의 SDD 파이프라인이 앞으로 도는 모든 change에서
  8가지 어긋남이 예방된다. 코드 실행 경로는 없으므로 사용자 대면 동작 변화는
  없고, 에이전트 지시문의 정확성과 파이프라인 안정성만 바뀐다.

### 받아들일 조건 (승인 기준)
- [ ] `worker.md`가 `blocked` 상태를 `missingArtifacts` 유무로 두 갈래로 나눠
      보고하는 지침을 담고 있다 (`missingArtifacts`라는 단어가 최소 1회 등장).
- [ ] `preparer.md`의 중단 RESULT 형식 줄에 `branch=` 필드가 있다.
- [ ] `reviewer.md`에 `skip_specs`라는 단어가 등장하고, specs가 비었을 때의
      대체 판정 기준(proposal 받아들일 조건 + tasks 머리말)이 명시돼 있다.
- [ ] `designer.md`의 중단 사유 목록에 "채택안 없음"(또는 동등한 표현)이
      추가돼 있고, `사용자가 고른 안:`도 `analyzer 생략: 예`도 없는 경우를
      가리킨다.
- [ ] `reviewer.md`와 `regression-verifier.md` 각각에 `만진 파일` 목록이
      프롬프트에 없을 때의 처리가 명시돼 있다.
- [ ] `designer.md`의 1단계(입력 다시 읽기)에 "프롬프트의 숫자·표와
      `analysis.md`가 다르면 파일이 맞다"는 취지의 우선순위 규칙이 있다.
- [ ] `finalizer.md`의 archive 금지 근거에서, 실측과 반대인 근거2("이중 적용")·
      근거3("validate가 막는 change도 archive는 그냥 한다")가 **삭제되어 있다.**
      남은 근거는 ① archive는 change 디렉터리를 옮기므로 되돌릴 수 없고 그래서 사용자가
      정한다 ② stdin이 없어 `--yes` 없이는 확인 프롬프트에서 죽는다 —
      **이 두 가지뿐이다.** (2026-09-09 수정: 원래 이 조건은 두 근거를 "교정 문구로
      고쳐 놓기"를 요구했는데, `design.md` D3는 그 대안을 명시적으로 기각했다 —
      반박이 붙은 근거를 남기면 다음 사람이 반박을 놓치고 그걸 근거로 쓴다.
      조건을 설계에 맞춰 "삭제"로 고쳤다.)
- [ ] `preparer.md`·`designer.md`·`worker.md`·`finalizer.md`·`analyzer.md`
      **다섯 파일**의 "Skill 도구가 없을 수 있다" 블록인용 문단이, `allowed-tools:
      Bash(openspec:*)` 제약을 근거로 든다. "스킬을 못 부른다는 이유로
      멈추지 마라"는 결론 문장은 다섯 파일 모두에 그대로 남는다.
      다섯 파일의 그 6줄 블록은 **글자 단위로 같다** — md5 대조로 확인한다
      (기준값 `7111c996def6a259f004dd92f1ee1dec`). 개수 세기 grep으로는
      "문구가 조금 다른" 경우를 못 잡는다.
- [ ] `openspec/config.yaml`의 `context:` 키가 주석이 아닌 실제 값으로
      채워져 있고, `openspec context` 실행 결과에 `Warning`이 없다
      (YAML 들여쓰기 깨짐 없음).
- [ ] 위 8개 파일 모두 `Edit` 부분 수정으로만 바뀌었다 (전체 `Write` 없음).
- [ ] `bash -n install.sh`가 통과한다 (이번 change는 install.sh를 건드리지
      않지만, 이 저장소에 실행 가능한 테스트 스위트가 없어 회귀 확인용 표준
      수단으로 쓴다).

### 겹치는 진행 중 change
**2026-09-09 갱신.** `openspec list --json` 실측 기준 `remove-analyzer-eval-mode`는
**끝났다**(32/32, 커밋 `6946374`). `fix-openspec-yaml-metadata-loss`도 완료
(18/18, 아직 archive 안 함). 지금 진행 중인 change는 이것 하나뿐이라 트리 충돌 위험이 없다.
→ 그래서 `.claude/agents/analyzer.md`가 자유로워져 이번 범위에 들어왔다.
`.claude/skills/orchestra/SKILL.md`와 `docs/example-run.md`는 여전히 범위 밖이다
(그쪽 소관이고 이번 8건과 관계없다).

### 가정
- 현재 브랜치 `fix-openspec-yaml-metadata-loss`를 그대로 쓴다 (사용자 지시).
  브랜치 이름이 이미 완료된 다른 change의 이름과 같지만, 이번 change의 이름은
  `fix-pipeline-handoff-gaps`로 별개다. 새 브랜치를 만들지 않았다.
- 8건 모두 실측·문서 대조로 확인됐다는 사용자의 확인을 그대로 받아들인다.
  이번 change에서 별도로 재검증하지 않는다 (analyzer가 필요시 재확인한다).
- capability는 이슈 항목(L1/L2/L4/L5/L9/F1/F2/F3) 단위로 1:1 매핑한다.
  L5의 두 하위 대상(designer의 채택안 누락, reviewer/regression-verifier의
  만진 파일 누락)은 "프롬프트로만 오는 정보에 대한 방어"라는 같은 주제로 묶어
  하나의 capability(`prompt-only-handoff-defense`)로 처리한다.

### 사용자에게 물어야 할 것
없음. 문제 정의와 재현 절차가 사용자 프롬프트에 이미 실측으로 첨부돼 있고,
범위 안/밖도 명확히 지정돼 있다.
