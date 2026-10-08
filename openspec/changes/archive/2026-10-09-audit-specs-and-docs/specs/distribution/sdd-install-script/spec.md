# Spec Delta

## MODIFIED Requirements

### Requirement: 설치 스크립트는 저장소에 남아 있어야 한다

`install.sh`는 저장소 루트에 있어야 한다(SHALL). 이 파일이 없으면 `README.md`만 읽고 복사 방식으로
SDD를 얹을 방법이 남지 않는다.

문법이 깨지지 않아야 하며(MUST), 무엇을 할지만 보여주는 마른 실행(`--dry-run`)이 있어야
한다(MUST). 이 저장소에는 테스트 스위트가 없어서 이 두 가지가 스크립트를 직접 돌려 보는 검증
수단이다. 저장소 전체의 검증 수단 목록은 `openspec/config.yaml`의 `context`에 있다.

설정 전환 스킬(`switch_skill/SKILL.md`)은 저장소에 없어야 한다(MUST NOT). 에이전트 설정은
사람마다 달라서 공유 저장소가 들고 다닐 물건이 아니다(사용자 결정).

#### Scenario: 스크립트가 있고 문법이 맞다

- **WHEN** 저장소 루트에서 `bash -n install.sh`를 돌린다
- **THEN** 종료코드가 0이다
- **AND** `install.sh`가 저장소 루트에 존재한다

#### Scenario: 마른 실행이 아무것도 바꾸지 않는다

- **WHEN** 임시 프로젝트에서 `bash install.sh --dry-run`을 돌린다
- **THEN** 무엇을 할지 보여주고 종료코드가 0이다
- **AND** 그 프로젝트의 파일이 하나도 바뀌지 않는다 (`git status`가 실행 전과 같다)

#### Scenario: 전환 스킬이 없다

- **WHEN** 저장소 전체에서 `switch_skill`이라는 이름의 디렉터리나 파일을 찾는다
- **THEN** 아무것도 없다
- **AND** `README.md`·`.claude/CLAUDE.md`·`skills/orchestra/SKILL.md` 어디에도 그것을
  쓰라는 안내가 남아 있지 않다

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

#### Scenario: 조각을 담은 파일이 저장소에 하나뿐이다

- **WHEN** 저장소 전체에서 줄 맨 앞이 `순서: `로 시작하는 줄(조각 본문의 파이프라인 순서 줄)을 담은 파일을
  `command grep -rlE '^순서: ' --exclude-dir=openspec --exclude-dir=.git .`로 센다 (`openspec/` 아래는 계획 문서라서 설명으로 인용하므로 제외한다)
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

### Requirement: 조각이 이미 들어갔는지 낱말 검색만으로 판별해서는 안 된다

`install.sh`는 `CLAUDE.md`에서 특정 **낱말** 하나를 찾는 것만으로 조각이 이미 들어갔는지
정해서는 안 된다(MUST NOT). 사람이 쓰는 낱말을 지문으로 쓰면 우연히 쓴 낱말이나 다른 언어로
옮긴 문구 때문에 오판한다.

대신 **마커 구획을 지문으로 써야 하고**(SHALL), 다음 세 갈래로 나눠 다뤄야 한다(MUST):

| 대상 `CLAUDE.md`의 상태 | 무엇을 하는가 |
|---|---|
| 마커 구획이 있다 | 이미 들어갔다. 건너뛴다 |
| 마커도 없고 옛 낱말도 없다 | 조각을 끝에 덧붙인다 |
| 마커는 없는데 옛 낱말이 있다 | **넣지 않고, 왜 넣지 않았는지 알린다** |

세 번째 갈래를 짐작으로 처리해서는 안 된다(MUST NOT). 넣지 않은 채 **사실과 직접 확인하는
방법을 알려야 한다**(MUST).

#### Scenario: 마커가 이미 있는 프로젝트에 다시 설치한다

- **WHEN** 이미 설치를 한 번 돌린 프로젝트에 다시 설치를 돌린다
- **THEN** `CLAUDE.md`의 마커 구획이 정확히 하나뿐이다 (조각이 두 번 들어가지 않는다)
- **AND** 이미 들어가 있다는 것을 알린다

#### Scenario: 마커도 낱말도 없는 프로젝트

- **WHEN** SDD와 무관한 `CLAUDE.md`가 있는 프로젝트에 설치한다
- **THEN** 조각이 마커째로 파일 끝에 덧붙는다
- **AND** 원래 내용이 그대로 남아 있다

#### Scenario: 마커는 없는데 옛 낱말이 있는 프로젝트

- **WHEN** `CLAUDE.md`에 마커는 없지만 옛 방식의 조각(또는 그 낱말)이 들어 있는 프로젝트에
  설치한다
- **THEN** 조각을 넣지 않는다
- **AND** 마커가 없는데 옛 낱말이 있다는 사실과, 직접 확인해서 넣는 방법을 알려 준다

### Requirement: 복사 방식과 링크 방식 중 어느 것을 쓸지 알려 줘야 한다

