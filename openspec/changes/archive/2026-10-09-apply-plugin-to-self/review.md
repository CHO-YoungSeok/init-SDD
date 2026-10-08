최종 판정: 통과 (라운드 1, 2026-10-09)

RESULT: 통과 | change=apply-plugin-to-self | scope=만진파일 | tests=안맡음 | blockers=0 | should_fix=0 | notes=4

## 리뷰: apply-plugin-to-self
판정: 통과
판정 기록: openspec/changes/apply-plugin-to-self/review.md
기준으로 삼은 채택안: 없음(analyzer 생략 경로, decision.md 없음) — proposal 받아들일 조건 + 가정 A1~A8 + tasks 머리말 + design D1~D7

openspec: `./bin/sdd-openspec` 1.14.1 (PATH `openspec` 1.12.0으로도 교차 확인)

### OpenSpec 검증
```
$ ./bin/sdd-openspec validate apply-plugin-to-self --strict; echo "exit=$?"
Change 'apply-plugin-to-self' is valid
exit=0
$ openspec validate apply-plugin-to-self --strict   (1.12.0)
Change 'apply-plugin-to-self' is valid
rc=0
$ ./bin/sdd-openspec validate --all --strict
rc=1
Totals: 14 passed, 9 failed (23 items)      ← 기준선 9와 같다
✓ spec/agent-instructions/project-context-completeness
```
status --change: proposal·specs·design·tasks 모두 done, isComplete true.
델타 형태: `## MODIFIED Requirements` / `### Requirement:` 헤더가 메인 spec과 글자 일치 / 기존 시나리오 이름 유지 + `####` 시나리오 하나 추가 → sdd-sync 병합 가능.
`context`/`rules` 블록이 산출물에 복사된 흔적 없음.

### 요구사항 충족

델타 `agent-instructions/project-context-completeness` (MODIFIED)
- "context에 담을 최소 내용" → 충족 (openspec/config.yaml:12-34). `instructions proposal --json`의 `context`에서
  `agents/` `skills/` `claude plugin validate` `bash -n` `한국어` `쉬운 말` `Edit 부분 수정` 모두 True,
  `.claude/agents/*.md`·`실행 코드가 없는` 모두 False (리뷰어 재실측)
- 시나리오 "파싱 경고가 없다"(기존 요구) → `sdd-openspec context` rc=0, `Warning` 0건
- 시나리오 "플러그인 전환 전 사실이 남아 있지 않다" → 충족. "뿐" 문장은 config.yaml:19 "실행 파일은 위 bash 스크립트뿐이다" 하나이며 검증 수단 나열이 아니다

받아들일 조건 — 정리
- 스캐폴드 0개(`ls -d .claude/skills/openspec-* .claude/commands` → 0), `git ls-files .claude` 세 줄 그대로, `.gitignore` 두 줄 각 1, 남길 파일 test rc=0 → 충족
- `git status --short`에 삭제 흔적 없음 → 충족

받아들일 조건 — `.claude/CLAUDE.md`
- 루트 CLAUDE.md 없음(rc=1), 마커 각 1, `claude --plugin-dir .`·`SDD로 개발`·validate 두 명령·`sdd-openspec validate`·`bash -n`·`작업 단위로 나눈다`·구조 표 → 모두 구획 밖에 있음 (.claude/CLAUDE.md:1-62)
- `command grep -rl ... '^순서:' .` → `./.claude/CLAUDE.md` 한 줄 → 충족
- 구획 안 순서 줄 (.claude/CLAUDE.md:72-73) 작은/큰 경로가 orchestra와 같고 analyzer 기본 단계 아님 → 충족
- 구획 diff(HEAD 대비) = `10c10` regression-verifier 괄호 한 줄뿐 (가정 A3) → 충족. 뒤 공백 줄 등 나머지 바이트 그대로
- 임시 프로젝트(scratchpad mktemp): dry-run rc=0·작업트리 변화 없음, 실제 설치 rc=0, 구획 want/got diff rc=0, `init-SDD:begin` 1, agents 8, 설치된 CLAUDE.md에 구획 밖 개발자 안내 미유출 → 충족 (리뷰어 재실측)
- 탐침 `claude -p --plugin-dir . --model haiku` → "검증 명령은 저장소 루트에서 돌리고 종료코드로 판정한다." 인용, grep 1 → 충족 (리뷰어 재실측)
- design D3 (a) 문안과 실제 구획 밖 내용 diff rc=0 (design.md:115-177 대비)

