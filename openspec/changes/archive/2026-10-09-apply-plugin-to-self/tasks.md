# Tasks

채택안: 없음(analyzer 생략 경로). 기준은 proposal의 받아들일 조건, 가정 A1~A8 전부 채택(사용자 위임). 설계는 design.md D1~D7.
핵심 결정:
- config `context:`와 메인 spec `project-context-completeness`를 함께 ③ 이후 사실로 맞춘다(델타는 designer가 이미 씀, D1·D2).
- `.claude/CLAUDE.md`는 Edit 두 번 — 구획 밖은 D3 문안으로 교체, 구획 안은 `(테스트가 있을 때, 동시)` → `(조건부, 동시)` 한 곳만. 구획 밖에 `init-SDD:begin`·`init-SDD:end` 글자를 쓰지 않는다.
- README는 **Write로 새로 쓰지 않는다.** D4 "Edit 순서" E1~E6대로 절 단위 Edit를 위에서부터 한다(메인 spec `analyzer-option-generation` "지침 문서 수정은 파일을 손상시키지 않아야 한다", A6). 옮긴 절은 이동 대조 M1~M5 `diff`, 계약은 키워드 K1~K26과 금지 키워드 표로 확인한다.
- 이 change가 고치는 파일(README, `.claude/CLAUDE.md`, `openspec/config.yaml`, 이 tasks.md 체크 포함)은 전부 Edit 부분 수정만 한다. 전체 Write 재작성·`sed -i`·스크립트로 파일 통째 다시 쓰기는 금지다.

진행: 묶음 1(정리 모드 worker)·2·3·4는 파일이 겹치지 않아 동시에 돌려도 된다. 묶음 5는 1~4가 모두 끝난 뒤 한 번. 묶음 4(4.1~4.9)는 같은 파일이라 worker 한 명이 순서대로 한다.
**tasks.md 체크:** 병렬 worker가 이 파일의 `- [ ]`를 동시에 고친다. 자기 항목 줄만 Edit로 `- [x]`로 바꾸고, Edit가 실패하면(파일이 그새 바뀜) 다시 Read한 뒤 재시도한다. Write로 덮지 않는다.
모든 명령은 저장소 루트 `/Users/0stone_1004/work-space/init-SDD`에서 돌리고 종료코드로 판정한다(`; echo "exit=$?"`, 파이프로 종료코드를 가리지 않는다).
이 환경의 `grep`은 ugrep 래퍼 함수라 `grep -r`가 경로 앞 `./`를 붙이지 않는다. **경로 출력을 기대값과 비교하는 grep은 `command grep`으로** 돌린다. 한글 문자열을 `==`로 비교하는 `awk`에는 `LC_ALL=C`를 붙인다(안 붙이면 `## 설치`와 `## 커스터마이즈`가 같다고 나온다, 실측).
openspec은 `./bin/sdd-openspec`(1.14.1)을 쓴다. 이 change에서 고치지 않는 파일: `install.sh`, `.claude/skills/init-sdd/`, `.claude/settings.json`, `.gitignore`, `agents/`, `skills/`, `bin/`, `hooks/`, `.claude-plugin/`.

## 1. 정리 — 무시된 openspec 스캐폴드 삭제 (정리 모드 worker 전용)

- [x] 1.1 아래 7개 경로 각각에 대해 먼저 `git ls-files <경로> | wc -l` → `0`이고 그 안 파일 하나로 `git check-ignore -q <파일>; echo $?` → `0`인지 확인한다. 둘 다 맞는 경로만 `rm -r <경로>`로 지운다. 하나라도 어긋나면 그 경로는 지우지 않고 보고한다. 경로(글자 그대로, 이 7개 밖은 지우지 않는다):
  - `.claude/skills/openspec-apply-change`
  - `.claude/skills/openspec-archive-change`
  - `.claude/skills/openspec-explore`
  - `.claude/skills/openspec-propose`
  - `.claude/skills/openspec-sync-specs`
  - `.claude/skills/openspec-update-change`
  - `.claude/commands`
  확인: `ls -d .claude/skills/openspec-* .claude/commands 2>/dev/null | wc -l` → `0`
