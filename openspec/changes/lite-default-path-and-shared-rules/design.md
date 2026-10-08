## Context

동기와 범위는 proposal.md("Why", "What Changes")와 상위 change `plugin-lite-sdd-distribution`의
decision.md·analysis.md(Q1~Q3, Q6)를 본다. 요구사항은 이 change의 specs 델타 9개가 정본이다.

설계가 기대는 현재 사실 (2026-10-08 디스크에서 다시 잼):

| 파일 | 줄 수 | 반복 절(쓰는 스킬/대화형/store/code-explorer/되돌릴 수 없는 일) 위치 |
|---|---|---|
| `.claude/agents/analyzer.md` | 175 | 21-55 |
| `.claude/agents/code-explorer.md` | 40 | 없음 |
| `.claude/agents/designer.md` | 311 | 32-82 |
| `.claude/agents/finalizer.md` | 299 | 60-106 (+ sync 본문 110-175) |
| `.claude/agents/preparer.md` | 241 | 17-65 |
| `.claude/agents/regression-verifier.md` | 148 | 29-38 |
| `.claude/agents/reviewer.md` | 224 | 33-62 |
| `.claude/agents/worker.md` | 242 | 27-74 |
| `.claude/skills/orchestra/SKILL.md` | 459 | 스킬 표 71-112 |
| `.claude/skills/init-sdd/SKILL.md` | 541 | — |
| `.claude/skills/agent-model-tier/SKILL.md` | 143 | — |
| 합계 | **2,823** | |

- 메인 spec의 `.claude/` 출현 수: 112 (`grep -ro '\.claude/' openspec/specs | wc -l`).
  이 change의 델타를 임시 사본에서 archive로 적용해 보니 152가 됐다(줄지 않음 — 일괄 치환 없음 확인).
  **③에 넘길 사실:** 이 change 뒤 메인 spec의 `.claude/` 출현 수는 152다. ③의 경로 일괄 치환은 이 값을 기준선으로 쓴다.
- 로컬 CLI 1.12.0. `openspec archive --help`에 `-y/--yes`, `--skip-specs` 있음.
- `claude` CLI 2.1.294 있음 (주입 확인에 쓴다).

## Goals / Non-Goals

**Goals:**
- 작은 작업 = `preparer → worker → reviewer → 커밋 관문 → finalizer`, 큰 작업에서만 designer·regression-verifier.
- 공용 규칙 7종을 `sdd-rules` 한 벌로, sync 절차를 `sdd-sync` 한 벌로. 에이전트는 역할만.
- 에이전트·orchestra·sdd-* 에서 스캐폴드 스킬 이름·경로 0건.
- 지시문 합계 2,823 미만 (새 스킬 2개 포함).

**Non-Goals:**
- `.claude/skills/openspec-*` 디렉터리 삭제 (gitignore 대상이고 `openspec init`이 계속 깐다 — 그냥 안 기댄다).
- 에이전트 업무 로직 재설계. 반려 루프·커밋 관문·archive 승인 통로 등은 그대로.
- 메인 spec `.claude/` 경로 일괄 치환, 이름 접두사, 플러그인 파일 (③).
- 에이전트의 "경로는 CLI에서 얻는다" 같은 짧은 역할 규칙의 공용화 — analyzer-option-generation 등
  기존 spec이 그 문장을 각 에이전트 파일에 남기라고 요구한다. 지우지 않는다.

## 용어 (문서 전체에서 이 이름만 쓴다)

| 이름 | 경로 | 언제 |
|---|---|---|
| **경량 모드** (기존, 안 바뀜) | `worker(모드: 경량) → finalizer(모드: 경량 커밋)` | 동작이 안 바뀌는 오타·주석·이름 |
| **작은 작업** (새 기본 경로) | `preparer → worker → reviewer(테스트 1회) → 커밋 관문 → finalizer` | 큰 작업 판정에 하나도 안 걸림 |
| **큰 작업** | `preparer → [analyzer → ★선택] → designer → worker → reviewer + regression-verifier(조건부) → 커밋 관문 → finalizer` | 판정 하나라도 걸림 / 분석 요청 / 애매함 |

proposal의 "경량 기본 경로"는 위 **작은 작업**과 같은 뜻이다. 지시문에는 "경량 경로"라는 말을 새로
쓰지 않는다 (기존 "경량 모드"와 헷갈린다).

## Decisions

### D1. 큰 작업 판정 기준은 orchestra 한 절, preparer는 CLI 출력에서 읽는다

- **정본 위치:** `.claude/skills/orchestra/SKILL.md`에 새 절 `## 큰 작업 판정` (0단계 바로 뒤).
  담을 것: 네 조건(한국어로) — ① 여러 모듈·서비스에 걸치거나 새 구조 패턴을 들인다
  ② 새 외부 의존성이나 데이터 모델의 큰 변경 ③ 보안·성능·마이그레이션 복잡도
  ④ 코딩 전에 기술 결정을 내려야 풀리는 모호함 — + ⑤ 사용자가 분석·방안 비교를 요청했다.
  "하나라도 해당 → 큼", "애매하면 큼(이유: 작은 작업엔 설계 단계가 없어 틀리면 worker가 막힌다)",
  "①~④의 원문은 `openspec instructions design`의 'create only if any apply' 목록이다 — CLI 문구가
  바뀌면 CLI가 맞다", "큼을 작음으로 내리지 않는다. 작음은 올릴 수 있다(분석 요청, worker 설계 구멍)".
  같은 절에 regression-verifier 호출 조건(D5)도 둔다.
- **판정 주체:** preparer. preparer.md에는 네 조건 문장을 **적지 않는다.** 대신:
  "`openspec instructions design --change "<이름>" --json`의 `instruction`에서 design.md를 만들 조건
  목록을 읽고, 하나라도 해당하면 `size=큼`. 기준의 정본은 orchestra의 '큰 작업 판정' 절이다.
  사용자 요청에 분석·방안 비교 요청이 있으면 큼. 애매하면 큼."
- **⑤ 분석 요청의 처리:** 요청 원문에 신호가 있으면 preparer가 큼으로 판정한다. preparer 뒤
  1단계 질문("방안을 비교해 보시겠어요?")에서 사용자가 원하면 orchestra가 큼으로 올린다.
- **버린 대안:** 기준을 sdd-rules에 두기 — preparer만 쓰는데 7개 에이전트에 주입되고, 오케스트레이터
  (메인 세션)는 sdd-rules를 주입받지 않아 결국 orchestra에도 사본이 생긴다. orchestra와 preparer 양쪽에
  사본 — "한 곳" 조건 위반.

### D2. preparer의 RESULT와 작은 작업 산출물

