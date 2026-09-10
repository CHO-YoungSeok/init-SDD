<!-- 이 change의 채택안과 핵심 결정 (design.md를 안 읽어도 방향을 알 수 있게 남긴다) -->
> **무엇을 만드는가**: 개인 agentic 설정을 별도 git 저장소에 두고 공유 프로젝트의
> `.claude/`에서 심볼릭 링크로 가리키게 해 주는 새 스킬 문서 하나
> (`.claude/skills/init-sdd/SKILL.md`).
>
> **핵심 결정 세 가지** (전체는 `decision.md`와 `design.md`):
> 1. `install.sh`(복사 방식)와 `init-sdd`(링크 방식)를 **둘 다 둔다.** 고르는 안내의
>    본문은 `README.md` 한 곳에만 두고, `install.sh`와 스킬 문서는 **가리키는 말만** 둔다.
> 2. **원래 것을 잃지 않는 것이 최우선이다.** 링크 자리에 추적 중인 실제 파일이 있으면
>    예외 없이 멈춘다. 절대 옮기지 않는다.
> 3. **경로를 하드코딩하지 않는다.** 원본·대상·개인 저장소 세 경로를 모두 실행 시점에
>    알아낸다. 개인 저장소 기본값은 `~/work-space/agentic`이지만 **권함일 뿐**이다.
>
> **이 저장소 규칙**: `.claude/skills/**/SKILL.md`는 부분 수정만 한다. `init-sdd/SKILL.md`는
> 새 파일이라 새로 써도 된다. `install.sh`와 `README.md`는 **부분 수정**만 한다.

## 1. 실측 — 문서에 적을 사실을 먼저 확인한다

이 저장소는 테스트 스위트가 없다. 문서에 쓸 사실은 임시 프로젝트에서 직접 재서 확인한다.
아래 실측은 임시 디렉터리에서만 한다 (**이 저장소나 `~/work-space/`의 실제 프로젝트에는
절대 링크를 걸지 마라** — proposal이 범위 밖으로 뺐다).

- [x] 1.1 임시 대상 프로젝트와 임시 개인 저장소를 만든다 (`git init` + 최초 커밋,
      `.claude/`에 `openspec-*` 흉내 디렉터리 몇 개). 두 경로를 적어 둔다.
      확인: 두 곳에서 `git log -1`이 종료코드 0.
- [x] 1.2 링크 네 개(`agents/`, `skills/orchestra/`, `skills/agent-model-tier/`,
      `settings.json`)를 손으로 걸고 다음을 재서 결과를 적어 둔다:
      셸 글롭 `.claude/agents/*.md`가 링크를 통과하는지, `cat`으로 내용이 읽히는지,
      `.claude/skills/`가 실제 디렉터리로 남는지.
      확인: 각 항목의 종료코드와 출력을 기록했다.
- [x] 1.3 링크를 걸기 **전**과 **후**의 `git status --porcelain`을 비교하고,
      `.git/info/exclude`에 링크 경로를 적은 뒤 다시 비교한다.
      확인: exclude를 적은 뒤 출력이 걸기 전과 같다.
- [x] 1.4 `CLAUDE.md`가 **추적 중인** 임시 프로젝트에서 조각을 끝에 붙이고
      `git update-index --skip-worktree CLAUDE.md`를 건 뒤 `git status --porcelain`을 본다.
      이어서 `--no-skip-worktree` → 조각 제거 → 상태 확인까지 한 바퀴 돌린다.
      확인: skip-worktree를 건 동안 상태가 조용하고, 되돌린 뒤 파일이 원래와 같다
      (`git diff --exit-code CLAUDE.md`가 0).
- [x] 1.5 `install.sh`의 `copy_if_absent` 판정을 링크 상대로 재확인한다:
      살아 있는 링크(`[[ -e ]]` 참 → 건너뜀), 끊긴 디렉터리 링크, 끊긴 파일 링크(부모 있음
      / 부모 없음) 네 경우의 `cp` 종료코드와 결과.
      확인: design.md `## Risks / Trade-offs` R1의 표와 일치한다. 다르면 표를 고친다.
