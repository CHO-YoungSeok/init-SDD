# project-context-completeness Specification

## Purpose

이 저장소 자신의 `openspec/config.yaml`이 `context:`로 프로젝트 사정(지시문 위치, 실행 파일, 검증 수단, 문서 관례)을 실제로 에이전트에게 전달하게 하고, 그 값이 YAML 들여쓰기 실수로 조용히 무시되지 않게 한다. 그래서 사이클마다 스택 정보를 사람이 손으로 프롬프트에 적지 않아도 된다.

## Requirements

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

### Requirement: context 키는 YAML 들여쓰기가 깨지지 않아야 한다

`context:` 키 자체가 줄 맨 앞(0칸)에 있어야 한다(MUST). 블록 스칼라(`|`)의 **내용**은
들여쓴다(2칸) — 이건 정상이고 필요하다. 키가 들여쓰기되면 OpenSpec이 값을 통째로 무시한다.

#### Scenario: 파싱 경고가 없다

- **WHEN** `openspec context`를 돌린다
- **THEN** 출력에 `Warning: could not parse ... ignoring it.`이 없다

#### Scenario: 종료코드만 보면 안 된다

- **WHEN** `context:` 키가 들여쓰기된 상태로 `openspec context`를 돌린다
- **THEN** 경고를 내면서도 종료코드는 0이라 통과처럼 보인다 (실측)
- **AND** 따라서 진짜 증거는 `openspec instructions proposal --json` 응답의 `context` 키 존재 여부다

#### Scenario: 주석 예시를 그대로 풀어 쓰지 않는다

- **WHEN** `config.yaml`의 예시 주석 `#   context: |`에서 `#`만 지운다
- **THEN** `   context: |`(3칸 들여쓰기)가 되어 값이 무시되므로, 이 방식으로 채우면 안 된다
