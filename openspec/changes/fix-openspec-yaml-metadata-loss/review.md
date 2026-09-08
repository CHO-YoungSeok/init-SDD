최종 판정: 통과 (라운드 1, 2026-09-09)

## 리뷰: fix-openspec-yaml-metadata-loss

판정: 통과
판정 기록: openspec/changes/fix-openspec-yaml-metadata-loss/review.md
기준으로 삼은 채택안: 1안 — 가드형 append 명령을 두 문서에 박고 확인 절에
`openspec status --json` 종료코드 게이트를 넣는다 (decision.md:3)

리뷰 방식: worker 보고서를 근거로 쓰지 않았다. 세 파일을 직접 읽었고, 문서에 박힌
bash 코드블록을 **awk로 파싱해 뽑아내** 임시 openspec 프로젝트
(`<scratchpad>/proj`, `openspec init --tools none`)에서 직접 실행했다.
이 저장소의 `openspec/`은 건드리지 않았다.

### OpenSpec 검증

```
$ openspec validate "fix-openspec-yaml-metadata-loss" --strict; echo "exit=$?"
Change 'fix-openspec-yaml-metadata-loss' is valid
exit=0
```

`openspec status --change ... --json` → `isPlanningComplete: true`, `isComplete: true`,
네 산출물 모두 `done`.

산출물 안에 `context` / `rules` / `<project_context>` 블록이 복사돼 들어간 흔적 없음
(change 디렉터리 전체 grep, 히트 0).

### 기준선 재측정 (내가 독립으로 다시 쟀다)

design.md:34-40의 확정판 표를, 임시 프로젝트에서 A~E를 새로 만들어 다시 돌렸다.
D행은 design.md:43-46의 재현 조건대로 **델타가 있는 change**에서 쟀다.

| # | 행동 | `validate` | `--strict` | `status --json` | design.md와 |
|---|---|---|---|---|---|
| A | `>` 덮어쓰기 | 1 | 1 | 1 | 일치 |
| B | 가드 없는 `>>` 두 번 | 1 | 1 | 1 | 일치 |
| C | 개행 없는 끝줄에 `>>` | 1 | 1 | 1 | 일치 |
| D | `retire_capabilities` 덮어쓰기 (델타 있음) | **0** | **0** | 1 | 일치 |
| E | preparer.md:156-157 코드블록 (문서에서 파싱해 실행) | 0 | 0 | 0 | 일치 |
| E2 | designer.md:166-167 코드블록 (문서에서 파싱해 실행) | 0 | 0 | 0 | 일치 |

design.md의 "읽는 법" 주장도 출력으로 확인했다.
- C의 `validate` 출력에는 YAML 얘기가 한 줄도 없고 `Change must have at least one delta`
  하나뿐이다. → design.md:50-53 주장 확인.
- C의 `status --json`은 exit=1 +
  `Invalid YAML in metadata file: Nested mappings are not allowed in compact mappings`.
  → design.md:54-58 주장 확인. **C행의 `status --json`은 1이 맞다.**
- D의 `validate --strict` 출력은 `Change 'mode-d' is valid` (exit=0)이고
  `status --json`만 exit=1 + `Invalid metadata: ... "path": ["schema"] ... expected string,
  received undefined`. → design.md:61-62, decision.md:56-59 주장 확인.

### 요구사항 충족 (델타 spec 6개 요구사항)

**R1. 마커 삽입 지침은 기존 키를 전부 보존해야 한다** → 충족
- preparer 시나리오: `.claude/agents/preparer.md:149`("이 파일은 네가 새로 만드는 파일이
  아니다. `openspec new change`가 이미 만들어 둔 파일"), `:151-152`(기존 키 전부 보존,
  `schema:` 하나가 아님), `:155-158`(복붙 코드블록), `:162`(`Write`·셸 `>` 금지).
  ①~④가 같은 6단계 절 안에 모두 있다.
- designer 시나리오: `.claude/agents/designer.md:160-163`, `:164-168`, `:171`. 동일.
- "지침대로 실행하면 기존 키가 살아남는다" 시나리오: `schema:`/`created:`/`goal:` 세 키가
  들어 있는 파일에 문서에서 뽑아낸 명령을 실행 → 세 키 모두 그대로 남고 마커 한 줄 추가.
  세 종료코드 모두 0 (위 표 E/E2행). **실측 확인.**