- [x] 1.2 남아야 할 것이 남았는지 확인한다: `git status --short`에 삭제 때문에 생긴 줄이 없다 / `git ls-files .claude` 출력이 `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/skills/init-sdd/SKILL.md` 세 줄 그대로 / `grep -cF '.claude/skills/openspec-*/' .gitignore` → 1, `grep -cF '.claude/commands/opsx/' .gitignore` → 1 / `test -f install.sh && test -f .claude/skills/init-sdd/SKILL.md && test -d .agents/skills/claude-handoff && test -f docs/field-validation.md; echo $?` → 0

## 2. `openspec/config.yaml` context 갱신

- [x] 2.1 `openspec/config.yaml`의 0칸 `context: |` 줄부터 `# Per-artifact rules (optional)` 앞 빈 줄 직전까지를 design.md D2의 yaml 블록(글자·들여쓰기 그대로)으로 Edit 한 번에 바꾼다. 맨 위 예시 주석(`#   context: |` 등)과 아래 주석은 건드리지 않는다. 확인: `git diff --stat openspec/config.yaml`이 이 파일 하나, `grep -c '^context: |' openspec/config.yaml` → 1, `grep -c '\.claude/agents' openspec/config.yaml` → 0
- [x] 2.2 파싱과 전달을 확인한다(D2 "확인 방법"): `./bin/sdd-openspec context > <scratch>/ctx.out 2>&1; echo "exit=$?"` → 0이고 `grep -c 'Warning' <scratch>/ctx.out` → 0 / `./bin/sdd-openspec instructions proposal --change apply-plugin-to-self --json > <scratch>/ins.json; echo "exit=$?"` → 0이고 그 JSON의 `context` 값에 `agents/`, `skills/`, `claude plugin validate`, `bash -n`, `한국어`, `쉬운 말`, `Edit 부분 수정`이 모두 있고 `.claude/agents/*.md`, `실행 코드가 없는`이 없다(python3으로 키별 True/False 출력을 보고서에 그대로 붙인다). `<scratch>`는 묶음 5 머리말의 scratchpad 아래 `mktemp -d`
- [x] 2.3 델타가 새 context와 맞는지 확인한다: `./bin/sdd-openspec validate apply-plugin-to-self --strict; echo "exit=$?"` → 0, `openspec validate apply-plugin-to-self --strict; echo "exit=$?"`(PATH 1.12.0) → 0. 델타 파일은 고치지 않는다(어긋나면 멈추고 보고 — designer 몫)

## 3. `.claude/CLAUDE.md` 재작성

