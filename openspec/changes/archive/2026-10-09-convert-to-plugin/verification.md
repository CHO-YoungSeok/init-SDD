# verification — convert-to-plugin

이 파일은 묶음 1(관문)과 묶음 9만 쓴다(design D14).

## 묶음 1 — 관문 실측 (2026-10-09, Claude Code 2.1.294)

시험 위치: 세션 scratchpad(`<SP>`로 줄여 적는다). 저장소 파일은 이 파일과 tasks.md 체크박스 말고는 건드리지 않았다.
`<SP>` = `/private/tmp/claude-501/-Users-0stone-1004-work-space-init-SDD/5584cf33-ec34-4527-843b-f700b5292cd5/scratchpad`

### 1.1 메인 spec 기준선 (치환 전)

| 명령 | 기대 | 실측 |
|---|---|---|
| `grep -o '\.claude/' -r openspec/specs \| wc -l` | 152 | **152** (같음) |
| `grep -r '\.claude/' openspec/specs \| wc -l` | 126 | **126** (같음) |

`grep -c '\.claude/' -r openspec/specs` 파일별 값 (합 126):

| 파일 | 줄 수 |
|---|---|
| openspec/specs/.gitkeep | 0 |
| agent-instructions/analyzer-option-generation/spec.md | 21 |
| agent-instructions/artifact-file-precedence-over-prompt/spec.md | 1 |
| agent-instructions/code-explorer-invocation/spec.md | 8 |
| agent-instructions/code-explorer-role/spec.md | 5 |
| agent-instructions/finalizer-archive-rationale-accuracy/spec.md | 1 |
| agent-instructions/lite-default-path/spec.md | 11 |
| agent-instructions/openspec-metadata-marker-safety/spec.md | 5 |
| agent-instructions/preparer-orphan-branch-reporting/spec.md | 1 |
| agent-instructions/project-context-completeness/spec.md | 0 |
| agent-instructions/prompt-only-handoff-defense/spec.md | 2 |
| agent-instructions/reviewer-skip-specs-fallback/spec.md | 1 |
| agent-instructions/shared-pipeline-rules/spec.md | 10 |
| agent-instructions/skill-tool-invocation-rationale/spec.md | 4 |
| agent-instructions/worker-blocked-state-disambiguation/spec.md | 1 |
| distribution/agent-model-tier/spec.md | 12 |
| distribution/init-sdd-skill/spec.md | 22 |
| distribution/sdd-install-script/spec.md | 21 |
| process/field-validation-record/spec.md | 0 |

(경로 앞의 `openspec/specs/`는 표에서 줄였다.)

### 1.2 시험 플러그인 `<SP>/plug-sdd`

만든 것:
- 지금 파일 복사: `.claude/agents/*.md` 8개 → `agents/`, `.claude/skills/{orchestra,sdd-rules,sdd-sync}` → `skills/`, `.claude/settings.json` → `.claude/settings.json`
- `.claude-plugin/plugin.json`(name `sdd`, version `0.0.1`), `.claude-plugin/marketplace.json`(name `sdd-marketplace`, `description` 있음, plugins[0].source `./`)
- `bin/sdd-probe`(자기 경로 echo), `skills/probe/SKILL.md`(본문에 `${CLAUDE_PLUGIN_ROOT}`)
- `hooks/hooks.json` + `hooks/session-start.sh` — 켜짐 조건은 proposal F7 측정 방법 그대로 "`openspec/`이 있으면 주입"(제품 조건 `openspec/.sdd`가 아니다. 이 관문은 주입 메커니즘만 잰다)
- F1~F5용 시험 에이전트·스킬: `agents/canary.md`(`skills: [canary-skill]`, 본문에 `${CLAUDE_PLUGIN_ROOT}`), `agents/canary2.md`(`skills: [sdd:canary-skill]`),
  `agents/caller.md`(`tools: Agent(canary)`), `agents/caller2.md`(`tools: Agent(sdd:canary)`), `skills/canary-skill/SKILL.md`

| 명령 | 종료코드 |
|---|---|
| `claude plugin validate <SP>/plug-sdd --strict` | **0** |
| `claude plugin validate <SP>/plug-sdd/.claude-plugin/plugin.json --strict` | **0** |

### 1.3 F1~F13 재측정

