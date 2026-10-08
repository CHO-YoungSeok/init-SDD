## Context

동기와 범위는 proposal.md("Why", "What Changes")와 상위 change `plugin-lite-sdd-distribution`의 decision.md(1안, 핵심 결정 2~5)를 본다.
요구사항은 이 change의 specs 델타가 정본이다. 이 문서는 "어떻게"만 적는다.

지금 상태 (2026-10-08 실측):
- 에이전트 8개는 `.claude/agents/`, 제품 스킬은 `.claude/skills/{orchestra,sdd-rules,sdd-sync,agent-model-tier,init-sdd}/`.
- orchestra의 `subagent_type` 18줄, sdd-rules의 code-explorer 호출 1곳은 접두사 없는 이름이다.
- 지시문의 openspec 실행 예시(D6 정규식, 하위명령 12개 기준, 2026-10-09 재측정): 에이전트 53줄(analyzer 2, designer 13, finalizer 10,
  preparer 19, reviewer 6, worker 3) + orchestra 9 + sdd-rules 6 + sdd-sync 5 = **73줄**. 하위명령 7개로만 세도 같은 값이다.
- 전역 `openspec`은 1.12.0, `npx -y @fission-ai/openspec@1.14.1`은 1.14.1. Claude Code 2.1.294.
- 메인 spec의 `.claude/` 출현: `grep -o` 152회, 줄 기준 126줄 (18개 spec 중 16개).
- preparer가 scratchpad canary로 잰 F1~F13은 proposal.md 표에 있다. 이 설계는 그 값을 근거로 쓴다.

designer가 추가로 잰 것 (scratchpad 사본, 이 문서의 결정 근거):
- **E1** 델타는 `openspec validate convert-to-plugin --strict`를 1.12.0과 1.14.1 **둘 다** exit 0으로 통과한다.
  1.14.1은 ADDED 요구사항 본문이 500자를 넘으면 `--strict`에서 실패시킨다. 그래서 긴 요구사항을 나눴다.
- **E2** MODIFIED 블록에서 **시나리오 이름을 바꾸면 validate가 막는다**
  (`omits scenario(s) the current spec still has: "설치 확인이 7종을 본다"`). 그래서 "7종", "5종"이 든
  시나리오 이름은 그대로 두고 본문만 고쳤다(본문에 그 사실을 한 줄 적었다).
- **E3** 저장소 사본에서 `npx -y @fission-ai/openspec@1.14.1 archive convert-to-plugin --yes`를 바로 돌리면
  **exit 1**이다. `agent-model-tier` 메인 spec의 등급 표 줄을 CLI가 "설명할 수 없는 내용"으로 보고 은퇴를 거부한다.
  메인 spec `agent-model-tier`를 먼저 지운 사본(= sdd-sync가 은퇴를 끝낸 상태)에서는 archive가 exit 0이고,
  두 번째 archive도 "Specs already in sync"로 exit 0이다. → **은퇴는 finalizer의 sync가 해야 한다.** archive에 맡기면 막힌다.
- **E4** 메인 spec에 대해 `openspec validate --all --strict`는 1.12.0에서 exit 0, 1.14.1에서 **exit 1**이다
  (이 change와 무관한 기존 메인 spec 9개의 "Requirement text is very long" 경고). 이 change가 만든 문제가 아니다.
- **E5** 사본에서 델타 반영 + 아래 D12 치환 표를 적용하면 `.claude/` 출현이 152 → 149(델타 반영 뒤) → **80회 / 63줄**(치환 뒤)이 된다.
  메인 spec에서 `agent-model-tier` 글자는 0건이 된다. (이 값은 첫 설계 때 사본 실측이다. 델타가 늘었으므로 finalizer가 대조할
  기대값은 묶음 9.12가 verification.md에 새로 남기는 실측값이다.)
- **E6** (2026-10-09, scratchpad) 훅 표식 `openspec/.sdd`를 둔 프로젝트에서 1.14.1 `init`·`new change`·`list`·`context`·`status --json`
  모두 exit 0, 1.12.0 `list` exit 0 — CLI는 `openspec/` 바로 아래의 이 파일을 무시한다.
- **E7** (2026-10-09, scratchpad, Claude Code 2.1.294) 저장소 파일(추적 + 미추적, 무시 제외)을 사본에 옮기고 묶음 8의 삭제·이동을 흉내 낸 뒤
  `claude plugin validate . --strict`와 `claude plugin validate .claude-plugin/plugin.json --strict`를 돌렸다.
  - 루트에 `CLAUDE.md`가 있을 때: 둘 다 **exit 1**. 경고 한 건 `root: CLAUDE.md at the plugin root is not loaded as project context. To ship context with your plugin, use a skill (skills/<name>/SKILL.md) instead.`
    (`--strict treats warnings as errors`). 관문 1.2 시험 플러그인에는 `CLAUDE.md`가 없어 못 잡았다.
  - `mv CLAUDE.md .claude/CLAUDE.md` 뒤: 둘 다 **exit 0**(`✔ Validation passed`), `--strict` 없는 `validate .`도 exit 0이고 경고 0건 —
    `.claude/CLAUDE.md`는 다른 경고를 내지 않는다.
  - `git check-ignore .claude/CLAUDE.md` → 1(무시되지 않음, 커밋 대상).
  → 오케스트레이터 결정대로 이 저장소의 프로젝트 지침 파일을 `.claude/CLAUDE.md`로 옮긴다(D15). 경고 허용 예외는 만들지 않는다.

## Goals / Non-Goals

**Goals:**
- 저장소 루트를 플러그인 `sdd`로 만들고, 기존 설치 방식(`install.sh`, `init-sdd`)도 새 경로에서 계속 돌게 한다.
- 파일 이동을 맨 뒤로 미뤄, 이 세션과 기존 개발 방식이 중간에 깨지지 않게 한다.
- 메인 spec의 경로 표기를 sync 한 번에 기계적으로(여러 번 돌려도 같은 결과로) 바꾼다.

**Non-Goals:**
- 에이전트 업무 로직 수정. 바꾸는 것은 호출 이름, openspec 명령 글자, 경로 언급뿐이다.
- 메인 spec의 긴 요구사항 경고(E4) 정리 — ⑥(spec 전수 검수)의 일이다.
- SessionStart 훅 지시를 메인 세션이 얼마나 잘 따르는지 측정 — 실전 검증 범위다.

## Decisions

### D1. 플러그인 골격 (새 파일)

`.claude-plugin/plugin.json`:
```json
{
  "name": "sdd",
  "version": "0.1.0",
  "description": "OpenSpec 위에서 도는 SDD(사양 주도 개발) 파이프라인 — 오케스트레이터와 서브에이전트 8개, 지휘·공용 규칙·sync·초기화 스킬",
  "author": { "name": "석" }
}
```
`.claude-plugin/marketplace.json`:
```json
{
  "name": "sdd-marketplace",
  "description": "SDD 파이프라인 플러그인(sdd)을 배포하는 마켓플레이스",
  "owner": { "name": "석" },
  "plugins": [
    { "name": "sdd", "source": "./", "description": "OpenSpec 위에서 도는 SDD 파이프라인" }
  ]
}
```
- `agents/`, `skills/`, `hooks/hooks.json`, `bin/`은 기본 위치라서 매니페스트에 경로를 적지 않는다(F9에서 그대로 인식됨).
- `author.name`은 `git config user.name` 값(`석`). email은 넣지 않는다(A5).
- 버린 대안: 저장소 하위 폴더(`plugin/`)를 플러그인 루트로 두기 — 지시문 원본이 두 벌이 되거나 심링크가 필요해서 버렸다.

### D2. `bin/sdd-openspec` (새 파일, 실행 권한)

```bash
#!/usr/bin/env bash
# SDD 플러그인 openspec 래퍼 — 사용자 PATH의 openspec 버전과 상관없이 고정 버전을 쓴다.
OPENSPEC_VERSION="1.14.1"
exec npx -y "@fission-ai/openspec@${OPENSPEC_VERSION}" "$@"
```
- `exec`라서 종료코드가 그대로 나온다. 버전 문자열은 이 한 줄에만 둔다.
- `chmod +x`. git이 실행 비트를 기록하는지 `git ls-files -s bin/sdd-openspec`의 `100755`로 확인한다.

### D3. SessionStart 훅 (새 파일 2개)

`hooks/hooks.json`:
```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh\"" } ] }
    ]
  }
}
```
`hooks/session-start.sh` (실행 권한, `set -e`를 쓰지 않는다 — 점검 하나가 실패해도 exit 0이어야 한다):
1. `ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"`. `[ -f "$ROOT/openspec/.sdd" ] || exit 0` — 아무것도 출력하지 않는다.
   `openspec/`만 있고 표식이 없는 프로젝트(openspec을 따로 쓰는 곳)에서도 조용하다(오케스트레이터 결정, 2026-10-09).
2. 지휘 규칙을 그대로 출력한다 (아래 6줄. 8줄 제한 안):
   ```text
   [SDD] 이 프로젝트는 SDD 파이프라인(openspec/)으로 일한다. (sdd 플러그인 SessionStart 훅)
   - 메인 세션은 오케스트레이터다. 사용자와 대화하고 지휘만 한다.
   - 분석·설계·파일 수정·리뷰·커밋은 직접 하지 말고 sdd: 서브에이전트(sdd:preparer, sdd:worker 등)에게 위임한다.
   - 일을 처리해 달라는 요청이 오면 먼저 sdd:orchestra 스킬을 불러 그 절차를 따른다.
   - 분석·방안 비교를 요청받았을 때만 sdd:analyzer를 넣고, 사용자가 방안을 고르게 한다.
   - 지휘 절차의 본문은 sdd:orchestra 스킬에 있다. 이 훅은 요약만 넣는다.
   ```
