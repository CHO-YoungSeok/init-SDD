# Design

## Context

동기·범위는 proposal.md("Why", "What Changes", "지켜야 할 spec 계약")를 본다. 여기에는 설계를 묶는 현재 사실만 적는다.

- 기준 HEAD: `6018683`(브랜치 `plugin-lite-sdd-distribution`). openspec CLI는 `./bin/sdd-openspec`(1.14.1). PATH `openspec`은 1.12.0이다.
- `install.sh`는 `MARK_BEGIN='<!-- init-SDD:begin -->'`, `MARK_END='<!-- init-SDD:end -->'`로
  `sed -n "/$MARK_BEGIN/,/$MARK_END/p" "$SRC/.claude/CLAUDE.md"`를 돌려 조각을 뽑는다(88~95행).
  README의 손 설치 안내는 더 짧은 패턴 `sed -n '/init-SDD:begin/,/init-SDD:end/p'`를 쓴다.
  **그래서 `.claude/CLAUDE.md`의 구획 밖에 `init-SDD:begin`·`init-SDD:end` 글자가 한 번이라도 나오면 엉뚱한 줄부터 뽑힌다.**
- `install.sh`의 안내 문구가 README 절 이름을 가리킨다: `'설치' 절`(21행), `'먼저 고른다' 절`(164행).
  `.claude/skills/init-sdd/SKILL.md`도 "`README.md`의 `## 설치` 절", "`## 설치` 맨 앞"(11·23행)을 가리킨다.
  이 두 파일은 이번 범위 밖이라 **README 쪽 제목을 그대로 지켜야 한다**: `## 설치`, `### 먼저 고른다 — 플러그인인가, 복사 방식인가, 링크 방식인가`.
- regression-verifier 정본 조건: `skills/orchestra/SKILL.md` 169행 "**큰 작업이고, 실행 코드가 바뀌었고, 프로젝트에 테스트 명령이 있을 때만 부른다.**"
  지금 어긋난 곳: `README.md` 8행("테스트가 있을 때"), 270행("큰 작업이고 테스트 명령이 있을 때만"), `.claude/CLAUDE.md` 23행("(테스트가 있을 때, 동시)").
- 삭제 대상 7경로(파일 12개)는 모두 `git check-ignore`에 걸리고 `git ls-files`에 0건이다(실측). `.claude/commands/` 안에는 `opsx/` 하나뿐이다.
  지우면 이 저장소 세션에서 `/opsx:*` 명령과 `openspec-*` 스킬이 사라진다. 필요하면 `openspec init --tools claude`로 다시 만든다(오케스트레이터 결정: 그대로 지운다).
- 문서 수정 규칙: 메인 spec `agent-instructions/analyzer-option-generation` "지침 문서 수정은 파일을 손상시키지 않아야 한다"가 이 change가 고치는 README·`.claude/CLAUDE.md`·`config.yaml`에 모두 걸린다 — 전체 재작성 금지, Edit 부분 수정, 끝난 뒤 무결성 검사.
- 이 환경의 `grep`은 ugrep 래퍼 함수라 `grep -r`가 경로 앞 `./`를 붙이지 않는다(실측). 경로 출력을 기대값과 비교하는 확인은 `command grep`을 쓴다.
  `/usr/bin/awk`는 한글 문자열 `==` 비교가 로캘 정렬 때문에 틀린다(`## 설치`가 `## 커스터마이즈`와 같다고 나옴, 실측). 한글 비교 awk에는 `LC_ALL=C`를 붙인다.
- 기준선: `./bin/sdd-openspec validate --all --strict` → `exit=1`, `Totals: 14 passed, 9 failed (23 items)`(이 change 델타를 쓴 뒤 실측).
  `spec/agent-instructions/project-context-completeness`는 통과 쪽이다. 이번 change 뒤에도 실패 수 9 이하, 이 spec은 통과로 남아야 한다.

## Goals / Non-Goals

**Goals:**
- config `context:`와 메인 spec `project-context-completeness`를 ③ 이후 사실로 함께 맞춘다(MODIFIED 델타 1개).
- `.claude/CLAUDE.md` 구획 밖을 개발자 지침으로 다시 쓰고, 구획 안은 regression-verifier 괄호 한 곳만 고친다.
- README를 플러그인 우선 순서로 다시 짜되(절 단위 Edit, Write 재작성 금지), 아래 D4 표의 메인 spec 계약을 하나도 잃지 않는다.
- 무시된 `openspec init` 스캐폴드 7경로를 지운다.

**Non-Goals (설계 수준):**
- `install.sh`, `.claude/skills/init-sdd/SKILL.md`, `agents/`, `skills/`, `bin/`, `hooks/`, `.claude-plugin/`, `.claude/settings.json`, `.gitignore`는 한 글자도 바꾸지 않는다.
- README 절 이름 중 다른 파일이 가리키는 것(`## 설치`, `### 먼저 고른다 — ...`, `방법 1 — install.sh`, `방법 2 — 손으로`, `설치 확인`, `이게 왜 필요한가`, `일의 크기에 따라 경로가 갈린다`)은 바꾸지 않는다.
- 메인 spec의 다른 요구사항은 건드리지 않는다. README·CLAUDE.md 고쳐 쓰기는 델타를 만들지 않는다(가정 A5).

## Decisions

### D1. 델타 — `project-context-completeness` 첫 요구사항만 MODIFIED

- 대상: `### Requirement: config.yaml의 context에 프로젝트 사정이 채워져 있어야 한다`. 헤더와 시나리오 이름 `에이전트가 프로젝트 사정을 CLI에서 받는다`는 메인 spec 원문 그대로다.
- 본문은 "실행 코드가 없는 지시문 저장소"·"검증 수단이 ... 뿐" 대신: 플러그인 `sdd`의 지시문 저장소, 지시문 위치 `agents/*.md`·`skills/**/SKILL.md`,
  실행 파일은 bash 스크립트(`install.sh`, `bin/`, `hooks/`)뿐, 검증 수단에 `bash -n`(스크립트 전부)·`claude plugin validate` 두 명령 추가,
  옛 경로 `.claude/agents/*.md` 금지(MUST NOT). 본문 458자(500자 이하, 실측).
- 시나리오 하나를 더한다: `플러그인 전환 전 사실이 남아 있지 않다`(옛 경로·"실행 코드가 없다"·"뿐" 단언 부재). 기존 시나리오 이름은 바꾸지 않는다.
- 두 번째 요구사항(`context 키는 YAML 들여쓰기가 깨지지 않아야 한다`)은 사실이 그대로라 델타에 넣지 않는다.
- 대안: 요구사항을 ADDED로 새로 만들고 옛 것을 REMOVED → 같은 요구를 이름만 바꿔 두 번 적는 꼴이고 archive 기록이 지저분해진다. 버림.