- RESULT: `RESULT: 준비완료 | change=<이름> | branch=<브랜치> | store=<id 또는 none> | size=작음|큼 | questions=<개수>`
  (형식 줄에는 `size=작음|큼`을 글자 그대로 두고 "둘 중 하나만 적는다"를 붙인다.) 중단 줄은 그대로.
- 보고서 본문에 두 줄 추가: `크기: 작음/큼 — <판정 근거 한 줄>`, `테스트 명령: <명령 / 없음>`.
  테스트 명령은 `openspec/config.yaml`의 `context`, `package.json` scripts, `Makefile` 등에서 찾는다.
- `size=작음`일 때 preparer가 추가로 하는 일 (새 절 `### 8. (작은 작업일 때만) 작업 목록과 델타`):
  1. 동작이 바뀌면 `openspec instructions specs` 지시대로 작은 델타 (받아들일 조건 → Scenario,
     요구사항마다 Scenario ≥1, MODIFIED는 메인 블록 통째 복사·헤더 글자 일치). 안 바뀌면 6단계의
     `skip_specs` 마커 명령 블록을 그대로 쓴다 (블록을 복사해 새로 적지 말고 "6단계의 명령"을 가리킨다).
  2. `openspec instructions tasks` 지시대로 `tasks.md`. `- [ ] 1.1` 번호, 항목마다 파일 경로,
     받아들일 조건마다 확인 작업, 테스트/검증 항목 포함, 머리말에 "작은 작업 — design.md 없음" +
     핵심 결정 2~3줄. "코드베이스를 살펴본다" 같은 항목 금지.
  3. 확인: 기존 7단계 블록(두 종료코드·`.openspec.yaml` 세 가지 진단)을 그대로 쓰되, 작은 작업이면
     `openspec validate "<이름>" --strict` exit=0 이어야 하고 `openspec instructions apply --change "<이름>" --json`의
     `state`가 `ready`여야 한다는 줄을 더한다.
- `size=큼`: 지금처럼 proposal까지만. specs·design·tasks 금지.
- "하지 말아야 할 것"의 "specs 델타, design.md, tasks.md 작성 (designer 몫)"은
  "design.md 작성, 그리고 큰 작업의 specs 델타·tasks.md 작성 (designer 몫)"으로 바꾼다.

### D3. sdd-rules 절 구성 (새 파일, Write 허용)

frontmatter:
```yaml
---
name: sdd-rules
description: SDD 파이프라인 서브에이전트 7개(preparer, analyzer, designer, worker, reviewer, regression-verifier, finalizer)가 함께 지키는 공용 규칙. 각 에이전트 frontmatter의 skills:로 주입된다. 사용자가 직접 부르는 스킬이 아니다.
---
```
본문 첫 문단: 무엇인지 + "역할 규칙은 각 에이전트 파일에 있다. 여기에는 공통만 둔다."

절 제목은 **아래 글자 그대로** 쓴다 (에이전트 쪽 grep 0건 검사와 sdd-rules 쪽 1건 검사가 이 글자에 기댄다):

1. `## 쓰는 스킬 — OpenSpec 일은 CLI 지시를 따른다`
   - 산출물은 `openspec instructions <artifact-id> --change "<이름>" --json`의 `template`·`instruction`을 따른다.
     `context`·`rules`는 제약이지 파일에 복사할 내용이 아니다.
   - 경로·상태는 `openspec status --change "<이름>" --json`에서. `resolvedOutputPath`가 글롭이면 파일로 쓰지 않는다.
   - 판정은 종료코드로, 파이프 금지.
   - 블록인용 문단 (spec `skill-tool-invocation-rationale`의 (a)(b)(c)): openspec 공식 스킬(`openspec init`이
     까는 `openspec-*`)은 부르지도 그 SKILL.md를 읽고 따르지도 않는다 / 근거: frontmatter
     `allowed-tools: Bash(openspec:*)` → 스킬이 도는 동안 도구가 `openspec` 하나로 좁혀져 산출물도 코드도 못
     고친다 / **"스킬을 못 부른다는 이유로 절대 멈추지 마라."** (이 문장 글자 그대로)
   - CLI 안내가 설치되지 않은 스킬을 가리키면 따르지 말고 `openspec instructions <artifact>`를 쓴다.
   - 주입되는 스킬: 7개 모두 `sdd-rules`, finalizer는 `sdd-sync`도.
   - 금지: `skills/openspec-` 문자열, 스캐폴드 6개 이름, "`Skill` 도구가 없을 수 있다".
2. `## 대화형 스킬을 만났을 때` — 사용자와 대화 불가. 스킬·CLI·지시 어디서든 "사용자 확인/질문"은 보고서
   "사용자에게 물어야 할 것"에 적는 것으로 대체하고 멈추지 않는다. 단 대상이 애매해 잘못 고르면 비싼 경우
   (예: change 이름이 애매)는 고르지 말고 멈춰 보고.
3. `## store 처리` — 지금 preparer.md 50-59의 내용 중 공통: `--store "<id>"`를 매번, 붙는 명령 11개
   (`new change`, `status`, `instructions`, `list`, `show`, `validate`, `archive`, `doctor`, `context`, `schemas`, `view`),
   `none`/`없음`/빈칸이면 안 붙임, 한 번 정해지면 끝까지, store면 `planningHome.root`가 store를 가리킴,
   예시는 축약형, openspec 명령을 안 쓰는 에이전트(regression-verifier)는 무시.
   (preparer 전용 — `openspec store list --json`으로 id 찾기와 RESULT `store=` — 는 preparer.md에 남긴다)
4. `## code-explorer 부르기` — 넓게 뒤질 때 `Agent` 도구로 `code-explorer`를 부를 수 있다, 결과를 받아
   자기 일을 계속한다, 다른 서브에이전트는 부르지 않는다(오케스트레이터만 지휘). 예시 질문 2~3개.
5. `## 되돌릴 수 없는 일` — 스스로 하지 말고 보고만: 파일·디렉터리·change 디렉터리 삭제(프롬프트가 경로를
   글자 그대로 준 worker 정리 모드만 예외), `git reset --hard`·`git checkout -- .`·`git clean`·브랜치 삭제·stash
   버리기, 커밋(finalizer만)·push·강제 푸시·히스토리 조작(`push: 해도 됨`일 때 finalizer만), `openspec archive`
   (`archive: 해도 됨`일 때 finalizer만), 메인 spec 파일 삭제, capability 은퇴, DB 마이그레이션·외부 서비스
   호출·전역 패키지 설치. 되돌릴 수 있는 일(`git switch -c`, `openspec new change`, change 산출물 수정)은 한다.
   "알아서 정리해라"는 거부하고 대상을 보고서에 적는다.
