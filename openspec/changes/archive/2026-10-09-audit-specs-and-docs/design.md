# Design

## Context

- 동기와 발견 목록은 `proposal.md`("Why", "발견 목록")를 본다. 이 문서는 **어떻게**만 적는다.
- 채택안: 없음(analyzer 생략). 기준은 proposal의 받아들일 조건 1~9와 가정 G1~G7(오케스트레이터가 전부 채택).
  발견 표 48행의 "고침/둔다" 판정도 그대로 따른다. decision.md는 만들지 않는다.
- 정본 CLI는 `./bin/sdd-openspec`(1.14.1). PATH의 `openspec`은 1.12.0이라 change 검증의 보조 게이트로만 쓴다.
- 시작 커밋(범위 밖 diff 기준): `5df62b21b69a7a5e07396552373fa7eef10cb731`.
- **proposal 숫자 정정:** proposal 첫 판은 "500자 초과 요구사항 34개"라고 적었지만 같은 줄의 내역(3+1+1+3+3+1+10+5+1)과
  `validate --all --strict` 실측은 **28개**다. proposal도 28로 고쳤다. 받아들일 조건 3(초과 0개)은 숫자와 상관없이 그대로다.
- **CLI 표기:** 저장소에서는 `./bin/sdd-openspec`, 저장소 밖 사본(mktemp)에서는 `<저장소 절대경로>/bin/sdd-openspec`로 적는다.
  `show`는 spec 전체 id(`openspec/specs/` 아래 경로, 예: `agent-instructions/lite-default-path`)를 받는다. 짧은 이름(`lite-default-path`)은 exit 1이다(실측).

### 1.14.1이 델타를 다루는 방식 (실측, 사본 `scratchpad/e2.*`)

| 시험 | 델타 모양 | `validate --strict` 결과 |
|---|---|---|
| E2-0 | MODIFIED X, 시나리오 이름 하나만 바꿈 | **exit 1** — `MODIFIED "X" omits scenario(s) the current spec still has: …` |
| A | REMOVED X + ADDED X(같은 헤더) | **exit 1** — `Requirement present in both ADDED and REMOVED` |
| B | RENAMED X→X' + MODIFIED X'(시나리오 이름 바꿈) | **exit 1** — 이름 바꾼 블록도 원래 시나리오 대조를 받는다 |
| C | REMOVED X + ADDED X'(새 헤더) | **exit 0** |
| D | RENAMED X→임시 + REMOVED 임시 + ADDED X | exit 0이지만 **버림**(아래 결정 2) |

