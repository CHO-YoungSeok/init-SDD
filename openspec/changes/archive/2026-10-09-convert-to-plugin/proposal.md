## Why

최상위 목표는 "openspec + orchestra 구조를 어떤 프로젝트에도 빠르게 적용"하는 것이다.
②까지 끝나서 파이프라인은 가볍고 스캐폴드에 기대지 않지만, 설치는 아직 `install.sh` 복사나 `init-sdd` 링크뿐이다.
둘 다 공유 저장소의 `.claude/`를 건드리고, 업데이트 수단이 없고, 사용자 PATH의 openspec 버전(여기서는 1.12.0)에 끌려간다.

상위 change `plugin-lite-sdd-distribution`의 하위 change ③이다. 결정 내용은 상위 change의 `decision.md`(1안, 핵심 결정 2~5)를 따른다.
①④②는 archive 완료다.

## What Changes

1. **플러그인 골격** — 저장소 루트 = 플러그인 루트.
   `.claude-plugin/plugin.json`(name `sdd`, version 고정, author), `.claude-plugin/marketplace.json`(예약 이름이 아닌 이름).
   에이전트는 `agents/`, 스킬은 `skills/` 표준 레이아웃으로 옮긴다.
2. **openspec 래퍼** — `bin/sdd-openspec` = `npx -y @fission-ai/openspec@1.14.1 "$@"`.
   플러그인의 `bin/`은 PATH 끝에 붙으므로 이름을 `openspec`과 다르게 둔다.
3. **SessionStart 훅** — `hooks/hooks.json`. `/sdd:init`이 남기는 표식 파일 `openspec/.sdd`가 있을 때만 지휘 규칙 5줄 안팎과 점검(doctor) 결과를 넣는다.
   `openspec/`만 있고 표식이 없는 프로젝트(openspec을 따로 쓰는 곳)에는 넣지 않는다. 표식을 지우면 꺼진다.
   플러그인 루트의 CLAUDE.md는 로드되지 않으므로 이 훅이 CLAUDE.md를 대신한다.
4. **`/sdd:init` 스킬**(요청 이름은 `/sdd-init`, 아래 가정 A4 참고) — 새 프로젝트에서 한 번 실행한다. 하는 일:
   - `openspec/`만 만드는 최소 init과 훅 표식 `openspec/.sdd`(여러 번 돌려도 같다)
   - 스택·테스트·빌드 명령을 감지해 `config.yaml` `context:` 초안을 쓰고 사용자에게 확인받는다
   - 기본 브랜치를 감지한다
   - 추가할 권한 목록을 보여 주고, 동의하면 `.claude/settings.local.json`에 기록한다
5. **에이전트 이름 접두사 `sdd:`** — orchestra의 `subagent_type`(지금 18곳)과 sdd-rules의 code-explorer 호출 이름을 `sdd:<이름>`으로 바꾼다.
6. **agent-model-tier 삭제** — 스킬 파일과 메인 spec `distribution/agent-model-tier`를 은퇴시킨다
   (요구사항 7개 전부 REMOVED, `retire_capabilities: true`). README, install.sh, init-sdd의 언급도 정리한다.
7. **기존 설치 방식 유지 + 이전 안내** — `install.sh`와 `init-sdd`는 지우지 않는다. "플러그인으로 이전" 안내를 넣는다.
   파일을 옮긴 뒤에도 둘이 깨지지 않게 원본 경로를 조정한다.
8. **dogfooding** — 이 저장소는 `claude --plugin-dir .`로 개발한다. README에 개발용 실행법을 먼저 적는다.
   파일 이동(`.claude/agents` → `agents/` 등)은 이 change의 **마지막 작업**이다.
   이 저장소의 CLAUDE.md는 개발자용 안내로 줄인다(전면 재작성은 ⑤).
   그리고 그 파일을 **`.claude/CLAUDE.md`로 옮긴다**(묶음 8 이동에 포함). 플러그인 루트(= 저장소 루트)의 `CLAUDE.md`는
   `claude plugin validate`가 경고하고 `--strict`가 실패시킨다(구현 중 실측, design E7·D15). Claude Code는 `.claude/CLAUDE.md`도
   프로젝트 지침으로 읽으므로 dogfooding은 유지된다. `install.sh`와 `init-sdd`의 조각 원본 경로·원본 탐색 조건도 `.claude/CLAUDE.md`로 맞춘다.
   설치 결과물인 대상 프로젝트의 `CLAUDE.md` 위치는 바뀌지 않는다.