6. `## RESULT 한 줄 보고 형식` — 공통만: 첫 줄 `RESULT: <상태> | change=<이름> | <역할별 필드>`, `키=값`을
   ` | `로 구분, 상태·판정 낱말은 붙여쓴다(`조건부통과`, `회귀있음`, `검증못함`, `구현막힘`, `마무리중단`) — 본문
   판정 줄도 같은 글자, 상태 낱말과 필드 목록은 각 에이전트 파일이 정한다, 명령 출력은 그대로 붙인다, 안
   돌린 명령을 돌렸다고 적지 않는다, 질문은 "사용자에게 물어야 할 것" 절(없으면 "없음"), 보고서를 파일로
   따로 남기지 않는다(지침이 정한 산출물 제외).
   **여기에 `branch=`, `size=`, `scope=`, `mode=`, `tasks=`, `tests=`, `spec_sync=` 같은 역할별 필드를 적지 않는다.**
7. `## 파일은 Edit로 부분 수정한다` — 이미 있는 파일은 Edit로 필요한 부분만, 전체 Write 재작성·`sed -i` 금지
   (이유 세 가지: 병렬 worker의 체크 날림, review.md 지난 라운드 소실, 리치 마크다운 `[[ORCA_RICH_MD:...]]`·
   들여쓰기 붕괴 사고), 새 파일만 Write, `.md` 고친 뒤 리치 마크다운 토큰 0개·코드펜스 짝수·frontmatter
   `---`와 원래 키 유지. `.openspec.yaml` 마커는 각 에이전트 파일의 명령 블록을 그대로 쓴다.
   **주의:** sdd-rules 자신도 "`grep -c ORCA_RICH_MD` 0" 검사 대상이다. 그 토큰 이름을 글자 그대로 쓰면
   스스로 검사에 걸린다. 토큰은 "리치 마크다운 토큰(`[[ORCA_...]]` 꼴)"처럼 이어지지 않게 적고,
   검사 명령은 `grep -c 'ORCA_RICH''_MD' <파일>`처럼 따옴표로 끊어 적는다 (셸에서는 같은 낱말로 붙는다).

목표 ≤ 95줄.

### D4. sdd-sync 최소 절차 (새 파일, Write 허용)

frontmatter: `name: sdd-sync`, `description: change의 델타 spec을 메인 spec(openspec/specs/)에 병합하는 절차. finalizer가 frontmatter skills:로 주입받아 커밋 전에 따른다. archive는 하지 않는다.`

내용은 지금 finalizer.md 110-175(sync 본문)를 **옮기고**, 스캐폴드 sync 절차에서 빠진 것만 보탠다:

1. 경로: `openspec status --change "<이름>" --json` → `planningHome.root`(store면 store), 델타는 **오직**
   `artifactPaths.specs.existingOutputPaths`. 비면 "sync할 델타 없음"으로 끝(skip_specs 정상).
2. 규칙 스냅샷: `openspec instructions specs --change "<이름>" --json` — rc≠0이거나 JSON이 깨지면 메인 spec을
   하나도 쓰지 말고 멈춤. `rules`가 없으면 규칙 없음. `rules` 문장을 파일에 베끼지 않는다.
3. 델타마다: 델타 읽기 → `<planningHome.root>/openspec/specs/<capability-path>/spec.md` 읽기(없을 수 있음) →
   구획 반영. **반영 순서: RENAMED → REMOVED → MODIFIED → ADDED** (CLI archive와 같은 순서. MODIFIED는 바뀐 새 이름으로 찾는다).
   - RENAMED: FROM → TO, 새 이름으로만 남게.
   - REMOVED: 블록 통째 삭제.
   - MODIFIED: 해당 요구사항만 델타 블록으로 바꾼다. 델타 블록은 살아남는 시나리오까지 통째로 담는다.
     델타가 말하지 않은 요구사항은 메인의 순서 그대로 둔다.
   - ADDED: 없으면 추가, 이미 있으면 델타대로 갱신.
   - 새 capability: `# <capability> Specification` → `## Purpose`(델타 Purpose 그대로) → `## Requirements`.
   - **은퇴:** 그 델타의 모든 구획을 반영한 **뒤** 요구사항이 0개일 때만 판단한다 (REMOVED + ADDED로 요구사항을
     갈아 끼우는 델타가 중간에 0개가 됐다고 은퇴로 보지 않는다 — 이 change의
     `skill-tool-invocation-rationale` 델타가 바로 그 모양이다). 여섯 조건(finalizer.md 136-142 그대로),
     ⑤만 없으면 콕 집어 보고, 빈 `## Requirements` 금지.
4. 형식: 델타 헤더(`## ADDED/MODIFIED/REMOVED/RENAMED Requirements`)가 메인에 들어가면 안 된다. Purpose는 메인 것이
   정본, 새 capability만 델타 Purpose, 없으면 TBD + 보고, 50자 이상. **change의 design.md에 "Purpose 갱신"
   목록이 있으면 그 문장으로 메인 Purpose를 직접 고치고 보고한다.** 여러 번 돌려도 같은 결과.
5. 재대조(ADDED 있음 / MODIFIED 반영·나머지 시나리오 그대로 / REMOVED 없음 / RENAMED 새 이름만) →
   `openspec validate --specs; echo "exit=$?"`, `openspec validate "<이름>"; echo "exit=$?"` 둘 다 0.
   하나라도 실패면 커밋하지 말고 보고.
6. 보고 항목(finalizer 보고서 "spec 갱신" 절이 받는다).
7. 맨 끝 한 줄: "archive는 이 스킬의 일이 아니다 — finalizer 5단계가 사용자 승인 뒤에만 한다."
   **`openspec archive` 명령 문자열은 이 파일에 쓰지 않는다** (실행 지시로 오독될 여지를 없앤다).

목표 ≤ 90줄. finalizer.md 1단계는 "주입된 `sdd-sync` 절차대로 한다" + 커밋보다 먼저 + 실패 시
`마무리중단 | reason=sync불일치` 정도 6~8줄만 남는다.

### D5. regression-verifier 호출 조건과 작은 작업의 테스트

- orchestra `## 큰 작업 판정` 절: "regression-verifier는 **큰 작업이고, 실행 코드가 바뀌었고, 프로젝트에 테스트
  명령이 있을 때만** 부른다. 테스트 명령은 preparer 보고서의 `테스트 명령:` 줄로 판단한다."
