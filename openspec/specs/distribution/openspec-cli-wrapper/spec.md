# distribution/openspec-cli-wrapper Specification

## Purpose
SDD 파이프라인이 사용자 PATH의 openspec 버전에 끌려가지 않도록, 플러그인 실행 파일 `sdd-openspec`이 고정 버전의 openspec CLI를 실행하게 하고 지시문이 그 래퍼를 먼저 쓰게 한다.

## Requirements

### Requirement: 래퍼는 고정 버전 openspec을 실행해야 한다

플러그인의 `bin/sdd-openspec`은 `@fission-ai/openspec@1.14.1`을 `npx -y`로 실행해야 한다(SHALL).
받은 인자를 모두 그대로 넘기고(MUST), 종료코드를 그대로 돌려주어야 한다(MUST) — 에이전트는 종료코드로
성공·실패를 판정한다. 버전 문자열은 파일 안 한 곳에만 있어야 한다(SHALL).

이름은 `openspec`과 달라야 한다(MUST). 플러그인 `bin/`은 PATH 끝에 붙으므로 같은 이름이면 사용자의
전역 `openspec`이 먼저 잡힌다.

실행 권한이 있어야 한다(MUST).

#### Scenario: 고정 버전이 나온다

- **WHEN** `bin/sdd-openspec --version; echo $?`를 돌린다
- **THEN** 출력이 `1.14.1`이고 종료코드가 0이다

#### Scenario: 종료코드를 그대로 돌려준다

- **WHEN** openspec 저장소가 아닌 임시 디렉터리에서 실패하는 명령(예: 없는 change에 `bin/sdd-openspec status --change nope`)을 돌린다
- **THEN** 종료코드가 0이 아니다

#### Scenario: 실행 파일이다

- **WHEN** `test -x bin/sdd-openspec; echo $?`를 돌린다
- **THEN** 종료코드가 0이다

### Requirement: 지시문은 래퍼를 먼저 써야 한다

에이전트 파일, orchestra 스킬, sdd-rules 스킬, sdd-sync 스킬의 openspec 실행 예시는 `sdd-openspec`으로
적어야 한다(SHALL). 모델은 예시 글자를 그대로 따라 치므로, `openspec`으로 남기면 PATH의 다른 버전이 돈다.

sdd-rules 스킬의 "쓰는 스킬" 절은 두 대체 규칙을 적어야 한다(MUST): PATH의 `openspec`이 1.14.1 이상이면
그대로 써도 된다. `sdd-openspec`이 없으면(기존 설치 방식) `openspec`을 쓰고 그 버전을 보고서에 적는다.

메인 spec 시나리오 안의 검증 명령(`openspec validate ...` 등)은 이 요구사항 때문에 바꾸지 않는다(SHALL).

#### Scenario: 예시가 래퍼를 쓴다

- **WHEN** `grep -nE '(^|[^-])\bopenspec (status|instructions|validate|new|archive|list|show|doctor|context|schemas|view|--version)' agents/*.md skills/orchestra/SKILL.md skills/sdd-rules/SKILL.md skills/sdd-sync/SKILL.md`를 돌린다
- **THEN** 결과가 0건이다

#### Scenario: 대체 규칙이 한 곳에 있다

- **WHEN** sdd-rules 스킬의 "쓰는 스킬" 절을 읽는다
- **THEN** 1.14.1 이상이면 `openspec`을 그대로 써도 된다는 규칙과, `sdd-openspec`이 없으면 `openspec`을 쓰고 버전을 보고한다는 규칙이 있다
- **AND** 에이전트 파일에는 같은 규칙의 사본이 없다

### Requirement: 권한 목록에 래퍼가 들어 있어야 한다

이 저장소의 `.claude/settings.json` `permissions.allow`에는 `Bash(sdd-openspec:*)`가 있어야 한다(SHALL).
`/sdd:init`이 사용자에게 보여 주는 권한 목록에도 `Bash(sdd-openspec:*)`가 들어 있어야 한다(SHALL).

#### Scenario: 권한 항목

- **WHEN** `.claude/settings.json`을 읽는다
- **THEN** `permissions.allow`에 `Bash(sdd-openspec:*)`가 있다
- **AND** 기존 항목은 하나도 빠지지 않았다
