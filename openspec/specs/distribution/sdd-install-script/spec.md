# distribution/sdd-install-script Specification

## Purpose

`install.sh`가 대상 프로젝트에 SDD 파이프라인을 얹는 절차를 정한다. 제품 파일과
`CLAUDE.md` 조각의 원본이 저장소에 **한 벌로만** 존재해야 하고, 대상 프로젝트에 이미 있는
파일을 잃지 않아야 하며, 설치 안내가 한 곳에만 있어야 한다.

## Requirements

### Requirement: 설치 스크립트는 저장소에 남아 있어야 한다

`install.sh`는 저장소 루트에 있어야 한다(SHALL). 이 파일이 없으면 `README.md`만 읽고 SDD를
얹을 방법이 **하나도 남지 않는다.**

문법이 깨지지 않아야 하며(MUST), 무엇을 할지만 보여주는 마른 실행(`--dry-run`)이 있어야
한다(MUST). 이 저장소는 테스트 스위트가 없어서 이 두 가지가 스크립트를 검증하는 유일한
수단이다 — `openspec/config.yaml`의 `context`와 메인 spec
`agent-instructions/project-context-completeness`가 그렇게 규정하고 있다.

설정 전환 스킬(`switch_skill/SKILL.md`)은 저장소에 없어야 한다(MUST NOT). 에이전트 설정은
사람마다 달라서 공유 저장소가 들고 다닐 물건이 아니고, 각자 로컬에서 관리하면 전환기가
풀려던 문제가 애초에 생기지 않는다(사용자 결정).

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
- **AND** `README.md`·`CLAUDE.md`·`.claude/skills/orchestra/SKILL.md` 어디에도 그것을
  쓰라는 안내가 남아 있지 않다

### Requirement: CLAUDE.md 조각의 원본은 한 벌이어야 한다

`CLAUDE.md` 조각의 원본은 이 저장소 `CLAUDE.md` 안의 **마커 구획**
(`<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->`) 한 곳이어야 한다(SHALL).

`install.sh`는 그 문구를 스크립트 안에 베껴 적어서는 안 되며(MUST NOT), 마커 구획에서
기계적으로 뽑아 써야 한다(SHALL):

```
sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$SRC/CLAUDE.md"
```

`README.md`도 그 조각을 코드블록으로 다시 실어서는 안 되며(MUST NOT), 대신 위와 같은 방식으로
뽑아 붙이는 방법을 적어야 한다(SHALL).

이 저장소는 실행 코드가 없고 **지시문이 곧 제품**이어서, 같은 문구의 사본이 갈라지는 것이
가장 나쁜 고장이다. 그 고장이 이미 두 번 났다. 조각 사본을 3벌(`CLAUDE.md`,
`install.sh`의 `$SNIPPET`, `README.md` 코드블록)에서 **1벌**로 줄인다.

#### Scenario: 조각을 담은 파일이 저장소에 하나뿐이다

- **WHEN** 저장소 전체에서 조각 본문의 특징적인 한 줄(파이프라인 순서를 적은 `순서:` 줄)을
  담은 파일을 센다 (`openspec/` 아래는 제외한다 — 계획 문서라서 설명으로 인용한다)
- **THEN** 파일이 정확히 하나이고, 그 파일은 `CLAUDE.md`다
- **AND** `install.sh`에도 `README.md`에도 그 줄이 없다

#### Scenario: 스크립트가 마커 구획에서 조각을 뽑는다

- **WHEN** `install.sh`의 `CLAUDE.md` 처리 부분을 읽는다
- **THEN** 조각 문구가 변수에 하드코딩되어 있지 않다
- **AND** `<!-- init-SDD:begin -->`부터 `<!-- init-SDD:end -->`까지를 `$SRC/CLAUDE.md`에서
  뽑아내는 명령이 있다

#### Scenario: 뽑힌 조각이 원본과 같다

- **WHEN** 임시 프로젝트에서 실제로 설치를 돌린 뒤, 대상 프로젝트 `CLAUDE.md`에 들어간
  마커 구획과 이 저장소 `CLAUDE.md`의 마커 구획을 대조한다
- **THEN** 두 구획의 내용이 같다
- **AND** 마커 줄(`<!-- init-SDD:begin -->`, `<!-- init-SDD:end -->`)도 함께 들어가 있다

#### Scenario: 대상 프로젝트에 CLAUDE.md가 이미 있다