### D2. `openspec/config.yaml` — `context:` 블록만 바꾼다

바꿀 범위: 0칸 `context: |` 줄부터 `# Per-artifact rules (optional)` 바로 앞 빈 줄까지. 나머지(맨 위 `schema:`와 주석, 아래 주석)는 그대로다.
**맨 위 예시 주석 `#   context: |`는 건드리지 않는다**(그 주석을 바꾸면 안 되고, 실제 키와 헷갈려 앵커로 잡지도 말 것 — 실험에서 한 번 그 주석을 잘못 잡아 파싱이 깨졌다).
Edit 한 번(옛 블록 → 새 블록)으로 바꾼다. 새 블록은 글자 그대로 아래다(키는 0칸, 내용은 2칸):

```yaml
context: |
  이 저장소는 Claude Code 플러그인 `sdd`의 "지시문 저장소"다. 저장소 루트가 곧 플러그인 루트다.
  - 서브에이전트 지시문: agents/*.md (파이프라인 7개 + 보조 code-explorer)
  - 스킬 문서: skills/**/SKILL.md (orchestra, sdd-rules, sdd-sync, init)
  - 플러그인 선언: .claude-plugin/plugin.json, .claude-plugin/marketplace.json, hooks/hooks.json
  - 실행 파일(bash 스크립트): bin/sdd-openspec, bin/sdd-init, hooks/session-start.sh, install.sh
  - 기존 설치 방식(폐기 예고): install.sh, .claude/skills/init-sdd/SKILL.md, .claude/CLAUDE.md 의 표식 구획
  - 문서: README.md, .claude/CLAUDE.md, docs/, evals/
  실행 파일은 위 bash 스크립트뿐이다. 빌드 산출물도 서버 런타임도 없다.

  테스트 스위트·빌드·CI가 없다. 검증은 다음으로 한다:
  - bash -n install.sh bin/sdd-init bin/sdd-openspec hooks/session-start.sh (문법 검사)
  - bash install.sh --dry-run (mktemp -d 임시 프로젝트에서)
  - claude plugin validate . --strict, claude plugin validate .claude-plugin/plugin.json --strict
  - OpenSpec CLI 실측 (./bin/sdd-openspec validate --strict / status / instructions / context).
    출력만 보지 말고 종료코드로 판정한다.
  - grep 대조 (문구가 실제로 들어갔는지, 여러 파일에 같은 문구가 유지되는지)
  - 마크다운 무결성 검사 (frontmatter 온전, 코드펜스 줄 수 짝수, 리치 마크다운 토큰 0개)

  문서는 전부 한국어로 쓴다. 어려운 용어를 피하고 누구나 이해할 수 있는 쉬운 말을 쓴다.

  agents/*.md 와 skills/**/SKILL.md 는 Edit 부분 수정만 한다.
  전체 Write 재작성과 sed -i 는 금지다 (전체 재작성으로 마크다운이 망가진 사고가 있었다).
```

새 블록 끝 줄 다음에는 빈 줄 하나를 두고 `# Per-artifact rules (optional)`이 온다(지금과 같은 간격).

**확인 방법 (designer가 scratchpad 사본에서 실측해 통과함):**
1. `./bin/sdd-openspec context > <scratch>/ctx.out 2>&1; echo "exit=$?"` → `exit=0`, 그리고 `grep -c 'Warning' <scratch>/ctx.out` → `0`.
   **종료코드만 보면 안 된다** — 파싱이 깨져도 `exit=0`이다(메인 spec 시나리오 "종료코드만 보면 안 된다").
2. 진짜 증거: `./bin/sdd-openspec instructions proposal --change apply-plugin-to-self --json > <scratch>/ins.json; echo "exit=$?"` 뒤
   `python3 -c 'import json,sys; c=json.load(open(sys.argv[1]))["context"]; ...' <scratch>/ins.json`로
   `agents/`, `skills/`, `claude plugin validate`, `bash -n`, `한국어`, `쉬운 말`, `Edit 부분 수정`이 모두 있고
   `.claude/agents/*.md`, `실행 코드가 없는`이 없음을 본다. `context` 키가 없으면(KeyError) 파싱 실패다.
3. 파이프(`| grep`)로 종료코드를 가리지 않는다. 출력은 scratchpad 파일로 받아 따로 grep한다.

### D3. `.claude/CLAUDE.md` — 구획 밖은 다시 쓰고, 구획 안은 한 곳만

**방법:** Edit 두 번. (a) 1행부터 템플릿 안내 주석 끝(`install.sh 를 쓰면 알아서 덧붙인다. -->`)과 그 뒤 빈 줄까지를 아래 새 문안으로 바꾼다.
(b) 구획 안 한 곳을 바꾼다. 구획의 나머지 바이트(뒤에 공백이 붙은 `직접 부를 수 있다. ` 줄 포함)는 손대지 않는다 — 그래서 Write 전체 재작성을 쓰지 않는다.

**(b) 구획 안 정확한 수정 (가정 A3):**
- 옛: `` `regression-verifier`(테스트가 있을 때, 동시) ``
- 새: `` `regression-verifier`(조건부, 동시) ``
- 그 밖의 구획 안 글자, `.claude/agents/`·`.claude/skills/orchestra/SKILL.md` 경로, `순서:` 줄은 그대로다.
  "조건부"의 뜻은 바로 다음 줄 "판정 기준은 `orchestra` 스킬에 있다"가 가리키는 orchestra가 정한다. 메인 spec `analyzer-option-generation`이 같은 표기 `regression-verifier(조건부)`를 쓴다.

**템플릿 안내 주석 처리 — 지운다.** 그 주석("이 파일을 통째로 복사하지 마라 … 끝에 덧붙여라")의 뜻은 새 문안 "표식 구획" 절의 평문으로 옮긴다.
이유: 이 파일은 이제 이 저장소 개발 지침이고, 구획만 뽑아 쓰는 방법은 README가 안내한다. 주석은 구획 밖이라 지워도 설치 결과(구획)가 바뀌지 않는다.

**구획 밖 금지 글자 (깨면 설치가 망가진다):**
- `init-SDD:begin`, `init-SDD:end` — 구획 밖에 한 번도 쓰지 않는다. 확인: `grep -c 'init-SDD:begin' .claude/CLAUDE.md` → 1, `grep -c 'init-SDD:end' .claude/CLAUDE.md` → 1.
- `순서:`로 **시작하는** 줄 — 구획 밖에 두지 않는다(`grep -c '^순서:' .claude/CLAUDE.md` → 1).
- 리치 마크다운 토큰 이름을 글자 그대로 쓰지 않는다(무결성 grep에 걸린다). 필요하면 `'ORCA_RICH''_MD'`처럼 끊어 쓴다.