3. 점검 (npx·네트워크 금지. `command -v`와 `grep`만):
   - `command -v node` 와 `command -v npx`가 둘 다 있어야 한다. 없으면 `[SDD 점검] node/npx가 PATH에 없다 — sdd-openspec이 돌지 않는다.`
   - `grep -qs 'sdd-openspec' "$ROOT/.claude/settings.json" "$ROOT/.claude/settings.local.json"`가 실패하면
     `[SDD 점검] 권한에 Bash(sdd-openspec:*)가 없다 — /sdd:init 으로 추가할 수 있다.`
   - `for t in "$ROOT"/openspec/changes/*/tasks.md` (이 글롭은 `archive/<이름>/`으로 내려가지 않는다. 그래도
     `case "$t" in */changes/archive/*) continue;; esac`로 한 번 더 막는다): `grep -qE '^[[:space:]]*- \[[xX]\]'`가 맞고
     `grep -qE '^[[:space:]]*- \[ \]'`가 없으면 `[SDD 점검] 끝났지만 archive 안 된 change: <디렉터리 이름>`.
   - 문제 줄이 하나도 없으면 `[SDD 점검] 이상 없음`.
4. `exit 0`.
- 직접 실행 검증: `CLAUDE_PROJECT_DIR=<dir> bash hooks/session-start.sh; echo "exit=$?"`, 그리고 `cd <dir> && bash <repo>/hooks/session-start.sh`.

**훅 표식 `openspec/.sdd`** (새 개념):
- 위치를 `openspec/` 안에 둔 이유: openspec을 쓰는 프로젝트라야 의미가 있고, 커밋 가능한 작은 파일이라 팀이 같은 저장소를 쓰면
  플러그인을 깐 팀원에게 함께 켜진다. 지우면 꺼진다. CLI는 이 파일을 무시한다(E6).
- 버린 대안: `config.yaml` 안의 키 — openspec이 모르는 키를 경고할 수 있고(`sdd-openspec context`의 Warning 확인이 깨질 위험),
  `/sdd:init`이 사용자가 고친 YAML을 다시 써야 한다. `.claude/` 안의 파일 — 공유 `.claude/`를 건드리지 않는다는 `/sdd:init` 계약과 부딪힌다.
- 내용 (글자 그대로. 훅은 내용을 보지 않고 `-f`만 본다):
  ```text
  # sdd 플러그인 표식 — 이 파일이 있으면 sdd 플러그인의 SessionStart 훅이 지휘 규칙과 점검 결과를 넣는다.
  # 이 프로젝트에서 끄려면 이 파일을 지운다. /sdd:init 이 만든다. 커밋하면 플러그인을 깐 팀원에게도 켜진다.
  ```
- `bin/sdd-init setup`이 만든다(D4). 이 저장소에도 같은 내용으로 둔다(tasks 2.6) — 이 저장소도 SDD로 개발하기 때문이다.

### D4. `/sdd:init` — 스킬 문서 + 실행 파일 하나

비대화 단계를 종료코드로 확인할 수 있어야 해서(spec `sdd-init-command`) 판단 없는 일은 실행 파일에 넣고,
스킬 문서는 "보여 주고 묻고 동의하면 기록 명령을 돌린다"만 맡는다.

`bin/sdd-init` (새 파일, 실행 권한, bash). 대상은 현재 디렉터리. 플러그인 루트는 `$(cd "$(dirname "$0")/.." && pwd)`.

| 하위 명령 | 하는 일 | 파일 변경 |
|---|---|---|
| `sdd-init setup` | git 저장소·커밋 확인(없으면 rc≠0과 안내). `openspec/config.yaml`이 있으면 "건너뜀". 없으면 `"$PLUGIN_ROOT/bin/sdd-openspec" init --tools none --no-animation`. 이어서 `openspec/.sdd`가 없으면 D3의 두 줄로 만들고, 있으면 "표식 있음". 두 번 돌려도 결과가 같다 | `openspec/` 3개 (F10) + `openspec/.sdd` |
| `sdd-init detect` | 스택·테스트·빌드·기본 브랜치를 감지하고 context 초안(YAML)을 stdout에 낸다 | 없음 |
| `sdd-init write-context` | `config.yaml`에 최상위 `^context:`가 있으면 쓰지 않고 rc=2 + "기존 값과 비교해 직접 고른다". 없으면 `detect` 초안을 파일 끝에 덧붙인다(앞에 빈 줄 하나, 키는 들여쓰기 없이) | `openspec/config.yaml` |
| `sdd-init permissions` | `$PLUGIN_ROOT/.claude/settings.json`의 `permissions.allow`를 한 줄씩 내고, 이어서 `참고: sdd-openspec 은 첫 실행 때 npm 레지스트리에서 @fission-ai/openspec@1.14.1 을 받는다.` 한 줄, 그리고 `git check-ignore -q .claude/settings.local.json` 결과를 알린다 | 없음 |
| `sdd-init write-permissions` | `.claude/settings.local.json`에 빠진 항목만 더한다. 파일이 없으면 만든다. 기존 파일이 JSON으로 안 읽히면 rc≠0으로 멈추고 쓰지 않는다 | `.claude/settings.local.json`만 |

- JSON 읽기·합치기는 `node -e`로 한다(node는 래퍼 때문에 어차피 필요하다). `jq`에 기대지 않는다.
- 감지 규칙 (`detect`): `package.json` → 잠금 파일로 npm/pnpm/yarn을 고르고 `scripts.test`·`scripts.build`가 있으면
  `<pm> test`, `<pm> run build`; `pyproject.toml`/`requirements.txt` → Python, `pytest`(tests/ 또는 pyproject에 pytest가 있을 때);
  `go.mod` → `go test ./...`, `go build ./...`; `Cargo.toml` → `cargo test`, `cargo build`; `pom.xml` → `mvn test`, `mvn package`;
  `build.gradle*` → `./gradlew test`, `./gradlew build`; `Makefile`의 `test:`·`build:` 대상 → `make test`, `make build`.
  못 찾은 칸은 `확인 필요`로 쓴다.
- 기본 브랜치: `git symbolic-ref --quiet --short refs/remotes/origin/HEAD`(앞의 `origin/` 제거) → `refs/heads/main` → `refs/heads/master`
  → `git branch --show-current`. 어느 단계로 정했는지를 괄호로 붙인다.
- 초안 모양:
  ```yaml
  context: |
    기술 스택: <감지값 또는 확인 필요>
    테스트 명령: <감지값 또는 확인 필요>
    빌드 명령: <감지값 또는 확인 필요>
    기본 브랜치: <이름> (<감지 방법>)
  ```

`skills/init/SKILL.md` (새 파일). frontmatter는 `name: init`과 `description:`(부르는 말: "SDD 초기화", "이 프로젝트에 SDD 세팅해줘",
"openspec 시작", "sdd init") 둘뿐, `allowed-tools` 없음. 본문 절차:
1. `sdd-init setup` — 결과를 그대로 보여 준다. 실패하면 안내대로 멈춘다. 표식 `openspec/.sdd`가 훅을 켜고, 커밋하면 팀원에게도
   켜지며, 지우면 꺼진다는 것을 한 줄로 알린다.
2. `sdd-init detect` — 초안을 보여 주고 고칠 곳을 묻는다. **동의를 받은 뒤에만** `sdd-init write-context`.
   rc=2면 기존 `context:`와 초안을 나란히 보여 주고 사용자가 고른 대로 Edit로 고친다. 기록 뒤 `sdd-openspec context`에 `Warning`이 없는지 본다.
3. 기본 브랜치는 2의 초안에 들어 있다. 틀리면 사용자 말대로 고친다.
4. `sdd-init permissions` — 목록과 npm 내려받기 안내 줄을 보여 주고 묻는다. **동의를 받은 뒤에만** `sdd-init write-permissions`.
   `.claude/settings.local.json`이 무시되지 않는다고 나오면 알리기만 한다(공유 `.gitignore`를 고치지 않는다).
5. 마무리 안내: 새 세션이 필요 없다(훅이 다음 세션부터 지휘 규칙을 넣는다). 할 일을 말하면 `sdd:orchestra`가 돈다.
   `.claude/commands/opsx/`, `.claude/skills/openspec-*`는 필요 없다.
- 스킬 문서는 `sdd-init`·`sdd-openspec`를 PATH 이름으로 부른다. 메인 세션 Bash PATH에 플러그인 `bin/`이 붙는지는 1단계 관문(G-PATH)에서 잰다.
  안 붙으면 스킬 문서에서 `"${CLAUDE_PLUGIN_ROOT}/bin/sdd-init"` 꼴로 바꾼다 (F3은 에이전트 본문 치환만 쟀으므로 스킬 본문 치환도 같은 관문에서 잰다).
- 권한 목록의 원본은 `.claude/settings.json` 한 벌(spec). 마켓플레이스 설치본(캐시)에 `.claude/settings.json`이 함께 복사되는지는 관문(G-CACHE)에서 잰다.
- 버린 대안: 모든 단계를 스킬 문서의 셸 블록으로만 두기 — 비대화 단계를 사람 없이 종료코드로 다시 돌릴 방법이 없다.
  `/sdd-init`이라는 이름 — 플러그인 스킬은 `sdd:<디렉터리>`가 되므로 `/sdd:sdd-init`이 된다(A4).

