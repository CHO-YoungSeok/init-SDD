최종 판정: 통과 (라운드 2, 2026-10-09)

## 라운드 2 (재리뷰 — 커밋 전 보완 3건)

RESULT: 통과 | change=convert-to-plugin | scope=만진파일 | tests=안맡음 | blockers=0 | should_fix=0 | notes=1

판정: 통과
범위: `bin/sdd-init`, `skills/init/SKILL.md`, `skills/orchestra/SKILL.md`, `install.sh` (2라운드 재작업분)

### OpenSpec 검증
```
$ ./bin/sdd-openspec validate convert-to-plugin --strict; echo "exit=$?"
Change 'convert-to-plugin' is valid
exit=0
```

### 이전 반려 내용 대조
1. [라운드 1 고쳐야 함 1] `/sdd:init` 내려받기 안내 순서 → **고쳐짐.**
   - `bin/sdd-init:45` — `setup`이 `sdd-openspec init`(:47)보다 먼저 "참고: sdd-openspec 은 첫 실행 때 npm 레지스트리에서 @fission-ai/openspec@1.14.1 을 받는다." 출력. 버전은 `wrapper_version`(:179-181)이 `bin/sdd-openspec`의 `OPENSPEC_VERSION`에서 읽는다(한 곳 원칙 유지).
   - `skills/init/SKILL.md:19` — 1단계 명령 앞에 사용자에게 먼저 알리라는 줄.
   - `permissions` 안내 줄(`bin/sdd-init:185`)은 그대로 — spec `sdd-init-command` "권한 목록은 래퍼의 첫 실행 내려받기를 알려야 한다" 계속 충족.
   - 실측(scratchpad mktemp, 래퍼를 스텁으로 바꾼 가짜 플러그인 루트, 네트워크 없음): 1회차 출력 순서 `참고: …1.14.1 을 받는다` → `openspec 초기화: …` → 스텁 init → `훅 표식: 만듦`, exit=0. 2회차(config 있음) 안내 줄 없이 `건너뜀`/`표식 있음`, exit=0. `permissions` 출력에 안내 줄 있음.
2. [라운드 1 regression 조용한 회귀 1] orchestra 메인 세션 명령 PATH 대비 → **고쳐짐.** `skills/orchestra/SKILL.md:52` 한 줄 추가(상태·목록 확인을 `openspec`으로 바꿔 친다). D6 grep 재실행 rc=1·0건, `sdd-sdd-openspec` 0건. 이 줄은 메인 세션용이라 spec `shared-pipeline-rules`의 "에이전트 파일에 사본 금지"·`openspec-cli-wrapper`의 "대체 규칙은 sdd-rules 쓰는 스킬 절" 과 부딪히지 않는다.
3. [라운드 1 regression 참고 3] 옛 `agent-model-tier` 잔존 안내 → **고쳐짐.** `install.sh:151-154` 결과 절에서 디렉터리가 있을 때만 "지워도 된다 (이 스크립트는 지우지 않는다)" 출력. 실측: 디렉터리를 둔 임시 프로젝트에서 `--dry-run` exit=0, 안내 1줄, 디렉터리 그대로 남음. 없는 프로젝트에서는 0줄.

### 새로 생긴 모순
없음. `.md` 점검: 리치 마크다운 토큰 0, 코드펜스 짝수(orchestra 34, init 12), frontmatter 그대로. `lite-default-path`(판정 절·파이프라인 그림)와 무관한 줄이다.

### 되돌릴 체크 항목
없음

### 발견 사항
1. [참고] `bin/sdd-init:42-45` — `openspec/config.yaml`이 이미 있으면 `setup`은 안내 줄을 내지 않는다. 그 경우 첫 내려받기는 2단계 `sdd-openspec context`에서 일어날 수 있지만, `skills/init/SKILL.md:19`가 1단계 전에 무조건 알리게 하므로 사용자에게는 이미 안내된 상태다. 고칠 필요 없다.

