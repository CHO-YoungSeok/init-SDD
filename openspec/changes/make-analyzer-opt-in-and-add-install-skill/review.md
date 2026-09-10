최종 판정: 통과 (라운드 1, 2026-09-11)

RESULT: 통과 | change=make-analyzer-opt-in-and-add-install-skill | scope=만진파일 | blockers=0 | should_fix=1 | notes=5

## 리뷰: make-analyzer-opt-in-and-add-install-skill

판정: 통과
판정 기록: `openspec/changes/make-analyzer-opt-in-and-add-install-skill/review.md`
기준으로 삼은 채택안: `decision.md` 의 결정 2·3 + **결정 변경 2026-09-11 (결정 6·7·8)**.
사용자 원문 *"switch skill은 필요 없겠어. 제거해"* 로 세 번째 축이 빠진 뒤의 범위를 기준으로 봤다.
analyzer를 부르지 않은 경로라 `analysis.md` 는 없다 — 정상이다.

기준 문서 경로는 모두 `openspec status --change ... --json` 에서 얻었다.
델타 spec 3개(`specs.existingOutputPaths`): `agent-instructions/analyzer-option-generation`,
`distribution/agent-model-tier`, `distribution/sdd-install-script`.

### OpenSpec 검증

```
openspec validate "make-analyzer-opt-in-and-add-install-skill" --strict
Change 'make-analyzer-opt-in-and-add-install-skill' is valid
exit=0

openspec status --change "make-analyzer-opt-in-and-add-install-skill" --json
→ isPlanningComplete: true, isComplete: true, 산출물 4개 모두 done (exit=0)
```

델타가 메인 spec에 병합될 수 있는 형태인지도 미리 봤다.
`MODIFIED` 3개의 요구사항 제목이 메인 spec
`openspec/specs/agent-instructions/analyzer-option-generation/spec.md` 의 제목과 **글자까지 같다**
(67·105·124줄). `ADDED` 3개는 메인에 없는 새 제목이다.
`distribution/*` 는 `openspec/specs/` 에 아직 없는 새 capability라
`retire_capabilities` 를 넣지 않은 것(결정 7)이 맞다. `.openspec.yaml` 은 두 키(`schema:`,
`created:`)가 그대로다.

---

### 요구사항 충족

#### 요구사항 1 — analyzer 옵트인 (`agent-instructions/analyzer-option-generation`)

- "기본 경로에는 analyzer와 방안 선택 관문이 없어야 한다" → **충족**
  - `CLAUDE.md:12-13` (`순서: preparer → designer → worker → reviewer + regression-verifier(동시) → finalizer`),
    `CLAUDE.md:15` (부를 때만 관문이 열린다는 한 줄)
  - `.claude/skills/orchestra/SKILL.md:3` (frontmatter description), `:45-64` (파이프라인 그림 —
    `[preparer]` 다음이 `[designer]`, `★ 사용자가 안을 고른다` 줄이 기본 흐름에 없음),
    `:54` (옵트인 안내 한 줄)
  - `README.md:164` (경로 표), `README.md:7-8`
  - `.claude/agents/analyzer.md:1-7` 그대로 있고 `name:`/`description:`/`model:`/`tools:` 다 있다
  - 묻는 지점 표 `.claude/skills/orchestra/SKILL.md:425-433` — `필수` 는 1·6·7단계 세 줄,
    방안 선택은 `조건부(analyzer를 불렀을 때 필수)`
- "analyzer를 부르는 신호와 판단 기준" → **충족**
  `.claude/skills/orchestra/SKILL.md:172-200`. 신호 5묶음 인용 목록(`"분석해줘"`, `"방안 뽑아줘"`,
  `"선택지 보여줘"`, `"analyzer 불러"` 모두 있음), 이름을 정확히 대지 않아도 걸린다는 문장(`:175`),
  하나의 판단 기준(`:188-189`), 애매하면 **부르지 않는다**와 그 이유(`:192-194`),
  1단계에 얹는 한 줄(`:162-165`)
