## RENAMED Requirements

- FROM: `### Requirement: 제품 7종을 깔아야 한다`
- TO: `### Requirement: 제품 6종을 깔아야 한다`

## MODIFIED Requirements

### Requirement: 복사 방식과 링크 방식 중 어느 것을 쓸지 알려 줘야 한다

SDD를 얹는 방식은 세 가지다: **플러그인**(권장), `install.sh`의 **복사 방식**, `init-sdd` 스킬의
**링크 방식**. 복사 방식과 링크 방식은 기존 설치 방식으로 남아 있고, 실전 검증 뒤 별도 change에서
없앤다. `README.md`는 **어떤 때 어느 것을 쓰는지**를 알려 줘야 한다(SHALL):

| 상황 | 쓰는 것 |
|---|---|
| 새로 시작한다 | **플러그인** — `/plugin marketplace add`, `/plugin install sdd@sdd-marketplace`, 그 뒤 `/sdd:init` |
| 팀이 SDD 방식에 합의했고, 플러그인 대신 설정을 프로젝트 저장소에 두어야 한다 | **복사 방식** — `install.sh` |
| 개인이 자기 agentic 설정을 별도 git으로 관리한다. 공유 저장소에 남기지 않는다 | **링크 방식** — `init-sdd` 스킬 |

이 안내의 본문은 `README.md` 한 곳에만 있어야 한다(SHALL). 같은 절차를 두 곳에 서술해서는
안 된다는 기존 요구사항("설치 안내는 README 한 곳에만 있어야 한다")이 그대로 적용된다.
안내가 없으면 같은 일을 하는 절차가 두 곳에 있는 것처럼 보이고, 이 저장소는 이미 그 고장
(같은 문구의 사본이 갈라지는 것)을 두 번 겪었다(사용자 결정).

`install.sh`와 `init-sdd` 스킬 문서는 **서로를 가리켜야 한다**(MUST). `install.sh`는 설치를
마친 뒤 안내에서 링크 방식도 있다는 것을 알려야 하고(SHALL), 그 안내는 **한 줄이면
충분하다** — 절차를 다시 적어서는 안 된다(MUST NOT).

이 요구사항은 `install.sh`의 **복사 규칙을 바꾸지 않는다.** 덮어쓰기 금지와 조각을 마커 구획에서
뽑는 방식은 그대로다. 복사 대상 목록은 "제품 6종을 깔아야 한다"가 정한다.

#### Scenario: README가 두 방식 중 고르는 법을 알려 준다

- **WHEN** `README.md`의 `## 설치` 절 맨 앞을 읽는다
- **THEN** 플러그인, 복사 방식, 링크 방식이 어떤 때 쓰는 것인지 갈라져 적혀 있고 플러그인이 권장으로 먼저 나온다
- **AND** 링크 방식을 쓰려면 `init-sdd` 스킬을 쓰라고 적혀 있다
- **AND** 기존 "방법 1 — install.sh"와 "방법 2 — 손으로"가 복사 방식으로서 그대로 남아 있다

#### Scenario: install.sh가 링크 방식을 가리킨다

- **WHEN** `bash install.sh --dry-run`을 돌리거나 `install.sh`의 안내 부분을 읽는다
- **THEN** 링크 방식(`init-sdd` 스킬)도 있다는 안내가 나온다
- **AND** 링크를 거는 절차 자체는 `install.sh`에 서술되어 있지 않다
- **AND** `bash -n install.sh`가 종료코드 0이다

#### Scenario: 복사 동작이 그대로다

- **WHEN** `install.sh`의 복사 대상 목록과 복사 방식을 읽는다
- **THEN** 원본 저장소의 `agents/`의 `.md` 파일들, `skills/orchestra`, `skills/sdd-rules`, `skills/sdd-sync`,
  `.claude/settings.json`이 대상이고, 대상 프로젝트의 `.claude/agents/`, `.claude/skills/<이름>`,
  `.claude/settings.json`으로 복사된다
- **AND** 그 밖의 스킬은 대상이 아니다
- **AND** 이미 있는 파일을 건너뛰는 규칙과 조각을 마커 구획에서 뽑는 방식이 바뀌지 않았다 (조각 원본 파일의 위치만 `.claude/CLAUDE.md`로 바뀐다)

### Requirement: 설치 안내는 README 한 곳에만 있어야 한다

같은 설치 절차가 두 곳에 서술되어서는 안 된다(MUST NOT). `README.md`만 읽고 설치할 수
있어야 하며(SHALL), 플러그인 설치가 먼저 나와야 한다(SHALL). 복사 방식에는 최소한 다음 흐름이 적혀
있어야 한다(MUST): 이 저장소를 복제한다 → 대상 프로젝트로 이동한다 → `bash install.sh`를 돌린다 →
`CLAUDE.md`가 합쳐졌는지 확인한다 → Claude Code를 새 세션으로 다시 연다.