- **WHEN** 사용자가 쓴 내용이 있는 `CLAUDE.md`가 있는 프로젝트에 설치한다
- **THEN** 그 파일을 덮어쓰지 않고 조각을 **끝에 덧붙인다**
- **AND** 사용자가 쓴 내용이 그대로 남아 있다

### Requirement: 조각이 이미 들어갔는지 낱말 검색만으로 판별해서는 안 된다

`install.sh`는 `CLAUDE.md`에서 특정 **낱말** 하나를 찾는 것만으로 조각이 이미 들어갔는지
정해서는 안 된다(MUST NOT). 사람이 쓰는 낱말을 지문으로 쓰면 오판 경로가 생긴다:
사용자가 그 낱말을 자기 문장에 우연히 쓴 경우(안 들어갔는데 들어갔다고 본다),
문구를 다른 언어로 옮긴 경우(들어갔는데 안 들어갔다고 본다).

대신 **마커 구획을 지문으로 써야 하고**(SHALL), 다음 세 갈래로 나눠 다뤄야 한다(MUST):

| 대상 `CLAUDE.md`의 상태 | 무엇을 하는가 |
|---|---|
| 마커 구획이 있다 | 이미 들어갔다. 건너뛴다 |
| 마커도 없고 옛 낱말도 없다 | 조각을 끝에 덧붙인다 |
| 마커는 없는데 옛 낱말이 있다 | **넣지 않고, 왜 넣지 않았는지 알린다** |

세 번째 갈래를 짐작으로 처리해서는 안 된다(MUST NOT). 예전 방식으로 이미 깔았을 수도 있고
(그때는 마커가 없었다) 사용자가 우연히 그 낱말을 썼을 수도 있으며, 스크립트가 둘을 구별할
방법이 없다. 넣지 않은 채 **사실과 직접 확인하는 방법을 알려야 한다**(MUST).

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

### Requirement: 제품 5종을 깔아야 한다

`install.sh`가 대상 프로젝트에 넣는 제품은 **5종**이어야 한다(SHALL):
`.claude/agents/*.md` 7개, `.claude/skills/orchestra/`,
`.claude/skills/agent-model-tier/`, `.claude/settings.json`, 그리고 `CLAUDE.md`의 조각.

`.claude/skills/agent-model-tier/`는 이번에 새로 더해지는 것이다. 그 전까지는 4종만 깔았다.
이것도 대상 프로젝트에서 실제로 쓰는 도구이므로 빠지면 안 된다.

설치 확인 절차도 5종에 맞아야 한다(MUST): 에이전트 파일 개수 확인,
`orchestra`와 `agent-model-tier` 스킬 존재 확인, openspec 공식 스킬 6개 존재 확인.

#### Scenario: 복사 대상 목록

- **WHEN** `install.sh`의 복사 부분을 읽는다
- **THEN** `.claude/agents/`의 `.md` 파일들, `.claude/skills/orchestra`,
  `.claude/skills/agent-model-tier`, `.claude/settings.json`이 모두 대상으로 적혀 있다

#### Scenario: 모델 등급 스킬이 실제로 복사된다

- **WHEN** 빈 임시 프로젝트에서 실제로 설치를 돌린다
- **THEN** `.claude/skills/agent-model-tier/SKILL.md`가 그 프로젝트에 생긴다
- **AND** 내용이 이 저장소의 원본과 같다

#### Scenario: 설치 확인이 5종을 본다

- **WHEN** 설치가 끝난 뒤 스크립트가 내는 확인 부분을 읽는다
- **THEN** 에이전트 개수(7이어야 한다)가 나온다
- **AND** `orchestra`와 `agent-model-tier` 스킬이 깔렸는지 확인한 결과가 나온다
- **AND** openspec 공식 스킬 6개 중 빠진 것이 있으면 그 이름과 복구 명령을 알려 준다

#### Scenario: 임시 프로젝트에 8개 에이전트가 실제로 깔린다

- **WHEN** `mktemp -d`로 만든 빈 임시 프로젝트에서 `bash install.sh`를 실제로 돌린다
  (이 저장소나 `~/work-space/`가 아닌 임시 디렉터리에서)
- **THEN** `.claude/agents/*.md`가 8개 생기고, 그 안에 `code-explorer.md`가 있다
- **AND** 설치 확인 절에 "에이전트: 8개 (8이어야 한다)"가 출력된다


### Requirement: 이미 있는 파일을 덮어써서는 안 된다

