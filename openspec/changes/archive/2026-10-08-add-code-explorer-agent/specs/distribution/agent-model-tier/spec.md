## ADDED Requirements

### Requirement: code-explorer는 등급 표 밖에 있어야 하고 표 자체는 늘어나지 않아야 한다

`code-explorer`가 새로 생겨도 `.claude/skills/agent-model-tier/SKILL.md`의 `normal` /
`semi-lower` / `lower` 등급 표는 여전히 에이전트 7개 행만 가져야 한다(MUST NOT 늘어남).
`code-explorer`는 이 스킬이 순회하는 대상이 아니고 언제나 `haiku`로 고정된다.

표 아래(또는 표와 같은 절 안)에 "`code-explorer`는 등급 표 밖, 항상 haiku"라는 취지의
한 줄 안내가 있어야 한다(SHALL). 스킬의 등급 판별·전환 절차는 `.claude/agents/code-explorer.md`의
`model:` 줄을 읽거나 고치지 않아야 한다(MUST NOT) — 이 스킬이 순회하는 파일 목록은 기존
7개 에이전트 파일 그대로다.

#### Scenario: 등급 표는 7행 그대로다

- **WHEN** 변경 뒤 `.claude/skills/agent-model-tier/SKILL.md`의 `normal`/`semi-lower`/`lower`
  표를 읽는다
- **THEN** 각 표가 여전히 7행이고 `code-explorer` 행이 없다

#### Scenario: 표 밖이라는 한 줄 안내가 있다

- **WHEN** 표 근처의 서술을 읽는다
- **THEN** `code-explorer`는 등급 표 밖에 있고 항상 `haiku`로 고정된다는 문장이 있다

#### Scenario: 등급 전환이 code-explorer를 건드리지 않는다

- **WHEN** 등급을 `normal`에서 `lower`로, 다시 `normal`로 되돌린다
- **THEN** `.claude/agents/code-explorer.md`의 `model:` 값은 두 전환 전체에 걸쳐 `haiku`로
  바뀌지 않는다
- **AND** `git diff`로 봤을 때 `code-explorer.md`는 등급 전환의 변경 대상에 없다
