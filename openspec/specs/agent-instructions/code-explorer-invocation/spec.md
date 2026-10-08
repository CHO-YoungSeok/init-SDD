# code-explorer invocation Specification

## Purpose

기존 7개 서브에이전트(preparer, analyzer, designer, worker, reviewer,
regression-verifier, finalizer)가 필요할 때 `code-explorer`를 직접 부를 수 있게 하고,
그 호출 범위가 `code-explorer` 하나로만 좁혀지게 한다. 이 저장소의 원칙("오케스트레이터만
지휘하고 서브에이전트는 직접 일한다")에서 벗어나는 구조 변경이므로, 그 이탈이 `code-explorer`
하나로만 한정된다는 것을 지침 문서 자체가 보장해야 한다.

## Requirements

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

### Requirement: code-explorer를 언제 부르는지 안내는 sdd-rules에 한 벌로 있고 7개 에이전트에 주입되어야 한다

code-explorer를 언제 부르는지 안내는 `skills/sdd-rules/SKILL.md`의
`code-explorer 부르기` 절 **한 곳에** 있어야 한다(SHALL). 그 절은 최소한 다음을 담아야
한다(MUST): 코드베이스나 spec을 넓게 뒤지거나 찾아야 할 때 `code-explorer`를 부를 수 있다는 것,
그 결과를 받아서 자기 일을 계속한다는 것, 다른 서브에이전트는 직접 부르지 않는다는 것.

7개 에이전트는 frontmatter `skills:`의 `sdd-rules`로 이 안내를 받는다(SHALL). 도구만 주고 언제
쓰는지 적지 않으면 아무도 안 쓸 수 있다는 것이 이 저장소가 analyzer 옵트인에서 얻은
교훈이므로, 안내가 주입되지 않는 에이전트에 `Agent` 도구만 남겨 두어서는 안 된다(MUST NOT).

#### Scenario: 안내 문단이 있다

- **WHEN** `skills/sdd-rules/SKILL.md`에서 `code-explorer 부르기` 절을 읽는다
- **THEN** 코드베이스를 넓게 뒤질 때 부른다는 것과 결과를 받아 이어서 일한다는 것이 담겨 있다

#### Scenario: 7개 에이전트가 안내를 주입받는다

- **WHEN** 7개 에이전트 파일의 frontmatter `skills:`를 읽는다
- **THEN** 모두 `sdd-rules`가 있다
- **AND** 에이전트 본문에는 `code-explorer 부르기` 절이 따로 없다

### Requirement: 서브에이전트 간 호출 범위는 code-explorer 하나로 좁아야 한다

7개 에이전트 파일과 그들에게 주입되는 `skills/sdd-rules/SKILL.md` 어디에도
`code-explorer` 외의 다른 서브에이전트 이름(`preparer`, `analyzer`, `designer`, `worker`,
`reviewer`, `regression-verifier`, `finalizer`)을 `Agent` 도구로 부르라는 지시가 있어서는
안 된다(MUST NOT).

오케스트레이터만 지휘한다는 절대 규칙(`skills/orchestra/SKILL.md`의 "절대 규칙"
절)은 그대로 유지되어야 한다(SHALL). 7개 에이전트가 `code-explorer` 하나만 예외적으로 부를 수
있다는 좁은 구멍 하나이며, "아무 에이전트나 서로 부를 수 있다"로 확대 해석되어서는 안
된다(MUST NOT).

#### Scenario: code-explorer 외의 다른 이름을 부르는 지시가 없다

- **WHEN** 7개 에이전트 파일과 sdd-rules 전체에서 `Agent` 도구로 다른 서브에이전트를 부르라는 지시를 찾는다
- **THEN** `code-explorer`를 부르라는 지시만 있고, 그 외 서브에이전트 이름을 부르라는 지시는 없다

#### Scenario: 절대 규칙과의 공존이 문서에 남아 있다

- **WHEN** `skills/orchestra/SKILL.md`의 "절대 규칙" 절과 그 근처를 읽는다
- **THEN** 오케스트레이터만 지휘한다는 다섯 가지 절대 규칙이 그대로 있다
- **AND** `code-explorer`는 7개 에이전트가 직접 부를 수 있는 유일한 예외라는 것이 한 줄
  이상으로 드러난다

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

### Requirement: 에이전트의 기본 모델은 각 파일의 model 줄 하나가 정해야 한다

각 에이전트의 기본 모델은 그 파일 frontmatter의 `model:` 한 줄이 정한다(SHALL). `tools:`에
`Agent`를 두는 일 때문에 `model:`, `name:`, `description:` 키를 바꾸거나 지워서는 안 된다(MUST NOT).
모델을 바꾸고 싶은 사용자는 자기 쪽 설정으로 바꾼다.

#### Scenario: 에이전트마다 model 줄이 하나 있다

- **WHEN** 7개 에이전트 파일의 frontmatter에서 `model:` 줄을 센다
- **THEN** 파일마다 정확히 하나다
- **AND** 그 값이 `opus`, `sonnet`, `haiku` 중 하나다
