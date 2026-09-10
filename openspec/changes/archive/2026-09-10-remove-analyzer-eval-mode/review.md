최종 판정: 통과 (라운드 1, 2026-09-09)

# 리뷰 기록: remove-analyzer-eval-mode

## 라운드 1 (판정: 통과)

판정: 통과
기준으로 삼은 채택안: 모드 분기를 없애고 사용자 후보 처리를 방안 생성 절 안의 짧은 규칙으로
흡수한다 (`decision.md`, 2026-09-09 / 오케스트레이터 결정, analyzer 생략 경로)

blockers=0 / should_fix=1 / notes=2

### OpenSpec 검증

```
$ openspec validate "remove-analyzer-eval-mode" --strict; echo "exit=$?"
Change 'remove-analyzer-eval-mode' is valid
exit=0
```

`openspec status --change ... --json` → 4개 산출물(proposal/specs/design/tasks) 모두 `done`,
`isComplete: true`.

### 요구사항 충족 (specs/agent-instructions/analyzer-option-generation/spec.md)

**R1. analyzer 지침에 동작 모드 분기가 없어야 한다** → 충족

- frontmatter description에 평가 업무 없음 (`.claude/agents/analyzer.md:3`).
  "요구사항과 코드베이스 분석 → 방안 최소 3가지 + 장단점 + 의견" 설명은 유지됨.
- `## 두 가지 모드` 절 없음, `## 사용자 안 평가` 절 없음.
  `grep -rn '평가 모드|평가할 안|feasible=|두 가지 모드|사용자 안 평가' .claude README.md docs/example-run.md`
  → exit=1 (무매치).
- RESULT 줄 `.claude/agents/analyzer.md:122` =
  `RESULT: 분석완료 | change=<이름> | options=<개수> | recommend=<N안> | questions=<개수>`.
  `feasible=` 없음, 나머지 4개 필드 유지, `||` 겹침 없음.

**R2. 사용자 후보는 방안 생성 절차 안에서 같은 형식으로 평가** → 충족

`.claude/agents/analyzer.md:88-91`, `### 3. 방안 최소 3가지 만들기` 안,
`- **코드가 아예 없는 프로젝트면 축이 다르다.**`(85-87) 다음이자 `- 각 안마다 반드시:`(92) 앞.
design.md D2가 지정한 위치·문장과 일치. 요구된 세 알맹이 모두 존재:
같은 형식 평가(88) / 번호 이어 붙임(89) / 성립 안 하면 파일:줄로 짚음(90-91).

**R3. 검증 안 된 안으로 설계에 들어가지 않는 안전장치** → 충족

`.claude/skills/orchestra/SKILL.md:185-192`:
- `바로 designer로 가지 마라. **검증 안 된 안을 설계하면 worker가 벽에 부딪힌다.**` (187) 유지
- `analyzer를 **다시 부르되, 그 안을 추가 후보로 얹어 보낸다:**` (188) — `(평가 모드)` 없음
- 호출 예시 (190): `평가할 안:` 없음, `사용자가 낸 안: <사용자가 말한 내용 그대로>` 있음.
  나머지 구성(`change 이름` / `store` / `브랜치` / `preparer가 확정한 것`)이
  2단계 호출 예시(`SKILL.md:163`)와 **문자 단위로 동일**. 한 줄, 코드펜스 안.
- `- 결과를 보여주고 **다시 고르게 한다.**` (191) 유지
- `analyzer가 "성립하지 않는다"고 하면 ... 사용자 아이디어라고 그냥 밀어주지 마라.` (191-192) 유지
- 파이프라인 그림 `SKILL.md:55` =
  `   ↓    사용자가 자기 안을 내면 → 그 안을 후보로 얹어 analyzer 재호출 → 다시 고르게 한다`
  들여쓰기 유지, `(평가 모드)` 없음, 감싼 코드펜스 온전.

**양쪽 맞물림 (이번 change의 급소)** → 맞물린다.
보내는 쪽 `SKILL.md:190`의 `사용자가 낸 안:` 키 ↔ 받는 쪽 `analyzer.md:88`의
"프롬프트에 사용자가 낸 후보가 함께 오면". 한쪽만 고쳐진 상태 아님.

**R4. 사용자 문서에 없어진 모드가 남아 있지 않아야 한다** → 충족

- `docs/example-run.md:102-103` — "평가 모드" 없음.
  `그 안을 **후보 하나로 얹어 analyzer를 다시 부른다.**` /
  `analyzer는 그 안이 실제로 성립하는지 코드로 확인하고, 안 되면 안 된다고 말한다.`
  → "코드로 확인하고 안 되면 안 된다고 말한다"는 취지 보존됨.
- `README.md` — 수정되지 않음(git status 무변경). 에이전트 표 `README.md:160` =
  `| analyzer | 코드베이스 분석, **방안 최소 3가지 + 의견과 근거** | opus |`. 평가 모드 언급 없음.
