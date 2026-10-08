# code-explorer invocation Specification

## Purpose

기존 7개 서브에이전트(preparer, analyzer, designer, worker, reviewer,
regression-verifier, finalizer)가 필요할 때 `code-explorer`를 직접 부를 수 있게 하고,
그 호출 범위가 `code-explorer` 하나로만 좁혀지게 한다. 이 저장소의 원칙("오케스트레이터만
지휘하고 서브에이전트는 직접 일한다")에서 벗어나는 구조 변경이므로, 그 이탈이 `code-explorer`
하나로만 한정된다는 것을 지침 문서 자체가 보장해야 한다.

## Requirements

### Requirement: 7개 기존 에이전트 파일은 Agent 도구를 가져야 한다

`.claude/agents/preparer.md`, `.claude/agents/analyzer.md`, `.claude/agents/designer.md`,
`.claude/agents/worker.md`, `.claude/agents/reviewer.md`,
`.claude/agents/regression-verifier.md`, `.claude/agents/finalizer.md` 7개 파일의
`tools:` 줄은 `Agent`를 포함해야 한다(SHALL). 그 외 기존 `tools:` 값(`Read`, `Grep`,
`Glob`, `Bash`, 파일별로 있는 `Write`/`Edit`/`NotebookEdit`/`TodoWrite`/`Skill`)은 그대로
유지되어야 한다(MUST NOT 제거). `model:` 줄은 건드리지 않는다(MUST NOT) —
등급은 `agent-model-tier` 스킬이나 사용자의 로컬 설정이 관리하는 값이다.

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

### Requirement: code-explorer를 언제 부르는지 안내는 sdd-rules에 한 벌로 있고 7개 에이전트에 주입되어야 한다

code-explorer를 언제 부르는지 안내는 `.claude/skills/sdd-rules/SKILL.md`의
`code-explorer 부르기` 절 **한 곳에** 있어야 한다(SHALL). 그 절은 최소한 다음을 담아야
한다(MUST): 코드베이스나 spec을 넓게 뒤지거나 찾아야 할 때 `code-explorer`를 부를 수 있다는 것,
그 결과를 받아서 자기 일을 계속한다는 것, 다른 서브에이전트는 직접 부르지 않는다는 것.

7개 에이전트는 frontmatter `skills:`의 `sdd-rules`로 이 안내를 받는다(SHALL). 도구만 주고 언제
쓰는지 적지 않으면 아무도 안 쓸 수 있다는 것이 이 저장소가 analyzer 옵트인에서 얻은
교훈이므로, 안내가 주입되지 않는 에이전트에 `Agent` 도구만 남겨 두어서는 안 된다(MUST NOT).

#### Scenario: 안내 문단이 있다

- **WHEN** `.claude/skills/sdd-rules/SKILL.md`에서 `code-explorer 부르기` 절을 읽는다
- **THEN** 코드베이스를 넓게 뒤질 때 부른다는 것과 결과를 받아 이어서 일한다는 것이 담겨 있다

#### Scenario: 7개 에이전트가 안내를 주입받는다

- **WHEN** 7개 에이전트 파일의 frontmatter `skills:`를 읽는다
- **THEN** 모두 `sdd-rules`가 있다
- **AND** 에이전트 본문에는 `code-explorer 부르기` 절이 따로 없다

### Requirement: 서브에이전트 간 호출 범위는 code-explorer 하나로 좁아야 한다

7개 에이전트 파일과 그들에게 주입되는 `.claude/skills/sdd-rules/SKILL.md` 어디에도
`code-explorer` 외의 다른 서브에이전트 이름(`preparer`, `analyzer`, `designer`, `worker`,
`reviewer`, `regression-verifier`, `finalizer`)을 `Agent` 도구로 부르라는 지시가 있어서는
안 된다(MUST NOT).

오케스트레이터만 지휘한다는 절대 규칙(`.claude/skills/orchestra/SKILL.md`의 "절대 규칙"
절)은 그대로 유지되어야 한다(SHALL). 7개 에이전트가 `code-explorer` 하나만 예외적으로 부를 수
있다는 좁은 구멍 하나이며, "아무 에이전트나 서로 부를 수 있다"로 확대 해석되어서는 안
된다(MUST NOT).

#### Scenario: code-explorer 외의 다른 이름을 부르는 지시가 없다

- **WHEN** 7개 에이전트 파일과 sdd-rules 전체에서 `Agent` 도구로 다른 서브에이전트를 부르라는 지시를 찾는다
- **THEN** `code-explorer`를 부르라는 지시만 있고, 그 외 서브에이전트 이름을 부르라는 지시는 없다

#### Scenario: 절대 규칙과의 공존이 문서에 남아 있다

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 "절대 규칙" 절과 그 근처를 읽는다
- **THEN** 오케스트레이터만 지휘한다는 다섯 가지 절대 규칙이 그대로 있다
- **AND** `code-explorer`는 7개 에이전트가 직접 부를 수 있는 유일한 예외라는 것이 한 줄
  이상으로 드러난다