`README.md`의 복사 방식 제품 설명과 설치 확인 절차는 **제품 6종**과 맞아야 한다(MUST).
`sdd-rules`·`sdd-sync`가 빠져 있으면 손으로 설치하는 사용자가 그 둘을 빠뜨려 에이전트가
공용 규칙을 못 받는다. 이미 설치한 프로젝트를 위한 안내도 있어야 한다(SHALL): 두 스킬을
새로 넣고, **에이전트 파일을 새 판으로 바꿔야 한다**(새 판과 비교해 옮긴다). `install.sh`는 이미
있는 파일을 덮어쓰지 않으므로 다시 돌려도 에이전트 파일은 `[있음, 건너뜀]`으로 옛 판이 남고,
옛 판에는 `skills: [sdd-rules]` 주입 줄이 없다. 기존 설치본에 남은 모델 등급 스킬은 더 쓰지 않으니
지워도 된다는 것도 알려야 한다(SHALL).

#### Scenario: README의 설치 흐름

- **WHEN** `README.md`의 설치 절만 읽는다
- **THEN** 플러그인 설치 두 줄과 `/sdd:init`이 먼저 나온다
- **AND** 복사 방식으로 복제 → 대상 프로젝트로 이동 → `bash install.sh` → 새 세션의 흐름을 알 수 있다
- **AND** `--dry-run`으로 미리 볼 수 있다는 것도 알 수 있다
- **AND** `.claude/skills/openspec-*`과 `.claude/commands/opsx/`는 복사하지 말고
  `openspec init`이 깔게 하라는 기존 경고가 남아 있다

#### Scenario: README가 5종을 말한다

- **WHEN** `README.md`의 복사 방식 제품 설명과 "설치 확인" 절을 읽는다
- **THEN** `orchestra`, `sdd-rules`, `sdd-sync`가 둘 다에 들어 있다
- **AND** 그 밖의 스킬은 둘 다에 없다 (시나리오 이름은 CLI가 이름 변경을 막아 그대로 둔다)

#### Scenario: README가 공용 스킬 두 개도 말한다

- **WHEN** `README.md`의 제품 설명(손으로 설치하는 복사 명령 포함)과 "설치 확인" 절을 읽는다
- **THEN** `sdd-rules`와 `sdd-sync`가 둘 다에 들어 있다
- **AND** 설치 확인이 openspec 공식 스킬 6개의 존재를 필수로 요구하지 않는다

#### Scenario: 이미 설치한 프로젝트를 위한 안내

- **WHEN** `README.md`에서 이미 설치한 프로젝트에 관한 안내를 찾는다
- **THEN** `sdd-rules`·`sdd-sync` 두 스킬을 새로 넣어야 한다는 안내가 있다
- **AND** 에이전트 파일을 새 판으로 바꿔야 한다(새 판과 비교해 옮긴다)는 안내가 있다
- **AND** `install.sh`를 다시 돌리는 것만으로는 이미 있는 에이전트 파일이 바뀌지 않는다는 것을 알 수 있다
- **AND** 남은 모델 등급 스킬은 지워도 된다는 안내가 있다

### Requirement: 제품 6종을 깔아야 한다

`install.sh`가 대상 프로젝트에 넣는 제품은 **6종**이어야 한다(SHALL): 서브에이전트 파일 8개, `orchestra`,
`sdd-rules`, `sdd-sync` 세 스킬, 권한 설정 파일, 그리고 `CLAUDE.md`의 조각.

원본은 이 저장소의 플러그인 레이아웃에서 가져와야 한다(SHALL): `agents/*.md`, `skills/orchestra/`,
`skills/sdd-rules/`, `skills/sdd-sync/`, `.claude/settings.json`, `.claude/CLAUDE.md`의 마커 구획. 대상 프로젝트의
위치는 기존 그대로다(SHALL): `.claude/agents/*.md`, `.claude/skills/<이름>/`, `.claude/settings.json`.
원본 위치만 바꾸고 대상 위치를 바꾸지 않아야 기존 설치본과 같은 모양으로 깔린다.

없어진 모델 등급 스킬은 복사해서는 안 된다(MUST NOT).

에이전트가 frontmatter `skills:`로 `sdd-rules`와 `sdd-sync`를 주입받으므로, 둘이 빠지면 설치본의 에이전트가
공용 규칙과 sync 절차를 받지 못한다.

