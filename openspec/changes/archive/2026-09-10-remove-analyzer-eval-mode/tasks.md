<!--
채택안: 모드 분기를 없애고, "입력에 사용자 후보가 있으면 그것도 안 하나로 포함해 같은
형식으로 평가한다"는 문장 하나로 흡수한다. (decision.md)

핵심 결정 3가지:
1. analyzer.md에서 모드 개념을 완전히 제거하고, 사용자 후보 처리는
   `### 3. 방안 최소 3가지 만들기` 안의 짧은 규칙 4줄로 흡수한다.
2. orchestra/SKILL.md의 안전장치 절은 지우지 않는다. 호출 형태만 평소 호출로 바꾼다.
   "검증 안 된 안을 설계하면 worker가 벽에 부딪힌다"는 근거 문장은 그대로 남긴다.
3. 대상 파일은 전부 Edit로 부분 수정한다. Write 전체 재작성은 금지
   (리치 마크다운 편집기 손상 사고가 실제로 있었다).
-->

## 1. 기준선 확보

- [x] 1.1 `grep -c 'ORCA_RICH_MD' .claude/agents/analyzer.md .claude/skills/orchestra/SKILL.md docs/example-run.md` 를 실행하고, 세 파일 모두 `0`임을 확인해 결과를 기록한다
- [x] 1.2 `for f in .claude/agents/analyzer.md .claude/skills/orchestra/SKILL.md docs/example-run.md; do echo "$f $(grep -c '^\`\`\`' $f)"; done` 를 실행하고, 각각 `4` / `28` / `24` 인지 확인해 기록한다 (편집 후 같은 값이어야 한다)
- [x] 1.3 `cp docs/example-run.md /tmp/example-run.md.bak` 로 사본을 남긴다 — 이 파일은 `.git/info/exclude` 로 git 추적 제외라 되돌리기가 git으로 안 된다. 사본이 만들어졌는지 `ls -l /tmp/example-run.md.bak` 로 확인한다
- [x] 1.4 `grep -n '평가 모드\|평가할 안\|feasible=' .claude/agents/analyzer.md .claude/skills/orchestra/SKILL.md docs/example-run.md README.md` 를 실행해 남아 있는 위치 목록을 기록한다 (작업 5.1에서 이 목록이 비는지 대조한다)

## 2. `.claude/agents/analyzer.md` 수정 (전부 Edit 도구로. Write 금지)

**아래 항목은 편집할 때마다 줄 번호가 밀린다. 매번 `grep -n` 으로 위치를 다시 확인하고
앵커 문자열로 찾아라. 줄 번호를 그대로 믿지 마라.**

- [x] 2.1 frontmatter `description`(3줄)에서 `사용자가 낸 안을 평가하는 일도 한다. ` 한 문장만 지운다. 앞뒤 문장(`...보고한다.` / `코드베이스 탐색/검색도...`)은 그대로 둔다. `grep -n 'description:' .claude/agents/analyzer.md` 로 한 줄짜리 `description:` 이 그대로 남아 있는지 확인한다
- [x] 2.2 `## 두 가지 모드` 절을 통째로 지운다. `## 두 가지 모드` 헤더부터 `아래 "사용자 안 평가"로 간다.` 줄까지, 그리고 그 절 뒤의 남는 빈 줄 하나까지 정리한다. 바로 앞(`...Bash로도 바꾸지 마라...`)과 바로 뒤(`## 쓰는 스킬`) 사이에 빈 줄이 정확히 하나 남는지 확인한다
- [x] 2.3 (설계 D5의 `S1`) 블록인용 `> **스킬을 못 부른다는 이유로 절대 멈추지 마라.**` **뒤에** 떠 있는 들여쓴 문장 `  (specs 델타가 어떤 형태여야 하는지 알면 실현 가능한 방안을 낼 수 있다)` 를 지우고, 같은 문장을 `- 기준을 정확히 알아야 할 때는 \`.claude/skills/openspec-propose/SKILL.md\`를 Read로 읽어라.` 항목 **바로 아래 줄**로 옮긴다 (들여쓰기 2칸 유지). 옮긴 뒤 블록인용과 `### 대화형 스킬을 만났을 때 (중요)` 사이에 뜬 문장이 없는지 확인한다
- [x] 2.4 `### 3. 방안 최소 3가지 만들기` 안, `- **코드가 아예 없는 프로젝트면 축이 다르다.**` 로 시작하는 항목 **다음**이자 `- 각 안마다 반드시:` **앞**에 design.md D2에 적힌 네 줄을 그대로 넣는다. `grep -n '사용자가 낸 후보가 함께 오면' .claude/agents/analyzer.md` 로 한 곳에만 들어갔는지 확인한다
- [x] 2.5 `## 사용자 안 평가 (프롬프트에 \`평가할 안:\`이 있을 때)` 절을 통째로 지운다. 헤더부터 `6. 기존 추천과 비교해서 의견을 다시 낸다.` 줄까지, 그리고 남는 빈 줄을 정리한다. 바로 앞(`### 5. 분석 노트 남기기` 절 끝)과 `## 하지 말아야 할 것` 사이에 빈 줄이 정확히 하나 남는지 확인한다
- [x] 2.6 `RESULT: 분석완료 | ...` 줄에서 ` | feasible=<평가 모드일 때만: 예/부분/아니오>` 조각만 지워 `RESULT: 분석완료 | change=<이름> | options=<개수> | recommend=<N안> | questions=<개수>` 로 만든다. 파이프 구분자가 겹치거나(`||`) 줄 끝에 남지 않는지 눈으로 확인한다
- [x] 2.7 `grep -n '평가 모드\|평가할 안\|feasible=\|두 가지 모드\|사용자 안 평가' .claude/agents/analyzer.md` 를 실행해 **결과가 하나도 없음**(exit=1)을 확인한다

