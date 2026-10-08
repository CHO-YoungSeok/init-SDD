## MODIFIED Requirements

### Requirement: 7개 기존 에이전트 파일은 Agent 도구를 가져야 한다

preparer, analyzer, designer, worker, reviewer, regression-verifier, finalizer 7개 에이전트 파일
(플러그인 루트 `agents/<이름>.md`)의 `tools:` 줄은 `Agent`를 포함해야 한다(SHALL). 그 외 기존 `tools:`
값(`Read`, `Grep`, `Glob`, `Bash`, 파일별로 있는 `Write`/`Edit`/`NotebookEdit`/`TodoWrite`/`Skill`)은 그대로
유지되어야 한다(MUST NOT 제거). `model:` 줄은 이 요구사항 때문에 바뀌지 않는다(MUST NOT) — 각 에이전트의
기본 모델은 그 파일의 `model:` 한 줄이 정하고, 바꾸고 싶은 사용자는 자기 쪽 설정으로 바꾼다.

frontmatter의 `skills:` 줄은 공용 규칙 주입(`agent-instructions/shared-pipeline-rules`)이
정한 값을 가진다(SHALL). 그 밖의 키(`name:`, `description:`)는 이 요구사항 때문에 바뀌지 않는다.

#### Scenario: 7개 파일의 tools 줄에 Agent가 있다

- **WHEN** 7개 파일 각각의 `tools:` 줄을 읽는다
- **THEN** 모두 `Agent`를 포함한다
- **AND** 이전에 있던 다른 도구 이름은 하나도 빠지지 않았다

#### Scenario: frontmatter의 나머지가 그대로다

- **WHEN** 변경 뒤 7개 파일의 frontmatter를 변경 전과 대조한다
- **THEN** `model:` 값이 바뀌지 않았다
- **AND** `---`로 열리고 닫히는 구조와 `name:`, `description:` 키가 그대로 있다
- **AND** `skills:` 줄은 `sdd-rules`(finalizer는 `sdd-sync`도)를 담고 있다

## ADDED Requirements

### Requirement: code-explorer를 부르는 이름은 플러그인 접두사를 따라야 한다

sdd-rules 스킬의 `code-explorer 부르기` 절은 `Agent` 도구의 `subagent_type`으로 `sdd:code-explorer`를
쓰라고 적어야 한다(SHALL). 그 결과가 `not found`이면 접두사 없는 `code-explorer`로 다시 부르라는 대비
규칙을 같은 절에 적어야 한다(SHALL) — 기존 설치 방식으로 깐 에이전트는 접두사 없이 실린다.

호출 대상을 `code-explorer` 하나로 좁히는 것은 **글로 된 규칙으로 유지한다**(SHALL). `tools:`에
`Agent(sdd:code-explorer)`처럼 대상을 적어도 다른 에이전트가 실제로 불리므로(실측, Claude Code 2.1.294),
도구 수준 강제를 쓴다고 문서에 적어서는 안 된다(MUST NOT).

#### Scenario: 부르는 이름과 대비 규칙

- **WHEN** sdd-rules 스킬의 `code-explorer 부르기` 절을 읽는다
- **THEN** `sdd:code-explorer`를 부르라는 지시가 있다
- **AND** `not found`면 `code-explorer`로 다시 부르라는 대비 규칙이 있다

#### Scenario: 도구 수준 강제를 주장하지 않는다

- **WHEN** 7개 에이전트 파일의 `tools:` 줄을 읽는다
- **THEN** `Agent(` 꼴로 대상을 적은 항목이 없다