- **"기본 경로의 designer 호출은 채택안이 없음을 명시해야 한다" → 충족 (가장 조용한 지점, 직접 대조했다)**
  `.claude/skills/orchestra/SKILL.md:242-250` 의 ① 프롬프트에
  `analyzer 생략: 예` + `채택안: 없음 — proposal의 받아들일 조건이 기준` 이 있고,
  빠지면 멈추는 이유까지 적혀 있다. `.claude/agents/designer.md:25-28` 이 요구하는 문구와
  **글자까지 일치**한다(`analyzer 생략: 예`). ② 경로(`:252-258`)에는 `사용자가 고른 안:` 만 있고
  `analyzer 생략: 예` 가 없다 — 시나리오대로다.
- (MODIFIED) "검증 안 된 안으로 설계에 들어가지 않는 안전장치" → **충족**
  `.claude/skills/orchestra/SKILL.md:224-236`. 재호출 예시에 `평가할 안:` 없음,
  `사용자가 낸 안:` 으로 추가 후보로 실림, "검증 안 된 안을 설계하면 worker가 벽에 부딪힌다"
  근거 문장 유지, 조건 명시 두 줄(`:226-227`)
- (MODIFIED) "사용자 문서에 없어진 모드가 남아 있지 않아야 한다" → **대체로 충족.
  단 `docs/final-report.md` 가 남았다** → 아래 발견 사항 1
  - `docs/example-run.md:59-60` — analyzer를 부른 경우의 흐름임을 밝힘, `평가 모드` 0개,
    재호출 서술(`:105-106`) 유지
  - `README.md:10-20` ("이게 왜 필요한가" — 강제라고 적지 않고, 기본 경로의 개입 지점 넷을 나열),
    `README.md:144-157`, `README.md:176` (analyzer 행에 `(부를 때만 돈다)`)
- (MODIFIED) "지침 문서 수정은 파일을 손상시키지 않아야 한다" → **충족**
  실측(아래 마크다운 무결성). 오염 토큰 형태(`[[ORCA_RICH_MD`)는 이번에 만진 파일에 **0개**다.

#### 요구사항 2 — `install.sh` (`distribution/sdd-install-script`)

- "설치 스크립트는 저장소에 남아 있어야 한다" → **충족**
  `install.sh` 존재, 실행 비트 유지(`-rwxr-xr-x`), `bash -n install.sh; echo "exit=$?"` → `exit=0`(직접 돌렸다),
  `--dry-run` 있음(`install.sh:11-12,23,117`). `switch_skill` 은 저장소에 없다(아래 참조).
- **"CLAUDE.md 조각의 원본은 한 벌이어야 한다" → 충족 (이번 change의 가장 큰 소득. 직접 셌다)**
  ```
  grep -rln '순서: `preparer`' . --include='*.md' --include='*.sh' | grep -vE '^(\./)?openspec/'
  → CLAUDE.md   (한 개)
  ```
  `openspec/` 아래를 뺀 나머지에서 조각을 담은 파일은 `CLAUDE.md` 하나다.
  `install.sh` 와 `README.md` 에는 그 줄이 없다. 시작 3벌 → **1벌** 이 맞다.
  뽑는 명령은 `install.sh:91`, 원본은 `CLAUDE.md:5`~`:23` 마커 구획(마커 각 1개),
  `README.md:76-78` 은 코드블록 사본이 아니라 `sed` 한 줄 안내다.
  빈 값이면 멈추는 안전장치도 있다(`install.sh:90,93` — design 결정 1의 딸린 조건).
