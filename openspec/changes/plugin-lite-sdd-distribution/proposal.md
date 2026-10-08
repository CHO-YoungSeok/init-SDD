## Why

목표는 "어느 프로젝트에든 OpenSpec 기반 SDD 파이프라인을 빠르게 적용"하는 것이다.
지금은 그게 느리고 무겁다.

- 설치가 세 갈래다 (install.sh 복사, init-sdd 심볼릭 링크, 수동 cp). 어느 것도 한 줄이 아니다.
- 지시문이 2,821줄이다 (에이전트 8개 1,679줄 + orchestra 459줄 + init-sdd 540줄 + agent-model-tier 143줄, analyzer 실측).
  같은 규칙(RESULT 한 줄 형식, archive/push 승인 규칙, Edit 부분 수정 규칙, store 전달)이 에이전트마다 되풀이된다 (약 250줄).
- 작은 일에도 designer가 필요하다. tasks.md를 designer만 만들기 때문이다.
- OpenSpec 스킬 6개를 `openspec init`이 깔아 주는데, 이 파일들이 디스크에서 사라져 파이프라인이 깨진 일이 있었다.
  (`openspec init --tools claude`로 복구했고 `openspec update`는 "No configured tools found"로 실패했다.)
- 지시문끼리 어긋나는 곳이 이미 확인됐다 (아래 "함께 고치는 불일치").

사용자가 1안(플러그인 전면 전환 + 자기완결)을 골랐다. 결정 내용은 `decision.md`에 있다.

## 이 change의 역할: 하위 change 4개를 묶는 상위 기록

이 change는 **코드·지시문을 직접 고치지 않는다.** 일을 4개 하위 change로 나누고,
각 하위 change가 preparer부터 정식 경로로 실제 수정을 한다. 이 change는 그 4개가 모두 archive되면 끝난다.

**순서: ① → ④ → ② → ③. 병행 금지.** 앞 change가 archive된 뒤 다음 change를 시작한다.
(①이 먼저여야 ②의 diff가 깨끗하고, ④가 ② 앞이면 줄이기 전 기준선을 잴 수 있고,
②가 이름·경로 참조를 모아 두면 ③이 작아진다.)

| 순서 | 하위 change | 선행 조건 | 만지는 파일 | capability |
|---|---|---|---|---|
| ① | `fix-doc-inconsistencies` | 없음 | `.claude/agents/code-explorer.md`, orchestra 에이전트 표 1줄, `.claude/agents/reviewer.md` 설명, `/tmp` → `mktemp` (`regression-verifier.md`, `init-sdd/SKILL.md`, README), `README.md:85`, `.agents/` 안내 | MOD `agent-instructions/code-explorer-role`, `agent-instructions/code-explorer-invocation`, `distribution/init-sdd-skill` |
| ④ | `add-field-validation-record` | ① archive | `docs/field-validation.md`(새), `evals/` 사례 폴더 뼈대(새) | ADD `process/field-validation-record` |
| ② | `lite-default-path-and-shared-rules` | ④ archive (줄이기 전 기준선을 ④ 양식으로 기록해 둠) | 에이전트 8개, orchestra, `.claude/skills/sdd-rules/`(새), `.claude/skills/sdd-sync/`(새) | ADD `agent-instructions/shared-pipeline-rules`, `agent-instructions/lite-default-path` / MOD `agent-instructions/skill-tool-invocation-rationale` 외 요구사항이 실제로 바뀌는 것 |
| ③ | `convert-to-plugin` | ② archive | `.claude-plugin/plugin.json`·`marketplace.json`(새), `agents/`·`skills/` 이동(마지막 작업), `hooks/`(새), `bin/sdd-openspec`(새), `/sdd-init` 스킬(새), `.claude/skills/agent-model-tier/` 삭제, `README.md`, `install.sh`, `CLAUDE.md` | ADD `distribution/sdd-plugin`, `distribution/openspec-cli-wrapper`, `distribution/sdd-init-command` / MOD `distribution/sdd-install-script`, `distribution/init-sdd-skill` / REMOVED `distribution/agent-model-tier` (`retire_capabilities: true`) |

## What Changes

이 change 자체가 바꾸는 것: 계획 기록(`decision.md`, 이 proposal, `tasks.md`)뿐이다. specs 델타는 없다 (`skip_specs: true`).

하위 change들이 합쳐서 바꾸는 것:

**① `fix-doc-inconsistencies` — 함께 고치는 불일치 6건**
- `code-explorer.md`: frontmatter는 "7개", 본문 12행은 "6개".
- orchestra 표는 analyzer를 "산출물 안 씀"이라 하는데, `analyzer.md`는 analysis.md를 쓴다.
- reviewer는 "읽기 전용"인데 Edit 도구를 가진다 (재리뷰 때 review.md 수정용 → 설명 문구를 고친다).
  7개 에이전트가 Agent 도구를 가지지만 code-explorer만 부를 수 있다는 규칙이 도구 수준으로 강제되지 않는다 (③ 실험 결과에 따라 처리, ①에서는 보류 사유 기록).
- 커밋 ca0e83b 메시지와 README:85의 "디스크엔 남아 있다" 서술이 실제와 달랐다.
- `.agents/skills/claude-handoff/`: 지우지 않고 README에 "SDD와 무관" 안내만 남긴다.
- `/tmp` 하드코딩 경로를 `mktemp` 로 바꾼다.

**④ `add-field-validation-record` — 실전 검증 준비**
- 직접 작업과 SDD 작업을 같은 항목(품질 / 소요 시간 / 토큰)으로 기록하는 표 양식.
- `claude plugin eval` 사례 폴더 뼈대(최소). 실제 측정 실행은 범위 밖.

**② `lite-default-path-and-shared-rules` — 경량화**
- 기본 경로: orchestra + worker + reviewer + 커밋 관문 + proposal / tasks / review 기록.
  tasks.md는 preparer가 쓴다. 동작이 바뀌면 preparer가 작은 specs 델타도 쓰고, 안 바뀌면 `skip_specs: true`.
- 큰 작업 판정(CLI design 조건 4가지 + 분석 요청)일 때만 analyzer / designer를 켠다. preparer가 RESULT에 `size=작음|큼`.
  regression-verifier는 실행 코드 + 테스트 명령이 있을 때만. 경량 경로는 reviewer가 테스트 1회.
- 반복 규칙을 `sdd-rules` 스킬 한 곳으로 모으고 frontmatter `skills:` 로 주입한다.
- 스캐폴드 SKILL.md 의존 제거: `openspec instructions` 만 따르고, sync 절차만 `sdd-sync` 스킬로 내장. explore 제외.

**③ `convert-to-plugin` — 플러그인 전환**
- 플러그인 이름 `sdd`. 저장소 루트 = 플러그인 루트. `.claude-plugin/marketplace.json` 으로 배포.
- `bin/sdd-openspec` = `npx -y @fission-ai/openspec@1.14.1`.
- 조건부 SessionStart 훅 (`[ -d openspec ]` 일 때만 지휘 규칙 주입) — CLAUDE.md 미로드 대체.
- `/sdd-init`: `openspec init`, `config.yaml` context 초안, 기본 브랜치 감지, 추가할 권한 목록을 보여주고 동의 시 `settings.local.json` 에 기록.
- agent-model-tier 스킬과 spec 삭제.
- install.sh / init-sdd는 "플러그인으로 이전" 안내만 추가 (제거는 실전 검증 뒤 다음 change).
- 메인 spec `.claude/` 경로 94곳: decision.md "핵심 결정 4" 규칙대로 처리 (요구사항이 바뀌는 capability만 델타, 단순 경로 치환은 ③ sync 때 일괄).

**BREAKING (③):** 에이전트 이름이 `sdd:<agent>` 로 바뀌고 설치 방식이 플러그인으로 바뀐다. agent-model-tier 스킬이 없어진다.

## 받아들일 조건 → 담당 하위 change

