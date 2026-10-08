# distribution/sdd-init-command Specification

## Purpose
새 프로젝트에서 한 번 실행하는 `/sdd:init` 스킬의 계약을 정한다. 최소한의 openspec 초기화와 훅 표식, 프로젝트 사정을 담은 context 초안, 기본 브랜치 감지, 사용자가 동의한 권한의 로컬 기록까지 하고, 공유 `.claude/` 파일은 건드리지 않는다.

## Requirements

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

### Requirement: 초기화 단계는 훅 표식을 만들고 여러 번 돌려도 같아야 한다

초기화 단계는 SessionStart 훅을 켜는 표식 파일 `openspec/.sdd`를 만들어야 한다(SHALL). 표식이 이미 있으면
그대로 둔다(SHALL). 표식 안에는 무엇을 켜는 파일인지와 지우면 꺼진다는 안내를 주석으로 적는다(SHALL).
초기화 단계는 여러 번 돌려도 결과가 같아야 한다(SHALL).

#### Scenario: 표식이 생긴다

- **WHEN** 커밋이 하나 있는 빈 `mktemp -d` 프로젝트에서 초기화 단계를 돌린다
- **THEN** `openspec/.sdd`가 생기고 그 안에 지우면 훅이 꺼진다는 주석이 있다

#### Scenario: 초기화를 두 번 돌린다

- **WHEN** 빈 프로젝트에서 초기화 단계를 두 번 돌린다
- **THEN** 두 번 모두 종료코드가 0이다
- **AND** 두 번째 실행 전후의 `git status --porcelain`과 `openspec/` 아래 파일 내용이 같다

### Requirement: context 초안을 만들고 확인받은 뒤에만 써야 한다

스킬은 프로젝트의 스택·테스트 명령·빌드 명령·기본 브랜치를 감지해 `openspec/config.yaml`의 `context:`
초안을 만들어야 한다(SHALL). 감지하지 못한 항목은 비워 두지 말고 "확인 필요"로 표시한다(SHALL).

초안은 사용자에게 보여 주고 **확인을 받은 뒤에만** 파일에 써야 한다(MUST). `config.yaml`에 이미 최상위
`context:`가 있으면 덮어써서는 안 되며(MUST NOT), 초안과 기존 값을 나란히 보여 주고 사용자가 고르게
한다(SHALL).

쓴 뒤에는 `sdd-openspec context`가 경고 없이 읽히는지 확인해야 한다(SHALL) — 들여쓰기가 깨진 YAML은
경고만 내고 파일 전체가 무시된다.

#### Scenario: 초안이 만들어진다

- **WHEN** `package.json`(`scripts.test`, `scripts.build` 포함)이 있는 임시 프로젝트에서 초안 단계를 돌린다
- **THEN** 종료코드가 0이고 출력된 초안에 그 테스트 명령과 빌드 명령이 들어 있다
- **AND** `openspec/config.yaml`은 아직 바뀌지 않았다

#### Scenario: 확인 뒤 기록과 검증

- **WHEN** 사용자가 초안을 확인해 기록 단계를 돌린다
- **THEN** `openspec/config.yaml`에 최상위 `context:`가 생긴다
- **AND** `sdd-openspec context` 출력에 `Warning`이 없다

### Requirement: 기본 브랜치를 감지해야 한다

스킬은 기본 브랜치를 다음 순서로 감지해야 한다(SHALL): 원격 `origin/HEAD`가 가리키는 브랜치 → 로컬에
`main`이 있으면 `main` → `master`가 있으면 `master` → 현재 브랜치. 어느 단계로 정했는지를 함께 알려야
한다(SHALL). 감지한 값은 context 초안에 들어간다(SHALL).

#### Scenario: 원격이 없는 프로젝트

- **WHEN** 원격 없이 `main` 브랜치 하나만 있는 임시 프로젝트에서 감지 단계를 돌린다
- **THEN** 기본 브랜치로 `main`을 알리고 종료코드가 0이다