9. **메인 spec 경로 표기** — decision 핵심 결정 4대로 처리한다.
   - 새 요구사항은 역할 이름으로 쓴다.
   - 델타는 요구사항이 실제로 바뀌는 capability만 만든다.
   - 경로만 바뀌는 곳은 sync 때 **플러그인 루트 기준 상대 경로**(`.claude/agents` → `agents` 등, 핵심 결정 4-1이 허용한 표기)로 일괄 치환하고, 치환 전후 수를 기록한다.
     역할 이름으로 문장을 다시 쓰는 치환은 조사·어순 판단이 들어가 기계적이지 않고, 시나리오 속 `grep` 명령을 못 돌리게 만들어서 쓰지 않는다(design D12).
10. **`.gitignore`에 `evals/results/` 추가.** 플러그인 루트가 생겼으니 `claude plugin eval`이 사례를 인식하는지 확인한다(비용 상한 `--max-cost-usd 0.05`).
    메인 spec `process/field-validation-record`의 "전환 전에는 실행할 수 없다"·"`evals/results/`가 없다" 서술을 전환 뒤 사실에 맞게 고친다.
11. **openspec 스캐폴드 정리 안내** — `.claude/commands/opsx/`와 `.claude/skills/openspec-*`는 gitignore 대상이라 그대로 둔다. 문서에 "이 파이프라인에 필요 없음"을 적는다.

**BREAKING:**
- 플러그인으로 설치하면 에이전트 이름이 `sdd:<이름>`이 된다.
- agent-model-tier 스킬이 없어진다.
- 저장소 안 에이전트·스킬 위치가 `.claude/`에서 `agents/`·`skills/`로 바뀐다.

## preparer 단계에서 미리 잰 사실 (scratchpad, claude 2.1.294, 2026-10-08)

analysis.md "미확인" 항목을 scratchpad의 canary 플러그인(name `sdd`)과 `claude -p --plugin-dir`로 확인했다.
③의 첫 작업(실험 관문)은 이 결과를 **실제 파일로 다시 확인**하는 일로 줄어든다.