## 3. `.claude/skills/orchestra/SKILL.md` 수정 (Edit 도구로. Write 금지)

- [x] 3.1 파이프라인 그림에서 `   ↓    사용자가 자기 안을 내면 → analyzer 재호출(평가 모드) → 다시 고르게 한다` 를 `   ↓    사용자가 자기 안을 내면 → 그 안을 후보로 얹어 analyzer 재호출 → 다시 고르게 한다` 로 바꾼다. 앞의 `   ↓    ` 들여쓰기를 그대로 유지하고, 그림을 감싼 코드펜스가 그대로인지 확인한다
- [x] 3.2 `### 사용자가 목록에 없는 자기 안을 냈을 때` 절에서 `analyzer를 **평가 모드로 다시 부른다:**` 를 `analyzer를 **다시 부르되, 그 안을 추가 후보로 얹어 보낸다:**` 로 바꾼다
- [x] 3.3 같은 절의 `Agent(subagent_type: "analyzer", ...)` 예시 한 줄을, `## 2. analyzer 호출` 의 예시와 같은 구성(`change 이름` / `store` / `브랜치` / `preparer가 확정한 것`)에 `\n사용자가 낸 안: <사용자가 말한 내용 그대로>` 한 줄을 더한 형태로 바꾼다. 지시문은 "요구사항과 현재 코드베이스를 분석하고 방안을 최소 3가지 제시하라. 사용자가 낸 안도 안 하나로 넣어 같은 형식으로 평가하고, 기존 안 뒤에 번호를 이어 붙여라." 로 한다. 예시가 **한 줄**이고 코드펜스 안에 들어 있는지 확인한다
- [x] 3.4 같은 절에서 **지우지 않았는지 확인한다**: `바로 designer로 가지 마라. **검증 안 된 안을 설계하면 worker가 벽에 부딪힌다.**` 문장, `- 결과를 보여주고 **다시 고르게 한다.**` 불릿, `analyzer가 "성립하지 않는다"고 하면...` 불릿. `grep -n '벽에 부딪힌다\|성립하지 않는다' .claude/skills/orchestra/SKILL.md` 로 확인한다
- [x] 3.5 `grep -n '평가 모드\|평가할 안' .claude/skills/orchestra/SKILL.md` 를 실행해 **결과가 하나도 없음**(exit=1)을 확인한다

## 4. `docs/example-run.md` 수정 (Edit 도구로. Write 금지)

- [x] 4.1 `목록에 없는 자기 안을 내도 된다. 그러면 analyzer가 **평가 모드**로 다시 돌아서` / `그 안이 실제로 성립하는지 코드로 확인하고, 안 되면 안 된다고 말한다.` 두 줄을, `목록에 없는 자기 안을 내도 된다. 그러면 그 안을 **후보 하나로 얹어 analyzer를 다시 부른다.**` / `analyzer는 그 안이 실제로 성립하는지 코드로 확인하고, 안 되면 안 된다고 말한다.` 로 바꾼다
- [x] 4.2 `grep -n '평가 모드' docs/example-run.md` 를 실행해 **결과가 하나도 없음**(exit=1)을 확인한다