| # | proposal 값 | 이번 실측 | 같은가 |
|---|---|---|---|
| F1 | 접두사 없는 `subagent_type` 안 풀림 | 메인 세션 `subagent_type: "canary"` → `Agent type 'canary' not found. Available agents: claude, Explore, general-purpose, Plan, sdd:analyzer, sdd:caller, sdd:caller2, sdd:canary, sdd:canary2, sdd:code-explorer, sdd:designer, sdd:finalizer, sdd:preparer, sdd:regression-verifier, sdd:reviewer, sdd:worker, statusline-setup` | 같음 |
| F2 | `skills:`에 접두사 필요 없음, 둘 다 주입 | `sdd:canary`(`[canary-skill]`)·`sdd:canary2`(`[sdd:canary-skill]`) 둘 다 서브 transcript에 SKILL 본문(`CANARY_SKILL_TOKEN_K8Z`)이 들어옴. **실제 파일** `sdd:regression-verifier`(`skills: [sdd-rules]`)도 transcript에 `<command-name>sdd-rules</command-name>`과 sdd-rules 본문(`# SDD 공용 규칙` … `## store 처리`)이 들어오고, 도구 없이 `## store 처리`를 인용함 | 같음 |
| F3 | 에이전트 본문 `${CLAUDE_PLUGIN_ROOT}` 치환됨, Bash 환경변수는 비어 있음 | `sdd:canary`가 본문의 값을 `<SP>/plug-sdd`(절대 경로)로 보고. Bash `echo "env=$CLAUDE_PLUGIN_ROOT"` → `env=` | 같음 |
| F4 | 서브에이전트 Bash PATH에 `bin/` 있음 | `sdd:canary`의 `command -v sdd-probe` → `<SP>/plug-sdd/bin/sdd-probe` | 같음 |
| F5 | `tools: Agent(...)`로 못 좁힘 | `sdd:caller`(`Agent(canary)`)와 `sdd:caller2`(`Agent(sdd:canary)`) 둘 다 `sdd:canary2`를 실제로 띄움 — subagents meta.json `agentType: "sdd:canary2"`, `parentAgentId`가 각 caller | 같음 |
| F6 | `--plugin-dir`이 같은 이름 설치본을 이김 | 격리 `CLAUDE_CONFIG_DIR`에 `sdd@sdd-marketplace` 0.0.1 설치 뒤 `--plugin-dir <SP>/f6`(0.0.2)로 실행 → init plugins 목록에 `sdd@inline` 0.0.2 하나만(나머지는 builtin) | 같음 |
| F7 | `openspec/` 있으면 stdout이 메인 컨텍스트에, 없으면 stdout `''` exit 0 | 있음: hook_response stdout `HOOK_INJECT_TOKEN_M5R: SDD gate hook active.\n` exit 0, 모델이 토큰을 그대로 출력. 없음: stdout `''` exit 0, 모델 `NONE`. (두 경우 모두 별도로 `{}`를 내는 훅이 하나 더 도는데, 사용자 전역 설정의 훅이고 시험 플러그인 것이 아니다) | 같음 |
| F8 | ① marketplace `description` 없으면 `--strict` rc=1 ② `validate .`는 plugin.json 매니페스트 자체를 검사하지 않음 | ① 같음: `description` 뺀 사본 → warning, `--strict` exit 1. ② **다름**: plugin.json에 `version: 123`과 모르는 키를 넣은 사본에서 `claude plugin validate <사본> --strict`가 `plugins[0] plugin.json → version: Invalid input` 오류와 `Validating plugin: <사본>/.claude-plugin/plugin.json` 블록을 내고 exit 1. 모르는 키(warning)만 남기면 `--strict` exit 1, `--strict` 없이 exit 0. 즉 `validate .`도 plugin.json을 검사한다(marketplace plugins[0].source `./` 기준) | **다름(②)** |
| F9 | validate 둘 다 rc=0, 고정 비용 약 1,669 토큰, 에이전트 8·스킬 4 | 지금 파일만 복사한 `<SP>/f9`(에이전트 8 + orchestra·sdd-rules·sdd-sync·init-sdd) → validate 둘 다 exit 0. `claude --plugin-dir <SP>/f9 plugin details sdd` → `Always-on: ~1,669 tok`, Skills (4), Agents (8) | 같음 |
| F10 | 최소 init이 3개 파일만 만들고 `new change`·`status` rc=0 | `mktemp -d` + `git init`에서 `npx -y @fission-ai/openspec@1.14.1 init --tools none --no-animation` exit 0 → `openspec/config.yaml`, `openspec/specs/.gitkeep`, `openspec/changes/archive/.gitkeep` 3개만, `.claude/` 없음. `new change probe-change` exit 0, `status --change probe-change` exit 0 | 같음 |
| F11 | 래퍼 1.14.1, 전역 1.12.0, Node v26.10.0 | `npx -y @fission-ai/openspec@1.14.1 --version` → `1.14.1` exit 0. `command -v openspec` → `/opt/homebrew/bin/openspec`, `openspec --version` → `1.12.0`. `node --version` → `v26.10.0` | 같음 |
| F12 | 로컬 경로 마켓플레이스 add·install rc=0, list에 enabled | 격리 `CLAUDE_CONFIG_DIR`: `marketplace add <SP>/plug-sdd` exit 0, `install sdd@sdd-marketplace` exit 0(scope user), `plugin list` → `sdd@sdd-marketplace` Version 0.0.1 `Status: ✔ enabled` | 같음 |
| F13 | eval에 dry-run 없음, 실행하면 비용 | `claude plugin eval --help` exit 0, 91줄. dry-run 옵션 없음. 있는 관련 옵션: `--json [path]`, `--max-cost-usd <usd>`, `--no-publish`, `--output-dir <dir>`, `--report <path>`, `--trust-plugin` | 같음(도움말만 기록) |

