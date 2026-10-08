최종 판정: 통과 (라운드 1, 2026-10-08)

RESULT: 통과 | change=lite-default-path-and-shared-rules | scope=만진파일 | tests=안맡음 | blockers=0 | should_fix=0 | notes=5

## 리뷰: lite-default-path-and-shared-rules
판정: 통과
판정 기록: /Users/0stone_1004/work-space/init-SDD/openspec/changes/lite-default-path-and-shared-rules/review.md
기준으로 삼은 채택안: 없음 (analyzer 생략 경로, decision.md 없음). 기준은 proposal의 받아들일 조건, specs 델타 9개, design.md D1~D10, tasks.md 머리말.

### OpenSpec 검증
openspec validate "lite-default-path-and-shared-rules" --strict:
```
Change 'lite-default-path-and-shared-rules' is valid
exit=0
```
openspec status --change "lite-default-path-and-shared-rules" --json: exit=0, isComplete=true. proposal/specs/design/tasks 모두 done.

### sdd-rules 주입 확인 (D10-7, reviewer가 직접 다시 돌림)
방법: 저장소를 scratchpad의 mktemp 디렉터리에 `cp -R`로 복사하고, 그 사본에서 새 `claude -p` 프로세스를 띄웠다(Claude Code 2.1.294).
프롬프트를 `--allowedTools "Agent"` 앞에 두었다.
- 기대 문장: `## store 처리` 바로 아래 첫 줄
  `프롬프트의 \`store: <id>\` 값이 있으면 그 store가 이번 작업의 OpenSpec 기준 저장소다.`
- 실행 전 `grep -rnF "$expected" .claude CLAUDE.md` → `.claude/skills/sdd-rules/SKILL.md:35` 한 곳만 나옴 (sdd-rules에만 있는 문장)
- 명령: `claude -p "Agent 도구로 subagent_type \"$a\" 를 한 번만 불러라. ... 없으면 NONE 이라고만 답하라. ..." --allowedTools "Agent"`

| 에이전트 | 출력 | 판정 |
|---|---|---|
| reviewer | 프롬프트의 `store: <id>` 값이 있으면 그 store가 이번 작업의 OpenSpec 기준 저장소다. | 기대와 일치 |
| finalizer | 프롬프트의 `store: <id>` 값이 있으면 그 store가 이번 작업의 OpenSpec 기준 저장소다. | 기대와 일치 |
| code-explorer | NONE | 기대대로 (skills 없음) |

세 실행 모두 rc=0. stderr에 "Ignoring 10 permissions.allow entries ... workspace has not been trusted" 경고 한 줄이 섞였는데, 사본이 신뢰되지 않은 작업 공간이라서 나는 것이고 판정과는 상관없다.
나머지 5개(preparer, analyzer, designer, worker, regression-verifier)는 worker ## 12.8 보고(7개 일치 + code-explorer NONE)를 근거로 삼고, 직접 다시 돌리지는 않았다.
덧붙임: 이 reviewer 세션은 새 reviewer.md 정의로 떴고 sdd-rules 본문이 컨텍스트에 주입된 상태였다. 주입이 된다는 증거가 하나 더 있는 셈이다.

### 작은 작업 CLI 재현 (reviewer가 일부 다시 돌림)
mktemp 빈 git 프로젝트에서 `openspec init --tools claude`(로컬 1.12.0)를 돌리고, proposal.md + tasks.md + `skip_specs: true`(preparer의 마커 명령 블록 그대로)로 change를 만들었다:
```
Change 'a-skip' is valid
ℹ [INFO] file: skip_specs is set in .openspec.yaml: change declares no spec-level behavior changes, zero deltas accepted
validate rc=0
state= ready
```
작은 델타 경우와 1.14.1 쪽은 worker ## 12.5 보고를 근거로 삼았다.