- "조각이 이미 들어갔는지 낱말 검색만으로 판별해서는 안 된다" → **충족**
  `install.sh:96-112` 가 마커를 지문으로 쓰고 세 갈래로 나눈다.
  세 번째 갈래(`:101-108`)는 넣지 않고 사실과 확인 방법을 알린다.
  실측 기록: `verification.md:797-859` 의 갈래 (a)~(d) 전부 합격, 두 번 돌려도 마커 1개.
- **"제품 5종을 깔아야 한다" → 충족**
  복사 대상 `install.sh:73-78` (에이전트 7개, `orchestra`, **`agent-model-tier`**, `settings.json`)
  + `CLAUDE.md` 조각(`:96-112`).
  설치 확인 `install.sh:119-148` — 에이전트 개수(7), 우리 스킬 2개 존재, openspec 스킬 6개와 복구 명령.
  실측: `verification.md:740-795` (대상에 실제로 복사되고 원본과 `diff` 차이 0).
- "이미 있는 파일을 덮어써서는 안 된다" → **충족**
  `install.sh:63-65` (건너뜀 + 목록 담기), `:155-159` (건너뛴 목록 + **저장소 쪽 원본 경로**),
  `settings.json` 합치는 절차 없음. 실측: `verification.md:812-819` (재실행에서 10개 건너뜀 목록 확인).
- "전제 조건을 먼저 확인해야 한다" → **충족**
  `install.sh:18` (저장소 자신 안에서 실행하면 멈춤 — 아무것도 쓰기 전이다),
  `:28-33` (git / 저장소 / 커밋 유무), `:38-45` (openspec CLI와 권장 버전).
- "openspec CLI가 깔아주는 것은 건드려서는 안 된다" → **충족**
  복사 대상에 `openspec-*`·`commands/opsx/` 없음, `openspec init --tools claude` 는 `:50-55`,
  `settings.local.json` 은 안내만(`:167`).
- "설치 안내는 README 한 곳에만 있어야 한다" → **조건 하나만 어긋남.**
  `README.md:30-114` 만 읽고 설치·확인·새 세션까지 갈 수 있고 `--dry-run` 권고와
  `.claude/*` 통째 복사 금지 경고(`:66-68`)도 남아 있다. 제품 5종이 두 곳
  (`:60-63` 손으로 복사, `:100-103` 설치 확인)에 모두 있다.
  **다만 `docs/final-report.md:47-97` 에 같은 설치 절차가 한 벌 더 있다** → 발견 사항 1.

#### 요구사항 3 — `agent-model-tier` (`distribution/agent-model-tier`)

- "활성 스킬로 놓여야 한다" → **충족** `.claude/skills/agent-model-tier/SKILL.md:1-4`.
  `name:`/`description:` 있고 `allowed-tools` 는 파일 전체에 **0개**.
  `description` 에 모델 낮추기·토큰 아끼기·등급 이름 셋·되돌리기가 모두 들어 있다(`:3`).
- "등급 세 개의 값 표" → **충족** `:32-40` 표 + `:42-52` 한 단계 내리기 규칙과
  "특별 취급하지 않는다" 문장. 짧은 이름만 쓰고 전체 모델 ID 없음(`:54-55`).
  **`normal` 열이 실제 값과 한 칸도 다르지 않은지 직접 대조했다:**
  preparer sonnet / analyzer opus / designer opus / worker sonnet / reviewer opus /
  regression-verifier sonnet / finalizer sonnet — 7개 파일의 `^model:` 값과 같다.
  `semi-lower` 는 한 단계 내린 값, `lower` 는 7개 전부 haiku로 맞다.
- "지금 등급 판별 / 섞인 상태" → **충족** `:57-76`. 짐작 금지, 7개 실제 값 보여주기,
  복구 불가 경고, 사용자에게 다시 묻기까지 있다.
