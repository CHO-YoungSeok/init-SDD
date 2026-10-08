# Spec Delta

## MODIFIED Requirements

### Requirement: 7개 기존 에이전트 파일은 Agent 도구를 가져야 한다

preparer, analyzer, designer, worker, reviewer, regression-verifier, finalizer 7개 에이전트 파일
(플러그인 루트 `agents/<이름>.md`)의 `tools:` 줄은 `Agent`를 포함해야 한다(SHALL). 그 밖의 `tools:`
값(`Read`, `Grep`, `Glob`, `Bash`, 파일별로 있는 `Write`/`Edit`/`NotebookEdit`/`TodoWrite`/`Skill`)은 유지되어야
한다(MUST).

frontmatter의 `skills:` 줄은 공용 규칙 주입(`agent-instructions/shared-pipeline-rules`)이
정한 값을 가진다(SHALL).

#### Scenario: 7개 파일의 tools 줄에 Agent가 있다

- **WHEN** 7개 파일 각각의 `tools:` 줄을 읽는다
- **THEN** 모두 `Agent`를 포함한다
- **AND** 모두 `Read`, `Grep`, `Glob`, `Bash`를 포함한다

#### Scenario: frontmatter의 나머지가 그대로다

- **WHEN** 7개 파일의 frontmatter를 읽는다
- **THEN** 각 파일에 `model:` 줄이 정확히 하나 있다
- **AND** `---`로 열리고 닫히는 구조와 `name:`, `description:` 키가 있다
- **AND** `skills:` 줄은 `sdd-rules`(finalizer는 `sdd-sync`도)를 담고 있다

## ADDED Requirements

### Requirement: 에이전트의 기본 모델은 각 파일의 model 줄 하나가 정해야 한다

각 에이전트의 기본 모델은 그 파일 frontmatter의 `model:` 한 줄이 정한다(SHALL). `tools:`에
`Agent`를 두는 일 때문에 `model:`, `name:`, `description:` 키를 바꾸거나 지워서는 안 된다(MUST NOT).
모델을 바꾸고 싶은 사용자는 자기 쪽 설정으로 바꾼다.

#### Scenario: 에이전트마다 model 줄이 하나 있다

- **WHEN** 7개 에이전트 파일의 frontmatter에서 `model:` 줄을 센다
- **THEN** 파일마다 정확히 하나다
- **AND** 그 값이 `opus`, `sonnet`, `haiku` 중 하나다