SDD를 얹는 방식은 세 가지다: **플러그인**(권장), `install.sh`의 **복사 방식**, `init-sdd` 스킬의
**링크 방식**. 복사·링크 방식은 기존 설치 방식으로 남아 있다. `README.md`는 **어떤 때 어느 것을
쓰는지**를 알려 줘야 하며(SHALL), 그 안내의 본문은 `README.md` 한 곳에만 있어야 한다(SHALL):

| 상황 | 쓰는 것 |
|---|---|
| 새로 시작한다 | **플러그인** — `/plugin install sdd@sdd-marketplace`, 그 뒤 `/sdd:init` |
| 팀이 SDD에 합의했고 설정을 프로젝트 저장소에 둔다 | **복사 방식** — `install.sh` |
| 개인 설정을 별도 git으로 관리한다 | **링크 방식** — `init-sdd` 스킬 |

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
- **AND** 이미 있는 파일을 건너뛰는 규칙과 조각을 `.claude/CLAUDE.md`의 마커 구획에서 뽑는 방식이 지켜진다

## REMOVED Requirements

### Requirement: 설치 안내는 README 한 곳에만 있어야 한다

**Reason**: 본문이 500자를 넘고(1.14.1 strict 실패), 시나리오 "README가 5종을 말한다"는 이름이 본문(스킬 3개)과 맞지 않고
"README가 공용 스킬 두 개도 말한다"와 거의 겹치며, 본문에 "CLI가 막아 이름을 둔다"는 메타 문장이 있다.
MODIFIED는 시나리오 이름을 바꾸거나 합칠 수 없어(1.14.1 실측) 새 헤더 세 개로 나눠 다시 넣는다.
**Migration**: 설치 절차 의무는 ADDED "설치 절차는 README 한 곳에 플러그인부터 서술되어야 한다"로,
제품 6종 대응은 ADDED "README의 복사 방식 설명과 설치 확인은 제품 6종과 맞아야 한다"(두 시나리오를 하나로 합침)로,
이미 설치한 프로젝트 안내는 ADDED "README는 이미 설치한 프로젝트를 위한 갱신 안내를 담아야 한다"로 옮겨 간다.

### Requirement: 제품 6종을 깔아야 한다

**Reason**: 본문이 500자를 넘고(1.14.1 strict 실패), 시나리오 이름 "설치 확인이 7종을 본다"가 제품 6종과 맞지 않으며
본문에 "CLI가 이름 변경을 막아 그대로 둔다"는 메타 문장이 있다. MODIFIED는 시나리오 이름을 바꿀 수 없어(1.14.1 실측) 새 헤더 두 개로 나눠 다시 넣는다.
**Migration**: 복사 의무는 ADDED "install.sh는 제품 6종을 플러그인 레이아웃에서 가져와 기존 위치에 깔아야 한다"로,
설치 확인 의무는 ADDED "install.sh의 설치 확인은 제품 6종에 맞아야 한다"로 옮겨 간다.

## ADDED Requirements

### Requirement: install.sh와 init-sdd 스킬 문서는 서로를 가리켜야 한다

`install.sh`와 `init-sdd` 스킬 문서는 **서로를 가리켜야 한다**(MUST). `install.sh`는 설치를
마친 뒤 안내에서 링크 방식도 있다는 것을 알려야 하고(SHALL), 그 안내는 **한 줄이면
충분하다** — 절차를 다시 적어서는 안 된다(MUST NOT). 같은 문구의 사본이 갈라지는 것은 이
저장소가 이미 두 번 겪은 고장이다(사용자 결정).

#### Scenario: init-sdd 스킬이 복사 방식을 가리킨다

- **WHEN** `.claude/skills/init-sdd/SKILL.md`를 읽는다
- **THEN** 복사 방식(`install.sh`)이 있다는 것과 언제 쓰는지가 적혀 있다
- **AND** `install.sh`가 하는 복사 절차를 다시 서술하지 않는다

### Requirement: 설치 절차는 README 한 곳에 플러그인부터 서술되어야 한다

같은 설치 절차가 두 곳에 서술되어서는 안 된다(MUST NOT). `README.md`만 읽고 설치할 수
있어야 하며(SHALL), 플러그인 설치가 먼저 나와야 한다(SHALL). 복사 방식에는 최소한 다음 흐름이 적혀
있어야 한다(MUST): 이 저장소를 복제한다 → 대상 프로젝트로 이동한다 → `bash install.sh`를 돌린다 →
`CLAUDE.md`가 합쳐졌는지 확인한다 → Claude Code를 새 세션으로 다시 연다.

#### Scenario: README의 설치 흐름

- **WHEN** `README.md`의 설치 절만 읽는다
- **THEN** 플러그인 설치 두 줄과 `/sdd:init`이 먼저 나온다
- **AND** 복사 방식으로 복제 → 대상 프로젝트로 이동 → `bash install.sh` → 새 세션의 흐름을 알 수 있다
- **AND** `--dry-run`으로 미리 볼 수 있다는 것도 알 수 있다
- **AND** `.claude/skills/openspec-*`과 `.claude/commands/opsx/`는 복사하지 말고
  `openspec init`이 깔게 하라는 기존 경고가 남아 있다

