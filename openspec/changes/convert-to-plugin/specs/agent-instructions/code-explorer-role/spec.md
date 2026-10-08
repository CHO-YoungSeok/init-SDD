## MODIFIED Requirements

### Requirement: code-explorer 에이전트 파일이 정해진 자리에 정해진 frontmatter로 있어야 한다

code-explorer 에이전트 파일(플러그인 루트 `agents/code-explorer.md`)이 존재해야 한다(SHALL). frontmatter는
다른 7개 에이전트 파일과 같은 형식(`---`로 열고 닫는 YAML)을 따라야 하며(MUST), 다음 키를 모두 가져야
한다(SHALL): `name: code-explorer`, `description:`(코드·스펙·문서를 탐색·검색하는 역할과
언제 불리는지를 담는다), `model: haiku`, `tools:`.

`model:`로 시작하는 줄은 파일에 정확히 하나여야 한다(MUST) — 같은 키가 두 번 있으면 어느 값으로
도는지 읽는 사람이 알 수 없다. code-explorer는 읽기 전용 보조 에이전트라 가벼운 모델로 고정한다.

#### Scenario: 파일 존재와 frontmatter 형식

- **WHEN** code-explorer 에이전트 파일(`agents/code-explorer.md`)을 읽는다
- **THEN** 파일이 존재하고 `---`로 열리고 닫히는 frontmatter에 `name: code-explorer`,
  `description:`, `model: haiku`, `tools:` 키가 모두 있다
- **AND** `model:`로 시작하는 줄이 정확히 하나다

#### Scenario: 에이전트 파일이 8개다

- **WHEN** `agents/*.md`를 센다
- **THEN** 개수가 8개다 (기존 7개 + `code-explorer.md`)

### Requirement: code-explorer의 존재가 README에도 반영돼야 한다

`README.md`는 `code-explorer`가 있다는 것과, 이 에이전트가 파이프라인 7개 서브에이전트와 성격이 다른
**보조 에이전트**라는 것을 알려야 한다(SHALL). 기존 "7개 서브에이전트" 표의 행 수를 늘리지 않아도 된다 —
표는 파이프라인 7개를 그대로 나타내고, `code-explorer`는 그 표 밖에서 별도로 서술한다(MUST).

#### Scenario: README가 code-explorer를 설명한다

- **WHEN** `README.md`에서 `code-explorer`를 언급하는 부분을 찾는다
- **THEN** 그 부분이 있고, 파이프라인 7개 표 밖의 보조 에이전트라는 것이 드러난다
- **AND** 없어진 모델 등급 스킬을 언급하지 않는다
