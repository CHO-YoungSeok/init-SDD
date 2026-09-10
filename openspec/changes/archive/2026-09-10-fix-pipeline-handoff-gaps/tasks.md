> **채택안**: 방안 비교 없음 (`analyzer 생략: 예`). 8건 모두 실측으로 고칠 형태가 확정돼 있어
> 오케스트레이터가 형태를 그대로 지정했다. 전체 배경과 답변 3개는 `decision.md`,
> 확정 문구와 이유는 `design.md`에 있다. **두 파일을 먼저 읽어라.**
>
> **핵심 결정 3줄**
> 1. **작업은 파일별로 묶었다.** 한 파일 = 한 묶음(2~8절). 묶음끼리 파일이 겹치지 않아
>    병렬 worker에게 절 단위로 나눠 줄 수 있다. 1절(기준선)과 9절(검증)만 순서가 고정이다.
> 2. **8개 대상 파일에 `Write`(전체 재작성)와 `sed -i`는 금지다. `Edit` 부분 수정만 쓴다.**
>    이번 세션에 전체 재작성으로 마크다운이 망가진 사고가 실제로 있었다.
> 3. **`.claude/skills/orchestra/SKILL.md`와 `docs/example-run.md`는 절대 건드리지 마라.**
>    `remove-analyzer-eval-mode` 소관이고 이번 8건과 관계없다. 열어서 고칠 판단조차 하지 마라.
>
> **2026-09-09 범위 변경 (2가지 — 자세한 건 `decision.md` 맨 아래 "범위 변경" 절)**
> - `.claude/agents/analyzer.md`가 **범위 안으로 들어왔다** (7개 → 8개 파일).
>   막고 있던 `remove-analyzer-eval-mode`가 끝나 커밋(`6946374`)되어 충돌이 사라졌다.
>   **10절이 그 작업이다. 아직 안 했으면 그것부터 해라.**
> - `proposal.md`의 받아들일 조건 7번을 설계(D3 = 틀린 근거를 **지운다**)에 맞춰 고쳤다.
>   **7.1이 시킨 대로 삭제한 게 맞다.** 되돌리지 마라.

## 1. 변경 전 기준선 기록 (가장 먼저 — 나중 검증의 대조군이다)

- [x] 1.1 `decision.md`와 `design.md`를 처음부터 끝까지 읽는다. `design.md`의 D2(F2 확정 문구)와
      D4(config.yaml 확정 내용)는 **글자 그대로 옮겨 쓸 원본**이다. 확인: 두 블록의 내용을
      보고서에 한 줄로 요약해 적을 수 있다.
- [x] 1.2 대상 7개 파일의 기준선을 재서 보고서에 기록한다.
      ```bash
      cd /Users/0stone_1004/orca/projects/init-SDD
      for f in .claude/agents/preparer.md .claude/agents/designer.md .claude/agents/worker.md \
               .claude/agents/reviewer.md .claude/agents/regression-verifier.md \
               .claude/agents/finalizer.md openspec/config.yaml; do
        echo "$f | fence=$(grep -c '^```' "$f") | orca=$(grep -c 'ORCA_RICH_MD' "$f")"
      done
      ```
      확인: 예상값과 일치한다 — fence는 preparer 16 / designer 10 / worker 6 / reviewer 8 /
      regression-verifier 6 / finalizer 10 / config.yaml 0 (**전부 짝수**), orca는 전부 0.
      다르면 멈추고 보고한다.
- [x] 1.3 F3의 "변경 전" 상태를 확인해 기록한다.
      ```bash
      openspec instructions proposal --change "fix-pipeline-handoff-gaps" --json | grep -c '"context"'
      ```
      확인: 지금은 `0`이 나온다 (context 키가 없다). 8절 이후에 `1` 이상으로 바뀌어야 한다.

## 2. `.claude/agents/worker.md` — L1 + F2

- [x] 2.1 정식 모드 1단계(현재 `.claude/agents/worker.md:76` 부근, `- \`state: "blocked"\`` 로
      시작하는 항목)를 `Edit`로 고쳐, `blocked`를 `missingArtifacts` 유무로 두 갈래로 나눠
      보고하게 한다. **`missingArtifacts`에 값이 있으면** 진짜 산출물 누락 — 지금 문구 그대로.
      **비어 있으면**(실측 응답: `tasks: []`, `progress.total: 0`) 파일은 있는데 체크박스가
      하나도 없는 것이므로 **"작업 목록에 체크박스가 없다"로 정확히 보고한다**. 이때
      "산출물 누락"으로 보고하면 designer가 "이미 다 있다"고 답해 무한 왕복이 된다는 이유도 적는다.
      기존 `design.md: 없음(의도적)` 예외 규칙과 `openspec-continue-change` 안내 문단은 그대로 둔다.
      확인: `grep -c 'missingArtifacts' .claude/agents/worker.md` 가 2 이상이고,
      `grep -n '체크박스가 없다' .claude/agents/worker.md` 가 결과를 낸다.