**(a) 구획 밖 새 문안 (worker는 이 글을 그대로 쓴다. 표·코드블록 모양 포함):**

````markdown
# 이 저장소를 고칠 때 (개발자 안내)

이 저장소는 Claude Code 플러그인 `sdd`의 원본이다. 저장소 루트가 곧 플러그인 루트다.
이 파일은 이 저장소를 고치는 세션이 읽는 프로젝트 지침이다. 루트는 플러그인 루트라서 루트에 `CLAUDE.md`를 두지 않는다.

## 띄우기

저장소 루트에서 `claude --plugin-dir .`로 띄운다. `--plugin-dir`이 같은 이름으로 설치된 플러그인보다 우선하므로
고친 `agents/`·`skills/`가 그대로 실린다. 에이전트 이름에는 `sdd:`를 붙인다(예: `sdd:worker`).

## 저장소 구조

| 경로 | 무엇 |
|---|---|
| `.claude-plugin/` | 플러그인 선언 `plugin.json`과 마켓플레이스 목록 `marketplace.json` |
| `agents/` | 서브에이전트 지시문 8개 (파이프라인 7개 + 보조 `code-explorer`) |
| `skills/` | 스킬 원본 — `orchestra`(지휘), `sdd-rules`(공용 규칙), `sdd-sync`(spec 병합), `init`(`/sdd:init`) |
| `bin/` | PATH에 실리는 실행 파일 — `sdd-openspec`(openspec 1.14.1 고정 래퍼), `sdd-init`(`/sdd:init`의 실행부) |
| `hooks/` | SessionStart 훅 (`hooks.json`, `session-start.sh`) |
| `openspec/` | 이 저장소의 사양(`specs/`)과 진행 중인 change(`changes/`). `openspec/.sdd`는 이 저장소의 훅 표식이다 |
| `install.sh`, `.claude/skills/init-sdd/` | 기존 설치 방식(복사·링크). 실전 검증 뒤 없앤다 |
| `.claude/settings.json` | 이 저장소의 개발 권한. `install.sh`의 복사 원본이자 `/sdd:init` 권한 목록의 원본이다 |
| `docs/`, `evals/` | 현장 검증 기록 양식과 `claude plugin eval` 사례 |

## 이 저장소도 SDD로 개발한다

일하는 방식은 아래 표식 구획과 `orchestra` 스킬(`skills/orchestra/SKILL.md`)을 따른다. 작은 작업·큰 작업 경로와 판정 기준은 거기에 있다.

- 구획 안의 `.claude/agents/`, `.claude/skills/orchestra/SKILL.md` 경로는 설치 대상 프로젝트 기준이다.
  이 저장소에서는 `agents/`, `skills/orchestra/SKILL.md`로 읽는다.
- openspec 명령은 `sdd-openspec`(또는 `./bin/sdd-openspec`)으로 친다.
- `agents/*.md`와 `skills/**/SKILL.md`는 Edit로 필요한 부분만 고친다.

## 검증 명령

검증 명령은 저장소 루트에서 돌리고 종료코드로 판정한다. 테스트 스위트·빌드·CI는 없다.

```bash
claude plugin validate . --strict; echo "exit=$?"
claude plugin validate .claude-plugin/plugin.json --strict; echo "exit=$?"
./bin/sdd-openspec validate "<change 이름>" --strict; echo "exit=$?"
for f in install.sh bin/sdd-init bin/sdd-openspec hooks/session-start.sh; do bash -n "$f"; echo "$f rc=$?"; done
```

- 고친 `.md`마다 마크다운 무결성을 본다: 리치 마크다운 토큰 0개(`grep -c 'ORCA_RICH''_MD' <파일>`), 코드펜스 줄 수 짝수, frontmatter 온전.
- `install.sh`나 아래 표식 구획을 고쳤으면 `mktemp -d`로 만든 임시 프로젝트에서 `bash install.sh --dry-run`과 실제 설치를 돌려 본다.
  이 저장소 안에서는 돌리지 않는다.

## 커밋 규칙

- 커밋은 작업 단위로 나눈다. 예: 설정과 spec / 지침 파일 / README / change 산출물. 여러 단위를 한 커밋에 섞지 않는다.
- 커밋은 finalizer가 한다. 메시지는 기존 꼴(`docs(spec): ...`, `chore(openspec): ...`)을 따른다.

## 표식 구획

아래 표식 구획은 기존 설치 방식(`install.sh`, `init-sdd`)이 대상 프로젝트 `CLAUDE.md` 끝에 뽑아 붙이는 조각의 원본이다.
원본은 저장소에 이 한 벌뿐이다. 이 파일을 통째로 복사하지 않는다 — 구획만 뽑아 붙인다(방법은 `README.md`).

- 구획 안은 되도록 고치지 않는다. 고칠 때는 `skills/orchestra/SKILL.md`와 `README.md`의 파이프라인 순서를 함께 맞추고,
  임시 프로젝트 설치로 구획이 그대로 옮겨지는지 확인한다.
- 구획 밖에는 표식 문자열을 쓰지 않는다. `install.sh`가 그 문자열로 구획을 찾아서, 밖에 쓰면 엉뚱한 줄부터 뽑힌다.
- 파이프라인 순서 줄은 구획 안에만 둔다.

````

(위 바깥 펜스 네 개짜리는 이 design.md 안에서 감싸려고 쓴 것이다. 실제 파일에는 안쪽 내용만 들어간다. 마지막 빈 줄 다음에 바로 구획 시작 표식 줄이 온다.)

**받아들일 조건 대조:** `claude --plugin-dir .`, "SDD로 개발", `claude plugin validate . --strict`, `claude plugin validate .claude-plugin/plugin.json --strict`,
`sdd-openspec validate`(`./bin/sdd-openspec validate` 안에 들어 있다), `bash -n`, "커밋은 작업 단위로 나눈다", `agents/`·`skills/`·`bin/`·`hooks/`·`.claude-plugin/` 구조 표 — 모두 구획 밖에 있다.

**`claude -p` 탐침 문장:** `검증 명령은 저장소 루트에서 돌리고 종료코드로 판정한다.` — 구획 밖에만 있는 새 문장이다(지금 저장소 어디에도 없음, 실측).

**구획 계약 대조 (`sdd-install-script`, `init-sdd-skill`, `sdd-plugin`, `analyzer-option-generation`):**

| 계약 | 이 설계에서 |
|---|---|
| 조각 원본은 `.claude/CLAUDE.md` 마커 구획 한 벌 | 위치·마커 그대로. 구획 밖 마커 글자 금지 |
| `^순서:` 줄은 `openspec/` 밖에서 `.claude/CLAUDE.md` 하나뿐 | 구획 안 1줄 그대로, README에도 없음 |
| 마커 각각 정확히 1번 | 구획 밖 금지로 보장 |
| `install.sh` 실제 설치 뒤 대상 구획 = 원본 구획 | 묶음 5에서 `diff` rc=0 실측 |
| `init-sdd`가 `install.sh` + `.claude/CLAUDE.md` 함께 있는 곳을 원본으로 찾는다 | 두 파일 위치 그대로 |
| 루트 `CLAUDE.md` 없음 | 만들지 않는다 |
| 두 경로 순서가 orchestra·README와 같다 | 순서 줄 그대로, 괄호만 정본 표기 |

