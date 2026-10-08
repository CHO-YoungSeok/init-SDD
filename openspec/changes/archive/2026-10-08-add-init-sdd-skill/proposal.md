## Why

지금 `install.sh`는 에이전트(`.claude/agents/*.md`)와 지휘 스킬(`orchestra`,
`agent-model-tier`)을 대상 프로젝트 안으로 **복사**해 넣는다. 복사된 파일은 대상 프로젝트의
공유 git 저장소에 커밋되기 쉬운 위치에 놓인다. 그런데 이 파일들은 "사람마다 agentic coding
사용법이 다르다"는 성격을 가진 **개인 설정**이다. 공유 저장소에 커밋되면 프로젝트에 참여하는
모든 사람이 같은 에이전트 구성을 강제로 쓰게 된다.

사용자는 이걸 풀기 위해 개인 agentic 설정을 **별도의 개인 git 저장소**(프로젝트별로 나뉜
디렉터리 구조)에 두고, 공유 프로젝트의 `.claude/` 안에서는 그 개인 저장소를 **심볼릭 링크**로
가리키는 방식을 쓰기로 정했다. `CLAUDE.md`처럼 공유 저장소가 이미 추적 중인 파일은 링크로
바꿀 수 없으니, "SDD 조각을 로컬에서만 끝에 덧붙이고 그 변경을 공유 저장소 git에는 넣지
않는" 별도 절차가 필요하다.

이 구조를 세워 주는 스킬(`init-sdd`)이 아직 없다. 이번 change는 그 스킬을 새로 만든다.

## What Changes

- 새 스킬 `.claude/skills/init-sdd/SKILL.md`를 만든다. 이 스킬이 다루는 절차:
  - **개인 소유와 openspec CLI 소유를 구분해서 링크한다.** `.claude/` 전체를 통째로
    링크하지 않는다. `agents/`, `skills/orchestra/`, `skills/agent-model-tier/`는 개인
    저장소로 링크 대상이고, `skills/openspec-*`(6개)와 `commands/opsx/`는 openspec CLI가
    대상 프로젝트에 직접 까는 것이므로 링크 대상에서 제외한다. `settings.local.json`은
    이미 각자 로컬/gitignore 대상이라 건드리지 않는다.
  - **`CLAUDE.md`를 로컬에서만 고치는 절차를 두 갈래로 다룬다**: (a) 아직 공유 저장소 git에
    추적되지 않은 경우 `.git/info/exclude`에 추가한다. (b) 이미 추적 중인 경우
    `git update-index --skip-worktree CLAUDE.md`를 건다. 이 경우 원격에서 팀원이
    `CLAUDE.md`를 바꿔 push하면 pull이 막히거나 조용히 그 변경을 못 받으므로, 스킬 절차 안에
    **해제(`--no-skip-worktree`) → pull → 재적용(`--skip-worktree`)**의 순서를 명시한다.
  - **양방향으로 만든다.** 링크를 거는 절차뿐 아니라 되돌리는(링크를 풀어 공유 저장소를
    원래 상태로 되돌리는) 절차, 그리고 **지금 걸려 있는지 확인**하는 절차를 포함한다.
  - **심볼릭 링크가 실제로 에이전트로 인식되는지 검증하고, 결과를 스킬 문서에 남긴다.**
    새 Claude Code 세션을 띄워 에이전트/스킬이 실제로 잡히는지 확인한 결과를 기록하고,
    인식되지 않을 경우를 대비해 복사(`cp -R`)로 대체하는 경로를 스킬 절차에 포함한다.
  - **`init-sdd` 스킬 자신이 어디 있어야 하는지**는 사용자 답변에 따라 정해진다 (아래
    "사용자에게 물어야 할 것" 참고). 이 스킬 문서를 만드는 실제 파일 위치는 designer 단계
    에서 확정한다.