- [x] 2.2 `.claude/agents/worker.md:32-35`의 블록인용 4줄을 `design.md` D2의 확정 문구
      6줄로 `Edit` 교체한다. 앞뒤 빈 줄은 그대로 둔다.
      확인: `grep -c 'Skill\` 도구가 없을 수 있다' .claude/agents/worker.md` 가 0,
      `grep -c 'allowed-tools' .claude/agents/worker.md` 가 1 이상,
      `grep -c '스킬을 못 부른다는 이유로 절대 멈추지 마라' .claude/agents/worker.md` 가 1 이상.

## 3. `.claude/agents/preparer.md` — L2 + F2

- [x] 3.1 "보고 형식" 절(현재 `.claude/agents/preparer.md:204`)의 중단 RESULT 줄을 `Edit`로
      `RESULT: 준비중단 | change=none | branch=<만든 브랜치 또는 none> | reason=<이름충돌/미커밋변경/초기커밋없음/기타> | questions=<개수>`
      로 고친다. 확인: `grep -n 'branch=' .claude/agents/preparer.md` 에 준비중단 줄이 포함된다.
- [x] 3.2 같은 자리 바로 아래(또는 브랜치를 만드는 4단계 설명)에 이 필드가 왜 필요한지
      **한 줄 근거**를 `Edit`로 넣는다: 브랜치(4단계)를 change(5단계)보다 먼저 만들기 때문에
      이름 충돌(`Error: Change '...' already exists`)로 5단계에서 멈추면 브랜치만 남고,
      이 필드가 없으면 오케스트레이터가 그 존재를 모른다.
      확인: `grep -n '브랜치만' .claude/agents/preparer.md` 가 결과를 낸다.
- [x] 3.3 `.claude/agents/preparer.md:31-34`의 블록인용 4줄을 `design.md` D2의 확정 문구로
      `Edit` 교체한다. 확인: 2.2와 같은 grep 3종이 preparer.md에 대해 통과한다.

## 4. `.claude/agents/designer.md` — L5(채택안 없음) + L9 + F2

- [x] 4.1 "보고 형식" 절(현재 `.claude/agents/designer.md:249`)의 중단 RESULT 줄 `reason=` 목록에
      `채택안 없음`을 `Edit`로 추가한다 (`reason=<고른 안이 성립하지 않음/채택안 없음/기타>`).
      확인: `grep -n '채택안 없음' .claude/agents/designer.md` 가 결과를 낸다.
- [x] 4.2 "반드시 지킬 것" 절에 멈추는 조건을 `Edit`로 추가한다: 프롬프트에 `사용자가 고른 안:`도
      `analyzer 생략: 예`도 **둘 다 없으면** 설계를 시작하지 말고
      `RESULT: 설계중단 | change=<이름> | reason=채택안 없음`으로 멈춘다. **둘 중 하나만 있으면
      정상 진행이다**(버그 수정 경로는 `analyzer 생략: 예`로 정당하게 채택안이 없다)는 것과,
      `analysis.md`의 추천안을 사용자의 선택으로 대체하면 ★방안 선택 관문이 증발한다는 이유도 적는다.
      확인: `grep -n '둘 다 없으면' .claude/agents/designer.md` 가 결과를 낸다.
