<!--
채택안: 없음 (analyzer를 부르지 않은 경로다. 기준은 proposal.md의 "받아들일 조건")

★★ 2026-09-11 이 계획이 한 번 크게 바뀌었다. 아래를 먼저 읽어라 ★★

사용자가 "switch skill은 필요 없겠어. 제거해" 라고 결정해 **설정 전환 스킬이 제품에서 빠지고
install.sh 가 되살아난다** (decision.md 결정 6).

- 묶음 1·3·4·8 은 그대로 유효하다 (기준선 / orchestra / agent-model-tier / docs 정합성).
- 묶음 2 는 2.3 만 무효다.
- 묶음 5·6·11 은 **전부 무효**다. 묶음 7 과 9 는 일부 무효다. 묶음 10 은 갈래 7 만 유효하다.
- **번호를 다시 매기지 않는다.** 무효가 된 작업에 그 자리에서 [무효] 표시를 달아 두고,
  대신 할 일은 **묶음 12** 에 새로 이어 붙였다. 이력이 남아야 왜 이게 안 됐는지 알 수 있다.
- 무효 표시가 붙은 작업은 **다시 하지 마라.** 묶음 12 가 그 자리를 대신한다.

핵심 결정 (자세한 근거는 design.md, 사용자 결정은 decision.md):
1. 기본 경로는 `preparer → designer → worker → reviewer + regression-verifier → finalizer`.
   analyzer는 자연어 신호로 부르는 옵트인 단계가 된다. 관문을 없애는 게 아니라 조건을 바꾼다.
   **이 결정은 그대로다.**
2. `install.sh` 는 **저장소에 남는다.** 두 곳만 고친다 — (가) `$SNIPPET` 하드코딩을 없애고
   `CLAUDE.md` 의 마커 구획에서 sed 로 뽑아 쓴다 (나) 복사 대상에 agent-model-tier 를 더해
   제품 5종을 깐다. 안전 모델("이미 있으면 건너뛴다")은 그대로 둔다.
   `switch_skill/SKILL.md` 는 **지운다.**
3. `CLAUDE.md` 조각의 원본은 저장소 `CLAUDE.md` 의 마커 구획 한 곳. 사본 3벌 → 1벌.
   **이번 change 의 가장 큰 소득이고, 전환 스킬이 빠진 뒤에도 살아남았다.**
   딸린 결과로 install.sh 의 "이미 들어갔나" 판별을 낱말에서 마커로 바꾼다 (design 결정 4).
4. `.claude/skills/agent-model-tier/SKILL.md`를 새로 만든다. 에이전트 7개의 `model:` 을
   등급 세 개(normal / semi-lower / lower)로 한 번에 간다. semi-lower는 "한 단계 내리기"
   (opus → sonnet, sonnet → haiku). **제품이 4종 → 5종이 되어 install.sh 의 복사 대상과
   README 제품 설명·설치 확인도 함께 바뀐다.** 이 결정은 그대로다.

이 저장소 규칙 (openspec/config.yaml의 context):
- `.claude/agents/*.md` 와 `.claude/skills/**/SKILL.md` 는 **Edit 부분 수정만.**
  전체 Write 재작성과 `sed -i` 금지. **새로 만드는 파일**
  (`switch_skill/SKILL.md`, `.claude/skills/agent-model-tier/SKILL.md`)은 Write로 만든다 —
  부분 수정할 대상이 아직 없다. 이번 change는 기존 에이전트 파일의 `model:` 줄을
  건드리지 않는다(등급 스킬 문서를 만드는 것까지가 범위다).
- 테스트 스위트가 없다. 검증은 openspec CLI 실측, grep 대조, 마크다운 눈검사로 한다.
- **10번 묶음은 임시 프로젝트 실측이었다** (사용자 결정 4). 그중 갈래 7 만 유효하다.
  **묶음 12 에 install.sh 재검증이 새로 들어 있다.** 임시 디렉터리에서만 하고 끝나면 치운다.
  결과는 changeRoot의 `verification.md`에 남긴다.
- **switch_skill/SKILL.md 와 install.sh 는 openspec/config.yaml 의 "Edit 부분 수정만" 규칙의
  대상이 아니다** (에이전트 지시문도 SKILL.md 도 아닌 셸 스크립트다). 다만 install.sh 는
  되살린 뒤 **필요한 곳만 Edit 으로 고친다** — 통째로 다시 쓰지 마라.
-->

## 1. 기준선 재기 (고치기 전에 지금 값을 남긴다)

- [x] 1.1 지금 `CLAUDE.md` 조각이 몇 개 파일에 있는지 센다. 아래를 실행해 **파일 목록과 개수를
      보고서에 적는다.** 지금은 3개(`CLAUDE.md`, `install.sh`, `README.md`)여야 한다.
      이 숫자가 마지막에 1개가 되는 것이 이번 작업의 검증 기준이다.
      `grep -rln '순서: `preparer`' . --include='*.md' --include='*.sh' | grep -v '^./openspec/'`
- [x] 1.2 지금 파이프라인 순서 문구가 있는 위치를 모두 찾아 보고서에 적는다.
      `grep -rn 'preparer.*analyzer\|analyzer.*designer' CLAUDE.md README.md .claude/skills/orchestra/SKILL.md install.sh`
- [x] 1.3 `.claude/agents/*.md` 7개, `.claude/skills/orchestra/SKILL.md`,
      `.claude/settings.json`의 줄 수를 재서 보고서에 적는다 (design.md가 2,025줄이라고
      적어 두었다. 다르면 그 사실을 보고한다).
      `cat .claude/agents/*.md | wc -l; wc -l .claude/skills/orchestra/SKILL.md .claude/settings.json`
- [x] 1.4 지금 에이전트 7개의 `model:` 값을 읽어 보고서에 적는다. `normal` 표의 기준선이며,
      design.md 결정 13의 표와 같아야 한다(preparer sonnet / analyzer opus / designer opus /
      worker sonnet / reviewer opus / regression-verifier sonnet / finalizer sonnet).
      다르면 **표를 고치지 말고 그 사실을 보고한다.**
      `for f in .claude/agents/*.md; do echo "$(basename $f) $(grep -m1 '^model:' $f)"; done`

## 2. `CLAUDE.md` — 마커 구획 + 새 순서 문구

- [x] 2.1 `CLAUDE.md`의 조각 본문(5~19줄, `# 작업 방식`부터 끝까지) 앞에
      `<!-- init-SDD:begin -->` 한 줄, 뒤에 `<!-- init-SDD:end -->` 한 줄을 Edit으로 넣는다.
      맨 위 "템플릿 안내" 주석은 구획 **밖에** 둔다(대상 프로젝트로 넘어가면 안 되는 문구다).
      검증: `sed -n '/init-SDD:begin/,/init-SDD:end/p' CLAUDE.md`가 `# 작업 방식`으로 시작하고
      "각 서브에이전트는 자기 파일..."로 끝나며, "템플릿 안내"가 그 안에 없다.
- [x] 2.2 `CLAUDE.md`의 `순서:` 줄(12-13줄)을 새 기본 순서로 Edit한다:
      `순서: preparer → designer → worker → reviewer + regression-verifier(동시) → finalizer`.
      바로 아래에 "analyzer는 분석·방안 비교를 요청할 때만 부른다. 그때 방안 선택 관문이
      열린다"는 한 줄을 더한다.
      검증: `grep -n 'analyzer' CLAUDE.md`가 `순서:` 줄에는 안 걸리고 그 아래 설명 줄에만 걸린다.
- [x] 2.3 **[무효 — 묶음 12.7 이 대신한다]** `install.sh` 가 되살아나므로 이 주석은 원래
      문구로 되돌아가야 한다. 아래는 당시 작업 기록이다.
      `CLAUDE.md` 맨 위 "템플릿 안내" 주석에서 `install.sh 를 쓰면 알아서 덧붙인다.`를
      `switch_skill 스킬을 쓰면 알아서 덧붙인다.`로 Edit한다.
      검증: `grep -c 'install.sh' CLAUDE.md`가 0이다.

## 3. `.claude/skills/orchestra/SKILL.md` — 지휘 절차 (Edit 부분 수정만)

- [x] 3.1 frontmatter `description`(3줄)의 파이프라인 나열을
      `preparer → designer → worker → reviewer + regression-verifier → finalizer`로 Edit하고,
      "analyzer는 분석·방안 비교를 요청했을 때만 넣는다"를 한 구절로 덧붙인다.
      검증: `sed -n '1,4p' SKILL.md`에 `---`가 두 줄 그대로 있고 `analyzer → (사용자 선택)`가 없다.
- [x] 3.2 파이프라인 그림(47-68줄)에서 `[analyzer]` 단계와 `★ 사용자가 안을 고른다` 줄,
      그리고 그 아래 재호출 줄을 기본 흐름에서 빼고, `[preparer]` 다음이 `[designer]`가 되게
      Edit한다. `[preparer]`와 `[designer]` 사이에
      `↓  (analyzer를 요청했으면 여기서 [analyzer] → ★안 선택. 아래 "analyzer를 언제 부르는가" 참고)`
      한 줄을 남긴다.
      검증: 그림 안에서 `[preparer]` 다음 대괄호 단계가 `[designer]`다. 코드펜스 개수가 짝수다.
- [x] 3.3 스킬 대응표(79-87줄)의 `analyzer` 행 "하는 일" 칸에 `(요청했을 때만 부른다)`를
      Edit으로 덧붙인다. 다른 행은 건드리지 않는다.
      검증: `grep -n 'analyzer.*openspec-explore' SKILL.md` 결과에 `요청했을 때만`이 있다.
