## REMOVED Requirements

### Requirement: code-explorer를 부르는 이름은 플러그인 접두사를 따라야 한다

**Reason**: 설치 수단이 플러그인 하나가 되어 `code-explorer`는 늘 `sdd:` 접두사와 함께 실린다. `not found`일 때 접두사 없는 이름으로 다시 부르는 대비 규칙과 그 시나리오는 지킬 대상이 없다.
**Migration**: 아래 ADDED 요구사항 "code-explorer는 sdd 접두사 이름 하나로만 불러야 한다"가 `sdd:code-explorer` 호출 규칙과 글로 된 호출 범위 규칙을 이어받고, 대비 규칙을 두지 않는다고 정한다.

## ADDED Requirements

### Requirement: code-explorer는 sdd 접두사 이름 하나로만 불러야 한다

sdd-rules 스킬의 `code-explorer 부르기` 절은 `Agent` 도구의 `subagent_type`으로 `sdd:code-explorer`를
쓰라고 적어야 한다(SHALL). 그 결과가 `not found`일 때 접두사 없는 `code-explorer`로 다시 부르라는 대비
규칙을 두어서는 안 된다(MUST NOT) — 설치 수단이 플러그인 하나라 에이전트는 늘 접두사와 함께 실린다.

호출 대상을 `code-explorer` 하나로 좁히는 것은 **글로 된 규칙으로 유지한다**(SHALL). `tools:`에
`Agent(sdd:code-explorer)`처럼 대상을 적어도 다른 에이전트가 실제로 불리므로(실측, Claude Code 2.1.294),
도구 수준 강제를 쓴다고 문서에 적어서는 안 된다(MUST NOT).

#### Scenario: 부르는 이름이 하나다

- **WHEN** sdd-rules 스킬의 `code-explorer 부르기` 절을 읽는다
- **THEN** `sdd:code-explorer`를 부르라는 지시가 있다
- **AND** `not found`면 접두사 없는 `code-explorer`로 다시 부르라는 대비 규칙이 없다

#### Scenario: 도구 수준 강제를 주장하지 않는다

- **WHEN** 7개 에이전트 파일의 `tools:` 줄을 읽는다
- **THEN** `Agent(` 꼴로 대상을 적은 항목이 없다