- "양방향·몇 번을 해도 같은 결과" → **충족** `:82-83` (이미 그 등급이면 안 건드림),
  `:89` (값이 같은 파일은 건드리지 않음), `:135-136` (되돌리기).
  실측: `verification.md:320-344` 갈래 ⑦ — `normal→semi-lower→lower→normal` 한 바퀴 뒤
  처음과 동일, `git diff` 가 `model:` 줄뿐. **이 갈래는 지금도 유효한 검증이 맞다.**
- "`model:` 한 줄만 고쳐야 한다" → **충족** `:85-96` (전체 재작성·`sed -i` 금지와 이유,
  대상 프로젝트에는 이 저장소 규칙이 없다는 근거), `:98-114` (바꾼 뒤 확인 3항목).
- "낮추면 무엇이 나빠지는지 경고" → **충족** `:116-136`. 조용한 실패라는 것,
  worker의 "멈출 줄 아는 판단", reviewer·designer의 질, 큰 일 금지, 되돌리는 방법,
  적용 **전에** 보여주라는 지시(`:118`)까지 있다.

#### 정량 요구사항

없다. 판정할 기준선 문제도 없다.

---

### 설계 준수

- design 결정 1(조각 원본 한 곳 + 빈 값이면 멈춤) → 지켜졌다. `install.sh:86,90,91,93`
- design 결정 2(원본은 `$SRC` 옆 트리) → `install.sh:9` 그대로
- design 결정 4(판별 세 갈래) → `install.sh:96-112`
- design 결정 5(복사 대상 / 건드리지 않을 것) → `install.sh:73-78`, `:167`
- design 결정 7(이미 있으면 건너뛴다) → `install.sh:63-65`, `:155-159`
- design 결정 8(settings.json 안 합침) → 합치는 코드가 없다
- design 결정 10(README가 유일한 안내) → `README.md` 는 맞다. `docs/final-report.md` 만 남았다
- design 결정 11(신호 + 기준 + 기울 방향) → orchestra `:172-200`
- design 결정 12(designer 프롬프트 두 벌, `designer.md` 는 고치지 않는다) → 지켜졌다.
  `git diff --stat -- .claude/agents/` 가 **빈 출력**이다(에이전트 파일 한 줄도 안 바뀌었다)
- design 결정 13(값 표 + 한 줄만 고치기) → `agent-model-tier/SKILL.md` 전부 반영
- 폐기 표시된 결정 3·6·9·14와 무효 표시된 작업(묶음 5·6·11 전체, 2·7·9·10 일부)은
  **이력이다. 결함으로 세지 않았다.** 지시받은 대로다.

**설계와 다르게 간 것:** 없다. 채택안(결정 6·7·8)과 다른 길로 간 곳도 없다.

---

### 작업 완료 검증

체크된 104개 중 **미체크 0개**. 최종 범위에 해당하는 것을 직접 확인했다.

| 묶음 | 확인 방법 | 결과 |
|---|---|---|
| 2 (`CLAUDE.md`) | 파일 23줄 눈검사, 마커 각 1개, `순서:` 줄에 analyzer 없음 | 실제로 됐다 |
| 3 (orchestra 11항목) | `git diff` 전체 + 헤더 구조 + 표 대조 | 실제로 됐다 |
| 4 (`agent-model-tier` 6항목) | 파일 136줄 전문 읽음 | 실제로 됐다 |
| 8 (`example-run.md`) | `평가 모드` 0개, `:59-60` 옵트인 표시 | 실제로 됐다 |
| 12-가~마 (22항목) | `install.sh` 전문 + `README.md` 전문 + `verification.md` 대조 | 실제로 됐다 |
| 12.20 | `git diff --stat -- .claude/agents/` 빈 출력 | 실제로 됐다 |
| 12.21 | `openspec/config.yaml:14,18` 과 메인 spec `project-context-completeness/spec.md:14` 가 `install.sh` 를 가리키고 둘 다 **안 바뀌었다** | 실제로 됐다 |
| 12.22 | `validate --strict` exit=0, `status --json` exit=0 | 실제로 됐다 |