- [x] 3.1 Edit (a): 1행 `# 이 저장소를 고칠 때 (개발자 안내)`부터 템플릿 안내 주석 끝(`install.sh 를 쓰면 알아서 덧붙인다. -->`)과 그 뒤 빈 줄까지를 design.md D3 "(a) 구획 밖 새 문안"의 안쪽 내용으로 바꾼다(템플릿 안내 주석은 없앤다). 새 문안 끝 빈 줄 다음 줄이 구획 시작 표식 줄이어야 한다. 확인: `grep -c 'init-SDD:begin' .claude/CLAUDE.md` → 1, `grep -c 'init-SDD:end' .claude/CLAUDE.md` → 1, `grep -c '템플릿 안내' .claude/CLAUDE.md` → 0
- [x] 3.2 Edit (b): 구획 안 `` `regression-verifier`(테스트가 있을 때, 동시) ``를 `` `regression-verifier`(조건부, 동시) ``로 바꾼다. 구획 안 다른 글자(뒤 공백 포함)는 그대로다. 확인: 구획 안 바뀐 줄이 이 한 줄뿐이다. 수정 전 구획은 `git show HEAD:.claude/CLAUDE.md | sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p'`, 수정 후 구획은 `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' .claude/CLAUDE.md`로 뽑아 `diff` → 차이가 `regression-verifier` 줄 하나(`<` 1줄, `>` 1줄)뿐
- [x] 3.3 받아들일 조건을 확인한다: `test -e CLAUDE.md; echo $?` → 1, `test -f .claude/CLAUDE.md; echo $?` → 0 / 구획 밖에서 각각 `grep -c` ≥ 1: `claude --plugin-dir .`, `SDD로 개발`, `claude plugin validate . --strict`, `claude plugin validate .claude-plugin/plugin.json --strict`, `sdd-openspec validate`, `bash -n`, `커밋은 작업 단위로 나눈다`, `` `agents/` ``, `` `skills/` ``, `` `bin/` ``, `` `hooks/` ``, `` `.claude-plugin/` `` (구획 밖 판정은 `awk '/<!-- init-SDD:begin -->/{exit} {print}' .claude/CLAUDE.md`로 뽑은 앞부분에 grep) / `grep -c '^순서:' .claude/CLAUDE.md` → 1이고 그 줄이 `` 순서: `preparer` → `worker` → `reviewer` → `finalizer` (기본 — 작은 작업) ``, 다음 줄이 `` 큰 작업이면 `preparer` → `designer` → `worker` → `reviewer` + `regression-verifier`(조건부, 동시) → `finalizer`. `` / 구획 안에 `analyzer`가 들어간 줄은 "분석·방안 비교를 요청할 때만" 줄 하나뿐 / 무결성: `grep -c 'ORCA_RICH''_MD' .claude/CLAUDE.md` → 0, `grep -c '^```' .claude/CLAUDE.md` 짝수

## 4. `README.md` 절 단위 Edit (worker 한 명이 4.1~4.9를 순서대로)

공통: `README.md`는 **Edit로만** 고친다(Write·`sed -i`·스크립트 통째 쓰기 금지). 줄 번호는 모두 HEAD 기준이라 앞 Edit로 밀린다 — `old_string`은 글자로 잡는다.
옮기는 글의 원문은 `git show HEAD:README.md | sed -n '<옛 행>p'`로 본다. 각 단계의 글자는 design.md D4 "Edit 순서" 표, "절별 내용" 표, 문안 블록을 따른다. 원격 주소는 `CHO-YoungSeok/init-SDD`.