설치 확인 절차도 6종에 맞아야 한다(MUST): 에이전트 파일 개수 확인, `orchestra`·`sdd-rules`·`sdd-sync` 세
스킬의 존재 확인. openspec 공식 스킬 6개(`.claude/skills/openspec-*`)의 존재 확인은 설치 확인의 필수 항목에서
빠져야 한다(SHALL) — 파이프라인이 더 이상 그 문서에 기대지 않으므로, 없다고 경고하면 없는
문제를 있는 것처럼 알리게 된다.

#### Scenario: 복사 대상 목록

- **WHEN** `install.sh`의 복사 부분을 읽는다
- **THEN** 원본 `agents/`의 `.md` 파일들, `skills/orchestra`, `skills/sdd-rules`, `skills/sdd-sync`,
  `.claude/settings.json`이 모두 대상으로 적혀 있다
- **AND** 스킬은 이 세 개뿐이다

#### Scenario: 공용 스킬이 실제로 복사된다

- **WHEN** 빈 임시 프로젝트에서 실제로 설치를 돌린다
- **THEN** `.claude/skills/sdd-rules/SKILL.md`와 `.claude/skills/sdd-sync/SKILL.md`가 그 프로젝트에 생긴다
- **AND** 내용이 이 저장소의 원본(`skills/sdd-rules/SKILL.md`, `skills/sdd-sync/SKILL.md`)과 같다

#### Scenario: 마른 실행이 공용 스킬을 복사 대상으로 보여준다

- **WHEN** 빈 `mktemp -d` 임시 프로젝트(커밋 하나)에서 `bash install.sh --dry-run`을 돌린다
- **THEN** 출력에 `sdd-rules`와 `sdd-sync`가 복사 예정 대상으로 나온다
- **AND** 종료코드가 0이다

#### Scenario: 설치 확인이 7종을 본다

- **WHEN** 설치가 끝난 뒤 스크립트가 내는 확인 부분을 읽는다 (시나리오 이름은 CLI가 이름 변경을 막아 그대로 둔다. 지금 제품은 6종이다)
- **THEN** 에이전트 개수(8이어야 한다)가 나온다
- **AND** `orchestra`, `sdd-rules`, `sdd-sync` 스킬이 깔렸는지 확인한 결과가 나온다
- **AND** openspec 공식 스킬 6개가 없다는 이유로 경고하지 않는다

#### Scenario: 임시 프로젝트에 8개 에이전트가 실제로 깔린다

- **WHEN** `mktemp -d`로 만든 빈 임시 프로젝트에서 `bash install.sh`를 실제로 돌린다
  (이 저장소나 `~/work-space/`가 아닌 임시 디렉터리에서)
- **THEN** `.claude/agents/*.md`가 8개 생기고, 그 안에 `code-explorer.md`가 있다
- **AND** 설치 확인 절에 "에이전트: 8개 (8이어야 한다)"가 출력된다

### Requirement: CLAUDE.md 조각의 원본은 한 벌이어야 한다

`CLAUDE.md` 조각의 원본은 이 저장소의 프로젝트 지침 파일 `.claude/CLAUDE.md` 안의 **마커 구획**
(`<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->`) 한 곳이어야 한다(SHALL). 저장소 루트는 플러그인
루트라서 거기에 `CLAUDE.md`를 두지 않는다(`distribution/sdd-plugin`).

`install.sh`는 그 문구를 스크립트 안에 베껴 적어서는 안 되며(MUST NOT), 마커 구획에서
기계적으로 뽑아 써야 한다(SHALL):

```
sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$SRC/.claude/CLAUDE.md"
```

`README.md`도 그 조각을 코드블록으로 다시 실어서는 안 되며(MUST NOT), 대신 위와 같은 방식으로
뽑아 붙이는 방법을 적어야 한다(SHALL).

같은 문구의 사본이 갈라지는 것이 이 저장소에서 가장 나쁜 고장이고 이미 두 번 났다. 그래서 조각
사본을 1벌로 유지한다. 바뀌는 것은 원본 파일의 위치뿐이고, 대상 프로젝트에 붙는 파일은 여전히
대상 프로젝트 루트의 `CLAUDE.md`다.

#### Scenario: 조각을 담은 파일이 저장소에 하나뿐이다

- **WHEN** 저장소 전체에서 조각 본문의 특징적인 한 줄(파이프라인 순서를 적은 `순서:` 줄)을
  담은 파일을 센다 (`openspec/` 아래는 제외한다 — 계획 문서라서 설명으로 인용한다)
- **THEN** 파일이 정확히 하나이고, 그 파일은 `.claude/CLAUDE.md`다
- **AND** `install.sh`에도 `README.md`에도 그 줄이 없다

#### Scenario: 스크립트가 마커 구획에서 조각을 뽑는다