### D4. README — 절 단위 Edit로 다시 짜기, 배치와 계약

**방법 (가정 A6):** README는 **Write로 새로 쓰지 않는다.** 아래 "절별 내용" 표(옛 행 → 새 절)대로 **절 단위 Edit를 위에서부터 차례로** 한다.
이유: 메인 spec `agent-instructions/analyzer-option-generation`의 "지침 문서 수정은 파일을 손상시키지 않아야 한다"가
이미 있는 지침·문서 파일의 전체 재작성을 막고 부분 수정을 요구한다(SHALL). 적용 범위가 "그 변경이 수정한 지침 파일과 문서 파일 전부"라 README도 들어간다.
- 절을 옮기는 곳(옛 "쓰는 법"~"만들어지는 파일" 블록을 위로, "개발" 절을 맨 아래로)은 **새 자리에 Edit로 넣고 → 옛 자리를 Edit로 지우는** 두 번이다.
  옮기는 글은 `git show HEAD:README.md | sed -n '<옛 행>p'`로 원문을 보고 글자 그대로 옮긴다. 이동 뒤 아래 "이동 대조"(M1~M5) `diff`로 계획한 차이만 남았는지 본다.
- 줄 번호는 모두 **HEAD 기준**이다. 앞 Edit로 줄이 밀리니 Edit의 `old_string`은 줄 번호가 아니라 글자로 잡는다.
- 같은 파일이라 묶음 4는 worker 한 명이 4.1~4.9를 순서대로 한다. Edit가 "여러 곳과 맞는다"로 실패하면 앞뒤 줄을 더 붙여 유일하게 만든다
  (예: 옛 블록 지우기는 `\n## 쓰는 법\n`처럼 앞 줄바꿈을 넣어 새 자리의 `### 쓰는 법`과 구별한다).
- 끝난 뒤 무결성 검사와 아래 계약 grep을 **반드시** 돌린다. `.claude/CLAUDE.md`(D3)와 `config.yaml`(D2)도 Edit다.

**Edit 순서 (위에서부터. 각 단계의 글자는 아래 "절별 내용" 표와 문안 블록을 따른다):**

| 단계 | 옛 행(HEAD) | 하는 일 |
|---|---|---|
| E1 | 5~9 | 소개 문단 본문(3행 굵은 줄은 그대로)을 "소개 문단" 문안의 본문으로 바꾸고, 그 뒤에 빈 줄 + "빠른 시작" 문안을 붙인다(표는 옛 26~30행 글자 그대로) |
| E2 | 24~31 | `## 전제 조건` 절(제목·빈 줄·표·뒤 빈 줄)을 `## 작동 방식` + 빈 줄 + 옛 224~298행 블록으로 바꾼다. 옮기면서 바꾸는 것은 네 줄뿐: `## 쓰는 법`·`## 7개 서브에이전트`·`## 만들어지는 파일` → `###`, regression-verifier 표 행 → 아래 표의 새 글자 |
| E3 | 74~100 | 플러그인 하위 절 나누기: `**훅 켜기·끄기:** ` 머리 → `### 훅 켜기·끄기` 제목(+ 줄 끝에 한 줄 추가), 그 뒤 `### 권한` 절 삽입, `**업데이트:**` → `### 업데이트`, `**팀 배포:** ` 머리 → `### 팀 배포` 제목, `**Windows:** ` 머리 → `### Windows` 제목 |
| E4 | 102~223 | 옛 102행 앞에 `### 기존 설치 방식 (폐기 예고)` + 머리말 삽입. 제목 여섯 개(옛 102·111·131·159·169·187행) `###` → `####`. 방법 1 확인 줄 삽입·`install.sh --dry-run` 글자, 방법 2 인용 블록 끝 한 줄 추가, 규칙 심기 첫 줄 추가 |
| E5 | 224~298 | 옛 작동 방식 블록(`## 쓰는 법`부터 `## 커스터마이즈` 앞 빈 줄까지)을 지운다. E2에서 새 자리에 옮긴 뒤에만 한다 |
| E6 | 299~355 | 커스터마이즈 본문(옛 301~305행) 교체 → `## 개발` 절(옛 307~317행) 지우기 → 알아 둘 것 다섯 곳 수정 → 파일 끝(옛 355행 뒤)에 빈 줄 + `## 개발` 절 + 한 줄 추가 |

**이동 대조 (Edit가 끝난 뒤. `awk`는 이 환경 로캘에서 한글 문자열 `==` 비교가 틀리므로 반드시 `LC_ALL=C`를 붙인다 — designer가 실측):**
- M1 작동 방식 블록: `diff <(git show HEAD:README.md | sed -n '224,298p') <(LC_ALL=C awk '$0=="### 쓰는 법"{f=1} $0=="## 설치"{f=0} f' README.md)` →
  차이가 정확히 네 군데(`1c1`, `38c38`, `47c47`, `58c58` 꼴): 세 제목의 `##`→`###`와 regression-verifier 행. 그 밖의 차이가 있으면 실패
- M2 개발 절: `diff <(git show HEAD:README.md | sed -n '307,316p') <(LC_ALL=C awk '$0=="## 개발 (이 저장소를 고칠 때)"{f=1} f' README.md)` → 끝에 `검증 명령과 커밋 규칙은` 한 줄 추가(`10a11`)뿐
- M3 전제 조건 표: `diff <(git show HEAD:README.md | sed -n '26,30p') <(LC_ALL=C awk '$0=="## 빠른 시작"{f=1} $0=="## 이게 왜 필요한가"{f=0} f' README.md | command grep '^|'); echo "rc=$?"` → `rc=0`
- M4 설치 절: `diff <(git show HEAD:README.md | sed -n '32,223p') <(LC_ALL=C awk '$0=="## 설치"{f=1} $0=="## 커스터마이즈"{f=0} f' README.md)` →
  차이가 E3·E4에서 계획한 것뿐이다(제목 삽입·강등, 굵은 머리 제거, `### 권한`·폐기 예고 머리말·방법 1 확인 줄·방법 2 인용 한 줄·규칙 심기 첫 줄 추가, `--dry-run` 은 → `install.sh --dry-run` 은).
  계획에 없는 줄의 삭제·변경이 하나라도 있으면 실패