`install.sh`는 대상 프로젝트에 같은 이름의 파일이 이미 있으면 **덮어쓰지 않고 건너뛰어야
한다**(SHALL). 대상 프로젝트의 설정을 지키는 것이 설치를 마치는 것보다 우선한다.

건너뛴 파일이 있으면 그 목록과 **저장소 쪽 원본 경로**를 함께 알려야 한다(MUST).
사용자가 직접 비교해서 필요한 내용을 옮길 수 있어야 하기 때문이다.

`.claude/settings.json`이 이미 있으면 JSON을 합치려 하지 말고 건너뛰고 알려야 한다(SHALL).
합치기는 키가 겹칠 때 한쪽을 버려야 하고, 어느 쪽을 버렸는지 사용자가 알 수 없다.

#### Scenario: 겹치는 파일이 있을 때

- **WHEN** `.claude/agents/preparer.md`와 `.claude/settings.json`이 이미 있는 프로젝트에
  설치한다
- **THEN** 그 두 파일의 내용이 바뀌지 않는다
- **AND** 건너뛴 파일 목록이 저장소 쪽 원본 경로와 함께 출력된다

#### Scenario: 설정 파일을 합치지 않는다

- **WHEN** `install.sh`의 `.claude/settings.json` 처리 부분을 읽는다
- **THEN** JSON을 합치는 절차가 없다
- **AND** 이미 있으면 건너뛰고 사용자에게 직접 옮기라고 알린다

### Requirement: 전제 조건을 먼저 확인해야 한다

`install.sh`는 설치를 시작하기 전에 다음을 확인해야 한다(SHALL): git이 있는지,
대상이 git 저장소인지, 커밋이 하나라도 있는지, openspec CLI가 있고 권장 버전인지.

커밋이 하나도 없는 저장소에서는 멈추고 초기 커밋을 만들라고 알려야 한다(MUST) —
그 상태에서는 preparer가 작업 브랜치를 만들 수 없다.

저장소 자신 안에서 실행했을 때는 멈춰야 한다(MUST). 원본과 대상이 같으면 자기 자신을
자기 위에 복사하는 것이 된다.

#### Scenario: 커밋이 없는 저장소

- **WHEN** `git init`만 하고 커밋이 없는 프로젝트에서 설치를 돌린다
- **THEN** 멈추고 초기 커밋을 만들라고 알린다
- **AND** 파일이 하나도 바뀌지 않는다

#### Scenario: 저장소 자신 안에서 실행

- **WHEN** init-SDD 저장소 루트에서 `bash install.sh`를 돌린다
- **THEN** 멈추고 설치할 프로젝트로 이동해서 실행하라고 알린다

### Requirement: openspec CLI가 깔아주는 것은 건드려서는 안 된다

`install.sh`는 `.claude/skills/openspec-*` 6개와 `.claude/commands/opsx/`를 복사해서는 안
된다(MUST NOT). 이 저장소에 들어 있는 것은 특정 버전의 스냅샷일 뿐이며,
`openspec init --tools claude`가 사용자의 CLI 버전에 맞는 것을 깔아 준다. 복사하면 오래된
것으로 덮어쓴다.

`.claude/settings.local.json`을 만들거나 고쳐서는 안 된다(MUST NOT). 개인 설정이며 추적
제외 대상이다. `.gitignore`에 한 줄을 더하라는 **안내만** 한다(SHALL).

#### Scenario: openspec 스킬은 CLI가 깔게 한다

- **WHEN** `install.sh`의 복사 대상 목록을 읽는다
- **THEN** `openspec-*` 스킬과 `commands/opsx/`가 대상에 없다
- **AND** 대신 `openspec init --tools claude`를 돌리는 단계가 있다

#### Scenario: 개인 설정은 안내만 한다

- **WHEN** 설치가 끝난 뒤 다음 할 일 안내를 읽는다
- **THEN** `.gitignore`에 `.claude/settings.local.json` 한 줄을 더하라는 안내가 있다
- **AND** 스크립트가 그 파일을 직접 만들거나 고치지 않는다

### Requirement: 복사 방식과 링크 방식 중 어느 것을 쓸지 알려 줘야 한다

SDD를 얹는 방식은 두 가지다: `install.sh`의 **복사 방식**과 `init-sdd` 스킬의 **링크
방식**. `README.md`는 **어떤 때 어느 것을 쓰는지**를 알려 줘야 한다(SHALL):