받아들일 조건 — `README.md`
- 계약 키워드 K1~K26 전부 `grep -cF` ≥ 1, 위치 조건 눈 대조 일치:
  K1~K3 빠른 시작(README.md:12-25)과 플러그인으로 설치(154-167) 두 곳 / K4 개발 절(384-) / K6 "필요 없다(지워도, 남겨도 된다)" 문장(166-167) /
  K7 업데이트 절 재시작 문장 / K8 팀 배포 / K10 훅 절에 표식·삭제·`/plugin disable sdd`·커밋하면 팀원에게도 켜짐 /
  K11 `## 설치`(128) 바로 다음 `### 먼저 고른다 — ...`(130), 표 첫 행 플러그인(권장) / K14 방법 1 흐름: clone → cd → install → CLAUDE.md 확인 줄(232) → 새 세션 /
  K16 손 설치 cp와 설치 확인에 세 스킬만 / K22 analyzer 행 / K23 소개 문단과 경로 표 / K24 code-explorer 절 `모델 등급` 0 / K25 `.openspec.yaml` 행 / K26 2곳(9, 99)
- 금지 키워드 전부 0 (`^순서:`, `평가 모드`, `agent-model-tier`(-i), `grep generatedBy`, `switch_skill`, `테스트가 있을 때`, 사본 전제 서술, `관문이 사라졌다`)
- `.claude/agents` 줄: 215·239·255·256·293·304(기존 설치 방식 하위 절), 343(커스터마이즈 "복사·링크 방식이면") 뿐 → 충족
- 소개 문단 플러그인 기준, 단계 늘리기·번역 안내 `agents/`·`skills/` 기준 → 충족 (README.md:5-10, 347, 371)
- regression-verifier 조건 세 조건 + orchestra 지시 (README.md:8-9, 99) → 충족
- 첫 화면 순서: 소개 → `## 빠른 시작`(12) → … → `## 설치`(128) → 충족
- 목차가 design D4 목차와 순서·글자 일치 (`grep -n '^##'`)
- `install.sh:21`("'설치' 절"), init-sdd SKILL.md:11·23("`## 설치` 맨 앞")이 가리키는 제목 그대로, `^## 설치$` 1

받아들일 조건 — 공통
- `claude plugin validate . --strict` exit=0, `.claude-plugin/plugin.json --strict` exit=0
- `bash -n` 네 스크립트 rc=0
- 훅 exit=0 — 단 지금 출력은 `[SDD 점검] 끝났지만 archive 안 된 change: apply-plugin-to-self` (발견 사항 1 참고)
- 수정·새 `.md` 전부 리치 마크다운 토큰 0, 코드펜스 줄 수 짝수(들여쓴 펜스 포함: README 26, CLAUDE.md 2, design 24, 나머지 0), spec·proposal 등 frontmatter 없음(원래 없음)
- 커밋 분리 → finalizer 몫(아직 해당 없음)

사용자 요청 대조 ("구조 적용 / 필요 없는 부분 지우기 / CLAUDE.md·README 변화에 맞게")
- 구조 적용: 개발 지침이 `claude --plugin-dir .`·`sdd-openspec` 기준, config context가 플러그인 레이아웃 기준 → 충족
- 지우기: 무시된 스캐폴드 7경로 삭제, 남길 것 판정 표대로 유지 → 충족
- CLAUDE.md·README: 위 대조대로 충족. "spec 작성 후 검토 후 진행"은 설계 검토 2회로 이행됨(오케스트레이터 보고). "커밋은 작업 단위별로"는 finalizer 단계