### Requirement: README의 복사 방식 설명과 설치 확인은 제품 6종과 맞아야 한다

`README.md`의 복사 방식 제품 설명과 설치 확인 절차는 **제품 6종**(`distribution/sdd-install-script`의
"install.sh는 제품 6종을…" 요구사항)과 맞아야 한다(MUST). `sdd-rules`·`sdd-sync`가 빠져 있으면 손으로
설치하는 사용자가 그 둘을 빠뜨려 에이전트가 공용 규칙을 못 받는다.

#### Scenario: README가 세 스킬을 제품 설명과 설치 확인 양쪽에 적는다

- **WHEN** `README.md`의 복사 방식 제품 설명(손으로 설치하는 복사 명령 포함)과 "설치 확인" 절을 읽는다
- **THEN** `orchestra`, `sdd-rules`, `sdd-sync`가 둘 다에 들어 있다
- **AND** 그 밖의 스킬은 둘 다에 없다
- **AND** 설치 확인이 openspec 공식 스킬 6개의 존재를 필수로 요구하지 않는다

### Requirement: README는 이미 설치한 프로젝트를 위한 갱신 안내를 담아야 한다

`README.md`에는 이미 복사 방식으로 설치한 프로젝트를 위한 안내가 있어야 한다(SHALL): 두 스킬
(`sdd-rules`, `sdd-sync`)을 새로 넣고, **에이전트 파일을 새 판으로 바꿔야 한다**(새 판과 비교해 옮긴다).
`install.sh`는 이미 있는 파일을 덮어쓰지 않으므로 다시 돌려도 에이전트 파일은 `[있음, 건너뜀]`으로 옛 판이
남는다. 기존 설치본에 남은 모델 등급 스킬은 더 쓰지 않으니 지워도 된다는 것도 알려야 한다(SHALL).

#### Scenario: 이미 설치한 프로젝트를 위한 안내

- **WHEN** `README.md`에서 이미 설치한 프로젝트에 관한 안내를 찾는다
- **THEN** `sdd-rules`·`sdd-sync` 두 스킬을 새로 넣어야 한다는 안내가 있다
- **AND** 에이전트 파일을 새 판으로 바꿔야 한다(새 판과 비교해 옮긴다)는 안내가 있다
- **AND** `install.sh`를 다시 돌리는 것만으로는 이미 있는 에이전트 파일이 바뀌지 않는다는 것을 알 수 있다
- **AND** 남은 모델 등급 스킬은 지워도 된다는 안내가 있다

### Requirement: install.sh는 제품 6종을 플러그인 레이아웃에서 가져와 기존 위치에 깔아야 한다

`install.sh`가 대상 프로젝트에 넣는 제품은 **6종**이어야 한다(SHALL): 서브에이전트 파일 8개, `orchestra`,
`sdd-rules`, `sdd-sync` 세 스킬, 권한 설정 파일, 그리고 `CLAUDE.md`의 조각.

원본은 이 저장소의 플러그인 레이아웃에서 가져와야 한다(SHALL): `agents/*.md`, `skills/orchestra/`,
`skills/sdd-rules/`, `skills/sdd-sync/`, `.claude/settings.json`, `.claude/CLAUDE.md`의 마커 구획. 대상 프로젝트의
위치는 기존 그대로다(SHALL): `.claude/agents/*.md`, `.claude/skills/<이름>/`, `.claude/settings.json`.
없어진 모델 등급 스킬은 복사해서는 안 된다(MUST NOT).

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

#### Scenario: 임시 프로젝트에 8개 에이전트가 실제로 깔린다

- **WHEN** `mktemp -d`로 만든 빈 임시 프로젝트에서 `bash install.sh`를 실제로 돌린다
  (이 저장소나 `~/work-space/`가 아닌 임시 디렉터리에서)
- **THEN** `.claude/agents/*.md`가 8개 생기고, 그 안에 `code-explorer.md`가 있다
- **AND** 설치 확인 절에 "에이전트: 8개 (8이어야 한다)"가 출력된다

### Requirement: install.sh의 설치 확인은 제품 6종에 맞아야 한다

`install.sh`가 설치 뒤 내는 확인은 제품 6종에 맞아야 한다(MUST): 에이전트 파일 개수 확인,
`orchestra`·`sdd-rules`·`sdd-sync` 세 스킬의 존재 확인. openspec 공식 스킬 6개(`.claude/skills/openspec-*`)의
존재 확인은 설치 확인의 필수 항목에서 빠져야 한다(SHALL) — 파이프라인이 그 문서에 기대지 않으므로,
없다고 경고하면 없는 문제를 있는 것처럼 알리게 된다.

#### Scenario: 설치 확인이 에이전트 개수와 세 스킬을 본다

- **WHEN** 설치가 끝난 뒤 스크립트가 내는 확인 부분을 읽는다
- **THEN** 에이전트 개수(8이어야 한다)가 나온다
- **AND** `orchestra`, `sdd-rules`, `sdd-sync` 스킬이 깔렸는지 확인한 결과가 나온다
- **AND** openspec 공식 스킬 6개가 없다는 이유로 경고하지 않는다