- [x] 4.3 "### 1. 입력 다시 읽기" 절(현재 `.claude/agents/designer.md:70` 부근, `읽을 것 (모두
      디스크에서):` 목록 앞)에 우선순위 규칙을 `Edit`로 넣는다: **프롬프트에 실려 온 숫자·표·인용과
      `analysis.md`의 내용이 다르면 파일이 맞다.** 보고서는 파일을 손으로 옮겨 적은 요약이라
      옮기다 틀릴 수 있다. 기준선 숫자처럼 설계가 기대는 값은 반드시 `analysis.md`에서 다시 읽고,
      다르면 그 사실을 보고서에 적는다. `finalizer.md`에 같은 취지의 방어가 이미 있다는 점도 적는다.
      확인: `grep -n '파일이 맞다' .claude/agents/designer.md` 가 결과를 낸다.
- [x] 4.4 `.claude/agents/designer.md:44-47`의 블록인용 4줄을 `design.md` D2의 확정 문구로
      `Edit` 교체한다. 확인: 2.2와 같은 grep 3종이 designer.md에 대해 통과한다.

## 5. `.claude/agents/reviewer.md` — L4 + L5(만진 파일 없음)

- [x] 5.1 "### 1. 기준을 먼저 읽는다"의 `artifactPaths.specs.existingOutputPaths` 항목
      (현재 `.claude/agents/reviewer.md:63-66`) 아래에 `skip_specs` 대체 기준을 `Edit`로 넣는다.
      바로 아래 `decision.md`가 없을 때의 대체 기준을 적어 둔 것과 **같은 방식**으로 쓴다:
      specs 산출물의 `status`(`status --json`의 `artifacts[]` 배열에 있다 —
      `artifactPaths.specs` 아래에는 **없다**, 실측)가 `skipped`이거나
      `artifactPaths.specs.existingOutputPaths`가 비어 있으면
      `skip_specs: true`인 change다. **이건 정상이고 반려 사유가 아니다.** 이때 기준은
      proposal의 받아들일 조건 + 작업 목록 머리말이다.
      확인: `grep -c 'skip_specs' .claude/agents/reviewer.md` 가 1 이상.
- [x] 5.2 "### 3. 실제 변경을 본다 — 범위를 좁혀서"(현재 `.claude/agents/reviewer.md:93-101`)에
      만진 파일 목록이 **없을 때**의 처리를 `Edit`로 추가한다: 멈추지 말고 전체 diff를 범위로 잡되
      "만진 파일 목록을 못 받아서 전체 diff를 범위로 삼았다. 다른 change의 변경이 섞였을 수 있다"를
      보고서에 한 줄로 적는다. 그 상태에서 발견한 "설계에 없는 변경"은 **막음으로 올리지 말고**
      기존 "이번 change 것인지 확인 필요한 변경" 절에 넣는다.
      확인: `grep -n '목록이 없으면' .claude/agents/reviewer.md` 가 결과를 낸다.
- [x] 5.3 "보고 형식"의 RESULT 줄(현재 `.claude/agents/reviewer.md:164-165`)에 `scope=` 표시를
      `Edit`로 추가하고, 만진 파일 목록을 못 받았을 때 `scope=전체diff`를 남기라고 적는다.
      **필드 이름은 `scope` 로 고정한다** (regression-verifier.md와 같아야 한다).
      확인: `grep -c 'scope=전체diff' .claude/agents/reviewer.md` 가 1 이상.

## 6. `.claude/agents/regression-verifier.md` — L5(만진 파일 없음)

- [x] 6.1 "### 1. 무엇이 바뀌었는지 파악"의 만진 파일 항목(현재
      `.claude/agents/regression-verifier.md:43-44`) 아래에 목록이 **없을 때**의 처리를 `Edit`로
      추가한다: 멈추지 말고 전체 diff를 범위로 잡되 그 사실을 보고서에 한 줄로 적는다.
      그 상태에서 원인을 가르지 못한 것은 막음이 아니라 4단계의 **"원인 구분 못 함"**에 넣는다.
      확인: `grep -n '목록이 없으면' .claude/agents/regression-verifier.md` 가 결과를 낸다.