- [x] 3.4 "preparer와 designer가 `openspec-propose`를 부르지 않고 읽는 이유"(89-91줄)를
      Edit한다. 지금 근거가 "analyzer의 분석과 사용자의 방안 선택 관문을 건너뛴다"인데,
      기본 경로에 그 관문이 없으므로 **항상 참인 근거로 바꾼다**: propose는 네 산출물을 한 번에
      만들어 결정 기록(decision.md)과 리뷰 관문을 건너뛴다. analyzer를 부른 경우에는 방안 선택
      관문까지 건너뛴다는 것을 조건절로 덧붙인다.
      검증: 그 문단에 "방안 선택"이 조건 없이 단독 근거로 남아 있지 않다.
- [x] 3.5 "네가 직접 하면 안 되는 것" 절(101-106줄)의 근거 문장도 3.4와 같은 방식으로 Edit한다
      ("방안 선택 관문과 리뷰 단계가 사라진다" → 리뷰·결정 기록을 항상 참인 근거로, 방안 선택은
      조건절로).
      검증: 그 절에 리뷰 단계와 결정 기록이 근거로 적혀 있다.
- [x] 3.6 **새 절을 만든다: `## analyzer를 언제 부르는가 (옵트인)`.** 위치는 "1. preparer 호출"
      다음, 지금의 "2. analyzer 호출" 앞이다. design.md 결정 11의 내용을 그대로 담는다:
      신호 목록 5묶음(분석을 달라 / 고를 거리를 달라 / 비교를 달라 / 이름으로 부르기 /
      방향이 없다고 말하기)과 각 묶음의 인용된 예시 문구, **하나의 판단 기준**
      ("사용자가 아직 방향을 정하지 않고 고를 거리를 달라고 하는가"), 판단 예시 두 개,
      그리고 **애매하면 부르지 않는다**는 기본값과 그 이유 한 문장.
      검증: 그 절만 읽고 `"분석해줘"`, `"방안 뽑아줘"`, `"선택지 보여줘"`, `"analyzer 불러"`가
      모두 신호로 걸리는지 알 수 있다.
- [x] 3.7 지금의 "2. analyzer 호출" 제목을 `## 2. (요청했을 때만) analyzer 호출`로,
      "3. ★ 사용자에게 안을 고르게 한다" 제목을
      `## 3. (analyzer를 불렀을 때) ★ 사용자에게 안을 고르게 한다`로 Edit한다.
      두 절의 본문 절차와 프롬프트 예시는 그대로 둔다.
      검증: 두 제목에 조건이 붙어 있고, `사용자가 낸 안:` 재호출 예시가 그대로 남아 있다.
- [x] 3.8 "1. preparer 호출" 절(범위 밖 확인 대목)에 한 줄을 Edit으로 더한다:
      범위 밖을 확인하는 같은 질문에 **"방안을 비교해 보고 고르시겠어요? 아니면 바로 설계로
      갈까요?"** 선택지를 얹으라는 지시와, 그것이 애매할 때 analyzer를 안 부르는 기본값을
      메우는 장치라는 이유 한 줄.
      검증: `grep -n '방안을 비교해' SKILL.md`가 1단계 절 안에서 걸린다.
- [x] 3.9 "4. designer 호출" 절의 프롬프트 예시를 **두 벌로** Edit한다.
      ① 기본(analyzer 안 부름): `analyzer 생략: 예`와
      `채택안: 없음 — proposal의 받아들일 조건이 기준` 두 줄을 넣은 예시.
      ② analyzer를 부른 경우: 지금 예시 그대로(`사용자가 고른 안:` 포함).
      ①에 **"이 두 줄이 빠지면 designer가 `RESULT: 설계중단 | reason=채택안 없음`으로 멈춘다"**는
      이유를 붙인다.
      검증: `grep -n 'analyzer 생략: 예' SKILL.md`가 4단계 절에서 걸리고, 그 근처에 `설계중단`이 있다.
- [x] 3.10 "사용자에게 묻는 지점" 표에서 `**필수** | **3단계 — 방안 선택 (절대 건너뛰지 마라)**`
      행을 `조건부(analyzer를 불렀을 때 필수)`로 Edit한다. 1·6·7단계 행은 `필수`로 그대로 둔다.
      표 아래 "4단계는 묻는 곳이 아니라 알리는 곳이다" 문장은 유지한다.
      검증: 표에서 `필수` 행이 3개(1·6·7단계)이고 방안 선택 행이 조건부다.
- [x] 3.11 "단계를 줄여도 되는 경우" 절의 `버그 수정(원인이 뻔함)` 항목을 Edit한다. 그 경로가
      이제 **기본 경로와 같으므로**, "analyzer 생략"이 예외가 아니라 기본이라는 것을 반영한다.
      `analyzer 생략: 예` / `채택안: 없음`을 designer에게 싣는 지시와 designer 생략 금지는
      그대로 유지한다. `"이거 왜 이래?" 조사 요청 → analyzer만` 항목도 그대로 둔다.
      검증: 그 절이 "기본 경로가 이미 analyzer 없는 경로"라는 사실과 어긋나지 않는다.

## 4. `.claude/skills/agent-model-tier/SKILL.md` 새로 만들기 (Write — 새 파일)

- [x] 4.1 `.claude/skills/agent-model-tier/SKILL.md`를 만든다. frontmatter에 `name:`과
      `description:`만 둔다. `description:`에는 발동 조건을 담는다 — "모델 낮춰", "토큰 아껴",
      "semi-lower로", "lower로", "normal로 되돌려", "지금 모델 등급 뭐야" 같은 말.
      검증: `head -5`에 `---` 두 줄과 `name:`, `description:`이 있고
      `grep -c 'allowed-tools' .claude/skills/agent-model-tier/SKILL.md`가 **0**이다.
- [x] 4.2 등급 표를 **값으로** 적는다. 세 등급 × 에이전트 7개가 빠짐없이 있어야 한다
      (design.md 결정 13의 표 그대로). `normal`을 반드시 포함한다 — 없으면 되돌릴 수 없다.
      값은 짧은 이름(`opus` / `sonnet` / `haiku`)만 쓰고 전체 모델 ID를 쓰지 않는다.
      표 옆에 **한 단계 내리기 규칙**(`opus → sonnet`, `sonnet → haiku`)도 함께 적는다.
      검증: `grep -c 'haiku' SKILL.md`가 0보다 크고, 표에 `normal`·`semi-lower`·`lower`
      세 열이 있고, 1.4에서 잰 실제 값이 `normal` 열과 한 칸도 다르지 않다.
- [x] 4.3 `## 지금 등급 확인` 절을 쓴다. 7개 파일의 `^model:` 값을 읽어 세 표와 대조하는
      방법을 적는다(각 파일에 `^model:` 줄이 정확히 하나임을 전제로 한다).
      어느 표와도 안 맞으면 **"섞인 상태"로 보고하고 멈춘다** — 가까운 등급으로 짐작하지
      않으며, 7개의 실제 값을 그대로 보여 준 뒤 사용자가 등급을 고르게 한다.
      **섞인 상태는 어디에도 기록되지 않아 복구할 수 없다**는 경고도 적는다.
      검증: 그 절에 "짐작하지 않는다"와 섞인 상태 보고 절차가 있다.
- [x] 4.4 `## 등급 적용` 절을 쓴다. **★ `model:` 한 줄만 Edit으로 고친다. 파일 전체
      재작성과 `sed -i` 금지**를 굵게 적고 이유(전체 재작성으로 마크다운이 망가진 사고)를
      함께 적는다. 이미 그 등급이면 아무것도 바꾸지 않고 알린다는 것도 적는다.
      **이 제약을 스킬 안에 적는 이유**(대상 프로젝트에는 이 저장소의 `config.yaml` 규칙이
      없다)를 한 줄로 남긴다.
      검증: 그 절에 `sed -i` 금지와 전체 재작성 금지가 모두 있다.
- [x] 4.5 `## 바꾼 뒤 확인` 절을 쓴다. `git diff`로 **바뀐 줄이 `model:` 줄들뿐인지** 보고,
      각 파일의 frontmatter가 `---` 두 줄과 `name:`·`description:`·`model:`·`tools:`를
      유지하는지, `^model:` 줄이 파일마다 정확히 하나인지 확인하게 한다.
      검증: 세 확인 항목이 실행 가능한 명령과 함께 있다.
- [x] 4.6 `## 낮추면 무엇이 나빠지는가` 절을 쓴다. design.md 결정 13의 경고 4항목을 담는다:
      worker가 약해지면 **멈출 줄 아는 판단**이 약해져 정해진 동작을 조용히 줄인다는 것
      (`orchestra/SKILL.md`의 문장을 근거로 인용), reviewer·designer가 약해질 때의 영향,
      낮춘 등급으로 큰 일을 돌리지 말라는 권고, `normal`로 되돌리는 방법.
      **이 실패 모드가 조용하다(에러가 안 난다)는 것을 분명히 적는다.**
      낮추기를 적용하기 **전에** 이 경고를 사용자에게 보여 주라고 지시한다.
      검증: 네 항목이 모두 있고, `semi-lower`가 README의 "opus 셋을 sonnet으로" 안내와
      같은 동작이라는 설명이 있다.

## 5. `switch_skill/SKILL.md` 새로 만들기 — **★ 전부 무효 (사용자 결정 6)**