- M5 알아 둘 것: `diff <(git show HEAD:README.md | sed -n '318,355p') <(LC_ALL=C awk '$0=="## 알아 둘 것"{f=1} $0=="## 개발 (이 저장소를 고칠 때)"{f=0} f' README.md)` →
  차이가 옛 336~355행 안(아래 "알아 둘 것에서 바꿀 것" 다섯 곳)과 맨 끝 빈 줄 하나 추가(`## 개발` 절을 뒤에 붙이며 생김)뿐이다

**목차 (제목 글자 그대로):**

```
# init-SDD
  (굵은 한 줄 + 소개 한 문단)
## 빠른 시작
## 이게 왜 필요한가
## 작동 방식
### 쓰는 법
### 일의 크기에 따라 경로가 갈린다
### 7개 서브에이전트
### 보조 에이전트: code-explorer
### 만들어지는 파일
## 설치
### 먼저 고른다 — 플러그인인가, 복사 방식인가, 링크 방식인가
### 플러그인으로 설치 (권장)
### 훅 켜기·끄기
### 권한
### 업데이트
### 팀 배포
### Windows
### 기존 설치 방식 (폐기 예고)
#### 기존 방식에서 플러그인으로 옮기기
#### 방법 1 — install.sh
#### 방법 2 — 손으로
#### CLAUDE.md 는 복사하지 말고 **합쳐라**
#### 이름이 겹칠 수 있는 파일
#### 설치 확인
### 프로젝트 규칙 심기 (빼먹으면 에이전트가 스택을 스스로 고른다)
## 커스터마이즈
## 알아 둘 것
## 개발 (이 저장소를 고칠 때)
```

**"빠른 시작"과 "`## 설치` 맨 앞 고르는 표"를 함께 지키는 배치:**
- `## 빠른 시작`은 `## 설치`와 **별도 절**로, 소개 문단 바로 다음에 둔다. 첫 화면 순서가 소개 → 설치 두 줄 + `/sdd:init`이 된다.
- `## 설치`의 **첫 하위 절은 `### 먼저 고른다 — ...`이고 그 첫 내용이 고르는 표**다. `## 설치` 제목과 이 하위 제목 사이에는 아무 글도 두지 않는다
  (`install.sh` 164행 "'먼저 고른다' 절", init-sdd 스킬 "`## 설치` 맨 앞"이 그대로 맞는다).
- 설치 절만 읽어도 설치할 수 있게(`sdd-install-script` "README의 설치 흐름"), `### 플러그인으로 설치 (권장)`에 **빠른 시작과 같은 두 줄 코드블록과 `/sdd:init`을 다시 싣는다.**
  같은 README 안의 두 줄 반복이라 "설치 안내는 README 한 곳에만"(파일 간 사본 금지)과 부딪히지 않는다.

**절별 내용 (옛 README 행 번호(HEAD) → 새 위치). 각 행은 위 "Edit 순서"의 단계 안에서 Edit로 바꾼다. "그대로"는 글자 그대로(제목 단계만 바뀔 수 있다), 옛 문장은 "바꿀 것"만 고친다:**

| 새 절 | 내용 출처 | 바꿀 것 |
|---|---|---|
| 소개 한 문단 | 옛 3~9행 | 아래 "소개 문단" 문안으로 교체. `.claude/`의 에이전트를 얹는다는 서술을 없앤다 |
| `## 빠른 시작` | 옛 26~30행 전제 조건 표, 60~69행 | 아래 "빠른 시작" 문안(E1). 옛 `## 전제 조건` 절은 E2에서 없어진다 |
| `## 이게 왜 필요한가` | 옛 11~22행 | 그대로(이미 `analyzer-option-generation` 계약을 만족) |
| `## 작동 방식` | 새 제목 (E2) | 제목 + 빈 줄만. 아래 다섯 절을 묶는다 |
| `### 쓰는 법` | 옛 224~246행 (E2로 이동) | 그대로(제목만 `##`→`###`). `/sdd:orchestra`(복사·링크 방식은 `/orchestra`) 유지 |
| `### 일의 크기에 따라 경로가 갈린다` | 옛 248~259행 (E2로 이동) | 그대로(표의 경로·호출 수·묻는 횟수 유지) |
| `### 7개 서브에이전트` | 옛 261~273행 (E2로 이동) | 제목 `##`→`###`. regression-verifier 행만 이 글자로: ``| `regression-verifier` | 기존 동작이 깨졌는지 (읽기 전용, reviewer와 병렬). 큰 작업이고, 실행 코드가 바뀌었고, 테스트 명령이 있을 때만(`orchestra` 기준) | sonnet |`` |
| `### 보조 에이전트: code-explorer` | 옛 275~279행 (E2로 이동) | 그대로 |
| `### 만들어지는 파일` | 옛 281~297행 (E2로 이동) | 그대로(제목만 `##`→`###`. `.openspec.yaml` 행 글자 유지) |
| `### 먼저 고른다 — ...` | 옛 34~56행 | 그대로(표 세 줄 글자 유지) |
| `### 플러그인으로 설치 (권장)` | 옛 58~72행 | 두 줄 코드블록 + 로컬 경로 등록 + `/sdd:init`이 하는 일 + 스캐폴드 불필요 안내(옛 71~72행 그대로) |
| `### 훅 켜기·끄기` | 옛 74~76행 (E3) | 제목 + 빈 줄을 넣고 옛 74행 머리 `**훅 켜기·끄기:** `를 뺀다. 나머지 글자 그대로. 옛 76행 다음 줄에 `다음 세션부터 훅이 지휘 규칙을 넣는다.` 한 줄 |
| `### 권한` | 새로 (E3) | "`/sdd:init`은 권한 목록을 보여 주고 동의를 받은 뒤 `.claude/settings.local.json`에만 빠진 줄을 더한다. 공유 `.claude/settings.json`은 고치지 않는다." (사실 출처: `skills/init/SKILL.md`, `bin/sdd-init`) |
| `### 업데이트` | 옛 78~86행 (E3) | `**업데이트:**` 한 줄을 `### 업데이트`로. 나머지 그대로(두 명령 → 재시작 → `version` 올리기) |
| `### 팀 배포` | 옛 88~98행 (E3) | 제목 + 빈 줄을 넣고 옛 88행 머리 `**팀 배포:** `를 뺀다. 나머지 그대로(JSON 포함) |
| `### Windows` | 옛 100행 (E3) | 제목 + 빈 줄을 넣고 머리 `**Windows:** `를 뺀다. 나머지 그대로 |
| `### 기존 설치 방식 (폐기 예고)` | 새 머리말 (E4, 옛 102행 앞) | "복사 방식(`install.sh`)과 링크 방식(`init-sdd` 스킬)은 기존 사용자를 위해 남아 있다. 실전 검증 뒤 없앤다. 새로 시작하면 플러그인을 써라." |
| `#### 기존 방식에서 플러그인으로 옮기기` | 옛 102~109행 (E4) | 제목만 `###`→`####`. 나머지 그대로 |
| `#### 방법 1 — install.sh` | 옛 111~129행 (E4) | 제목 `###`→`####`. 옛 123행 끝 "`--dry-run` 은"(두 번째 것, 다음 줄 "무엇을 복사할지와"로 이어짐)을 "`install.sh --dry-run` 은"으로 고친다(받아들일 조건의 글자 `install.sh --dry-run`). 옛 119행 코드펜스 닫는 줄 뒤 빈 줄 다음, 옛 121행 "그 다음 Claude Code를 **새 세션으로**" 앞에 이 한 줄 + 빈 줄을 넣는다: ``설치가 끝나면 대상 프로젝트 `CLAUDE.md` 끝에 지시문 조각이 붙었는지 본다: `grep -c 'init-SDD:begin' CLAUDE.md` → `1`.`` (계약: 복제 → 이동 → `bash install.sh` → **CLAUDE.md 합쳐졌는지 확인** → 새 세션) |
| `#### 방법 2 — 손으로` | 옛 131~157행 (E4) | 제목 `###`→`####`. 나머지 그대로(인용 블록 첫 문장 "이 저장소에 git으로 커밋돼 있지 않다"는 사실이라 유지). 인용 블록 끝(옛 157행 `> 버전에 맞는 걸 새로 만들어라.`) 다음 줄에 옛 347행 안내를 옮겨 이 한 줄을 더한다: ``> 이미 깔린 그 파일들은 CLI를 올린 뒤 `openspec update`로 갱신한다(스킬 폴더가 남아 있을 때만 동작한다).`` |
| `#### CLAUDE.md 는 복사하지 말고 **합쳐라**` | 옛 159~167행 (E4) | 제목만 `###`→`####`. 나머지 그대로(`sed -n '/init-SDD:begin/,/init-SDD:end/p'` 방법 유지, 조각 본문 코드블록 금지) |
| `#### 이름이 겹칠 수 있는 파일` | 옛 169~185행 (E4) | 제목만 `###`→`####`. 나머지 그대로(이 절의 `.claude/agents/...` 경로는 복사 방식 설명이라 허용) |
| `#### 설치 확인` | 옛 187~203행 (E4) | 제목만 `###`→`####`. 나머지 그대로(세 스킬만, `openspec-*` 필수 아님, 이미 설치한 프로젝트 안내 4가지) |
| `### 프로젝트 규칙 심기 ...` | 옛 205~222행 (E4) | 제목 단계 `###` 그대로. 제목 뒤 빈 줄 다음, 옛 207행 앞에 "플러그인은 `/sdd:init`이 초안을 보여 주고 동의 뒤 적는다. 복사·링크 방식은 손으로 적는다." 한 줄 + 빈 줄 추가. 나머지 그대로 |
| `## 커스터마이즈` | 옛 299~305행 (E6) | 제목 그대로, 본문(옛 301~305행)을 아래 "커스터마이즈" 문안의 본문으로 |
| `## 알아 둘 것` | 옛 318~355행 (E6) | 아래 "알아 둘 것에서 바꿀 것" 다섯 곳만 Edit |
| `## 개발 (이 저장소를 고칠 때)` | 옛 307~316행 (E6으로 맨 끝에 이동) | 그대로 + 옛 316행 다음 줄에 "검증 명령과 커밋 규칙은 `.claude/CLAUDE.md`에 있다." 한 줄. 파일은 그 줄과 줄바꿈 하나로 끝난다 |