**R2. 마커 삽입 지침은 여러 번 실행해도 안전해야 한다** → 충족
- 3회 연속 실행 시나리오: 문서에서 뽑아낸 preparer 명령을 같은 change에 3번 실행 →
  매번 exit=0, `grep -c '^skip_specs:'` = **1**. **실측 확인.**
- 개행 없는 마지막 줄 시나리오: `goal: temp verify`로 개행 없이 끝나는 파일에 실행 →
  `tail -2`가 `goal: temp verify` / `skip_specs: true` 두 줄로 분리됨. 붙지 않았다.
  `status --change ... --json` exit=0이고 `specs` 산출물이 `skipped`.
  (`[('proposal','ready'),('specs','skipped'),('design','blocked'),('tasks','blocked')]`)
  **실측 확인.**

**R3. 마커 설정 결과는 CLI 종료코드로 확인해야 한다** → 충족
- designer 검증 절 시나리오: `designer.md:210`에 `openspec status --change "<이름>" --json
  >/dev/null; echo "metadata exit=$?"`가 있고, `:219`에 "`metadata exit`이 `0`이 아니면
  `.openspec.yaml`이 깨진 것이다"라는 설명이 붙어 있다.
- preparer 확인 절 시나리오: `preparer.md:168-169`에 `validate`와 `status --json` 두 줄이
  모두 있고, `:172-174`가 둘 다 찍어 보고 둘 다 보고하라고 적는다.
- "메타데이터가 깨진 채 검증을 돌린다" 시나리오: D행 실측으로 확인 (strict=0, status=1).
- "마커가 앞 줄에 이어 붙은 change" 시나리오: C행 실측으로 확인
  (status=1 + YAML 파싱 실패 메시지, validate 출력에는 델타 없음 에러 하나뿐).

**R4. 진단 절차는 특정 에러 문구에 기대지 않아야 한다** → 충족
- `preparer.md:184-189`, `designer.md:219-224`. 양쪽 다 `cat "<changeRoot>/.openspec.yaml"`로
  파일을 열어 ①기존 키 생존 ②마커 키 중복 없음 ③앞 줄에 이어 붙지 않음 세 가지를 보라고
  적고, "에러 문구 하나를 찾지 말고 파일을 봐라"를 명시한다. 두 문서의 세 항목은
  마커 이름만 다르고 문장이 동일하다 (대조 확인).

**R5. 델타 없음 에러를 조건 없이 정상이라고 가르치지 않아야 한다** → 충족
- `preparer.md:179` — "아직 델타가 없어서 실패할 수 있다(`exit=1`).
  **`skip_specs`를 설정하지 않았다면** 그건 정상이다."
- `preparer.md:182-183` — "**`skip_specs`를 넣었는데도 델타 없음 에러가 나오면 그건 정상이
  아니다.** 마커가 반영되지 않은 것이니 아래 진단으로 `.openspec.yaml`을 확인해라."
- 179~183을 이어 읽으면 같은 exit=1을 서로 반대로 해석하지 않는다. D5대로 문장을 지우지
  않고 조건을 붙였다.

**R6. 사용자 문서가 마커 파일의 성격을 정확히 설명해야 한다** → 충족
- `README.md:182` — "누가 씀" 칸이 "`openspec new change` 가 만들고, preparer / designer 가
  마커만 덧붙임"으로 바뀌었다. 표의 파이프 개수가 다른 줄(173~181)과 동일한 4개라
  마크다운 표 구조가 깨지지 않았다.

### proposal.md "받아들일 조건" 8개 대조

