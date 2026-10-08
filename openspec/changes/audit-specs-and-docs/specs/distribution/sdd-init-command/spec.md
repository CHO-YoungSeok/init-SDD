# Spec Delta

## MODIFIED Requirements

### Requirement: 초기화 스킬은 /sdd:init으로 불려야 한다

초기화 스킬은 플러그인의 `skills/init/SKILL.md`에 있어야 한다(SHALL). 플러그인 스킬은 `sdd:<디렉터리 이름>`으로
불리므로 이 위치여야 `/sdd:init`이 된다.

frontmatter는 `name`과 `description`만 가져야 하며(SHALL), `allowed-tools`를 넣어서는 안 된다(MUST NOT) —
이 스킬은 파일을 만들고 git 명령을 돌린다. `description`에는 사용자가 실제로 할 만한 부르는 말이 들어
있어야 한다(MUST) (예: "SDD 초기화", "이 프로젝트에 SDD 세팅", "openspec 시작").

#### Scenario: 스킬 파일과 frontmatter

- **WHEN** `skills/init/SKILL.md`를 읽는다
- **THEN** `---`로 열고 닫히는 frontmatter에 `name`과 `description`만 있다
- **AND** `allowed-tools`가 없고 코드펜스 줄 개수가 짝수다

### Requirement: openspec 초기화는 최소로 해야 한다

`openspec/config.yaml`이 없으면 `sdd-openspec init --tools none --no-animation`으로 초기화해야 한다(SHALL). 이 명령은
`openspec/config.yaml`, `openspec/specs/.gitkeep`, `openspec/changes/archive/.gitkeep`만 만들고 `.claude/`를
건드리지 않는다(실측). 스캐폴드 스킬과 명령(`--tools claude`)을 깔아서는 안 된다(MUST NOT) — 이 파이프라인은
그것에 기대지 않는다.

`openspec/config.yaml`이 이미 있으면 초기화를 건너뛰어야 한다(SHALL). 초기화를 할지는 `openspec/` 디렉터리가
아니라 `openspec/config.yaml` 파일이 있는지로 정한다(SHALL).

#### Scenario: 빈 프로젝트에서 초기화

- **WHEN** 커밋이 하나 있는 빈 `mktemp -d` 프로젝트에서 초기화 단계를 돌린다
- **THEN** 종료코드가 0이고 `openspec/config.yaml`이 생긴다
- **AND** `.claude/` 디렉터리가 생기지 않는다

#### Scenario: 이미 초기화된 프로젝트

- **WHEN** `openspec/config.yaml`이 있는 프로젝트에서 초기화 단계를 돌린다
- **THEN** 그 파일이 바뀌지 않고 건너뛰었다고 알린다