> **5.1 ~ 5.13 을 다시 하지 마라.** 사용자가 *"switch skill은 필요 없겠어. 제거해"* 라고
> 결정해 이 파일(646줄)은 **지워진다** (묶음 12.1). 에이전트 설정은 사람마다 달라서 공유
> 저장소가 들고 다닐 물건이 아니고, 각자 로컬에서 관리하면 전환기가 풀려던 문제가 애초에
> 생기지 않는다. 아래는 당시 작업 기록으로만 남긴다.
>
> **여기서 살아남아 install.sh 로 옮겨 간 것:** 조각을 마커 구획에서 뽑아 쓰기(5.1의 취지 →
> 12.3), 제품 5종 목록(5.5 → 12.5·12.6), 낱말 대신 마커로 판별하기(5.4의 취지 → 12.4).

- [x] 5.1 `switch_skill/SKILL.md`를 **저장소 루트 아래** `switch_skill/`에 만든다.
      frontmatter에 `name:`과 `description:`만 둔다. `description:`에는 **언제 발동하는지**를
      담는다(예: SDD 설치·적용, `SDD 켜줘`, `SDD 꺼줘`, `원래 설정으로 돌려줘`,
      `지금 어느 쪽이야`). 본문 형태는 `.claude/skills/orchestra/SKILL.md`의 frontmatter를
      참고한다.
      검증: `head -5 switch_skill/SKILL.md`에 `---`가 두 줄, `name:`, `description:`이 있고
      `grep -c 'allowed-tools' switch_skill/SKILL.md`가 **0**이다.
- [x] 5.2 스킬에 `## 동작 세 가지 — 켜기 / 끄기 / 상태` 절을 쓴다. 사용자가 무슨 말을 하면
      어느 동작인지 판별하는 기준을 함께 적는다.
      검증: 그 절만 읽고 세 동작과 각각의 발동 문구를 알 수 있다.
- [x] 5.3 `## 원본 트리 구하기` 절을 쓴다. design.md 결정 2의 세 갈래를 그 순서로 적고,
      제품 5종이 다 있는지 확인하는 단계와 "하나라도 없으면 아무것도 바꾸지 않고 멈춘다"를
      적는다. `CLAUDE.md` 조각은 아래 명령으로 뽑는다고 적는다 —
      `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$SRC/CLAUDE.md"`.
      **조각 문구 자체를 스킬에 베껴 적지 않는다.**
      검증: `grep -c '오케스트레이터' switch_skill/SKILL.md`가 0이다(조각이 안 실렸다는 뜻).
- [x] 5.4 `## 지금 상태 판별` 절을 쓴다. `.claude/sdd-switch/state.json` 우선, 없으면 지문 3종
      (`CLAUDE.md`의 마커, `orchestra` 스킬 문서와 그 `name: orchestra`, 에이전트 이름 7개 중
      3개 이상). 아무것도 안 걸릴 때만 "처음 적용". **`grep -q '오케스트레이터'` 같은 낱말 검색
      방식은 쓰지 않는다**는 것과 그 방식의 오판 경로 4개를 적는다(design.md 결정 4의 표).
      검증: 그 절에 낱말 하나로 판별하는 방법이 없고, 오판 경로 4개가 적혀 있다.
- [x] 5.5 `## 전환 대상` 절을 쓴다. **제품 5종**을 표로 적는다: `.claude/agents/*.md` 7개,
      `.claude/skills/orchestra/`, **`.claude/skills/agent-model-tier/`**,
      `.claude/settings.json`, `CLAUDE.md`의 마커 구획. 각각 켤 때·끌 때 무엇을 하는지
      한 칸씩 적는다(design.md 결정 5의 표).
      검증: 표에 5줄이 있고 `agent-model-tier`가 들어 있다.
- [x] 5.6 `## 보관 위치와 형태` 절을 쓴다. `.claude/sdd-switch/`의 세 항목
      (`state.json`, `saved/original/`, `saved/sdd/`), `state.json`의 필드
      (`version`, `active`, `source`, `switchedAt`, `managed[].path/kind/hadOriginal`),
      그리고 **`hadOriginal`이 왜 안전의 핵인지**를 적는다.
      검증: 그 절만 읽고 `state.json`을 손으로 만들 수 있다.
- [x] 5.7 `## 켜기` 절을 쓴다. design.md 결정 7의 6단계를 순서대로 적는다:
      검사 → 사용자에게 목록 보이고 확인 → 보관(복사 후 **바이트 비교 검증**) → 교체 →
      `state.json` 쓰기(마지막) → 보고. **3번이 하나라도 실패하면 아무것도 바꾸지 않고
      멈춘다**를 굵게 적는다. 미커밋 변경이 있으면 먼저 커밋/치우라고 요청하고 멈추는 단계도
      넣는다. 처음 적용일 때는 전제 조건 확인(git 저장소, 커밋 존재, openspec CLI와 버전)과
      `openspec init --tools claude`, 설치 확인, 다음 할 일 안내를 포함한다 —
      `install.sh`의 1·2·5번 절과 140-150줄 안내가 원본이다.
      **`saved/sdd/`에 보관물이 있으면 원본 트리에서 새로 복사하지 말고 그 보관물을
      되돌린다**(design.md 결정 14). 안 그러면 사용자가 내려 둔 모델 등급이 켤 때마다
      말없이 `normal`로 돌아간다. 보관 칸이 비어 있을 때만 원본 트리에서 가져온다.
      검증: 절 안에서 "복사 → 검증 → 교체" 순서와 "실패하면 무변경 후 멈춘다"를 찾을 수 있고,
      `saved/sdd/`가 있을 때의 분기가 적혀 있다.
- [x] 5.8 `## 끄기` 절을 쓴다. `hadOriginal`에 따라 되돌림/삭제를 나누고, `CLAUDE.md`는 마커
      구획만 빼며 사용자가 쓴 나머지는 건드리지 않는다는 것, SDD 파일은 `saved/sdd/`에 보관한
      뒤 물러난다는 것을 적는다. 보관물이 없어 되돌릴 수 없으면 **멈추고 알린다.**
      결과 보고에 **"`openspec/`과 `.claude/skills/openspec-*`은 그대로 남는다"**를 적게 한다.
      검증: 절 안에 `hadOriginal` 분기와 마커 구획만 빼는 지시가 있다.
- [x] 5.9 `## 상태` 절을 쓴다. 보고할 것: 켜진 쪽, 원본 트리 경로, 제품 5종의 현재 위치,
      보관 칸 존재 여부, **어긋남**. 어긋남은 보고만 하고 **자동으로 고치지 않는다**를 적는다.
      검증: 절 안에 다섯 항목과 "자동으로 고치지 않는다"가 있다.
- [x] 5.10 `## 건드리지 않는 것` 절을 쓴다. `.claude/settings.local.json`은 읽기·쓰기·보관 모두
      금지. `.claude/skills/openspec-*` 6개는 전환 대상이 아니며 그 이유 3개(openspec CLI 소유,
      SDD 전용이 아님, `allowed-tools` 때문에 파일을 못 씀)를 적는다.
      검증: 두 항목과 이유가 모두 있다.
- [x] 5.11 `## settings.json 은 합치지 않는다` 절과 `## .gitignore` 절을 쓴다. 파일 통째로
      맞바꾸는 이유와, 원래 파일 보관 경로를 사용자에게 알려 직접 옮기게 하는 안내.
      켤 때 대상 `.gitignore`에 `.claude/sdd-switch/`와 `.claude/settings.local.json` 두 줄을
      (없으면) 더한다는 것, 그리고 **보관 칸을 지우면 원래 설정으로 못 돌아간다는 경고를
      보고에 반드시 적는다**는 것.
      검증: 두 절이 있고 경고 문구가 보고 항목으로 지정되어 있다.
- [x] 5.12 `switch_skill/SKILL.md`가 **서브에이전트를 부르지 않는다**는 것을 절 하나로 적고
      이유 3개를 담는다(design.md 결정 9의 (나)). 사용자와 확인을 주고받아야 하는 지점을
      함께 표시한다.
      검증: 그 절에 이유 3개가 있고, 스킬 어디에도 `Agent(subagent_type:` 호출 예시가 없다.
- [x] 5.13 `switch_skill/SKILL.md`가 `.claude/skills/switch_skill/`에는 없는지 확인한다.
      검증: `ls switch_skill/SKILL.md`는 성공하고 `ls .claude/skills/switch_skill 2>/dev/null`은
      아무것도 내지 않는다.

## 6. `install.sh` 삭제 — **★ 전부 무효 (결정 1이 뒤집혔다)**

> **6.1 ~ 6.2 를 다시 하지 마라.** 삭제의 근거는 "전환 스킬이 기능상 상위집합"이었고,
> 그 스킬이 빠지면서 근거가 사라졌다. 지우면 **설치 수단이 하나도 안 남는다.**
> `install.sh` 는 **묶음 12.2 에서 되살린다.** 지금은 `git rm` 이 스테이징만 된 상태다.

- [x] 6.1 `git rm install.sh`로 지운다 (사용자가 삭제를 승인했다 — decision.md 결정 1).
      **이 한 파일만 지운다.**
      검증: `ls install.sh 2>/dev/null`이 아무것도 내지 않고 `git status`에 그 삭제만 잡힌다.
- [x] 6.2 저장소 전체에서 `install.sh`를 가리키는 안내가 남아 있는지 확인하고, `README.md`
      밖에 남은 것이 있으면 Edit으로 고친다(`README.md`는 7번 묶음에서 다룬다).
      검증: `grep -rn 'install\.sh' . --include='*.md' --include='*.json' | grep -v '^./openspec/' | grep -v '^./docs/' | grep -v '^./README.md'`가
      아무것도 내지 않는다.

## 7. `README.md` 다시 쓰기 (스킬 기준으로)

- [x] 7.1 6-7줄의 순서 문구를 새 기본 순서로 Edit하고, 방안 선택이 analyzer를 부를 때 열린다는
      것을 한 구절로 적는다.
      검증: 그 문장에 `**사용자가 방안 선택**`이 무조건 단계로 들어 있지 않다.