- **두 방식을 나란히 둔다** (사용자 결정 — `decision.md` 참고). `install.sh`는
  **복사 방식**(팀이 SDD에 합의한 경우)이고 `init-sdd`는 **링크 방식**(개인이 자기
  설정을 별도 git으로 관리하는 경우)이다. 같은 절차가 두 곳에 있는 것처럼 보이면 안
  되므로 **"어떤 때 어느 것을 쓰는지"를 한 곳(`README.md`)에 적고, 둘이 서로를
  가리키게 한다.** 이를 위해 기존 파일 두 개를 최소한으로 손댄다:
  - `README.md`: `## 설치` 맨 앞에 "먼저 고른다 — 복사 방식인가 링크 방식인가" 안내를
    더한다. 기존 방법 1·2(복사 방식)는 그대로 둔다.
  - `install.sh`: 설치가 끝난 뒤 안내에 **링크 방식도 있다는 한 줄**을 더한다. 복사
    동작 자체는 바꾸지 않는다.
  `install.sh`를 지우지도, 링크 방식으로 바꾸지도 않는다.
- 이 저장소(`init-SDD`) 자신에게 실제로 심볼릭 링크를 거는 작업(`.claude/agents/agy.md`를
  개인 저장소로 옮기는 등)은 이번 change의 범위가 아니다. 이번 change는 **스킬을 만드는 것**
  까지다. 실제로 이 저장소에 적용할지는 스킬이 만들어진 뒤 별도로 판단한다.

**BREAKING**: 없음. 새 스킬 문서를 추가할 뿐, 기존 파일의 동작을 바꾸지 않는다.

## Capabilities

### New Capabilities
- `distribution/init-sdd-skill`: 개인 agentic 설정(에이전트, 지휘 스킬, 모델 등급 스킬)을
  별도의 개인 git 저장소로 분리하고, 공유 프로젝트의 `.claude/`에서 심볼릭 링크로 연결하는
  절차에 대한 요구사항. `CLAUDE.md`처럼 이미 추적 중인 공유 파일을 로컬에서만 고치는 절차
  (미추적/추적 두 갈래), 양방향 적용/해제, 현재 연결 상태 확인, 링크 인식 여부 실측과 실패
  시 대체 경로, `.claude/` 중 개인 소유만 골라 링크하고 openspec CLI 소유는 제외하는
  경계를 포함한다.

### Modified Capabilities
- `distribution/sdd-install-script`: 요구사항 하나를 **더한다**(ADDED). 복사 방식과
  링크 방식 중 어느 것을 쓸지 고르는 안내가 `README.md` 한 곳에 있어야 하고,
  `install.sh`와 `init-sdd` 스킬이 서로를 가리켜야 한다는 요구사항이다. 기존 요구사항
  (제품 5종, 조각 원본 한 벌, 덮어쓰기 금지 등)은 **하나도 바꾸지 않는다** — 복사
  방식의 계약은 그대로다. 그 외 기존 메인 spec 10개(`agent-instructions`)와
  `distribution/agent-model-tier`는 이번 요청과 겹치지 않는다.

## Impact

- 영향 파일: 새 파일 `.claude/skills/init-sdd/SKILL.md` 1개(위치 확정 —
  사용자 결정 4), 그리고 기존 파일 **두 개를 최소 수정**한다: `README.md`(고르는 안내
  한 절 추가), `install.sh`(안내 한 줄 추가). 그 밖의 기존 파일
  (`CLAUDE.md`, `.claude/agents/*.md`, `.claude/skills/**` 기존 스킬)은 건드리지 않는다.