- 작은 작업: reviewer 프롬프트에 `테스트: 1회 — <테스트 명령 또는 없음>`을 싣는다. reviewer.md에 새 소절:
  이 줄이 있으면 그 명령(없으면 프로젝트에서 찾음)을 **한 번** 돌리고 결과를 review.md `### 테스트 (1회)`에
  출력 그대로 남긴다. 이번 변경 탓으로 깨지면 [막음]. 명령이 없으면 "테스트 없음". 고치지 않는다.
  RESULT에 `tests=통과/실패/못돌림/없음` 필드를 붙인다 (`테스트:` 줄이 없으면 `tests=안맡음`).
  "하지 말아야 할 것"의 "전체 테스트 스위트 재실행 금지"에 "프롬프트가 `테스트: 1회`를 맡긴 경우 한 번만 예외"를 붙인다.
  "네 일이 아닌 것"도 같은 예외를 한 줄로.
- 큰 작업인데 regression-verifier 조건이 안 맞으면(테스트 명령 없음, 또는 실행 코드 변경 없음): reviewer만 부르고
  `테스트:` 줄은 넣지 않는다.
- **실행 코드가 바뀌었는지의 판단 주체는 orchestra다.** worker 보고서의 만진 파일 목록을 보고, 실행 코드(스크립트·소스)가
  하나도 없으면(문서·지시문·스펙만) "실행 코드 변경 없음"으로 본다. 이 저장소처럼 지시문만 고치는 큰 작업이 여기 해당한다.
- finalizer 프롬프트: `regression 판정: <regression-verifier RESULT 첫 줄 / 생략(작은 작업) / 생략(테스트 명령 없음) / 생략(실행 코드 변경 없음)>`.
  finalizer.md "먼저 확인할 것"의 regression 문단에 "`regression 판정: 생략(...)`이 **글자로** 있으면 회귀 검증을
  거치지 않는 경로이니 보고서에 적고 진행한다. 줄 자체가 없으면 지금처럼 멈춘다"를 넣는다.

### D6. 작은 작업 → 큰 작업 올리기

- 언제: 작은 작업 worker가 설계 구멍(`RESULT: 구현막힘` + 설계 문제)을 들고 올 때, 사용자가 중간에 분석을
  요청할 때.
- orchestra "설계 수정이 필요해졌을 때" 절에 두 번째 프롬프트를 둔다:
  `change 이름 / store / 브랜치 / analyzer 생략: 예 / 채택안: 없음 — proposal의 받아들일 조건이 기준 /
  작은 작업에서 올라왔다. preparer가 쓴 tasks.md(와 델타)가 이미 있다. / 바뀐 사실: <worker 보고>`
  + "이미 있는 산출물을 고치는 절차로 이어받아 큰 작업 산출물을 갖춰라."
  분석 요청으로 올렸으면 analyzer → ★선택 → designer ② 프롬프트(`사용자가 고른 안:`)에 같은 "이미 있다" 줄을 더한다.
- designer.md의 산출물 절차 절(아래 D7)에 "작은 작업에서 올라온 경우"를 고칠 때의 경우로 명시한다.

### D7. 에이전트별 수정 지도와 줄 수 배분

frontmatter `skills:` 줄 (모두 `model:` 줄은 건드리지 않는다):

| 파일 | 지금 | 바꾼 뒤 |
|---|---|---|
| preparer | `skills: [openspec-explore, openspec-propose]` | `skills: [sdd-rules]` |
| analyzer | `skills: [openspec-explore]` | `skills: [sdd-rules]` |
| designer | `skills: [openspec-propose, openspec-update-change]` | `skills: [sdd-rules]` |
| worker | `skills: [openspec-apply-change]` | `skills: [sdd-rules]` |
| finalizer | `skills: [openspec-sync-specs, openspec-archive-change]` | `skills: [sdd-rules, sdd-sync]` |
| reviewer | (없음) | `tools:` 줄 다음에 `skills: [sdd-rules]` 추가 |
| regression-verifier | (없음) | `tools:` 줄 다음에 `skills: [sdd-rules]` 추가 |
| code-explorer | (없음) | 그대로 (파일 무수정) |

줄 수 목표 (기준선 → 목표). **필수 조건은 "각 파일이 기준선보다 짧고 합계 < 2,823"**, 목표는 그 아래 값이다.
못 맞추면 실제 줄 수와 이유를 worker 보고서에 적는다 (analysis Q6: designer·worker·finalizer·preparer는 150~200이 바닥).

| 파일 | 기준선 | 목표 | 주로 줄어드는 곳 |
|---|---|---|---|
| analyzer | 175 | ≤ 130 | 21-55 → 3줄(`## 산출물 형태 참고`), 보고 형식 2안/3안 줄 합치기, "하지 말아야 할 것"의 질문 줄 |
| code-explorer | 40 | 40 | 변경 없음 |
| designer | 311 | ≤ 235 | 32-82 → 12줄(D7-designer), 대화형/store/code-explorer 삭제, 5단계 tasks 설명 압축 |
| finalizer | 299 | ≤ 215 | 1단계 sync 본문 → sdd-sync, 60-106 → 5줄(`## 단계별로 쓰는 도구`), 5단계 재작성 |
| preparer | 241 | ≤ 230 | 17-65 → 6줄 (D2 추가분이 +25줄 안팎) |
| regression-verifier | 148 | ≤ 110 | 29-38 삭제, 도입부 12-27 압축, 2단계 명령 압축, 금지 목록 중복 제거 |
| reviewer | 224 | ≤ 205 | 33-62 → 4줄 (D5 추가분 +8줄 안팎) |
| worker | 242 | ≤ 210 | 27-74 → 8줄, 93-95 → 1줄 |
| **에이전트 합계** | 1,680 | ≤ 1,405 | |
| orchestra | 459 | ≤ 470 | 71-112 → 약 25줄, 큰 작업 판정 절 +약 18줄, 분기 프롬프트 +약 15줄 |
| init-sdd | 541 | ≤ 556 | 링크 목록 두 줄씩 추가 |
| agent-model-tier | 143 | 143 | 변경 없음 (③에서 삭제) |
| sdd-rules (새) | 0 | ≤ 95 | |
| sdd-sync (새) | 0 | ≤ 90 | |
| **합계** | 2,823 | ≤ 2,759 | |

**역할 전용 절 제목 규칙:** 에이전트 파일에 남기는 역할 전용 절에는 `## 쓰는 스킬`이라는 제목을 쓰지 않는다.
그 제목은 sdd-rules 첫 절(`## 쓰는 스킬 — OpenSpec 일은 CLI 지시를 따른다`)의 것이라, 에이전트에 다시 나오면
"공용 규칙 절이 에이전트 본문에 다시 나온다"(shared-pipeline-rules)를 어긴 것처럼 읽힌다. 제목은 아래처럼 정한다:
analyzer `## 산출물 형태 참고`, designer `## 산출물 쓰는 절차`, worker `## 구현 절차의 기준`, reviewer `## 기준 문서`,
finalizer `## 단계별로 쓰는 도구`. preparer·regression-verifier는 따로 절을 두지 않는다.