### 이번 change 것인지 확인 필요한 변경
라운드 1과 같음(빈 `.agents/skills/`). 추가 없음.

### 다음 단계
통과 — finalizer에게 넘긴다. 라운드 1 "다음 단계"의 블록·은퇴 승인 줄·대조 기대값 그대로.

## 라운드 1 (지난 판정: 통과)

RESULT: 통과 | change=convert-to-plugin | scope=만진파일 | tests=안맡음 | blockers=0 | should_fix=1 | notes=7

## 리뷰: convert-to-plugin
판정: 통과
판정 기록: openspec/changes/convert-to-plugin/review.md
기준으로 삼은 채택안: 상위 change `plugin-lite-sdd-distribution` decision.md 1안(플러그인 전면 전환). 이 change에는 decision.md가 없다(analyzer 생략 경로) — proposal 받아들일 조건 + specs 델타 11개 + design D1~D15 + tasks 머리말을 기준으로 삼았다.

리뷰 환경: PATH에 `sdd-openspec` 없음 → `./bin/sdd-openspec`(1.14.1), PATH `openspec` 1.12.0. 이 세션은 파일 이동 뒤라 reviewer 정의를 `agents/reviewer.md`에서 Read로 읽어 따랐다.

### OpenSpec 검증
```
$ ./bin/sdd-openspec validate convert-to-plugin --strict; echo "exit=$?"
Change 'convert-to-plugin' is valid
exit=0
$ openspec validate convert-to-plugin --strict; echo "exit=$?"     (1.12.0)
Change 'convert-to-plugin' is valid
exit=0
```
`./bin/sdd-openspec status --change convert-to-plugin --json` exit=0, 산출물 4개 모두 `done`, `isComplete: true`.
산출물에 `context`/`rules`/`<project_context>` 블록 복사 없음(grep 0건). `.openspec.yaml`에 `retire_capabilities: true` 있음.

### 요구사항 충족

**distribution/sdd-plugin (ADDED 11)**
- 매니페스트 name `sdd`, version `0.1.0`, author.name `석`, email 없음 → 충족 (`.claude-plugin/plugin.json:2-5`)
- 마켓플레이스 `sdd-marketplace`, 최상위 description, plugins[0] `sdd` source `./` → 충족 (`.claude-plugin/marketplace.json:2-7`)
- validate 두 명령 `--strict` 통과 → 충족 (verification.md:106, 복구 뒤 재측정 270-271. 루트 `CLAUDE.md` 없음 확인)
- 표준 레이아웃 / 옛 위치 비었음 → 충족. `ls agents/*.md` 8, `skills/` = init·orchestra·sdd-rules·sdd-sync, `git ls-files .claude` = `.claude/CLAUDE.md`·`settings.json`·`skills/init-sdd/SKILL.md` 세 줄, 모델 등급 스킬 없음. init 이벤트 목록 verification.md:125-127
- `sdd:` 접두사 + 대비 규칙 두 곳 한 번씩 → 충족 (`skills/orchestra/SKILL.md:29-32`, `skills/sdd-rules/SKILL.md:53-55`; orchestra `subagent_type` 18줄 모두 `sdd:`, 비-`sdd:` 0줄). 기존 설치본 동작 verification.md:179-186
- `skills:` 접두사 없음 → 충족 (`agents/*.md:6` 7줄, finalizer `sdd-sync` 포함)
- `--plugin-dir` 개발 → 충족 (`README.md:312`, `.claude/CLAUDE.md:3`, 표식 구획 `.claude/CLAUDE.md:14,36` 각 1회, 구획 안 diff 0)
- 지침 파일 `.claude/CLAUDE.md` → 충족 (`test -e CLAUDE.md` → 1 직접 확인, 새 세션 인용 verification.md:255-268)
- README 설치 다섯 가지 → 충족 (`README.md:41,63-64,71-72,102-109,312`)
- README 업데이트·팀 배포·Windows → 충족 (`README.md:78-86,88-98,100`). 팀 배포 문구는 아래 참고 2
- eval 결과 무시 + 인식 확인 기록 → 충족 (`.gitignore:16`, verification.md:188-202). 아래 참고 4