- [x] 7.2 "이게 왜 필요한가" 절(9-15줄)을 Edit한다. "이 구조는 그 지점을 강제로 만든다"를
      사실과 맞게 고친다: 기본 경로에도 남는 개입 지점 4개(범위 밖 확인, 설계 요약 알림,
      조건부 통과, 커밋 관문)와 결정 기록·리뷰가 여전히 있다는 것, 그리고 방안 선택 관문은
      **원할 때 부르면 열린다**는 것. **"관문이 사라졌다"고 적지 않는다.**
      검증: 그 절에 "강제로"가 없고 개입 지점 목록이 있다.
- [x] 7.3 **[무효 — 묶음 12.8 이 대신한다]** 설치 절이 다시 `install.sh` 기준으로 돌아간다.
      아래는 당시 작업 기록이다.
      "## 설치" 절을 다시 쓴다. `방법 1 — 스크립트 (권장)`을
      `방법 1 — switch_skill 스킬 (권장)`으로 바꾸고 design.md 결정 10의 흐름 네 단계를 적는다:
      저장소 clone → `switch_skill/`을 대상 프로젝트 `.claude/skills/`로 복사 →
      Claude Code 새 세션 → 말로 `SDD 켜줘`. `switch_skill`만 복사하라는 것과,
      clone한 디렉터리를 남겨 두면 스킬이 원본 트리로 다시 쓸 수 있다는 것도 적는다.
      `bash install.sh --dry-run` 안내는 없앤다.
      검증: `grep -n 'install.sh' README.md`가 0건. 네 단계가 순서대로 있다.
- [x] 7.4 **[부분 무효 — 묶음 12.9 가 마무리한다]** 조각 코드블록을 없애고 `sed` 한 줄로
      바꾼 것은 **유효하다.** 다만 그 절의 `switch_skill 스킬을 쓰면 알아서 해준다` 문구는
      `install.sh` 기준으로 고쳐야 한다. 아래는 당시 작업 기록이다.
      "### CLAUDE.md 는 복사하지 말고 **합쳐라**" 절(58-79줄)에서 **조각 코드블록을
      삭제하고**, 대신 마커 구획에서 뽑아 붙이는 한 줄로 대체한다:
      `sed -n '/init-SDD:begin/,/init-SDD:end/p' /tmp/init-SDD/CLAUDE.md >> CLAUDE.md`.
      스킬을 쓰면 이걸 알아서 해준다는 것도 적는다.
      검증: `README.md`에 `순서: `preparer`` 문구가 없다(1.1의 개수가 줄어드는 지점이다).
- [x] 7.5 **[무효 — 묶음 12.10 이 대신한다]** 보관·맞바꾸기 모델이 없어졌으므로 이 절은
      "덮어쓰지 말고 내용을 확인해라"로 되돌아간다. 아래는 당시 작업 기록이다.
      "이름이 겹칠 수 있는 파일" 절(81-88줄)을 Edit한다. "덮어쓰지 말고 내용을 확인해라"를
      전환 모델에 맞게 고친다: 스킬이 건너뛰지 않고 `.claude/sdd-switch/saved/original/`로
      보관하며, `.claude/settings.json`은 합치지 않고 맞바꾼다는 것.
      검증: 그 절에 `permissions.allow 배열만 합친다`가 남아 있지 않다.
- [x] 7.6 **[유효]** 제품 5종에 맞춘 것이므로 그대로 살아 있다.
      "### 설치 확인" 절(90-97줄)을 Edit한다. `ls .claude/skills` 결과 설명을
      `openspec-* 6개 + orchestra + agent-model-tier`로 고치고, `agent-model-tier/SKILL.md`가
      있는지 확인하는 줄을 더한다.
      검증: 그 절에 `agent-model-tier`가 있다.
- [x] 7.7 "방법 2 — 손으로" 절(40-52줄)에 `agent-model-tier` 스킬 복사를 더한다
      (`cp -r /tmp/init-SDD/.claude/skills/agent-model-tier .claude/skills/`).
      `.claude/skills/openspec-*`과 `.claude/commands/opsx/`는 복사하지 말라는 기존 경고
      (54-56줄)는 **그대로 둔다.**
      검증: 그 절에 `agent-model-tier` 복사 줄이 있고 기존 경고가 남아 있다.
- [x] 7.8 "## 커스터마이즈" 절의 "모델 바꾸기 — 에이전트 파일의 `model:` 한 줄"(189줄)을
      Edit해 `agent-model-tier` 스킬로 등급을 한 번에 갈 수 있다는 것과 세 등급 이름을 적는다.
      손으로 한 줄씩 고치는 방법도 남겨 둔다.
      검증: 그 항목에 `normal`·`semi-lower`·`lower`가 있다.
- [x] 7.9 "쓰는 법" 절의 "반드시 답해야 하는 지점" 목록(136-144줄)을 Edit한다. 필수 3개
      (범위 밖 확인 / 조건부 통과 / 커밋 직전)로 줄이고, 방안 선택은 "analyzer를 부르면
      열린다"로 옮긴다. 개수 문구("네 곳")도 맞춘다.
      검증: 목록의 번호가 3개이고 방안 선택이 조건으로 적혀 있다.
- [x] 7.10 "일의 크기에 따라 경로가 갈린다" 표(146-153줄)를 Edit한다. `새 기능·리팩터링` 행의
      경로를 기본 경로로, 서브에이전트 호출 횟수를 **6번**으로, 묻는 횟수를 실제 필수 개수로
      맞춘다. `원인이 뻔한 버그` 행이 기본 경로와 같아졌으므로 두 행의 관계를 정리한다.
      `"이거 왜 이래?" 조사 | analyzer 1번` 행은 그대로 둔다.
      검증: 표의 어느 행에도 기본 경로에 analyzer가 들어 있지 않다.
- [x] 7.11 "7개 서브에이전트" 표(157-165줄)의 `analyzer` 행에 `(부를 때만 돈다)`를 Edit으로
      덧붙인다. 설명 문구 "코드베이스 분석, 방안 최소 3가지 + 의견과 근거"는 **그대로 둔다**
      (메인 spec 시나리오가 이 문구를 지목한다).
      검증: `grep -n '방안 최소 3가지 + 의견과 근거' README.md`가 걸리고 같은 행에 `부를 때만`이 있다.
- [x] 7.12 "알아 둘 것" 절(195줄 이하)에서 사실과 어긋난 항목을 Edit한다:
      "정식 경로 한 번은 서브에이전트 7번"(207줄) → 기본은 6번, analyzer를 부르면 7번.
      "대화형 세션에서만 제대로 돈다"(210-211줄) → 근거를 방안 선택 관문 하나에서
      범위 밖 확인·커밋 관문으로 넓힌다. `/opsx`를 직접 쓰면 안 되는 이유(214-215줄) →
      3.4와 같은 근거로 고친다. `.claude/skills/openspec-*` 관련 항목은 그대로 둔다.
      검증: `grep -n '서브에이전트 7번' README.md`가 0건.

## 8. 추적 제외 로컬 문서 정합성

- [x] 8.1 `docs/example-run.md`에서 analyzer가 기본 2단계로 나오는 대목(57줄 주변)에,
      이 예시가 **analyzer를 부른 경우의 흐름**이라는 것을 알 수 있는 한 줄을 Edit으로 더한다.
      "평가 모드" 표현이 없는지, 재호출 흐름 서술(102-103줄)이 남아 있는지 함께 확인한다.
      **`docs/final-report.md`와 `docs/verification-2026-09-08.md`는 날짜 박힌 과거 기록이라
      고치지 않는다.**
      검증: `grep -c '평가 모드' docs/example-run.md`가 0이고, 57줄 주변에 옵트인임을 알리는
      문구가 있다. (이 파일은 `.git/info/exclude`로 추적 제외라 커밋에 잡히지 않는다 —
      보고서의 "만진 파일"에 그 사실을 함께 적는다)

## 9. 검증

- [x] 9.1 **조각이 한 벌만 남았는지 센다.** 1.1과 같은 명령을 다시 돌려 **파일 1개
      (`CLAUDE.md`)**만 나오는지 확인하고, 1.1의 값과 함께 보고서에 적는다.
      `grep -rln '순서: `preparer`' . --include='*.md' --include='*.sh' | grep -v '^./openspec/'`
- [x] 9.2 **세 문서의 순서 문구가 일치하는지** grep으로 대조한다.
      `grep -n 'preparer' CLAUDE.md README.md .claude/skills/orchestra/SKILL.md`의 결과에서
      `preparer` 다음이 `designer`인지, 사이에 `analyzer`가 없는지 확인한다.
- [x] 9.3 **마크다운 무결성**을 확인한다. 이번에 만지거나 새로 만든 모든 `.md` 파일에 대해
      `grep -c 'ORCA_RICH_MD'`가 0이고, 백틱 3개로 시작하는 줄의 개수가 짝수인지 본다.
      `.claude/skills/orchestra/SKILL.md`의 frontmatter가 `---` 두 줄과 `name:`,
      `description:`을 유지하는지 확인한다.
- [x] 9.4 **에이전트 파일 7개가 손대지지 않았는지** 확인한다.
      `git diff --stat -- .claude/agents/`에 아무것도 없어야 한다. 이번 change는 에이전트
      파일을 고치지 않는다 — `analyzer.md`도 `designer.md`도, 그리고 **`model:` 줄도
      건드리지 않는다** (등급 스킬 문서를 만드는 것까지가 범위다. 실제 등급 변경은 나중에
      사용자가 스킬을 써서 한다).
