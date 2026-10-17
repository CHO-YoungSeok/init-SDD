# distribution/sdd-plugin Specification

## Purpose
SDD 파이프라인을 Claude Code 플러그인 `sdd`로 배포하는 계약을 정한다. 저장소 루트가 곧 플러그인 루트이고, 매니페스트·마켓플레이스·표준 레이아웃·에이전트 이름 접두사·개발용 실행 방법이 검증 가능한 형태로 맞아야 한다.

## Requirements

### Requirement: 플러그인 매니페스트는 이름과 버전을 고정해야 한다

저장소 루트의 `.claude-plugin/plugin.json`은 플러그인 매니페스트여야 한다(SHALL). 값은 다음과 같아야
한다(MUST): `name`은 `sdd`, `version`은 semver로 고정한 값(첫 릴리스 `0.1.0`), `author.name`은 저장소
git 사용자 이름. 이메일은 넣지 않는다(SHALL).

#### Scenario: 플러그인 매니페스트 값

- **WHEN** `.claude-plugin/plugin.json`을 읽는다
- **THEN** `name`이 `sdd`이고 `version`이 `0.1.0`이며 `author.name`이 있고 `author.email`이 없다

### Requirement: 마켓플레이스 매니페스트는 예약되지 않은 이름과 설명을 가져야 한다

`.claude-plugin/marketplace.json`은 이 저장소를 로컬 경로나 git 저장소로 추가할 수 있는 마켓플레이스여야
한다(SHALL). `name`은 `sdd-marketplace`여야 하며(SHALL), 예약된 이름 꼴(`claude-plugins-official`,
`anthropic-`로 시작하는 이름 등)을 써서는 안 된다(MUST NOT). 최상위 `description`이 있어야 한다(MUST) —
없으면 `--strict` 검증이 실패한다. 플러그인 목록에는 `sdd` 하나가 저장소 루트를 원천으로 들어 있어야
한다(SHALL).

#### Scenario: 마켓플레이스 매니페스트 값

- **WHEN** `.claude-plugin/marketplace.json`을 읽는다
- **THEN** `name`이 `sdd-marketplace`이고 최상위 `description`이 있으며 플러그인 `sdd`를 담고 있다

### Requirement: 플러그인 검증 명령 두 개를 모두 통과해야 한다

`claude plugin validate .`와 `claude plugin validate .claude-plugin/plugin.json`을 `--strict`로 **둘 다**
통과해야 한다(MUST). `marketplace.json`이 있으면 앞의 명령은 마켓플레이스 매니페스트를 보고 `plugins[0]`(source `./`)을
따라가 `plugin.json`과 에이전트·스킬도 검사한다(실측, Claude Code 2.1.294). 뒤의 명령은 그래서 중복이지만
해가 없고, Claude Code 버전에 따라 동작이 다를 수 있어 둘 다 유지한다.

#### Scenario: 두 검증 명령이 모두 통과한다

- **WHEN** 저장소 루트에서 `claude plugin validate . --strict; echo $?`와
  `claude plugin validate .claude-plugin/plugin.json --strict; echo $?`를 돌린다
- **THEN** 두 종료코드가 모두 0이다

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

### Requirement: 프로젝트 지침 파일은 플러그인 루트가 아닌 .claude/CLAUDE.md에 두어야 한다

이 저장소의 프로젝트 지침 파일은 `.claude/CLAUDE.md`에 있어야 하고(SHALL), 저장소 루트(= 플러그인 루트)에
`CLAUDE.md`가 있어서는 안 된다(MUST NOT). 플러그인 루트의 `CLAUDE.md`는 `claude plugin validate`가 경고를
내고("플러그인 루트의 CLAUDE.md는 프로젝트 컨텍스트로 로드되지 않는다"), `--strict`는 그 경고를 오류로
바꿔 두 검증 명령을 모두 실패시킨다(실측, Claude Code 2.1.294). `.claude/CLAUDE.md`는 Claude Code가 프로젝트
지침으로 읽는 자리라서 이 저장소를 개발하는 세션은 계속 이 지침을 받는다. 이 경고를 허용 예외로 두지 않는다.

#### Scenario: 루트에 CLAUDE.md가 없다

- **WHEN** 저장소 루트에서 `test -e CLAUDE.md; echo $?`와 `test -f .claude/CLAUDE.md; echo $?`를 돌린다
- **THEN** 앞은 1, 뒤는 0이다
- **AND** `claude plugin validate . --strict` 출력에 `CLAUDE.md at the plugin root` 경고가 없다

#### Scenario: 이 저장소 세션이 지침을 싣는다

- **WHEN** 저장소 루트에서 새 `claude -p` 프로세스에 `.claude/CLAUDE.md`에만 있는 문장을 그대로 인용하라고 묻는다(파일 읽기 도구 없이)
- **THEN** 그 문장이 답에 나온다

### Requirement: README는 업데이트·팀 배포·실행 환경을 안내해야 한다

`README.md`는 다음을 담아야 한다(MUST):
- 플러그인 업데이트 절차 한 단락(마켓플레이스 갱신 → 플러그인 업데이트 → 재시작)
- 팀 배포 한 단락(프로젝트 `.claude/settings.json`의 `extraKnownMarketplaces`와 `enabledPlugins`)
- Windows에서는 bash가 필요하다는 한 줄(훅과 `bin/` 실행 파일이 bash 스크립트다)

#### Scenario: README에 업데이트·팀 배포·bash 안내가 있다

- **WHEN** `README.md`를 읽는다
- **THEN** 업데이트 절차 단락이 있다
- **AND** `extraKnownMarketplaces`와 `enabledPlugins`가 나오는 팀 배포 단락이 있다
- **AND** Windows에서 bash가 필요하다는 줄이 있다

### Requirement: 플러그인 eval 결과는 추적하지 않아야 한다

`.gitignore`에 `evals/results/`가 있어야 한다(SHALL). `claude plugin eval`이 `evals/`의 사례를
인식하는지(실행 시작까지)는 확인해 기록해야 한다(SHALL). 이 확인은 비용 상한 0.05달러(`--max-cost-usd 0.05`)
안에서 돌리고, `--json`·`--report` 출력은 저장소 밖에 둔다(SHALL). 점수 측정은 하지 않는다 — 모델 호출
비용이 들고, 실전 측정 change의 일이다.

#### Scenario: 결과 폴더 무시와 인식 확인

- **WHEN** `.gitignore`를 읽고 archive된 change `2026-10-09-convert-to-plugin`의 `verification.md`를 읽는다
- **THEN** `.gitignore`에 `evals/results/` 줄이 있다
- **AND** `claude plugin eval`이 `evals/`의 사례 이름을 인식했는지에 대한 확인 결과가 있다

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