파일별 반드시 지킬 것 (줄이다 지우면 안 되는 문장 — 기존 메인 spec이 요구):

- **preparer:** 4단계 브랜치·중단 RESULT의 `branch=`(preparer-orphan-branch-reporting), 6단계 `skip_specs` 마커 명령
  블록·`Write`/`>` 금지·"이미 만들어져 있는 파일" 문구, 7단계 두 종료코드·세 가지 진단·"skip_specs를 설정하지
  않았다면 정상" 조건(openspec-metadata-marker-safety). 1단계 "목표치를 발명하지 마라". 쓰는 스킬 절 대신 남길 것:
  "요청이 흐릿하면 무엇을 만들지부터 세우고 모르는 건 질문으로 올린다", "`git switch -c`·`openspec new change`는
  되돌릴 수 있어 해도 된다", store 전용 두 줄(`openspec store list --json`, RESULT `store=`).
- **analyzer:** analyzer-option-generation의 "지우지 않아야 할 규칙" 전부 — 1단계 경로를 CLI에서, 사실/추측 구분,
  스택 없으면 혼자 정하지 마라, analysis.md 맨 위 경고 줄, 코드 수정 금지, `RESULT` 형식(`feasible=` 없음),
  보고 형식, `### 3. 방안 최소 3가지 만들기` 제목과 사용자 후보 규칙 3가지. 쓰는 스킬 절 대신 `## 산출물 형태 참고`
  3줄: "산출물을 쓰지 않는다. 델타 형태를 알아야 하면 `openspec instructions specs --change "<이름>" --json`을 읽는다."
- **designer:** "반드시 지킬 것"(채택안 없음 중단 — prompt-only-handoff-defense), 1단계 원본 파일 우선 3문장
  (artifact-file-precedence-over-prompt), `retire_capabilities` 마커 블록, 7단계 검증(두 종료코드·진단 3가지·
  `validate --specs` 쓰지 마라), 종료 조건. 32-82를 아래 `## 산출물 쓰는 절차` 한 절로 바꾼다:
  - 처음 만들 때: 아래 4~5단계 (`openspec instructions` 루프). proposal은 preparer가 썼으니 건너뛴다.
  - 이미 있는 산출물을 고칠 때(worker가 설계 구멍을 들고 옴 / 사용자가 결정을 바꿈 / **작은 작업에서 올라옴**):
    `artifactPaths.<id>.existingOutputPaths`의 파일만 고친다(글롭 `resolvedOutputPath`에 쓰지 않는다) → 요청된 수정을
    먼저 하고 나머지 산출물을 앞뒤 어느 방향으로든 대조해 어긋난 곳을 함께 고친다 → 크게 다시 써야 하면
    `openspec instructions <id>`의 template·rules를 먼저 받는다 → 아직 없는 산출물(작은 작업에서 올라온 경우의
    design.md 등)은 4~5단계대로 새로 만든다 → 고친 것과 이유는 보고서 "고친 앞 산출물"에 적는다(확인 단계 없음).
  - 본문의 "`openspec-update-change` 스킬이 손대지 않는다"(2단계), "`openspec-propose` 스킬이 이렇게 말한다"(검증 절
    끝)에서 스킬 이름을 뺀다 ("산출물 고치는 절차가 손대지 않는다", "OpenSpec 원칙: *Dependencies are enablers, not gates.*").
- **worker:** 정식 모드 1단계의 `missingArtifacts` 두 갈래와 `design.md: 없음(의도적)` 예외
  (worker-blocked-state-disambiguation), 재작업 모드 `all_done` 예외, 체크박스 Edit 규칙, 산출물 수정 금지의 예외 2가지,
  "너는 7개 중 유일하게 파일을 쓰는 에이전트다"와 정리 모드 삭제 예외. 27-74를 `## 구현 절차의 기준` 한 절(약 8줄)로:
  "정식·재작업 모드는 `openspec instructions apply` 출력을 따른다(아래 요약과 어긋나면 CLI가 맞다, 단 재작업 예외는 우선)",
  "산출물 내용 수정이 필요하면 직접 고치지 말고 보고 — 오케스트레이터가 큰 작업으로 올려 designer에게 맡긴다",
  예외 2가지, "경량·정리 모드는 openspec 명령을 쓰지 않는다". 13행 "designer가 짜 놓은 설계" → "작업 목록(큰 작업은
  designer, 작은 작업은 preparer가 씀)". 93-95 → "CLI 안내가 설치되지 않은 스킬을 가리키면 따르지 말고 보고한다" 한 줄.
  96-98 예외 설명에 "작은 작업이라 처음부터 없거나" 추가.
- **reviewer:** 1단계 skip_specs 대체 기준(reviewer-skip-specs-fallback), 3단계 만진 파일 없을 때 전체diff·`scope=전체diff`
  (prompt-only-handoff-defense), review.md 라운드 규칙. 33-50 → `## 기준 문서` 약 4줄: "산출물 형태의 기준은
  `openspec instructions <artifact>`의 template·instruction이다. `context`/`rules`/`<project_context>` 블록이 산출물에
  복사돼 들어갔으면 올린다(자주 나는 실수). 델타가 sdd-sync로 병합 가능한 형태인지(구획 헤더, `####` Scenario,
  MODIFIED 헤더 글자 일치)도 본다." 82행 "(방안 선택을 건너뛴 버그 수정 경로)" → "(analyzer를 안 부른 경로)". D5 추가.
- **regression-verifier:** prompt-only-handoff-defense의 만진 파일 없음 처리·`scope=전체diff`·"원인 구분 못 함",
  `git stash` 금지와 그 이유, `mktemp` 대조 방법, RESULT 형식. 도입부에 "큰 작업이고 테스트 명령이 있을 때만 불린다" 한 줄.