**distribution/openspec-cli-wrapper (ADDED 3)**
- 고정 버전·인자·종료코드 그대로·버전 한 곳·실행 권한 → 충족 (`bin/sdd-openspec:3-4`, `exec`. 직접 `validate` exit 0 확인, 9.2 실패 rc≠0 tasks 2.2)
- 지시문이 래퍼 사용, D6 grep 0건 → 충족 (직접 돌림: rc=1, 출력 없음, `sdd-sdd-openspec` 0). 에이전트 diff는 53줄 전부 `openspec`→`sdd-openspec` 치환뿐임을 줄 단위로 대조
- 대체 규칙은 sdd-rules "쓰는 스킬" 절에만, 에이전트에 사본 없음 → 충족 (`skills/sdd-rules/SKILL.md:19-21`, `agents/*.md`에 `not found`·`1.14` 0건)
- 권한 `Bash(sdd-openspec:*)` + 기존 항목 유지 → 충족 (`.claude/settings.json:5`, diff +1줄뿐)

**distribution/session-start-hook (ADDED 4)** — 직접 재실행으로 확인
- 표식 있을 때만 주입, 어느 경우든 exit 0 → 충족 (`hooks/session-start.sh:7,10,49`). 빈 dir / `openspec/`만 → exit=0, 0바이트. 표식 있음 → 817바이트. `cd` 후 `CLAUDE_PROJECT_DIR` 없이 실행해도 같음
- README 끄는 법 → 충족 (`README.md:74-76`)
- 지휘 규칙 6줄(≤8), 오케스트레이터·`sdd:`·`sdd:orchestra` → 충족 (`hooks/session-start.sh:14-19`)
- 점검: npx 실행 없음(`command -v`만, :25), 권한 점검(:30), archive 제외 완료 change(:35-43; `wip`(미완료)와 `archive/…old-one` 제외 직접 확인), 문제 없을 때 "이상 없음"(:45-47) → 충족

**distribution/sdd-init-command (ADDED 8)**
- `skills/init/SKILL.md` frontmatter `name`·`description`만, `allowed-tools` 없음, 부르는 말 → 충족 (`skills/init/SKILL.md:1-4`)
- 최소 init(`--tools none`), config 있으면 건너뜀 → 충족 (`bin/sdd-init:42-54`; 실측 verification.md:149)
- 표식 생성·멱등 → 충족 (`bin/sdd-init:56-62`; verification.md:150)
- context 초안 / 확인 뒤 기록 / 기존 `context:` 보호(rc=2) → 충족 (`bin/sdd-init:77-162`, 스킬 `skills/init/SKILL.md:37,43-44`). detect 직접 실행: npm test / npm run build / `main (로컬 main 브랜치)`
- 기본 브랜치 감지 순서 → 충족 (`bin/sdd-init:119-132`)
- 권한: 원본 한 곳, `settings.local.json`에만, 빠진 것만, 기존 키 유지, 깨진 JSON이면 안 씀, `.gitignore` 안 고침 → 충족 (`bin/sdd-init:165-230`). 직접 확인: 깨진 JSON → exit=1·파일 그대로, 2회 실행 11개·중복 0, 커밋된 `.claude/settings.json` diff 0, status 차이는 무시된 `settings.local.json`뿐
- 내려받기 안내 줄 → 충족 (`bin/sdd-init:184`). 순서는 아래 고쳐야 함 1
- 비대화 단계 종료코드 확인 + 마켓플레이스 설치 끝까지 → 충족 (verification.md:145-157, 164)