| 상황 | 쓰는 것 |
|---|---|
| 팀이 SDD 방식에 합의했다. 설정을 프로젝트 저장소에 두어도 된다 | **복사 방식** — `install.sh` |
| 개인이 자기 agentic 설정을 별도 git으로 관리한다. 공유 저장소에 남기지 않는다 | **링크 방식** — `init-sdd` 스킬 |

이 안내의 본문은 `README.md` 한 곳에만 있어야 한다(SHALL). 같은 절차를 두 곳에 서술해서는
안 된다는 기존 요구사항("설치 안내는 README 한 곳에만 있어야 한다")이 그대로 적용된다.
안내가 없으면 같은 일을 하는 절차가 두 곳에 있는 것처럼 보이고, 이 저장소는 이미 그 고장
(같은 문구의 사본이 갈라지는 것)을 두 번 겪었다(사용자 결정).

`install.sh`와 `init-sdd` 스킬 문서는 **서로를 가리켜야 한다**(MUST). `install.sh`는 설치를
마친 뒤 안내에서 링크 방식도 있다는 것을 알려야 하고(SHALL), 그 안내는 **한 줄이면
충분하다** — 절차를 다시 적어서는 안 된다(MUST NOT).

이 요구사항은 `install.sh`의 **복사 동작을 바꾸지 않는다.** 복사 대상 목록(제품 5종),
덮어쓰기 금지, 조각을 마커 구획에서 뽑는 방식은 그대로다.

#### Scenario: README가 두 방식 중 고르는 법을 알려 준다

- **WHEN** `README.md`의 `## 설치` 절 맨 앞을 읽는다
- **THEN** 복사 방식과 링크 방식이 어떤 때 쓰는 것인지 갈라져 적혀 있다
- **AND** 링크 방식을 쓰려면 `init-sdd` 스킬을 쓰라고 적혀 있다
- **AND** 기존 "방법 1 — install.sh"와 "방법 2 — 손으로"가 복사 방식으로서 그대로 남아 있다

#### Scenario: install.sh가 링크 방식을 가리킨다

- **WHEN** `bash install.sh --dry-run`을 돌리거나 `install.sh`의 안내 부분을 읽는다
- **THEN** 링크 방식(`init-sdd` 스킬)도 있다는 안내가 나온다
- **AND** 링크를 거는 절차 자체는 `install.sh`에 서술되어 있지 않다
- **AND** `bash -n install.sh`가 종료코드 0이다

#### Scenario: 복사 동작이 그대로다

- **WHEN** 변경 뒤 `install.sh`의 복사 대상 목록을 읽는다
- **THEN** `.claude/agents/`의 `.md` 파일들, `.claude/skills/orchestra`,
  `.claude/skills/agent-model-tier`, `.claude/settings.json`이 변경 전과 똑같이 대상이다
- **AND** `CLAUDE.md` 조각을 마커 구획에서 뽑는 부분이 바뀌지 않았다

### Requirement: 설치 안내는 README 한 곳에만 있어야 한다

같은 설치 절차가 두 곳에 서술되어서는 안 된다(MUST NOT). `README.md`만 읽고 설치할 수
있어야 하며(SHALL), 최소한 다음 흐름이 적혀 있어야 한다(MUST):
이 저장소를 복제한다 → 대상 프로젝트로 이동한다 → `bash install.sh`를 돌린다 →
`CLAUDE.md`가 합쳐졌는지 확인한다 → Claude Code를 새 세션으로 다시 연다.

`README.md`의 제품 설명과 설치 확인 절차는 **제품 5종**과 맞아야 한다(MUST).
`agent-model-tier`가 빠져 있으면 사용자가 그 스킬이 있는지 모른다.

#### Scenario: README의 설치 흐름

- **WHEN** `README.md`의 설치 절만 읽는다
- **THEN** 복제 → 대상 프로젝트로 이동 → `bash install.sh` → 새 세션의 흐름을 알 수 있다
- **AND** `--dry-run`으로 미리 볼 수 있다는 것도 알 수 있다
- **AND** `.claude/skills/openspec-*`과 `.claude/commands/opsx/`는 복사하지 말고
  `openspec init`이 깔게 하라는 기존 경고가 남아 있다

#### Scenario: README가 5종을 말한다

- **WHEN** `README.md`의 제품 설명과 "설치 확인" 절을 읽는다
- **THEN** `agent-model-tier`가 둘 다에 들어 있다
- **AND** `orchestra`도 함께 들어 있다
