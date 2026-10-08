## MODIFIED Requirements

### Requirement: 스킬은 이 저장소에 있고 도구를 좁혀서는 안 된다

`init-sdd` 스킬 문서는 이 저장소의 `.claude/skills/init-sdd/SKILL.md`에 있어야 한다(SHALL).
이 스킬의 일 중 하나가 **개인 저장소를 만들어 주는 것**이라서, 개인 저장소가 아직 없는
상태에서도 손에 잡혀야 한다. 개인 저장소 쪽에 두면 스킬을 쓰려면 개인 저장소가 있어야 하고
개인 저장소를 만들려면 스킬이 있어야 하는 순환이 된다(사용자 결정).

이 스킬은 플러그인에 넣지 않는다(SHALL). 플러그인 레이아웃(`skills/`)으로 옮기지 않고 위 자리에 이 저장소
전용 스킬로 남는다. 플러그인에 넣으면 사용자 프로젝트에서 매 세션 이 스킬 설명을 읽느라 토큰을 쓰고,
초기화 스킬(`/sdd:init`)과 헷갈린다.

frontmatter에는 `name`과 `description`만 있어야 하며(SHALL), `allowed-tools`를 넣어서는 안
된다(MUST NOT). 이 스킬은 파일을 만들고 링크를 걸고 git 명령을 돌려야 한다. openspec 공식
스킬 6개가 `allowed-tools: Bash(openspec:*)`로 도구를 하나로 좁혀서 파일을 못 쓰게 되는
일이 실제로 일어났다.

`description`에는 사용자가 실제로 할 만한 **발동 신호(부르는 말)**가 들어 있어야 한다(MUST).
같은 저장소의 `orchestra` 스킬이 그렇게 되어 있다. 신호가 없으면 스킬이 있어도 불리지 않는다.
`description`이 나열하는 링크 대상 스킬에 없어진 모델 등급 스킬이 있어서는 안 된다(MUST NOT).

#### Scenario: 스킬 파일이 제 위치에 있고 마크다운이 온전하다