- `docs/verification-2026-09-08.md`의 "평가 모드" 5곳은 design.md Non-Goals에 따라 대상 아님.
  spec R4의 "날짜가 박힌 검증 기록은 대상이 아니다" 단서와 일치. 결함 아님.

**R5. 파일 손상 없음** → 충족 (design.md 기준선과 대조)

| 파일 | ORCA_RICH_MD | 코드펜스 | 기준선 |
|---|---|---|---|
| `.claude/agents/analyzer.md` | 0 | 4 | 4 일치 |
| `.claude/skills/orchestra/SKILL.md` | 0 | 28 | 28 일치 |
| `docs/example-run.md` | 0 | 24 | 24 일치 |

frontmatter(`analyzer.md:1-7`) `---`로 열고 닫히며 `name:` / `description:` / `model:` /
`tools:` / `skills:` 전부 유지. `description:`은 한 줄 그대로.
`git diff`상 두 파일 모두 최소 범위 부분 수정(+10/-27). Write 전체 재작성 흔적 없음.

**R5 부속: 지우지 않아야 할 규칙** → design.md D5 "남기기로 한 것" 10항목 전수 대조, 전부 생존.

| D5 항목 | 위치 |
|---|---|
| 고르는 건 사용자가 한다 | analyzer.md:17 |
| 설계 문서도 코드도 쓰지 않는다 (화이트리스트) | analyzer.md:18 |
| Bash로도 바꾸지 마라 (`sed -i`, 포매터 `--write`) | analyzer.md:19 |
| explore는 결론을 내주지 않는다 | analyzer.md:24-25 |
| `Skill` 도구가 없을 수 있다 블록인용 | analyzer.md:31-34 |
| store 처리 절 | analyzer.md:41-46 |
| 경로를 CLI에서 얻으라 | analyzer.md:50-54 |
| `resolvedOutputPath`를 파일로 취급하지 마라 | analyzer.md:58 |
| 관찰한 사실과 추측 구분 | analyzer.md:71 |
| 정량 요구사항 기준선 측정 | analyzer.md:74-76 |
| 방안 축(axis) 목록 | analyzer.md:80-84 |
| 스택 없으면 혼자 정하지 마라 | analyzer.md:85-87 |
| analysis.md 맨 위 경고 줄 | analyzer.md:107-110 |
| 코드 수정 금지 / 하지 말아야 할 것 | analyzer.md:112-117 |
| 보고 형식 | analyzer.md:119-161 |

### 설계 준수

- **D1 (Edit 부분 수정)** → 준수. diff가 국소 수정만 보여준다.
- **D2 (규칙 위치·문장)** → 준수. 위치·네 줄 문장 모두 설계대로.
- **D2 표의 "버림" 3항목 실지 확인**:
  - 2번 "실제 코드로 성립하는지 확인" → `### 2. 코드베이스 분석`(63-72)이 실제로 덮는다.
    "요구사항과 닿는 코드를 실제로 읽는다. 추측하지 마라"(64),
    "제약: 의존성, 테스트, 설정, 성능, 하위 호환"(69)이 원문의 "라이브러리 버전, 기존 구조,
    제약과 부딪히는지"를 포함한다. **확인됨.**
  - 6번 "기존 추천과 비교해 의견 재산출" → `### 4. 내 의견 내기`(100-103)가 매 실행마다
    전체 안을 놓고 추천을 새로 내게 한다. **확인됨.**
  - 4번 "부분 성립이면 다듬은 변형안 제시" → **확인 안 됨.** 아래 발견 사항 1 참조.
- **D3 (`feasible=` 대체 필드 없음)** → 준수. RESULT 필드 4개뿐.
- **D4 (안전장치 절 유지, 호출 형태만 변경)** → 준수. 위 R3 참조.
- **D5 S1 (뜬 문장 이동)** → 준수. 블록인용 뒤에 떠 있던
  `(specs 델타가 어떤 형태여야 하는지 알면...)`이 `analyzer.md:29`로 이동,
  Read 항목(28) 바로 아래 들여쓰기 2칸. 블록인용(31-34)과 `### 대화형 스킬을 만났을 때`(36)
  사이에 뜬 문장 없음.
- 절 삭제 후 빈 줄 정리: 19→(빈)20→21 `## 쓰는 스킬`, 110→(빈)111→112 `## 하지 말아야 할 것`.
  둘 다 빈 줄 정확히 하나.
- 산출물에 `context` / `rules` / `<project_context>` 블록 복사 유입 없음 (grep 무매치).

### 작업 완료 검증