- [x] 9.5 **모델 등급 스킬 확인.** `.claude/skills/agent-model-tier/SKILL.md`에서
      `grep -c 'allowed-tools'`가 0이고, `normal`·`semi-lower`·`lower` 세 등급 이름이 모두
      있고, 에이전트 7개 이름이 모두 등급 표에 있고, `sed -i`가 금지로 적혀 있는지 본다.
      `normal` 열의 값이 1.4에서 잰 실제 값과 한 칸도 다르지 않은지 대조한다.
- [x] 9.6 **[부분 무효 — 묶음 12.16 이 다시 확인한다]** 대조 대상이 `switch_skill/SKILL.md`
      에서 `install.sh` 로 바뀐다. 아래는 당시 작업 기록이다.
      **제품 5종이 문서마다 일관된지** 확인한다. `switch_skill/SKILL.md`의 전환 대상 표와
      `README.md`의 설치·설치 확인 절에 `agent-model-tier`가 모두 들어 있어야 한다.
      `grep -rn 'agent-model-tier' README.md switch_skill/SKILL.md`
- [x] 9.7 **[무효 — 대상 파일이 없어진다]** 아래는 당시 작업 기록이다.
      **`switch_skill/SKILL.md`에 제품 내용이 안 실렸는지** 확인한다.
      `grep -c '오케스트레이터' switch_skill/SKILL.md`가 0,
      `grep -c 'allowed-tools' switch_skill/SKILL.md`가 0,
      `grep -c 'Agent(subagent_type' switch_skill/SKILL.md`가 0.
- [x] 9.8 **openspec CLI 실측.** 종료코드로 판정한다. 파이프를 붙이지 않는다.
      `openspec validate "make-analyzer-opt-in-and-add-install-skill" --strict --change`가 아니라
      `openspec validate "make-analyzer-opt-in-and-add-install-skill" --strict; echo "exit=$?"`로
      `exit=0`을 확인하고,
      `openspec status --change "make-analyzer-opt-in-and-add-install-skill" --json >/dev/null; echo "metadata exit=$?"`로
      `exit=0`을 확인한다.
- [x] 9.9 **[무효 — 판정이 정반대로 뒤집혔다. 묶음 12.19 가 대신한다]** 이제 `install.sh`는
      **있어야 하고** 그것을 가리키는 안내도 **있어야 한다.** 없어야 하는 것은
      `switch_skill` 이다. 아래는 당시 작업 기록이다.
      **`install.sh`가 없고 그것을 가리키는 안내도 없는지** 마지막으로 확인한다.
      `ls install.sh`가 실패하고,
      `grep -rn 'install\.sh' . --include='*.md' | grep -v '^./openspec/' | grep -v '^./docs/'`가
      아무것도 내지 않는다.

## 10. 임시 프로젝트에서 실제로 돌려 보기 — **★ 갈래 7 만 유효. 나머지는 무효**

> **10.2 ~ 10.7, 10.9 (갈래 1~6, 8) 는 전환 스킬 실측이라 무효다.** 그 기능이 제품에서
> 빠졌다. **다시 하지 마라.** 대신 묶음 12.13 이 `install.sh` 재검증을 새로 요구한다.
>
> **10.8 (갈래 7 — `agent-model-tier` 등급 한 바퀴) 은 유효하다.** 그 스킬은 그대로
> 남으므로 이 검증은 지금도 살아 있는 근거다.
>
> **10.1 (verification.md 머리말) 과 10.10 ~ 10.12 (치우기·마무리·흔적 확인) 도 유효하다.**
> 다만 `verification.md` 는 묶음 12.12 에서 "전환기 절은 이후 제거된 기능이다" 를 밝히도록
> 손본다. **실측 기록은 지우지 않는다** — 스킬 결함 4개를 찾아낸 과정이고 왜 그렇게
> 설계했는지의 근거다.

**두 스킬은 프로그램이 아니라 절차 문서다.** "돌려 본다"는 곧 **worker가 그 문서를 읽고
적힌 절차를 임시 프로젝트에서 손으로 실행해 본다**는 뜻이다. 문서에 빠진 단계나 안 맞는
명령이 있으면 그게 바로 이 시험이 찾는 결함이다 — 발견하면 스킬 문서를 고치고 다시 돌린다.

**★ 안전 못박기 (어기면 사용자 데이터가 위험하다):**
- **시험 대상은 `mktemp -d`로 만든 임시 디렉터리뿐이다.** 이 저장소(`init-SDD`)나 사용자의
  다른 프로젝트를 대상으로 삼지 마라. `openspec init`도 임시 디렉터리 안에서만 돌린다.
- **이 저장소의 `.claude/agents/*.md`의 `model:` 줄을 건드리지 마라.** 등급 시험은 임시
  프로젝트에 복사된 사본에서만 한다 (9.4가 이 저장소에 diff가 없어야 한다고 요구한다).
- 만든 임시 경로를 **10.1에 기록**하고, **10.10에서 반드시 치운다.**

**결과를 남기는 곳:** `openspec/changes/make-analyzer-opt-in-and-add-install-skill/verification.md`
— `analysis.md`처럼 스키마 밖 파일이지만 changeRoot 안에 있어 **커밋되고 archive된다.**
`docs/` 아래에는 적지 마라. 추적 제외라 reviewer가 확인할 수 없다.

- [x] 10.1 `verification.md`를 만들고 머리말을 쓴다: 시험 날짜, 임시 디렉터리 절대 경로,
      `openspec --version`, `git --version`. 아래 갈래마다 **실행한 명령과 그 출력, 그리고
      합격/불합격**을 적는다.
      합격 기준: 파일이 있고 머리말 4항목이 채워져 있다.
- [x] 10.2 **갈래 1 — 첫 적용.** `mktemp -d`로 빈 프로젝트를 만들고 `git init`,
      `git commit --allow-empty -m init`, `openspec init --tools claude`를 돌린 뒤,
      `switch_skill/`을 그 프로젝트의 `.claude/skills/`로 복사하고 켜기 절차를 실행한다.
      합격 기준: (a) `.claude/agents/*.md`가 7개, (b) `.claude/skills/orchestra/SKILL.md` 있음,
      (c) `.claude/skills/agent-model-tier/SKILL.md` 있음, (d) `.claude/settings.json` 있음,
      (e) `CLAUDE.md`에 마커 구획이 정확히 하나, (f) `openspec list`가 종료코드 0,
      (g) `.claude/sdd-switch/state.json`의 `active`가 sdd, (h) `.gitignore`에
      `.claude/sdd-switch/`가 있음.
- [x] 10.3 **갈래 2 — 겹치는 설정이 있는 경우.** 새 임시 프로젝트에 미리 내용을 넣어 둔다:
      사람이 쓴 문장이 든 `CLAUDE.md`, 우리 것과 다른 `.claude/settings.json`,
      우리와 같은 이름이지만 내용이 다른 `.claude/agents/preparer.md`.
      **켜기 전에 이 셋을 임시 경로에 따로 사본으로 떠 둔다**(대조용). 그 다음 켜기를 실행한다.
      합격 기준: (a) 세 파일이 `.claude/sdd-switch/saved/original/` 아래 같은 상대 경로에 있고,
      (b) 떠 둔 사본과 `diff`해서 **차이가 0**이며, (c) `state.json`의 `managed`에서 이 셋이
      `hadOriginal: true`이고, (d) `CLAUDE.md`의 사람이 쓴 문장이 그대로 남아 있다.
- [x] 10.4 **갈래 3 — 끄기(되돌리기).** 10.3의 프로젝트에서 끄기 절차를 실행한다.
      합격 기준: (a) `CLAUDE.md`·`settings.json`·`preparer.md`가 10.3에서 떠 둔 사본과
      `diff` 차이 0, (b) `CLAUDE.md`에 마커 구획이 없음, (c) SDD가 새로 만든 파일
      (`hadOriginal: false`인 것들)은 지워졌고 빈 디렉터리도 안 남음,
      (d) `state.json`의 `active`가 original, (e) 결과 보고에 "`openspec/`과
      `.claude/skills/openspec-*`은 그대로 남는다"가 있고 실제로 남아 있음.
- [x] 10.5 **갈래 4 — 여러 번 갈아타기.** 10.4의 프로젝트에서 켜기 → 끄기를 **두 번 더**
      반복한다. 각 켠 직후와 끈 직후 상태를 `diff -r`로 첫 회차와 대조한다.
      합격 기준: (a) 켠 직후 상태가 매번 첫 켜기 직후와 차이 0, (b) 끈 직후 상태가 매번
      켜기 전 원본과 차이 0, (c) `CLAUDE.md`의 마커 구획이 언제나 정확히 하나(두 번 안 들어감),
      (d) `saved/` 아래에 회차마다 쌓이는 쓰레기가 없음.
- [x] 10.6 **갈래 5 — `hadOriginal` 두 갈래.** 10.2의 프로젝트(원래 아무것도 없던 쪽)에서
      끄기를 실행해 `hadOriginal: false` 갈래를 밟고, 10.4에서 이미 밟은 `true` 갈래 결과와
      나란히 적는다.
      합격 기준: (a) `false` 갈래에서는 해당 파일이 **지워지고**, (b) `true` 갈래에서는
      **바이트 그대로 되돌아오며**, (c) 두 갈래가 `verification.md`에 따로 기록되어 있다.
