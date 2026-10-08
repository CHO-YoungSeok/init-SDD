# distribution/session-start-hook Specification

## Purpose
플러그인 루트의 CLAUDE.md는 로드되지 않으므로, SessionStart 훅이 `/sdd:init`으로 SDD를 켠 프로젝트(표식 파일 `openspec/.sdd`가 있는 곳)에서만 메인 세션에 지휘 규칙과 빠른 점검 결과를 넣게 한다. 표식이 없는 프로젝트에는 `openspec/`이 있더라도 아무것도 넣지 않는다.

## Requirements

### Requirement: SDD 표식 파일이 있을 때만 주입해야 한다

플러그인의 `hooks/hooks.json`은 SessionStart 훅 하나를 등록해야 한다(SHALL). 훅은 프로젝트 루트
(`CLAUDE_PROJECT_DIR`, 없으면 현재 디렉터리)에 표식 파일 `openspec/.sdd`가 있을 때만 stdout에 내용을
내야 한다(SHALL). 표식이 없으면 `openspec/`이 있더라도 아무것도 출력하지 않아야 한다(MUST) — openspec을
따로 쓰는 프로젝트에 지휘 규칙을 밀어 넣지 않기 위해서다.

표식은 `/sdd:init`의 초기화 단계가 만드는, 커밋할 수 있는 작은 파일이다. 훅은 내용이 아니라 있는지만
본다(SHALL).

훅은 어느 경우든 종료코드 0으로 끝나야 한다(MUST). 점검 하나가 실패해도 세션 시작을 막아서는 안
된다(MUST NOT).

훅 명령을 셸에서 직접 실행해도 같은 결과가 나와야 한다(SHALL) — 사람이 셸에서 바로 훅을 검증할 수 있게 하기 위해서다.

#### Scenario: openspec 폴더가 없는 디렉터리

- **WHEN** `mktemp -d`로 만든 빈 디렉터리에서 훅 스크립트를 직접 실행한다
- **THEN** stdout이 비어 있다
- **AND** 종료코드가 0이다

#### Scenario: openspec 폴더는 있지만 표식이 없는 디렉터리

- **WHEN** `openspec/`은 있고 `openspec/.sdd`는 없는 디렉터리에서 훅 스크립트를 직접 실행한다
- **THEN** stdout이 비어 있다
- **AND** 종료코드가 0이다

#### Scenario: 표식이 있는 디렉터리

- **WHEN** `openspec/.sdd`가 있는 디렉터리에서 훅 스크립트를 직접 실행한다
- **THEN** 지휘 규칙과 점검 결과가 나온다
- **AND** 종료코드가 0이다

#### Scenario: 실제 세션에서도 같다

- **WHEN** `openspec/.sdd`가 있는 디렉터리에서 새 `claude -p --plugin-dir <플러그인 루트> --output-format stream-json --verbose` 프로세스를 띄운다
- **THEN** SessionStart 훅 응답에 직접 실행했을 때와 같은 지휘 규칙이 들어 있다

### Requirement: README는 훅을 끄는 법을 알려야 한다

`README.md`는 훅이 켜지는 조건(표식 `openspec/.sdd`)과 끄는 법을 적어야 한다(MUST):
그 프로젝트에서 끄려면 표식을 지운다, 모든 프로젝트에서 끄려면 플러그인을 끈다(`/plugin disable sdd`).
표식을 커밋하면 같은 저장소에서 플러그인을 깐 팀원에게도 켜진다는 사실도 적는다(SHALL).

#### Scenario: 끄는 법이 적혀 있다

- **WHEN** `README.md`에서 `openspec/.sdd`를 찾는다
- **THEN** 표식이 훅을 켠다는 설명과, 표식을 지우거나 플러그인을 꺼서 훅을 끄는 법이 있다

### Requirement: 지휘 규칙은 짧게 핵심만 담아야 한다

훅이 넣는 지휘 규칙은 8줄을 넘지 않아야 한다(SHALL). 최소한 다음을 담아야 한다(MUST):
- 메인 세션은 오케스트레이터다. 사용자와 대화하고 지휘만 한다.
- 분석·설계·파일 수정·리뷰·커밋은 `sdd:` 접두사가 붙은 서브에이전트에게 위임한다.
- 일을 처리해 달라는 요청이 오면 `sdd:orchestra` 스킬을 불러 그 절차를 따른다.

지휘 절차의 본문은 orchestra 스킬 한 곳에 있어야 하며(SHALL), 훅에 그 절차를 옮겨 적어서는 안
된다(MUST NOT).

#### Scenario: 지휘 규칙의 내용과 길이

- **WHEN** `openspec/.sdd`가 있는 디렉터리에서 훅 출력의 지휘 규칙 부분을 읽는다
- **THEN** 8줄 이하이다
- **AND** 오케스트레이터, `sdd:` 서브에이전트 위임, `sdd:orchestra` 스킬이 모두 나온다

### Requirement: 점검은 빠르고 문제가 있을 때만 알려야 한다

훅은 매 세션 시작에 돌므로 네트워크나 `npx`를 써서는 안 된다(MUST NOT). 점검 항목은 다음과 같다(SHALL):

| 점검 | 문제일 때 |
|---|---|
| `node`와 `npx`가 PATH에 있는가 | 없으면 `sdd-openspec`이 돌지 않는다고 알린다 |
| 권한 파일(`.claude/settings.json`, `.claude/settings.local.json`)에 `sdd-openspec` 허용이 있는가 | 없으면 `/sdd:init`을 권한다 |
| `openspec/changes/` 아래(`archive` 제외) `tasks.md`의 체크박스가 하나 이상 있고 전부 `[x]`인 change가 있는가 | 있으면 archive 안 된 완료 change로 이름을 알린다 |

문제가 있는 점검만 한 줄씩 알려야 한다(SHALL). 문제가 하나도 없으면 "이상 없음"을 한 줄로
알린다(SHALL).

#### Scenario: 훅이 npx를 부르지 않는다

- **WHEN** 훅 스크립트를 읽는다
- **THEN** `npx`를 실행하는 줄과 네트워크를 쓰는 명령이 없다 (`command -v npx`로 존재만 확인하는 것은 된다)

#### Scenario: 완료됐지만 archive 안 된 change를 알린다

- **WHEN** 표식 `openspec/.sdd`가 있고, `openspec/changes/<이름>/tasks.md`의 체크박스가 모두 `[x]`이며, `openspec/changes/archive/<날짜-이름>/tasks.md`도 모두 `[x]`인 임시 프로젝트에서 훅을 실행한다
- **THEN** 출력에 `<이름>` change가 나온다
- **AND** `openspec/changes/archive/` 아래의 change는 나오지 않는다

#### Scenario: 권한이 없을 때

- **WHEN** 표식 `openspec/.sdd`가 있고 `.claude/settings*.json`에 `sdd-openspec`이 없는 임시 프로젝트에서 훅을 실행한다
- **THEN** `/sdd:init`을 권하는 줄이 나온다