### 요구사항 충족
경량 경로·분기 (lite-default-path)
- 기본 경로 = 작은 작업 경로이고 큰 작업에만 designer를 둔다 → 충족 (.claude/skills/orchestra/SKILL.md:50-72 그림. size= 분기, 작은 갈래 [worker], 큰 갈래에만 [designer], analyzer는 흐름 밖 72행)
- 큰 작업 판정 기준이 orchestra 한 곳에 있다 → 충족 (orchestra:149-165. 네 조건 + 분석 요청, "애매하면 큰 작업"). `grep -c "큰 작업"` = 23. preparer.md에서 `여러 모듈|외부 의존|마이그레이션` 0건. 에이전트 파일에서 걸린 줄은 regression-verifier.md:70 "설정/환경변수/마이그레이션이 필요한데 빠뜨린 곳" 하나로, 판정 기준 문장이 아니다
- preparer RESULT 준비완료 줄에 `size=작음|큼` → 충족 (preparer.md:194-195). 준비중단 줄(196)에는 `branch=`가 있고 `size=`는 없다. 본문에 `크기:`, `테스트 명령:` 줄(202-203)이 있다
- 작은 작업이면 preparer가 tasks와 델타를 쓴다 → 충족 (preparer.md:144-153 `openspec instructions tasks`/`specs`, skip_specs 선택, size=큼이면 건너뜀). 마커 명령 블록, Write/`>` 금지, 두 종료코드, 세 가지 진단, "skip_specs를 설정하지 않았다면" 조건이 모두 남아 있다 (126-133, 155-178). 작은 작업의 `--strict`와 `state: ready` 확인 (179-180)
- regression-verifier 호출 조건과 reviewer 테스트 1회 → 충족 (orchestra:163-165, 292-298. reviewer.md:22-25, 128-131, 152, 166, 179-180. finalizer.md:47-54의 `생략(...)` 세 이유와 "줄이 없으면 멈춤")
- "designer를 생략하면 안 된다" 0건, 작은 작업 → 큰 작업 올리기 → 충족 (orchestra:379-385. `analyzer 생략: 예`, `채택안: 없음`, "이미 있다" 줄이 있다)

공용 규칙·스캐폴드 의존 제거 (shared-pipeline-rules, skill-tool-invocation-rationale, code-explorer-invocation)
- sdd-rules·sdd-sync가 있고 frontmatter는 name·description만이다 → 충족 (각 SKILL.md:1-4)
- 반복 절 제목이 에이전트에 0건이고 sdd-rules에 각 1건 → 충족 (sdd-rules:11, 27, 33, 44, 51, 63, 72에 일곱 절)
- 7개 에이전트의 `skills:`에 sdd-rules가 있고, finalizer만 sdd-sync를 더 갖고, code-explorer에는 skills 줄이 없다 → 충족 (각 파일 6행)
- 스캐폴드 참조 grep(agents, orchestra, sdd-rules, sdd-sync) 0건 → 충족
- `allowed-tools`(지시문 범위로 한정: agents, orchestra, init-sdd, agent-model-tier, sdd-rules, sdd-sync, CLAUDE.md, README.md)는 sdd-rules:23 본문 한 곳에만 있고 frontmatter에는 없다 → 충족
- "`Skill` 도구가 없을 수 있다"가 agents, sdd-rules, README 어디에도 없다 → 충족
- sdd-sync가 sync 절차(경로 → 스냅샷 → RENAMED→REMOVED→MODIFIED→ADDED → 형식·Purpose 예외 → 재대조·두 validate)를 담고 archive를 돌리지 않는다 → 충족 (sdd-sync:10-77, `openspec archive` 0건, 은퇴 여섯 조건과 ⑤를 콕 집어 보고하라는 지시는 34-46)
- 스캐폴드 없이 돈다 → worker ## 12.6 보고(다섯 instructions와 archive 모두 rc=0)를 근거로 삼았고 다시 돌리지는 않았다. 지시문에 스캐폴드 참조가 0건이라 구조상으로도 맞다
- 새 세션 주입 확인이 review.md에 있다 → 충족 (위 절)

finalizer archive (finalizer-archive-rationale-accuracy)
- 근거 ①(되돌릴 수 없음)이 먼저 나오고 ②(stdin 문구)가 남아 있으며, `openspec archive "<이름>" --yes` 한 길이다 → 충족 (finalizer.md:125-150). "이중 적용", "안전망이 아니다", "Sync now"는 0건

마커 안전 (openspec-metadata-marker-safety) → 충족 (preparer.md:126-133, designer.md 마커 블록과 진단 유지)