**소개 문단 (글자 그대로):**

```markdown
**어떤 프로젝트에든 얹어서 바로 시작하는 SDD(사양 주도 개발) 초기 구조.**

Claude Code 플러그인 `sdd`를 설치하고 프로젝트에서 `/sdd:init`을 한 번 돌리면, 그 프로젝트의 Claude Code가
"요구사항 정리 → 설계 → 구현 → 리뷰 → 회귀 검증 → 커밋" 순서로 일하게 된다. 각 단계는 전용 서브에이전트가 맡고,
사양과 작업 기록은 프로젝트의 `openspec/`에 쌓인다. 기본(작은 작업)은 `preparer → worker → reviewer → finalizer`이고,
큰 작업은 `preparer → designer → worker → reviewer (+ regression-verifier) → finalizer`다. `regression-verifier`(회귀 검증)는
큰 작업이고, 실행 코드가 바뀌었고, 프로젝트에 테스트 명령이 있을 때만 reviewer와 함께 붙는다(기준은 `orchestra` 스킬).
분석과 **사용자가 방안 선택**하는 단계는 기본 경로에는 없다 — `"분석해줘"`, `"방안 뽑아줘"`처럼 방안 비교를 요청하면 그때 열린다.
```

**빠른 시작 (글자 그대로. 표는 옛 전제 조건 표 그대로 옮긴다):**

````markdown
## 빠른 시작

Claude Code 안에서 두 줄:

```text
/plugin marketplace add CHO-YoungSeok/init-SDD
/plugin install sdd@sdd-marketplace
```

그 뒤 SDD를 쓸 프로젝트에서 한 번:

```text
/sdd:init
```

이제 평소처럼 말하면 된다(예: `로그인에 2단계 인증 추가해줘`). 다음 세션부터 훅이 지휘 규칙을 넣는다.
다른 설치 방식(복사·링크)과 자세한 설명은 아래 "설치"에 있다.

필요한 것:

(옛 26~30행 전제 조건 표를 그대로)
````

**커스터마이즈 (글자 그대로):**

```markdown
## 커스터마이즈

플러그인으로 깐 파일은 업데이트 때 새 판으로 바뀐다. 오래 쓸 수정은 이 저장소를 포크해서 고치고,
`claude --plugin-dir <포크 경로>`로 띄우거나 포크를 마켓플레이스로 등록해 쓴다. 복사·링크 방식이면 대상 프로젝트의 `.claude/agents/`를 고친다.

- **모델 바꾸기** — 각 에이전트 파일(`agents/<이름>.md`)의 `model:` 한 줄이 기본값이다. 바꾸려면 그 줄을 고친다.
- **단계 늘리기** — `agents/`에 파일 하나 추가하고 `skills/orchestra/SKILL.md`의 파이프라인에 배선한다
- **프로젝트 규칙 주입** — `openspec/config.yaml` 의 `context:` 와 `rules:`.
  거기 적은 내용이 모든 산출물 작성에 제약으로 들어간다. 에이전트 파일을 고치는 것보다 이게 낫다
- **스킬 추가** — 쓰면서 필요한 걸 `skills/`에 늘려 간다. 이 구조는 그걸 전제로 만들었다
```

**알아 둘 것에서 바꿀 것 (E6. 나머지 항목은 옛 318~335행 그대로. 각 항목을 Edit 한 번씩):**

