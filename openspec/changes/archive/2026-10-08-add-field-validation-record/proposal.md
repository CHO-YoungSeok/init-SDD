## Why

상위 change `plugin-lite-sdd-distribution` 은 파이프라인을 경량화(②)하고 플러그인으로 바꾼다(③).
그런데 "줄여도 결과가 나빠지지 않는지", "직접 작업보다 나은지"를 판정할 **같은 잣대**가 없다.
줄이기 전 파이프라인을 기준선으로 잴 수 있는 마지막 기회가 지금(②보다 앞)이라서 ④를 먼저 한다.

이 change는 **측정을 하지 않는다.** 측정 방법과 기록 양식만 만든다. 양식이 없으면 ②·③ 뒤에 쓰는
숫자를 서로 비교할 수 없고, "단계를 남길까 뺄까" 결정이 느낌으로 흐른다.

## What Changes

- 새 문서 `docs/field-validation.md` (`docs/` 디렉터리도 새로 생긴다):
  - 측정 항목 3가지: 결과물 품질(판정 기준), 소요 시간, 토큰. 사용할 수 있는 측정 수단
    (`/cost`, `claude plugin details <name>` 의 토큰 추정, 세션 로그)과 각각이 재는 것·못 재는 것.
  - 비교 대상 3가지: 직접 작업 / SDD 경량 경로 / SDD 정식 경로.
  - 기록 표 양식 (작업 1건당 1행, 같은 항목으로 세 대상을 적는다).
  - 기준선 값 칸: 지시문 2,821줄, 세션당 약 1.5k 토큰, 기본 경로 1회 약 80k 토큰 추정 (모두 analyzer 실측·추정값. 출처와 "추정"임을 표시).
  - 판정 규칙: 어떤 결과면 어떤 단계(analyzer / designer / regression-verifier 등)를 남기거나 뺄지.
- 새 폴더 `evals/` 뼈대 (최소): `claude plugin eval` 이 읽는 사례 폴더 구조, `evals/README.md` 1개,
  실제 사례는 1~2개 자리만 (`prompt.md` + `graders/*.md`).
  `claude plugin eval --ablation with-without` 로 쓸 수 있게 맞춘다.
- 이 change는 에이전트·스킬·README·플러그인 파일을 건드리지 않는다.

## 받아들일 조건

- [ ] `docs/field-validation.md` 가 있고, 측정 항목 3가지(품질 / 소요 시간 / 토큰)와 각 항목의 측정 수단이 적혀 있다.
- [ ] 같은 문서에 비교 대상 3가지(직접 작업 / 경량 경로 / 정식 경로)와, 작업 1건당 1행으로 세 대상을 같은 항목으로 적는 빈 표 양식이 있다 (상위 조건 9).
- [ ] 기준선 값 칸에 2,821줄 / 약 1.5k 토큰 / 약 80k 토큰 추정이 출처와 함께 들어 있다.
- [ ] 판정 규칙이 있다: 조건(결과)과 그에 따른 조치(단계 유지/제거)가 짝으로 적혀 있다. 목표 숫자를 새로 지어내지 않고, 임계값이 필요한 곳은 "측정 뒤 사용자가 정한다"로 남긴다.
- [ ] `evals/` 아래에 사례 폴더 뼈대와 `evals/README.md` 가 있고, 사례 폴더가 `claude plugin eval init --bare` 가 만드는 모양(`prompt.md` + `graders/criteria.md`)과 같다.
- [ ] 실제 측정을 돌리지 않았고, 표의 값 칸은 비어 있다(기준선 값 칸만 채움).
- [ ] `openspec validate "add-field-validation-record" --strict` 종료코드 0, 마크다운 frontmatter / 코드펜스 짝 확인.

## 범위 밖 / 세운 가정

범위 밖:
- 실제 프로젝트 1~2개에서 작업 3~5건을 돌려 측정하는 일 자체.
- 에이전트 파일, orchestra, README, `install.sh`, `CLAUDE.md`, 플러그인 파일(`.claude-plugin/`, `hooks/`, `bin/`) 수정.
- `claude plugin eval` 을 실제로 돌리는 일, 평가용 플러그인 작성.

가정:
- 목표치(예: "토큰 몇 % 절감")는 정하지 않는다. 지금은 기준선과 측정 절차만 만든다. 목표가 필요하면 측정 뒤 사용자가 정한다.
- `evals/` 폴더 형식은 `claude plugin eval --help` 와 `claude plugin eval init --bare` 로 실제 확인했다 (Claude Code 2.1.294). 사례는 `prompt.md`(frontmatter `max_turns`, `allowed_tools`) + `graders/*.md`(frontmatter `type: llm`, `weight`). 이 저장소는 아직 플러그인이 아니라서(③에서 전환) 지금은 `evals/` 가 실행 가능한 상태가 아니다. 실행은 ③ 뒤에 한다고 README에 적는다.
- capability 위치: 기존 `agent-instructions/`(에이전트 지시문)나 `distribution/`(설치·배포)에 맞지 않아 상위 proposal 표대로 새 그룹 `process/` 를 만든다.

## Capabilities

### New Capabilities
- `process/field-validation-record`: 실전 검증을 같은 항목(품질 / 소요 시간 / 토큰)으로 기록·비교하는 방법과 양식, 판정 규칙, `evals/` 사례 폴더 뼈대가 갖춰야 할 요구사항.

### Modified Capabilities
(없음)

## Impact

- 새 파일: `docs/field-validation.md`, `evals/README.md`, `evals/<사례1>/prompt.md`, `evals/<사례1>/graders/criteria.md` (사례 1~2개).
- 새 메인 spec 그룹: `openspec/specs/process/` (archive 때 sync로 생김).
- 기존 파일 변경 없음. 의존: 없음 (측정 때 Claude Code `/cost`, `claude plugin details`, `claude plugin eval` 을 쓴다).
- 상위 change `plugin-lite-sdd-distribution` 의 tasks 2.1 이 이 change 완료를 가리킨다.