- [x] 6.2 "보고 형식"의 RESULT 줄(현재 `.claude/agents/regression-verifier.md:104-105`)에
      `scope=` 표시를 `Edit`로 추가하고, 목록을 못 받았을 때 `scope=전체diff`를 남기라고 적는다.
      **reviewer.md와 글자 그대로 같은 필드 이름을 쓴다.**
      확인: `grep -c 'scope=전체diff' .claude/agents/regression-verifier.md` 가 1 이상.

## 7. `.claude/agents/finalizer.md` — F1 + F2

- [x] 7.1 "### 5. archive"의 "이유:" 목록 3항목(현재 `.claude/agents/finalizer.md:210-215`)을
      `Edit`로 2항목으로 바꾼다. 순서는 **되돌릴 수 없음 → stdin**:
      ① `openspec archive`는 change 디렉터리를 옮긴다. **되돌릴 수 없다. 그래서 사용자가 정한다.**
      ② `--yes` 없이 돌리면 확인 프롬프트를 기다리다 실패한다
      (`Error: 1 incomplete task(s) found ... and no answer could be read from stdin.`).
      너에게는 stdin이 없다.
      **실측과 반대인 근거 2·3은 지운다** (남겨 두면 다음 사람이 그걸 믿고 잘못 판단한다).
      바로 아래 "→ **`openspec-archive-change` 절차 한 길로만 간다.** ..." 문단과 조사용 `bash`
      블록은 **그대로 둔다.**
      확인: `grep -c '이중 적용' .claude/agents/finalizer.md` 가 0,
      `grep -c '안전망이 아니다' .claude/agents/finalizer.md` 가 0,
      `grep -c 'stdin' .claude/agents/finalizer.md` 가 1 이상,
      `grep -c 'openspec-archive-change' .claude/agents/finalizer.md` 가 1 이상.
- [x] 7.2 `.claude/agents/finalizer.md:64-67`의 블록인용 4줄을 `design.md` D2의 확정 문구로
      `Edit` 교체한다. 확인: 2.2와 같은 grep 3종이 finalizer.md에 대해 통과한다.

## 8. `openspec/config.yaml` — F3 (이 저장소의 모든 openspec 명령에 영향을 주니 마지막에 한다)

- [x] 8.1 `design.md` D4의 확정 내용을 `openspec/config.yaml`에 `Edit`로 추가한다.
      넣을 자리는 "# Project context (optional)" 예시 주석 블록 **바로 다음**,
      "# Per-artifact rules (optional)" 주석 **앞**이다. **예시 주석은 지우지 말고 그대로 둔다.**
      **`context:` 키는 줄 맨 앞(0칸)에서 시작해야 한다.** 블록 스칼라(`|`) 내용만 2칸 들여쓴다.
      예시 주석에서 `#`만 지우는 방식으로 만들면 `   context: |`(3칸)가 되어 값이 무시된다 — 하지 마라.
      확인: `grep -n '^context:' openspec/config.yaml` 이 정확히 한 줄을 낸다.
- [x] 8.2 파싱 경고가 없는지 확인한다.
      ```bash
      openspec context 2>&1 | grep -c 'Warning'
      ```
      확인: `0`. (주의: 경고가 나도 종료코드는 0이라 통과처럼 보인다 — 반드시 문자열로 센다.)
- [x] 8.3 **진짜 증거**를 확인한다. `context` 키가 실제로 CLI 응답에 생겼는지 본다.
      ```bash
      openspec instructions proposal --change "fix-pipeline-handoff-gaps" --json \
        | python3 -c "import json,sys; d=json.load(sys.stdin); print('context key:', 'context' in d); print(d.get('context','<없음>')[:200])"
      ```
      확인: `context key: True` 이고 본문에 "지시문 저장소", "bash -n install.sh", "Edit 부분 수정"이
      보인다. 1.3에서 잰 `0`이 이제 바뀌었다. **8.2가 통과해도 여기서 실패할 수 있다. 둘 다 봐라.**

## 9. 전체 검증 (2~8절이 모두 끝난 뒤)

- [x] 9.1 **마크다운 무결성** — 1.2의 기준선과 대조한다. 같은 명령을 다시 돌린다.
      확인: 코드펜스 개수가 **기준선과 완전히 같고 전부 짝수**, `ORCA_RICH_MD` 개수가 전부 0.
      (`config.yaml`의 코드펜스는 0으로 유지)
