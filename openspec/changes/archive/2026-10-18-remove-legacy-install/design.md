# Design

## Context

동기는 proposal.md "Why"에 있다. 지금 상태에서 설계에 영향을 주는 사실만 적는다.

- 기존 설치 방식의 흔적은 추적 파일 기준으로 `install.sh`, `.claude/skills/init-sdd/SKILL.md`(이 둘은 통째로 지운다)와
  `README.md`, `.claude/CLAUDE.md`, `skills/orchestra/SKILL.md`, `skills/sdd-rules/SKILL.md`, `openspec/config.yaml`,
  `docs/field-validation.md`(34행 각주, 범위 밖)에 있다. `agents/`, `bin/`, `hooks/`, `skills/init`, `skills/sdd-sync`,
  `evals/`, `.claude-plugin/`, `.gitignore`, `.claude/settings.json`에는 없다(grep 확인).
- 이 저장소에는 훅 표식 `openspec/.sdd`가 있어 SessionStart 훅이 지휘 규칙 요약을 이미 넣는다. 그래도 `.claude/CLAUDE.md`의
  지휘 지침은 남긴다 — 서브에이전트도 이 파일을 물려받아 읽고, `agent-instructions/analyzer-option-generation`이
  `.claude/CLAUDE.md`의 파이프라인 순서 문구를 orchestra·README와 맞추라고 요구한다.
- `.claude/skills/` 아래 추적 파일은 `init-sdd` 하나뿐이고, 디스크에도 그것만 있다. 지우면 `.claude/skills/`가 빈 디렉터리가 된다.
- 메인 spec은 worker가 고치지 않는다(finalizer의 sync 몫). 그래서 받아들일 조건 3번 grep은 worker 단계에서
  `openspec/` 전체를 빼고 돌리고, 메인 spec 쪽은 델타 문구에 금지 낱말이 없다는 것으로 보증한다(설계 단계에서 확인함).

## Goals / Non-Goals

**Goals:**
- 설치 수단을 플러그인 하나로 줄이고, 지시문·README·사양에서 대비 규칙과 이전 안내를 걷어 낸다.
- `.claude/CLAUDE.md`를 이 저장소 기준(경로 `agents/`, `skills/orchestra/SKILL.md`, 이름 `sdd:<이름>`)의 표식 없는 지침으로 만든다.

**Non-Goals:**
- 훅 요약(`hooks/session-start.sh`)과 `.claude/CLAUDE.md` 지휘 지침의 겹침을 없애는 것. 둘은 독자가 다르다(훅은 메인 세션,
  CLAUDE.md는 서브에이전트까지). 겹침은 그대로 둔다.
- `docs/field-validation.md` 고치기, 플러그인 버전 올리기, `.claude/settings.json` 내용 바꾸기.

## Decisions

### D1. 은퇴하는 두 capability는 REMOVED로 전부 지우고 `retire_capabilities: true`

`distribution/sdd-install-script`(14개)·`distribution/init-sdd-skill`(23개) 요구사항을 모두 `## REMOVED`로 지운다.
`.openspec.yaml`에 마커를 붙였다. 실제 메인 spec 파일 삭제는 커밋 관문 승인 뒤 finalizer가 한다.

플러그인 쪽으로 옮길 것은 "설치 절차는 README 한 곳에 플러그인부터"의 앞부분(README 한 곳, 플러그인 설치)뿐이라
`distribution/sdd-plugin`의 README 요구사항에 "설치 절차는 README 한 곳에만"으로 합쳤다. "openspec CLI가 까는 것은 건드리지
않는다"는 `/sdd:init`의 `--tools none`(`distribution/sdd-init-command`)과 README의 스캐폴드 불필요 안내가 이미 맡는다.
`.claude/settings.local.json` 안내도 `/sdd:init`이 맡는다. 나머지(덮어쓰지 않기, 링크 걸기·풀기 등)는 플러그인에 해당이 없다.

### D2. 시나리오를 빼야 하는 요구사항은 MODIFIED가 아니라 REMOVED + ADDED