측정 방법 메모: 모델 호출은 `claude -p "<프롬프트>" --plugin-dir <S> --output-format stream-json --verbose --model haiku ...`(프롬프트를 플래그 앞에, stdin `/dev/null`).
격리 `CLAUDE_CONFIG_DIR`은 로그인 정보가 없어 모델 호출이 `Not logged in`으로 끝난다. 그래서 F6은 init 이벤트와 hook 이벤트만 그 설정에서 보고, 모델이 필요한 F1~F5·F7·G-PATH·G-SKILLROOT는 기본 설정에서 `--plugin-dir`로 쟀다(설치된 플러그인 없음 — `claude plugin list` → `No plugins installed.`).
서브에이전트는 백그라운드로 떠서 결과를 `~/.claude/projects/<cwd>/<session>/subagents/*.jsonl`·`*.meta.json`에서 확인했다.

### 1.4 추가 관문

| 관문 | 측정 | 결과 |
|---|---|---|
| G-PATH | 메인 세션 Bash `command -v sdd-probe; echo "rc=$?"` | `<SP>/plug-sdd/bin/sdd-probe`, `rc=0`. PATH 맨 끝에 `<SP>/plug-sdd/bin`이 붙음. 메인 세션 Bash에서도 `$CLAUDE_PLUGIN_ROOT`는 비어 있음 → **통과** |
| G-SKILLROOT | 메인 세션이 `Skill("sdd:probe")` 호출 | 주입된 본문이 `Plugin root seen by this skill body: <SP>/plug-sdd`(절대 경로로 치환됨) → **통과** |
| G-CACHE | 격리 `CLAUDE_CONFIG_DIR`에서 `marketplace add <SP>/plug-sdd` → `install sdd@sdd-marketplace` 뒤 캐시 `<CFG>/plugins/cache/sdd-marketplace/sdd/0.0.1/` | `.claude/settings.json` 있음(`test -f` exit 0), `bin/sdd-probe` 있고 실행 가능(`test -x` exit 0). 캐시에 `.claude-plugin/`, `agents/`, `skills/`, `hooks/`도 모두 복사됨 → **통과** |

### 1.5 멈춤 판정

판정: **멈춤** — F8이 proposal과 다르다(`claude plugin validate .`가 marketplace plugins[0](`./`)을 따라 plugin.json도 검사한다). 다른 항목(F1~F7, F9~F13, G-PATH, G-SKILLROOT, G-CACHE)은 모두 proposal·기대와 같다. F2 통과, G-CACHE 통과, G-PATH 통과.

참고(판단은 오케스트레이터 몫): 차이의 방향은 "`validate .`가 더 많이 검사한다"이다. 두 명령을 다 돌리라는 받아들일 조건은 여전히 맞고 해가 없다(중복일 뿐). 바뀌는 것은 proposal F8 근거 문장과, 그 문장을 인용한 설계·spec 서술이다.

## 묶음 9 — 이동 뒤 검증 (2026-10-09, Claude Code 2.1.294, 전역 openspec 1.12.0, sdd-openspec 1.14.1)

시험 위치는 `<SP>/n9/` 아래 `mktemp -d`들이다. 모델 호출은 `--model haiku`(9.16만 기본 모델). 격리 설정 `<CFG>` = `<SP>/n9/cfg.*`.
기본 설정의 `claude plugin list` → `No plugins installed.`(시험 전 기록).