### Requirement: 권한은 동의를 받아 settings.local.json에만 기록해야 한다

스킬은 추가할 권한 목록을 사용자에게 보여 주어야 한다(SHALL). 목록의 원본은 플러그인 루트의
`.claude/settings.json` `permissions.allow` 한 곳이어야 한다(SHALL). 동의를 받으면 대상 프로젝트의
`.claude/settings.local.json`에만 써야 한다(SHALL): 없으면 만들고, 있으면 빠진 항목만 더한다. 기존 키와
항목을 지워서는 안 된다(MUST NOT). `.claude/settings.json`과 그 밖의 공유 `.claude/` 파일을 고쳐서는 안
된다(MUST NOT). 동의가 없으면 아무것도 쓰지 않는다(SHALL).

`.claude/settings.local.json`이 git에서 무시되는지 `git check-ignore`로 확인하고(SHALL), 무시되지 않으면
알리기만 하며 공유 `.gitignore`를 고쳐서는 안 된다(MUST NOT).

#### Scenario: 권한 목록이 나온다

- **WHEN** 임시 프로젝트에서 권한 목록 단계를 돌린다
- **THEN** 종료코드가 0이고 `Bash(sdd-openspec:*)`를 포함한 목록이 나온다
- **AND** 아무 파일도 바뀌지 않는다

#### Scenario: 동의 뒤 기록해도 공유 파일은 그대로다

- **WHEN** 커밋된 `.claude/settings.json`이 있는 임시 프로젝트에서 기록 단계를 돌리고 전후 `git status --porcelain`을 대조한다
- **THEN** `.claude/settings.local.json`에 목록 항목이 모두 있다
- **AND** `.claude/settings.json`과 `.gitignore`의 내용이 바뀌지 않았다
- **AND** `git status --porcelain`의 차이는 `.claude/settings.local.json` 한 줄(또는 무시되면 0줄)뿐이다

#### Scenario: 이미 있는 항목을 두 번 넣지 않는다

- **WHEN** 기록 단계를 두 번 돌린다
- **THEN** `permissions.allow`에 같은 항목이 두 번 나오지 않는다
- **AND** 원래 있던 다른 키가 그대로 있다

### Requirement: 권한 목록은 래퍼의 첫 실행 내려받기를 알려야 한다

권한 목록 단계는 목록과 함께 "`sdd-openspec`은 첫 실행 때 npm 레지스트리에서 `@fission-ai/openspec`을
받는다"는 안내를 한 줄 내야 한다(SHALL). 사용자는 그 내려받기까지 포함해 권한에 동의한다.

#### Scenario: 내려받기 안내 줄

- **WHEN** 임시 프로젝트에서 권한 목록 단계를 돌린다
- **THEN** 출력에 `sdd-openspec`이 첫 실행 때 npm에서 받는다는 줄이 있다

### Requirement: 비대화 단계는 사람 없이 다시 돌려 볼 수 있어야 한다

초기화, 초안 만들기, 기본 브랜치 감지, 권한 목록 보기는 사용자 확인 없이 명령으로 돌려 종료코드로 확인할 수
있어야 한다(SHALL). 사용자 확인이 필요한 두 단계(context 기록, 권한 기록)는 명시적인 기록 명령을 따로 두고,
스킬 문서는 사용자 동의를 받은 뒤에만 그 명령을 돌리라고 적어야 한다(MUST).

#### Scenario: 마켓플레이스로 설치한 새 프로젝트에서 끝까지

- **WHEN** 격리한 `CLAUDE_CONFIG_DIR`에서 `claude plugin marketplace add <이 저장소 경로>`와 `claude plugin install sdd@sdd-marketplace`를 돌린 뒤, `mktemp -d` 새 프로젝트에서 비대화 단계를 차례로 돌린다
- **THEN** 각 단계의 종료코드가 0이다
- **AND** 이어서 작은 작업 1건의 change(proposal과 tasks)를 만들고 `sdd-openspec validate "<이름>" --strict`가 종료코드 0이다