1. 옛 336행("`openspec init` 이 `/opsx:propose` 같은 명령 6개도 깔아 준다.") 한 줄만 이 글자로 바꾼다(337~338행 그대로):
   ``- `openspec init --tools claude`로 초기화하면 `/opsx:propose` 같은 명령 6개도 깔린다(`/sdd:init`은 깔지 않는다).``
2. 옛 340행("다른 언어로 쓰려면 `.claude/agents/*.md` 와 … 를 번역하고,")만 이 글자로 바꾼다(339·341행 그대로):
   ``  다른 언어로 쓰려면 포크에서 `agents/*.md`와 `skills/{orchestra,sdd-rules,sdd-sync,init}/SKILL.md`를 번역하고,``
3. 옛 342~343행("OpenSpec CLI 1.12 기준으로 만들었다. …" 항목 두 줄)을 이 두 줄로 바꾼다:
   ```
   - **OpenSpec 버전:** 플러그인은 `sdd-openspec`이 1.14.1을 고정해 실행한다. 복사·링크 방식은 PATH의 `openspec`(1.12 이상)을 쓴다.
     버전이 올라 명령이 바뀌어도 에이전트는 `openspec instructions` 출력을 정답으로 삼아 대부분 따라간다.
   ```
4. 옛 344~347행("**이 저장소의 `.claude/skills/openspec-*` 은 …"으로 시작하는 항목 네 줄)을 **지운다.** 복사하지 말라는 경고와 `openspec init --tools claude`는 `#### 방법 2 — 손으로` 인용 블록에 이미 있고,
   347행의 "CLI를 올린 뒤 `openspec update`로 갱신" 안내는 E4에서 같은 인용 블록 끝 한 줄로 옮겨 둔다(위 표의 방법 2 행).
5. 옛 348~355행 `**버전 확인:**` 블록을 이 글자로 바꾼다(코드블록은 `grep generatedBy` 줄을 빼고, 앞 문장을 생성기 버전 비교가 아닌 실제 출력 비교로 고친다):
   ````
   - **버전 확인:**
     ```bash
     openspec --version        # 플러그인이면 sdd-openspec --version
     ```
     에이전트 파일이 가정한 CLI 세부와 실제 출력이 다르면 정답은 `openspec status --change <이름> --json`의 실제 출력이다.
     에이전트 파일도 전부 "경로와 상태는 CLI에서 얻는다. 짐작하거나 하드코딩하지 마라"고 말한다.
   ````

**README가 지켜야 할 메인 spec 계약 키워드 (전수 grep: `grep -rn 'README' openspec/specs` 58줄을 8개 spec에서 대조).**
판정은 저장소 루트에서 `grep -cF '<키워드>' README.md` ≥ 1(따로 적은 것 제외). 위치 조건은 눈으로 본다.

| # | 출처 메인 spec (요구사항) | 키워드 (grep -F) | 위치·모양 조건 |
|---|---|---|---|
| K1 | distribution/sdd-plugin (플러그인 설치를 먼저) | `/plugin marketplace add` | 빠른 시작과 플러그인으로 설치 두 곳 |
| K2 | 〃 | `/plugin install sdd@sdd-marketplace` | 〃 |
| K3 | 〃 | `/sdd:init` | 〃 |
| K4 | 〃 (개발용 실행법) | `claude --plugin-dir .` | 개발 절 |
| K5 | 〃 | `기존 방식에서 플러그인으로 옮기기` | 기존 설치 방식 아래 |
| K6 | 〃 | `.claude/commands/opsx/`, `.claude/skills/openspec-*` | "필요 없다(지워도, 남겨도 된다)" 문장 안 |
| K7 | sdd-plugin (업데이트·팀 배포·실행 환경) | `claude plugin marketplace update sdd-marketplace`, `claude plugin update sdd@sdd-marketplace` | 업데이트 절, 재시작 문장 포함 |
| K8 | 〃 | `extraKnownMarketplaces`, `enabledPlugins` | 팀 배포 절 |
| K9 | 〃 | `Windows` | bash가 필요하다는 줄 |
| K10 | distribution/session-start-hook (훅 끄는 법) | `openspec/.sdd`, `/plugin disable sdd` | 표식이 켠다 / 지우면 꺼진다 / 커밋하면 팀원에게도 켜진다 |
| K11 | distribution/sdd-install-script (어느 방식을 쓸지) | `## 설치`, `### 먼저 고른다` | `## 설치` 다음 첫 줄이 이 하위 제목, 그 첫 내용이 표. 표 첫 행이 플러그인(권장) |
| K12 | 〃 | `init-sdd` | 고르는 표의 링크 방식 행 |
| K13 | 〃 | `방법 1 — install.sh`, `방법 2 — 손으로` | 기존 설치 방식 아래 |
| K14 | sdd-install-script (설치 안내는 README 한 곳) | `git clone`, `bash "$SDD_SRC/install.sh"`, `install.sh --dry-run`, `새 세션` | 복제 → 이동 → 설치 → CLAUDE.md 확인 → 새 세션 흐름 |
| K15 | 〃 | `openspec init --tools claude` | `openspec-*`·`opsx/`를 복사하지 말라는 경고 곁 |
| K16 | 〃 (README가 5종을/공용 스킬 두 개도 말한다) | `sdd-rules`, `sdd-sync`, `orchestra` | 손 설치 `cp` 명령과 `설치 확인` 둘 다. 그 두 곳에 다른 스킬 이름(`init`, `openspec-*` 필수 확인) 없음 |
| K17 | 〃 (이미 설치한 프로젝트) | `이미 설치한 프로젝트` | 두 스킬 새로 넣기·에이전트 새 판과 비교·`install.sh` 재실행으로 안 바뀜·모델 등급 스킬 지워도 됨 |
| K18 | sdd-install-script (조각 원본 한 벌) | `sed -n '/init-SDD:begin/,/init-SDD:end/p'` | 조각 본문 코드블록 없음 |
| K19 | distribution/init-sdd-skill (고르는 안내 본문은 README) | (K11과 같음) | — |
| K20 | agent-instructions/analyzer-option-generation ("이게 왜 필요한가") | `## 이게 왜 필요한가` | 관문 강제 아님·원할 때 연다·작은 작업 개입 지점 셋·큰 작업에 결정 기록+설계 요약 알림 |
| K21 | 〃 (경로 표와 묻는 횟수) | `일의 크기에 따라 경로가 갈린다`, `반드시` | 기본 경로에 analyzer 없음, 호출 4번/5~6번, 방안 선택은 analyzer를 부를 때 |
| K22 | 〃 (README 재확인) | `방안 최소 3가지 + 의견과 근거`, `부를 때만 돈다` | 7개 표 analyzer 행 |
| K23 | 〃 (세 문서 순서 일치) | `preparer → worker → reviewer → finalizer`, `preparer → designer → worker → reviewer (+ regression-verifier) → finalizer` | 소개 문단과 경로 표 |
| K24 | agent-instructions/code-explorer-role | `code-explorer`, `보조 에이전트` | 7개 표 밖 별도 절. 그 절(`### 보조 에이전트: code-explorer`)에 없어진 모델 등급 스킬 언급이 없다(`LC_ALL=C awk '$0=="### 보조 에이전트: code-explorer"{f=1} $0=="### 만들어지는 파일"{f=0} f' README.md`에 `모델 등급` 0건). README 전체 금지 grep은 쓰지 않는다 — `기존 방식에서 플러그인으로 옮기기`·`이미 설치한 프로젝트` 안내에는 그 말이 필요하다 |
| K25 | agent-instructions/openspec-metadata-marker-safety | `.openspec.yaml`, `마커만 덧붙임` | 만들어지는 파일 표의 `.openspec.yaml` 행 |
| K26 | (정본 orchestra 169행) regression-verifier 조건 | `실행 코드가 바뀌었고` | 소개 문단과 7개 표 행. 2곳 이상 |