- 받아들일 조건 (승인 기준):
  - [ ] `init-sdd` 스킬 문서가 "개인 소유"(`agents/`, `skills/orchestra/`,
        `skills/agent-model-tier/`)와 "openspec CLI 소유"(`skills/openspec-*` 6개,
        `commands/opsx/`)를 구분해서 명시하고, 후자는 링크 대상에서 제외한다고 못박고
        있다 (`.claude/` 통째 링크 금지가 문서에 명확히 적혀 있다).
  - [ ] `CLAUDE.md`를 다루는 절차가 "미추적일 때"(`.git/info/exclude`)와 "이미
        추적 중일 때"(`git update-index --skip-worktree`)로 갈라져 있고, 후자에는
        해제 → pull → 재적용 순서가 명시돼 있다.
  - [ ] 링크 걸기와 풀기(되돌리기) 절차가 둘 다 있고, 풀었을 때 공유 저장소가 원래
        상태로 돌아온다는 것이 문서로 확인된다.
  - [ ] "지금 링크가 걸려 있는지" 확인하는 절차(또는 명령)가 스킬에 있다.
  - [ ] 심볼릭 링크가 새 Claude Code 세션에서 에이전트로 실제 인식되는지를 **임시
        프로젝트에서 실측하고, 그 결과(된다/안 된다)가 스킬 문서 또는 change 산출물에
        기록되어 있다.** 인식되지 않을 경우를 대비한 복사(`cp -R`) 대체 경로가 문서에
        있다.
  - [ ] 스킬 문서 어디에도 이 저장소의 현재 절대경로
        (`/Users/0stone_1004/orca/projects/init-SDD`)가 하드코딩되어 있지 않다 (이
        저장소가 추후 다른 경로로 옮겨질 예정이라 하드코딩하면 그때 깨진다).
  - [ ] 개인 agentic 저장소의 경로/이름을 스킬이 하드코딩하지 않고, 실행 시점에
        사용자에게 확인하거나 설정 가능한 값으로 다룬다.
  - [ ] `README.md`에 복사 방식과 링크 방식 중 **어느 것을 쓸지 고르는 안내**가 있고,
        `install.sh`의 안내와 `init-sdd` 스킬 문서가 **서로를 가리킨다** (사용자 결정 1).
  - [ ] 이번 change가 손댄 기존 파일은 `README.md`와 `install.sh` **둘뿐이다**.
        `CLAUDE.md`, `.claude/agents/*.md`, 기존 스킬 문서는 바뀌지 않았다
        (`git diff --stat`으로 확인). `install.sh`는 `bash -n` exit=0이고 복사 대상
        목록이 이전과 같다.
  - [ ] `openspec validate "add-init-sdd-skill" --strict` exit=0.
- 가정:
  - (해소됨) `install.sh`와 `init-sdd`의 관계 → **① 둘 다 둔다.** 용도를 갈라서 쓴다.
  - (해소됨) `.claude/settings.json`은 **개인 것**이며 링크 대상에 넣는다.
  - 이 저장소(`init-SDD`) 자신에게 구조를 실제로 적용하는 것은 이번 change 범위 밖이다.
  - 보류 중인 다른 change `split-repo-tracking-scope`는 다른 브랜치에 있고 이번 change와
    겹치지 않는다고 가정한다(브랜치가 달라 `openspec list`에 나타나지 않아 직접 대조는
    못 했다 — designer 단계에서 그 브랜치 내용을 다시 확인할 필요가 있을 수 있다).
- 정량 요구사항 아님(구조/문서 정리). 측정 절차 대신 위 승인 기준(문서 존재/문구 확인,
  실제 세션에서의 인식 여부 실측, `openspec validate`)으로 판정한다.
- 사용자에게 물어야 할 것 → **네 개 모두 답을 받았다. 답은 `decision.md`에 있다.**
  (아래는 원래 질문과 받은 답을 짝지어 남긴 것이다)
  1. (답: ① 둘 다 둔다 — 복사 방식/링크 방식으로 용도를 가른다)
     `install.sh`와 `init-sdd` 스킬의 관계. 셋 중 어느 쪽인가: ① 둘 다 둔다(용도가 다르다)
     ② `install.sh`를 없앤다 ③ `install.sh`를 링크 방식으로 바꾼다. 참고: 바로 앞 change
     (`make-analyzer-opt-in-and-add-install-skill`)에서 `install.sh`를 지웠다가 되살린
     이력이 있다 (그때 근거는 "스킬이 install.sh의 상위집합"이었다).
  2. (답: `~/work-space/agentic/` 를 **기본값으로 권하되 하드코딩하지 않는다.** 안에
     프로젝트별 디렉터리를 둔다. 별도 git으로 추적한다)
     개인 agentic 저장소의 경로와 이름. 프로젝트별로 어떻게 나눌지도 함께.
  3. (답: **개인 설정**이다. 링크 대상에 넣는다)
     `.claude/settings.json`은 개인 설정인가, 공유 설정인가.
  4. (답: **이 저장소**에 둔다 — `.claude/skills/init-sdd/SKILL.md`. 개인 저장소를
     만들어 주는 것이 이 스킬의 일이라 개인 저장소가 없는 상태에서도 있어야 한다)
     `init-sdd` 스킬 자신은 어디에 두는가.