- [x] 10.7 **갈래 6 — 중간에 실패했을 때.** 보관 단계를 일부러 깨고 켜기를 시도한다.
      깨는 방법 예: `.claude/sdd-switch/saved/original`을 미리 만들고 `chmod 500`으로 쓰기를
      막는다(끝나면 `chmod 700`으로 되돌린다). 복사나 바이트 비교가 실패해야 한다.
      합격 기준: (a) 절차가 **교체 단계로 넘어가지 않고 멈춘다**, (b) 어느 파일에서 실패했는지
      보고한다, (c) **원래 자리의 파일이 하나도 바뀌지 않았다**(미리 떠 둔 사본과 `diff` 차이 0),
      (d) `state.json`이 안 만들어졌거나 `active`가 바뀌지 않았다.
      **강제로 깨는 데 실패하면** 그 사실을 적고, 스킬 문서의 해당 분기를 읽어 확인한 것으로
      대체한 뒤 **"강제 실패 시험은 못 했다"를 `verification.md`에 분명히 남긴다.**
      추측으로 합격 처리하지 마라.
- [x] 10.8 **갈래 7 — `agent-model-tier` 한 바퀴.** 임시 프로젝트(10.2)에서
      `normal → semi-lower → lower → normal`을 차례로 적용한다. 시작 전에 7개 파일의
      `model:` 값과 파일 사본을 떠 둔다.
      합격 기준: (a) 각 단계에서 7개 값이 4.2의 표와 한 칸도 다르지 않음,
      (b) 마지막 `normal`이 시작 값과 같음, (c) 각 파일 frontmatter가 `---` 두 줄과
      `name:`·`description:`·`model:`·`tools:`를 유지, (d) `^model:` 줄이 파일마다 정확히 하나,
      (e) 코드펜스 개수가 짝수이고 `grep -c 'ORCA_RICH_MD'`가 0,
      (f) `git diff`(임시 프로젝트 쪽)에서 **바뀐 줄이 `model:` 줄들뿐**,
      (g) 같은 등급을 두 번 적용했을 때 아무것도 바뀌지 않음.
- [x] 10.9 **갈래 8 — 두 스킬이 겹치는 지점(결정 14).** 10.8에서 등급을 `lower`로 내려 둔 채
      SDD를 끄고 다시 켠다.
      합격 기준: (a) 다시 켠 뒤 7개 `model:` 값이 여전히 `lower` 표와 같고,
      (b) 원본 트리의 `normal` 값으로 말없이 돌아가지 않았으며, (c) 켜기 절차가
      `saved/sdd/`의 보관물을 되돌린 것임을 로그나 보고로 확인할 수 있다.
      **여기서 `normal`로 돌아가면 결정 14가 문서에 안 반영된 것이다** — 스킬을 고치고 다시 돌린다.
- [x] 10.10 **치운다.** 10.2·10.3에서 만든 임시 디렉터리를 `rm -rf`로 지우고, 지운 경로를
      `verification.md`에 적는다. `chmod`로 바꿔 둔 권한이 남아 있지 않은지도 확인한다.
      합격 기준: 기록된 임시 경로들이 더 이상 존재하지 않는다(`ls`가 실패한다).
- [x] 10.11 **`verification.md` 마무리.** 갈래 1~8의 합격/불합격을 표 하나로 요약하고,
      시험 때문에 스킬 문서를 고쳤다면 무엇을 왜 고쳤는지 적는다.
      합격 기준: 표에 8줄이 있고 각 줄에 합격/불합격과 근거(명령 출력)가 달려 있다.
      **불합격이 하나라도 있으면 그 사실을 그대로 남긴다.** 통과로 적지 마라.
- [x] 10.12 시험이 끝난 뒤 **이 저장소에 시험 흔적이 없는지** 확인한다.
      합격 기준: `git status --short`에 임시 파일이 없고,
      `git diff --stat -- .claude/agents/`가 비어 있다(9.4와 같은 확인).

## 11. 교착 수정과 재검증 — **★ 전부 무효 (전환기 전용)**

> **11.1 ~ 11.9 를 다시 하지 마라.** 이 묶음은 전환 스킬의 켜기·끄기 관문만 다룬다.
> `install.sh` 에는 켜기·끄기가 없고 깨끗한 작업 트리 관문도 없다. `decision.md` 결정 5도
> 함께 폐기됐다. 아래는 당시 작업 기록으로만 남긴다 (그 교착을 어떻게 판단했는지는
> `verification.md` 417줄 이하에 남아 있고, 그 기록 자체는 지우지 않는다).

묶음 10 실측에서 **끄기의 "깨끗한 작업 트리" 관문이 켜기가 만든 변경에 걸려 켠 직후 끄기가
언제나 멈추는** 교착이 나왔다. designer가 판단해 `decision.md` 결정 5로 정했고
`design.md` 결정 7과 spec에 반영했다. 여기서는 그 결정을 스킬에 옮기고 다시 밟는다.

**결정 요약:** 확인 대상은 만질 경로 5개뿐(이건 worker가 이미 결함 1로 고쳤다).
**켜기는 멈추고, 끄기는 알리기만 한다.** 켜기 6단계 보고에 "전환으로 생긴 변경을 커밋해
두라"를 더한다. 이유는 두 방향에서 git이 지켜 주는 것이 다르기 때문이다 — 근거는
`decision.md` 결정 5에 있다.

- [x] 11.1 `switch_skill/SKILL.md`의 **`## 끄기`** 절에서 커밋 확인을 **멈춤에서 알림으로**
      내린다. 확인 자체와 좁힌 경로 5개는 그대로 두고, "있으면 멈춘다"를 "있으면 알리고
      진행한다"로 Edit한다. **왜 끄기는 멈추지 않는지** 한 줄을 함께 적는다
      (물러나는 것은 전부 켜기가 놓은 파일이고 `saved/sdd/`에 바이트 비교까지 거쳐 보관된다).
      합격 기준: `## 끄기` 절에 "멈춘다"가 커밋 확인 대목에 없고, 알림으로 적혀 있고 이유가 있다.
- [x] 11.2 `switch_skill/SKILL.md`의 **`## 켜기` 6단계 보고**에 **"전환으로 생긴 변경을
      커밋해 두라"**는 안내를 Edit으로 더한다. 안 적으면 사용자가 막힌 채 다음 수를 모른다.
      합격 기준: 6단계 보고 항목에 그 안내가 있고, 다음에 무엇을 하면 되는지 알 수 있다.
- [x] 11.3 `## 켜기` 절의 커밋 확인이 **켜기에서는 여전히 멈추는지** 확인한다(내리지 마라 —
      켜기는 사용자 작업 트리에만 있는 파일을 밀어내고 보관 칸은 추적 제외라 git으로 복구되지
      않는다). 이유가 절에 적혀 있지 않으면 한 줄 더한다.
      합격 기준: `## 켜기`에는 "멈춘다"가 남아 있고, 켜기만 멈추는 이유가 적혀 있다.
- [x] 11.4 `## 끄기` 결과 보고에 **"관리 목록에 없는 경로에 사용자가 만든 파일은 그대로
      남는다"**를 Edit으로 더한다. 안 적으면 사용자가 남은 파일을 고장으로 오해한다.
      합격 기준: 끄기 보고 항목에 그 문장이 있다.
- [x] 11.5 **재검증 — 갈래 ③(끄기).** 임시 프로젝트를 새로 만들어(묶음 10의 안전 규칙 그대로:
      `mktemp -d`만, 이 저장소 금지, 끝나고 치운다) 겹치는 설정을 심고 켠 뒤,
      **전환 변경을 커밋하지 않은 채 곧바로 끄기를 실행한다.**
      합격 기준: (a) 끄기가 **멈추지 않고 진행된다**, (b) 커밋 안 된 변경이 있다는 **알림이
      전달된다**, (c) 원래 설정 세 파일이 켜기 전 사본과 `diff` 차이 0,
      (d) `CLAUDE.md`에 마커 구획이 없고 사용자 문장이 살아 있다.
- [x] 11.6 **재검증 — 갈래 ④(반복).** 같은 프로젝트에서 **한 번도 커밋하지 않고** 켜기 → 끄기를
      두 번 더 되풀이한다. 관문을 내린 뒤에도 반복 안전성이 유지되는지가 핵심이다.
      합격 기준: (a) 매 회차가 멈추지 않고 끝난다, (b) 켠 직후 상태가 매번 첫 켜기 직후와
      `diff -r` 차이 0, (c) 끈 직후 상태가 매번 켜기 전 원본과 차이 0,
      (d) 마커 구획이 언제나 정확히 하나, (e) `saved/` 아래에 회차마다 쌓이는 쓰레기가 없다.
- [x] 11.7 **재검증 — 켜기 관문은 여전히 걸리는지.** 같은 프로젝트에서 만질 경로 하나
      (예: `CLAUDE.md`)에 사용자 변경을 만들어 커밋하지 않은 채 켜기를 실행한다.
      합격 기준: (a) 켜기가 **멈춘다**, (b) 커밋/치우기를 요청한다, (c) 파일이 하나도 바뀌지 않는다.
      **여기서 안 멈추면 11.1이 켜기까지 내려 버린 것이다** — 되돌린다.
- [x] 11.8 `verification.md`에 **"실측 뒤 고친 것"** 절을 더한다. 교착의 내용, `decision.md`
      결정 5로 어떻게 정했는지, 11.5~11.7 재검증 결과(합격 기준별 실측)를 적는다.
      기존 갈래 8줄 요약 표에는 손대지 말고, 표 아래에 이 절을 붙인다.
      합격 기준: 절이 있고 재검증 3건의 합격/불합격과 근거(명령 출력)가 달려 있다.
- [x] 11.9 **치우고 확인한다.** 11.5에서 만든 임시 디렉터리를 `rm -rf`로 지우고 경로를
      `verification.md`에 적는다.
      합격 기준: 기록된 경로가 더 이상 없고, `git status --short`에 임시 파일이 없고,
      `git diff --stat -- .claude/agents/`가 비어 있다.