- **WHEN** `.claude/skills/init-sdd/SKILL.md`를 읽는다
- **THEN** 파일이 있고, `---`로 둘러싼 frontmatter가 온전하며 `name: init-sdd`가 있다
- **AND** 코드펜스(```) 개수가 짝수다
- **AND** 플러그인 `skills/` 아래에는 `init-sdd`가 없다

#### Scenario: 도구를 좁히지 않았다

- **WHEN** `.claude/skills/init-sdd/SKILL.md`의 frontmatter를 읽는다
- **THEN** `allowed-tools` 키가 없다

#### Scenario: 부르는 말이 적혀 있다

- **WHEN** `description` 값을 읽는다
- **THEN** 사용자가 쓸 만한 말이 여러 개 들어 있다 (예: "링크로 연결", "개인 저장소로
  분리", "연결 풀기", "지금 연결돼 있어?")
- **AND** 이 스킬이 무엇을 하는 스킬인지 한 문장으로 알 수 있다
- **AND** 나열한 스킬 이름이 링크 대상 세 스킬(`orchestra`, `sdd-rules`, `sdd-sync`)뿐이다

### Requirement: 개인 소유와 openspec CLI 소유를 갈라서 링크해야 한다

스킬은 `.claude/`를 통째로 링크해서는 안 된다(MUST NOT). 그 안에는 소유자가 다른 것이
섞여 있다. **개인 소유만 골라서** 링크해야 한다(SHALL).

대상 프로젝트의 링크 대상은 정확히 다섯 개다(SHALL):

| 경로 | 종류 |
|---|---|
| `.claude/agents/` | 디렉터리 |
| `.claude/skills/orchestra/` | 디렉터리 |
| `.claude/skills/sdd-rules/` | 디렉터리 |
| `.claude/skills/sdd-sync/` | 디렉터리 |
| `.claude/settings.json` | 파일 |

없어진 모델 등급 스킬은 링크 대상이 아니다(MUST NOT link).

개인 저장소를 처음 채울 때(초기 이관) 원본은 원본 저장소의 플러그인 레이아웃에서 가져와야 한다(SHALL):
`agents/`, `skills/orchestra/`, `skills/sdd-rules/`, `skills/sdd-sync/`, `.claude/settings.json`.

`.claude/skills/sdd-rules/`와 `.claude/skills/sdd-sync/`는 에이전트가 frontmatter `skills:`로
주입받는 스킬이라 에이전트와 함께 다녀야 한다. 빠지면 링크된 에이전트가 공용 규칙과 sync
절차를 받지 못한다.

`.claude/skills/openspec-*`(6개)와 `.claude/commands/opsx/`는 링크 대상에서 **제외해야
한다**(MUST NOT link). `openspec init --tools claude`가 사용자의 CLI 버전에 맞는 것을 대상
프로젝트에 직접 깔아 주는 물건이다.

`.claude/skills/` 자체는 **실제 디렉터리로 남아야 하며**(SHALL), 그 안의 세 개만 링크가
된다. `.claude/settings.local.json`은 만들지도 고치지도 지우지도 않아야 한다(MUST NOT) —
개인 로컬 설정이고 이미 추적 제외 대상이다.

#### Scenario: 문서가 소유를 갈라 적는다

- **WHEN** 스킬 문서에서 링크 대상 목록을 읽는다
- **THEN** 위 다섯 개가 링크 대상으로 적혀 있고 그 밖의 스킬은 없다
- **AND** `openspec-*` 6개와 `commands/opsx/`가 **링크하지 않는 것**으로 적혀 있고 그 이유
  (openspec CLI가 깐다)가 함께 적혀 있다
- **AND** `.claude/` 통째 링크를 하지 말라는 말이 명시돼 있다
- **AND** `settings.local.json`은 건드리지 않는다고 적혀 있다
- **AND** 초기 이관의 원본 경로가 원본 저장소의 `agents/`, `skills/<이름>/`이다

#### Scenario: 링크를 걸어도 openspec 스킬이 그대로 남는다

- **WHEN** 임시 프로젝트에 절차를 돌린 뒤 `.claude/skills/`를 본다
- **THEN** `.claude/skills/`는 심볼릭 링크가 아닌 실제 디렉터리다
- **AND** `openspec-*` 스킬 디렉터리들이 실제 디렉터리로 그대로 있다
- **AND** `orchestra`, `sdd-rules`, `sdd-sync`만 심볼릭 링크다

### Requirement: 걸었다 풀 수 있어야 하고, 풀면 원래 상태로 돌아와야 한다

스킬은 링크를 거는 절차와 **푸는 절차를 둘 다 가져야 한다**(SHALL). 푸는 절차는 다음을
전부 되돌려야 한다(MUST):

- 만든 심볼릭 링크 다섯 개를 없앤다 (링크만 없앤다 — 링크가 가리키던 개인 저장소의 내용은
  건드리지 않는다). `.claude/skills/` 아래에 다섯 목록에 없지만 개인 저장소를 가리키는 링크(이전 판이 만든
  링크)가 남아 있으면 그 링크도 알리고 같은 방식으로 없앤다(SHALL)
- `CLAUDE.md`의 마커 구획을 떼어 낸다
- `git update-index --no-skip-worktree CLAUDE.md`로 표시를 해제한다
- `.git/info/exclude`에 스킬이 적어 넣은 줄만 지운다 (사용자가 원래 적어 둔 줄은 그대로 둔다)

푼 뒤에는 공유 저장소가 절차를 돌리기 **전과 같아야 한다**(SHALL): 추적 파일 내용이 같고
`git status`가 같다. 개인 저장소의 내용은 지워지지 않아야 한다(MUST NOT) — 다른 프로젝트도
그것을 쓴다.

#### Scenario: 걸었다 풀면 제자리로 돌아온다

- **WHEN** 임시 프로젝트에 절차를 돌리고, 파일 목록과 `git status`를 기록한 뒤 푸는 절차를
  돌린다
- **THEN** 링크 다섯 개가 사라진다
- **AND** `CLAUDE.md`가 절차 전 내용과 같고 `skip-worktree` 표시가 해제돼 있다
- **AND** `.git/info/exclude`가 절차 전과 같다
- **AND** `git status`가 절차 전과 같다

#### Scenario: 풀어도 개인 저장소는 남는다

- **WHEN** 푸는 절차를 돌린 뒤 개인 저장소를 본다
- **THEN** 프로젝트별 디렉터리와 그 안의 파일이 그대로 있다
- **AND** 개인 저장소의 git 이력이 그대로 있다

### Requirement: 지금 걸려 있는지 알 수 있어야 한다

스킬은 현재 연결 상태를 보여주는 절차를 가져야 한다(SHALL). 다음을 모두 보여야 한다(MUST):

- 링크 대상 다섯 개 각각이 **링크됨(어디를 가리키는지) / 실제 파일·디렉터리 / 없음 /
  끊긴 링크** 중 무엇인지
- `CLAUDE.md`에 마커 구획이 있는지
- `CLAUDE.md`에 `skip-worktree` 표시가 걸려 있는지
- `.git/info/exclude`에 스킬이 적은 줄이 있는지

**끊긴 링크**(가리키는 곳이 없는 링크)를 따로 알려야 한다(MUST). 개인 저장소를 아직 복제하지
않은 새 컴퓨터에서 이 상태가 되고, 그 상태에서는 에이전트가 하나도 로드되지 않는데 링크는
걸려 있어서 겉으로는 정상처럼 보인다.

#### Scenario: 상태 확인이 네 갈래를 구분한다

- **WHEN** 상태 확인 절차를 읽는다
- **THEN** 링크 대상 다섯 개 모두에 대해 링크됨·실제 파일·없음·끊긴 링크 네 갈래를 구분하는 방법이 적혀 있다
- **AND** `CLAUDE.md` 마커·`skip-worktree`·`.git/info/exclude`도 함께 확인한다

#### Scenario: 끊긴 링크를 잡아낸다

- **WHEN** 링크를 걸어 둔 뒤 개인 저장소 디렉터리 이름을 바꿔 링크를 끊고 상태 확인을 돌린다
- **THEN** 그 링크가 끊겼다고 알린다
- **AND** 개인 저장소를 복제·복구하거나 링크를 풀라고 알려 준다

### Requirement: 경로를 하드코딩해서는 안 된다

스킬 문서는 절대 경로를 하드코딩해서는 안 된다(MUST NOT). 다음 세 경로를 **실행 시점에**
알아내야 한다(SHALL):

- **원본 저장소** (이 init-SDD 복제본): 스킬 자신의 위치에서 위로 올라가 `install.sh`와
  `.claude/CLAUDE.md`가 함께 있는 디렉터리를 찾는다. 찾지 못하면 사용자에게 묻는다. 조각 원본은
  저장소 루트가 아니라 `.claude/CLAUDE.md`에 있다(`distribution/sdd-plugin`).
- **대상 프로젝트**: 기본값은 현재 작업 디렉터리. 사용자에게 확인한다.
- **개인 agentic 저장소**: 기본값 `~/work-space/agentic`을 **권하되**, 실행 시점에 사용자
  에게 확인한다. 사용자가 다른 경로를 주면 그것을 쓴다.

특히 이 저장소의 현재 절대 경로(`/Users/0stone_1004/orca/projects/init-SDD`)가 문서 어디에도
있어서는 안 된다(MUST NOT). 이 저장소는 곧 다른 경로로 옮겨질 예정이고, 박아 두면 그때 깨진다.

#### Scenario: 저장소 절대 경로가 문서에 없다

- **WHEN** 스킬 문서 전체를 `/Users/`로 검색한다
- **THEN** 아무것도 나오지 않는다

#### Scenario: 개인 저장소 경로를 실행 시점에 확인한다

- **WHEN** 스킬 문서에서 개인 저장소 경로를 정하는 부분을 읽는다
- **THEN** `~/work-space/agentic`이 **기본값·권함**으로 제시된다
- **AND** 실행 시점에 사용자에게 확인하라고 적혀 있고, 사용자가 준 경로를 쓴다고 적혀 있다
- **AND** 그 경로가 그 자리 말고 다른 절차 단계에 다시 박혀 있지 않다 (변수로 다룬다)

#### Scenario: 원본 저장소를 스스로 찾는다

- **WHEN** 스킬 문서에서 원본 저장소를 정하는 부분을 읽는다
- **THEN** 스킬 자신의 위치를 기준으로 위로 올라가 `install.sh`와 `.claude/CLAUDE.md`가 함께 있는
  디렉터리를 찾는 방법이 적혀 있다
- **AND** 찾지 못했을 때 사용자에게 묻는 길이 적혀 있다

### Requirement: CLAUDE.md 조각은 원본 한 벌에서 뽑아 붙여야 한다

스킬은 SDD 지시문 조각을 문서 안에 베껴 적어서는 안 된다(MUST NOT). 원본 저장소 `.claude/CLAUDE.md`의
마커 구획(`<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->`)에서 **기계적으로 뽑아야
한다**(SHALL). `install.sh`가 이미 같은 방식을 쓰고 있고, 조각 원본이 저장소 전체에 한 벌인
것은 메인 spec `distribution/sdd-install-script`가 요구하는 것이다.

뽑은 조각이 비면 **멈춰야 한다**(MUST). 빈 값을 붙이면 "성공"이라고 말하면서 아무 지시문도
안 들어간다. `install.sh`가 이미 그 안전장치를 갖고 있다.

대상 프로젝트 `CLAUDE.md`가 이미 있으면 덮어쓰지 않고 **끝에 덧붙여야 한다**(SHALL). 마커
구획이 이미 있으면 두 번 넣지 않아야 한다(MUST NOT). 대상 쪽 파일은 대상 프로젝트 루트의 `CLAUDE.md` 그대로다.

#### Scenario: 조각을 베끼지 않고 뽑는다

- **WHEN** 스킬 문서의 `CLAUDE.md` 처리 부분을 읽는다
- **THEN** 조각 본문(파이프라인 순서를 적은 `순서:` 줄 등)이 스킬 문서에 실려 있지 않다
- **AND** 마커 구획을 원본 `.claude/CLAUDE.md`(`$SRC/.claude/CLAUDE.md`)에서 뽑아내는 명령이 있다

#### Scenario: 뽑은 조각이 비었다

- **WHEN** 원본 `.claude/CLAUDE.md`에 마커가 없거나 구획이 비어서 뽑기가 빈 값을 낸다
- **THEN** 멈추고 원본의 마커를 확인하라고 알린다
- **AND** 대상 프로젝트 `CLAUDE.md`가 바뀌지 않는다

#### Scenario: 조각이 두 번 들어가지 않는다

- **WHEN** 이미 마커 구획이 있는 `CLAUDE.md`에 절차를 다시 돌린다
- **THEN** 이미 들어가 있다고 알리고 넣지 않는다
- **AND** 마커 구획이 정확히 하나뿐이다

## ADDED Requirements

### Requirement: 링크 방식은 플러그인으로 이전하라고 안내해야 한다

스킬 문서는 플러그인 설치가 권장 방식이라는 것과 링크 방식이 기존 설치 방식으로 남아 있다는 것을 앞부분에
적어야 한다(SHALL). 플러그인 설치 절차는 `README.md`를 가리키고(SHALL), 스킬 문서에 다시 적어서는 안
된다(MUST NOT).

이미 링크를 건 프로젝트가 플러그인으로 옮기려면 "풀기" 절차로 링크를 푼 뒤 플러그인을 설치하라고
안내해야 한다(SHALL). 링크와 플러그인을 함께 쓰면 같은 에이전트가 두 이름(`sdd:<이름>`, `<이름>`)으로 실린다.

#### Scenario: 이전 안내가 있다

- **WHEN** 스킬 문서의 앞부분을 읽는다
- **THEN** 플러그인이 권장 방식이고 설치 안내는 `README.md`에 있다는 말이 있다
- **AND** 링크를 푼 뒤 플러그인을 설치하라는 이전 순서가 있다
- **AND** 플러그인 설치 명령(`/plugin install`)의 절차가 스킬 문서에 다시 서술되어 있지 않다