- [x] 9.2 **frontmatter 무결성** — 6개 에이전트 파일의 머리 6줄이 온전한지 본다.
      ```bash
      cd /Users/0stone_1004/orca/projects/init-SDD
      for f in preparer designer worker reviewer regression-verifier finalizer; do
        echo "--- $f"; head -8 ".claude/agents/$f.md"
      done
      ```
      확인: 각 파일이 `---`로 시작하고 `name:`, `description:`, `model:`, `tools:` 가 있으며
      닫는 `---`가 있다. 하나라도 빠지면 그 에이전트가 등록되지 않는다.
- [x] 9.3 **F2 네 곳 대조** — 같은 문구가 네 파일에 똑같이 들어갔는지 본다.
      ```bash
      cd /Users/0stone_1004/orca/projects/init-SDD
      for f in preparer designer worker finalizer; do
        echo "$f | old=$(grep -c '도구가 없을 수 있다' .claude/agents/$f.md) | new=$(grep -c 'allowed-tools' .claude/agents/$f.md) | 결론=$(grep -c '절대 멈추지 마라' .claude/agents/$f.md)"
      done
      ```
      확인: 네 파일 모두 `old=0`, `new>=1`, `결론>=1`.
- [x] 9.4 **`scope` 필드 이름 일치** — reviewer.md와 regression-verifier.md가 같은 낱말을 쓰는지 본다.
      확인: 두 파일 모두 `grep -c 'scope=전체diff'` 가 1 이상이고, 다른 이름(`범위=`, `diff_scope=` 등)을
      쓰지 않는다.
- [x] 9.5 **회귀 확인** — 이 저장소에는 실행 가능한 테스트 스위트가 없어 표준 수단을 쓴다.
      ```bash
      bash -n install.sh; echo "exit=$?"
      ```
      확인: `exit=0`. (이번 change는 `install.sh`를 건드리지 않는다. 안 건드렸는데 실패하면
      다른 change 탓이므로 그렇게 보고한다.)
- [x] 9.6 **범위 밖 파일이 안 바뀌었는지 확인** — 이번 작업으로 금지 3개 파일을 건드리지 않았는지 본다.
      ```bash
      cd /Users/0stone_1004/orca/projects/init-SDD && git status --short
      ```
      확인: `.claude/agents/analyzer.md`, `.claude/skills/orchestra/SKILL.md`, `docs/example-run.md`가
      **이번 작업 때문에** 바뀌지 않았다. (다른 change가 이미 고쳐 둔 변경이 보일 수 있다 —
      그건 내 것이 아니므로 건드리지 말고 보고서에 "다른 change 것"으로 적는다.)
- [x] 9.7 **부분 수정만 했는지 확인** — 전체 재작성 사고가 없었는지 본다.
      ```bash
      cd /Users/0stone_1004/orca/projects/init-SDD && git diff --stat -- .claude/agents openspec/config.yaml
      ```
      확인: 각 파일의 변경 줄 수가 전체 줄 수에 비해 작다(수십 줄 규모). 한 파일이 통째로
      지워졌다 다시 쓰인 모양(예: `227 ++---...` 처럼 거의 전량)이면 `Write`나 `sed -i`가
      쓰인 것이므로 **멈추고 보고한다.**
- [x] 9.8 **OpenSpec 검증** — 종료코드로 판정한다. 파이프를 붙이지 마라.
      ```bash
      cd /Users/0stone_1004/orca/projects/init-SDD
      openspec validate "fix-pipeline-handoff-gaps" --strict; echo "exit=$?"
      openspec status --change "fix-pipeline-handoff-gaps" --json >/dev/null; echo "metadata exit=$?"
      ```
      확인: 둘 다 `exit=0`.
- [x] 9.9 **받아들일 조건 대조** — `proposal.md`의 "받아들일 조건" 11개를 하나씩 짚으며
      실제로 만족하는지 확인하고, 결과를 보고서에 항목별로 적는다.
      확인: 11개 모두 근거(grep 결과 또는 명령 출력)와 함께 통과로 적혀 있다.

## 10. `.claude/agents/analyzer.md` — F2 (2026-09-09 범위 추가)

