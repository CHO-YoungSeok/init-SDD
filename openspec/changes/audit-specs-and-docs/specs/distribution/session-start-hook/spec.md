# Spec Delta

## MODIFIED Requirements

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