**사고 기록 (9.8 도중):** init-sdd 걸기·풀기 시험 스크립트 1회차가 bash에서 쓸 수 없는 한글 변수 이름(`대상=`, `개인=`)을 써서 대입이 실패했고,
`cd`가 실패한 채 저장소 루트에서 이어 돌았다. 그 결과 저장소에 ① 커밋 `3eb4cd1 init`(작성자 `t <t@t>` — 그때 스테이징돼 있던 8.1·8.2 이동과
루트 `CLAUDE.md`(3줄짜리 시험 내용)가 들어감) ② 루트 `CLAUDE.md`(시험 내용) ③ `.git/info/exclude` 끝의 `docs/` 한 줄 ④ 미추적 디렉터리 `$대상/`, `$개인/`(안에 중첩 git 저장소)이 생겼다.
worker는 되돌리지 않았다(히스토리 조작·삭제는 worker 권한 밖). 아래 9.1·9.16은 사고 **전**에 잰 값이다. 2회차(ASCII 변수, `cd` 실패 시 중단)는 scratchpad 안에서만 돌았다.

| # | 결과 | 요약 |
|---|---|---|
| 9.1 | 통과 | `claude plugin validate . --strict` exit=0, `claude plugin validate .claude-plugin/plugin.json --strict` exit=0, 둘 다 `✔ Validation passed`, 경고 0건(`CLAUDE.md at the plugin root` 없음). `--strict` 없는 `validate .`도 exit=0 |
| 9.2 | 통과 | 아래 목록 |
| 9.3 | 통과 | 7개 = 기대 문장, code-explorer = NONE (아래 표) |
| 9.4 | 통과 | `bin/sdd-openspec --version` → `1.14.1`, exit=0. 세 파일은 미추적이라 임시 인덱스(`GIT_INDEX_FILE=<SP>/idx9`, 실제 인덱스 안 건드림)에 add 해서 `git ls-files -s` → 셋 다 `100755` (`core.fileMode=true`) |
| 9.5 | 통과 | (a) exit=0, 0바이트 / (b) exit=0, 0바이트 / (c) exit=0, 817바이트, 지휘 규칙 6줄 + `[SDD 점검] 권한에 Bash(sdd-openspec:*)가 없다 — /sdd:init 으로 추가할 수 있다.` + `[SDD 점검] 끝났지만 archive 안 된 change: done-one`, `old-one` 없음 / (d) hook_response(exit_code 0, outcome success) stdout이 직접 실행 출력과 글자까지 같음(`same_as_direct: True`) |
| 9.6 | 통과(팀 배포 키 일부 미확인) | 아래 |
| 9.7 | 통과 | 아래 |
| 9.8 | 통과 | 아래 (2회차 기준) |
| 9.9 | 통과 | 아래 |
| 9.10 | 통과 | `subagent_type: "` 18줄 모두 `sdd:`(비-`sdd:` 0), `skills/sdd-rules/SKILL.md:49`에 `sdd:code-explorer`, D6 grep 0건(rc=1), `^skills:` 7줄 모두 접두사 없음 |
| 9.11 | 통과(오케스트레이터 판정 (b)) | 복구 뒤(HEAD `3d1c42c`, 루트 `CLAUDE.md` 없음) 돌림. 비용 상한 중단 exit=2, `direct-work-control`만 인식 확인. 아래 |
| 9.15 | 해당 없음(9.11 기록) | eval 뒤 `test -e evals/results` → 1(안 생김) |
| 9.12 | 통과 | 아래. **finalizer가 대조할 기대값: 110회/90줄** |
| 9.13 | 통과 | 아래 |
| 9.14 | 통과 | 아래 표 |
| 9.16 | 통과 | 아래 |

### 9.2 init 이벤트 (`claude -p "준비됐으면 OK라고만 답하라" --plugin-dir . --output-format stream-json --verbose --max-turns 1 --model haiku`, exit=0)

- agents: `['claude', 'Explore', 'general-purpose', 'Plan', 'sdd:analyzer', 'sdd:code-explorer', 'sdd:designer', 'sdd:finalizer', 'sdd:preparer', 'sdd:regression-verifier', 'sdd:reviewer', 'sdd:worker', 'statusline-setup']`
- skills 중 `sdd:` 항목: `'sdd:init', 'sdd:orchestra', 'sdd:sdd-rules', 'sdd:sdd-sync'` (그 밖의 `sdd:` 없음, 모델 등급 스킬 없음). 나머지는 프로젝트 `.claude/skills/`(`init-sdd`, `openspec-*`)와 사용자 전역·내장 스킬
- plugins: `{'name': 'sdd', 'path': '/Users/0stone_1004/work-space/init-SDD', 'source': 'sdd@inline', 'version': '0.1.0'}` + builtin 4개

### 9.3 sdd-rules 주입