- **finalizer:** "먼저 확인할 것"의 review.md 직접 확인·최종 판정 줄·조건부통과 대조
  (artifact-file-precedence-over-prompt의 finalizer 쪽), 경량 커밋·WIP 커밋 예외, 2~4단계, 5단계 근거 ①② (spec
  finalizer-archive-rationale-accuracy). 60-106은 `## 단계별로 쓰는 도구` 3~5줄(sync = 주입된 `sdd-sync`,
  archive = 5단계, 커밋 = git). 5단계 재작성:
  - "**`archive: 해도 됨`이 없으면 archive하지 않는다.**" + 근거 ① 되돌릴 수 없어 사용자가 정한다
    ② `--yes` 없이는 stdin 프롬프트에서 죽는다(`Error: 1 incomplete task(s) found ... and no answer could be read from stdin.`) —
    그래서 돌릴 때는 반드시 `--yes`.
  - 승인 없을 때: 조사(status·validate·`- [ ]` 개수)만 하고 보고 (지금과 같다).
  - 승인 있을 때: 조사 통과(validate exit 0, 미완료 0)면 `openspec archive "<이름>" --yes; echo "exit=$?"` **한 길로만**.
    스캐폴드 절차·`mv` 금지. 이미 sync했으므로 보통 `Specs already in sync`가 나온다 — 메인 spec이 바뀌었으면 보고.
    옮겨진 결과(작업 트리 변경)는 3단계 규칙대로 커밋한다.
  - "Sync now / Archive without syncing / Cancel" 문단(250-251)은 스캐폴드 질문이라 지운다.
  "하지 말아야 할 것"의 "`openspec archive` CLI 직접 실행" → "`archive: 해도 됨` 없이 `openspec archive` 실행".

### D8. orchestra 수정 지도

| 위치(지금 줄) | 바꿀 것 |
|---|---|
| 3 description | 순서를 "작은 작업은 preparer → worker → reviewer → finalizer, 큰 작업은 designer·regression-verifier가 더 붙는다"로. analyzer 옵트인 문장은 유지 |
| 48-69 파이프라인 그림 | `[preparer]` 다음에 `size=` 분기: 작음 → `[worker]` → `[reviewer] (테스트 1회)` / 큼 → `(분석 요청이면 [analyzer] → ★안 선택)` → `[designer]` → `[worker]` → `[reviewer] + [regression-verifier](조건부)`. 두 갈래가 커밋 관문 → `[finalizer]`로 모인다 |
| 71-103 스킬 표 절 | 절 제목 `## 단계별로 따르는 지시`. 표: preparer=`openspec instructions proposal`(작음이면 +specs/tasks), analyzer=없음(analysis.md), designer=`openspec instructions specs/design/tasks`, worker=`openspec instructions apply`, reviewer·regression-verifier=없음, finalizer=`sdd-sync`(주입) + 승인 시 `openspec archive --yes`. 그 아래: "공용 규칙은 `sdd-rules`가 frontmatter `skills:`로 7개 에이전트에 주입된다. 에이전트가 스킬 근거·store·되돌릴 수 없는 일을 모르는 낌새면 새 세션에서 주입을 확인하라." 90-95(propose를 읽기만 하는 이유)는 지운다. 97-103(되돌릴 수 없는 일·글자 그대로 지시)은 "목록은 sdd-rules"로 줄여 남긴다 |
| 105-112 | `/opsx:*` 직접 금지 규칙은 그대로. 108-109 "리뷰 단계(reviewer + regression-verifier)와 결정 기록(decision.md)이 사라진다"만 작은 작업에 맞게: "리뷰 단계(reviewer, 큰 작업이면 regression-verifier까지)가 사라지고, 큰 작업이면 결정 기록(decision.md)도 사라진다." |
| 132-153 0단계 | "애매하면 정식 경로로" → "애매하면 preparer부터(기본 경로)". 나머지 그대로 |
| 0단계 뒤 (새 절) | `## 큰 작업 판정` — D1 + D5의 regression-verifier 조건 |
| 160-173 1단계 | `size=`로 분기하는 bullet 추가 (작음 → 5단계 worker, 큼 → 4단계 designer). 167-170 질문 문구 "아니면 바로 설계로 갈까요?" → "아니면 바로 진행할까요?", 비교를 원하면 큼으로 올린다 |
| 201-203 | "designer를 `openspec-update-change` 경로로" → "designer를 이미 있는 산출물을 고치는 경로로" |
| 241 4단계 제목 | `## 4. (큰 작업일 때만) designer 호출`. ① 라벨 "analyzer를 부르지 않은 큰 작업 (평소 큰 작업)". 249-252의 두 줄 필수·멈춤 이유는 그대로, 252 "기본 경로가 전부" → "analyzer 없는 큰 작업이 전부" |
| 271-279 5단계 | 277 bullet: "designer의 RESULT가 `design=건너뜀`이거나 **작은 작업**이면 `design.md: 없음(의도적)`" |
| 290-305 6단계 | 제목 `## 6. reviewer (+ regression-verifier) 호출`. 작은 작업 reviewer 프롬프트 예시 추가(`테스트: 1회 — <명령 또는 없음>`). 큰 작업이고 D5 조건이면 지금 두 호출 그대로, 아니면 reviewer만 |
| 332 7단계 관문 이유 | "사용자가 마지막으로 본 것은 설계 요약이고" → "사용자가 마지막으로 본 것은 큰 작업이면 설계 요약, 작은 작업이면 preparer의 요구사항 정리이고" |
| 338 7단계 finalizer 프롬프트 | `regression 판정: <RESULT 첫 줄 / 생략(작은 작업) / 생략(테스트 명령 없음) / 생략(실행 코드 변경 없음)>` + 한 줄 설명 (줄을 빼면 finalizer가 멈춘다). 실행 코드 여부는 worker의 만진 파일 목록으로 판단(D5) |
| 364-370 설계 수정 | 369 프롬프트의 "openspec-update-change 절차대로" → "이미 있는 산출물을 고치는 절차대로". D6 올리기 문단과 프롬프트 추가 |
| 388 | "(`openspec-update-change`)" 삭제 |
| 410 | "designer가 '기준선 측정'을" → "작업 목록을 쓰는 쪽(preparer 또는 designer)이 '기준선 측정'을" |
| 440-451 줄여도 되는 경우 | 443-448 재작성: "버그 수정(원인이 뻔함) → 크기 판정대로. 보통 작은 작업". **"designer를 생략하면 안 된다" 문장 삭제.** 450: "이미 change가 있고 구현만 남음 → worker → reviewer (+ regression-verifier 조건부) → finalizer" |

### D9. 설치 경로와 문서 (최소 수정)

- `install.sh`: 77행 뒤에 `copy_if_absent ".claude/skills/sdd-rules" ...`, `sdd-sync` 두 줄. 121-135 루프를
  `for ours in orchestra agent-model-tier sdd-rules sdd-sync`로, 주석 "우리 스킬 4개". 136-148(openspec 공식 스킬
  6개 확인과 복구 명령)을 지운다. "다음 할 일"에 한 줄: "이미 깔았던 프로젝트면 [있음, 건너뜀]으로 남은 에이전트
  파일을 새 판과 비교해 옮겨라 (새 판은 sdd-rules·sdd-sync를 주입받는다)."