**distribution/sdd-install-script (RENAMED 1, MODIFIED 5, ADDED 1)** — 직접 재실행으로 확인
- 세 갈래 안내, 플러그인 먼저, 방법 1·2 유지 → 충족 (`README.md:36-56,111`)
- 제품 6종, 원본 플러그인 레이아웃, 대상 위치 그대로, 모델 등급 스킬 없음 → 충족 (`install.sh:76-82,127`)
- 조각 원본 `.claude/CLAUDE.md` 한 벌 → 충족 (`install.sh:91,94-97`; `grep -rl '^순서:'` → `./.claude/CLAUDE.md`만)
- 건너뜀 안내 원본 경로가 실제 경로 → 충족 (`install.sh:62-68,149`). 빈 임시 프로젝트에 2회 설치: 두 번째 `(원본: …)` 12개 모두 `test -e` 통과, worker 원본 `<repo>/agents/worker.md`
- 플러그인 이전 안내(시작·다음 할 일, 두 이름) → 충족 (`install.sh:21,163-164`; dry-run exit=0, 복사 예정 12)
- README 손 설치·설치 확인 3개·남은 모델 등급 스킬 지워도 됨 → 충족 (`README.md:141-148,191,200-201`)

**distribution/init-sdd-skill (MODIFIED 6, ADDED 1)**
- 위치 그대로·플러그인 밖, description에서 모델 등급 스킬 제거 → 충족 (`.claude/skills/init-sdd/SKILL.md:3`)
- 링크 다섯 개, 초기 이관 원본 `agents/`·`skills/` → 충족 (diff 전체 확인, `여섯` 0건)
- 원본 탐색 `install.sh` + `.claude/CLAUDE.md`, 조각 원본 `$SRC/.claude/CLAUDE.md`, 대상 `$대상/CLAUDE.md` 그대로 → 충족 (SKILL.md:48,58,238-239)
- 목록 밖 옛 링크 찾기·풀기(`-L`이고 `$P` 아래만 `rm`) → 충족 (SKILL.md 풀기·상태 보기 추가 블록)
- 이전 안내 앞부분, `/plugin install` 절차 재서술 없음 → 충족 (SKILL.md:10-13)
- 실제 걸기·상태·풀기 1회 → verification.md:172-173

**agent-instructions/code-explorer-invocation, code-explorer-role, shared-pipeline-rules**
- 7개 `tools:`에 `Agent`, `Agent(` 꼴 없음 → 충족 (`agents/*.md:5`)
- code-explorer `model: haiku` 한 줄, `skills:` 없음 → 충족 (`agents/code-explorer.md:4`)
- README code-explorer 보조 에이전트, 모델 등급 스킬 언급 없음 → 충족 (`README.md:275-279`)
- sdd-rules 절 7개, `not found`는 "code-explorer 부르기"에만 1줄, `1.14.1`은 "쓰는 스킬"에만 → 충족 (awk 직접 확인: 19행·53행)
- 새 프로세스 주입 7/7 + code-explorer NONE → 충족 (verification.md:129-143)

**process/field-validation-record (MODIFIED 2)**
- `evals/README.md` "플러그인 루트에서 실행", 실행 불가 서술 0, `--no-publish` → 충족 (`evals/README.md:7-10,42-45`)
- `evals/results/` 추적 안 됨·무시 → 충족 (`git check-ignore` 0, `git ls-files` 0)

**distribution/agent-model-tier (REMOVED 7, 은퇴)**
- 스킬 파일 삭제 → 충족 (`git status`: `D  .claude/skills/agent-model-tier/SKILL.md`). 메인 spec 은퇴는 finalizer sync 몫(design 블록 2, 은퇴 승인 줄 필요)