해당 없음으로 확인한 spec: `agent-instructions/lite-default-path`(README 요구 없음. 경로 표기는 K23이 맡는다),
`process/field-validation-record`(요구 대상은 `evals/README.md`라 이 README와 무관).

**금지 키워드 (각각 결과 0이어야 한다):**

| 검사 | 기대 | 이유 |
|---|---|---|
| `grep -c '^순서:' README.md` | 0 | sdd-install-script: 조각 본문을 README에 싣지 않는다 |
| `grep -c '평가 모드' README.md` | 0 | analyzer-option-generation |
| `grep -ci 'agent-model-tier' README.md` | 0 | 은퇴한 capability |
| `grep -c 'grep generatedBy' README.md` | 0 | 이 저장소에 `openspec-*` 사본이 없어진다 |
| `grep -c 'switch_skill' README.md` | 0 | sdd-install-script "전환 스킬이 없다" |
| `grep -c '테스트가 있을 때' README.md` | 0 | regression-verifier 조건 축약 금지 |
| `grep -c '이 저장소의 .\?\.claude/skills/openspec' README.md` | 0 | 사본 전제 서술 삭제(옛 344행은 백틱이 끼어 있어 `.\?`로 받는다. HEAD에서는 1, 실측) |
| `grep -n '\.claude/agents' README.md` | 결과가 모두 `## 설치`의 복사·링크 방식 하위 절과 `## 커스터마이즈`의 "복사·링크 방식이면" 문장 안 | 플러그인 기준 경로 |
| `grep -c '관문이 사라졌다' README.md` | 0 | analyzer-option-generation MUST NOT |

### D5. 정리(삭제) — 정리 모드 worker, 경로 글자 그대로

삭제는 되돌릴 수 없어 공용 규칙상 정리 모드 worker가 tasks의 경로 글자 그대로만 지운다. 지우기 전에 경로마다 `git ls-files <경로> | wc -l` → 0과
`git check-ignore -q <경로>`(디렉터리면 그 안 파일 하나로) → 0을 확인하고, 하나라도 어긋나면 지우지 않고 보고한다.
`.gitignore` 줄은 남긴다(A2). 삭제는 커밋 diff에 나오지 않는다.

### D6. 묶음과 병렬

| 묶음 | 파일 | 누가 | 앞 묶음 의존 |
|---|---|---|---|
| 1 정리 | 무시된 7경로 | 정리 모드 worker | 없음 |
| 2 config | `openspec/config.yaml` | worker | 없음 (델타는 designer가 이미 씀) |
| 3 지침 | `.claude/CLAUDE.md` | worker | 없음 |
| 4 README | `README.md` | worker | 없음 |
| 5 통합 검증 | (쓰기: `<changeRoot>/verification.md`만) | worker | 1~4 전부 |

1~4는 파일이 겹치지 않아 동시에 돌려도 된다. 5는 마지막에 한 번.

### D7. 커밋 단위 (finalizer용 제안, 가정 A8)

1. `openspec/config.yaml` + 메인 spec sync 결과(`project-context-completeness`)
2. `.claude/CLAUDE.md`
3. `README.md`
4. change 산출물(`openspec/changes/apply-plugin-to-self/`)
정리(삭제)는 무시된 파일이라 커밋이 없다.

## Risks / Trade-offs

- [절 이동·Edit 중 계약 문구가 빠지거나 옮긴 글이 바뀜] → D4 이동 대조 M1~M5 `diff`, 키워드 표 K1~K26과 금지 표를 묶음 4와 5에서 두 번 돌린다. 하나라도 어긋나면 완료로 치지 않는다.
- [옛 블록 지우기 Edit가 새 자리와 겹쳐 "여러 곳과 맞는다"로 실패] → `old_string`에 앞 줄바꿈과 `##`/`###` 차이를 넣어 유일하게 잡는다. 절대 Write로 우회하지 않는다.
- [구획 밖에 마커 글자를 써서 설치 조각이 오염] → D3 금지 글자 grep + 묶음 5의 실제 설치 `diff` rc=0.
- [config 블록 교체 때 예시 주석을 잘못 잡아 YAML이 깨짐(실험에서 실제로 났다)] → 실제 키 `\ncontext: |` 기준으로 Edit, `openspec context` 출력의 `Warning` 0 + `instructions` JSON의 `context` 키로 확인.
- [README 두 곳에 같은 두 줄] → 같은 파일 안 반복이라 계약 위반은 아니다. 원격 주소가 바뀌면 두 곳을 함께 고쳐야 한다(A7: 지금은 `CHO-YoungSeok/init-SDD`).
- [`install.sh`·init-sdd 스킬이 README 절 이름을 가리킴] → 제목 글자 고정(Non-Goals). 묶음 5에서 `grep -c '^## 설치$'`·`grep -c '^### 먼저 고른다'` 각 1.
- [`claude -p` 탐침이 모델 응답이라 흔들림] → 탐침 문장을 짧고 독특하게 잡고, 실패하면 한 번 다시 돌린다. 두 번 다 실패면 멈추고 보고(지침 로드 전제 실패).
- [메인 spec `sdd-install-script`의 "이 두 가지가 스크립트를 검증하는 유일한 수단이다 — config context가 그렇게 규정" 문장] → `install.sh`에 대해서는 여전히 `bash -n`·`--dry-run`이 맞아 모순은 아니다. 문구 정돈은 ⑥ 범위.

## Migration Plan

배포 단계 없음. 되돌리기: 커밋 단위별 `git revert`. 지운 스캐폴드는 `openspec init --tools claude`로 언제든 다시 생긴다(`.gitignore`가 커밋을 막는다).