마크다운 무결성 (직접 잼):

| 파일 | 줄 | 펜스 | `[[ORCA_RICH_MD` |
|---|---|---|---|
| `.claude/skills/orchestra/SKILL.md` | 456 | 30 | 0 |
| `.claude/skills/agent-model-tier/SKILL.md` | 136 | 4 | 0 |
| `README.md` | 253 | 14 | 0 |
| `CLAUDE.md` | 23 | 0 | 0 |
| `docs/example-run.md` | 236 | 24 | 0 |
| `verification.md` | 950 | 74 | 0 |

worker가 보고한 마지막 실측과 모두 같다. 펜스는 전부 짝수다.

`switch_skill` 흔적: `openspec/` 아래(계획 문서의 이력 서술)를 빼면 **아무것도 없다.**
`git status --short` 에 `?? switch_skill/` 도 없다. 정상이다.

### 되돌릴 체크 항목

없음.

---

### 발견 사항

1. **[고쳐야 함] `docs/final-report.md` 가 없어진 동작을 아직 설명한다.**
   - `:12` "핵심은 하나다. **분석이 끝나면 방안 3가지를 들고 와서 사람에게 고르게 한다.**"
   - `:16` "이 구조는 그 지점을 **강제로** 만든다"
   - `:31-33` 파이프라인 그림이 `preparer → analyzer → ★사용자가 방안 선택 → designer ...`
   - `:114` "새 기능·리팩터링 | 정식 파이프라인 (서브에이전트 7번) | 묻는 횟수 4"
   - `:116-120` "**반드시 답해야 하는 네 곳**" 2번이 방안 선택
   - `:47-97` 설치 절차가 한 벌 더 있다 (`--dry-run` 포함. 지금 `install.sh` 와 어긋나지는 않는다)
   - `:97` "스킬 6개" — 이제 우리 스킬 2개 + openspec 6개다

   왜 올리나: 델타 spec의 "사용자 문서에 없어진 모드가 남아 있지 않아야 한다(MUST NOT)" 와
   "설치 안내는 README 한 곳에만 있어야 한다(MUST NOT)" 두 요구사항의 문장 범위에 들어간다.
   `tasks.md` 8.1 은 이 파일을 "날짜가 박힌 과거 기록"으로 보고 손대지 않기로 했는데,
   **파일 안에 날짜가 한 곳도 없고** 머리말이 "3분 안에 읽는 요약 … 내 프로젝트에 어떻게
   쓰는지"라 지금 상태를 설명하는 문서로 읽힌다.

   **왜 막음이 아닌가:** `.git/info/exclude` 로 추적 제외라(`git check-ignore` 로 확인)
   커밋에 실리지 않고 저장소를 받는 사람에게 가지 않는다. 제품 동작도 바뀌지 않는다.
   지금 이 저장소를 쓰는 사람만 헷갈린다. 고치는 방법은 두 가지 중 하나다 —
   (가) `README.md` 처럼 문구를 맞추거나, (나) 머리말에 "2026-09-08 시점의 기록"이라고
   날짜를 박아 정말 과거 기록으로 만든다. **어느 쪽으로 갈지는 사용자가 정할 일이다.**

2. **[참고] `.claude/skills/agent-model-tier/` 는 아직 git에 안 올라간 새 디렉터리다
   (`?? .claude/skills/agent-model-tier/`). 커밋에서 빠지면 `install.sh` 가 죽는다.**
   `install.sh:68` 의 `cp -R` 는 원본이 없으면 실패하고, `set -euo pipefail`(`:7`) 때문에
   스크립트가 3단계 중간에 멈춘다. 원본 존재 확인은 없다(design 결정 2에서 그 검사가
   전환기와 함께 폐기됐으니 코드 문제는 아니다).
   → finalizer가 커밋할 때 이 디렉터리를 반드시 넣어야 한다. 알림 목적으로만 적는다.