## 12. `switch_skill` 빼고 `install.sh` 되살리기 (2026-09-11 사용자 결정 6)

이 묶음이 무효가 된 묶음 5·6·11 과 묶음 7·9 의 일부를 대신한다.
**근거:** `decision.md` 의 `## 결정 변경 2026-09-11`(결정 6~8), `design.md` 결정 1·2·4·5·7·8·10.

**여기서 지키는 두 가지 소득 (이게 이 묶음의 목적이다):**

1. **조각 원본 1벌.** 되살린 `install.sh` 가 조각 문구를 하드코딩하지 않고 `CLAUDE.md` 의
   마커 구획에서 뽑아 쓴다. 마커 구획은 그대로 둔다 — 지우지 마라.
2. **제품 5종.** `install.sh` 의 복사 대상에 `.claude/skills/agent-model-tier/` 를 넣는다.

**건드리지 마라:** 요구사항 1(analyzer 옵트인) 결과 전부, 요구사항 3(`agent-model-tier` 스킬)
전부, `CLAUDE.md` 의 마커 구획, 묶음 1·3·4·8 의 결과, 다른 change(`split-repo-tracking-scope`),
`.agents/skills/claude-handoff/`(다른 도구가 놓은 것이다).

### 12-가. 파일 두 개 (지우기와 되살리기)

- [x] 12.1 `switch_skill/` 을 지운다. 이 디렉터리는 아직 커밋된 적이 없어서(`git status` 에
      `?? switch_skill/`) git 으로 복구되지 않는다. 그래서 `git rm` 이 아니라 `rm -rf` 다.
      ```bash
      rm -rf switch_skill
      ```
      검증: `ls switch_skill 2>/dev/null` 이 아무것도 내지 않고, `git status --short` 에
      `?? switch_skill/` 이 없다.
- [x] 12.2 `install.sh` 를 되살린다. **아래 명령을 그대로 써라.** 지금 이 브랜치는 커밋된 게
      없고 `git rm install.sh` 만 스테이징된 상태여서, `HEAD` 와 `master` 의 `install.sh` 가
      바이트까지 같다(`md5` 대조로 확인했다). 파일 모드가 `100755`(실행 가능)라는 점이
      중요하다.
      ```bash
      git checkout HEAD -- install.sh
      ```
      이 한 줄이 **내용·파일 모드(755)·스테이징된 삭제 취소를 한 번에** 처리한다.
      `git show HEAD:install.sh > install.sh` 도 내용은 같지만 **실행 비트를 잃고**
      스테이징된 삭제가 남으므로, 그 형태를 쓸 경우 `chmod +x install.sh` 와
      `git add install.sh` 를 반드시 함께 해야 한다. 되도록 위의 `git checkout` 을 써라.
      검증: `ls -l install.sh` 가 `-rwxr-xr-x`(실행 비트 있음)를 보이고,
      `git status --short` 에 `install.sh` 의 삭제(`D`)가 더 이상 없고,
      `bash -n install.sh; echo "exit=$?"` 가 `exit=0` 이다.

### 12-나. `install.sh` 고치기 (Edit 부분 수정만 — 통째로 다시 쓰지 마라)

- [x] 12.3 **★ 조각 하드코딩을 없앤다** (`design.md` 결정 1). `install.sh` 82-96줄의
      `SNIPPET='...'` 대입을 지우고, 저장소 `CLAUDE.md` 의 마커 구획에서 뽑는 형태로 바꾼다:
      ```bash
      SNIPPET="$(sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$SRC/CLAUDE.md")"
      ```
      **그리고 뽑은 값이 비어 있으면 멈춘다.** 이건 하드코딩에는 없던 새 실패 모드다 —
      빈 값을 붙이면 스크립트가 "성공"이라 말하면서 아무 지시문도 넣지 않고 사용자는 깔렸다고
      믿는다. `fail()` 이 이미 있으니 그것을 쓴다. 예:
      `[[ -n "$SNIPPET" ]] || fail "CLAUDE.md 에서 init-SDD 구획을 뽑지 못했다. $SRC/CLAUDE.md 의 마커를 확인해라."`
      검증: `grep -c '오케스트레이터' install.sh` 가 **1 이하**여야 한다(12.4 의 판별에 쓰는
      한 곳만 남는다). `grep -n 'init-SDD:begin' install.sh` 가 걸린다.
      `grep -n 'SNIPPET' install.sh` 결과에 여러 줄짜리 조각 본문이 없다.
- [x] 12.4 **판별을 낱말에서 마커로 바꾼다** (`design.md` 결정 4). 101줄의
      `grep -q '오케스트레이터' "$DST/CLAUDE.md"` 하나를 **세 갈래**로 나눈다:
      - `CLAUDE.md` 에 `<!-- init-SDD:begin -->` 가 있다 → 이미 들어갔다. 건너뛴다
      - 마커도 없고 `오케스트레이터` 도 없다 → 조각을 끝에 덧붙인다 (지금 동작)
      - 마커는 없는데 `오케스트레이터` 가 있다 → **넣지 않고 왜 넣지 않았는지 알린다.**
        예전 방식으로 깔았을 수도 있고 사용자가 우연히 그 낱말을 썼을 수도 있어 스크립트가
        구별할 수 없다. 직접 확인해 넣는 방법(`sed -n ...` 한 줄)을 함께 알린다.
      검증: `grep -n 'init-SDD:begin' install.sh` 가 조각 뽑기(12.3)와 판별 두 곳에 걸리고,
      세 갈래의 안내 문구가 각각 있다.
- [x] 12.5 **복사 대상에 모델 등급 스킬을 더한다** (`design.md` 결정 5). 73-77줄의
      `copy_if_absent` 호출 옆에 한 줄을 더한다:
      ```bash
      copy_if_absent ".claude/skills/agent-model-tier" ".claude/skills/agent-model-tier"
      ```
      검증: `grep -n 'agent-model-tier' install.sh` 가 걸린다.
- [x] 12.6 **설치 확인을 5종에 맞춘다.** 112-129줄의 확인 부분에 `orchestra` 와
      `agent-model-tier` 스킬이 깔렸는지 보는 줄을 더한다. 에이전트 7개 세기와 openspec 스킬
      6개 확인은 그대로 둔다.
      검증: 확인 부분에 `orchestra` 와 `agent-model-tier` 가 둘 다 나온다.
- [x] 12.7 **`CLAUDE.md` 맨 위 "템플릿 안내" 주석을 되돌린다** (2.3 이 무효가 된 자리다).
      `switch_skill 스킬을 쓰면 알아서 덧붙인다.` → `install.sh 를 쓰면 알아서 덧붙인다.`
      **마커 구획 자체(`<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->`)와 그 안의 조각
      본문은 한 글자도 건드리지 마라.** 이제 `install.sh` 가 그 구획을 읽어 쓴다.
      검증: `grep -n 'install.sh' CLAUDE.md` 가 걸리고 `grep -c 'switch_skill' CLAUDE.md` 가 0.
      `grep -c 'init-SDD:begin' CLAUDE.md` 가 1, `grep -c 'init-SDD:end' CLAUDE.md` 가 1.

### 12-다. `README.md` 를 `install.sh` 기준으로 다시 쓰기

- [x] 12.8 **"## 설치" 절의 "방법 1" 을 다시 쓴다** (7.3 이 무효가 된 자리다.
      `design.md` 결정 10). `방법 1 — switch_skill 스킬 (권장)` →
      `방법 1 — install.sh (권장)`. 흐름 네 단계를 적는다:
      ```bash
      git clone --depth 1 https://github.com/CHO-YoungSeok/init-SDD.git /tmp/init-SDD
      cd /path/to/your-project
      bash /tmp/init-SDD/install.sh --dry-run     # 무엇을 할지 먼저 본다
      bash /tmp/init-SDD/install.sh               # 설치
      ```
      그 다음 Claude Code 를 **새 세션으로** 다시 연다는 것도 적는다.
      **`--dry-run` 을 먼저 권하는 것을 빼지 마라** — 남의 프로젝트에 파일을 쓰는 스크립트다.
      전환 관련 서술(`SDD 켜줘`, `SDD 꺼줘`, `지금 어느 쪽이야`,
      `.claude/sdd-switch/saved/original/`)은 전부 없앤다.
      검증: 그 절에 `install.sh` 와 `--dry-run` 이 있고 `switch_skill`·`sdd-switch` 가 없다.
- [x] 12.9 **"### CLAUDE.md 는 복사하지 말고 합쳐라" 절을 마무리한다** (7.4 의 남은 부분).
      **조각 코드블록을 없애고 `sed` 한 줄로 바꾼 것은 그대로 둔다 — 그게 이번 소득이다.**
      `(switch_skill 스킬을 쓰면 알아서 해준다)` → `(install.sh 를 쓰면 알아서 해준다)`.
      검증: 그 절에 `sed -n` 한 줄이 남아 있고 `switch_skill` 이 없다.
- [x] 12.10 **"### 이름이 겹칠 수 있는 파일" 절을 되돌린다** (7.5 가 무효가 된 자리다).
      보관·맞바꾸기 서술을 없애고 `install.sh` 의 안전 모델로 되돌린다:
      **이미 있으면 덮어쓰지 않고 건너뛰며, 건너뛴 목록과 저장소 쪽 원본 경로를 알려 준다.**
      겹칠 수 있는 파일 목록(제품 5종)은 그대로 두고, `.claude/settings.json` 항목은
      "이미 있으면 덮어쓰지 말고 필요한 줄을 직접 옮겨라"로 되돌린다 (`design.md` 결정 8).
      검증: 그 절에 `sdd-switch`·`맞바꾼다`·`SDD 꺼줘` 가 없고 `건너` 가 있다.
      제품 5종 목록에 `agent-model-tier` 가 남아 있다.