**받아들일 조건(proposal)** — 리뷰 시점에 확인 가능한 것은 모두 충족. 남은 것은 finalizer 몫: 메인 spec 은퇴, `.claude/` 치환 전후 값(전 152/126 기록됨, 기대값 110회/90줄 verification.md:213), archive 뒤 `validate --all --strict`.

### 설계 준수
- D1~D4: 파일 내용이 설계 글자와 같다(plugin.json·marketplace.json·sdd-openspec·hooks.json·표식 두 줄·지휘 규칙 6줄·`sdd-init` 다섯 하위 명령·스킬 절차 5단계). `jq` 0건, JSON은 `node -e`.
- D5·D6: orchestra 18줄·대비 문단·257행 문구, sdd-rules 첫 문장·대비 두 줄·래퍼 규칙 줄 글자 그대로. 예외(`openspec init`이 까는, `Bash(openspec:*)`, `openspec` 셸 명령) 유지.
- D7: 정리 모드로 `git rm` (인덱스에 `D`). D8·D9·D10: diff가 설계 항목과 1:1. D11: `git mv` 다섯 건이 인덱스에 `R`로 잡힘. D12: 시뮬레이션만, 실제 메인 spec 무변경(`git status`에 `openspec/specs` 없음). D13·D14: verification.md. D15: 루트 `CLAUDE.md` 없음, `.claude/CLAUDE.md` 추적 대상.
- 설계와 다른 점: D13·tasks 9.11의 `timeout 600`을 macOS에서 `perl alarm`으로 대체(verification.md:190) — 측정 내용은 같다. 참고 3.

### 작업 완료 검증
체크된 50개 중 50개 실제 확인(파일·grep·diff 직접 확인, 훅·install.sh·sdd-init 비네트워크 단계는 임시 디렉터리에서 직접 재실행. 모델 호출·마켓플레이스·eval 항목(1.x, 9.2·9.3·9.5d·9.6·9.9·9.11·9.16)은 verification.md 기록과 지금 파일 상태의 정합으로 확인). 남은 `[ ]` 0개.

### 되돌릴 체크 항목
없음