설치·링크 (sdd-install-script, init-sdd-skill)
- install.sh: copy_if_absent로 sdd-rules·sdd-sync를 복사하고, 설치 확인은 네 스킬, 공식 스킬 6개 확인 블록은 삭제, "다음 할 일" 5번에 기존 설치 안내 → 충족 (install.sh:78-79, 123-125, 159-160). `bash -n` rc=0
- init-sdd: 표·cp·ln·exclude·세 `for p in` 줄(334, 401, 498)이 같은 여섯 경로를 같은 순서로 갖는다. 개수 낱말이 "여섯"으로 바뀌었고, 98행 "skills/ 안의 네 개"는 스킬 4개를 말하는 것이라 맞다 → 충족

줄 수 (기준선 2,823)

| 파일 | 지금 | 기준선 | 목표 | 판정 |
|---|---|---|---|---|
| analyzer | 142 | 175 | ≤130 | 기준선 아래, 목표에 못 미침 (+12) |
| code-explorer | 40 | 40 | ≤40 | 같음 (허용) |
| designer | 265 | 311 | ≤235 | 기준선 아래, 목표에 못 미침 (+30) |
| finalizer | 199 | 299 | ≤215 | 목표 달성 |
| preparer | 223 | 241 | ≤230 | 목표 달성 |
| regression-verifier | 117 | 148 | ≤110 | 기준선 아래, 목표에 못 미침 (+7) |
| reviewer | 209 | 224 | ≤205 | 기준선 아래, 목표에 못 미침 (+4) |
| worker | 199 | 242 | ≤210 | 목표 달성 |
| 에이전트 합계 | 1,394 | 1,680 | | 충족 |
| orchestra | 470 | 459 | ≤470 | |
| init-sdd | 551 | 541 | | |
| agent-model-tier | 143 | 143 | | |
| sdd-rules | 80 | 신규 | ≤95 | |
| sdd-sync | 77 | 신규 | ≤90 | |
| **합계** | **2,715** | **2,823** | | 충족 (-108) |

필수 조건(합계 < 2,823, 각 에이전트가 기준선보다 짧음)은 충족한다. 목표에 못 미친 4개는 proposal이 "보고로 처리"한다고 정해 둔 것이어서 막음이 아니다.

메인 spec 경로 수: `grep -ro '\.claude/' openspec/specs | wc -l` = 112 (기준선 그대로. 일괄 치환하지 않았다).

### 설계 준수
- D1 (판정 위치): preparer는 `instructions design` 출력과 orchestra 절을 가리키기만 한다 (preparer.md:137-142). 일치
- D3/D4 (sdd-rules·sdd-sync): 절 제목 일곱 개, 토큰 이름을 이어 쓰지 않은 것(sdd-rules:76 `[[ORCA_...]]`), 반영 순서와 Purpose 예외 모두 맞다
- D7 (역할 전용 절 제목): `^## 쓰는 스킬`이 에이전트에 0건이다. analyzer는 "산출물 형태 참고", finalizer는 "단계별로 쓰는 도구", designer는 "산출물 쓰는 절차", worker는 "구현 절차의 기준", reviewer는 "기준 문서"
- D8 (orchestra): description(3행), 그림, 단계표(78-86), `/opsx` 절 97-98행 "큰 작업이면 결정 기록(decision.md)도", 4단계 ①②, 5단계 `design.md: 없음(의도적)`, 6단계 작은 작업 프롬프트, 7단계 `regression 판정:` 생략 세 이유와 판단 주체(348행), 338행 "작은 작업이면", 456-461행 단계 줄이기. 일치
- D9 (설치·문서): 일치
- 경로 문구 일관성 (오케스트레이터 요청 대조)
  - 작은 작업 순서 `preparer → worker → reviewer → finalizer`: orchestra:3, 58-60, 458 / CLAUDE.md:13 / README.md:7, 195. 일치
  - 큰 작업 순서 `preparer → designer → worker → reviewer (+ regression-verifier) → finalizer`: orchestra:3, 61-64 / CLAUDE.md:14 / README.md:8, 196. 일치
  - 호출 횟수: README.md:195-196, 262 (작은 4번, 큰 5~6번, analyzer는 +1). orchestra에는 횟수 서술이 없어 부딪히지 않는다. preparer.md:222 다음 단계 문구도 맞다
  - regression-verifier 조건을 줄여 쓴 문구가 문서마다 조금씩 다르다 (참고 1)