- [x] 12.11 **`README.md` 에 남은 `switch_skill` 언급을 모두 없앤다.**
      검증: `grep -c 'switch_skill' README.md` 가 0, `grep -c 'sdd-switch' README.md` 가 0.
      7.6 ~ 7.12 에서 고친 것(설치 확인 5종, 커스터마이즈의 등급 3개, 묻는 지점 3개,
      경로 표, 에이전트 표, "알아 둘 것")은 **그대로 둔다 — 유효하다.**

### 12-라. `verification.md` 정리 (지우지 말고 표시한다)

- [x] 12.12 **전환기 실측 절에 "이 기능은 이후 제거됐다"를 밝힌다.** 파일 머리말 바로 아래에
      경고 블록을 넣는다: 갈래 ①~⑥·⑧ 과 묶음 11 재검증은 `switch_skill` 실측이고
      그 기능은 2026-09-11 사용자 결정으로 **제품에서 빠졌다는 것**, 그래서 지금 제품과
      맞지 않는다는 것, 그런데도 **기록으로 남기는 이유**(스킬 결함 4개를 찾아낸 과정이고
      왜 그렇게 설계했는지의 근거다), 그리고 **갈래 ⑦(등급 한 바퀴)은 `agent-model-tier`
      자체의 검증이라 지금도 유효**하다는 것.
      **한 줄도 지우지 마라.** 표시만 더한다. 요약 표의 갈래 ①~⑥·⑧ 행에도 짧게
      `(제거된 기능)` 을 달고, ⑦ 행에는 `(유효)` 를 단다.
      검증: `grep -c '' verification.md` 가 627 이상이고(줄이 줄지 않았다),
      머리말 근처에 `제거` 가 있고 갈래 ⑦ 줄에 `유효` 가 있다.
- [x] 12.13 **`install.sh` 재검증 절을 `verification.md` 끝에 새로 더한다.**
      **묶음 10 의 안전 규칙을 그대로 지킨다** — 시험은 `mktemp -d` 임시 디렉터리에서만 하고,
      이 저장소와 사용자의 다른 프로젝트를 대상으로 삼지 않고, 끝나면 치운다.
      임시 경로를 적어 두고 12.14 에서 지운다. 네 가지를 **실행한 명령과 출력과 함께** 남긴다:
      1. **문법:** `bash -n install.sh; echo "exit=$?"` → `exit=0`
      2. **마른 실행:** 임시 프로젝트에서 `bash /path/install.sh --dry-run` →
         종료코드 0 이고, 그 뒤 `git status --porcelain` 이 실행 전과 같다(아무것도 안 바뀜)
      3. **실제 설치 — 조각이 마커에서 제대로 뽑혔는지:** 빈 임시 프로젝트에
         `git init` + 초기 커밋 후 실제 설치. 그 다음 대상 `CLAUDE.md` 의 마커 구획과
         저장소 `CLAUDE.md` 의 마커 구획을 **`diff` 로 대조**해 차이가 없어야 한다.
         마커 두 줄도 함께 들어갔는지 본다
      4. **`agent-model-tier` 가 복사됐는지:**
         `ls <임시>/.claude/skills/agent-model-tier/SKILL.md` 가 있고,
         저장소 원본과 `diff` 로 차이가 없다
      그리고 **판별 세 갈래**(12.4)도 실제로 밟는다:
      같은 프로젝트에 설치를 **한 번 더** 돌려 `grep -c 'init-SDD:begin' CLAUDE.md` 가
      **1** 인지(조각이 두 번 들어가지 않았는지) 확인하고,
      마커 없이 `오케스트레이터` 만 있는 `CLAUDE.md` 를 만들어 두고 돌려 **넣지 않고
      알리는지** 확인한다.
      하나라도 안 되면 **안 됐다고 적는다.** 추측으로 합격 처리하지 마라.
- [x] 12.14 **치우고 확인한다.** 12.13 에서 만든 임시 디렉터리를 `rm -rf` 로 지우고 지운
      경로를 `verification.md` 에 적는다.
      검증: 지운 경로가 `ls` 로 없고, 이 저장소에 시험 흔적이 없다 —
      `git status --short` 에 임시 경로가 없고 `git diff --stat -- .claude/agents/` 가 비어 있다.

### 12-마. 마무리 검증 (묶음 9 를 지금 상태 기준으로 다시 돌린다)

- [x] 12.15 **조각이 한 벌만 남았는지 다시 센다.** 1.1 과 같은 명령을 돌린다. 이제
      `install.sh` 가 있으므로 **그 파일에도 조각이 없어야 한다**는 것이 요점이다.
      필터가 새지 않게 아래 형태를 그대로 써라 (`grep -v '^./openspec/'` 는 샌다):
      ```bash
      grep -rln '순서: `preparer`' . --include='*.md' --include='*.sh' | grep -vE '^(\./)?openspec/'
      ```
      합격: 파일이 **정확히 하나**이고 그 파일은 `./CLAUDE.md` 다. 1.1 의 값과 함께 보고한다.
- [x] 12.16 **제품 5종이 문서마다 일관된지 다시 확인한다** (9.6 을 대신한다).
      `grep -n 'agent-model-tier' README.md install.sh` 가 **양쪽 다** 걸려야 한다.
      `install.sh` 의 복사 대상과 설치 확인, `README.md` 의 "방법 2 — 손으로" 복사 명령과
      "설치 확인" 절, "이름이 겹칠 수 있는 파일" 목록에 모두 있어야 한다.
- [x] 12.17 **세 문서의 순서 문구가 여전히 일치하는지** 확인한다 (9.2 와 같은 방식).
      `grep -n 'preparer' CLAUDE.md README.md .claude/skills/orchestra/SKILL.md` 결과에서
      `preparer` 다음이 `designer` 이고 사이에 `analyzer` 가 없는지 본다.
      **요구사항 1 의 결과를 흔들지 않았는지 보는 관문이다.**
- [x] 12.18 **마크다운 무결성**을 다시 확인한다. 이번 묶음에서 만진 모든 `.md`
      (`CLAUDE.md`, `README.md`, `verification.md`, changeRoot 의 계획 문서들)에 대해
      `grep -c 'ORCA_RICH_MD'` 가 0 이고, 백틱 3개로 시작하는 줄의 개수가 짝수인지 본다.
      실측된 마지막 줄 수와 펜스 수를 참고선으로 쓴다: `orchestra` 456(펜스 30),
      `agent-model-tier` 136(펜스 4), `README` 253(펜스 14), `CLAUDE.md` 23(펜스 0),
      `verification.md` 604(펜스 40) — `README` 와 `verification.md` 는 이번에 늘어난다.
- [x] 12.19 **`switch_skill` 흔적이 없고 `install.sh` 안내는 있는지** 확인한다
      (9.9 가 정반대로 뒤집힌 자리다). 필터가 새지 않는 형태를 쓴다:
      ```bash
      grep -rn 'switch_skill\|sdd-switch' . --include='*.md' --include='*.sh' --include='*.json' | grep -vE '^(\./)?openspec/'
      ```
      합격: **아무것도 나오지 않는다** (`openspec/` 아래 계획 문서는 이력으로 언급하므로
      제외한다). 그리고 `ls -l install.sh` 가 실행 비트와 함께 있고,
      `grep -n 'install.sh' README.md` 가 걸린다.
- [x] 12.20 **에이전트 파일 7개가 손대지지 않았는지** 다시 확인한다.
      `git diff --stat -- .claude/agents/` 에 아무것도 없어야 한다. `model:` 줄도 그대로다.
- [x] 12.21 **`openspec/config.yaml` 과 메인 spec 을 확인한다 (고칠 필요가 없음을 확인하는
      작업이다).** `openspec/config.yaml` 의 `context` 와 메인 spec
      `openspec/specs/agent-instructions/project-context-completeness/spec.md` 가 검증 수단으로
      `bash -n install.sh` / `bash install.sh --dry-run` 을 적고 있다. `install.sh` 가
      되살아나므로 **그 문장은 참 그대로다.**
      검증: `grep -n 'install.sh' openspec/config.yaml openspec/specs/agent-instructions/project-context-completeness/spec.md`
      가 걸리고, `ls install.sh` 가 성공한다. **둘 중 어느 파일도 고치지 않는다.**
      만약 어긋난 서술을 발견하면 고치지 말고 보고서에 적어라 (메인 spec 은 finalizer 몫이다).
- [x] 12.22 **openspec CLI 실측.** 종료코드로 판정한다. 파이프를 붙이지 않는다
      (파이프를 붙이면 종료코드가 파이프 끝 명령의 것으로 바뀐다).
      `openspec validate` 는 `--change` 를 받지 않으니 **위치 인자**로 준다:
      ```bash
      openspec validate "make-analyzer-opt-in-and-add-install-skill" --strict; echo "exit=$?"
      openspec status --change "make-analyzer-opt-in-and-add-install-skill" --json >/dev/null; echo "metadata exit=$?"
      ```
      합격: 둘 다 `exit=0`. `metadata exit` 이 0 이 아니면
      `cat openspec/changes/make-analyzer-opt-in-and-add-install-skill/.openspec.yaml` 로 파일을
      직접 열어 `schema:` 와 `created:` 두 키가 살아 있는지 본다.
      **이번 change 는 `.openspec.yaml` 에 `retire_capabilities` 를 넣지 않는다**
      (`decision.md` 결정 7 — 지울 메인 spec 이 없다). 그 파일을 건드리지 마라.