### D5. 에이전트 이름 접두사와 대비 규칙

- orchestra의 18줄 `Agent(subagent_type: "<이름>"` → `Agent(subagent_type: "sdd:<이름>"`. 이름별로 Edit `replace_all`
  (`subagent_type: "worker"` → `subagent_type: "sdd:worker"` 등 7개 이름. `regression-verifier`를 `reviewer`보다 먼저 하지 않아도 된다 —
  따옴표까지 포함한 문자열이라 겹치지 않는다).
- orchestra "절대 규칙" 절의 "또 다른 예외" 문단 **바로 뒤**에 넣을 문단 (글자 그대로):
  ```text
  **에이전트 이름:** 아래 호출 예시는 플러그인 이름 `sdd:<이름>`을 쓴다. 결과가 `Agent type 'sdd:<이름>' not found`이면
  같은 프롬프트로 접두사 없는 `<이름>`을 다시 부르고, 그 세션에서는 계속 접두사 없는 이름을 쓴다.
  기존 설치 방식(`install.sh`, `init-sdd`)으로 깐 에이전트는 접두사 없이 실리기 때문이다.
  이 대비 규칙은 기존 설치 방식을 없애는 change에서 함께 지운다.
  ```
- orchestra 257행 "`.claude/agents/designer.md`가" → "designer 에이전트 파일이".
- sdd-rules "code-explorer 부르기" 절 첫 문장을 다음으로 바꾸고, 절 끝에 대비 규칙 두 줄을 더한다 (절 수는 7개 그대로):
  ```text
  코드베이스나 스펙을 넓게 뒤져야 할 때 `Agent` 도구로 `subagent_type: "sdd:code-explorer"`를 직접 부를 수 있다.
  ...(예시·결과 받기·다른 서브에이전트 금지 문장은 그대로)...
  결과가 `not found`이면 같은 프롬프트로 접두사 없는 `code-explorer`를 다시 부른다 — 기존 설치 방식(`install.sh`, `init-sdd`)으로
  깐 에이전트는 접두사 없이 실린다. 이 대비 규칙은 기존 설치 방식을 없애는 change에서 함께 지운다.
  부를 수 있는 대상을 `tools:` 설정으로 막을 수는 없다(실측) — 이 글 규칙을 지킨다.
  ```
- 에이전트 frontmatter `skills:`는 그대로 둔다(A12, F2).

### D6. openspec 명령 표기 — `sdd-openspec`

- 대상 파일: `.claude/agents/*.md` 8개, orchestra, sdd-rules, sdd-sync (이동 전 경로에서 고친다).
- 바꾸는 것: 실행하라는 뜻의 `openspec <하위명령>` — 하위명령 `status`, `instructions`, `validate`, `new`, `archive`, `list`, `show`,
  `doctor`, `context`, `schemas`, `view`, `--version`. 코드블록과 인라인 코드 모두. 바꾸기 전 줄 수(실측 2026-10-09): 에이전트 53
  (analyzer 2, designer 13, finalizer 10, preparer 19, reviewer 6, worker 3), orchestra 9, sdd-rules 6, sdd-sync 5.
  방법: 파일마다 Edit `replace_all`로 `openspec status` → `sdd-openspec status`처럼 하위명령별로 바꾼다
  (`sed -i`·전체 Write 금지, sdd-rules 규칙). 한 파일에서 같은 하위명령을 두 번 돌리지 않는다(`sdd-sdd-openspec`이 생긴다).
- 그대로 두는 것: sdd-rules의 "`openspec init`이 까는 `openspec-*` 스킬"(사용자 프로젝트의 스캐폴드를 설명하는 말),
  "`allowed-tools: Bash(openspec:*)`", "`openspec` 셸 명령 하나로", 디렉터리 이름 `openspec/`, 산문 속 "openspec 명령" 같은 일반 명사.
- sdd-rules "쓰는 스킬" 절의 "주입되는 스킬" 줄 앞에 넣을 줄 (글자 그대로):
  ```text
  - openspec 명령은 `sdd-openspec`으로 친다(플러그인이 고정 버전 1.14.1을 실행하는 래퍼). PATH의 `openspec`이 1.14.1 이상이면
    (`--version`으로 확인) `openspec`을 그대로 써도 된다. `sdd-openspec`이 PATH에 없으면(기존 설치 방식으로 깐 경우)
    `openspec`을 쓰고 그 버전을 보고서에 적는다.
  ```
  이 줄에는 `openspec --version`처럼 `openspec` 뒤에 공백과 하위명령이 붙은 글자를 쓰지 않는다 — 아래 확인 grep에 걸린다.
  이 줄에는 `not found` 글자를 쓰지 않는다 — sdd-rules에서 `not found`는 "code-explorer 부르기" 절의 대비 규칙 한 줄에만 있어야
  한다(spec `shared-pipeline-rules` ADDED 시나리오, tasks 4.2 확인).
- 확인: `grep -nE '(^|[^-])\bopenspec (status|instructions|validate|new|archive|list|show|doctor|context|schemas|view|--version)'`가
  이 네 묶음에서 0건 (spec `openspec-cli-wrapper` 시나리오와 같은 명령). `grep -c 'sdd-sdd-openspec'` 0건.
- 기존 설치본은 플러그인 `bin/`이 PATH에 없다 → 위 대체 규칙으로 `openspec`을 쓴다. `.claude/settings.json`에는
  `Bash(openspec:*)`를 남기고 `Bash(sdd-openspec:*)`를 바로 뒤에 더한다(A9).

### D7. agent-model-tier 삭제 — 언제, 무엇을

- **근거:** 사용자 명시 결정이다(2026-10-08 "agent-model-tier 스킬 — 없앰", 상위 `plugin-lite-sdd-distribution/decision.md` 16·66행).
  sdd-rules "되돌릴 수 없는 일"의 capability 은퇴·파일 삭제는 이 결정을 승인 근거로 삼는다.
- **이동 묶음(8)의 첫 작업**으로, 이동 전 경로에서 지운다: `git rm -r .claude/skills/agent-model-tier`
  (경로 글자 그대로: `.claude/skills/agent-model-tier/`). git 이력에 남으므로 되돌릴 수 있다.
- worker 지침(worker.md "삭제는 프롬프트가 경로를 글자 그대로 지정한 정리 모드만")에 따라, 이 작업은 **정리 모드 worker를 따로 부른다**
  (`모드: 정리`). 같은 묶음의 이동(`git mv`)은 그 뒤에 정식 모드 worker가 한다.
- 이동 전에 지우는 이유: `git mv` 대상 목록을 세 스킬로 고정할 수 있고, 내용 수정 묶음이 도는 동안에는 파일이 남아 있어
  병렬 worker가 그 파일 유무로 헷갈리지 않는다.
- 오케스트레이터는 이 작업을 맡기는 정리 모드 worker 프롬프트에 위 경로를 **글자 그대로** 실어야 한다(sdd-rules "되돌릴 수 없는 일"의 예외 조건).
  정리 모드는 openspec 명령을 쓰지 않으므로, 끝난 뒤 tasks 8.1 체크는 이어 부르는 정식 모드 worker(8.2 담당)가 확인 명령을 다시 돌려 한다.
- 글자 언급 정리: README, install.sh, init-sdd SKILL.md, 메인 spec(델타·sync). `docs/field-validation.md` 32행의 기준선 서술,
  `openspec/changes/archive/**`, `openspec/changes/plugin-lite-sdd-distribution/**`, 이 change 디렉터리는 예외다.

### D8. install.sh (기존 파일 수정)

- 복사 원본 경로만 바꾼다. 대상 경로는 그대로:
  `copy_if_absent "agents/$agent.md" ".claude/agents/$agent.md"`, `copy_if_absent "skills/orchestra" ".claude/skills/orchestra"`,
  `sdd-rules`, `sdd-sync` 같은 꼴. `.claude/settings.json`은 원본·대상 모두 그대로.
- `agent-model-tier` 복사 줄과 확인 루프의 항목을 지운다. 주석 "우리 스킬 4개" → "우리 스킬 3개 (지휘 + 공용 규칙 + sync 절차)".
  확인 루프의 원본 안내 `$SRC/.claude/skills/$ours` → `$SRC/skills/$ours`.
- `say "init-SDD 설치"` 바로 뒤에 한 줄: `say "  권장 설치는 플러그인이다 — $SRC/README.md 의 '설치' 절. 이 스크립트는 기존 방식으로 남아 있다."`
- "다음 할 일"에 두 줄:
  `플러그인으로 옮기려면: 복사된 .claude/agents 와 .claude/skills/{orchestra,sdd-rules,sdd-sync} 를 지우고 플러그인을 설치해라 ($SRC/README.md).`
  `플러그인과 이 복사본을 함께 두면 같은 에이전트가 두 이름(sdd:<이름>, <이름>)으로 실린다.`