이 절은 나중에 붙어서 번호가 9절(전체 검증) 뒤에 있다. **9절을 다시 돌릴 필요는 없다** —
`analyzer.md`를 새로 건드리면서 필요한 검증을 아래 확인 항목 안에 전부 넣어 뒀다.
확인 ①은 9.3(F2 네 곳 대조)을 **다섯 곳으로 확장한 것**이다.

- [x] 10.1 `.claude/agents/analyzer.md:31-34`의 옛 블록인용 4줄을, 이미 바뀐 네 파일의 6줄과
      **글자 단위로 같게** `Edit`로 교체한다. 옛 문구
      ("이 환경의 서브 에이전트에게는 `Skill` 도구가 없을 수 있다 (실측으로 확인됨)")는
      이 환경에서 **거짓이다** — 다섯 에이전트 전부 frontmatter `tools:` 줄에 `Skill`이 있다.
      **새로 타이핑하지 마라.** 손으로 옮겨 적으면 한 글자가 틀어져 md5가 어긋난다.
      `sed -n '32,37p' .claude/agents/worker.md` 로 원본 6줄을 떠서 그대로 붙인다.
      앞뒤 빈 줄과 들여쓰기는 원래대로 둔다. `analyzer.md`에도 `Write`와 `sed -i`는 금지다.

      확인 ① **(핵심)** — 다섯 파일의 그 6줄 블록 md5가 전부 같다:
      ```bash
      cd /Users/0stone_1004/orca/projects/init-SDD
      for f in preparer designer worker finalizer analyzer; do
        echo "$f $(grep '^> ' .claude/agents/$f.md | md5)"
      done
      ```
      다섯 줄 모두 `7111c996def6a259f004dd92f1ee1dec` 여야 한다. 하나라도 다르면 멈추고 보고한다.
      (`md5`가 없으면 `md5sum`을 쓴다. 그러면 값이 다르게 나오니 **다섯 값이 서로 같은지**만 본다.)
      이 명령이 성립하는 이유: 다섯 파일 모두 `^> ` 로 시작하는 블록인용이 이 한 곳뿐이다(실측).

      확인 ② — 옛 근거가 사라지고 새 근거·결론이 들어갔다:
      `grep -c '도구가 없을 수 있다' .claude/agents/analyzer.md` 가 0,
      `grep -c 'allowed-tools' .claude/agents/analyzer.md` 가 1 이상,
      `grep -c '절대 멈추지 마라' .claude/agents/analyzer.md` 가 1 이상.

      확인 ③ — `analyzer.md`가 안 망가졌다. 1.2의 기준선 명령을 `analyzer.md`에 대해 돌려서
      코드펜스 개수가 **4**(변경 전과 같고 짝수), `ORCA_RICH_MD` 개수가 **0** 인지 본다.
      `head -8 .claude/agents/analyzer.md` 의 frontmatter도 온전해야 한다.
      **주의: `analyzer.md`의 frontmatter는 다른 파일과 달리 `skills:` 줄이 하나 더 있다**
      (`---` / `name:` / `description:` / `model:` / `tools:` / `skills:` / `---`).
      9.2 기준으로 보면 줄이 하나 많은데 **그게 원래 모습이다. 지우지 마라.**

      확인 ④ — 범위 밖 파일은 그대로다. `git status --short` 에
      `.claude/skills/orchestra/SKILL.md` 와 `docs/example-run.md` 가 없다.
      `git diff --stat -- .claude/agents/analyzer.md` 의 변경 줄 수가 10줄 안팎이다
      (전량 재작성 모양이면 `Write`나 `sed -i`가 쓰인 것이므로 멈추고 보고한다).

      확인 ⑤ — 받아들일 조건 재대조. 9.9에서 짚은 11개 중 **7번(finalizer 틀린 근거 삭제)**,
      **8번(F2 다섯 파일 + md5 동일)**, **10번(8개 파일 Edit 부분 수정)** 세 개는 이번
      범위 변경으로 문구가 바뀌었다. 이 셋을 `proposal.md`에서 **다시 읽고** 근거와 함께
      보고서에 적는다. 나머지 8개는 9.9 결과를 그대로 쓴다.
