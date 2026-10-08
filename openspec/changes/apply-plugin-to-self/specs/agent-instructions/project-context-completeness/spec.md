## MODIFIED Requirements

### Requirement: config.yaml의 context에 프로젝트 사정이 채워져 있어야 한다

`openspec/config.yaml`은 주석이 아닌 실제 `context:` 값을 가져야 한다(SHALL).
그 값은 최소한 다음을 담아야 한다(SHALL): 플러그인 `sdd`의 지시문 저장소이고 지시문이
`agents/*.md`·`skills/**/SKILL.md`에 있다는 것, 실행 파일은 bash 스크립트(`install.sh`, `bin/`, `hooks/`)뿐이고
테스트·빌드·CI가 없다는 것, 검증 수단이 `bash -n`(그 스크립트 전부) / `bash install.sh --dry-run` /
`claude plugin validate` 두 명령 / OpenSpec CLI 실측 / grep 대조라는 것, 문서는 한국어이며 쉬운 말을 쓴다는 것,
지시문 파일은 `Edit` 부분 수정만 한다는 것. 옛 지시문 경로 `.claude/agents/*.md`를 적어서는 안 된다(MUST NOT).

#### Scenario: 에이전트가 프로젝트 사정을 CLI에서 받는다

- **WHEN** `openspec instructions proposal --change "<이름>" --json`을 돌린다
- **THEN** 응답에 `context` 키가 실제로 존재하고 그 안에 위 내용이 들어 있다
  (최소한 `agents/`, `skills/`, `claude plugin validate`, `bash -n`, 한국어·쉬운 말, `Edit` 부분 수정)
- **AND** 오케스트레이터가 스택 정보를 프롬프트에 손으로 적어 보내지 않아도 된다

#### Scenario: 플러그인 전환 전 사실이 남아 있지 않다

- **WHEN** 같은 응답의 `context` 값을 읽는다
- **THEN** `.claude/agents/*.md`라는 옛 지시문 경로가 없다
- **AND** "실행 코드가 없다"는 단언과, 검증 수단을 `claude plugin validate` 없이 나열하며 "뿐"이라 끝맺는 문장이 없다
