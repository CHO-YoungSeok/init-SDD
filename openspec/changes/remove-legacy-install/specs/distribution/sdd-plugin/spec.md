## MODIFIED Requirements

### Requirement: 저장소 루트가 플러그인 루트이고 표준 레이아웃을 따라야 한다

플러그인이 싣는 것은 플러그인 루트의 표준 위치에 있어야 한다(SHALL): 서브에이전트 8개는 `agents/*.md`,
스킬 4개(`orchestra`, `sdd-rules`, `sdd-sync`, `init`)는 `skills/<이름>/SKILL.md`, SessionStart 훅은
`hooks/hooks.json`, 실행 파일은 `bin/`.

서브에이전트와 스킬은 `.claude/agents/`·`.claude/skills/`에 있어서는 안 된다(MUST NOT) — 같은 지시문이
두 벌이 되면 갈라진다. 이 저장소가 `.claude/` 아래에 추적하는 파일은 프로젝트 지침 `.claude/CLAUDE.md`와
개발 권한 `.claude/settings.json` 둘뿐이어야 한다(SHALL). 없어진 모델 등급 스킬은 어디에도 없어야 한다(MUST NOT).

#### Scenario: 새 프로세스가 에이전트와 스킬을 접두사와 함께 싣는다

- **WHEN** 저장소 루트에서 새 `claude -p --plugin-dir . --output-format stream-json --verbose` 프로세스를 띄우고 init 이벤트를 읽는다
- **THEN** 에이전트 목록에 `sdd:preparer`, `sdd:analyzer`, `sdd:designer`, `sdd:worker`, `sdd:reviewer`,
  `sdd:regression-verifier`, `sdd:finalizer`, `sdd:code-explorer` 8개가 있다
- **AND** 스킬 목록에 `sdd:orchestra`, `sdd:sdd-rules`, `sdd:sdd-sync`, `sdd:init`이 있다
- **AND** 에이전트는 이 8개뿐이고 스킬은 이 4개뿐이다 (플러그인 `sdd`가 싣는 것만 센다)

#### Scenario: 옛 위치가 비었다

- **WHEN** 저장소에서 `.claude/agents/`와 `.claude/skills/{orchestra,sdd-rules,sdd-sync}/`를 찾고, `git ls-files .claude`와 `skills/` 아래 디렉터리 목록을 본다
- **THEN** 앞의 네 경로가 없다
- **AND** `git ls-files .claude`의 결과가 `.claude/CLAUDE.md`와 `.claude/settings.json` 두 줄뿐이다 (gitignore 대상인 `openspec-*` 스캐폴드는 추적되지 않으니 나오지 않는다)
- **AND** `skills/` 아래는 `orchestra`, `sdd-rules`, `sdd-sync`, `init` 네 개뿐이다

### Requirement: 에이전트 frontmatter의 skills 항목은 접두사 없는 이름을 써야 한다

에이전트 frontmatter `skills:`는 접두사 없는 `sdd-rules`, `sdd-sync`를 써야 한다(SHALL). 플러그인
안에서는 접두사 없는 이름이 주입된다(실측).

#### Scenario: skills 줄에 접두사가 없다

- **WHEN** `grep -n '^skills:' agents/*.md`를 돌린다
- **THEN** `sdd:`가 들어간 줄이 없다
- **AND** 7개 파일이 `sdd-rules`를, finalizer가 `sdd-sync`도 담고 있다

### Requirement: 이 저장소는 --plugin-dir로 개발해야 한다

이 저장소는 `claude --plugin-dir .`로 띄워서 개발해야 한다(SHALL). 파일을 플러그인 레이아웃으로 옮긴
뒤에는 그렇게 띄우지 않으면 에이전트가 하나도 실리지 않는다. `--plugin-dir`로 띄운 플러그인은 같은
이름으로 설치된 플러그인보다 우선한다(실측).

`README.md`는 이 개발용 실행법을 적어야 하고(MUST), 이 저장소의 프로젝트 지침 파일 `.claude/CLAUDE.md`는
개발자용 안내(이 실행법과 "이 저장소도 SDD로 개발한다")와 지휘 지침(작업 방식)을 담아야 한다(SHALL).
`.claude/CLAUDE.md`에는 다른 프로젝트로 뽑아 붙이기 위한 구획 표식 주석이 있어서는 안 된다(MUST NOT).

#### Scenario: 개발용 실행법이 적혀 있다

- **WHEN** `README.md`와 `.claude/CLAUDE.md`에서 `claude --plugin-dir .`를 찾는다
- **THEN** 두 파일에 모두 있다

#### Scenario: 지휘 지침이 표식 없이 남아 있다

- **WHEN** `.claude/CLAUDE.md`를 읽고 `grep -cE 'init-SDD:(begin|end)' .claude/CLAUDE.md`를 돌린다
- **THEN** grep 결과가 `0`이다
- **AND** "이 저장소도 SDD로 개발한다"와, 메인 세션은 오케스트레이터로서 지휘만 하고 서브에이전트에게 위임한다는 지휘 지침이 있다
- **AND** 기본(작은 작업)·큰 작업 두 파이프라인 순서 줄과 `code-explorer` 예외, analyzer는 요청할 때만 부른다는 문장이 있다

## REMOVED Requirements

### Requirement: 에이전트는 sdd 접두사 이름으로 부르고 접두사 없는 이름으로 대비해야 한다