사전 확인: `grep -rnF "<문장>" agents skills .claude` → `skills/sdd-rules/SKILL.md:38` 한 곳뿐. 문장 = ``프롬프트의 `store: <id>` 값이 있으면 그 store가 이번 작업의 OpenSpec 기준 저장소다.``
방법: 저장소 루트에서 `claude -p "<Agent로 sdd:<이름>을 부르고, 도구 없이 주입된 공용 규칙의 '## store 처리' 첫 문장 또는 NONE을 답하게 하라>" --plugin-dir . --allowedTools "Agent" --output-format stream-json --verbose --model haiku`, 8회 모두 exit=0. 서브에이전트 답은 tool_result에서 뽑았다.

| subagent_type | 서브에이전트 답 | tool_uses | 판정 |
|---|---|---|---|
| sdd:preparer | 기대 문장 | 0 | 주입됨 |
| sdd:analyzer | 기대 문장 | 0 | 주입됨 |
| sdd:designer | 기대 문장 | 0 | 주입됨 |
| sdd:worker | 기대 문장 | 0 | 주입됨 |
| sdd:reviewer | 기대 문장 | 0 | 주입됨 |
| sdd:regression-verifier | 1회차 `프롬프GT의 \`store: <id>\` 값이 …`(첫 낱말 한 글자 출력 오류, 나머지 같음) → 재실행 기대 문장 그대로 | 0 / 0 | 주입됨 |
| sdd:finalizer | 기대 문장 | 0 | 주입됨 |
| sdd:code-explorer | `NONE` | 0 | 주입 안 됨(기대) |

### 9.6 마켓플레이스 설치와 `/sdd:init` 비대화 단계 (격리 `<CFG>`)

- `claude plugin marketplace add <repo>` exit=0, `claude plugin install sdd@sdd-marketplace` exit=0(scope user), `plugin list` → `sdd@sdd-marketplace` Version 0.1.0 `✔ enabled`
- 캐시 `<CFG>/plugins/cache/sdd-marketplace/sdd/0.1.0/`에 `bin/sdd-init`, `bin/sdd-openspec`, `.claude/settings.json` 있음. 셸에서는 캐시 경로로 직접 불렀다
- 새 프로젝트(`git init -b main`, 빈 커밋, `package.json` test·build): `sdd-init setup` exit=0 → `openspec/.sdd`, `openspec/config.yaml`, `openspec/specs/.gitkeep`, `openspec/changes/archive/.gitkeep`, `.claude` 없음(rc=1)
- `setup` 두 번째 exit=0(`건너뜀`, `표식 있음`), 전후 `git status --porcelain` 같음(`?? openspec/`, `?? package.json`), `find openspec -type f | sort | xargs cat | shasum` 같음(`d972f83a…`) → 멱등
- `detect` exit=0: `기술 스택: Node.js (npm)` / `테스트 명령: npm test` / `빌드 명령: npm run build` / `기본 브랜치: main (로컬 main 브랜치)`
- `permissions` exit=0: 11개 항목(`Bash(sdd-openspec:*)` 포함) + `참고: sdd-openspec 은 첫 실행 때 npm 레지스트리에서 @fission-ai/openspec@1.14.1 을 받는다.` + 무시 여부 줄
- `write-context` exit=0 → `sdd-openspec context` exit=0, `Warning` 0건. 두 번째 `write-context` → exit=2(기존 `context:` 보호)
- 팀 배포 키: 새 격리 설정 + 프로젝트 `.claude/settings.json`에 `extraKnownMarketplaces`(source `directory`, 로컬 경로) + `enabledPlugins` → `claude plugin list` `No plugins installed`, `marketplace list`에 sdd-marketplace 없음,
  `claude -p` init plugins 목록에 `sdd` 없음 → **비대화(`-p`) 모드에서는 `extraKnownMarketplaces`가 자동 등록·설치되지 않는다**(설계가 말한 "신뢰할 때 설치 안내"는 대화형 신뢰 화면이라 자동으로 못 쟀다).
  `enabledPlugins`는 프로젝트 범위에서 읽힌다: 설치된 격리 설정에서 프로젝트 `.claude/settings.json`에 `"sdd@sdd-marketplace": false`를 두면 init plugins에서 `sdd`가 빠지고 `plugin list`가 `✘ disabled`
- 대화가 필요한 단계(초안 확인, 권한 동의, 스킬 문서 흐름 자체)는 자동으로 확인하지 않았다. 자동 확인 범위는 위 실행 파일 단계까지다

### 9.7 권한 기록과 작은 작업 change