체크된 27개 전부 실제 확인. 미체크 항목 없음.
- 1.1-1.4 기준선: design.md에 기록된 값과 현재 값이 일치하므로 기준선 확보가 실제로 있었음이 확인됨.
- 2.1-2.7 / 3.1-3.5 / 4.1-4.2 / 5.1-5.7: 위 요구사항·설계 절에서 전부 파일로 확인.
- 6.1 `bash -n install.sh` → exit=0 (재실행 확인).
- 6.2 `bash install.sh --dry-run` → 이 저장소 안에서는 exit=1 (아래 참고 1).
- 6.3 `openspec validate --strict` → exit=0 (재실행 확인).
- 6.4 `openspec status --json` → exit=0 (재실행 확인).
- 6.5 `git diff --stat` → `.claude/agents/analyzer.md`, `.claude/skills/orchestra/SKILL.md` 둘뿐.
- 6.6 제거 문장 목록 → worker 보고서에 원문 그대로 존재. 아래 참고 2.

### 되돌릴 체크 항목

없음.

### 발견 사항

1. **[고쳐야 함]** `.claude/skills/orchestra/SKILL.md:191` ↔ `.claude/agents/analyzer.md`
   — "다듬은 변형안"을 만들 사람이 사라졌다.
   SKILL.md:191은 여전히 `analyzer가 "성립하지 않는다"고 하면 그 근거를 그대로 전하고,
   다듬은 변형안이나 기존 안으로 다시 고르게 한다.`고 지시한다. 그런데 이번 change로
   구 `## 사용자 안 평가` 4번 항목(`부분만 성립하면, 성립하는 형태로 다듬은 변형안을 하나
   제시한다.`)이 사라지면서 analyzer.md에는 `변형안`이라는 말이 한 번도 나오지 않는다
   (`grep -n '변형안' .claude/agents/analyzer.md` → exit=1).
   design.md D2가 든 대체 근거("「진짜로 다른 길을 3가지」가 이미 변형안을 허용한다")는
   본문과 어긋난다. 해당 문장 `analyzer.md:79`는
   `진짜로 다른 길이어야 한다. 같은 안을 말만 바꿔 3개로 늘리지 마라.`로,
   오히려 사용자 안의 **변형**을 별도 안으로 세우는 것을 억제하는 쪽이다.
   **영향:** 사용자 안이 "부분만 성립"할 때 orchestra가 제시하기로 한 두 갈래 중 하나가
   비고, 기존 안으로만 되돌아가게 된다. 조용히 깨지지는 않고(기존 안 폴백이 있음)
   spec 델타 R2가 요구한 세 항목에도 포함되지 않아 **막음은 아니다.**
   고친다면 analyzer.md:88-91 규칙에 "부분만 성립하면 성립하는 형태로 다듬은 안을 하나 더
   붙인다" 한 줄을 더하거나, SKILL.md:191에서 "다듬은 변형안이나"를 빼서 양쪽을 맞추면 된다.
   **어느 쪽이든 산출물(design/tasks) 수정이 따르므로 designer 판단 사안이다.**

2. **[참고]** `tasks.md` 6.2 문구 결함 (구현 결함 아님).
   `bash install.sh --dry-run`을 이 저장소 안에서 돌리면 자기 보호 장치가
   `오류: init-SDD 저장소 안에서 실행했다.`를 내고 exit=1이다(재현 확인).
   작업 문구가 요구한 exit=0은 저장소 밖에서만 나온다. worker가 저장소 밖 빈 git 저장소에서
   exit=0을 받았다고 보고했다. proposal의 받아들일 조건에는 `bash -n install.sh` exit=0만
   있고 dry-run은 없으므로 승인 기준에는 영향 없다. **반려 사유 아님.**

3. **[참고]** spec R5 부속 시나리오의 `제거된 문장은 무엇을 왜 뺐는지 확인할 수 있게
   보고되어 있다`는 worker 보고서(대화)에만 남아 있고 파일로는 없다.
   이번 리뷰에서 `git diff`로 직접 대조해 검증했으므로 충족으로 본다.
   다만 커밋 후에는 `git show`가 유일한 근거가 된다.

### 이번 change 것인지 확인 필요한 변경

없음. `git status --short` = `M .claude/agents/analyzer.md`, `M .claude/skills/orchestra/SKILL.md`,
`?? openspec/changes/remove-analyzer-eval-mode/`, `?? openspec/changes/fix-pipeline-handoff-gaps/`.
마지막 것은 다른 change 산출물로 범위 밖(사전 고지됨).

### finalizer 참고: 델타 병합 가능성

델타 capability `agent-instructions/analyzer-option-generation`은 신규다.
현재 메인 spec은 `agent-instructions/openspec-metadata-marker-safety` 하나뿐이라 충돌 없음.
델타가 `## ADDED Requirements`만 담고 있어 새 spec 디렉터리 생성으로 그대로 병합된다.

### 다음 단계

finalizer에게 넘길 것. 발견 사항 1은 막음이 아니므로 이번 change를 막지 않는다.
다만 후속 change(예: `fix-pipeline-handoff-gaps`)에서 양쪽 문구를 맞추는 것을 권한다.