- **WHEN** `install.sh`의 `CLAUDE.md` 처리 부분을 읽는다
- **THEN** 조각 문구가 변수에 하드코딩되어 있지 않다
- **AND** `<!-- init-SDD:begin -->`부터 `<!-- init-SDD:end -->`까지를 `$SRC/.claude/CLAUDE.md`에서
  뽑아내는 명령이 있다

#### Scenario: 뽑힌 조각이 원본과 같다

- **WHEN** 임시 프로젝트에서 실제로 설치를 돌린 뒤, 대상 프로젝트 `CLAUDE.md`에 들어간
  마커 구획과 이 저장소 `.claude/CLAUDE.md`의 마커 구획을 대조한다
- **THEN** 두 구획의 내용이 같다
- **AND** 마커 줄(`<!-- init-SDD:begin -->`, `<!-- init-SDD:end -->`)도 함께 들어가 있다

#### Scenario: 대상 프로젝트에 CLAUDE.md가 이미 있다

- **WHEN** 사용자가 쓴 내용이 있는 `CLAUDE.md`가 있는 프로젝트에 설치한다
- **THEN** 그 파일을 덮어쓰지 않고 조각을 **끝에 덧붙인다**
- **AND** 사용자가 쓴 내용이 그대로 남아 있다

### Requirement: 이미 있는 파일을 덮어써서는 안 된다

`install.sh`는 대상 프로젝트에 같은 이름의 파일이 이미 있으면 **덮어쓰지 않고 건너뛰어야
한다**(SHALL). 대상 프로젝트의 설정을 지키는 것이 설치를 마치는 것보다 우선한다.

건너뛴 파일이 있으면 그 목록과 **저장소 쪽 원본 경로**를 함께 알려야 한다(MUST). 원본 경로는
실제로 있는 경로여야 한다(MUST) — 원본 위치(`agents/`, `skills/<이름>/`)와 대상 위치
(`.claude/agents/`, `.claude/skills/<이름>/`)가 다르므로 대상 경로에 `$SRC/`를 붙여 만들어서는 안 된다(MUST NOT).
사용자가 직접 비교해서 필요한 내용을 옮길 수 있어야 하기 때문이다.

`.claude/settings.json`이 이미 있으면 JSON을 합치려 하지 말고 건너뛰고 알려야 한다(SHALL).
합치기는 키가 겹칠 때 한쪽을 버려야 하고, 어느 쪽을 버렸는지 사용자가 알 수 없다.

#### Scenario: 겹치는 파일이 있을 때

- **WHEN** `.claude/agents/preparer.md`와 `.claude/settings.json`이 이미 있는 프로젝트에
  설치한다
- **THEN** 그 두 파일의 내용이 바뀌지 않는다
- **AND** 건너뛴 파일 목록이 저장소 쪽 원본 경로와 함께 출력된다
- **AND** `.claude/agents/preparer.md`의 원본으로 `<저장소>/agents/preparer.md`가 나오고, 출력된 원본 경로가 모두 실제로 있다

#### Scenario: 설정 파일을 합치지 않는다

- **WHEN** `install.sh`의 `.claude/settings.json` 처리 부분을 읽는다
- **THEN** JSON을 합치는 절차가 없다
- **AND** 이미 있으면 건너뛰고 사용자에게 직접 옮기라고 알린다

## ADDED Requirements

### Requirement: 설치 스크립트는 플러그인으로 이전하라고 안내해야 한다

`install.sh`는 시작 부분과 끝의 "다음 할 일"에서 플러그인 설치가 권장 방식이라는 것을 한 줄씩 알려야
한다(SHALL). 안내는 `README.md`의 설치 절을 가리켜야 하며(SHALL), 플러그인 설치 절차를 스크립트 안에 다시
적어서는 안 된다(MUST NOT).

플러그인과 복사 방식을 한 프로젝트에 함께 쓰면 같은 에이전트가 두 이름(`sdd:<이름>`, `<이름>`)으로 실린다는
것도 한 줄로 알려야 한다(SHALL). 이전하려면 복사된 에이전트·스킬을 지우고 플러그인을 쓰라고 안내한다.

`install.sh`는 지워지지 않고 동작해야 한다(SHALL) — 제거는 실전 검증 뒤 별도 change에서 한다.

#### Scenario: 마른 실행에 이전 안내가 나온다

- **WHEN** 빈 `mktemp -d` 임시 프로젝트(커밋 하나)에서 `bash install.sh --dry-run`을 돌린다
- **THEN** 플러그인이 권장 방식이라는 안내와 `README.md`를 가리키는 줄이 나온다
- **AND** 같은 에이전트가 두 이름으로 실릴 수 있다는 안내가 나온다
- **AND** 종료코드가 0이다