- [x] 4.1 E1 소개·빠른 시작: 옛 5~9행(소개 본문, 3행 굵은 줄은 그대로)을 D4 "소개 문단" 문안의 본문으로 바꾸고, 바로 뒤에 빈 줄 + D4 "빠른 시작" 문안을 넣는다. 문안의 "(옛 26~30행 전제 조건 표를 그대로)" 자리에는 옛 26~30행 표 다섯 줄을 글자 그대로 넣는다
- [x] 4.2 E2 작동 방식 옮겨 넣기: 옛 `## 전제 조건` 절(옛 24~31행: 제목·빈 줄·표·뒤 빈 줄)을 `## 작동 방식` + 빈 줄 + 옛 224~298행 블록으로 Edit 한 번에 바꾼다. 옮기면서 바꾸는 것은 네 줄뿐이다: `## 쓰는 법`·`## 7개 서브에이전트`·`## 만들어지는 파일` → `###`, regression-verifier 표 행 → D4 "절별 내용" 표의 새 글자. 옛 자리(옛 224~298행)는 아직 지우지 않는다(4.5)
- [x] 4.3 E3 플러그인 하위 절: 옛 74~100행을 D4 표의 `### 훅 켜기·끄기`·`### 권한`·`### 업데이트`·`### 팀 배포`·`### Windows` 행대로 Edit한다(굵은 머리 → 제목, 훅 절 끝 한 줄, `### 권한` 절 삽입)
- [x] 4.4 E4 기존 설치 방식: 옛 102행 앞에 `### 기존 설치 방식 (폐기 예고)` + 빈 줄 + 머리말 + 빈 줄을 넣고, 제목 여섯 개(옛 102·111·131·159·169·187행)를 `###` → `####`로 바꾼다. 방법 1 확인 줄 삽입과 `install.sh --dry-run` 글자, 방법 2 인용 블록 끝 `openspec update` 한 줄, `### 프로젝트 규칙 심기` 첫 줄을 D4 표의 글자대로 넣는다
- [x] 4.5 E5 옛 작동 방식 블록 지우기: 옛 224~298행(`## 쓰는 법`부터 `## 커스터마이즈` 앞 빈 줄까지)을 Edit로 지운다. 4.2에서 옮긴 새 자리(`### 쓰는 법`…)와 겹쳐 "여러 곳과 맞는다"가 나오면 `old_string`을 `\n## 쓰는 법\n`처럼 앞 줄바꿈과 `##` 두 개로 시작해 유일하게 잡는다. 확인: `grep -c '^## 쓰는 법$' README.md` → 0, `grep -c '^### 쓰는 법$' README.md` → 1, `grep -c '^### 7개 서브에이전트$' README.md` → 1
- [x] 4.6 E6 아래쪽: (1) `## 커스터마이즈` 본문(옛 301~305행)을 D4 "커스터마이즈" 문안의 본문으로 바꾼다 (2) `## 개발 (이 저장소를 고칠 때)` 절(옛 307~317행)을 지운다 (3) `## 알아 둘 것`의 다섯 곳을 D4 "알아 둘 것에서 바꿀 것" 1~5대로 Edit한다(옛 344~347행 삭제, `grep generatedBy` 줄 없는 버전 확인 블록) (4) 파일 끝(버전 확인 블록 마지막 줄 뒤)에 빈 줄 + 옛 307~316행 `## 개발` 절 글자 그대로 + ``검증 명령과 커밋 규칙은 `.claude/CLAUDE.md`에 있다.`` 한 줄을 붙인다. 파일은 줄바꿈 하나로 끝난다
- [x] 4.7 구조를 확인한다(결과를 보고서에 그대로 붙인다): `grep -n '^## \|^### \|^#### ' README.md` 출력이 D4 "목차"와 순서·글자가 같다 / `## 빠른 시작` 줄 번호 < `## 설치` 줄 번호 / `## 설치` 다음 비지 않은 첫 줄이 `### 먼저 고른다 — 플러그인인가, 복사 방식인가, 링크 방식인가`이고 그 아래 첫 내용이 고르는 표(첫 행 플러그인·권장) / `grep -c '^## 설치$' README.md` → 1, `grep -c '^### 먼저 고른다' README.md` → 1 / 소개 문단에 `.claude/`의 에이전트를 얹는다는 서술이 없다 / D4 "이동 대조" M1~M5 `diff`를 하나씩 돌려 계획한 차이만 있다(M1 네 군데, M2 `10a11` 한 줄, M3 `rc=0`, M4 E3·E4 계획 차이만, M5 다섯 곳 + 끝 빈 줄). 계획에 없는 차이가 하나라도 있으면 그 줄을 Edit로 원문대로 되돌리고 다시 돌린다
- [x] 4.8 계약 키워드를 확인한다: design.md D4 표 K1~K26의 키워드마다 `grep -cF '<키워드>' README.md` ≥ 1을 돌려 결과를 표로 보고하고, 위치·모양 조건을 눈으로 대조한다. 받아들일 조건 목록(`/plugin marketplace add`, `/plugin install sdd@sdd-marketplace`, `/sdd:init`, `claude --plugin-dir .`, `.claude/commands/opsx/`, `.claude/skills/openspec-*`, `extraKnownMarketplaces`, `enabledPlugins`, `/plugin disable sdd`, `openspec/.sdd`, `Windows`, `install.sh --dry-run`, `init-sdd`, `sdd-rules`, `sdd-sync`, `code-explorer`, `.openspec.yaml`, `## 설치`, `이게 왜 필요한가`, `일의 크기에 따라 경로가 갈린다`, `방법 1 — install.sh`, `방법 2 — 손으로`, `설치 확인`)도 하나씩 ≥ 1
- [x] 4.9 금지 키워드를 확인한다: design.md D4 "금지 키워드" 표의 검사를 전부 돌려 기대값과 같다(`^순서:` 0, `평가 모드` 0, `agent-model-tier`(-i) 0, `grep generatedBy` 0, `switch_skill` 0, `테스트가 있을 때` 0, `이 저장소의 .\?\.claude/skills/openspec` 0, `관문이 사라졌다` 0, `grep -n '\.claude/agents' README.md`의 모든 줄이 복사·링크 방식 하위 절 또는 커스터마이즈의 "복사·링크 방식이면" 문장 안). regression-verifier 조건을 적은 곳(`grep -n 'regression-verifier' README.md`)이 세 조건을 다 적거나 orchestra를 가리킨다 / K24: `LC_ALL=C awk '$0=="### 보조 에이전트: code-explorer"{f=1} $0=="### 만들어지는 파일"{f=0} f' README.md` 출력에 `모델 등급` 0건(README 전체 금지 grep은 하지 않는다 — 옮기기·이미 설치한 프로젝트 안내엔 그 말이 필요하다) / 무결성: `grep -c 'ORCA_RICH''_MD' README.md` → 0, `grep -c '^```' README.md` 짝수