- `[[ "$SRC" == "$DST" ]]` 검사는 그대로. (install.sh는 `BASH_SOURCE`로 원본을 정하므로 원본 탐색 조건이 없다.)
- **(D15 추가) 조각 원본 경로:** 4절의 `$SRC/CLAUDE.md` 다섯 곳(`EXTRACT_CMD`, 존재 검사 `[[ -f ... ]]`과 그 `fail` 문구, `SNIPPET=` 줄, 빈 조각 `fail` 문구)을
  `$SRC/.claude/CLAUDE.md`로 바꾸고, 85행 근처 주석 "이 저장소 CLAUDE.md 의 마커 구획" → "이 저장소 .claude/CLAUDE.md 의 마커 구획"(루트는 플러그인 루트라 CLAUDE.md를 두지 않는다). 대상 쪽 `$DST/CLAUDE.md`(98~113행 근처)는 **바꾸지 않는다** — 설치 결과물은 대상 프로젝트 루트의 `CLAUDE.md`다.
  확인 grep: `grep -c '\$SRC/CLAUDE\.md' install.sh` → 0, `grep -c '\$SRC/\.claude/CLAUDE\.md' install.sh` ≥ 3, `grep -c '\$DST/CLAUDE\.md' install.sh`가 수정 전과 같다.
- **(D8 범위 확장) 건너뜀 안내의 원본 경로:** 지금 결과 절은 `(원본: $SRC/$p)`로 **대상** 상대 경로에 `$SRC/`를 붙인다.
  원본·대상 위치가 갈린 뒤에는 `$SRC/.claude/agents/worker.md`처럼 없는 경로를 안내한다(메인 spec "이미 있는 파일을 덮어써서는 안 된다" 위반).
  고치는 모양 — 원본 상대 경로를 나란한 배열에 함께 담는다:
  - 3절: `SKIPPED=()` 다음 줄에 `SKIPPED_SRC=()`. `copy_if_absent`의 건너뜀 갈래에서 `SKIPPED+=("$2")` 다음에 `SKIPPED_SRC+=("$1")`.
  - 결과 절: `for p in "${SKIPPED[@]}"; do ... (원본: $SRC/$p)` 한 줄을
    `for i in "${!SKIPPED[@]}"; do say "  - ${SKIPPED[$i]}   (원본: $SRC/${SKIPPED_SRC[$i]})"; done`로 바꾼다.
    이 루프는 `${#SKIPPED[@]} -gt 0` 안이라 `set -u`에서 빈 배열 전개 문제가 없다(macOS bash 3.2 포함).
  - 버린 대안: 대상 경로에서 원본 경로를 문자열 치환으로 거꾸로 만들기 — `settings.json`처럼 원본·대상이 같은 항목과 갈리는 항목이 섞여 규칙이 둘이 된다.

### D9. init-sdd 스킬 (기존 파일 수정, 위치 그대로 `.claude/skills/init-sdd/SKILL.md`)

- description: "orchestra·agent-model-tier·sdd-rules·sdd-sync 스킬" → "orchestra·sdd-rules·sdd-sync 스킬".
- 링크 표·초기 이관 `cp`·`ln -s`·exclude 블록·풀기 루프·상태 루프·새 세션 확인 목록·복사로 떨어지는 절차에서 모델 등급 스킬 줄을 지운다.
  "정확히 여섯 개" → "정확히 다섯 개", "여섯" 언급 전부, `.claude/skills/` 안 링크 "네 개" → "세 개".
- 초기 이관 원본: `cp -R "$SRC/agents" ...`, `cp -R "$SRC/skills/orchestra" ...`, `sdd-rules`, `sdd-sync` 같은 꼴. `$SRC/.claude/settings.json`은 그대로.
- 풀기·상태 보기에 한 단계: `.claude/skills/` 아래 링크 중 다섯 목록에 없고 `$P`(개인 저장소)를 가리키는 것을 찾아 알리고, 풀기에서는 그것도
  `rm`으로 링크만 지운다(`[ -L ]`일 때만). 스킬 이름을 글자로 적지 않는다(D7의 grep 0건 조건).
- 앞부분("이 스킬이 무엇인가")에 이전 안내 세 줄: 플러그인이 권장 방식, 설치는 `README.md`, 옮기려면 "풀기"로 링크를 푼 뒤 플러그인 설치.
  링크와 플러그인을 함께 두면 같은 에이전트가 두 이름으로 실린다.
- **(D15 추가) 원본 탐색과 조각 원본:**
  - `원본` 표의 "알아내는 법" 칸: "`install.sh`와 `CLAUDE.md`가 **함께**" → "`install.sh`와 `.claude/CLAUDE.md`가 **함께**".
  - 탐색 루프: `[[ -f "$d/install.sh" && -f "$d/CLAUDE.md" ]]` → `[[ -f "$d/install.sh" && -f "$d/.claude/CLAUDE.md" ]]`.
    스킬 위치 `.claude/skills/init-sdd/`에서 위로 올라가면 저장소 루트에서 걸린다(중간의 `.claude/`에는 `install.sh`가 없다).
  - 그 아래 설명 "`CLAUDE.md`까지 함께 보는 이유는" → "`.claude/CLAUDE.md`까지 함께 보는 이유는".
  - 6단계 첫 문장 "원본 `CLAUDE.md`의 마커 구획에서 뽑는다" → "원본 `.claude/CLAUDE.md`의 마커 구획에서 뽑는다".
  - 6단계 조각 뽑기: `sed ... "$SRC/CLAUDE.md"` → `"$SRC/.claude/CLAUDE.md"`, 빈 조각 안내 "원본 CLAUDE.md 의 마커" → "원본 .claude/CLAUDE.md 의 마커".
  - `$대상/CLAUDE.md`와 대상 쪽 `CLAUDE.md` 언급(추적 판정, skip-worktree, exclude, 풀기, 상태 보기)은 **바꾸지 않는다**.
  - 확인 grep: `grep -c '"\$d/CLAUDE\.md"\|\$SRC/CLAUDE\.md' .claude/skills/init-sdd/SKILL.md` → 0, `grep -c '\$d/\.claude/CLAUDE\.md' ...` → 1, `grep -c '\$SRC/\.claude/CLAUDE\.md' ...` ≥ 1.

### D10. 문서·설정 (기존 파일 수정)

- `README.md`:
  - `## 설치` 맨 앞 표를 세 갈래(플러그인 권장 / 복사 / 링크)로. 새 절 `### 플러그인으로 설치 (권장)`:
    ````text
    /plugin marketplace add CHO-YoungSeok/init-SDD
    /plugin install sdd@sdd-marketplace
    ````
    그 뒤 새 프로젝트에서 `/sdd:init`(초기화) 한 번. 로컬 복제본이면 `marketplace add <경로>`.
  - 같은 절 안에 짧은 단락 넷:
    - **훅 켜기·끄기:** `/sdd:init`이 만드는 표식 `openspec/.sdd`가 있는 프로젝트에서만 SessionStart 훅이 지휘 규칙을 넣는다.
      표식을 커밋하면 같은 저장소에서 플러그인을 깐 팀원에게도 켜진다. 그 프로젝트에서 끄려면 표식을 지운다.
      모든 프로젝트에서 끄려면 `/plugin disable sdd`.
    - **업데이트:** `claude plugin marketplace update sdd-marketplace` → `claude plugin update sdd@sdd-marketplace` → Claude Code 재시작
      (CLI `--help`로 확인한 명령, 2.1.294). 새 판을 낼 때는 `plugin.json`의 `version`을 올린다.
    - **팀 배포:** 프로젝트 `.claude/settings.json`에 `extraKnownMarketplaces`(이름 `sdd-marketplace`, 출처 GitHub `CHO-YoungSeok/init-SDD`)와
      `enabledPlugins`(`"sdd@sdd-marketplace": true`)를 넣으면 팀원이 저장소를 신뢰할 때 설치를 안내받는다. JSON 예시 한 블록:
      ```json
      {
        "extraKnownMarketplaces": {
          "sdd-marketplace": { "source": { "source": "github", "repo": "CHO-YoungSeok/init-SDD" } }
        },
        "enabledPlugins": { "sdd@sdd-marketplace": true }
      }
      ```
      (designer가 실측하지 못한 모양이다. 묶음 7은 이대로 쓰고, 묶음 9.6이 격리 `CLAUDE_CONFIG_DIR` 시험 프로젝트에 이 두 키를 넣어
      `claude -p` init 이벤트의 plugins 목록이나 `claude plugin list`로 인식되는지 본다. 안 되면 verification.md에 적고 보고한다 — README 수정은 재작업으로.)
    - **Windows:** 훅과 `bin/` 실행 파일이 bash 스크립트라 bash(Git Bash 또는 WSL)가 필요하다. 한 줄.
  - 새 절 `### 기존 방식에서 플러그인으로 옮기기`: 복사본은 `.claude/agents`, `.claude/skills/{orchestra,sdd-rules,sdd-sync}`와
    남은 모델 등급 스킬 디렉터리를 지운 뒤 설치, 링크본은 `init-sdd`의 "풀기" 뒤 설치. `CLAUDE.md`의 표식 구획은 훅이 대신하므로 지워도 된다.
    설치 뒤 `/sdd:init`을 한 번 돌려 훅 표식 `openspec/.sdd`를 만든다(이미 초기화된 `openspec/`은 건너뛰고 표식만 생긴다).
  - 기존 "방법 1·2"는 복사 방식으로 남긴다. "방법 1 — install.sh (권장)" → "방법 1 — install.sh". 손 설치 명령의 원본 경로를
    `"$SDD_SRC"/agents/*.md`, `"$SDD_SRC"/skills/{orchestra,sdd-rules,sdd-sync}`로, 모델 등급 스킬 줄(86, 123, 134행) 삭제, 설치 확인을 3개 스킬로.
    이미 설치한 프로젝트 안내에 "남은 모델 등급 스킬 디렉터리는 지워도 된다" 한 줄.
  - 새 절 `## 개발 (이 저장소를 고칠 때)`: `claude --plugin-dir .`로 띄운다. 에이전트는 `agents/`, 스킬은 `skills/`가 원본이다.
    `--plugin-dir`이 같은 이름 설치본보다 우선한다.
  - 스캐폴드 안내 한 단락: `openspec init --tools claude`가 까는 `.claude/commands/opsx/`, `.claude/skills/openspec-*`는 이 파이프라인에
    필요 없다(지워도, 남겨도 된다). `/sdd:init`은 `--tools none`으로 깔지 않는다.
  - "쓰는 법"의 `/orchestra` → `/sdd:orchestra`(기존 설치본은 `/orchestra`). 모델 언급(215, 222, 244, 264행)에서 모델 등급 스킬을 빼고
    "각 에이전트 파일의 `model:` 한 줄이 기본값"으로. code-explorer 절은 "파이프라인 7개 표 밖의 보조 에이전트, `model: haiku` 고정".
  - 전제 조건 표의 OpenSpec 행: 플러그인은 Node/npx만 있으면 된다(`sdd-openspec`이 1.14.1을 받는다), 복사·링크 방식은 전역 `openspec`.
  - **(D15 추가)** "CLAUDE.md 는 복사하지 말고 합쳐라" 절의 원본 쪽 두 곳: "이 저장소 `CLAUDE.md`의" → "이 저장소 `.claude/CLAUDE.md`의",
    손 설치 명령 `"$SDD_SRC"/CLAUDE.md >> CLAUDE.md` → `"$SDD_SRC"/.claude/CLAUDE.md >> CLAUDE.md`(뒤의 대상 `CLAUDE.md`는 그대로).
    "개발" 절에 한 줄: "이 저장소의 프로젝트 지침은 `.claude/CLAUDE.md`에 있다. 저장소 루트는 플러그인 루트라 `CLAUDE.md`를 두지 않는다
    (`claude plugin validate --strict`가 경고로 실패한다)." 대상 프로젝트 `CLAUDE.md`를 말하는 곳(107·126·128·178행 근처)은 바꾸지 않는다.
