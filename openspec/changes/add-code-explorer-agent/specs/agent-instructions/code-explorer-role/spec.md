## Purpose

SDD 파이프라인의 7개 서브에이전트가 코드베이스를 넓게 뒤져야 할 때 위임할 수 있는
읽기 전용 보조 에이전트 `code-explorer`가 갖춰야 할 자리, frontmatter, 역할과 그 경계를
정한다. 산출물을 만들지 않고, 프로젝트 코드나 OpenSpec 산출물을 고치지 않으며, 다른
서브에이전트를 부르지 않는다.

## ADDED Requirements

### Requirement: code-explorer 에이전트 파일이 정해진 자리에 정해진 frontmatter로 있어야 한다

`.claude/agents/code-explorer.md`가 존재해야 한다(SHALL). frontmatter는 다른 7개 에이전트
파일과 같은 형식(`---`로 열고 닫는 YAML)을 따라야 하며(MUST), 다음 키를 모두 가져야
한다(SHALL): `name: code-explorer`, `description:`(코드·스펙·문서를 탐색·검색하는 역할과
언제 불리는지를 담는다), `model: haiku`, `tools:`.

`model:`로 시작하는 줄은 파일에 정확히 하나여야 한다(MUST) — `agent-model-tier` 스킬이
7개 에이전트 파일의 `model:` 줄 개수를 grep으로 세는 방식에 기대고 있어서, 이 파일 자체의
정합성을 위해 같은 형식을 지켜야 한다. 단 `code-explorer`는 그 스킬이 순회하는 7개 목록에
들어가지 않으므로 등급 전환 대상이 아니다.

#### Scenario: 파일 존재와 frontmatter 형식

- **WHEN** `.claude/agents/code-explorer.md`를 읽는다
- **THEN** 파일이 존재하고 `---`로 열리고 닫히는 frontmatter에 `name: code-explorer`,
  `description:`, `model: haiku`, `tools:` 키가 모두 있다
- **AND** `model:`로 시작하는 줄이 정확히 하나다

#### Scenario: 에이전트 파일이 8개다

- **WHEN** `.claude/agents/*.md`를 센다
- **THEN** 개수가 8개다 (기존 7개 + `code-explorer.md`)

### Requirement: code-explorer는 읽기 전용이며 다른 서브에이전트를 부를 수 없다

`code-explorer.md`의 `tools:` 줄은 `Read`, `Grep`, `Glob`, `Bash`만 가져야 한다(SHALL).
`Write`, `Edit`, `NotebookEdit`, `Agent`, `Skill`이 있어서는 안 된다(MUST NOT).

`Agent`를 주지 않는 이유는 안전 기본값이다(SHALL 문서화): 서브에이전트가 서브에이전트를
부르는 패턴이 이번에 처음 생기는데, `code-explorer`까지 다른 에이전트를 부를 수 있게 하면
호출 깊이에 제한이 없어져 몇 단계까지 깊어질지 아무도 보장할 수 없다.

#### Scenario: tools 줄에 쓰기 도구와 Agent가 없다

- **WHEN** `.claude/agents/code-explorer.md`의 `tools:` 줄을 읽는다
- **THEN** `Read`, `Grep`, `Glob`, `Bash`만 있다
- **AND** `Write`, `Edit`, `NotebookEdit`, `Agent`, `Skill` 중 어느 것도 없다

#### Scenario: 도구가 없는 이유가 문서에 남아 있다

- **WHEN** `code-explorer.md`에서 `Agent` 도구를 안 주는 이유를 찾는다
- **THEN** 호출 깊이 제한을 위한 안전 기본값이라는 취지의 문장이 있다

### Requirement: code-explorer의 역할은 탐색·보고로 한정되어야 한다

`code-explorer.md` 본문은 다음을 명시해야 한다(SHALL): 코드, spec(`openspec/`), 문서를
읽고 검색해서 호출한 에이전트에게 결과를 정리해 보고하는 것이 유일한 일이라는 것;
프로젝트 코드나 OpenSpec 산출물(`.claude/`, `openspec/changes/**`, 메인 spec)을 고치지
않는다는 것(MUST NOT); 산출물 파일을 새로 쓰지 않고 보고만 한다는 것(자기 결과물을
디스크에 남기지 않는다).

#### Scenario: 역할 서술

- **WHEN** `code-explorer.md`의 "하는 일" 관련 절을 읽는다
- **THEN** 탐색·검색해서 호출한 에이전트에게 보고하는 것이 일이라고 적혀 있다
- **AND** 코드와 OpenSpec 산출물을 고치지 않는다는 문장이 있다
- **AND** 파일을 새로 만들지 않는다는 문장이 있다

### Requirement: code-explorer의 존재가 README에도 반영돼야 한다

`README.md`는 `code-explorer`가 있다는 것과, 이 에이전트가 `agent-model-tier`의 등급
전환 대상 7개 밖에 있다는 것을 알려야 한다(SHALL). 기존 "7개 서브에이전트" 표의 행 수를
늘리지 않아도 된다 — 표는 등급 전환 대상 7개를 그대로 나타내고, `code-explorer`는 그
표와는 성격이 다르다는 것이 드러나도록 별도로 서술한다(MUST).

#### Scenario: README가 code-explorer를 설명한다

- **WHEN** `README.md`에서 `code-explorer`를 언급하는 부분을 찾는다
- **THEN** 그 부분이 있고, 등급 표(7개 대상) 밖이라는 것이 드러난다