| # | 조건 | 판정 | 근거 |
|---|---|---|---|
| 1 | preparer.md 6단계 보존 문구 + 복붙 명령 + `Write`/`>` 금지 | 충족 | preparer.md:149-162 |
| 2 | designer.md 5단계에 동일 형태 | 충족 | designer.md:160-171 |
| 3 | 두 문서 확인 절에 일반화된 진단 절차 + 두 종료코드 | 충족 | preparer.md:168-189, designer.md:209-224 |
| 4 | designer.md 7단계에 `status --json` 종료코드 확인 | 충족 | designer.md:210, 217-219 |
| 5 | preparer.md 154행(현 179행) 조건 붙이기 | 충족 | preparer.md:179-183 |
| 6 | README.md 182행 "덧붙인다" | 충족 | README.md:182 |
| 7 | A~E 재현 시 E가 세 종료코드 0 + 3회 멱등 | 충족 | 위 기준선 표 + `grep -c`=1 실측 |
| 8 | `bash -n install.sh` 통과 | 충족 | `bash -n exit=0` |

체크박스는 `- [ ]`로 남아 있지만 **내용상 8개 전부 충족**이다. 아래 발견 사항 1번 참고.

### 설계 준수

- decision.md:3의 채택안(1안)대로 갔다. 2안(서술형 원칙)·3안(공통 문서)의 흔적 없음.
  새 파일을 만들지 않아 design.md:17-20의 `install.sh` 배포 제약을 지켰다.
- D1 관용구가 decision.md:38-41 / design.md:96-106과 **문자 단위로 동일**하다
  (문서에서 파싱해 뽑은 바이트를 확인).
- D2(두 가지 금지 다 적기), D3(두 게이트), D4(파일 확인 절차), D5(조건 붙이기),
  D6(README 한 줄) 모두 반영.
- design.md:88의 Non-Goal대로 `finalizer.md`, `orchestra/SKILL.md`는 손대지 않았다.
  다른 문서의 `.openspec.yaml` 언급을 전수 grep해 확인한 결과, 마커를 **쓰라고** 가르치는
  곳은 preparer.md/designer.md 둘뿐이고 나머지(finalizer.md:128, sync-specs SKILL.md:124,
  propose SKILL.md:109 등)는 전부 읽는 쪽 설명이라 이번 수정과 어긋나지 않는다.
- design.md:85의 Non-Goal대로 `.claude/settings.json`은 건드리지 않았다.
- `<changeRoot>` 치환에 필요한 값의 출처가 두 문서에 이미 있다 (preparer.md:122,
  designer.md:76 — status JSON에서 `changeRoot`를 읽으라고 되어 있다).
- store 규칙: 두 문서 모두 "이 문서의 예시는 `--store`가 빠진 축약형"이라는 총괄 규칙이
  있어(preparer.md:57, designer.md:67) 새로 넣은 `status --json` 줄도 자동으로 덮인다.

### 작업 완료 검증

체크된 18개 중 18개 실제 확인.

- 1.1~1.4 (기준선 재현): tasks.md:44-50의 그룹 1 결과 주석이 실측과 맞는지 내가 다시 재서
  확인했다. C행 정정도 실측과 일치한다.
- 2.1~2.4: preparer.md:149-189에서 항목별로 확인.
- 3.1~3.3: designer.md:160-171, 209-224에서 확인.
  3.1의 "preparer 2.1과 같은 사실을 말하는지"는 두 절을 마커 이름만 치환해 정규화한 뒤
  **단어 순서 비교**로 대조했다. 차이는 딱 한 곳, 마커별 결과를 설명하는 문장뿐이다
  (preparer: "`openspec validate`가 `Change must have at least one delta`로 막는다" /
  designer: "finalizer가 메인 spec 파일을 지우지 못하고 sync가 멈춘다").
  이건 두 마커의 실제 결과가 달라서 **갈라지는 게 맞는** 자리다. ①~④는 단어 단위로 동일.
- 4.1: README.md:182, 파이프 개수 4개로 표 구조 유지, `git diff README.md`가 그 한 줄뿐.
- 5.1~5.3: **내가 문서에서 코드블록을 파싱해 다시 실행했다.** worker 보고와 동일한 결과.
- 5.4: `bash -n install.sh; echo "exit=$?"` → exit=0.
- 5.6: `git status --short`가 `M .claude/agents/designer.md`, `M .claude/agents/preparer.md`,
  `M README.md`, `?? openspec/changes/fix-openspec-yaml-metadata-loss/` 넷뿐이다.
  임시 openspec 프로젝트는 스크래치패드에만 있고 저장소로 새지 않았다.

### 되돌릴 체크 항목