- `CLAUDE.md`(묶음 8.2에서 `.claude/CLAUDE.md`로 옮겨진다 — D15): 맨 위 템플릿 주석 **앞에** 개발자 안내 절을 둔다(표식 구획 밖, `순서:` 줄을 쓰지 않는다):
  `claude --plugin-dir .`로 띄운다 / 이 저장소도 SDD로 개발한다 / 아래 표식 구획은 기존 설치 방식이 뽑아 쓰는 조각 원본이라 그 안의
  `.claude/agents/`·`.claude/skills/orchestra/SKILL.md` 경로는 설치 대상 프로젝트 기준이다 — 이 저장소에서는 `agents/`, `skills/orchestra/SKILL.md`로
  읽고 에이전트 이름에는 `sdd:`를 붙인다. 표식 구획 안은 고치지 않는다(A8).
- `.claude/settings.json`: `"Bash(openspec:*)",` 다음 줄에 `"Bash(sdd-openspec:*)",`. `python3 -m json.tool`로 JSON 확인.
- `.gitignore`: 끝에 `# claude plugin eval 결과 (로컬 측정물)` + `evals/results/`.
- `evals/README.md`: "지금은 실행할 수 없다" 절 → "플러그인 루트(저장소 루트)에서 실행한다". `--eval-dir evals` 안내는 "플러그인이 되기 전" 문맥이므로 지운다.
  "결과는 `evals/results/`에 쌓이고 `.gitignore`가 무시한다"로 고친다. (메인 spec `process/field-validation-record` MODIFIED 델타와 맞춘다:
  "아직 플러그인이 아니다"·"실행할 수 없다" 서술 0건, 플러그인 루트에서 실행한다는 문장 있음.)
  "실행" 절의 명령에 `--no-publish`를 더하고 "기본값은 보고서를 claude.ai에 올린다" 한 줄을 붙인다.
- `openspec/.sdd`(새 파일): D3의 표식 두 줄. 이 저장소도 SDD로 개발하므로 훅을 켠다.

### D11. 파일 이동과 이 세션

- 이동 명령 (이동 묶음 8, D7 다음):
  `git mv .claude/agents agents`, `git mv .claude/skills/orchestra skills/orchestra`, `git mv .claude/skills/sdd-rules skills/sdd-rules`,
  `git mv .claude/skills/sdd-sync skills/sdd-sync`, `git mv CLAUDE.md .claude/CLAUDE.md`(D15). `skills/`는 묶음 2가 `skills/init/`을 만들어 이미 있다.
- 이동 뒤 `.claude/`에 남는 것(추적): `CLAUDE.md`, `settings.json`, `skills/init-sdd/`. (추적 안 됨) `settings.local.json`, `skills/openspec-*`, `commands/opsx/`.
- `CLAUDE.md` 이동은 다른 이동과 같은 커밋에 든다. install.sh·init-sdd의 원본 경로 수정(묶음 6.4·6.5)은 내용 수정이라 이동 **전에** 끝낸다
  (6.1이 `agents/`를 이동 전에 가리키게 한 것과 같은 원칙). 그 사이 install.sh가 원본을 못 찾는 구간은 묶음 8 커밋 하나 안에서 닫힌다.
- 이 오케스트레이터 세션의 메모리는 세션 시작 때 루트 `CLAUDE.md`에서 읽혔다. 이동 뒤 새 세션은 `.claude/CLAUDE.md`에서 같은 내용을 읽는다(9.16에서 확인).
- **이 오케스트레이터 세션:** 서브에이전트 정의는 세션 시작 때 `.claude/agents/`에서 읽혔다. 이동 뒤에도 옛 정의가 메모리에 남아 뜰 수도,
  `not found`가 날 수도 있다. 어느 쪽이든 다음을 지킨다.
  - 이동 뒤 부르는 reviewer·finalizer·worker 프롬프트에는 **새 경로**를 적는다(`agents/<이름>.md`, `skills/<이름>/SKILL.md`).
  - 프롬프트에 한 줄을 싣는다: "sdd-rules가 주입되지 않았으면 `skills/sdd-rules/SKILL.md`를 Read로 읽고 따른다"
    (finalizer는 `skills/sdd-sync/SKILL.md`도). 옛 정의의 `skills:`가 가리키던 `.claude/skills/sdd-rules/`가 없어지기 때문이다.
  - 옛 이름(`reviewer`)이 `not found`면 사용자에게 `claude --plugin-dir .`로 새 세션을 열자고 말하고, 새 세션에서 `sdd:reviewer`로 잇는다.
    지시 내용은 이동 전과 같으므로(바뀐 것은 이름·경로·openspec 글자뿐) 옛 정의로 리뷰해도 판정 기준은 같다.
- 버린 대안: 이동을 먼저 하고 내용 수정을 나중에 — 도중에 세션이 끊기면 에이전트가 하나도 안 실린다(decision 핵심 결정 3).

### D12. 메인 spec 경로 치환 규칙 (finalizer가 sync 때 한 번에)

decision 핵심 결정 4-3은 "역할 이름으로 일괄 치환"이다. 다만 일괄 치환은 기계적이고 여러 번 돌려도 같아야 하는데(sdd-sync),
문장마다 "`.claude/agents/worker.md`를" → "worker 에이전트 파일을"로 다시 쓰는 것은 조사·어순 판단이 들어간다. 또 시나리오 안의
`grep ... .claude/agents/*.md` 같은 명령은 역할 이름으로 바꾸면 돌릴 수 없게 된다. 그래서 핵심 결정 4-1이 허용한 다른 표기 —
**플러그인 루트 기준 상대 경로** — 로 치환한다. 새로 쓴 델타 요구사항은 역할 이름(+ 필요한 곳에 상대 경로)으로 이미 썼다.
이 표기는 설계 검토 뒤 오케스트레이터가 사용자 위임으로 채택을 확정했다(2026-10-09). proposal "What Changes" 9와 Capabilities 끝 문단도 이에 맞췄다.

| 대상 | 찾을 글자 | 바꿀 글자 |
|---|---|---|
| `agent-instructions/` 아래 14개 spec 전부 | `.claude/agents` | `agents` |
| 같은 14개 | `.claude/skills/orchestra` | `skills/orchestra` |
| 같은 14개 | `.claude/skills/sdd-rules` | `skills/sdd-rules` |
| 같은 14개 | `.claude/skills/sdd-sync` | `skills/sdd-sync` |
| `distribution/sdd-install-script` 의 한 줄만 | `` `README.md`·`CLAUDE.md`·`.claude/skills/orchestra/SKILL.md` `` | `` `README.md`·`.claude/CLAUDE.md`·`skills/orchestra/SKILL.md` `` |
| `agent-instructions/analyzer-option-generation` 의 한 조각만 | `Agent(subagent_type: "analyzer", ...)` | `Agent(subagent_type: "sdd:analyzer", ...)` |
| `agent-instructions/analyzer-option-generation` 의 두 곳 (D15) | `` `CLAUDE.md`, `README.md` `` | `` `.claude/CLAUDE.md`, `README.md` `` |