### 설계 준수
- D1 델타: 헤더·기존 시나리오 이름 원문 그대로, 시나리오 하나 추가, 두 번째 요구사항 미포함 → 일치
- D2 config: design.md:57-79 블록과 실제 `context:` 블록 diff rc=0. 위 예시 주석·아래 주석 불변
- D3 CLAUDE.md: 구획 밖 문안 diff rc=0, 구획 안 한 줄만, 템플릿 안내 주석 삭제, 구획 밖 마커 글자 0
- D4 README: Write 재작성이 아니라 절 단위 Edit로 판단한다. 근거:
  - `git diff --stat` +161/−122, 14 hunk. 대부분이 75줄짜리 작동 방식 블록 이동(E2/E5)과 개발 절 이동(E6)이다
  - 이동 대조 M1(`1c1`·`38c38`·`47c47`·`58c58`), M2(`10a11`), M3(rc=0), M4(E3·E4 계획 차이만), M5(다섯 곳 + 끝 빈 줄) 모두 리뷰어가 다시 돌려 계획한 차이만 확인
  - "이게 왜 필요한가" HEAD 11-22행과 글자 동일, 소개·빠른 시작·커스터마이즈는 design 문안과 diff rc=0
  - 계획 밖 문장 변경·삭제 0 → 통째 재작성 흔적 없음
- D5 정리: 7경로만 사라짐, `.gitignore` 유지
- D6/D7: 해당 없음(병렬 묶음 / finalizer 커밋 단위)
- Non-Goals: `agents/ skills/ bin/ hooks/ .claude-plugin/ install.sh .claude/settings.json .gitignore .claude/skills/init-sdd` HEAD 대비 diff 0

### 작업 완료 검증
체크된 26개 중 26개 실제 확인 (1.1~1.2, 2.1~2.3, 3.1~3.3, 4.1~4.9는 결과물 재검사로, 5.1~5.9는 같은 명령 재실행으로).
5.5의 "이상 없음"은 당시(07:03, 마지막 체크 전) 출력으로 scratchpad `v5.RkqJPe/hook.out`에서 확인했다. 현재 출력이 다른 이유는 발견 사항 1.

### 되돌릴 체크 항목
없음

### 발견 사항
1. [참고] hooks/session-start.sh:40 — 지금 `CLAUDE_PROJECT_DIR="$PWD" bash hooks/session-start.sh`는 exit=0이지만
   `[SDD 점검] 이상 없음` 대신 `끝났지만 archive 안 된 change: apply-plugin-to-self`를 낸다. tasks 26/26이 끝나 훅이 정상적으로 알리는 것이다.
   받아들일 조건 "훅 → 이상 없음"은 archive 전까지 성립하지 않는 조건이라 결함이 아니다. archive는 사용자 요청 때만(tasks Workflow follow-up) — 사용자에게 알릴 것.
2. [참고] README.md:173 — `### 훅 켜기·끄기` 끝에 붙은 "다음 세션부터 훅이 지휘 규칙을 넣는다."가 바로 앞 "끄려면 … `/plugin disable sdd`." 뒤에 와서
   끈 뒤의 동작처럼 읽힐 수 있다. design 문안 글자 그대로라 설계 준수이고 사실도 틀리지 않는다. 다음 문서 정리(⑥) 때 순서만 다듬으면 좋다.
3. [참고] verification.md 5.8의 펜스 수(README 24, design 18)는 `^```` 만 센 값이다. 들여쓴 펜스까지 세면 README 26, design 24 — 둘 다 짝수라 판정은 같다.
4. [참고] README `## 개발` 절과 `.claude/CLAUDE.md` "띄우기"가 같은 사실(`--plugin-dir` 우선, 루트 CLAUDE.md 없음)을 짧게 반복한다. 계약("설치 안내는 README 한 곳")은 설치 안내 대상이라 위반 아님.

### 이번 change 것인지 확인 필요한 변경
없음 (`git status --short`: `M .claude/CLAUDE.md`, `M README.md`, `M openspec/config.yaml`, `?? openspec/changes/apply-plugin-to-self/` — 모두 만진 파일 목록 안)

### 다음 단계
finalizer에게:
- 메인 spec sync: `agent-instructions/project-context-completeness` MODIFIED (델타 형태 병합 가능 확인)
- D7 단위로 커밋: ① `openspec/config.yaml` + 메인 spec sync 결과 ② `.claude/CLAUDE.md` ③ `README.md` ④ change 산출물(이 review.md, verification.md 포함). 삭제는 무시된 파일이라 커밋 없음
- 사용자에게 알릴 것: 발견 사항 1(archive 전까지 훅이 "archive 안 된 change"를 알림), archive는 요청 시에만
