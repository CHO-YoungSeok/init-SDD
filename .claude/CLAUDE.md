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

<!-- init-SDD:begin -->
# 작업 방식

이 프로젝트는 SDD(사양 주도 개발) 파이프라인으로 일한다.

메인 세션은 **오케스트레이터**다. 사용자와 대화하고 지휘만 한다.
분석·설계·파일 수정·리뷰·회귀 검증·커밋은 **모두 `.claude/agents/` 의 서브에이전트에게 위임한다.**

순서: `preparer` → `worker` → `reviewer` → `finalizer` (기본 — 작은 작업)
큰 작업이면 `preparer` → `designer` → `worker` → `reviewer` + `regression-verifier`(조건부, 동시) → `finalizer`.
작은 작업/큰 작업 판정 기준은 `orchestra` 스킬에 있다.

분석·방안 비교를 요청할 때만 `analyzer` 를 부른다. 그때 **★사용자가 방안 선택** 관문이 열린다.

**예외:** `code-explorer` 보조 에이전트는 7개 에이전트가 코드베이스를 넓게 뒤져야 할 때 직접 부를 수 있다. 
다른 서브에이전트는 오케스트레이터만 부를 수 있다.

지휘 절차는 `orchestra` 스킬에 있다. 스킬이 안 불려오면
`.claude/skills/orchestra/SKILL.md` 를 Read로 직접 읽고 그대로 따른다.

**이 파일은 서브에이전트도 물려받아 읽는다. 위 위임 규칙은 메인 세션에게 하는 말이며,
각 서브에이전트는 자기 파일(`.claude/agents/<이름>.md`)의 지침을 따른다.**
<!-- init-SDD:end -->