- [x] 1.6 `install.sh`의 글롭 유출을 이 저장소에서 확인한다:
      `ls .claude/agents/*.md | wc -l`과 `git ls-files .claude/agents | wc -l`을 비교한다.
      확인: 앞이 8, 뒤가 7이다 (미추적 `agy.md` 한 개 차이). design.md R3의 근거다.
      **`agy.md`를 커밋·이동·삭제하지 마라.**
- [x] 1.7 1.1~1.6에서 만든 임시 디렉터리를 지운다.
      확인: 임시 경로가 남아 있지 않고, 이 저장소 `git status --porcelain`이 작업 시작 전과 같다.

## 2. 스킬 문서 쓰기 — `.claude/skills/init-sdd/SKILL.md`

새 파일이라 새로 써도 된다. 절대 경로(`/Users/...`)를 한 글자도 넣지 마라.

- [x] 2.1 frontmatter를 쓴다: `name: init-sdd`와 `description` 두 키만.
      `description`에는 사용자가 실제로 할 만한 말을 여러 개 넣는다 (예: "개인 설정을
      별도 저장소로 분리", "링크로 연결해줘", "연결 풀어줘", "지금 연결돼 있어?").
      형식은 `.claude/skills/orchestra/SKILL.md`와 `.claude/skills/agent-model-tier/SKILL.md`의
      frontmatter를 그대로 본다.
      확인: `allowed-tools` 키가 없고, `---`로 둘러싼 frontmatter가 온전하다.
- [x] 2.2 "이 스킬이 무엇인가 / 복사 방식과 어떻게 다른가" 절을 쓴다. 자신이 **링크 방식**
      이고 `install.sh`가 **복사 방식**임을 밝히고, **고르는 안내의 본문이 `README.md`에
      있다는 것을 가리킨다.** 절차를 여기 다시 서술하지 마라 (design.md D10).
      확인: `README.md`를 가리키는 말이 있고, 고르는 표가 이 문서에 중복돼 있지 않다.
- [x] 2.3 경로 세 개를 실행 시점에 알아내는 절을 쓴다 (design.md D2): 원본(스킬 자신의
      위치에서 위로 올라가 `install.sh`와 `CLAUDE.md`가 함께 있는 곳, 못 찾으면 묻는다),
      대상(기본값 현재 디렉터리, 확인한다), 개인 저장소(기본값 `~/work-space/agentic`를
      **권하되** 실행 시점에 확인한다).
      확인: `grep -n '/Users/' .claude/skills/init-sdd/SKILL.md`가 아무것도 못 찾는다.
- [x] 2.4 개인 저장소 준비 절을 쓴다 (design.md D6): 없으면 `git init` + 최초 커밋,
      있으면 그것을 쓴다. 프로젝트별 디렉터리 이름은 대상 폴더 이름이 기본값이고,
      `.init-sdd-target` 파일로 짝을 적어 둔다. 같은 이름일 때의 세 갈래(같다 → 다시 쓴다,
      다르다 → 멈추고 묻는다, 기록 없음 → 멈추고 확인한다)를 표로 적는다.
      확인: 세 갈래가 표에 다 있고, "덮어쓴다"는 길이 하나도 없다.
- [x] 2.5 링크 대상 표를 쓴다 (design.md D5): 링크할 네 개와 **링크하지 않는 것**
      (`openspec-*` 6개, `commands/opsx/`)과 그 이유, `.claude/` 통째 링크 금지,
      `.claude/skills/`는 실제 디렉터리로 남긴다, `settings.local.json`은 건드리지 않는다.
      확인: 표에 네 개가 있고 제외 두 종류와 이유가 함께 적혀 있다.
- [x] 2.6 "자리가 비어 있지 않을 때" 절을 쓴다 (design.md D7의 다섯 갈래 표).
      추적 중이면 **예외 없이 멈춘다**는 것과, 멈출 때 알려 줄 두 가지 선택
      (개인 저장소로 옮기고 다시 돌리기 / 복사 방식 쓰기)을 적는다. 판정에 `-e`와 `-L`을
      **함께** 보는 이유(끊긴 링크는 `-e`가 거짓이다 — 1.5 실측)도 적는다.
      확인: 다섯 갈래가 다 있고, 추적 중인 파일을 옮기는 길이 하나도 없다.
- [x] 2.7 `CLAUDE.md` 절을 쓴다 (design.md D3, D4): 추적 여부 판정 명령,
      갈래 두 개(`.git/info/exclude` / `skip-worktree`)와 각각의 되돌리는 법,
      `.gitignore`는 고치지 않는다, 조각을 원본 마커 구획에서 뽑는 `sed` 명령,
      **뽑은 값이 비면 멈춘다**, 대상에 넣을지 판정하는 세 갈래(마커 있음 / 마커도 옛 낱말도
      없음 / 마커는 없는데 옛 낱말 있음), `sed -i` 대신 임시 파일로 쓴다.
      확인: 조각 본문(`순서:` 줄 등)이 이 문서에 베껴져 있지 않다 —
      `grep -c '순서: ' .claude/skills/init-sdd/SKILL.md`가 0이다.
- [x] 2.8 `skip-worktree` 함정 절을 쓴다 (design.md D3): 팀원의 변경을 못 받는다는 사실과
      해제 → 조각 보관 → `git pull` → 조각 복원 → 재적용 다섯 단계를 실행할 수 있는 명령과
      함께 적는다.
      확인: 다섯 단계가 순서대로 있고 `--no-skip-worktree`가 명령으로 적혀 있다.
- [x] 2.9 `.git/info/exclude` 절을 쓴다 (design.md D8): 왜 링크에는 exclude가 통하고
      `CLAUDE.md`에는 안 통하는지, 표시(`# init-sdd:begin` ~ `# init-sdd:end`)로 둘러싸서
      풀 때 그 사이만 지운다는 것.
      확인: 사용자가 원래 적어 둔 줄을 건드리지 않는다는 말이 있다.
- [x] 2.10 "풀기" 절을 쓴다 (spec의 양방향 요구사항): 링크 네 개 제거(가리키던 개인
      저장소 내용은 그대로), `CLAUDE.md` 마커 구획 제거, `--no-skip-worktree`,
      exclude의 표시 구간 제거. 푼 뒤 `git status`가 걸기 전과 같아야 한다는 것도 적는다.
      확인: 네 가지가 모두 있고, 개인 저장소를 지우지 않는다는 말이 있다.
- [x] 2.11 "상태 보기" 절을 쓴다: 링크 네 개 각각이 링크됨(가리키는 곳)/실제 파일/없음/
      **끊긴 링크** 중 무엇인지, `CLAUDE.md` 마커 유무, `skip-worktree` 표시 유무
      (`git ls-files -v`에서 `S`로 시작하는 줄), exclude 표시 구간 유무.
      끊긴 링크가 왜 위험한지(에이전트가 하나도 안 도는데 겉으론 정상처럼 보인다)도 적는다.
      확인: 네 갈래가 구분되고 끊긴 링크를 따로 알려 주는 절차가 있다.
- [x] 2.12 마지막 절 "새 세션에서 확인하기"를 쓴다 (design.md D9): 1.2~1.4 실측에서
      **확인된 것**과 **확인되지 않은 것**(에이전트로 로드되는지)을 표로 갈라 적고,
      사용자가 새 Claude Code 세션을 열어 에이전트·스킬이 잡히는지 확인하는 방법을 적고,
      **안 잡혔을 때 복사(`cp -R`)로 떨어지는 절차**(복사된 경로도 exclude에 적는다)를 적는다.
      확인: "확인되지 않았다"는 말이 있고, 복사 대체 절차가 실행할 수 있게 적혀 있다.
- [x] 2.13 "복사 방식과 섞였을 때" 절을 쓴다 (design.md R1): 살아 있는 링크는
      `install.sh`가 건너뛴다는 것과, **끊긴 링크일 때의 위험**(install이 중간에 죽거나
      개인 저장소 자리에 파일이 간다 — 1.5 실측), 돌리기 전에 개인 저장소가 제자리인지
      확인하라는 말.
      확인: 1.5의 실측 결과와 문서의 서술이 일치한다.

## 3. 기존 두 파일에 안내를 더한다 (부분 수정만)

- [x] 3.1 `README.md`의 `## 설치` 맨 앞(`### 방법 1` 바로 위)에 "먼저 고른다 — 복사
      방식인가 링크 방식인가" 표를 더한다. 두 줄: 팀이 합의했다 → 복사 방식(`install.sh`,
      아래 방법 1·2), 개인이 별도 git으로 관리한다 → 링크 방식(`init-sdd` 스킬).
      기존 "방법 1 — install.sh"와 "방법 2 — 손으로"는 **그대로 둔다.**
      확인: `sed -n '/^## 설치/,/^### 방법 2/p' README.md`에 표와 두 방식이 다 보이고,
      기존 두 방법의 본문이 바뀌지 않았다 (`git diff README.md`가 추가 줄만 보인다).