| # | 항목 | 결과 | 근거 |
|---|---|---|---|
| F1 | 접두사 없는 `subagent_type: "canary"`가 풀리는가 | **안 풀린다.** `Agent type 'canary' not found. Available agents: ..., sdd:caller, sdd:canary, sdd:canary2, ...` | 메인·서브 양쪽 tool_result |
| F2 | 에이전트 `skills:` 항목에 접두사가 필요한가 | **필요 없다.** `canary-skill`과 `sdd:canary-skill` 둘 다 주입된다(서브 transcript에 SKILL 본문 토큰이 들어옴, 도구는 Read·Bash뿐) | subagents/*.jsonl |
| F3 | 에이전트 본문의 `${CLAUDE_PLUGIN_ROOT}` | **치환된다**(플러그인 절대 경로). Bash 환경변수로는 `unset` | 같은 transcript |
| F4 | 플러그인 `bin/`이 서브에이전트 Bash PATH에 있는가 | **있다.** `command -v sdd-probe` → `<plugin>/bin/sdd-probe` | 같은 transcript |
| F5 | `tools: Agent(canary)` / `tools: Agent(sdd:canary)`로 호출 대상을 좁힐 수 있는가 | **못 좁힌다.** 두 경우 모두 caller 서브에이전트가 `sdd:canary2`를 실제로 띄웠다 | subagents/*.meta.json `agentType: sdd:canary2` |
| F6 | `--plugin-dir`과 같은 이름 설치본 동시 로드 | **`--plugin-dir`이 이긴다.** init 이벤트의 plugins 목록에 `sdd@inline`(0.0.1) 하나만 있고, 설치본 0.0.9는 로드되지 않았다 | 격리한 `CLAUDE_CONFIG_DIR`로 측정 |
| F7 | SessionStart 훅 조건부 주입 | `openspec/`이 있으면 stdout이 메인 컨텍스트에 들어간다. 없으면 stdout `''`, exit 0 | stream-json `hook_response` |
| F8 | `claude plugin validate .` 범위 | `marketplace.json`이 있으면 `.`은 marketplace 매니페스트를 검사하고, `plugins[0]`(source `./`)을 따라가 `plugin.json`과 에이전트·스킬도 검사한다(관문 1.3 실측: `version` 숫자형 → exit 1, 모르는 키 → `--strict`에서 exit 1). `claude plugin validate .claude-plugin/plugin.json --strict`는 그래서 중복이지만 해가 없고, 버전에 따라 동작이 다를 수 있어 둘 다 돌린다. marketplace에 `description`이 없으면 `--strict`에서 rc=1 | 직접 실행 |
| F9 | 현재 파일을 플러그인 모양으로 복사하면 | `validate` 두 개 모두 rc=0. `plugin details`: 매 세션 고정 비용 약 1,669 토큰(init-sdd 포함), 에이전트 8, 스킬 4 | 직접 실행 |
| F10 | 최소 init | `npx -y @fission-ai/openspec@1.14.1 init --tools none --no-animation`은 `openspec/config.yaml`, `openspec/specs/.gitkeep`, `openspec/changes/archive/.gitkeep` 3개만 만든다(`.claude/` 안 건드림). 이어서 `new change`·`status`가 rc=0 | 직접 실행 |
| F11 | 래퍼 버전 | `npx -y @fission-ai/openspec@1.14.1 --version` → `1.14.1`(rc=0). 전역 `openspec`은 1.12.0(`/opt/homebrew/bin`), Node v26.10.0 | 직접 실행 |
| F12 | 로컬 경로 마켓플레이스 | 격리 설정에서 `claude plugin marketplace add <경로>` → `claude plugin install sdd@<마켓 이름>` 모두 rc=0, `plugin list`에 enabled | 직접 실행 |
| F13 | `claude plugin eval` | dry-run 옵션이 없다. 실행하면 모델 호출 비용이 든다 | `--help` |

아직 확인하지 못한 것: SessionStart 훅으로 넣은 지시를 메인 세션이 CLAUDE.md만큼 잘 따르는지. 실전 검증 범위라 이 change에서는 재지 않는다.

## 받아들일 조건

- [ ] `claude plugin validate . --strict; echo $?` → 0, 그리고 `claude plugin validate .claude-plugin/plugin.json --strict; echo $?` → 0 (F8 때문에 둘 다)
- [ ] 새 `claude -p --plugin-dir .` 프로세스의 init 이벤트(`--output-format stream-json --verbose`)에서 확인:
      - 에이전트 8개가 `sdd:` 접두사로 나온다
      - 스킬 목록에 `sdd:orchestra`, `sdd:sdd-rules`, `sdd:sdd-sync`, `sdd:init`(이름은 A4)이 있다
      - `agent-model-tier`는 없다
- [ ] 새 프로세스에서 7개 에이전트가 sdd-rules에만 있는 문장을 인용한다(주입 확인, 메인 spec `shared-pipeline-rules` 시나리오)
- [ ] `bin/sdd-openspec --version` → `1.14.1`, rc=0
- [ ] SessionStart 훅을 세 디렉터리에서 실행해 확인:
      - `openspec/` 없는 디렉터리(`mktemp -d`): stdout이 비어 있고 rc=0
      - `openspec/`은 있지만 표식 `openspec/.sdd`가 없는 디렉터리: stdout이 비어 있고 rc=0
      - 표식이 있는 디렉터리: 지휘 규칙과 점검 결과가 나온다
      - 훅 명령을 직접 실행해도 같은 결과가 나온다
- [ ] 이 저장소에 표식 `openspec/.sdd`가 있다(커밋 대상). README에 표식과 훅 끄는 법이 있다
- [ ] `mktemp -d` 새 프로젝트에서 다음 순서로 rc=0을 확인한다(사용자 전역 설정은 `CLAUDE_CONFIG_DIR` 격리로 보호):
      1. `claude plugin marketplace add <이 저장소 경로>`
      2. `claude plugin install sdd@<마켓 이름>`
      3. `/sdd:init`의 비대화 단계(`openspec/`과 표식 생성 — 두 번 돌려도 같음, context 초안 생성, 기본 브랜치 감지, 권한 목록 출력)
      4. 작은 작업 1건의 change 산출물(proposal + tasks, `validate --strict` rc=0)까지

      대화가 필요한 단계(사용자 확인, 권한 기록 동의)는 절차 문서와 "어디까지 자동으로 확인했는지"를 남긴다.
- [ ] `/sdd:init`이 권한을 `.claude/settings.local.json`에만 쓰고 `.claude/settings.json`과 공유 `.claude/` 파일은 바꾸지 않는다(전후 `git status`로 대조)
- [ ] `grep -rn 'subagent_type: "' skills/orchestra/SKILL.md`의 모든 이름이 `sdd:` 접두사를 가진다. sdd-rules의 code-explorer 호출 이름도 `sdd:code-explorer`다
- [ ] agent-model-tier 정리:
      - `skills/agent-model-tier/` 없음
      - 메인 spec `distribution/agent-model-tier` 은퇴
      - `grep -rn 'agent-model-tier'`가 archive·상위 기록 change·측정 기록(`docs/field-validation.md`의 기준선 서술)을 뺀 곳에서 0건
- [ ] 저장소 루트에 `CLAUDE.md`가 없고 `.claude/CLAUDE.md`가 있다. 새 `claude -p --plugin-dir .` 세션이 `.claude/CLAUDE.md`의 문장을 읽기 도구 없이 인용한다
- [ ] `bash -n install.sh` rc=0, `bash install.sh --dry-run`(빈 `mktemp -d` 대상)이 새 경로(`agents/`, `skills/`, `.claude/CLAUDE.md`)에서 원본을 찾는다. `init-sdd`의 원본 경로와 원본 탐색 조건(`install.sh` + `.claude/CLAUDE.md`)도 같은 기준으로 맞는다
- [ ] `install.sh`가 이미 있는 파일을 건너뛸 때 안내하는 원본 경로가 실제로 있는 경로다(예: `.claude/agents/worker.md` → `<저장소>/agents/worker.md`)
- [ ] README에 다음이 있다:
      - 플러그인 설치 두 줄
      - `/sdd:init`
      - 개발용 `claude --plugin-dir .`
      - 기존 방식에서 이전하는 안내
      - 스캐폴드(`.claude/commands/opsx/`, `.claude/skills/openspec-*`)가 필요 없다는 안내
      - 플러그인 업데이트 절차, 팀 배포(`extraKnownMarketplaces`/`enabledPlugins`), Windows는 bash 필요
- [ ] `.gitignore`에 `evals/results/`가 있다. `claude plugin eval`이 `evals/`의 사례를 인식하는지(실행 시작까지, `--max-cost-usd 0.05`, `--json`/`--report`는 저장소 밖) 확인 결과를 남긴다. 실행 뒤 `evals/results/`가 git에 추적되지 않는다. 점수 측정은 범위 밖
- [ ] 메인 spec `process/field-validation-record`에 "전환 전에는 실행할 수 없다"는 MUST와 "`evals/results/`가 존재하지 않는다"는 시나리오가 남지 않는다(델타로 고침)
- [ ] 메인 spec `.claude/` 출현 수(`grep -o '\.claude/' -r openspec/specs | wc -l`)의 치환 전후 값을 review/commit 기록에 남긴다. 치환 전은 **152**(줄 기준 `grep -c` 합 126)
- [ ] `openspec validate "convert-to-plugin" --strict` rc=0. archive 뒤 `openspec validate --all --strict` rc=0
- [ ] 수정한 `.md` 전부: 리치 마크다운 토큰 0, 코드펜스 짝수, frontmatter 온전

## 범위 밖

- 실전 측정(실제 프로젝트 3~5건, `plugin eval` 점수 측정)
- 공식 마켓플레이스 등록
- `install.sh`와 `init-sdd` 삭제(실전 검증 뒤 별도 change)
- CLAUDE.md·README 전면 재작성(⑤)
- spec·문서 전수 검수(⑥)
- 에이전트 업무 로직 재설계
- 상위 기록 change(`plugin-lite-sdd-distribution`)의 tasks 체크. 이 change가 archive된 뒤 상위 기록에서 한다

## 가정 (사용자 위임으로 preparer가 정한 추천 기본값 — designer가 근거를 들어 뒤집을 수 있다)

- **A1 openspec 호출 표기:** 지시문의 openspec 명령 예시를 `sdd-openspec`으로 바꾼다(래퍼 우선).
  - 지금 에이전트·스킬에 실행 예시가 약 73곳 있다. 모델은 예시 글자를 그대로 따라 치므로, 규칙 한 줄만 두고 예시를 `openspec`으로 남기면 전역 1.12가 실행된다.
  - sdd-rules 한 곳에 "PATH의 `openspec`이 1.14.1 이상이면(`--version`으로 확인) `openspec`을 그대로 써도 된다"를 적는다.
  - 권한 목록에는 `Bash(sdd-openspec:*)`를 넣는다.
  - 메인 spec 시나리오 안의 검증 명령(`openspec validate ...`)은 경로 치환처럼 다루고 의미를 바꾸지 않는다.
- **A2 레거시 설치와 이름 접두사:** `install.sh`와 `init-sdd`로 깐 에이전트는 접두사 없는 이름(`worker`)으로 로드된다(F1의 반대 경우). orchestra가 `sdd:worker`만 부르면 기존 설치본이 깨진다.
  - 그래서 orchestra와 sdd-rules에 대비 규칙을 한 줄 둔다: "`sdd:<이름>`이 `not found`면 접두사 없이 `<이름>`으로 다시 부른다". 실패 메시지가 가능한 이름 목록을 보여 주므로 비용이 작다.
  - 이 대비 규칙은 install.sh와 init-sdd를 없앨 때 함께 지운다.
- **A3 init-sdd 위치:** `init-sdd`는 플러그인에 넣지 않는다. 이 저장소의 `.claude/skills/init-sdd/`에 두는 프로젝트 전용 스킬로 남긴다.
  - 플러그인에 넣으면 사용자 프로젝트에 링크를 거는 레거시 도구가 매 세션 약 240 토큰을 쓰고, `/sdd:init`과 헷갈린다.
  - 원본 탐색 조건은 `install.sh` + `.claude/CLAUDE.md`가 함께 있는 디렉터리로 바꾼다(지침 파일 이동 — What Changes 8, design D15). 복사·링크 원본 경로는 `agents/`, `skills/`로 바꾼다.
- **A4 초기화 스킬 이름:** 플러그인 스킬은 `sdd:<이름>`으로 불린다(F2와 init 목록 `sdd:canary-skill`로 확인).
  - 디렉터리를 `sdd-init`으로 두면 `/sdd:sdd-init`이 되므로 `skills/init/`으로 두어 `/sdd:init`으로 부른다.
  - 문서에서는 "`/sdd:init`(초기화)"로 적는다.
- **A5 매니페스트 값:**
  - `plugin.json`: `name: sdd`, `version: 0.1.0`(첫 플러그인 릴리스, semver 고정), `author.name`은 저장소 git 사용자 이름(email은 생략)
  - `marketplace.json`: `name: sdd-marketplace`(scratchpad에서 validate 통과, `claude-plugins-official`·`anthropic-*` 같은 예약 꼴 아님), 최상위 `description` 필수(F8)
  - 설치 명령은 `/plugin marketplace add <owner/repo 또는 경로>`, `/plugin install sdd@sdd-marketplace`
- **A6 훅 점검(doctor)은 빠르게:** 훅은 매 세션 시작에 돈다. 그래서 훅 안에서 `npx`를 부르지 않는다(첫 실행 3.2초, 네트워크 필요).
  - 켜짐 조건: 표식 `openspec/.sdd` 존재(없으면 아무것도 안 낸다 — 오케스트레이터 결정으로 `openspec/` 존재에서 좁혔다)
  - 점검: `command -v node npx`, 권한 파일(`.claude/settings*.json`)에 `sdd-openspec` 허용 여부, `openspec/changes/*/tasks.md`(archive 제외) 체크박스가 전부 `[x]`인 change(= archive 안 된 완료 change)
  - 문제가 있을 때만 한 줄씩 알린다.
  - 지휘 규칙은 메인 세션 = 오케스트레이터, 일은 `sdd:` 서브에이전트에 위임, `sdd:orchestra` 스킬 사용 — 5줄 안팎으로 쓴다.
- **A7 권한 기록:** `/sdd:init`은 `.claude/settings.local.json`에만 쓴다(없으면 만들고, 있으면 `permissions.allow`에 빠진 항목만 더한다).
  - 이 파일이 git에서 무시되는지 `git check-ignore`로 확인한다. 무시되지 않으면 공유 `.gitignore`를 고치지 않고 사용자에게 알리기만 한다.
- **A8 이 저장소의 CLAUDE.md:** 개발자용 안내(`claude --plugin-dir .` 실행, 이 저장소도 SDD로 개발)로 줄인다.
  - install.sh와 init-sdd가 뽑아 쓰는 `<!-- init-SDD:begin/end -->` 표식 블록은 레거시 조각 원본이므로 남긴다(메인 spec "조각 원본 한 벌" 유지).
  - 표식 블록 안의 `.claude/agents/` 경로는 레거시 설치 대상 프로젝트에서는 여전히 맞으므로 그대로 둔다.
  - 파일은 `.claude/CLAUDE.md`로 옮긴다(루트에 두면 `validate --strict` 실패 — design E7). 내용·표식 구획은 그대로다.
- **A9 이 저장소의 `.claude/settings.json`:** 레거시 install.sh가 복사하는 원본이자 이 저장소 개발 권한이므로 남긴다. `Bash(sdd-openspec:*)`를 더한다.
- **A10 메인 spec 경로 치환 예외:** 일괄 치환에서 아래는 그대로 둔다. 둘 다 플러그인 전환 뒤에도 실제로 남는 **사용자 프로젝트 쪽 경로**이기 때문이다.
  - `.claude/settings.local.json`
  - `sdd-install-script`·`init-sdd-skill` spec 안의 **설치 대상 프로젝트** 경로(`<대상>/.claude/agents` 등)
- **A11 code-explorer 호출 제한(F5):** 도구 수준 강제가 불가능하다고 확인됐다. ①에서 보류한 항목은 "글로 된 규칙으로 유지, 도구 수준 강제 불가(F5)"로 마무리한다. 요구사항 변경은 없다.
- **A12 skills: 항목 표기(F2):** 에이전트 frontmatter `skills:`는 접두사 없는 `sdd-rules`, `sdd-sync`를 그대로 둔다. 레거시 설치(`.claude/skills/`)와 플러그인 양쪽에서 같은 글자로 동작한다.

## Capabilities

### New Capabilities
- `distribution/sdd-plugin`: 플러그인 매니페스트·마켓플레이스·표준 레이아웃(`agents/`, `skills/`, `hooks/`, `bin/`), 에이전트 이름 `sdd:` 접두사와 레거시 대비 규칙, 개발용 `--plugin-dir` 실행, validate 두 명령 통과, 이 저장소 지침 파일은 루트가 아닌 `.claude/CLAUDE.md`
- `distribution/openspec-cli-wrapper`: `bin/sdd-openspec`이 고정 버전 1.14.1을 실행한다. 지시문은 래퍼를 우선 쓰고, 전역 1.14.1 이상이면 허용한다
- `distribution/session-start-hook`: `/sdd:init`이 남긴 표식 `openspec/.sdd`가 있을 때만 지휘 규칙과 점검 결과를 주입하고, 없으면(`openspec/`만 있어도) 아무것도 출력하지 않는다. 점검 항목, 훅의 실행 시간 제약(npx 금지), README의 끄는 법도 다룬다
- `distribution/sdd-init-command`: `/sdd:init` — 최소 init(`--tools none`), 스택·명령 감지로 context 초안 쓰고 확인받기, 기본 브랜치 감지, 권한 목록 제시 후 동의 시 `.claude/settings.local.json`에만 기록, 공유 `.claude/` 불변

### Modified Capabilities
- `distribution/sdd-install-script`: 바뀌는 요구사항은 아래와 같다.
  - "제품 7종을 깔아야 한다"에서 agent-model-tier를 뺀다
  - 원본 위치를 `agents/`·`skills/`로 바꾼다
  - "플러그인으로 이전" 안내를 넣는다
  - "설치 안내는 README 한 곳"을 플러그인 설치와의 관계에 맞춘다
  - "CLAUDE.md 조각의 원본은 한 벌" — 원본 파일을 `.claude/CLAUDE.md`로
  - "이미 있는 파일을 덮어써서는 안 된다" — 건너뜀 안내의 원본 경로가 실제로 있는 경로여야 한다
- `distribution/init-sdd-skill`: 바뀌는 요구사항은 아래와 같다.
  - 링크 대상에서 agent-model-tier를 뺀다
  - 원본 경로를 `agents/`·`skills/`로 바꾼다
  - 원본 탐색 조건과 조각 원본을 `.claude/CLAUDE.md`로 바꾼다
  - 플러그인 이전 안내를 넣는다
  - 스킬 위치가 이 저장소 전용(플러그인 밖)이 된다
- `agent-instructions/code-explorer-invocation`: 등급 관리 주체 문구(agent-model-tier)를 정리하고, 부르는 이름을 `sdd:code-explorer`로 바꾸며 레거시 대비 규칙을 넣는다. 도구 수준 강제 불가(F5)를 근거로 남긴다
- `agent-instructions/code-explorer-role`: `model:` 한 줄 요구의 근거(agent-model-tier)와 README 반영 문구 중 agent-model-tier 부분을 정리한다
- `agent-instructions/shared-pipeline-rules`: 주입 확인 시나리오를 플러그인 프로세스(`--plugin-dir`) 기준으로 바꾸고, openspec 호출 표기 규칙(A1)과 에이전트 이름 규칙(A2)이 sdd-rules 한 곳에 있다는 요구를 더한다
- `distribution/agent-model-tier`: **은퇴.** 요구사항 7개 전부 REMOVED, `.openspec.yaml`에 `retire_capabilities: true`.
  은퇴는 사용자 명시 결정이다(2026-10-08 "agent-model-tier 스킬 — 없앰", 상위 `plugin-lite-sdd-distribution/decision.md`)
- `process/field-validation-record`: 요구사항 2개 MODIFIED — `evals/README.md`가 "전환 전에는 실행할 수 없다"를 적어야 한다는 MUST를 "플러그인 루트에서 실행한다"로,
  "`evals/results/`가 없어야 한다"를 "추적되지 않고 `.gitignore`가 무시한다"로 바꾼다. 요구사항 헤더와 시나리오 이름은 원문 그대로 둔다

경로만 낡는 나머지 메인 spec은 델타를 만들지 않는다. sync 때 decision 핵심 결정 4-1이 허용한 **플러그인 루트 기준 상대 경로**로 일괄 치환한다(design D12, 예외는 A10).
같은 치환에서 `analyzer-option-generation` 시나리오의 `Agent(subagent_type: "analyzer", ...)` 한 조각을 `sdd:analyzer`로 바꾼다(orchestra 호출 이름과 맞춤).
그 spec이 순서 문서로 가리키는 이 저장소 `CLAUDE.md` 두 곳도 `.claude/CLAUDE.md`로 바꾼다(design D12 (b3)).

## Impact

- 새 파일: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `bin/sdd-openspec`, `bin/sdd-init`, `hooks/hooks.json`(+ 훅 스크립트), `skills/init/SKILL.md`, 이 저장소의 훅 표식 `openspec/.sdd`
- 이동(마지막 작업): `.claude/agents/*.md` → `agents/`, `.claude/skills/{orchestra,sdd-rules,sdd-sync}` → `skills/`, `CLAUDE.md` → `.claude/CLAUDE.md`
- 삭제: `.claude/skills/agent-model-tier/`(되돌릴 수 없는 일 — 오케스트레이터가 **정리 모드** worker를 따로 불러 프롬프트에 경로를 글자 그대로 싣는다)
- 수정:
  - `skills/orchestra/SKILL.md`(subagent_type 18곳)
  - sdd-rules
  - 에이전트 지시문의 openspec 예시 약 73곳
  - `install.sh`, `.claude/skills/init-sdd/SKILL.md`, `.claude/settings.json`, `README.md`, `CLAUDE.md`, `.gitignore`, `evals/README.md`
- 메인 spec: 위 델타 + sync 때 경로 일괄 치환(치환 전 152회)
- 외부 의존: Node/npx, npm 레지스트리(`@fission-ai/openspec@1.14.1`), Claude Code 플러그인 시스템(2.1.294에서 확인)
- 개발 방식: 이동 뒤 이 저장소는 `claude --plugin-dir .`로만 에이전트가 로드된다. README 안내를 이동보다 먼저 쓴다