- 시험 프로젝트: `.claude/settings.json`(`permissions.allow` 1개 + `env`)과 `.gitignore` 커밋, 기존 `.claude/settings.local.json`(`Bash(git status:*)` + `model`)
- `write-permissions` 1회 exit=0(10개 더함), 2회 exit=0(`더할 항목이 없다`). 결과 11개, 중복 0, `model` 키 유지. `.claude/settings.json`·`.gitignore` 해시 불변
- 이 기기는 사용자 전역 `~/.config/git/ignore`가 `**/.claude/settings.local.json`을 무시 → 전후 `git status --porcelain` 차이 0줄. 전역 무시를 끈 저장소(`core.excludesFile=/dev/null`)에서는 차이가 `?? .claude/settings.local.json` 한 줄, 추적 파일 diff 0
- `sdd-openspec new change try-small` exit=0, proposal.md·tasks.md 손으로 작성, `.openspec.yaml`에 마커 명령 꼴로 `skip_specs: true` → `validate try-small --strict` exit=0(`skip_specs is set` INFO), `status --change try-small --json` exit=0

### 9.8 기존 설치본

- `bash -n install.sh` rc=0, `--dry-run` exit=0: `[복사 예정]` = `.claude/agents/*.md` 8개 + `orchestra`·`sdd-rules`·`sdd-sync` + `.claude/settings.json`, 모델 등급 스킬 없음. 플러그인 권장 줄(`권장 설치는 플러그인이다 — …`)과 두 이름 줄(`… 두 이름(sdd:<이름>, <이름>)으로 실린다.`) 있음
- 실제 설치 exit=0, 설치 확인 전부 ok. `diff -r <repo>/skills/sdd-rules <T>/.claude/skills/sdd-rules` 차이 없음(rc=0). `<T>/CLAUDE.md`와 `<repo>/.claude/CLAUDE.md` 표식 구획 `diff` rc=0(23줄)
- 두 번째 실행 exit=0, 12개 전부 `[있음, 건너뜀]`. `(원본: …)` 12개 모두 `test -e` 0. `.claude/agents/worker.md` 줄의 원본 = `<repo>/agents/worker.md`
- init-sdd 원본 경로 `test -e`(`agents`, `skills/orchestra`, `skills/sdd-rules`, `skills/sdd-sync`, `.claude/settings.json`, `.claude/CLAUDE.md`, `install.sh`) 모두 0. 원본 탐색 루프가 `<repo>`를 찾음
- 걸기·상태·풀기 1회(2회차, `CLAUDE.md` 커밋된 프로젝트 = skip-worktree 갈래): 걸기 뒤 링크 5개 모두 개인 저장소를 가리키고 살아 있음, 공유 `git status --porcelain` 전후 같음(빈 출력). 상태 보기 5자리 `링크됨`, `CLAUDE.md : 조각 있음`/`git 추적 중`, `skip-worktree : 걸려 있음`, exclude 구간 5줄.
  풀기 뒤 링크 0개, `git status --porcelain` 같음, `git diff --exit-code` rc=0, `CLAUDE.md` 해시 원래와 같음, exclude의 init-sdd 줄 0(사용자 줄 `docs/` 그대로), 개인 저장소 남음

### 9.9 기존 설치본 대비 규칙 (9.8 설치 프로젝트, 플러그인 없음, exit=0)

init agents: `analyzer, claude, code-explorer, designer, Explore, finalizer, general-purpose, Plan, preparer, regression-verifier, reviewer, statusline-setup, worker`(`sdd:` 없음).

```text
TOOL_USE Agent sdd:code-explorer
TOOL_RESULT is_error=True: Agent type 'sdd:code-explorer' not found. Available agents: analyzer, claude, code-explorer, designer, Explore, finalizer, general-purpose, Plan, preparer, regression-verifier, reviewer, statusline-setup, worker
TOOL_USE Agent code-explorer
TOOL_RESULT is_error=None: Async agent launched successfully. ...
```

마지막 결과: `sdd:code-explorer 호출 결과: not found` / `code-explorer 호출 결과: NONE`(시험 프로젝트에 README.md 없음).

### 9.11 eval 인식 (복구 뒤 측정)

`.gitignore` 16줄에 `evals/results/` 있음. 이 macOS에는 `timeout`(과 `gtimeout`)이 없어서(`timeout` → `command not found`, exit=127, 아무것도 안 돎)
같은 일을 하는 `perl -e 'alarm 600; exec @ARGV'`로 감쌌다. 출력은 모두 `<SP>/ev11.B3PnUr/` 아래다.