| # | 받아들일 조건 | 담당 |
|---|---|---|
| 1 | 새 프로젝트에서 플러그인 설치 두 줄(`/plugin marketplace add`, `/plugin install`)과 `/sdd-init` 한 번으로 파이프라인을 시작할 수 있다 (실측 절차를 문서로 남긴다) | ③ |
| 2 | 별도 `npm i -g openspec` 없이 `sdd-openspec` 래퍼로 고정 버전(1.14.1) OpenSpec이 실행된다 (`sdd-openspec --version`으로 확인) | ③ |
| 3 | OpenSpec 스캐폴드 SKILL.md 6개가 없어도 파이프라인이 돈다 | ② |
| 4 | 기본 경로(orchestra + worker + reviewer + 커밋 관문 + proposal/tasks/review 기록)로 작은 작업 하나를 끝까지 돌릴 수 있고, tasks.md를 누가 만드는지가 정해져 있다 | ② |
| 5 | analyzer / designer / regression-verifier는 큰 작업 조건에서만 켜진다는 규칙이 orchestra에 한 곳으로 적혀 있다 | ② |
| 6 | 반복 규칙(RESULT 형식, 승인 필요 작업, Edit 부분 수정, store 전달)이 공용 문서 한 곳에만 있고, `wc -l` 지시문 총 줄 수가 2,821줄보다 줄었다. 에이전트당 약 100줄은 목표이며 달성 못 하면 이유를 보고한다 | ② (③ 뒤 agent-model-tier 삭제분까지 포함해 최종 확인) |
| 7 | "함께 고치는 불일치" 6건이 각각 고쳐졌거나 보류 사유가 적혀 있다 (grep으로 대조) | ① (도구 수준 강제 항목은 ③ 실험 결과로 마무리) |
| 8 | 플러그인 제약(permissions 배포 불가, CLAUDE.md 미로드)에 대한 대안이 정해져 있고, 사용자가 해야 할 권한 설정이 `/sdd-init` 또는 문서에 안내돼 있다 | ③ |
| 9 | 측정 양식이 있어서, 직접 작업과 SDD 작업을 같은 항목(품질 / 소요 시간 / 토큰)으로 기록할 수 있다 | ④ |
| 10 | 각 하위 change의 `openspec validate "<이름>" --strict` 종료코드 0, `bash -n install.sh` 통과, 마크다운 frontmatter / 코드펜스 무결성 확인. 이 상위 change도 `openspec validate "plugin-lite-sdd-distribution" --strict` 종료코드 0 | ①④②③ 각자 + 이 change |

## 공식 문서로 확인된 플러그인 제약 (③의 전제)

- 플러그인 `settings.json`은 `agent`, `subagentStatusLine` 키만 적용된다. **permissions allow/deny는 배포할 수 없다.**
- 플러그인 루트의 CLAUDE.md는 로드되지 않는다.
- 플러그인 에이전트 frontmatter에서 `hooks` / `permissionMode` / `mcpServers`는 무시된다. `model` / `tools` / `disallowedTools` / `skills` 등은 지원된다.
- 본문에서 `${CLAUDE_PLUGIN_ROOT}`는 치환되지만 Bash 환경변수로는 없다. 상태 저장은 `${CLAUDE_PLUGIN_DATA}`.
- 버전은 plugin.json `version`으로 고정한다. 서드파티 마켓플레이스는 자동 업데이트가 기본 꺼짐.
- 자체 마켓플레이스(GitHub 저장소)는 심사가 없다. 공식 마켓플레이스 등록의 심사 여부는 **미확인**.
- 그 밖의 미확인 7개는 ③의 첫 작업에서 `claude --plugin-dir` 실험으로 확인한다 (decision.md "핵심 결정 5").

## 범위 안 / 범위 밖

범위 안 (하위 change들이 나눠 맡음):
- 1안에 따른 지시문 / 플러그인 구조 / 스킬 / 훅 / 문서 변경
- 확인된 불일치 수정
- 측정 방법 + 기록 양식 작성

범위 밖 (이번에 안 한다):
- **실제 프로젝트에서 작업 3~5건을 돌려 측정하는 일 자체** (양식만 만든다)
- install.sh / init-sdd 제거 (이전 안내만. 제거는 실전 검증 뒤 다음 change)
- 공식 마켓플레이스 등록 신청
- OpenSpec CLI 자체의 개선 / 포크
- 에이전트의 업무 로직(무엇을 검사하는지)을 새로 설계하는 일 (중복 제거와 분리만 한다)

## Capabilities

이 change 자체는 spec을 바꾸지 않는다 (`.openspec.yaml` 에 `skip_specs: true`). spec 변경은 위 표대로 하위 change가 각자 델타로 담당한다.

### New Capabilities
(없음 — 하위 change ④②③가 담당)

### Modified Capabilities
(없음 — 하위 change ①②③가 담당)

## Impact

- 이 change: `openspec/changes/plugin-lite-sdd-distribution/` 안의 계획 기록만.
- 하위 change 전체: `.claude/agents/*.md` 8개, `.claude/skills/orchestra`, `init-sdd`, `agent-model-tier`(삭제),
  새 `.claude-plugin/`, `bin/`, `hooks/`, `docs/`, `evals/`, 공용 규칙·sync 스킬, `install.sh`, `README.md`, `CLAUDE.md`, `.gitignore`, 메인 spec 14개.
- 외부 의존: Node / npx, `@fission-ai/openspec@1.14.1`, Claude Code 플러그인 시스템.
- 겹치던 활성 change 5개(add-code-explorer-agent 등)는 커밋 4ef15aa에서 이미 archive됐다. 남은 충돌 없음.