**Reason**: 설치 수단이 플러그인 하나가 되어 에이전트는 늘 `sdd:` 접두사와 함께 실린다. 접두사 없는 이름으로 다시 부르는 대비 규칙과 그 동작 시나리오는 지킬 대상이 없다.
**Migration**: 아래 ADDED 요구사항 "에이전트는 sdd 접두사 이름으로 불러야 한다"가 호출 예시 규칙을 이어받고, 대비 규칙을 두지 않는다고 정한다.

### Requirement: README는 플러그인 설치와 이전 안내를 담아야 한다

**Reason**: 다른 설치 방식에서 플러그인으로 옮기는 안내를 지운다(사용자 결정: 필요 없음). 설치 두 줄을 코드블록 두 개로 나누는 조건이 더해진다.
**Migration**: 아래 ADDED 요구사항 "README는 플러그인 설치를 한 길로 안내해야 한다"가 설치 두 줄·`/sdd:init`·스캐폴드 불필요 안내를 이어받는다.

## ADDED Requirements

### Requirement: 에이전트는 sdd 접두사 이름으로 불러야 한다

플러그인으로 실린 에이전트는 `sdd:<이름>`으로만 풀린다(실측). 그래서 orchestra 스킬의 모든 서브에이전트
호출 예시는 `subagent_type: "sdd:<이름>"`이어야 한다(SHALL).

설치 수단은 플러그인 하나뿐이므로, `sdd:<이름>`이 `not found`일 때 접두사 없는 `<이름>`으로 다시 부르는
대비 규칙을 orchestra 스킬과 sdd-rules 스킬 어디에도 두어서는 안 된다(MUST NOT).

#### Scenario: orchestra의 호출 이름이 모두 접두사를 가진다

- **WHEN** `grep -n 'subagent_type: "' skills/orchestra/SKILL.md`를 돌린다
- **THEN** 나온 모든 줄의 이름이 `sdd:`로 시작한다

#### Scenario: 대비 규칙이 없다

- **WHEN** `grep -n 'not found' skills/orchestra/SKILL.md skills/sdd-rules/SKILL.md`를 돌린다
- **THEN** 결과가 0건이다
- **AND** 두 파일에 "접두사 없는 이름으로 다시 부른다"는 규칙이 없다

### Requirement: README는 플러그인 설치를 한 길로 안내해야 한다

설치 절차는 `README.md` 한 곳에만 서술되어야 한다(SHALL). `README.md`는 다음을 담아야 한다(MUST):
- 플러그인 설치 두 줄. `/plugin marketplace add <owner/repo 또는 경로>`와 `/plugin install sdd@sdd-marketplace`는
  각각 다른 코드블록에 한 줄씩 둔다(SHALL) — 한 블록에 두 줄을 넣으면 한 번에 붙여 넣어 첫 줄만 돈다.
- 새 프로젝트에서 한 번 실행하는 `/sdd:init`
- `openspec init`이 까는 스캐폴드(`.claude/commands/opsx/`, `.claude/skills/openspec-*`)가 필요 없다는 안내

플러그인 밖의 다른 설치 방식이나 그 이전 안내를 담아서는 안 된다(MUST NOT).

#### Scenario: 설치 두 줄이 코드블록 두 개로 나뉘어 있다

- **WHEN** `README.md`의 "빠른 시작" 절과 "플러그인으로 설치" 절을 읽는다
- **THEN** 두 절 각각에서 `/plugin marketplace add`와 `/plugin install sdd@sdd-marketplace`가 서로 다른 코드블록에 있고, 각 코드블록은 그 한 줄만 담는다
- **AND** `/sdd:init`이 그 뒤에 나온다

#### Scenario: 스캐폴드가 필요 없다는 안내가 있다

- **WHEN** `README.md`를 읽는다
- **THEN** `.claude/commands/opsx/`와 `.claude/skills/openspec-*`가 필요 없다는 안내가 있다

#### Scenario: 다른 설치 방식 안내가 없다

- **WHEN** `README.md`에서 설치 방식을 고르는 절, 다른 설치 방식 절, 그 방식에서 플러그인으로 옮기는 안내를 찾는다
- **THEN** 셋 다 없다
- **AND** 대상 프로젝트로 지시문을 복사하거나 링크하는 절차가 없다

### Requirement: 설치 수단은 플러그인 하나뿐이어야 한다

이 저장소는 플러그인 `sdd`와 `/sdd:init` 말고 다른 설치 수단을 담아서는 안 된다(MUST NOT): 대상 프로젝트로
지시문을 복사하는 설치 스크립트도, 링크를 거는 스킬도 없어야 한다. 추적 중인 파일(지난 change 기록
`openspec/changes/` 아래와 측정 당시 사실을 적은 `docs/field-validation.md` 각주는 빼고)에 그 수단의 이름이나
그 수단을 위한 대비 문구가 남아 있어서는 안 된다(MUST NOT).

#### Scenario: 설치 수단 파일이 없다

- **WHEN** 저장소 루트에서 `git ls-files '*.sh'`와 `git ls-files .claude/skills`를 돌린다
- **THEN** 앞의 결과는 `hooks/session-start.sh` 한 줄뿐이다
- **AND** 뒤의 결과는 0건이다

#### Scenario: 낡은 설치 방식 낱말이 남아 있지 않다

- **WHEN** 저장소 루트에서 `git ls-files | grep -vE '^openspec/changes/|^docs/field-validation[.]md$' | xargs grep -nE 'install[.]sh|init-sd[d]|복사 방[식]|링크 방[식]|기존 설[치]|init-SDD:(begin|end)'`를 돌린다 (대소문자를 가린다)
- **THEN** 결과가 0건이다