### 발견 사항
1. [고쳐야 함] `skills/init/SKILL.md:17-27`, `bin/sdd-init:45-46` — `/sdd:init` 1단계 `sdd-init setup`이 곧바로 `sdd-openspec init`(= `npx -y @fission-ai/openspec@1.14.1`)을 돌려 npm 레지스트리에서 내려받는다. 내려받기 안내는 4단계 `permissions` 출력(`bin/sdd-init:184`)에서야 나온다. spec `sdd-init-command`의 "사용자는 그 내려받기까지 포함해 권한에 동의한다"는 근거와 순서가 거꾸로다. 요구사항 글자는 지켰고(안내 줄이 있다), Claude Code가 `sdd-init setup` Bash 실행 자체에 권한 확인을 띄우므로 완전히 묵시적이지는 않다. 고치는 방법: 스킬 1단계 앞에 "첫 실행에 npm에서 openspec 1.14.1을 받는다"는 한 줄을 알리게 하거나, `setup`이 init 전에 같은 줄을 출력하게 한다. 이 change를 막지는 않는다.
2. [참고] `README.md:88-89` 팀 배포 — "팀원이 그 저장소를 신뢰할 때 플러그인 설치를 안내받는다"는 자동 설치를 주장하지 않고, 대화형 신뢰 화면의 동작으로 적었다. 과장은 아니다. 다만 실측으로 확인한 것은 "`claude -p`에서는 등록·설치되지 않는다"와 "프로젝트 `enabledPlugins: false`는 읽힌다"뿐이다(verification.md:154-156). 대화형 동작은 미확인이다. 원하면 "(대화형 세션에서. `claude -p`에서는 등록되지 않는다)"를 붙인다.
3. [참고] `design.md:449`, `tasks.md:93` — eval 명령의 `timeout 600`이 macOS에 없다(실측 exit=127). 사용자용 문서(`README.md`, `evals/README.md`)에는 `timeout`이 없어서 사용자 영향은 없다. change 산출물은 archive로 그대로 남으므로, 대체 방법이 verification.md:190에 기록돼 있다는 것으로 충분하다. 다음 eval change에서 쓰려면 이식 가능한 꼴(`perl -e 'alarm N; exec @ARGV'` 등)로 적는다.
4. [참고] 9.11 — `--max-cost-usd 0.05`를 붙였지만 CLI가 실행 한 번 뒤에 상한을 판정해 실제 비용은 0.0645달러였다. spec `sdd-plugin`의 "비용 상한 0.05달러 안에서"를 글자로는 넘었다(CLI 동작 때문). `lite-path-small-task`는 인식 여부를 모른다. 오케스트레이터 판정 (b)로 통과 처리됨(verification.md:202) — 사용자가 알도록 남긴다.
5. [참고] `README.md:5,302,340` — 소개 문단, "단계 늘리기 — `.claude/agents/`에 파일 추가", 번역 안내가 아직 복사 방식 레이아웃 기준이다. 플러그인 사용자에게는 맞지 않는다. README 전면 재작성(⑤)이 범위 밖으로 잡혀 있어 여기서는 막지 않는다.
6. [참고] `hooks/session-start.sh:30` — 권한 점검이 프로젝트의 `.claude/settings*.json`만 본다. 사용자 전역 `~/.claude/settings.json`에 `Bash(sdd-openspec:*)`를 둔 사람에게는 매 세션 "권한 없음" 줄이 잘못 나온다. spec의 점검 표가 프로젝트 두 파일로 정해 두었으므로 spec 위반은 아니다.
7. [참고] `specs/process/field-validation-record/spec.md:11` — "플러그인 전환(`convert-to-plugin`) 뒤에는 실행할 수 없다는 서술이 남아 있어서는 안 된다"는 "전환 뒤에 실행할 수 없다"로도 읽힌다. 뜻은 "'전환 전에는 실행할 수 없다'는 옛 서술이 남으면 안 된다"다. sync로 메인 spec에 들어가므로 ⑥ 검수 때 다듬을 후보로 남긴다.
8. [참고] 사고 흔적 점검 — 남은 것 없음: 루트 `CLAUDE.md` 없음(`test -e` → 1), `$대상`·`$개인` 디렉터리 없음, `.git/info/exclude`는 기본 주석 6줄뿐(`docs/` 없음), `3eb4cd1`은 어느 브랜치에도 없음(`git branch --contains` 빈 출력, reflog `HEAD@{1}`에만 남음 — 무해), 저장소 안 중첩 `.git` 없음, 무시된 파일은 `openspec-*`·`commands/`뿐. HEAD는 `3d1c42c`. finalizer에게: 인덱스에는 이동(`R`)과 삭제(`D`)만 스테이징돼 있고 내용 수정과 새 파일(`.claude-plugin/`, `bin/`, `hooks/`, `skills/init/`, `openspec/.sdd`, change 디렉터리)은 스테이징 전이다.

### 이번 change 것인지 확인 필요한 변경
- 저장소 루트의 빈 디렉터리 `.agents/skills/`(2026-10-08 21:36 생성, 이 change 시작 전). 비어 있어서 `git status`에 안 나오고 커밋되지 않는다. 이 change와 무관해 보인다 — 막지 않는다.

### 다음 단계
통과 — finalizer에게 넘긴다. design.md "finalizer 프롬프트에 글자 그대로 실을 블록"을 그대로 싣고, `은퇴 승인: agent-model-tier (사용자 결정)` 줄을 따로 싣는다(archive까지면 `archive: 해도 됨`). 대조 기대값은 verification.md의 "110회/90줄".
고쳐야 함 1은 이번 커밋 전에 고칠지(스킬 한 줄 추가, 작은 재작업) 다음 change로 넘길지 사용자에게 확인하면 좋다.