`perl -e 'alarm 600; exec @ARGV' claude plugin eval . --runs 1 --max-cost-usd 0.05 --no-publish --output-dir <SP>/ev11.B3PnUr/eval-out --json <SP>/ev11.B3PnUr/eval.json --report <SP>/ev11.B3PnUr/eval.html` → **exit=2**. 신뢰 질문은 안 나왔다(`--trust-plugin` 안 씀).

- stderr: `Ablation: defaulting to with-without — ... each case also runs a no-plugin baseline arm (2× runs) ...`
- eval.json: `"partial": true`, `"partialReason": "cost_ceiling"`, `"costUsd": 0.0645046`(상한 0.05를 첫 실행 한 번에 넘김), `suite.plugins` = `sdd` 0.1.0(저장소 루트)
- `cases`에는 `direct-work-control`(`dir: evals/direct-work-control`, `source: prose`) **하나만** 있다. with 팔 1회 뒤 상한으로 멈췄고 grader는 `skipped: cost ceiling`.
  `lite-path-small-task`는 json·html·`eval-out/aggregate-result.json` 어디에도 이름이 없다 — 돌기 전에 멈춰서 **인식 여부를 이 출력으로는 알 수 없다.**
- 추가로 돈이 안 드는 확인: `--case 'zz-no-such-case'`(나머지 플래그 같음, 출력 `<SP>/ev11b.kNAG46/`) → `No eval cases found matching --case "zz-no-such-case" under /Users/0stone_1004/work-space/init-SDD.` exit=1. 찾은 사례 목록은 안 보여 준다.
- 실행 뒤: `test -e evals/results` → 1, `git check-ignore -q evals/results/x` → 0, `git ls-files evals/results | wc -l` → 0. `evals/results/`가 안 생겼으므로 9.15는 해당 없음.
- 기록할 사실: 비용 상한 초과(0.0645 > 0.05 — 상한은 실행이 끝난 뒤 판정됨), macOS `timeout` 대신 `perl alarm 600` 사용, json `runsPerCase`가 `--runs 1`인데도 3으로 표시됨(실제 실행은 with 팔 1회).
- **오케스트레이터 판정 (b):** `direct-work-control` 인식만으로 9.11을 통과로 친다(추가 비용 없음. 두 사례는 ④ 리뷰에서 bare 템플릿과 같은 구조로 대조됨).

### 9.12 메인 spec 치환 시뮬레이션 (`<SP>/n9/sim.*` 사본, 저장소 `openspec/specs`는 안 건드림)

- 사본 치환 전 152회/126줄. 사본에서 `openspec/specs/distribution/agent-model-tier/` 삭제 → `<repo>/bin/sdd-openspec archive convert-to-plugin --yes` exit=0(`Totals: + 30, ~ 17, - 0, → 1`) → 176회/150줄
- D12 치환(파이썬 문자열 치환, 사본만): (a) 14개 spec `.claude/agents` 37, `.claude/skills/orchestra` 20, `.claude/skills/sdd-rules` 8, `.claude/skills/sdd-sync` 3 / (b) 1 / (b2) 1 / (b3) 2
- 치환 뒤 **110회 / 90줄**. 같은 치환 2회차: 바뀐 것 0, `diff -r` 같음(멱등)
- `grep -rn 'agent-model-tier' openspec/specs` → 0건. 저장소 메인 spec의 현재 값은 20줄(`agent-model-tier/spec.md` 8 + code-explorer-role 2 + code-explorer-invocation 1 + init-sdd-skill 3 + sdd-install-script 6)이고, 은퇴 + archive 델타 반영만으로 0이 된다(치환 단계 전 이미 0)
- `analyzer-option-generation`: `subagent_type: "analyzer"` 0, ``grep -c '`CLAUDE.md`, `README.md`'`` 0, ``grep -c '`.claude/CLAUDE.md`, `README.md`'`` 2. `field-validation-record`: `되기 전에는 실행할 수 없다` 0, `가 존재하지 않는다` 0
- 남은 `agent-instructions/` 의 `.claude/` 5줄은 모두 "그대로 두는 것": 홀로 쓴 `.claude/`(code-explorer-role), `.claude/skills/openspec-*`(shared-pipeline-rules 2), `.claude/CLAUDE.md`(b3 2)

finalizer가 대조할 기대값: 110회/90줄

### 9.13 change 검증

