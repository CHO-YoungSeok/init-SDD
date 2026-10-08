## MODIFIED Requirements

### Requirement: 공용 규칙은 frontmatter skills로 주입되어야 한다

code-explorer를 뺀 7개 에이전트 파일(preparer, analyzer, designer, worker, reviewer,
regression-verifier, finalizer)의 frontmatter `skills:`에는 `sdd-rules`가 있어야
한다(SHALL). finalizer는 `sdd-sync`도 가져야 한다(SHALL). 어느 에이전트의 `skills:`에도
`openspec-`로 시작하는 스킬 이름이 있어서는 안 된다(MUST NOT). 스킬 이름에는 플러그인 접두사(`sdd:`)를
붙이지 않는다(SHALL) — 플러그인 안에서도 접두사 없는 이름이 주입되고(실측), 기존 설치본에서도 같은 글자로
동작한다.

`code-explorer.md`에는 `skills:`를 넣지 않는다(SHALL) — 공용 규칙은 다른 에이전트를 부르고
산출물을 다루는 에이전트를 위한 것이고, code-explorer는 읽기만 하는 보조 에이전트다.

주입이 실제로 일어나는지는 플러그인을 실은 새 Claude Code 프로세스(`claude -p --plugin-dir <플러그인 루트>`)에서
확인할 수 있어야 한다(SHALL). frontmatter `skills:`는 세션이 시작될 때 읽히므로 같은 세션 안에서는 확인할
수 없다.

#### Scenario: frontmatter의 skills 줄

- **WHEN** 7개 에이전트 파일의 frontmatter를 읽는다
- **THEN** 모두 `skills:`에 `sdd-rules`가 있고, finalizer만 `sdd-sync`도 있다
- **AND** 어디에도 `openspec-`로 시작하는 스킬 이름이 없다
- **AND** `code-explorer.md`에는 `skills:` 줄이 없다

#### Scenario: 새 프로세스에서 주입을 확인한다

- **WHEN** 저장소 루트에서 새 `claude -p --plugin-dir .` 프로세스를 띄워, 각 에이전트(`sdd:<이름>`)에게 sdd-rules에만 있는 문장을 인용하게 한다
- **THEN** 7개 에이전트는 그 문장을 인용하고, code-explorer는 인용하지 못한다
- **AND** 그 방법과 결과가 change의 검증 기록이나 `review.md`에 남아 있다

## ADDED Requirements

### Requirement: openspec 호출 표기와 에이전트 이름 규칙은 sdd-rules 한 곳에 있어야 한다

서브에이전트가 따르는 다음 두 규칙은 sdd-rules 스킬에 한 번씩만 있어야 한다(SHALL). 에이전트 파일에 사본을
두어서는 안 된다(MUST NOT).

- openspec 호출 표기: 명령은 `sdd-openspec`으로 친다. 대체 규칙(PATH의 `openspec`이 1.14.1 이상이면 그대로
  써도 된다, `sdd-openspec`이 없으면 `openspec`을 쓰고 버전을 보고한다)은 "쓰는 스킬" 절에 둔다.
- 에이전트 이름: 서브에이전트를 부를 때는 `sdd:<이름>`을 쓰고, `not found`면 접두사 없는 이름으로 다시
  부른다. "code-explorer 부르기" 절에 둔다.

두 규칙은 기존 일곱 절 안에 들어가야 하며(SHALL), 절을 새로 늘려서는 안 된다(MUST NOT).

#### Scenario: 두 규칙이 sdd-rules에 있고 에이전트에는 없다

- **WHEN** sdd-rules 스킬과 `agents/*.md`에서 "1.14.1"과 "not found"를 찾는다
- **THEN** sdd-rules에서 "1.14.1"은 "쓰는 스킬" 절에만, "not found"는 "code-explorer 부르기" 절에만 나오고 "not found"는 파일 전체에서 한 줄이다
- **AND** `agents/*.md`에는 그 규칙 문장이 없다

#### Scenario: 절 수가 그대로다

- **WHEN** sdd-rules 스킬의 `## ` 절 제목을 센다
- **THEN** 일곱 개다