openspec 1.14.1은 MODIFIED 블록이 메인 spec의 시나리오를 빠뜨리면 `validate --strict`를 막는다(실측: "omits scenario(s) the current
spec still has"). 그래서 대비 규칙 시나리오를 없애야 하는 세 요구사항은 옛 이름을 REMOVED, 새 이름을 ADDED로 바꿔 끼운다.
- `sdd-plugin`: "…접두사 없는 이름으로 대비해야 한다" → "에이전트는 sdd 접두사 이름으로 불러야 한다"
- `sdd-plugin`: "README는 플러그인 설치와 이전 안내를 담아야 한다" → "README는 플러그인 설치를 한 길로 안내해야 한다"
- `code-explorer-invocation`: "code-explorer를 부르는 이름은 플러그인 접두사를 따라야 한다" → "code-explorer는 sdd 접두사 이름 하나로만 불러야 한다"

시나리오 이름이 그대로 맞는 나머지는 MODIFIED로 둔다. 버린 대안: 옛 시나리오 이름을 남기고 내용만 뒤집기 — 이름("대비 규칙이 두 곳에 한 번씩 있다")이
내용과 거꾸로 되어 읽는 사람을 속인다.

### D3. 메인 spec에 들어갈 문구에는 금지 낱말을 글자 그대로 쓰지 않는다

받아들일 조건 3번은 sync 뒤의 메인 spec도 대상으로 삼는다. 그래서 MODIFIED·ADDED 문구는 "설치 수단", "다른 설치 방식" 같은 말로 쓰고,
grep 명령이 들어가는 시나리오는 `install[.]sh`, `init-sd[d]`, `기존 설[치]`처럼 대괄호로 글자를 쪼갠다(이 저장소의 `'ORCA_RICH''_MD'` 관례와 같은 이유).
REMOVED 블록의 Reason/Migration은 메인 spec에 옮겨지지 않으므로 낱말을 써도 된다.

### D4. `.claude/CLAUDE.md`의 목표 모양

표식 두 줄과 "## 표식 구획" 절을 없애고, 구획 본문을 "## 이 저장소도 SDD로 개발한다" 절에 합친다. 절 위치는 지금 그 절 자리(저장소 구조 다음)다.
경로는 이 저장소 기준으로 바꾸므로 "구획 안의 `.claude/agents/` 경로는 설치 대상 기준이다" 안내 줄은 필요 없어진다.
그 밖의 절(제목·소개, 띄우기, 커밋 규칙)은 그대로 둔다. 바뀌는 절의 목표 문안은 다음과 같다(worker는 이 글자대로 옮긴다).

저장소 구조 표에서 바뀌는 행:
- `| \`install.sh\`, \`.claude/skills/init-sdd/\` | … |` 행을 지운다.
- `.claude/settings.json` 행 설명을 `이 저장소의 개발 권한. \`/sdd:init\` 권한 목록의 원본이다`로 바꾼다.

"## 이 저장소도 SDD로 개발한다" 절 전체(구획 본문을 합친 모양):

```markdown
## 이 저장소도 SDD로 개발한다

이 저장소는 SDD(사양 주도 개발) 파이프라인으로 일한다. 훅 표식 `openspec/.sdd`가 있어 SessionStart 훅도 아래 지휘 규칙의 요약을 넣는다.

메인 세션은 **오케스트레이터**다. 사용자와 대화하고 지휘만 한다.
분석·설계·파일 수정·리뷰·회귀 검증·커밋은 **모두 `agents/`의 서브에이전트(`sdd:<이름>`)에게 위임한다.**

순서: `preparer` → `worker` → `reviewer` → `finalizer` (기본 — 작은 작업)
큰 작업이면 `preparer` → `designer` → `worker` → `reviewer` + `regression-verifier`(조건부, 동시) → `finalizer`.
작은 작업/큰 작업 판정 기준은 `orchestra` 스킬에 있다.

분석·방안 비교를 요청할 때만 `analyzer` 를 부른다. 그때 **★사용자가 방안 선택** 관문이 열린다.

**예외:** `code-explorer` 보조 에이전트는 7개 에이전트가 코드베이스를 넓게 뒤져야 할 때 직접 부를 수 있다.
다른 서브에이전트는 오케스트레이터만 부를 수 있다.

지휘 절차는 `orchestra` 스킬(`sdd:orchestra`)에 있다. 스킬이 안 불려오면 `skills/orchestra/SKILL.md`를 Read로 직접 읽고 그대로 따른다.

- openspec 명령은 `sdd-openspec`(또는 `./bin/sdd-openspec`)으로 친다.
- `agents/*.md`와 `skills/**/SKILL.md`는 Edit로 필요한 부분만 고친다.
- 파이프라인 순서를 고치면 이 절, `skills/orchestra/SKILL.md`, `README.md`의 순서 문구를 함께 맞춘다.

**이 파일은 서브에이전트도 물려받아 읽는다. 위 위임 규칙은 메인 세션에게 하는 말이며,
각 서브에이전트는 자기 파일(`agents/<이름>.md`)의 지침을 따른다.**
```

"## 검증 명령" 절에서 바뀌는 곳:
- `for f in install.sh bin/sdd-init …` → `for f in bin/sdd-init bin/sdd-openspec hooks/session-start.sh; do bash -n "$f"; echo "$f rc=$?"; done`
- "`install.sh`나 아래 표식 구획을 고쳤으면 … 임시 프로젝트에서 … 돌려 본다. / 이 저장소 안에서는 돌리지 않는다." 두 줄을 지운다.

"## 표식 구획" 절(설명 문단, 세 개 글머리표)과 그 아래 `<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->` 구획 전체를 지운다
(본문은 위 절로 옮겼다). 파일 끝은 "## 커밋 규칙" 절이 된다 — 순서: 제목·소개 → 띄우기 → 저장소 구조 → 이 저장소도 SDD로 개발한다 → 검증 명령 → 커밋 규칙.

버린 대안: 구획 본문을 "# 작업 방식" 같은 별도 h1로 끝에 남기기 — 같은 파일에 "이 저장소도 SDD로 개발한다"와 "작업 방식"이 두 군데로 갈라져 같은 말(orchestra 경로, openspec 명령)을 두 번 하게 된다.

### D5. README

- "빠른 시작"과 "플러그인으로 설치": 두 줄 코드블록 하나를 한 줄짜리 `text` 코드블록 두 개로 나눈다. 앞 문장 "Claude Code 안에서 두 줄:"은
  "Claude Code 안에서 마켓플레이스를 등록하고:" / (두 블록 사이) "플러그인을 설치한다:"로 바꾼다. 두 절 모두 같은 모양.
- "빠른 시작" 28행: "다른 설치 방식(복사·링크)과 자세한 설명은 아래 "설치"에 있다." → "자세한 설명은 아래 "설치"에 있다."
- 필요한 것 표 OpenSpec CLI 행: 플러그인 칸만 남긴다 — 확인 `node --version`, `npx --version` (Node/npx만 있으면 된다 — `sdd-openspec`이 1.14.1을 받는다), 없으면 `Node.js 설치`.
- 60행: 괄호 "(복사·링크 방식으로 깐 프로젝트는 `/orchestra`)"를 지운다.
- "### 먼저 고른다 — …" 절(130~152행)을 지운다. 그 안의 플러그인 설명 문단(141~142행, "**플러그인**은 … `/sdd:init`이다.")만
  "플러그인으로 설치" 절 첫 문단으로 옮기고 첫 낱말 강조를 풀어 "에이전트와 스킬은 Claude Code 플러그인 `sdd`로 실린다. …"로 쓴다.
  절 제목 "### 플러그인으로 설치 (권장)"은 "### 플러그인으로 설치"로 바꾼다(고를 것이 없다).
- "### 기존 설치 방식 (폐기 예고)"부터 "**Claude Code를 새 세션으로 다시 열어야** …" 줄(211~319행)까지 통째로 지운다.
  다음 절 "### 프로젝트 규칙 심기"가 바로 "### Windows" 뒤에 온다.
- 323행: "플러그인은 `/sdd:init`이 초안을 보여 주고 동의 뒤 적는다. 복사·링크 방식은 손으로 적는다." → "`/sdd:init`이 초안을 보여 주고 동의 뒤 적는다. 나중에 고칠 때는 아래처럼 손으로 적는다."
- 346행 끝 문장 "복사·링크 방식이면 대상 프로젝트의 `.claude/agents/`를 고친다."를 지운다.
- 379행: "복사·링크 방식은 PATH의 `openspec`(1.12 이상)을 쓴다." 문장을 지운다. 383행 코드 `openspec --version        # 플러그인이면 sdd-openspec --version` →
  `sdd-openspec --version    # 1.14.1`. 385행의 `openspec status --change <이름> --json` → `sdd-openspec status --change <이름> --json`.

### D6. 지시문 두 개와 config.yaml

- `skills/orchestra/SKILL.md` 29~32행: "**에이전트 이름:** 아래 호출 예시는 플러그인 이름 `sdd:<이름>`을 쓴다." 한 문장만 남기고 나머지(접두사 없이 다시 부르기, 그 이유, 지운다는 예고)를 지운다.
  52행 "메인 세션이 직접 치는 `sdd-openspec` 명령(…)은 `sdd-openspec`이 PATH에 없으면 … `openspec`으로 바꿔 친다." 줄을 통째로 지운다.
- `skills/sdd-rules/SKILL.md` "쓰는 스킬" 절 19~21행: "- openspec 명령은 `sdd-openspec`으로 친다(플러그인이 고정 버전 1.14.1을 실행하는 래퍼). PATH의 `openspec`이 1.14.1 이상이면
  (`--version`으로 확인) `openspec`을 그대로 써도 된다." 로 끝낸다(“`sdd-openspec`이 PATH에 없으면 … 버전을 보고서에 적는다.” 부분 삭제).
  "code-explorer 부르기" 절 53~54행(`not found` 대비 규칙 두 줄)을 지운다. 절 수(일곱)는 바뀌지 않는다.
- `openspec/config.yaml` `context:`: 17행 끝의 `, install.sh`를 지우고, 18행(기존 설치 방식 줄)을 지우고, 23행을 `  - bash -n bin/sdd-init bin/sdd-openspec hooks/session-start.sh (문법 검사)`로, 24행(dry-run 줄)을 지운다.
  `context:` 키는 0칸 들여쓰기 그대로 둔다.

### D7. 파일 삭제

`git rm`이 아니라 일반 삭제로 지우고(커밋은 finalizer), 빈 디렉터리 `.claude/skills/`도 지운다. 경로는 tasks.md에 글자 그대로 적는다.

## Risks / Trade-offs

- [이미 복사·링크 방식으로 깐 프로젝트가 접두사 없는 이름으로 에이전트를 싣고 있다] → 이 저장소 새 판의 orchestra·sdd-rules에는 대비 규칙이 없어 섞어 쓰면 `not found`가 난다. 사용자 결정(이전 안내 불필요)으로 받아들인다.
- [README에서 줄 번호로 지정한 범위가 앞 수정 때문에 밀린다] → 위 줄 번호는 수정 전 기준이다. worker는 줄 번호가 아니라 절 제목과 인용한 문장으로 위치를 찾는다.
- [메인 spec에 금지 낱말이 남아 받아들일 조건 3번이 sync 뒤 실패] → D3대로 델타에서 이미 걸렀다. finalizer sync 뒤 reviewer/finalizer가 같은 grep을 `openspec/specs/`까지 넣어 다시 돌린다(tasks 5.4).
- [`.claude/CLAUDE.md`를 고치는 즉시 지금 세션이 읽는 지침과 달라진다] → 새 세션부터 적용된다. 이번 change의 일은 바뀐 지침과 충돌하지 않는다.
