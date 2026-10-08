## ADDED Requirements

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