없음.

### 발견 사항

1. [참고] `openspec/changes/fix-openspec-yaml-metadata-loss/proposal.md:129-158` —
   "받아들일 조건" 8개가 `- [ ]` 미체크로 남아 있다. worker가 "proposal은 자기 산출물이
   아니라 손대지 않았다"고 판단한 것인데, 이 저장소 어디에도 worker가 proposal 체크박스를
   채우라는 규칙이 없으므로 **판단이 맞다.** 내용상 8개 전부 충족임을 위 표에서 확인했다.
   finalizer는 이 미체크 상태를 "조건 미충족"으로 읽지 마라. 판정 근거는 이 파일이다.

2. [참고] `.claude/agents/designer.md:202` — 7단계 머리의 예시 블록에 `--json` 없는
   `openspec status --change "<이름>"`이 남아 있다. 확인해 보니 이 형태도 메타데이터가
   깨지면 exit=1을 내므로(임시 프로젝트에서 mode-c·mode-d 둘 다 exit=1 실측) 구멍은 아니다.
   판정에 쓰는 권위 있는 블록은 바로 아래 `:209-210`이고 거기에 종료코드 게이트가 들어갔다.
   설계 범위 밖이라 그대로 둔 worker 판단에 동의한다.

3. [참고] `.claude/agents/preparer.md:167-170` — design.md:146-150의 D3 예시는 코드블록이
   세 줄(`validate` / `status --json` / `cat`)인데, 실제 문서는 코드블록에 두 줄만 넣고
   `cat`을 `:184`의 조건부 항목("두 종료코드 중 하나라도 기대와 다르면")으로 옮겼다.
   델타 spec R4가 요구하는 것은 "`cat`으로 열어 세 가지를 보라는 절차가 적혀 있을 것"이고
   그건 충족한다. 매번 `cat`하지 않아도 되니 오히려 낫다. 문제 아님.

4. [참고] 가드형 관용구의 경계 동작 하나 (설계가 이미 감수한 것, 새 결함 아님).
   `<changeRoot>`를 잘못 적어 **파일 이름만 틀리고 디렉터리는 맞는** 경우
   (`.openspec.yaml.WRONG` 같은), `grep -q`가 exit=2를 내고 `||`가 발동해
   **엉뚱한 파일이 마커만 담은 채 새로 생기고 명령은 exit=0**을 낸다. 실측 확인했다.
   - 진짜 `.openspec.yaml`은 손상되지 않는다 (내용 그대로).
   - `skip_specs` 쪽은 안전하다. 마커가 안 먹으므로 `validate`가 델타 없음 에러를 내고,
     이번에 고친 `preparer.md:182-183`이 바로 그 경우를 "정상이 아니다"라고 잡아낸다.
   - `retire_capabilities` 쪽은 아무 게이트에도 안 걸린다. 다만 이건
     design.md:69-70이 이미 적어 둔 CLI 특성(`retire_capabilities`는 어떤 JSON에도 값이
     노출되지 않는다)이고 이번 change가 만든 문제가 아니다.
   - 디렉터리 자체가 없으면 `>>`가 실패해 exit=1로 즉시 드러난다 (실측).
   지금 고칠 필요는 없다. 세 번째 마커가 생겨 3안(공통 문서)으로 옮길 때 함께 다루면 된다.

### 이번 change 것인지 확인 필요한 변경

없음. 바뀐 파일이 프롬프트의 "만진 파일" 목록과 정확히 일치한다.

### 다음 단계

finalizer에게 넘긴다.
- 커밋 대상: `.claude/agents/preparer.md`, `.claude/agents/designer.md`, `README.md`,
  그리고 `openspec/changes/fix-openspec-yaml-metadata-loss/` (아직 untracked).
- 델타 spec은 `--strict` 통과 상태이고 `## ADDED Requirements` 한 구획에
  요구사항 6개·시나리오 11개가 모두 `#### Scenario:`를 갖추고 있어 sync 가능한 형태다.
  메인 spec에 `agent-instructions/openspec-metadata-marker-safety`가 새로 생긴다.
- 회귀 여부는 regression-verifier 보고서를 따로 확인해라. 이 리뷰는 회귀를 보지 않았다.
