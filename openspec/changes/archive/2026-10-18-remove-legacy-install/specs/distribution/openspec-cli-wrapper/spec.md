## MODIFIED Requirements

### Requirement: 지시문은 래퍼를 먼저 써야 한다

에이전트 파일, orchestra 스킬, sdd-rules 스킬, sdd-sync 스킬의 openspec 실행 예시는 `sdd-openspec`으로
적어야 한다(SHALL). 모델은 예시 글자를 그대로 따라 치므로, `openspec`으로 남기면 PATH의 다른 버전이 돈다.

sdd-rules 스킬의 "쓰는 스킬" 절은 대체 규칙 하나를 적어야 한다(MUST): PATH의 `openspec`이 1.14.1 이상이면
그대로 써도 된다. `sdd-openspec`이 PATH에 없을 때 `openspec`으로 바꿔 치라는 규칙은 sdd-rules 스킬과
orchestra 스킬 어디에도 두어서는 안 된다(MUST NOT) — 설치 수단이 플러그인 하나라 `sdd-openspec`은 늘 있다.

메인 spec 시나리오 안의 검증 명령(`openspec validate ...` 등)은 이 요구사항 때문에 바꾸지 않는다(SHALL).

#### Scenario: 예시가 래퍼를 쓴다

- **WHEN** `grep -nE '(^|[^-])\bopenspec (status|instructions|validate|new|archive|list|show|doctor|context|schemas|view|--version)' agents/*.md skills/orchestra/SKILL.md skills/sdd-rules/SKILL.md skills/sdd-sync/SKILL.md`를 돌린다
- **THEN** 결과가 0건이다

#### Scenario: 대체 규칙이 한 곳에 있다

- **WHEN** sdd-rules 스킬의 "쓰는 스킬" 절을 읽고, `grep -n 'PATH에 없으면' skills/sdd-rules/SKILL.md skills/orchestra/SKILL.md`를 돌린다
- **THEN** "쓰는 스킬" 절에 1.14.1 이상이면 `openspec`을 그대로 써도 된다는 규칙이 있다
- **AND** grep 결과가 0건이다
- **AND** 에이전트 파일에는 같은 규칙의 사본이 없다