### 작업 완료 검증
체크된 41개 중 41개를 실제로 확인했다 (미체크 0개).
- ## 1~11: 파일을 직접 읽거나 grep으로 확인했다. sed -i로 체크박스를 바꿔서 생길 수 있는 덮임이나 누락은 없다(41/41 `[x]`, tasks.md 본문과 코드펜스 정상)
- ## 12.1~12.4, 12.7(bash -n), 12.9: 다시 돌려 같은 결과를 얻었다
- ## 12.5: skip_specs 경우를 로컬 1.12.0으로 다시 돌려 일치했다. 작은 델타 경우와 1.14.1은 worker 보고에 기댄다
- ## 12.6, 12.7(실설치·cmp): worker 보고에 기댄다. 다시 돌리지 않았다
- ## 12.8: 3개 에이전트로 다시 돌려 일치했다 (위 절)

### 되돌릴 체크 항목
없음

### 발견 사항
1. [참고] README.md:8, README.md:212, CLAUDE.md:14 — regression-verifier 조건을 "테스트가 있을 때"로 줄여 적었다. 정본인 orchestra:163은 "큰 작업 + 실행 코드 변경 + 테스트 명령" 세 가지다(regression-verifier.md:14도 세 가지). 순서 일치 조건은 충족하고 판정 기준은 orchestra에만 두라고 했으니 문제는 아니다. 다만 문서만 바뀐 큰 작업에서 사용자는 회귀 검증이 붙을 거라고 기대할 수 있다.
2. [참고] .claude/agents/reviewer.md:129 — "그 명령(없으면 프로젝트에서 찾음)"과 130행 "명령이 없으면 '테스트 없음'"이 동시에 있어서, 오케스트레이터가 `테스트: 1회 — 없음`을 보냈을 때 프로젝트를 다시 뒤져야 하는지가 모호하다. preparer가 이미 찾아서 "없음"이라고 한 값이라 실제 피해는 작다.
3. [참고] .claude/agents/designer.md:108 — `analyzer 생략: 예` 경로를 "(원인이 명확한 버그 등)"으로 설명하는데, 이제는 analyzer 없는 큰 작업 전부의 평소 경로다(orchestra:252). 동작에는 영향이 없다.
4. [참고] .claude/skills/sdd-rules/SKILL.md:57은 "메인 spec 파일 삭제, capability 은퇴"를 예외 없이 보고만 할 일로 둔다. 그런데 .claude/skills/sdd-sync/SKILL.md:36은 여섯 조건(⑤ `retire_capabilities: true` 포함)을 만족하면 spec.md를 지운다. 옛 finalizer.md에도 같은 긴장이 있었으니(옛 93-96행과 은퇴 절차) 이번에 새로 생긴 것은 아니다. sdd-rules "되돌릴 수 없는 일"의 괄호 예외에 "(sdd-sync의 은퇴 여섯 조건을 모두 만족할 때 finalizer만)"을 넣으면 해석이 갈리지 않는다.
5. [참고] tasks.md:9, 76과 design.md:145는 무결성 검사 명령 문구로 토큰 이름을 글자 그대로 담고 있어서, `grep -c` 무결성 검사에 걸린다(tasks.md는 2). 실제로 끼어든 토큰은 아니다(`[[ORCA` 꼴로 찾으면 design.md:145의 설명 문구 하나뿐). 지시문 파일(agents, skills, CLAUDE.md, README.md)은 모두 0이다.

### 이번 change 것인지 확인 필요한 변경
없음. `git status --short`의 변경은 모두 만진 파일 목록에 있다. 미추적 `openspec/changes/lite-default-path-and-shared-rules/`는 이번 change의 산출물이다.

### 다음 단계
finalizer에게 넘긴다.
- regression 판정: 이번 change는 지시문·문서·install.sh만 바꿨고 테스트 명령이 없다. 오케스트레이터는 regression-verifier 결과나 `생략(...)` 줄을 글자로 실어야 한다.
- design.md의 "Purpose 갱신" 목록과 "finalizer 프롬프트에 글자 그대로 실을 문장" 블록을 finalizer 프롬프트에 그대로 싣는다. RENAMED→MODIFIED 순서도 함께 싣는다(옛 finalizer 대응. 오케스트레이터가 처리한다고 했다).
- 위 참고 5건은 고치지 않아도 된다. 고친다면 후속 change에서 한다.