마지막 줄(b3)은 이 저장소의 파이프라인 순서 문서를 가리키는 곳이다(요구사항 본문 한 곳, 시나리오 "세 문서의 순서 문구가 일치한다" 한 곳).
두 번 돌려도 바뀐 글자 `` `.claude/CLAUDE.md` ``에서는 찾을 글자(백틱 바로 뒤 `CLAUDE.md`)가 다시 걸리지 않는다. `.claude/` 출현이 2회 늘어난다.
`sdd-install-script`·`init-sdd-skill`에서 이 저장소 쪽 `CLAUDE.md`를 가리키는 요구사항은 델타(MODIFIED)로 바뀌므로 치환하지 않는다.
(b) 줄도 같은 이유로 `.claude/CLAUDE.md`로 바꾼다(`.claude/` 출현 수는 그대로).

마지막 줄은 경로가 아니라 호출 이름이다. orchestra의 호출 예시가 `sdd:analyzer`로 바뀌므로(D5) 그 예시를 가리키는 시나리오 글자가
낡는다. 요구사항 헤더·시나리오 이름은 건드리지 않고 시나리오 본문의 이 한 조각만 바꾼다(원문 보존). 두 번 돌려도 `"sdd:analyzer"`에는
찾을 글자 `subagent_type: "analyzer"`가 없으므로 결과가 같다. `.claude/` 출현 수에는 영향이 없다.

그대로 두는 것 (A10 + 실제로 남는 경로):
- `.claude/settings.local.json`, `.claude/settings.json`(이 저장소에도 대상 프로젝트에도 그 자리에 남는다)
- `.claude/skills/openspec-*`, `.claude/commands/opsx/`(사용자 프로젝트의 스캐폴드 위치)
- `.claude/skills/init-sdd/`(옮기지 않는다, A3)
- 홀로 쓴 `.claude/` (`code-explorer-role`의 "고치지 않는 곳" 목록 등 — 프로젝트의 `.claude/` 자체를 뜻한다)
- `distribution/` 아래 나머지 전부: `sdd-install-script`·`init-sdd-skill`에 남는 `.claude/agents` 등은 **설치 대상 프로젝트** 경로(A10),
  새 capability 4개는 이번에 새 표기로 쓴 것이다
- `process/` 아래 (`.claude/` 0회. `field-validation-record`는 델타로만 바뀐다)
- 메인 spec 안의 `openspec <명령>` 글자 (A1 — `sdd-openspec <명령>`도 그 글자를 품는다)

기대값: 치환 전 **152회/126줄**은 고정(현재 메인 spec 실측). 치환 뒤 값은 묶음 9.12가 저장소 사본에 이 change의 최종 델타로
archive + 위 표를 적용해 재고 verification.md에 "finalizer가 대조할 기대값"으로 남긴다(첫 설계 때 사본 값은 80회/63줄이었다 — E5).
finalizer는 실제 값을 재서 verification.md 값과 다르면 커밋하지 말고 보고한다.

### D13. 검증 방법 (묶음 9에서 쓰는 명령 골격)

- **새 프로세스 init 이벤트:** 저장소 루트에서
  `claude -p "준비됐으면 OK라고만 답하라" --plugin-dir . --output-format stream-json --verbose --max-turns 1 > <scratch>/init.jsonl`.
  첫 `"subtype":"init"` 줄에서 agents·skills·plugins 목록을 뽑아 기록한다.
- **sdd-rules 주입:** ②와 같은 방법(`claude -p "<프롬프트>" --plugin-dir . --allowedTools "Agent"` — 프롬프트를 플래그 **앞에** 둔다).
  기대 문장은 `## store 처리` 첫 줄. 실행 전 `grep -rnF "<문장>" agents skills .claude`(이동 뒤 `.claude/CLAUDE.md` 포함)가 `skills/sdd-rules/SKILL.md` 한 곳뿐인지 확인한다.
  8개 각각 `subagent_type "sdd:<이름>"`. 기대: 7개 = 문장, code-explorer = NONE.
- **사용자 전역 설정 보호:** 마켓플레이스 설치 시험은 `export CLAUDE_CONFIG_DIR="$(mktemp -d)"`로 격리한다(F6·F12와 같은 방법).
  격리 전에 `claude plugin list`에 `sdd`가 이미 깔려 있는지 기록한다.
- **외부 호출 허용 범위:** 묶음 1·2·9의 `claude -p`, `claude plugin validate/marketplace/install/list/eval`,
  `npx`·`sdd-openspec`의 npm 내려받기, 로컬 경로 마켓플레이스는 이 change가 허용한 외부 호출이다(sdd-rules "외부 서비스 호출"의 승인 근거).
  오케스트레이터는 해당 worker 프롬프트에 `외부 호출: 허용 (tasks 머리말 범위)` 한 줄을 싣는다. 전역 설치(`npm i -g` 등)와 사용자 전역
  `~/.claude` 변경은 허용 범위가 아니다.
- **훅 세 갈래:** (a) 빈 `mktemp -d` (b) `openspec/`만 있고 표식 없음 (c) 표식 있음 + `openspec/changes/done-one/tasks.md` 전부 `[x]` +
  `openspec/changes/archive/2026-01-01-old-one/tasks.md` 전부 `[x]` + 권한 파일 없음. (a)(b)는 stdout 0바이트·rc=0, (c)는 지휘 규칙 +
  `done-one` 줄 + `/sdd:init` 권유 줄이 있고 `old-one`은 없다.
  stdout 바이트 수와 종료코드는 따로 잰다: `out="$(CLAUDE_PROJECT_DIR=<dir> bash hooks/session-start.sh)"; echo "exit=$?"; printf %s "$out" | wc -c`
  (`| wc -c`를 직접 붙이면 종료코드가 `wc`의 것이 된다).
- **설치본에서 init 비대화 단계:** 셸에는 플러그인 `bin/`이 PATH에 없으므로 캐시 경로를 찾아 직접 부른다
  (`find "$CLAUDE_CONFIG_DIR/plugins" -path '*/bin/sdd-init' -type f`). 새 프로젝트: `mktemp -d` → `git init -b main` → 빈 커밋 →
  `package.json`(test·build 스크립트) → `sdd-init setup` rc=0 → 전후 `git status --porcelain`·`find openspec -type f | sort | xargs cat | shasum`을 잡고
  `sdd-init setup` 한 번 더 rc=0, 두 값이 같다(멱등) → `detect`(기본 브랜치 `main`) / `permissions`(npm 안내 줄) 각 rc=0 →
  `write-context` → `sdd-openspec context`에 Warning 없음.
- **팀 배포 키 확인:** 같은 격리 설정의 다른 `mktemp -d` 프로젝트에 D10의 `extraKnownMarketplaces`·`enabledPlugins` 블록을
  `.claude/settings.json`으로 두고(`source`는 로컬 경로 마켓플레이스로 바꿔도 된다) 인식 여부를 기록한다. 인식 안 되면 보고만 한다.
  권한 기록은 `.claude/settings.json`을 하나 커밋해 둔 뒤 `write-permissions`를 두 번 돌리고 전후 `git status --porcelain`·`git diff`를 대조.
- **작은 작업 change:** 같은 프로젝트에서 `sdd-openspec new change try-small` → proposal.md·tasks.md를 손으로 짧게 쓰고,
  델타가 없으므로 `.openspec.yaml`에 `skip_specs: true`를 마커 명령 블록 꼴(`grep -q ... || printf '\nskip_specs: true\n' >> "$f"`)로 넣는다 →
  `sdd-openspec validate try-small --strict; echo "exit=$?"` → 0, `sdd-openspec status --change try-small --json >/dev/null; echo "exit=$?"` → 0.
- **기존 설치본 대비 규칙:** 플러그인이 전역에 깔려 있지 않은 설정(필요하면 격리 `CLAUDE_CONFIG_DIR`)에서 `mktemp -d` 프로젝트에
  `bash <repo>/install.sh` → 그 프로젝트에서
  `claude -p "Agent 도구로 subagent_type \"sdd:code-explorer\"를 불러 'README.md가 있으면 첫 줄, 없으면 NONE'을 알아 오라. 결과가 not found면 같은 요청으로 subagent_type \"code-explorer\"를 다시 불러라. 마지막 두 줄에 첫 호출 결과와 두 번째 호출 결과를 적어라." --allowedTools "Agent" --output-format stream-json --verbose`.
  기대: 첫 tool_result에 `not found`, 두 번째 호출이 실제로 뜬다.
- **기존 설치본 init-sdd 실제 걸기/풀기:** `mktemp -d` 프로젝트(`git init -b main`, `CLAUDE.md` 하나 커밋)와 `mktemp -d` 개인 저장소를
  `개인` 경로로 두고 `.claude/skills/init-sdd/SKILL.md`의 "걸기" 절차를 그대로 따른 뒤 "상태 보기" → "풀기"를 한 번씩 돈다.
  기대: 걸기 뒤 링크 다섯 개가 개인 저장소를 가리키고 공유 `git status --porcelain`이 조용하다, 풀기 뒤 링크 0개·`CLAUDE.md` 원래 내용·
  `.git/info/exclude`의 스킬 표시 0줄. 모든 경로는 두 `mktemp -d` 안이다(사용자 `~/work-space/agentic` 등은 쓰지 않는다).