## 5. 대조 검증

- [x] 5.1 `grep -rn '평가 모드\|평가할 안\|feasible=' .claude README.md docs/example-run.md` 를 실행해 결과가 하나도 없음을 확인한다. `docs/verification-2026-09-08.md` 와 `openspec/changes/` 는 대상이 아니다 (과거 기록 / 계획 문서라 손대지 않는다)
- [x] 5.2 `README.md` 를 읽고 analyzer가 별도 평가 모드를 가진다는 취지의 문구가 새로 생기지 않았음을 확인한다. **README.md 는 수정하지 않는다** — 확인만 한다
- [x] 5.3 `grep -c 'ORCA_RICH_MD' .claude/agents/analyzer.md .claude/skills/orchestra/SKILL.md docs/example-run.md` 가 세 파일 모두 `0` 인지 확인한다 (1.1의 기준선과 같아야 한다)
- [x] 5.4 세 파일의 코드펜스 개수(`grep -c '^\`\`\`'`)가 1.2에서 기록한 `4` / `28` / `24` 와 **같은지** 확인한다. 다르면 편집이 코드펜스를 깨뜨린 것이니 되돌린다
- [x] 5.5 `head -8 .claude/agents/analyzer.md` 로 frontmatter가 `---` 로 열리고 닫히며 `name:`, `description:`, `model:`, `tools:` 키가 모두 살아 있는지 확인한다
- [x] 5.6 `.claude/agents/analyzer.md` 전문을 읽고 design.md D5 "남기기로 한 것" 표의 항목이 **전부 그대로 남아 있는지** 대조한다 (경로를 CLI에서 얻으라는 지시 / 관찰과 추측 구분 / 스택 혼자 정하지 말 것 / analysis.md 맨 위 경고 줄 / 코드 수정 금지 / 보고 형식)
- [x] 5.7 analyzer.md의 새 규칙("프롬프트에 사용자가 낸 후보가 함께 오면")과 orchestra 새 호출 예시의 키(`사용자가 낸 안:`)가 서로 **맞물리는지** 두 파일을 나란히 읽어 확인한다. 한쪽만 고쳐지면 안전장치가 조용히 끊긴다

## 6. 회귀·최종 확인

- [x] 6.1 `bash -n install.sh; echo "exit=$?"` 가 `exit=0` 인지 확인한다 (이 change는 install.sh를 건드리지 않는다. 회귀 없음을 보이는 표준 확인 수단이다)
- [x] 6.2 `bash install.sh --dry-run; echo "exit=$?"` 가 `exit=0` 인지 확인한다
- [x] 6.3 `openspec validate "remove-analyzer-eval-mode" --strict; echo "exit=$?"` 가 `exit=0` 인지 확인한다 (파이프를 붙이지 마라 — 종료코드가 바뀐다)
- [x] 6.4 `openspec status --change "remove-analyzer-eval-mode" --json >/dev/null; echo "metadata exit=$?"` 가 `exit=0` 인지 확인한다
- [x] 6.5 `git diff --stat` 으로 수정된 파일이 `.claude/agents/analyzer.md` 와 `.claude/skills/orchestra/SKILL.md` 둘뿐인지 확인한다 (`docs/` 는 추적 제외라 안 보이는 게 정상이고, `openspec/changes/` 신규 파일은 `git status` 에 잡힌다). `README.md` 나 다른 에이전트 파일이 들어 있으면 되돌린다
- [x] 6.6 이 change에서 제거한 문장을 **전부 목록으로** 보고서에 남긴다 (2.1의 description 문구, 2.2의 `## 두 가지 모드` 절 전체, 2.5의 `## 사용자 안 평가` 절 전체, 2.6의 `feasible=` 필드). reviewer가 "이거 왜 없어졌지"를 대조할 수 있어야 한다

## 재작업

- [x] R1 `.claude/agents/analyzer.md`의 사용자 후보 규칙(`### 3. 방안 최소 3가지 만들기` 안,
  "프롬프트에 사용자가 낸 후보가 함께 오면..." 4줄) 뒤에, 사용자 후보가 부분만 성립할 때
  다듬은 변형안을 하나 더 제시한다는 한 줄을 덧붙인다. `orchestra/SKILL.md:191`의
  "다듬은 변형안이나 기존 안으로 다시 고르게 한다" 지시와 짝을 맞춘다.