## 5. 통합 검증 (묶음 1~4가 모두 끝난 뒤, 정식 모드 worker. 쓰는 파일은 `openspec/changes/apply-plugin-to-self/verification.md` 하나)

**안전 규칙:** 이 묶음의 셸 스크립트는 변수 이름을 ASCII로만 쓰고(`d`, `src`, `rc` 같은 이름), 맨 앞에 `set -eu`를 두며, 디렉터리 이동은 반드시 `cd "$d" || exit 1` 꼴로 한다.
0이 아닌 종료코드가 기대값인 검사는 `rc=0; <명령> || rc=$?; echo "rc=$rc"` 꼴로 받아 `set -e`에 끊기지 않게 한다.
임시 디렉터리는 scratchpad `/private/tmp/claude-501/-Users-0stone-1004-work-space-init-SDD/5584cf33-ec34-4527-843b-f700b5292cd5/scratchpad` 아래 `mktemp -d`로만 만든다.
이 저장소에서는 `git reset`, `git init`, `git commit`을 돌리지 않는다(`git init`·`git commit`은 임시 프로젝트 안에서만). 시작할 때와 끝날 때 `git rev-parse HEAD`를 적고 둘이 같아야 한다.

- [x] 5.1 시작 HEAD를 `git rev-parse HEAD`로 적는다(기대 `6018683…`, 다르면 그 값을 그대로 적고 진행). `git status --short`도 함께 적는다
- [x] 5.2 묶음 1~4의 확인 명령(1.1 끝 줄, 1.2, 2.1~2.3, 3.2 끝 diff, 3.3, 4.7~4.9)을 한 번 더 돌려 결과를 verification.md에 그대로 붙인다. 하나라도 기대값과 다르면 멈추고 보고한다
- [x] 5.3 설치 조각 실측: scratchpad `mktemp -d`로 `d`를 만들고 `cd "$d" || exit 1; git init -q; git -c user.name=t -c user.email=t@t commit -q --allow-empty -m init` / `bash /Users/0stone_1004/work-space/init-SDD/install.sh --dry-run; echo "exit=$?"` → 0이고 `git status --short` 출력이 실행 전과 같다 / 실제 `bash /Users/0stone_1004/work-space/init-SDD/install.sh; echo "exit=$?"` → 0 / 결과 파일은 임시 프로젝트 밖의 **별도** scratchpad `mktemp -d`(`o`)에 둔다: `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$d/CLAUDE.md" > "$o/got.txt"`, `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' /Users/0stone_1004/work-space/init-SDD/.claude/CLAUDE.md > "$o/want.txt"`, `diff "$o/want.txt" "$o/got.txt"; echo "rc=$?"` → 0 / `grep -c 'init-SDD:begin' "$d/CLAUDE.md"` → 1 / `ls "$d/.claude/agents" | wc -l` → 8
- [x] 5.4 플러그인 검증: `claude plugin validate . --strict; echo "exit=$?"` → 0, `claude plugin validate .claude-plugin/plugin.json --strict; echo "exit=$?"` → 0 (출력에 `CLAUDE.md at the plugin root` 경고 없음)
- [x] 5.5 스크립트: `for f in install.sh bin/sdd-init bin/sdd-openspec hooks/session-start.sh; do bash -n "$f"; echo "$f rc=$?"; done` → 넷 다 0 / `CLAUDE_PROJECT_DIR="$PWD" bash hooks/session-start.sh; echo "exit=$?"` → 0이고 출력에 `[SDD 점검] 이상 없음`
- [x] 5.6 OpenSpec: `./bin/sdd-openspec validate apply-plugin-to-self --strict; echo "exit=$?"` → 0, `openspec validate apply-plugin-to-self --strict; echo "exit=$?"` → 0, `./bin/sdd-openspec status --change apply-plugin-to-self --json >/dev/null; echo "exit=$?"` → 0 / `./bin/sdd-openspec validate --all --strict > <scratch>/all.out 2>&1; echo "exit=$?"`의 `Totals:` 줄에서 failed 수가 기준선 9 이하이고 `spec/agent-instructions/project-context-completeness`가 통과(✓) 쪽이다
- [x] 5.7 지침 로드 탐침: 저장소 루트에서 `claude -p "파일 읽기 도구를 쓰지 말고, 지금 받은 프로젝트 지침에서 '검증 명령은'으로 시작하는 문장을 한 글자도 바꾸지 말고 그대로 인용하라. 없으면 NONE이라고만 답하라." --plugin-dir . --max-turns 1 --model haiku < /dev/null > <scratch>/probe.out 2>&1; echo "exit=$?"` → 0이고 `grep -c '검증 명령은 저장소 루트에서 돌리고 종료코드로 판정한다' <scratch>/probe.out` ≥ 1. 실패하면 한 번 더 돌린다. 두 번 다 실패면 원인을 가르려고 구획 안 문장으로 한 번 더 묻는다: 같은 명령에서 질문만 `'이 파일은 서브에이전트도'로 시작하는 문장`으로 바꿔 `<scratch>/probe2.out`에 받고 `grep -c '서브에이전트도 물려받아 읽는다' <scratch>/probe2.out`을 본다. ≥ 1이면 지침은 실리는데 구획 밖 새 문안이 안 들어간 것(3.1 확인), 0이면 지침 로드 자체가 안 되는 것이다. 어느 쪽이든 멈추고 세 답을 그대로 붙여 보고한다
- [x] 5.8 무결성: 이번에 고치거나 만든 `.md` 전부(`README.md`, `.claude/CLAUDE.md`, `openspec/changes/apply-plugin-to-self/` 아래 `.md`)에 대해 `grep -c 'ORCA_RICH''_MD'` → 0, `grep -c '^```'` 짝수. `command grep -rl --exclude-dir=.git --exclude-dir=openspec '^순서:' .` → `./.claude/CLAUDE.md` 한 줄뿐(래퍼 `grep`은 `./`를 빼고 찍으니 반드시 `command grep`)
- [x] 5.9 끝 HEAD를 `git rev-parse HEAD`로 적고 5.1과 같은지 본다. `git status --short`가 `M .claude/CLAUDE.md`, `M README.md`, `M openspec/config.yaml`, `?? openspec/changes/apply-plugin-to-self/` 밖의 줄을 갖지 않는다. 결과를 verification.md 끝에 붙인다

## Workflow follow-up

- finalizer가 메인 spec sync(`project-context-completeness` MODIFIED) 뒤 design.md D7 단위로 나눠 커밋한다: config+spec / `.claude/CLAUDE.md` / `README.md` / change 산출물. 정리(삭제)는 무시된 파일이라 커밋이 없다.
- archive는 사용자가 요청할 때만(`archive: 해도 됨`).