- **eval 인식 (오케스트레이터 결정, 비용 상한 0.05달러):** 저장소 루트에서
  `timeout 600 claude plugin eval . --runs 1 --max-cost-usd 0.05 --no-publish --output-dir <scratch>/eval-out --json <scratch>/eval.json --report <scratch>/eval.html; echo "exit=$?"`.
  `--no-publish`는 반드시 붙인다 — 기본값이 보고서를 claude.ai에 올린다(`--help`, 2.1.294). `--output-dir`을 주면 기본 위치
  `./evals/results/<timestamp>/`에 쓰지 않는다. 상한에 걸려 중단돼도(exit≠0) 인식 여부만 보면 되므로 실패로 치지 않는다.
  출력과 json에서 사례 이름(`lite-path-small-task`, `direct-work-control`)이 인식됐는지 본다. 신뢰 확인 질문이 나오면 `--trust-plugin`을 붙인다.
  점수는 기록하지 않는다(범위 밖). 실행 뒤 `test -e evals/results; echo $?`와 `git check-ignore -q evals/results/x; echo $?`(→ 0),
  `git ls-files evals/results | wc -l`(→ 0)을 기록한다. `evals/results/`가 생겼으면 묶음 9.15의 정리 모드 worker가 지운다.
- **프로젝트 지침 로드 (D15):** 저장소 루트에서 `test -e CLAUDE.md; echo $?`(→ 1), `test -f .claude/CLAUDE.md; echo $?`(→ 0). 이어서
  `claude -p "읽기 도구를 쓰지 말고, 이 세션에 실린 프로젝트 지침에서 '# 이 저장소를 고칠 때' 바로 아래 첫 줄을 그대로 적어라. 없으면 NONE." --plugin-dir . --max-turns 1`
  → `.claude/CLAUDE.md`의 그 줄("- 이 저장소는 플러그인 `sdd`의 루트다. ...")이 나온다. NONE이면 멈추고 보고한다(D15의 전제가 무너진 것 — designer로 돌아온다).
- **CLI 버전:** 받아들일 조건의 `openspec validate ... --strict`는 PATH의 `openspec`(1.12.0)과 `bin/sdd-openspec`(1.14.1) **둘 다** 돌려 기록한다.
  change 검증은 둘 다 0이어야 한다(E1). 메인 spec `--all --strict`의 1.14.1 실패(E4)는 기존 문제로 기록만 한다.

### D14. 검증 기록 파일

`<changeRoot>/verification.md`(새 파일)에 관문 결과(G-*), 치환 전 기준선, 묶음 9의 명령·출력·종료코드를 남긴다.
reviewer와 finalizer는 이 파일을 근거로 본다. 묶음 1과 묶음 9만 이 파일을 쓴다(병렬 worker끼리 겹치지 않게).

### D15. 프로젝트 지침 파일을 `.claude/CLAUDE.md`로 옮긴다 (2026-10-09 추가, 오케스트레이터 결정)

- 이유: 플러그인 루트의 `CLAUDE.md`는 `claude plugin validate`가 경고하고 `--strict`가 실패시킨다(E7). 받아들일 조건 첫 줄(두 validate `--strict` exit 0)과
  sdd-plugin의 "루트 CLAUDE.md에 개발자 안내 + 표식 구획" 요구가 정면으로 부딪쳤다. Claude Code는 `./.claude/CLAUDE.md`도 프로젝트 지침으로 읽으므로
  옮기면 dogfooding(이 저장소 세션이 지휘 규칙을 받는 것)과 validate 통과가 함께 선다.
- 무엇이 옮겨지나: **이 저장소(원본) 쪽만.** 내용은 그대로(개발자 안내 절 + 템플릿 주석 + 표식 구획). 파일 이동은 묶음 8.2의 `git mv`로 한다.
- 원본 경로를 쓰는 곳: install.sh(D8 추가분), init-sdd(D9 추가분), README(D10 추가분), 델타(`sdd-plugin` 새 요구사항,
  `sdd-install-script`·`init-sdd-skill` MODIFIED), 메인 spec 치환(D12 (b)·(b3)).
- 바꾸지 않는 것: 설치 결과물인 **대상 프로젝트 루트의 `CLAUDE.md`**(install.sh `$DST/CLAUDE.md`, init-sdd `$대상/CLAUDE.md`, README의 대상 안내).
  기존 설치본 사용자의 프로젝트 모양은 바뀌지 않는다.
- 버린 대안:
  - 경고 1건을 허용 예외로 두기 — 받아들일 조건을 약하게 만들고, 다음 경고가 섞여도 못 알아본다(오케스트레이터가 배제).
  - 지침을 루트에서 지우고 훅만 쓰기 — 이 저장소의 개발자 안내와 조각 원본(메인 spec "조각 원본 한 벌")이 갈 곳이 없어진다.
  - 조각 원본을 `skills/` 아래로 옮기기 — 플러그인이 매 세션 싣는 스킬이 되거나 스킬 레이아웃 밖 파일이 생긴다. `.claude/CLAUDE.md`는 지침과 원본을 한 파일로 유지한다.

## Purpose 갱신 (sdd-sync가 읽는 목록)

- `distribution/init-sdd-skill`: 아래 "finalizer 프롬프트에 글자 그대로 실을 블록"의 문장으로 바꾼다.
- `distribution/sdd-install-script`: 같은 블록의 문장으로 바꾼다.
- 나머지 수정 capability의 Purpose는 그대로 둔다.

## finalizer 프롬프트에 글자 그대로 실을 블록

이 change의 sync는 이동 뒤에 돈다. 옛 finalizer 정의가 돌 수도 있으므로(D11) 오케스트레이터는 아래 블록을 **그대로 복사해**
finalizer 프롬프트에 싣는다. 블록 안의 문장을 고쳐 쓰거나 요약하지 않는다.
오케스트레이터는 블록과 함께 승인 줄 `은퇴 승인: agent-model-tier (사용자 결정)`을 프롬프트에 따로 싣는다
(근거: 2026-10-08 사용자 선택 "agent-model-tier 스킬 — 없앰", 상위 `plugin-lite-sdd-distribution/decision.md`).
archive까지 맡기려면 `archive: 해도 됨`도 싣는다.

