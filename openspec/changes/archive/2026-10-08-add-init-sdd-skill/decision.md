# 결정 기록

- 채택한 안: 없음 (방안 비교를 거치지 않은 경로 — analyzer 생략)
- 결정한 사람: 사용자 (오케스트라를 통해)
- 결정 날짜: 2026-09-11
- analyzer 추천안: 해당 없음 (analyzer를 부르지 않았다. `analysis.md`가 없다)

기준선은 `proposal.md`의 **받아들일 조건 9개**다. 아래는 그 위에 사용자가 직접 정한
네 가지 결정과 스무 가지 남짓의 제약이다. proposal이 "designer 이전에 답이 필요하다"고
적어 둔 질문 4개가 여기서 모두 답을 받았다.

## 채택 이유
사용자가 별도의 방안 비교를 요청하지 않았다. `analyzer`가 옵트인으로 바뀌었고 이번에는
부르지 않았다. 대신 사용자가 아래 네 가지를 직접 정해 주었다.

## 사용자가 정한 것 네 가지

### 1. `install.sh`와 `init-sdd`를 둘 다 둔다 — 용도를 갈라서
- `install.sh` = **복사 모델.** 팀이 SDD 방식에 합의한 경우. 파일을 대상 프로젝트에
  복사해 넣는다. 그 파일은 팀 저장소에 커밋될 수 있다.
- `init-sdd` = **링크 모델.** 개인이 자기 agentic 설정을 별도 git으로 관리하고,
  공유 프로젝트에서는 심볼릭 링크로 가리킨다.
- **"어떤 때 어느 것을 쓰는지"를 문서에 반드시 명시한다. 둘이 서로를 가리켜야 한다.**
  안 적으면 같은 절차가 두 곳에 있는 것처럼 보이고, 그게 이 저장소가 이미 `CLAUDE.md`
  중복으로 두 번 겪은 고장이다.
- proposal의 질문 1에 대한 답 = ① 둘 다 둔다.

### 2. 개인 agentic 저장소는 `~/work-space/agentic/`
- 별도 git으로 추적한다. 안에 프로젝트별 디렉터리를 둔다.
- **단 이 경로를 스킬에 하드코딩하지 않는다.** 기본값·권함으로 제시하고 실행 시점에
  사용자에게 확인한다 (받아들일 조건 7번).
- `~/work-space/`에는 이미 다른 프로젝트들이 있다 (AuctionBoss, docview-server 등).
  `agentic`은 그 옆에 선다.
- proposal의 질문 2에 대한 답.

### 3. `.claude/settings.json`은 개인 것이다 — 링크 대상에 넣는다
- 권한 목록은 사람마다 다르다.
- proposal의 질문 3에 대한 답. proposal은 "답이 오기 전까지 링크 대상 목록에도
  제외 목록에도 넣지 않는다"고 보류해 뒀다. 이제 **링크 대상**으로 확정한다.
- 주의: 복사 모델(`install.sh`)은 이 파일을 계속 복사한다. 두 모델이 같은 파일을
  다르게 다루는 것은 의도된 것이다 (모델이 다르니까). 메인 spec
  `distribution/sdd-install-script`의 "제품 5종" 요구사항은 그대로 둔다.

### 4. `init-sdd` 스킬은 이 저장소에 둔다 — `.claude/skills/init-sdd/SKILL.md`
- 이유: 개인 저장소를 **만들어 주는 것**이 이 스킬의 일이다. 개인 저장소가 아직
  없는 상태에서도 손에 잡혀야 한다. 개인 저장소 쪽에 두면 닭이 먼저냐 달걀이 먼저냐가 된다.
- proposal의 질문 4에 대한 답.

## 링크 대상 — 골라서 링크한다 (`.claude/` 통째 링크 금지)

| 경로 | 누구 것 | 처리 |
|---|---|---|
| `.claude/agents/` | 개인 | **링크** (디렉터리) |
| `.claude/skills/orchestra/` | 개인 | **링크** (디렉터리) |
| `.claude/skills/agent-model-tier/` | 개인 | **링크** (디렉터리) |
| `.claude/settings.json` | 개인 (결정 3) | **링크** (파일) |
| `.claude/skills/openspec-*` 6개 | openspec CLI가 대상 프로젝트에 깖 | 링크 안 함 |
| `.claude/commands/opsx/` | 같음 | 링크 안 함 |
| `.claude/settings.local.json` | 개인, 이미 gitignore | **절대 건드리지 않는다** |

`.claude/skills/` **자체는 실제 디렉터리로 남고, 그 안의 두 개만 링크**가 된다.
`.claude/`를 통째로 링크하면 openspec CLI 소유물까지 개인 저장소로 끌려간다.

## 핵심 결정 (설계에서 확정한 것 — 근거는 design.md)

- **원본·대상·개인 저장소 세 경로를 모두 실행 시점에 알아낸다.** 절대 경로를 스킬 문서에
  적지 않는다. 이 저장소는 곧 `~/work-space/dev-initSDD/init-SDD`로 옮겨진다.
- **`CLAUDE.md` 조각은 원본 저장소 `CLAUDE.md`의 마커 구획에서 뽑는다.** `install.sh:91`과
  같은 방식이고, 조각을 스킬 문서에 베껴 넣지 않는다. 뽑은 값이 비면 멈춘다
  (`install.sh:93`의 안전장치와 같은 이유).
- **추적되는 `CLAUDE.md`는 `git update-index --skip-worktree`로 다루고, 해제 → pull →
  재적용 절차를 문서에 넣는다.** `.git/info/exclude`는 추적 안 되는 파일에만 통한다.
- **대상 프로젝트에 이미 실제 `.claude/agents/`가 있으면 멈추고 보고한다.** 추적 중인
  것은 스킬이 절대 옮기지 않는다. 미추적인 것만, 사용자가 명시적으로 그러라고 할 때
  백업 이름으로 비켜 둔다. 원래 것을 잃지 않는 것이 최우선이다.
- **링크가 실제로 에이전트로 로드되는지는 사용자가 새 세션에서 확인해야 한다.**
  서브에이전트는 새 Claude Code 세션을 띄울 수 없다. 파일시스템·git 수준까지만 실측하고,
  그 한계를 정직하게 적는다. 안 되면 복사로 떨어지는 길을 문서에 둔다.
- **링크 자체가 공유 저장소 git에 새어 나가지 않도록 대상 프로젝트
  `.git/info/exclude`에 링크 경로를 적는다.** 링크는 미추적 파일이라 exclude가 통한다.
- **`allowed-tools`를 frontmatter에 넣지 않는다.** 좁게 걸면 파일을 못 쓴다
  (openspec 공식 스킬 6개에서 실측된 함정이다).
- **`install.sh`는 한 줄만 손댄다** — 링크 모델이 있다는 안내. README에 "먼저 고른다"
  절을 더한다. 그래서 `distribution/sdd-install-script`에 요구사항 하나를 **ADDED**한다.
  proposal의 "install.sh를 고치지 않는다"는 이 결정 1 때문에 갱신했다 (아래 참고).

## proposal 갱신 내역
결정 1의 "둘이 서로를 가리켜야 한다"가 proposal의 다음 두 곳과 어긋나서 proposal을 고쳤다.
- `## What Changes`의 "이번 change는 `install.sh` 자체는 고치지 않는다"
- 받아들일 조건 8번 "기존 파일을 직접 고치지 않았다"
- `## Capabilities`의 `### Modified Capabilities` "(없음)"
자세한 내용은 design.md의 Decisions와 proposal.md 본문을 봐라.
