## REMOVED Requirements

### Requirement: 제품 5종을 깔아야 한다

**Reason**: 에이전트가 frontmatter `skills:`로 주입받는 `sdd-rules`·`sdd-sync` 스킬이 더해져
제품이 7종이 되고, 설치 확인에서 openspec 공식 스킬 6개 존재 확인이 빠진다.
**Migration**: 아래 ADDED 요구사항 "제품 7종을 깔아야 한다"가 복사 대상·설치 확인을 이어받는다.

## ADDED Requirements

### Requirement: 제품 7종을 깔아야 한다

`install.sh`가 대상 프로젝트에 넣는 제품은 **7종**이어야 한다(SHALL):
`.claude/agents/*.md` 8개, `.claude/skills/orchestra/`,
`.claude/skills/agent-model-tier/`, `.claude/skills/sdd-rules/`, `.claude/skills/sdd-sync/`,
`.claude/settings.json`, 그리고 `CLAUDE.md`의 조각.

`.claude/skills/sdd-rules/`와 `.claude/skills/sdd-sync/`는 이번에 새로 더해지는 것이다.
에이전트가 frontmatter `skills:`로 이 둘을 주입받으므로, 빠지면 설치본의 에이전트가 공용
규칙과 sync 절차를 받지 못한다.

설치 확인 절차도 7종에 맞아야 한다(MUST): 에이전트 파일 개수 확인,
`orchestra`·`agent-model-tier`·`sdd-rules`·`sdd-sync` 네 스킬의 존재 확인.
openspec 공식 스킬 6개(`.claude/skills/openspec-*`)의 존재 확인은 설치 확인의 필수 항목에서
빠져야 한다(SHALL) — 파이프라인이 더 이상 그 문서에 기대지 않으므로, 없다고 경고하면 없는
문제를 있는 것처럼 알리게 된다.

#### Scenario: 복사 대상 목록

- **WHEN** `install.sh`의 복사 부분을 읽는다
- **THEN** `.claude/agents/`의 `.md` 파일들, `.claude/skills/orchestra`,
  `.claude/skills/agent-model-tier`, `.claude/skills/sdd-rules`, `.claude/skills/sdd-sync`,
  `.claude/settings.json`이 모두 대상으로 적혀 있다

#### Scenario: 공용 스킬이 실제로 복사된다

- **WHEN** 빈 임시 프로젝트에서 실제로 설치를 돌린다
- **THEN** `.claude/skills/sdd-rules/SKILL.md`와 `.claude/skills/sdd-sync/SKILL.md`가 그 프로젝트에 생긴다
- **AND** 내용이 이 저장소의 원본과 같다

#### Scenario: 마른 실행이 공용 스킬을 복사 대상으로 보여준다

- **WHEN** 임시 프로젝트에서 `bash install.sh --dry-run`을 돌린다
- **THEN** 출력에 `sdd-rules`와 `sdd-sync`가 복사 예정 대상으로 나온다

#### Scenario: 설치 확인이 7종을 본다

- **WHEN** 설치가 끝난 뒤 스크립트가 내는 확인 부분을 읽는다
- **THEN** 에이전트 개수(8이어야 한다)가 나온다
- **AND** `orchestra`, `agent-model-tier`, `sdd-rules`, `sdd-sync` 스킬이 깔렸는지 확인한 결과가 나온다
- **AND** openspec 공식 스킬 6개가 없다는 이유로 경고하지 않는다

#### Scenario: 임시 프로젝트에 8개 에이전트가 실제로 깔린다

- **WHEN** `mktemp -d`로 만든 빈 임시 프로젝트에서 `bash install.sh`를 실제로 돌린다
  (이 저장소나 `~/work-space/`가 아닌 임시 디렉터리에서)
- **THEN** `.claude/agents/*.md`가 8개 생기고, 그 안에 `code-explorer.md`가 있다
- **AND** 설치 확인 절에 "에이전트: 8개 (8이어야 한다)"가 출력된다

## MODIFIED Requirements

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

이 요구사항은 `install.sh`의 **복사 규칙을 바꾸지 않는다.** 복사 대상 목록(제품 7종),
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

- **WHEN** `install.sh`의 복사 대상 목록과 복사 방식을 읽는다
- **THEN** `.claude/agents/`의 `.md` 파일들, `.claude/skills/orchestra`,
  `.claude/skills/agent-model-tier`, `.claude/skills/sdd-rules`, `.claude/skills/sdd-sync`,
  `.claude/settings.json`이 대상이다
- **AND** 이미 있는 파일을 건너뛰는 규칙과 `CLAUDE.md` 조각을 마커 구획에서 뽑는 부분이 바뀌지 않았다

### Requirement: 설치 안내는 README 한 곳에만 있어야 한다

같은 설치 절차가 두 곳에 서술되어서는 안 된다(MUST NOT). `README.md`만 읽고 설치할 수
있어야 하며(SHALL), 최소한 다음 흐름이 적혀 있어야 한다(MUST):
이 저장소를 복제한다 → 대상 프로젝트로 이동한다 → `bash install.sh`를 돌린다 →
`CLAUDE.md`가 합쳐졌는지 확인한다 → Claude Code를 새 세션으로 다시 연다.

`README.md`의 제품 설명과 설치 확인 절차는 **제품 7종**과 맞아야 한다(MUST).
`sdd-rules`·`sdd-sync`가 빠져 있으면 손으로 설치하는 사용자가 그 둘을 빠뜨려 에이전트가
공용 규칙을 못 받는다. 이미 설치한 프로젝트를 위한 안내도 있어야 한다(SHALL): 두 스킬을
새로 넣고, **에이전트 파일을 새 판으로 바꿔야 한다**(새 판과 비교해 옮긴다). `install.sh`는 이미
있는 파일을 덮어쓰지 않으므로 다시 돌려도 에이전트 파일은 `[있음, 건너뜀]`으로 옛 판이 남고,
옛 판에는 `skills: [sdd-rules]` 주입 줄이 없다.

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

#### Scenario: README가 공용 스킬 두 개도 말한다

- **WHEN** `README.md`의 제품 설명(손으로 설치하는 복사 명령 포함)과 "설치 확인" 절을 읽는다
- **THEN** `sdd-rules`와 `sdd-sync`가 둘 다에 들어 있다
- **AND** 설치 확인이 openspec 공식 스킬 6개의 존재를 필수로 요구하지 않는다

#### Scenario: 이미 설치한 프로젝트를 위한 안내

- **WHEN** `README.md`에서 이미 설치한 프로젝트에 관한 안내를 찾는다
- **THEN** `sdd-rules`·`sdd-sync` 두 스킬을 새로 넣어야 한다는 안내가 있다
- **AND** 에이전트 파일을 새 판으로 바꿔야 한다(새 판과 비교해 옮긴다)는 안내가 있다
- **AND** `install.sh`를 다시 돌리는 것만으로는 이미 있는 에이전트 파일이 바뀌지 않는다는 것을 알 수 있다