결론: MODIFIED는 원래 시나리오를 **하나도** 빼거나 이름을 바꿀 수 없다(1.14.1 #1477 검사, archive도 같은 검사로 거부).
CLI 지시(`instructions specs`)도 "긴 요구사항은 MODIFIED로 헤더와 모든 시나리오를 지키고 본문만 줄인 뒤, 뺀 행동을 ADDED로"라고 적는다.

## Goals / Non-Goals

**Goals:**
- 메인 spec 요구사항 본문 500자 초과 0개(1.14.1 `validate --all --strict` exit 0).
- 발견 표 "고침" 행(#1~#21, #28~#45)을 전부 반영하고, 지시문·문서는 Edit 부분 수정만.
- finalizer가 손 sync를 해도 뒤의 `archive --yes`가 "already in sync"로 끝나게 델타를 짠다.

**Non-Goals:**
- `bin/`, `hooks/`, `install.sh`, `.claude-plugin/` 변경(diff 0 유지). #26·#27·#48은 후속 후보.
- 겹치는 규칙의 소유자 통합(#23), spec 제목 형식 통일(#25), 기준선 기록 수정(#46 — designer 재량으로 **안 함**).
- `docs/field-validation.md` 기록 표 채우기(실측은 범위 밖).

## Decisions

### 결정 1. 나누기는 "MODIFIED로 헤더·시나리오 지키기 + ADDED로 뺀 의무"가 기본이다

- 길기만 한 요구사항: MODIFIED로 헤더와 원래 시나리오를 **전부** 그대로 두고 본문을 한 행동으로 줄인다.
  빠진 의무 문장은 새 ADDED 요구사항(새 시나리오 하나 이상)으로 옮긴다. 원래 시나리오는 **모두 원래 헤더 아래 남는다**
  (CLI가 옮기는 것을 막는다).
- 의무 없는 근거·경위 문장은 G2대로 줄이거나 지운다(지운 것은 아래 대조표에 "근거 삭제"로 적었다).
- 버린 대안: 표·목록을 시나리오로 옮겨 본문만 줄이기 — 의무가 시나리오(검증 예시)로 내려가 SHALL이 사라진다.

### 결정 2. 시나리오 이름을 바꾸거나 지워야 하는 곳은 REMOVED + ADDED(새 헤더)

- 실측 C 방식. G3가 지정한 방식이고 sdd-sync 손 병합 규칙(REMOVED는 지우고 ADDED는 더한다)과 그대로 맞는다.
- 버린 대안 D(RENAMED→임시→REMOVED로 같은 헤더 되살리기): CLI는 받지만, sdd-sync 5단계 재대조
  "RENAMED가 새 이름으로만 있다"에서 임시 이름이 없어 finalizer가 `sync불일치`로 멈춘다.
- 대가: 아래 9개 요구사항은 헤더가 바뀐다. 받아들일 조건 4("원래 헤더가 없어지지 않는다")의 **예외**이고,
  의무는 대조표로 전부 추적된다.

| capability | 지운 헤더 | 새 헤더(ADDED) | 바뀐 시나리오 |
|---|---|---|---|
| analyzer-option-generation | 검증 안 된 안으로 설계에 들어가지 않는 안전장치가 지휘 문서에 남아야 한다 | ① analyzer를 부른 뒤 목록 밖 사용자 안은 analyzer를 다시 불러 검증해야 한다 ② 목록 밖 사용자 안의 재검증은 analyzer를 부른 경우에만 걸린다고 적혀야 한다 | "파이프라인 그림의 화살표" → "analyzer를 부른 경우의 재호출 흐름"(①) |
| analyzer-option-generation | 사용자 문서에 없어진 모드가 남아 있지 않아야 한다 | ① 사용자 문서는 없는 동작과 강제 관문을 설명해서는 안 된다 ② 사용자 문서는 작은 작업과 큰 작업의 개입 지점을 나눠 적어야 한다 | "README 재확인" → "README에 평가 모드와 강제 관문이 없다"(①), "예제 실행 문서" **삭제**(#2) |
| finalizer-archive-rationale-accuracy | finalizer의 archive 금지 근거는 실측과 일치해야 한다 | ① finalizer는 실측과 맞는 두 근거로만 archive 승인 정책을 설명해야 한다 ② finalizer는 승인이 있을 때만 archive --yes 한 길로 archive해야 한다 | "…근거를 제거한다" ×2 → "…근거가 없다" ×2(①), "정책과 결론은 그대로다" → "승인 정책과 archive 명령"(②) |
| shared-pipeline-rules | 공용 규칙은 sdd-rules 스킬 한 곳에 있어야 한다 | ① sdd-rules 스킬은 공용 규칙 일곱 가지를 절마다 담아야 한다 ② sdd-rules 스킬의 frontmatter는 이름과 설명만 가져야 한다 | "일곱 절이 각각 한 번씩 있다" → "세 제목이 한 번씩 있고 나머지 네 절도 있다"(①) |
| sdd-install-script | 설치 안내는 README 한 곳에만 있어야 한다 | ① 설치 절차는 README 한 곳에 플러그인부터 서술되어야 한다 ② README의 복사 방식 설명과 설치 확인은 제품 6종과 맞아야 한다 ③ README는 이미 설치한 프로젝트를 위한 갱신 안내를 담아야 한다 | "README가 5종을 말한다"+"README가 공용 스킬 두 개도 말한다" → **합침** "README가 세 스킬을 제품 설명과 설치 확인 양쪽에 적는다"(②) |
| sdd-install-script | 제품 6종을 깔아야 한다 | ① install.sh는 제품 6종을 플러그인 레이아웃에서 가져와 기존 위치에 깔아야 한다 ② install.sh의 설치 확인은 제품 6종에 맞아야 한다 | "설치 확인이 7종을 본다" → "설치 확인이 에이전트 개수와 세 스킬을 본다"(②) |
| sdd-plugin | README는 플러그인 설치를 먼저 안내해야 한다 | README는 플러그인 설치와 이전 안내를 담아야 한다 | "README에 다섯 가지가 있다" → "README에 플러그인 안내 네 가지가 있다"(`claude --plugin-dir .`는 "이 저장소는 --plugin-dir로 개발해야 한다"가 계속 맡음) |
| field-validation-record | evals 폴더가 claude plugin eval 사례 뼈대와 안내 문서를 담아야 한다 | ① evals 폴더는 bare 모양의 사례 폴더 두 개를 담아야 한다 ② evals 안내 문서는 구조와 실행 방법과 실행 위치를 알려야 한다 | "README가 실행 방법과 실행 불가 시점을 알린다" → "README가 실행 방법과 실행 위치를 알린다"(②) |
| field-validation-record | 이 양식은 측정 결과 없이 비어 있는 상태로 제공되어야 한다 | eval 실행 결과물은 저장소에 추적되지 않아야 한다 | "값 칸이 비어 있음" → "eval 결과 폴더가 추적되지 않는다"(빈 칸 규칙 삭제 #13) |

### 결정 3. 나누기 대조표 (원 요구사항 → 새 헤더, 의무 문장 1:1)

표기: **[M]** 원래 헤더 MODIFIED(원 시나리오 전부 그 아래 유지) / **[A]** ADDED / **[R]** REMOVED. 괄호 안 숫자는 1.14.1이 잰 원래 본문 길이.
"근거 삭제"는 의무어(SHALL/MUST) 없는 설명 문장을 G2로 지운 것이다.

**analyzer-option-generation (3개)**

| 원 요구사항 | 원래 의무 문장 | 간 곳 |
|---|---|---|
| 검증 안 된 안으로…(527) [R] | 목록 밖 안이면 analyzer를 다시 부르는 절차 유지(SHALL) / 평소 호출 형태·추가 후보로 얹기(MUST) / 근거 문장 지우지 않기(MUST NOT) | [A] analyzer를 부른 뒤 목록 밖 사용자 안은… |
|  | analyzer를 부른 경우에만이라는 조건을 적기(MUST) | [A] 목록 밖 사용자 안의 재검증은 analyzer를 부른 경우에만… |
|  | 시나리오 4개 | 첫째(이름 변경)·둘째·셋째·넷째 → 첫 [A]. 둘째 [A]에 새 시나리오 1 |
| 사용자 문서에 없어진 모드…(501) [R] | 없는 동작 설명 금지(MUST NOT) / 강제 관문 서술도 대상(SHALL) / "관문이 사라졌다" 금지(MUST NOT) | [A] 사용자 문서는 없는 동작과 강제 관문을… ("모든 정식 요청" → "모든 요청") |
|  | 작은·큰 작업 개입 지점 나눠 적기(SHALL) / 작은 작업에 결정 기록 개입 지점 금지(MUST NOT) | [A] 사용자 문서는 작은 작업과 큰 작업의 개입 지점을…(#3: 금지 범위를 "analyzer 없는 큰 작업"까지 넓힘, decision.md는 analyzer를 불렀을 때만) |
|  | 시나리오 4개 | 예제 실행 문서 **삭제**(#2) / README 재확인(이름 변경)·경로 표 → 첫 [A] / 이게 왜 필요한가(THEN 갱신) → 둘째 [A] |
| 기본 경로에는 analyzer와…(671) [M] | 기본 경로(SHALL) / 관문 금지(MUST NOT) / analyzer.md 남음(MUST) / 흐름 유지(MUST) | [M] 유지 |
|  | 세 문서가 같은 두 경로를 같은 순서로(MUST) | [A] 파이프라인 순서를 적은 문서는 같은 두 경로를… (새 시나리오 1) |

같은 capability의 짧은 요구사항 "지침 문서 수정은 파일을 손상시키지 않아야 한다"는 [M]으로 시나리오 본문만 고친다(#5: "군살을 뺀 뒤", "제거된 문장은 보고되어 있다" 삭제).

**code-explorer-invocation (1개)**

| 원 요구사항 | 원래 의무 문장 | 간 곳 |
|---|---|---|
| 7개 기존 에이전트 파일은 Agent 도구를…(552) [M] | tools에 Agent(SHALL) / 기존 tools 제거 금지(MUST NOT → "유지되어야 한다(MUST)"로 현재형) / skills 값(SHALL) | [M] 유지 |
|  | model 줄이 바뀌지 않음(MUST NOT) / name·description 안 바뀜 | [A] 에이전트의 기본 모델은 각 파일의 model 줄 하나가… (현재형 MUST NOT, 새 시나리오 1) |
|  | 시나리오 2개 | 둘 다 [M]. 본문만 현재형으로(#5: "변경 전과 대조", "이전에 있던 도구가 빠지지 않았다") |

**finalizer-archive-rationale-accuracy (1개)** — 결정 2 표. 두 근거(SHALL)·틀린 근거 금지(MUST NOT) → ①, 정책(SHALL)·`--yes` 한 길(SHALL)·스캐폴드/`mv` 금지(MUST NOT) → ②.

**lite-default-path (3개)**

| 원 요구사항 | 원래 의무 문장 | 간 곳 |
|---|---|---|
| 기본 경로는 작은 작업 경로여야 한다(503) [M] | 전부(SHALL ×3) | [M] 유지. "지금처럼", "이 경로는 바뀌지 않는다" 삭제(#5), 경량 모드 문장에 (SHALL). 셋째 시나리오 본문 #6(`sdd-openspec` 1.14.1 하나로) |
| 큰 작업 판정 기준은 orchestra 한 곳에만(565) [M] | 한 절(SHALL) / 네 가지+분석 요청(MUST) / 애매하면 큼(SHALL) | [M] 유지 |
|  | 판정은 preparer(SHALL) / preparer.md 기준 사본 없이 가리키기(SHALL) / 다른 에이전트 사본 금지(MUST NOT) | [A] 크기 판정은 preparer가 하고… (새 시나리오 1) |
| 회귀 검증 단계는 조건이 맞을 때만(603) [M] | 호출 조건(SHALL)·적기(MUST) / 실행 코드 판단(SHALL) / reviewer 1회(SHALL)·지시(MUST) | [M] 유지 |
|  | 생략 이유 적기(SHALL) / 줄 없으면 finalizer 멈춤(SHALL, "지금처럼" 삭제) | [A] 회귀 검증을 생략하면 finalizer 프롬프트에… (새 시나리오 1) |

짧은 "작은 작업일 때 preparer가 작업 목록을 써야 한다"는 [M]으로 "지금처럼" 하나만 지운다(#5).

**shared-pipeline-rules (3개)**

| 원 요구사항 | 원래 의무 문장 | 간 곳 |
|---|---|---|
| 공용 규칙은 sdd-rules 스킬 한 곳에(537) [R] | 파일(SHALL) / 7절(MUST) / 제목 글자(SHALL) | [A] sdd-rules 스킬은 공용 규칙 일곱 가지를… (시나리오 이름 변경) |
|  | frontmatter 두 키(SHALL) / allowed-tools 금지(MUST NOT) / description(SHALL) | [A] sdd-rules 스킬의 frontmatter는… ("파일과 frontmatter" + 새 시나리오 1) |
| 공용 규칙은 frontmatter skills로(646) [M] | sdd-rules(SHALL) / sdd-sync(SHALL) / openspec- 금지(MUST NOT) / 접두사 없음(SHALL) / 새 프로세스 확인(SHALL) | [M] 유지(근거 줄임) |
|  | code-explorer에 skills 없음(SHALL) | [A] code-explorer 에이전트 파일에는 skills 줄이 없어야 한다 (새 시나리오 1) |
| sdd-sync 스킬은 sync 절차만…(859) [M] | 파일(SHALL) / frontmatter(SHALL) / 절차 목록(MUST) | [M] 유지 |
|  | Purpose 갱신 예외(SHALL) / 목록 없으면 안 건드림(MUST NOT) | [A] sdd-sync는 design.md의 Purpose 갱신 목록이 있을 때만… (새 시나리오 1, "유일한 통로" → "통로") |
|  | archive 지시 금지(MUST NOT) | [A] sdd-sync는 archive를 실행하라고 지시해서는 안 된다 (finalizer 승인 뒤(SHALL) 덧붙임, 새 시나리오 1) |

짧은 두 요구사항도 [M]: "파이프라인은 OpenSpec 스캐폴드 스킬 문서에 기대지 않아야 한다"(#7 시나리오 전제를 `mktemp -d` 임시 프로젝트로),
"openspec 호출 표기와 에이전트 이름 규칙은…"(#8 `sdd:<이름>` → `sdd:code-explorer` 하나).

**skill-tool-invocation-rationale (1개)**

| 원 요구사항 | 원래 의무 문장 | 간 곳 |
|---|---|---|
| 스킬 호출 근거 문단은 sdd-rules 한 곳에서…(706) [M] | 한 곳(SHALL) / 다섯 파일 사본 금지(MUST NOT) / "`Skill` 도구가 없을 수 있다" 금지(MUST NOT) | [M] 유지, 시나리오 4개 유지 |
|  | 세 가지 (a)(b)(c)(SHALL) | [A] 스킬 호출 근거 문단은 대신 따를 것과 근거와 결론을… (새 시나리오 1) |

**init-sdd-skill (10개)**

| 원 요구사항 | 원래 의무 문장 | 간 곳 |
|---|---|---|
| 스킬은 이 저장소에 있고…(784) [M] | 위치(SHALL) / 플러그인에 안 넣음(SHALL) / frontmatter 두 키(SHALL) / allowed-tools 금지(MUST NOT) | [M] 유지(근거 줄임) |
|  | description 부르는 말(MUST) / 모델 등급 스킬 금지(MUST NOT) | [A] init-sdd 스킬 설명에는 부르는 말이… |
| 개인 소유와 openspec CLI 소유를…(1012) [M] | 통째 링크 금지(MUST NOT) / 개인 소유만(SHALL) / 다섯 개(SHALL, 표 → 문장) / 모델 등급 금지(MUST NOT link) | [M] 유지 |
|  | 초기 이관 원본(SHALL) / sdd-rules·sdd-sync 함께(의무어 없던 문장 → SHALL) | [A] 초기 이관 원본은 원본 저장소의 플러그인 레이아웃에서… |
|  | openspec-*·opsx 제외(MUST NOT link) / `.claude/skills/` 실제 디렉터리(SHALL) / settings.local.json(MUST NOT) | [A] openspec CLI가 까는 것과 개인 로컬 설정은… |
| 경로를 하드코딩해서는 안 된다(544) [M] | 하드코딩 금지(MUST NOT) / 세 경로 실행 시점(SHALL) / 저장소 절대 경로 금지(MUST NOT) | [M] 유지. 옛 경로 글자와 "곧 옮겨질 예정" 삭제(#18) |
| 개인 저장소가 없으면 만들고…(537) [M] | 만들기(SHALL) / 재init 금지(MUST NOT) / 기본 이름(SHALL) / 기록(SHALL) | [M] 유지 |
|  | 겹칠 때 표(의무어 없던 표 → SHALL) / 짐작 덮어쓰기 금지(MUST NOT) | [A] 프로젝트별 디렉터리 이름이 겹치면… |
| 대상 프로젝트에 이미 있는 것을…(646) [M] | 우선(SHALL) / 표(MUST) / 멈출 때 다음 선택 알림(MUST) | [M] 유지 |
|  | 추적 파일 옮기기 금지(MUST NOT) / 지우지 않기(MUST NOT delete) / 백업 이름(SHALL) | [A] 추적 중인 파일은 옮기지 않고… |
| CLAUDE.md 조각은 원본 한 벌에서…(501) [M] | 전부(MUST NOT / SHALL / MUST / SHALL / MUST NOT) | [M] 유지, 근거 줄임만 |
| 추적 여부에 따라 CLAUDE.md를…(530) [M] | 들어가지 않기(SHALL) / 두 갈래(MUST) / exclude 오용 금지(MUST NOT) | [M] 유지 |
|  | `.gitignore` 금지(MUST NOT) / "exclude가 통한다"고 적기 금지(근거 문장 → MUST NOT) | [A] CLAUDE.md를 로컬에만 둘 때 공유 .gitignore를… |
| 걸었다 풀 수 있어야 하고…(518) [M] | 두 절차(SHALL) / 되돌리기 목록(MUST) / 이전 판 링크(SHALL) | [M] 유지 |
|  | 풀면 전과 같음(SHALL) / 개인 저장소 안 지움(MUST NOT) | [A] 링크를 풀어도 공유 저장소는 원래대로… |
| 링크가 에이전트로 로드되는지는…(535) [M] | 정직하게 적기(MUST) / 새 세션 확인 절차(SHALL) / 확인 안 된 것 단정 금지(MUST NOT) | [M] 유지. 시나리오 본문 "(또는 이 change의 산출물)" 삭제(#17) |
|  | 복사로 떨어지는 길(SHALL) | [A] 링크가 로드되지 않을 때 복사로 떨어지는 길을… |
| 복사 방식과 언제 무엇을 쓰는지…(595) [M] | 링크/복사 적기(SHALL) / 언제 무엇(MUST) / 두 곳 서술 금지(MUST NOT) / README 가리키기(SHALL) | [M] 유지 |
|  | 섞였을 때 적기(MUST) / install.sh 전 확인(SHALL) | [A] 링크가 걸린 프로젝트에서 install.sh를 돌리기 전의 위험을… |

**sdd-install-script (5개)**

| 원 요구사항 | 원래 의무 문장 | 간 곳 |
|---|---|---|
| CLAUDE.md 조각의 원본은 한 벌(522) [M] | 원본 한 곳(SHALL) / 베끼기 금지(MUST NOT) / 뽑기(SHALL) / README 재게재 금지(MUST NOT) / 뽑는 방법(SHALL) | [M] 유지, 근거 문단 삭제. 첫 시나리오 본문 #11(`command grep -rlE '^순서: ' --exclude-dir=openspec --exclude-dir=.git .`) |
| 낱말 검색만으로 판별 금지(570) [M] | 전부(MUST NOT / SHALL / MUST / MUST NOT / MUST) | [M] 유지, 예시 줄임만 |
| 복사 방식과 링크 방식 중…(958) [M] | README가 어느 것을(SHALL) / 본문 한 곳(SHALL) | [M] 유지(표 줄임). "이 요구사항은 복사 규칙을 바꾸지 않는다"(의무어 없음) 삭제 — 시나리오 "복사 동작이 그대로다"는 [M]에 남는다 |
|  | 서로 가리키기(MUST) / install.sh 한 줄 안내(SHALL) / 절차 재서술 금지(MUST NOT) | [A] install.sh와 init-sdd 스킬 문서는 서로를 가리켜야 한다 (새 시나리오 1) |
| 설치 안내는 README 한 곳에만(636) [R] | 결정 2 표 ①②③ | 두 곳 금지(MUST NOT)·README만으로(SHALL)·플러그인 먼저(SHALL)·흐름(MUST) → ① / 6종 맞춤(MUST) → ② / 갱신 안내(SHALL)·모델 등급 지워도 됨(SHALL) → ③ |
| 제품 6종을 깔아야 한다(831) [R] | 결정 2 표 ①② | 6종(SHALL)·원본(SHALL)·대상 위치(SHALL)·모델 등급 금지(MUST NOT) → ① / 설치 확인(MUST)·공식 스킬 확인 제외(SHALL) → ② |

짧은 "설치 스크립트는 저장소에 남아 있어야 한다"는 [M]으로 "유일한 수단"과 거짓 근거를 고친다(#9).

**field-validation-record (1개)** — 결정 2 표. 사례 폴더 README(SHALL)·모양(MUST)·2개(SHALL) → ①, 안내 문서(MUST) → ②,
"전환 뒤 실행 불가 서술 금지(MUST NOT)" → ② "실행 위치는 지금 실행할 수 있는 곳으로 적는다(SHALL)"(#12 긍정형).
"양식은 비어 있게"의 측정 금지(MUST NOT)·빈 칸(MUST)·기준선만 채움(SHALL)은 **의도적으로 삭제**(#13), `evals/results/` 미추적(MUST NOT·SHALL)은 새 [A]로.
짧은 "비교 대상 3가지와…"는 [M]: 빈 칸 규칙(MUST) 삭제(#13), 용어를 orchestra 작은/큰 작업 경로로(#14).

**나머지 [M]만 있는 capability:** sdd-plugin("플러그인 검증 명령 두 개" "관문 1.3 실측" → "실측", "eval 결과" 시나리오의
"이 change의 검증 기록" → archive `2026-10-09-convert-to-plugin`의 `verification.md`, #17),
sdd-init-command(#19: 표기 규칙 문장 삭제, 초기화 판단을 `openspec/config.yaml` 기준으로),
session-start-hook(#15: "유일한 수단" 삭제).

### 결정 4. 측정 결과 (사본에서 `archive --yes` 병합, 1.14.1)

| 항목 | 지금(메인) | 델타 반영 뒤 |
|---|---|---|
| `validate --all --strict` | exit 1 (13 passed / 9 failed, 이 change 포함 시 10 failed) | **exit 0** (21 passed / 0 failed; change가 진행 중인 채 sync한 사본은 23 passed) |
| 500자 초과 요구사항 | 28개 | 0개 (480자 넘는 것: shared-pipeline-rules "공용 규칙은 frontmatter skills로…" 496·"sdd-sync 스킬은…" 483, 손대지 않은 openspec-metadata-marker-safety 496, lite-default-path "기본 경로는…" 490·"작은 작업일 때…" 483) |
| 메인 spec 시나리오 수 | 220 | 238 (줄지 않음. 의도한 삭제·합침 2개 포함: 예제 실행 문서 −1, README 5종 합침 −1) |
| 요구사항 수가 바뀐 spec | — | analyzer 8→11, code-explorer-invocation 4→5, finalizer-archive 1→2, lite 6→8, shared 6→10, skill-tool 1→2, init-sdd 14→23, install 10→14, field 6→7 |
| 손 sync(=archive 결과 복사 + Purpose 3개) 뒤 `archive --yes` 재적용 | — | exit 0, `Specs already in sync; no files changed.` (REMOVED는 경고 한 줄씩) |
| change 검증 | — | `./bin/sdd-openspec validate audit-specs-and-docs --strict` exit 0, PATH `openspec`(1.12.0) 같은 명령 exit 0 |

델타 반영 순서 RENAMED → REMOVED → MODIFIED → ADDED에서 문제 없음: 이 change에 RENAMED는 없고,
REMOVED한 헤더를 MODIFIED가 가리키지 않으며, ADDED 헤더는 모두 메인에 없는 새 이름이다(사본 archive가 증명).
ADDED는 메인 spec 끝에 델타 파일 순서대로 붙는다.

### 결정 5. Purpose 갱신

sdd-sync 4절 예외. finalizer는 아래 capability의 메인 spec `## Purpose` 본문(제목 다음 줄부터 `## Requirements` 앞 빈 줄까지)을
**아래 문장 한 문단으로 글자 그대로** 바꾼다.

#### Purpose 갱신

- `agent-instructions/project-context-completeness`:
  이 저장소 자신의 `openspec/config.yaml`이 `context:`로 프로젝트 사정(지시문 위치, 실행 파일, 검증 수단, 문서 관례)을 실제로 에이전트에게 전달하게 하고, 그 값이 YAML 들여쓰기 실수로 조용히 무시되지 않게 한다. 그래서 사이클마다 스택 정보를 사람이 손으로 프롬프트에 적지 않아도 된다.
- `agent-instructions/skill-tool-invocation-rationale`:
  "openspec 스킬을 직접 부르지 마라"는 지침이 사실인 근거 위에 서게 한다. 근거는 openspec 스킬이 frontmatter의 `allowed-tools: Bash(openspec:*)`로 도구를 좁힌다는 사실이고, 그 문단은 `sdd-rules` 한 곳에만 둔다. "`Skill` 도구가 없을 수 있다" 같은 사실이 아닌 근거는 어디에도 두지 않는다.
- `process/field-validation-record`:
  직접 작업과 SDD 작업(orchestra의 작은 작업 경로 / 큰 작업 경로)을 같은 항목(품질 / 소요 시간 / 토큰)으로 기록하고 비교해, 파이프라인의 각 단계를 남길지 뺄지를 느낌이 아니라 기록으로 정할 수 있게 하는 측정 문서와 `claude plugin eval` 사례 폴더 뼈대가 갖춰야 할 요구사항을 정한다.

### 결정 6. 지시문 Edit (델타 없음, 커밋 단위 ②)

모두 Edit 부분 수정. "찾을 글자"는 지금 파일에 정확히 한 번 있는 글자다(설계 시점 `grep -cF` 실측). 줄 번호는 참고용이다.
표 칸에서 글자 전체를 감싼 **바깥** 백틱(한 개 또는 두 개)은 표시용이고 파일 글자가 아니다. 그 안쪽의 백틱은 파일 글자다.
`<br>`는 줄바꿈이다(파일에서도 줄을 나눈다). "…"는 그 사이 글자를 바꾸지 않는다는 뜻이다.

| # | 파일 | 찾을 글자 | 바꿀 글자 |
|---|---|---|---|
| 28 | `skills/orchestra/SKILL.md` (382) | 아래 블록 A의 "지금" | 블록 A의 "바꾼 뒤" |
| 29 | `skills/orchestra/SKILL.md` (466) | `- **"이거 왜 이래?" 같은 조사 요청** → analyzer만.` | `- **"이거 왜 이래?" 같은 조사 요청** → preparer → analyzer. analyzer는 change가 있어야 돌므로 preparer가 먼저 change를 만든다. preparer 뒤 요구사항 확인은 묻지 않는다(조사라 아직 고칠 범위가 없다). 분석 결과를 보여 주고 고칠지 한 번 묻는다(고치면 3단계(방안 선택)부터 이어 간다).`<br>`  고치지 않고 끝나면 "사용자가 중간에 취소할 때" 절차로 만든 change·브랜치를 남길지·지울지·나중에 이어 갈지 묻는다.` |
| 30 | `skills/sdd-rules/SKILL.md` (63) | ``- `sdd-openspec archive` (`archive: 해도 됨`일 때 finalizer만), 메인 spec 파일 삭제, capability 은퇴`` | ``- `sdd-openspec archive` (`archive: 해도 됨`일 때 finalizer만), 메인 spec 파일 삭제·capability 은퇴 (finalizer가 `sdd-sync`의 은퇴 여섯 조건을 모두 확인했고, 그 change의 커밋을 사용자가 커밋 관문에서 승인했을 때만 예외 — 오케스트레이터가 커밋 확인 때 은퇴 대상을 보여 준다. 사용자가 커밋 관문에서 "알아서 해"라고 했으면 그 뒤 change의 은퇴도 사전 승인으로 본다)`` |
| 30·G4 | `skills/orchestra/SKILL.md` (346 다음 줄) | `- 리뷰 통과 결과와 `git diff --stat` 요약을 보여주고 **커밋해도 되는지 한 번 확인한다.**` | 그 줄 + 새 줄: ``- change의 `.openspec.yaml`에 `retire_capabilities: true`가 있으면 이 확인에 **은퇴할 capability(지워질 메인 spec 경로)**를 함께 보여 준다. 사용자가 커밋을 승인하면 그것이 은퇴 승인이다(`sdd-rules` "되돌릴 수 없는 일"의 예외). "알아서 해" 뒤에는 은퇴 대상을 알리기만 한다(사전 승인). 은퇴를 원하지 않으면 커밋하지 말고 designer에게 돌려보낸다.`` |
| 30 | `agents/designer.md` (147) | `이유를 적는다. **이 마커가 없으면 finalizer가 메인 spec 파일을 지우지 못하고 sync가 멈춘다.**` | `이유를 적는다. **이 마커가 없으면 finalizer가 메인 spec 파일을 지우지 못하고 sync가 멈춘다.** 마커는 은퇴 예약일 뿐이다 — 실제 삭제는 커밋 관문에서 사용자가 승인한 뒤 finalizer가 한다.` |
| 31 | `skills/orchestra/SKILL.md` (103-105) | `regression-verifier까지)가 사라지고, 큰 작업이면 결정 기록(decision.md)도 사라진다.** analyzer를 부른 경우에는`<br>`사용자의 방안 선택 관문까지 사라진다.` | `regression-verifier까지)가 사라진다.** analyzer를 부른 경우에는`<br>`결정 기록(decision.md)과 사용자의 방안 선택 관문까지 사라진다.` |
| 31 | `skills/orchestra/SKILL.md` (68, 그림) | `[designer]  decision.md + specs 델타 + design.md + tasks.md  (설계 요약을 알린다)` | `[designer]  specs 델타 + design.md + tasks.md (+ analyzer를 불렀으면 decision.md)  (설계 요약을 알린다)` |
| 31 | `skills/orchestra/SKILL.md` (88, 표) | `(큰 작업만) decision.md + specs 델타 + design.md + tasks.md \|` | `(큰 작업만) specs 델타 + design.md + tasks.md (+ analyzer를 불렀을 때만 decision.md) \|` |
| 31 | `agents/designer.md` (238, 보고 양식) | `- decision.md — 채택안 <N안>` | `- decision.md — 채택안 <N안> (analyzer를 불렀을 때만. 생략 경로면 "decision.md 없음 (analyzer 생략 경로)")` |
| 31 | `agents/reviewer.md` (174) | `기준으로 삼은 채택안: <N안> (decision.md)` | `기준으로 삼은 채택안: <N안> (decision.md) / 없음 — decision.md 없음(analyzer 생략 경로), 기준은 proposal의 받아들일 조건` |
| 32 | `agents/designer.md` (3) | `description: 파이프라인의 3번 타자. 사용자가 고른 방안을 받아서 OpenSpec 산출물(specs 델타, design.md, tasks.md)과 결정 기록(decision.md)을 작성한다.` | `description: 큰 작업의 설계 담당(preparer 다음, analyzer를 불렀으면 사용자 선택 다음). 사용자가 고른 방안 — analyzer를 부르지 않았으면 proposal의 받아들일 조건 — 을 받아서 OpenSpec 산출물(specs 델타, design.md, tasks.md)을 작성하고, 고른 안이 있으면 결정 기록(decision.md)도 남긴다.` |
| 32 | `agents/designer.md` (13-14) | `너는 analyzer 다음 타자다.`<br>`사용자가 고른 안을 받아서, **worker가 고민 없이 따라 만들 수 있는 설계**로 바꿔 놓는다.` | `너는 큰 작업에서 preparer 다음(analyzer를 불렀으면 사용자가 안을 고른 다음)에 돈다.`<br>`사용자가 고른 안 — analyzer를 부르지 않은 평소 큰 작업이면 proposal의 받아들일 조건 — 을 받아서, **worker가 고민 없이 따라 만들 수 있는 설계**로 바꿔 놓는다.` |
| 32 | `agents/designer.md` (27-28) | `**둘 중 하나만 있으면 정상 진행이다** — 버그 수정처럼 방안 비교가 필요 없는 경로는`<br>`` `analyzer 생략: 예`로 정당하게 채택안이 없다.`` | `**둘 중 하나만 있으면 정상 진행이다** — analyzer를 부르지 않은 큰 작업(평소 큰 작업 전부)은`<br>`` `analyzer 생략: 예`로 정당하게 채택안이 없다.`` |
| 32 | `agents/designer.md` (65) | ``- `<changeRoot>/analysis.md` `` (읽을 것 목록의 그 줄) | ``- `<changeRoot>/analysis.md` (analyzer를 불렀을 때만 있다. 없으면 건너뛴다)`` |
| 32 | `agents/designer.md` (108) | `방안 선택을 거치지 않은 경로다(원인이 명확한 버그 등).` | `방안 선택을 거치지 않은 경로다(analyzer를 부르지 않은 큰 작업 — 평소 큰 작업 전부).` |
| 32 | `agents/designer.md` (231) | `RESULT: 설계완료 \| change=<이름> \| 채택안=<N안> \|` | `RESULT: 설계완료 \| change=<이름> \| 채택안=<N안/없음> \|` |
| 32 | `agents/designer.md` (235) | `반영한 안: <N안 — 이름>  (decision.md에 기록함)` | `반영한 안: <N안 — 이름>  (decision.md에 기록함) / 없음 — analyzer 생략, 기준은 proposal의 받아들일 조건 (decision.md 없음)` |
| 33 | `agents/analyzer.md` (3) | `description: 파이프라인의 2번 타자. preparer가` … `자기 의견과 그 이유까지 보고한다. 코드베이스 탐색/검색도 이 에이전트가 맡는다.` | `description: 사용자가 분석·방안 비교를 요청했을 때만 preparer 다음에 부르는 분석 담당. preparer가` … `자기 의견과 그 이유까지 보고한다.` (가운데 글자는 그대로) |
| 33 | `agents/analyzer.md` (13) | `너는 preparer 다음 타자다.` | `너는 사용자가 분석·방안 비교를 요청했을 때만 preparer 다음에 불린다(옵트인).` |
| 33 | `agents/worker.md` (3) | `description: 파이프라인의 4번 타자. ` | `description: 구현 담당(작은 작업은 preparer, 큰 작업은 designer 다음). ` |
| 33 | `agents/worker.md` (33) | `- 너는 7개 중 유일하게 파일을 쓰는 에이전트다. 가장 조심해야 한다.` | `- 너는 프로젝트 파일(코드·지시문·문서)을 고치는 유일한 에이전트다. 다른 에이전트는 change 안의 자기 산출물만 쓴다. 가장 조심해야 한다.` |
| 33 | `agents/reviewer.md` (3) | `description: 파이프라인의 5번 타자. ` | `description: 검증 담당(worker 다음). ` |
| 34 | `agents/reviewer.md` (129-130) | `- 프롬프트에 `테스트: 1회 — <명령 또는 없음>`이 있으면 그 명령(없으면 프로젝트에서 찾음)을 **한 번** 돌린다.`<br>`- 결과를 review.md `### 테스트 (1회)`에 출력 그대로 남긴다. 이번 변경 탓으로 깨지면 [막음]. 명령이 없으면 "테스트 없음".` | `- 프롬프트에 `테스트: 1회 — <명령 또는 없음>`이 있으면 그 명령을 **한 번** 돌린다. 값이 `없음`이면 프로젝트에서 찾지 않고 돌리지 않는다 — 테스트 명령은 preparer가 찾는다.`<br>`- 결과를 review.md `### 테스트 (1회)`에 출력 그대로 남긴다. 이번 변경 탓으로 깨지면 [막음]. 값이 `없음`이면 "테스트 없음"(RESULT `tests=없음`).` |
| 35 | `agents/finalizer.md` (115) | `- 커밋 메시지 끝에 붙인다:` | `- 커밋 메시지 끝에는 하네스(시스템 안내)나 사용자가 지정한 attribution 줄(모델 이름이 든 `Co-Authored-By:` 줄 등)을 글자 그대로 붙인다. 지정된 줄이 없을 때만 아래 기본 줄을 붙인다:` (코드펜스와 기본 줄은 그대로) |
| 37 | `skills/sdd-rules/SKILL.md` (76) | `- 보고서를 파일로 따로 남기지 않는다(지침이 정한 산출물은 예외). 마지막 답변으로 돌려준다.` | `- 보고서를 파일로 따로 남기지 않는다. 마지막 답변으로 돌려준다. 지침이 쓰라고 정한 `analysis.md`·`decision.md`·`review.md`와 design·tasks가 정한 검증 기록(`verification.md` 등)은 다음 에이전트가 읽는 파이프라인 산출물이지 보고서 파일이 아니다 — 지침대로 쓴다. 쓰기가 막히면 막힌 사실과 쓰려던 내용을 보고서에 적는다.` |
| 37 | `agents/analyzer.md` (93) | ``- `<changeRoot>/analysis.md`에 위 내용을 저장한다.`` | ``- `<changeRoot>/analysis.md`에 위 내용을 저장한다. 이 파일은 designer·reviewer가 읽는 파이프라인 산출물이다(보고서 파일 아님, `sdd-rules`). 쓰기가 막히면 막힌 사실과 내용을 보고서에 적는다.`` |
| 37 | `agents/reviewer.md` (134) | ``` `<changeRoot>/review.md`에 아래 보고 내용을 그대로 저장한다.``` | ``` `<changeRoot>/review.md`에 아래 보고 내용을 그대로 저장한다. 이 파일은 finalizer가 읽는 파이프라인 산출물이다(보고서 파일 아님, `sdd-rules`).``` |
| 38 | `agents/regression-verifier.md` (102) | `   확인 방법: (stash 대조했으면 그 결과)` | `   확인 방법: (`git show <기준커밋>:<파일>`로 바꾸기 전 내용과 대조했으면 그 결과)` |
| 39 | `agents/preparer.md` (22) | `` `openspec store list --json` `` | `` `sdd-openspec store list --json` `` |
| 40 | `skills/orchestra/SKILL.md` (40) | `RESULT: 통과 \| change=add-2fa \| scope=만진파일 \| blockers=0 \| should_fix=2 \| notes=1` | `RESULT: 통과 \| change=add-2fa \| scope=만진파일 \| tests=안맡음 \| blockers=0 \| should_fix=2 \| notes=1` |
| 36 | `skills/init/SKILL.md` (78) | `- 새 세션을 열 필요는 없다. 다음 세션부터 훅이 지휘 규칙을 넣는다.` | `- 훅(지휘 규칙 주입)은 다음 세션부터 켜진다. 지금 세션을 다시 열 필요는 없다.` |

표 안의 `\|`는 표 칸 구분과 헷갈리지 않게 적은 것이고, 실제 파일 글자는 `|`다.

**블록 A (#28, `skills/orchestra/SKILL.md` "설계 수정이 필요해졌을 때")**

지금:

```
Agent(subagent_type: "sdd:designer", prompt: "change 이름: <이름>\nstore: <id>\n이미 산출물이 있다. 고쳐야 한다.\n바뀐 사실: <worker 보고 또는 사용자 결정>\n\n이미 있는 산출물을 고치는 절차대로 산출물을 앞뒤 맞게 갱신하라. decision.md의 채택안도 함께 갱신하라.")
```

바꾼 뒤(코드펜스 안 한 줄 + 펜스 뒤 목록 두 줄):

```
Agent(subagent_type: "sdd:designer", prompt: "change 이름: <이름>\nstore: <id>\n브랜치: <이름>\nanalyzer 생략: 예\n채택안: 없음 — proposal의 받아들일 조건이 기준\n이미 산출물이 있다. 고쳐야 한다.\n바뀐 사실: <worker 보고 또는 사용자 결정>\n\n이미 있는 산출물을 고치는 절차대로 산출물을 앞뒤 맞게 갱신하라. decision.md가 있고 채택안이 바뀌었으면 decision.md도 갱신하라.")
```

펜스 바로 뒤에 붙일 목록:

```
- **채택안 줄을 빼지 마라.** 위는 analyzer를 부르지 않은 change의 예시다. analyzer를 불러 안을 고른 change면
  `analyzer 생략: 예`·`채택안:` 두 줄 대신 `사용자가 고른 안: <decision.md의 채택안 또는 사용자가 새로 고른 안>`을 넣는다.
  둘 다 없으면 designer가 `설계중단 reason=채택안 없음`으로 멈춘다(4단계와 같은 이유).
```

### 결정 7. 문서 Edit (델타 없음, 커밋 단위 ③)

| # | 파일 | 찾을 글자 | 바꿀 글자 |
|---|---|---|---|
| 31 | `README.md` (45-46) | `**커밋 직전 확인**(diff 요약을 보고 확인). 큰 작업에는 여기에 **결정 기록**과 **설계 요약`<br>`알림**(설계가 끝났을 때)이 더해진다.` | `**커밋 직전 확인**(diff 요약을 보고 확인). 큰 작업에는 여기에 **설계 요약`<br>`알림**(설계가 끝났을 때)이 더해진다.` |
| 31 | `README.md` (370-371) | `**그걸 직접 쓰면 결정 기록(decision.md)과 리뷰 단계가 사라진다.** analyzer를 부른 경우라면`<br>`  방안 선택 관문까지 함께 건너뛰게 된다.` | `**그걸 직접 쓰면 리뷰 단계가 사라진다.** analyzer를 부른 경우라면`<br>`  결정 기록(decision.md)과 방안 선택 관문까지 함께 건너뛰게 된다.` |
| 31 | `README.md` (96, 에이전트 표 designer 칸) | `` \| `designer` \| 큰 작업일 때만 — 결정 기록(decision.md), specs 델타, design.md, tasks.md \| `` | `` \| `designer` \| 큰 작업일 때만 — specs 델타, design.md, tasks.md (analyzer를 불렀으면 결정 기록 decision.md도) \| `` |
| 30 | `README.md` (360-361) | `` - **되돌릴 수 없는 일은 에이전트가 하지 않는다.** `git push`, `openspec archive`,`` + 다음 줄 `  메인 spec 파일 삭제는 사용자가 명시적으로 요청해야 한다.` | `` - **되돌릴 수 없는 일은 에이전트가 하지 않는다.** `git push`, `openspec archive`는`` + `  사용자가 명시적으로 요청해야 한다. 메인 spec 파일 삭제(capability 은퇴)는 커밋 확인 때 은퇴 대상을 보여 주고,`<br>`  사용자가 커밋을 승인한 change에서만 finalizer가 한다.` |
| 41 | `README.md` (66-67) | `고르시겠어요? 아니면 바로 설계로 갈까요?"도 함께 물어본다)` | `고르시겠어요? 아니면 바로 진행할까요?"도 함께 물어본다)` |
| 42 | `README.md` (84) | `\| "이거 왜 이래?" 조사 \| analyzer 1번 \| 1번 \| 0 \|` | `\| "이거 왜 이래?" 조사 \| `preparer → analyzer` (analyzer는 change가 있어야 돈다) \| 2번 \| 1~2 (고칠지 1번, 고치지 않고 끝나면 change 정리 1번. 고치면 3단계 방안 선택부터 큰 작업 관문이 이어진다) \|` (`orchestra` #29 문장과 같은 횟수) |
| 31 | `README.md` (118, "만들어지는 파일" 표) | `` \| `decision.md` \| designer \| **사용자가 고른 안** (리뷰의 기준) \| `` | `` \| `decision.md` \| designer \| **사용자가 고른 안** (리뷰의 기준, analyzer를 불렀을 때만) \| `` |
| 36 | `README.md` (171-175) | 아래 블록 B의 "지금" | 블록 B의 "바꾼 뒤" |
| 26 | `README.md` (179, 권한 절 끝) | `` `/sdd:init`은 권한 목록을 보여 주고 동의를 받은 뒤 `.claude/settings.local.json`에만 빠진 줄을 더한다. 공유 `.claude/settings.json`은 고치지 않는다.`` | 그 줄 + 빈 줄 + `` 훅 점검은 프로젝트의 두 파일(`.claude/settings.json`, `.claude/settings.local.json`)만 본다. 권한을 전역 `~/.claude/settings.json`에 두었다면 "권한에 Bash(sdd-openspec:*)가 없다" 경고는 무시해도 된다.`` |
| 43 | `README.md` (293) | ``- `.claude/agents/{preparer,analyzer,designer,worker,reviewer,regression-verifier,finalizer}.md` `` | ``- `.claude/agents/{preparer,analyzer,designer,worker,reviewer,regression-verifier,finalizer,code-explorer}.md` `` |
| 44 | `README.md` (331-334) | `  Tech stack: <언어/프레임워크>`<br>`  테스트: <실제 명령>`<br>`  빌드: <실제 명령>` | `  기술 스택: <언어/프레임워크>`<br>`  테스트 명령: <실제 명령>`<br>`  빌드 명령: <실제 명령>`<br>`  기본 브랜치: <이름>` (`관례:` 줄은 그대로. 라벨은 `bin/sdd-init` 137-140과 같다) |
| 43 | `.claude/skills/init-sdd/SKILL.md` (3) | `개인 agentic 설정(서브에이전트 7개,` | `개인 agentic 설정(서브에이전트 8개,` |
| 43 | `.claude/skills/init-sdd/SKILL.md` (514-515) | ``2. 서브에이전트가 잡히는지 본다: 에이전트 목록에 7개(`preparer`, `analyzer`, `designer`,`` + 다음 줄 ``   `worker`, `reviewer`, `regression-verifier`, `finalizer`)가 보이는지.`` | ``2. 서브에이전트가 잡히는지 본다: 에이전트 목록에 8개(`preparer`, `analyzer`, `designer`,`` + ``   `worker`, `reviewer`, `regression-verifier`, `finalizer`, `code-explorer`)가 보이는지.`` |
| 14 | `docs/field-validation.md` (3) | `직접 작업, SDD 경량 경로, SDD 정식 경로로` | `직접 작업, SDD 작은 작업 경로, SDD 큰 작업 경로로` |
| 14·45 | `docs/field-validation.md` (12-13) | `\| 경량 경로 \| orchestra + worker + reviewer + 커밋 관문 \| ② 이후 \|`<br>`\| 정식 경로 \| preparer → designer → worker → reviewer + regression-verifier → finalizer (analyzer는 요청할 때만) \| 가능 \|` | `\| 작은 작업 경로 \| `preparer → worker → reviewer → 커밋 관문 → finalizer` (orchestra 기본 경로) \| 가능 \|`<br>`\| 큰 작업 경로 \| `preparer → designer → worker → reviewer (+ regression-verifier, 조건부) → 커밋 관문 → finalizer` (analyzer는 요청할 때만) \| 가능 \|`<br>(표 바로 뒤 빈 줄 다음에) `orchestra의 경량 모드(worker → finalizer, 동작이 안 바뀌는 수정)는 비교 대상이 아니다.` |
| 45 | `docs/field-validation.md` (21) | `(지시문 정적 토큰 추정, ③ 이후)` | `(지시문 정적 토큰 추정)` |
| 45 | `docs/field-validation.md` (26) | `- (c) `claude plugin eval` grader 점수 (③ 이후)` | `- (c) `claude plugin eval` grader 점수` |
| 14 | `docs/field-validation.md` (51) | `L = 경량 경로, F = 정식 경로.` | `L = 작은 작업 경로, F = 큰 작업 경로.` |
| 14 | `docs/field-validation.md` (72) | `경량 경로를 기본으로 유지한다.` | `작은 작업 경로를 기본으로 유지한다.` |
| 45 | `docs/field-validation.md` (85) | `플러그인 전환(③) 뒤에는 `claude plugin eval` 로 품질 점수를 보조로 얻을 수 있다.` | `` `claude plugin eval` 로 품질 점수를 보조로 얻을 수 있다(저장소 루트에서 실행).`` |
| 14 | `evals/README.md` (25) | `` - `lite-path-small-task`: 경량 경로로 처리할 작은 작업.`` | `` - `lite-path-small-task`: 작은 작업 경로(`preparer → worker → reviewer → finalizer`)로 처리할 작은 작업.`` |
| 14 | `evals/lite-path-small-task/prompt.md` (6) | `이 자리는 경량 경로로 처리할 작은 작업` | `이 자리는 작은 작업 경로로 처리할 작은 작업` |

**블록 B (#36, `README.md` "훅 켜기·끄기")**

지금:

```
`/sdd:init`이 만드는 표식 파일 `openspec/.sdd`가 있는 프로젝트에서만 SessionStart 훅이
지휘 규칙과 점검 결과를 넣는다. 표식을 커밋하면 같은 저장소에서 플러그인을 깐 팀원에게도 켜진다.
그 프로젝트에서 끄려면 표식을 지운다. 모든 프로젝트에서 끄려면 `/plugin disable sdd`.
다음 세션부터 훅이 지휘 규칙을 넣는다.
```

바꾼 뒤:

```
`/sdd:init`이 만드는 표식 파일 `openspec/.sdd`가 있는 프로젝트에서만 SessionStart 훅이
지휘 규칙과 점검 결과를 넣는다. 켜는 것도 끄는 것도 다음 세션부터 적용된다.
표식을 커밋하면 같은 저장소에서 플러그인을 깐 팀원에게도 켜진다.
그 프로젝트에서 끄려면 표식을 지운다. 모든 프로젝트에서 끄려면 `/plugin disable sdd`.
```

범위 밖 관찰 — 오케스트레이터 지시로 정리함(구현 리뷰 뒤 재작업): 발견 목록에는 없지만 옛 경로 이름이 남은 5곳,
`agents/preparer.md`·`agents/finalizer.md` description의 "타자", `agents/worker.md` 137·`skills/orchestra/SKILL.md` 136의
"정식 경로", `README.md` 368 "경량 경로"를 지금 이름(작은 작업/큰 작업, 경량 모드)에 맞춰 고쳤다.

### 결정 8. finalizer 프롬프트에 글자 그대로 실을 블록

오케스트레이터는 커밋 관문 뒤 finalizer 프롬프트 끝에 아래를 **그대로** 붙인다.

```
[audit-specs-and-docs sync 지시]
1. 커밋은 다섯 단위로 나눈다. 한 커밋에 단위를 섞지 않는다. 메시지는 `type(scope): 한국어 서술`.
   ① change 산출물: openspec/changes/audit-specs-and-docs/ (proposal·specs·design·tasks·review.md)
   ② 지시문: agents/*.md, skills/orchestra/SKILL.md, skills/sdd-rules/SKILL.md, skills/init/SKILL.md
   ③ 문서: README.md, docs/field-validation.md, evals/README.md, evals/lite-path-small-task/prompt.md, .claude/skills/init-sdd/SKILL.md
   ④ 메인 spec sync: openspec/specs/** (Purpose 갱신 포함)
   ⑤ archive: archive: 해도 됨 이 있을 때만, 저장소 루트에서 `./bin/sdd-openspec archive audit-specs-and-docs --yes`
2. 델타 반영 순서는 RENAMED → REMOVED → MODIFIED → ADDED. 이 change에 RENAMED는 없다.
   REMOVED 9개는 블록째 지우고, MODIFIED·ADDED 블록은 델타에서 **글자 그대로** 옮긴다(손으로 다듬지 않는다 —
   뒤의 archive가 "Specs already in sync"로 끝나려면 블록이 같아야 한다). ADDED는 그 spec의 맨 끝에 델타 파일 순서대로 붙인다.
3. Purpose 갱신: design.md "결정 5"의 "Purpose 갱신" 목록 세 capability의 `## Purpose` 본문을 목록 문장 한 문단으로 글자 그대로 바꾼다.
   다른 capability의 Purpose는 건드리지 않는다.
4. 분할 대조 확인: (a) 대조 원본은 **sync 전 메인 spec으로 고정**한다. 저장소 작업트리를 손 sync(2·3) 뒤에 복사하면
   사본 archive가 "Specs already in sync"로 끝나 대조가 무의미하다. 그래서 작업트리가 아니라 시작 커밋에서 꺼낸다
   (시작 커밋 = tasks 1.1이 기록한 값 `5df62b21b69a7a5e07396552373fa7eef10cb731`, design.md Context와 같다. worker는 `openspec/specs/`를 안 건드렸다 — tasks 4.6).
   scratchpad 안에서 `set -eu; d=$(mktemp -d); git -C <저장소 절대경로> archive 5df62b21b69a7a5e07396552373fa7eef10cb731 openspec | tar -x -C "$d"`,
   이어서 `cp -R <저장소 절대경로>/openspec/changes/audit-specs-and-docs "$d/openspec/changes/"`(change 디렉터리는 시작 커밋에 없다).
   사본에서 `cd "$d" || exit 1; <저장소 절대경로>/bin/sdd-openspec archive audit-specs-and-docs --yes; echo "exit=$?"` → exit=0 이고
   출력에 "already in sync"가 **없어야** 한다. 그 `"$d"/openspec/specs`와 손 sync한 저장소 `openspec/specs`를 `diff -r`로 대조한다 —
   차이는 Purpose 세 곳뿐이어야 한다. (b) 메인 spec 시나리오 수 220 → 238(줄면 안 된다).
   (c) design.md "결정 3" 대조표의 새 헤더가 메인 spec에 모두 있고, "결정 2" 표의 지운 헤더 9개가 없다.
5. sync 뒤 저장소에서 `./bin/sdd-openspec validate --all --strict; echo "exit=$?"` → exit=0 이어야 한다(1.14.1, 실패 0개).
   `./bin/sdd-openspec validate --specs`와 `./bin/sdd-openspec validate audit-specs-and-docs`도 exit=0. 하나라도 아니면 커밋하지 말고 보고한다.
6. 500자 초과 0개 확인: 저장소 루트에서 spec마다 `./bin/sdd-openspec show <전체 id> --type spec --json --no-scenarios`의 `requirements[].text` 길이가 모두 500 이하.
   전체 id는 `openspec/specs/` 아래 경로다(예: `agent-instructions/lite-default-path`. 짧은 이름은 exit 1). 21개 전부:
   `for id in $(cd openspec/specs && find . -name spec.md | sed 's|^\./||; s|/spec\.md$||'); do ./bin/sdd-openspec show "$id" --type spec --json --no-scenarios | jq -r --arg id "$id" '.requirements[] | select((.text|length) > 500) | $id'; done` → 출력 0줄.
7. 범위 밖 확인: `git diff --stat 5df62b21b69a7a5e07396552373fa7eef10cb731.. -- bin hooks install.sh .claude-plugin` 출력이 비어 있다.
```

## Risks / Trade-offs

- [9개 헤더가 바뀌어 받아들일 조건 4의 "원래 헤더 유지"를 글자 그대로는 못 지킨다] → CLI 실측(E2-0, A, B)으로 다른 길이 없음을 보였고, 결정 2·3 표로 의무와 시나리오를 1:1 추적한다. 리뷰는 표로 대조한다.
- [MODIFIED가 원 시나리오를 못 옮겨, 나눈 의무와 그 의무를 확인하던 시나리오가 다른 헤더에 있을 수 있다] → 원 시나리오는 원 헤더에 남기고, 옮긴 의무마다 새 시나리오를 하나씩 붙였다(시나리오 220→238).
- [손 sync가 델타 블록과 한 글자라도 다르면 뒤의 archive가 ADDED 충돌로 실패한다] → finalizer 블록 2·4(a)에서 글자 그대로 옮기고 사본 archive 결과와 diff로 대조한다.
- [본문 480자를 넘는 요구사항이 다섯 있다(최대 496, 결정 4 표)] → 지금은 통과. 나중 change가 그 본문에 덧붙이면 다시 나눠야 한다.
- [#30 은퇴 예외가 "커밋 승인 = 은퇴 승인"이라 사용자가 "알아서 해"를 고른 뒤에는 묻지 않고 지나간다] → G4 결정대로 두고, sdd-rules 예외 문장과 orchestra 커밋 관문 줄에 "'알아서 해' = 사전 승인"을 글자로 적는다. 커밋 관문 알림에는 은퇴 대상이 항상 보인다.

## Migration Plan

1. worker가 tasks 2(지시문)·3(문서)를 Edit로 반영하고 4(통합 검증)를 돈다.
2. reviewer 판정 뒤 finalizer가 결정 8 블록대로 ①②③ 커밋 → sync(④) → archive(⑤, 승인 시).
3. 되돌리기: 커밋 단위가 나뉘어 있어 ④만 `git revert`하면 메인 spec이 원래대로 돌아간다(지시문·문서와 독립).