| 명령 | exit |
|---|---|
| `openspec validate "convert-to-plugin" --strict` (1.12.0) | 0 (`Change 'convert-to-plugin' is valid`) |
| `bin/sdd-openspec validate "convert-to-plugin" --strict` (1.14.1) | 0 (`Change 'convert-to-plugin' is valid`) |
| `bin/sdd-openspec status --change "convert-to-plugin" --json >/dev/null` | 0 |
| `openspec validate --all --strict` (1.12.0) | 0 (`Totals: 20 passed, 0 failed (20 items)`, 긴 요구사항은 INFO) |
| `bin/sdd-openspec validate --all --strict` (1.14.1) | 1 (`Totals: 11 passed, 9 failed (20 items)`) — 실패 9개는 모두 메인 spec의 `Requirement text is very long (>500 characters)` WARNING(design E4, 이 change 문제 아님). `change/convert-to-plugin`은 ✓ |

1.14.1 실패 spec(9개, 모두 같은 경고): agent-instructions/{analyzer-option-generation, code-explorer-invocation, finalizer-archive-rationale-accuracy, lite-default-path, shared-pipeline-rules, skill-tool-invocation-rationale}, distribution/{agent-model-tier, init-sdd-skill, sdd-install-script}.

### 9.14 고친·만든 `.md` 점검

| 파일 | 리치 토큰 | 코드펜스 줄(짝수) | frontmatter |
|---|---|---|---|
| agents/analyzer.md | 0 | 4 | `---` 2줄 + name·description·model·tools·skills, HEAD와 같음 |
| agents/code-explorer.md | 0 | 0 | name·description·model·tools, HEAD와 같음 |
| agents/designer.md | 0 | 14 | 5키, HEAD와 같음 |
| agents/finalizer.md | 0 | 12 | 5키, HEAD와 같음 |
| agents/preparer.md | 0 | 18 | 5키, HEAD와 같음 |
| agents/regression-verifier.md | 0 | 4 | 5키, HEAD와 같음 |
| agents/reviewer.md | 0 | 12 | 5키, HEAD와 같음 |
| agents/worker.md | 0 | 6 | 5키, HEAD와 같음 |
| skills/init/SKILL.md | 0 | 12 | name·description (새 파일) |
| skills/orchestra/SKILL.md | 0 | 40 | name·description, HEAD와 같음 |
| skills/sdd-rules/SKILL.md | 0 | 0 | name·description, HEAD와 같음 |
| skills/sdd-sync/SKILL.md | 0 | 4 | name·description, HEAD와 같음 |
| .claude/skills/init-sdd/SKILL.md | 0 | 48 | name·description(설명 값만 D9대로 모델 등급 스킬 이름 삭제) |
| README.md | 0 | 22 | 없음(원래 없음) |
| .claude/CLAUDE.md | 0 | 0 | 없음(원래 없음) |
| evals/README.md | 0 | 6 | 없음(원래 없음) |

본문의 `---` 줄 수(가로줄)는 HEAD와 같다(analyzer 4, worker 7, orchestra 5, init-sdd 10). 파일 첫 줄 `---` + 다음 `---`가 frontmatter다.

### 9.16 프로젝트 지침 위치 (사고 전 측정)

`test -e CLAUDE.md` → 1, `test -f .claude/CLAUDE.md` → 0, `git check-ignore -q .claude/CLAUDE.md` → 1.
`claude -p "읽기 도구를 쓰지 말고, 이 세션에 실린 프로젝트 지침에서 '# 이 저장소를 고칠 때' 바로 아래 첫 줄을 그대로 적어라. 없으면 NONE." --plugin-dir . --max-turns 1` exit=0, 답:

```text
- 이 저장소는 플러그인 `sdd`의 루트다. `claude --plugin-dir .`로 띄운다.

이 세션에 실린 제목은 정확히 `# 이 저장소를 고칠 때 (개발자 안내)`이고, 위 줄은 그 제목 다음 빈 줄을 건너뛴 첫 내용 줄입니다.
```

**복구 뒤 재측정 (HEAD `3d1c42c`):** `test -e CLAUDE.md` → 1, `test -f .claude/CLAUDE.md` → 0, `git check-ignore -q .claude/CLAUDE.md` → 1.
같은 `claude -p ... --plugin-dir . --max-turns 1`(stdin `/dev/null`) exit=0, 답:

```text
- 이 저장소는 플러그인 `sdd`의 루트다. `claude --plugin-dir .`로 띄운다.

(제목 바로 다음 줄은 빈 줄이라서, 빈 줄을 빼고 처음 나오는 내용 줄을 적었습니다.)
```

**9.1 복구 뒤 재측정:** `claude plugin validate . --strict` → `Validating marketplace manifest: .../.claude-plugin/marketplace.json` `✔ Validation passed` exit=0,
`claude plugin validate .claude-plugin/plugin.json --strict` → `Validating plugin manifest: .../.claude-plugin/plugin.json` `✔ Validation passed` exit=0. 경고 0건.