- `init-sdd/SKILL.md`: 링크 목록 네 개 → 여섯 개. 바꿀 곳: 3(description), 75-81(표·제목 "정확히 여섯 개"),
  95("그 안의 두 개만" → "네 개만"), 150-151(cp), 155 제목("네 자리" → "여섯 자리"), 179("네 자리 모두" → "여섯 자리 모두"),
  185-186(ln), 210-211(exclude),
  323-326(풀기 제목·for 목록), 390-393(상태 보기 제목·for 목록), 479(새 세션에서 볼 스킬 목록), 489-499(복사로 떨어지기의
  for 목록·cp). 세 `for p in ...` 목록은 같은 여섯 경로를 같은 순서로:
  `.claude/agents .claude/skills/orchestra .claude/skills/agent-model-tier .claude/skills/sdd-rules .claude/skills/sdd-sync .claude/settings.json`.
- `CLAUDE.md` 13-14행 (마커 구획 안):
  ```
  순서: `preparer` → `worker` → `reviewer` → `finalizer` (기본 — 작은 작업)
  큰 작업이면 `preparer` → `designer` → `worker` → `reviewer` + `regression-verifier`(테스트가 있을 때, 동시) → `finalizer`.
  작은 작업/큰 작업 판정 기준은 `orchestra` 스킬에 있다.
  ```
  `순서:`로 시작하는 줄은 저장소에서 CLAUDE.md 하나뿐이어야 한다(sdd-install-script). README·orchestra에 이 줄을 복사하지 않는다.
- `README.md` (전면 재작성 금지, ⑤ 몫): 5-8 소개 순서 / 15-17 개입 지점(설계 요약 알림은 큰 작업일 때) /
  81-85 손 설치 `cp` 두 줄 추가 / 117-119 겹칠 수 있는 파일에 두 스킬 / 124-140 설치 확인(`openspec-{...}` ls 줄 삭제,
  sdd-rules·sdd-sync 확인 추가, openspec config 복구 블록은 "openspec 공식 스킬은 없어도 파이프라인은 돈다"로 낮춤) /
  "이미 설치한 프로젝트" 안내 한 문단(두 스킬 추가 + 에이전트 새 판으로) / 167-168 질문 문구 / 186-196 경로 표
  (경량 모드 2번·작은 작업 4번·큰 작업 5~6번, 판정 기준은 orchestra를 가리킴 — 네 조건을 적지 않는다) /
  198-208 에이전트 표(preparer "작은 작업이면 작업 목록까지", designer "큰 작업일 때만", regression-verifier
  "큰 작업이고 테스트 명령이 있을 때만") / 225-232 파일 표(specs·tasks 쓰는 사람) / 250-253 "`Skill` 도구가 없을 수
  있다" 문단 → "에이전트는 openspec 스킬을 부르지도 읽지도 않는다. `openspec instructions` 출력과 공용 규칙
  `sdd-rules`, sync 절차 `sdd-sync`를 따른다" / 258-261 호출 횟수 / 270 번역 대상에 두 스킬 / 272-274 "에이전트는
  `openspec instructions` 출력을 정답으로 삼아 대부분 자동으로 따라간다".

### D10. 검증 방법