- [x] 3.2 `install.sh`의 끝 "다음 할 일" 안내에 `say` **한 줄**을 더한다: 개인 설정을 공유
      저장소에 남기지 않으려면 링크 방식(`init-sdd` 스킬)도 있다는 안내와 `README.md`의
      고르는 절을 가리키는 말. **복사 동작은 한 줄도 바꾸지 마라.**
      확인: `bash -n install.sh` 종료코드 0이고, `bash install.sh --dry-run`을 임시
      프로젝트에서 돌리면 그 안내가 출력된다. `git diff install.sh`가 `say` 추가 줄만 보인다.

## 4. 검증

- [x] 4.1 마크다운 무결성을 눈으로 검사한다: `init-sdd/SKILL.md`의 frontmatter가 온전한지,
      코드펜스(```) 개수가 짝수인지, 표가 깨지지 않았는지.
      확인: `grep -c '^```' .claude/skills/init-sdd/SKILL.md`가 짝수다.
- [x] 4.2 받아들일 조건을 하나씩 대조한다 (`proposal.md`의 `## Impact` 아래 목록 10개).
      특히 절대 경로 없음(`grep -rn '/Users/' .claude/skills/init-sdd/`가 빈 출력),
      개인 저장소 경로가 하드코딩이 아니라 기본값으로 다뤄진 것, 손댄 기존 파일이
      `README.md`와 `install.sh` **둘뿐**인 것(`git diff --stat`).
      확인: 조건 10개 각각에 대해 어디서 충족되는지 적을 수 있다.
- [x] 4.3 `openspec validate "add-init-sdd-skill" --strict`와
      `openspec status --change "add-init-sdd-skill" --json >/dev/null`을 돌린다.
      확인: 둘 다 종료코드 0이다 (`; echo "exit=$?"`로 확인한다. 파이프를 붙이지 마라).
- [x] 4.4 이 저장소가 깨끗한지 확인한다: `git status --porcelain`에 미추적 개인 파일
      두 개(`.claude/agents/agy.md`, `.agents/scripts/`)가 **그대로 미추적으로 남아 있고**,
      새로 생긴 변경은 `.claude/skills/init-sdd/`, `README.md`, `install.sh`,
      `openspec/changes/add-init-sdd-skill/`뿐이다.
      확인: 그 밖의 변경이 하나도 없다.