```text
[convert-to-plugin sync 지시 — designer 작성, 글자 그대로]
0. 이 change부터 공용 규칙은 skills/sdd-rules/SKILL.md, sync 절차는 skills/sdd-sync/SKILL.md 에 있다.
   주입이 안 됐으면 두 파일을 Read로 읽고 따른다. openspec 명령은 sdd-openspec 을 쓰고, 없으면 openspec 을 쓰고 버전을 적는다.
1. 델타 반영 전에 잰다:
   grep -o '\.claude/' -r openspec/specs | wc -l      (기대 152)
   grep -r '\.claude/' openspec/specs | wc -l         (기대 126)
   다르면 멈추고 두 값을 보고한다.
2. 델타 반영 — sdd-sync 3단계, 순서 RENAMED → REMOVED → MODIFIED → ADDED:
   - distribution/sdd-install-script: RENAMED 1("제품 7종을 깔아야 한다" → "제품 6종을 깔아야 한다"), MODIFIED 5(새 이름으로 찾는다), ADDED 1
   - distribution/agent-model-tier: REMOVED 7 → 요구사항 0개 → 은퇴. .openspec.yaml 에 retire_capabilities: true 가 있다.
     이 은퇴는 사용자 결정(상위 plugin-lite-sdd-distribution/decision.md, 2026-10-08 "agent-model-tier 스킬 — 없앰")에 따른 것이다.
     이것이 sdd-rules "되돌릴 수 없는 일"(메인 spec 파일 삭제, capability 은퇴)의 승인 근거다. 오케스트레이터가 프롬프트에
     "은퇴 승인: agent-model-tier (사용자 결정)" 줄을 함께 싣는다. 그 줄이 없으면 은퇴하지 말고 멈춰 보고한다.
     은퇴 여섯 조건을 확인하고 spec.md 와 비게 된 디렉터리를 지운다. 등급 표 줄은 요구사항 본문이라 ④를 만족한다.
     (openspec archive 는 이 은퇴를 거부한다 — 실측. 은퇴는 반드시 이 sync가 한다.)
   - distribution/init-sdd-skill: MODIFIED 6, ADDED 1
   - agent-instructions/code-explorer-invocation: MODIFIED 1, ADDED 1
   - agent-instructions/code-explorer-role: MODIFIED 2
   - agent-instructions/shared-pipeline-rules: MODIFIED 1, ADDED 1
   - process/field-validation-record: MODIFIED 2 (요구사항 헤더·시나리오 이름은 메인 spec 원문 그대로다. 본문만 바뀐다)
   - 새 capability 4개 (Purpose는 델타 것을 옮긴다): distribution/sdd-plugin ADDED 11, distribution/openspec-cli-wrapper ADDED 3,
     distribution/session-start-hook ADDED 4, distribution/sdd-init-command ADDED 8
3. Purpose 갱신 (사용자 결정 — 메인 Purpose 정본 규칙의 예외). 아래 두 capability의 "## Purpose" 본문을 --- 사이 문장으로 통째로 바꾸고 보고한다.
   다른 capability의 Purpose는 건드리지 않는다.
   distribution/init-sdd-skill:
   ---
   개인 agentic 설정(서브에이전트, 지휘·공용 규칙·sync 스킬, 권한 설정)을 별도의 개인 git 저장소에 두고, 공유 프로젝트의 `.claude/` 안에서는 그것을 심볼릭 링크로 가리키게 해 주는 `init-sdd` 스킬의 계약을 정한다. 플러그인이 권장 설치 방식이 된 뒤에도 기존 설치 방식으로 남는다. 링크를 걸고 푸는 것이 양방향이어야 하고, 공유 저장소가 원래 상태로 되돌아와야 하며, 대상 프로젝트에 이미 있는 것을 잃지 않아야 한다.
   ---
   distribution/sdd-install-script:
   ---
   `install.sh`가 대상 프로젝트에 SDD 파이프라인을 얹는 절차를 정한다. 플러그인이 권장 설치 방식이 된 뒤에도 기존 설치 방식으로 남으며, 원본은 저장소의 플러그인 레이아웃에서 가져온다. 제품 파일과 `CLAUDE.md` 조각의 원본이 저장소에 한 벌로만 존재해야 하고, 대상 프로젝트에 이미 있는 파일을 잃지 않아야 하며, 설치 안내가 한 곳에만 있어야 한다.
   ---
4. 경로 일괄 치환 — 2·3 다음에 한 번. 요구사항의 의미는 바꾸지 않는다. 같은 치환을 두 번 돌려도 결과가 같아야 한다.
   (a) openspec/specs/agent-instructions/ 아래 spec.md 전부에서:
       ".claude/agents" → "agents"
       ".claude/skills/orchestra" → "skills/orchestra"
       ".claude/skills/sdd-rules" → "skills/sdd-rules"
       ".claude/skills/sdd-sync" → "skills/sdd-sync"
   (b) openspec/specs/distribution/sdd-install-script/spec.md 에서 이 한 줄 조각만:
       "`README.md`·`CLAUDE.md`·`.claude/skills/orchestra/SKILL.md`" → "`README.md`·`.claude/CLAUDE.md`·`skills/orchestra/SKILL.md`"
   (b2) openspec/specs/agent-instructions/analyzer-option-generation/spec.md 에서 이 한 조각만 (호출 이름. 헤더·시나리오 이름은 그대로):
       "Agent(subagent_type: \"analyzer\", ...)" → "Agent(subagent_type: \"sdd:analyzer\", ...)"
   (b3) 같은 analyzer-option-generation/spec.md 에서 이 조각 전부(2곳 — 요구사항 본문 1, 시나리오 1. 이 저장소 지침 파일이 .claude/CLAUDE.md 로 옮겨졌다):
       "`CLAUDE.md`, `README.md`" → "`.claude/CLAUDE.md`, `README.md`"
       (a)를 먼저 하고 (b3)을 한다. 두 번 돌려도 결과가 같다(바뀐 글자에는 백틱 바로 뒤 CLAUDE.md 가 없다).
   (c) 그 밖은 바꾸지 않는다: .claude/settings.json, .claude/settings.local.json, .claude/skills/openspec-*, .claude/commands/opsx/,
       .claude/skills/init-sdd/, 홀로 쓴 `.claude/`, distribution/ 의 나머지(설치 대상 프로젝트 경로와 새 capability), process/,
       그리고 메인 spec 안의 `openspec <명령>` 글자.
   치환은 Edit replace_all 로 파일마다 한다(sed -i 금지).
5. 치환 뒤 잰다 (같은 두 명령). 기대값은 openspec/changes/convert-to-plugin/verification.md 의 9.12 실측값
   ("finalizer가 대조할 기대값" 줄)이다. 숫자를 이 블록에 고정하지 않는다. 그리고
   grep -rn 'agent-model-tier' openspec/specs → 0건 (기대)
   grep -c 'subagent_type: "analyzer"' openspec/specs/agent-instructions/analyzer-option-generation/spec.md → 0 (기대)
   다르면 커밋하지 말고 어느 파일이 다른지 보고한다.
6. 커밋 메시지 본문에 한 줄로 남긴다: "메인 spec .claude/ 출현: 치환 전 152회/126줄 → 치환 후 <실측>회/<실측>줄".
7. sdd-sync 5단계 검증: sdd-openspec validate --specs; echo "exit=$?" 와 sdd-openspec validate "convert-to-plugin"; echo "exit=$?" 둘 다 0.
   추가로 openspec validate --specs --strict; echo "exit=$?" (PATH의 openspec, 1.12.0 — 기대 0)와
   sdd-openspec validate --specs --strict; echo "exit=$?" (1.14.1)를 돌려 결과를 그대로 적는다.
   1.14.1의 --strict 는 기존 메인 spec의 긴 요구사항 경고로 1이 나온다 — 이 change의 문제가 아니다. 그 하나는 커밋을 막지 않고 보고만 한다.
8. archive (`archive: 해도 됨`일 때만): sdd-openspec(1.14.1)으로 한다. sdd-openspec 이 없으면 PATH의 openspec 으로 하고
   openspec --version 값을 보고서에 적는다. 은퇴(2번)가 끝난 뒤라야 archive 가 exit 0이다(실측).
   archive 뒤 openspec validate --all --strict; echo "exit=$?" (1.12.0, 기대 0)와 sdd-openspec validate --all --strict; echo "exit=$?"
   (1.14.1, 7번과 같은 기존 경고로 1일 수 있다 — 출력 그대로 적는다)를 돌린다. 1.12.0 쪽이 0이 아니면 멈추고 보고한다.
```

## Risks / Trade-offs

- [관문 실패: 실제 파일로 다시 재도 F1~F12 중 하나가 다르다] → 묶음 1에서 멈추고 보고한다. F2가 안 되면(F3과 상관없이) 공용 규칙 주입과
  A12(접두사 없는 `skills:`)가 무너지므로 멈춘다. F2·F3이 둘 다 안 되면 decision 핵심 결정 5대로 `bin/sdd-rules` 출력 방식 검토로 돌아간다(사용자 결정).
- [표식이 없어 훅이 안 켜진다] → 기존 SDD 프로젝트(복사·링크본에서 옮겨 온 곳)는 `openspec/.sdd`가 없다. 훅이 조용할 뿐 파이프라인은 돈다.
  README "기존 방식에서 플러그인으로 옮기기"에 `/sdd:init`(이미 초기화된 곳은 표식만 만든다)을 한 번 돌리라고 적는다.
- [`claude plugin eval` 기본값이 보고서를 claude.ai에 올린다] → `--no-publish`를 반드시 붙인다(D13). 비용은 `--max-cost-usd 0.05`로 막는다.
- [마켓플레이스 캐시에 `.claude/settings.json`이 안 복사된다(G-CACHE)] → 권한 목록 원본을 플러그인 레이아웃 안(`skills/init/permissions.json` 등)으로
  옮기고 install.sh가 그것을 쓰게 하는 설계 변경이 필요하다. 관문에서 멈추고 designer로 돌아온다.
- [메인 세션 Bash PATH에 플러그인 `bin/`이 없다(G-PATH)] → 스킬 문서의 명령을 `${CLAUDE_PLUGIN_ROOT}/bin/...` 꼴로 쓴다(스킬 본문 치환도 같은 관문에서 잰다).
  둘 다 안 되면 멈추고 보고.
- [기존 설치본은 `sdd-openspec`이 없다] → sdd-rules 대체 규칙으로 `openspec`을 쓴다. 전역이 1.12면 지금과 같은 버전으로 돈다(지금보다 나빠지지 않는다).
- [시나리오 이름 "7종", "5종"이 본문과 안 맞는다(E2)] → 본문에 이유를 한 줄 적었다. 이름을 바꾸려면 REMOVED+ADDED가 필요해 diff가 커져서 미뤘다(⑥).
- [`openspec archive`가 은퇴를 거부(E3)] → finalizer sync가 은퇴를 먼저 끝내면 archive는 exit 0(사본 실측). 블록 2에 적었다.
- [`validate --all --strict`가 1.14.1에서 실패(E4)] → 받아들일 조건은 PATH의 `openspec`(1.12.0) 기준으로 재고 1.14.1 결과는 기록만 한다. 사용자 확인 사항으로 올린다.
- [같은 에이전트가 두 이름으로 실림(플러그인 + 복사본)] → install.sh·init-sdd·README에 이전 안내. 대비 규칙은 `sdd:` 먼저라서 플러그인 쪽이 쓰인다.
- [이동 뒤 이 세션의 서브에이전트] → D11.
- [`.claude/CLAUDE.md`가 프로젝트 지침으로 안 실린다(D15 전제)] → 9.16에서 새 세션으로 확인한다. 실패하면 멈추고 designer로 돌아온다(validate 통과와 dogfooding 중 무엇을 양보할지 사용자 결정 필요).
- [묶음 6.4·6.5 뒤 8.2 전까지 install.sh·init-sdd가 조각 원본을 못 찾는다] → 6.1이 `agents/`를 미리 가리킨 것과 같은 구간이다. 묶음 8 커밋 하나 안에서 닫힌다.

## Migration Plan

1. 이 저장소: 이동 커밋 뒤에는 `claude --plugin-dir .`로만 연다(README·CLAUDE.md에 먼저 적는다). 프로젝트 지침은 `.claude/CLAUDE.md`에서 읽힌다(D15).
2. 기존 복사·링크 사용자: 아무것도 안 해도 지금처럼 돈다(대비 규칙 + openspec 대체 규칙). 옮기려면 README "기존 방식에서 플러그인으로 옮기기".
3. 되돌리기: 이 change의 커밋을 `git revert`하면 `.claude/` 레이아웃으로 돌아온다. 사용자 쪽은 `/plugin uninstall sdd`.