1. **스펙·무결성:** `openspec validate "lite-default-path-and-shared-rules" --strict` rc=0, `status --json` rc=0.
   수정·신규 `.md` 전부 `grep -c ORCA_RICH_MD` 0, ```` ^``` ```` 줄 개수 짝수, 에이전트 frontmatter `name`·`description`·`model`·`tools`.
2. **grep 대조:** proposal 받아들일 조건의 grep 명령 전부 (반복 절 0건, sdd-rules 1건씩, 스캐폴드 참조 0건,
   `designer를 생략하면 안 된다` 0건, `size=` 줄, `큰 작업` ≥1, 에이전트 파일에 네 조건 문장 없음, `allowed-tools: Bash(openspec:`이
   sdd-rules에만).
   **네 조건 문장 확인은 문장 단위로 한다.** "마이그레이션"·"외부 의존" 같은 낱말 하나로 `.claude/agents/*.md` 전체를 grep하면
   regression-verifier.md:100("설정/환경변수/마이그레이션이 필요한데 빠뜨린 곳")처럼 판정 기준과 무관한 줄이 걸린다.
   낱말 grep은 preparer.md에만 하고, 다른 에이전트 파일은 걸린 줄을 읽어 "큰 작업 판정 기준을 적은 문장"인지 판단한다.
3. **줄 수:** `wc -l .claude/agents/*.md .claude/skills/{orchestra,init-sdd,agent-model-tier,sdd-rules,sdd-sync}/SKILL.md`.
4. **작은 작업 CLI 재현 (mktemp):** 빈 git 프로젝트 → `openspec init --tools claude --no-animation` →
   change A(proposal + tasks + `skip_specs: true`), change B(proposal + tasks + 요구사항 1개 델타) →
   각각 `openspec validate "<이름>" --strict; echo rc` 와 `openspec instructions apply --change "<이름>" --json`의 `state`.
   같은 디렉터리에서 `npx -y @fission-ai/openspec@1.14.1`로 반복. 네트워크가 없어 npx가 실패하면 그 출력과 함께 "못 함".
5. **스캐폴드 없이 (mktemp):** 저장소를 `cp -R`로 복사 → `rm -rf .claude/skills/openspec-*` → `openspec new change t1` →
   `openspec instructions proposal|specs|design|tasks|apply --change t1 --json` 각 rc. change t2(proposal + 모두 `[x]`인 tasks +
   `skip_specs: true`) → `openspec archive t2 --yes; echo rc`.
6. **설치:** `bash -n install.sh`, mktemp 빈 git 저장소(커밋 1개)에서 `bash "$REPO/install.sh" --dry-run` 출력에
   `sdd-rules`·`sdd-sync` "[복사 예정]", 이어서 실제 설치 후 두 SKILL.md가 원본과 `cmp` 같음.
7. **sdd-rules 주입 (새 프로세스):** 이 세션의 서브에이전트 정의는 세션 시작 때 읽혀서 같은 세션 안에서는 확인할 수 없다.
   대신 **새 `claude -p` 프로세스**를 저장소 사본에서 띄운다:
   ```bash
   t="$(mktemp -d)"; cp -R "<repo>" "$t/r"; cd "$t/r"
   expected="$(awk '/^## store 처리/{f=1;next} f&&NF{print;exit}' .claude/skills/sdd-rules/SKILL.md)"
   for a in preparer analyzer designer worker reviewer regression-verifier finalizer code-explorer; do
     out="$(claude -p "Agent 도구로 subagent_type \"$a\" 를 한 번만 불러라. 그 에이전트에게 보낼 프롬프트: '도구를 하나도 쓰지 마라. 파일도 읽지 마라. 지금 네 컨텍스트(시스템 지시와 미리 주입된 스킬)에 \"## store 처리\" 라는 제목이 있으면 그 제목 바로 아래 첫 줄을 글자 그대로 한 줄로만 답하라. 없으면 NONE 이라고만 답하라.' 그 에이전트의 답을 덧붙임 없이 그대로 출력하라." --allowedTools "Agent")"
     printf '%s\t%s\n' "$a" "$out"
   done
   ```
   **프롬프트는 반드시 `--allowedTools` 앞에 둔다.** `--allowedTools`는 값을 여러 개 받는 플래그라 뒤에 오는
   프롬프트까지 도구 이름으로 삼켜 실패한다(`claude -p --allowedTools "Agent" "<프롬프트>"` 꼴은 안 된다 — reviewer 실측).
   판정: 7개 에이전트의 `out`이 `expected`와 같고, code-explorer는 `NONE`. `## store 처리` 첫 줄은 sdd-rules에만
   있는 문장이어야 한다(실행 전에 `grep -rnF "$expected" .claude CLAUDE.md`가 sdd-rules 한 곳만 나오는지 확인).
   사본에서 돌리는 이유: 불린 에이전트가 지시를 어기고 파일을 만져도 저장소가 안전하다.
   실패하면(7개 중 하나라도 불일치) 주입이 안 된 것이다 — 상위 decision의 대비책(`bin/sdd-rules` 출력)은 ③ 범위라
   이 change에서는 결과를 그대로 기록하고 사용자에게 올린다.
   **기록:** worker가 한 번 돌려 출력을 보고서에 붙이고, reviewer가 다시 돌려(적어도 한 에이전트) 방법과 결과를
   `review.md`에 남긴다 (받아들일 조건).
8. **메인 spec 경로 수:** sync 뒤 `grep -ro '\.claude/' openspec/specs | wc -l`이 112 이상(임시 사본 실측 152).

## Risks / Trade-offs

- [`skills:` 주입이 Skill 도구 없는 에이전트(reviewer·regression-verifier)에서 안 될 수 있다] → **실측 사실:**
  claude 2.1.294에서 Skill 도구가 없는 에이전트도 frontmatter `skills:` 주입을 받는다(구현 전 설계 검토 때 reviewer가
  임시 프로젝트에서 실측). 그래도 D10-7로 이 저장소의 7개를 각각 확인한다. 안 되면 사실대로 기록하고 사용자에게
  올린다 (대비책은 ③).
- [이 세션의 reviewer·finalizer는 세션 시작 때 읽힌 옛 정의로 돌 수 있다] → 옛 정의도 디스크의 스캐폴드 문서로 정상
  동작한다(스캐폴드 디렉터리를 지우지 않는다). 이 change의 sync는 옛 finalizer 절차로 해도 결과가 같다(델타 형식은 같다).
- [preparer의 크기 판정이 틀려 작은 작업에서 worker가 막힌다] → 애매하면 큼, D6 올리기 경로.
- [작은 작업 경로에서 회귀 검증이 약해진다] → reviewer 테스트 1회 + 큰 작업에서 테스트가 있으면 regression-verifier.
  테스트가 없는 프로젝트(이 저장소 포함)는 원래부터 regression-verifier가 할 일이 거의 없었다.
- [`size=작음|큼`의 `|`가 필드 구분자처럼 보인다] → 형식 줄에 "둘 중 하나만"을 붙이고, 실제 출력은 `size=작음` 한 낱말.
- [이미 설치한 프로젝트는 install.sh를 다시 돌려도 에이전트 파일이 건너뛰어진다] → install.sh "다음 할 일"과 README에 안내.
- [REMOVED + ADDED로 요구사항을 갈아 끼우는 델타를 은퇴로 오판] → sdd-sync에 "모든 구획을 반영한 뒤 0개일 때만" 규칙.
  이 change의 델타를 임시 사본에서 `openspec archive --yes`로 적용해 보니 정상 적용됨(skill-tool-invocation-rationale:
  `+1 added -1 removed`).
- [줄 수 목표 미달] → 필수는 "기준선보다 짧고 합계 < 2,823". 목표 미달은 보고로 처리.

## Migration Plan

1. sdd-rules·sdd-sync를 먼저 만든다 (에이전트가 가리킬 대상).
2. 에이전트 7개를 파일별로 고친다 (서로 독립, 병렬 가능).
3. orchestra → 설치 경로·문서 → 검증.
4. 되돌리기: 이 change의 커밋을 revert하면 된다. 스캐폴드 문서는 지우지 않으므로 옛 지시문이 그대로 다시 돈다.

### Purpose 갱신 (sdd-sync D4-4가 읽는 목록)

- `agent-instructions/finalizer-archive-rationale-accuracy`: 아래 "finalizer 프롬프트에 글자 그대로 실을 문장"의 Purpose 문장으로 바꾼다.
- 나머지 수정 capability의 Purpose는 그대로 둔다.

### finalizer 프롬프트에 글자 그대로 실을 문장

이 change의 sync는 **옛 finalizer**(세션 시작 때 읽힌 정의, 메인 Purpose를 정본으로 두고 건드리지 않는 규칙)가 돌린다.
옛 finalizer는 위 "Purpose 갱신" 목록을 모르므로, 오케스트레이터가 아래 블록을 **그대로 복사해** finalizer 프롬프트에 싣는다.
블록 안의 문장을 고쳐 쓰거나 요약하지 않는다.

```text
Purpose 갱신 (사용자 결정 — 메인 Purpose 정본 규칙의 예외):
sync 때 openspec/specs/agent-instructions/finalizer-archive-rationale-accuracy/spec.md 의 "## Purpose" 본문을
아래 문장으로 통째로 바꾸고, 바꾼 사실을 보고서 "spec 갱신" 절에 적어라. 다른 capability의 Purpose는 건드리지 마라.
---
finalizer가 "사용자 승인 없이 archive하지 않는다"는 정책을 실측과 맞는 근거로만 뒷받침하고, 승인 뒤에는 `openspec archive --yes` 한 길로만 가게 한다. 틀린 근거를 남겨 두면 다음 사람이 그걸 믿고 잘못 판단한다.
---
```

## Open Questions

없음. (주입 확인 결과가 실패로 나오면 그건 열린 질문이 아니라 사용자에게 올릴 사실이다.)