3. **[참고] worker 질문 3에 대한 답 — "조각을 못 뽑아 멈추는 자리"는 note다. 옮기지 않아도 된다.**
   그 지점(`install.sh:90,93`)이 3단계(복사) 뒤에 있어 멈출 때 대상에 제품 4종이 들어간
   상태인 것은 사실이다. 그래도 (가) 종료코드 1과 파일 경로가 박힌 오류 문구가 나오고,
   (나) 다시 돌리면 있는 것은 건너뛰고 `CLAUDE.md` 만 채우며(`verification.md:882-897` 로 확인),
   (다) 조용히 잃는 것이 없어 이 저장소의 안전 모델("최악이 덜 깔린 채로 무엇이 덜 됐는지
   알려 주는 것", design 결정 7) 안에 있다. 게다가 이 실패는 **저장소 자신의 `CLAUDE.md`
   마커가 깨졌을 때만** 나는 것이라 사용자가 밟는 길이 아니다.
   design 결정 1·7과 작업 12.3이 4단계에 두라고 적었으니 지시를 따른 것이 맞다.
   더 좋은 형태(1단계로 올려 아무것도 쓰기 전에 멈추기)라는 worker의 관찰은 맞고,
   `verification.md:899-912` 에 근거째로 남아 있다. **다음 change 거리로 남기면 된다.**

4. **[참고] worker 질문 1에 대한 답 — 두 곳의 한 줄 넘김은 되돌리지 마라. 둘 다 spec이 요구한다.**
   - `.claude/skills/orchestra/SKILL.md:262-263` (`3단계에서 이미 방향을 골랐다` →
     `1단계에서 요구사항과 범위를 이미 확인했다 (analyzer를 불렀으면 3단계에서 방향까지 골랐다)`)
     — 기본 경로에 3단계가 없으므로 원래 문장은 **거짓**이 된다. "존재하지 않는 동작을
     설명해서는 안 된다(MUST NOT)" 에 걸린다. 고친 것이 맞다.
   - `.claude/skills/orchestra/SKILL.md:226-227` (재호출 안전장치가 analyzer를 부른 경우에만
     걸린다는 두 줄) — 델타 spec의 MODIFIED 요구사항이 **"이 조건을 문서에 분명히 적어야
     한다(MUST)"** 라고 못 박았다. 안 적으면 그게 미충족이었다.

   둘 다 최소 수정이고 다른 절차를 흔들지 않았다. **유효로 판정한다.**

5. **[참고] worker 질문 2에 대한 답 — `OLD_WORD` 로 한 곳에 모은 처리는 적절하다.**
   `install.sh:88` 에 낱말을 한 번만 두고 `:101` 의 `grep` 과 `:104` 의 안내가 같은 변수를
   쓴다. 내가 직접 센 `grep -c '오케스트레이터' install.sh` 는 **1** 이라 12.3의 기준(≤1)을
   만족하고, 셋째 갈래 문구는 실행할 때 낱말이 채워져 나오므로 12.4의 "그 낱말이 있다고
   알린다"도 만족한다(`verification.md:840-859` 의 실제 출력으로 확인). 낱말을 갈면 판별과
   안내가 함께 갈리므로 갈라질 틈도 없다. **두 기준의 충돌을 제대로 푼 형태다.**

6. **[참고] worker 질문 4에 대한 답 — 검사 문구 두 개는 **틀린 것이 맞다.** 다만 지금 고치지
   않아도 된다.**
   - `tasks.md` 1.1·9.1 의 `grep -v '^./openspec/'` 는 실제로 샌다. 내가 같은 명령을 돌려
     `openspec/...` 경로가 그대로 통과하는 것을 봤다. 맞는 형태는
     `grep -vE '^(\./)?openspec/'` 이고, **12.15·12.19가 이미 그 형태를 쓰면서
     "`grep -v '^./openspec/'` 는 샌다"고 적어 두었다.** 그래서 기록이 스스로 바로잡혀 있고,
     최종 판정에 쓰인 명령은 새지 않는 쪽이다. 결과도 내가 다시 세서 같았다(1벌).
   - `ORCA_RICH_MD` 를 세는 검사는 **백틱 안에 규칙을 인용한 문장까지 잡는다.** 실제 오염
     토큰은 `[[ORCA_RICH_MD` 형태라 그것으로 세는 게 맞다. 나도 그렇게 셌고 만진 파일은 전부 0이다.
     이 문구는 델타 spec에도 그대로 들어 있어서(`specs/agent-instructions/analyzer-option-generation/spec.md:212`),
     **그 문장 그대로면 그 spec 파일 자신이 자기 검사를 통과하지 못한다.**
     단 이 문장은 이번에 만든 것이 아니라 **이미 메인 spec에 있던 것**이다
     (`openspec/specs/agent-instructions/analyzer-option-generation/spec.md:139`, 지난 change에서 왔다).
     이번 change가 만든 흠이 아니므로 반려 사유로 세지 않는다. 손보려면 메인 spec 문장까지
     함께 봐야 하니 **별도 change 거리**다.

7. **[참고] 작은 어긋남 두 개 (제품 동작에 영향 없음)**
   - `README.md:244` "(위 설치 절차 3번)" — 다시 쓴 설치 절에는 번호가 붙은 3번 단계가 없다.
     `HEAD` 의 `README.md:224` 에도 있던 옛 참조가 그대로 따라온 것이다.
   - 델타 spec의 시나리오 "README의 '이게 왜 필요한가'" 는 기본 경로의 개입 지점으로
     `범위 밖 확인, 결정 기록, 리뷰, 커밋 관문` 을 들었는데, `README.md:15-17` 은
     `결정 기록` 대신 `설계 요약 알림` 을 넣었다. **README 쪽이 사실에 맞다** — 기본 경로에서는
     decision.md를 안 만든다(orchestra `:250`). 시나리오 문구가 조금 느슨한 것이고
     문서가 틀린 것이 아니다. 메인 spec으로 병합될 때 알고 넘어가면 된다.

### 이번 change 것인지 확인 필요한 변경

`git status --short` / `git diff --stat` 로 본 결과, 프롬프트의 만진 파일 목록과 다른 것은
`?? .agents/` 하나뿐이다. **범위 밖이라고 미리 알려 준 것이라 판정에 넣지 않았다.**
그 밖에 섞인 변경은 없다. 스테이징된 것도 없다(`git diff --cached --stat` 빈 출력).
`docs/example-run.md` 가 `git diff` 에 안 나오는 것은 `.git/info/exclude:9` 때문이고
정상이다(`git check-ignore` 로 확인했다).

### 다음 단계

**finalizer에게 넘긴다.** 막음이 없다.

넘길 때 챙길 것:

1. **`.claude/skills/agent-model-tier/` 를 반드시 커밋에 넣어라** (발견 사항 2).
   빠지면 저장소를 받는 사람의 `install.sh` 가 3단계에서 죽는다.
2. `?? .agents/` 는 커밋에서 빼라 (이번 change 것이 아니다).
3. `docs/` 아래 세 파일은 `.git/info/exclude` 로 추적 제외라 커밋에 안 잡힌다. 정상이다.
4. 델타 3개 모두 메인 spec에 병합 가능한 형태다. `MODIFIED` 3개는 제목이 메인과 같고,
   `distribution/*` 2개는 새 capability로 들어간다. `retire_capabilities` 는 넣지 않는다(결정 7).
5. **발견 사항 1(`docs/final-report.md`)은 사용자에게 물어야 하는 갈림길이다.** 지금 문구를
   맞출지, 아니면 날짜를 박아 과거 기록으로 둘지. 추적 제외 파일이라 커밋을 막지는 않는다.
