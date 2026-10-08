<!--
채택안: analyzer 생략 — 방안 비교 없이 proposal.md의 받아들일 조건이 그대로 기준이다
(decision.md 없음).

핵심 결정 (design.md 참고):
- 매핑은 사용자 확정값 그대로: 1=lower(전부 haiku), 2=semi-lower, 4=normal(기본값),
  3·5는 미정. 표 열 순서는 오름차순(1/5 → 2/5 → 4/5)으로 정렬한다.
- 3과 5는 표에 빈 칸/열로 넣지 않는다. 표 바로 아래 문장 하나로만 "아직 정의 안 됨"을 적는다
  — "지금 등급 확인" 절차의 정확한 표 전체 대조 로직을 그대로 보존하기 위해서다. 이 로직
  자체(파일 읽기 → 세 표와 대조 → 안 맞으면 "섞인 상태")는 절대 느슨하게 바꾸지 않는다.
- 하위 호환 없음: 숫자(`1`/`2`/`4`) 외의 입력(문자열 이름, `3`, `5` 포함)은 적용하지 않고
  거부 안내만 한다.
- `.claude/agents/*.md` 7개는 건드리지 않는다 — 실제 model: 값과 적용 로직 불변, 이름표만
  숫자로 바뀐다. `.claude/commands/`에는 `/agent-model-tier` 슬래시 명령 파일이 없다(확인함,
  건드릴 파일 아님).
- main spec(`openspec/specs/distribution/agent-model-tier/spec.md`) 직접 수정은
  finalizer 몫이다. 여기 tasks는 specs 델타(이미 작성됨)와 SKILL.md·README.md만 다룬다.
-->

## 1. SKILL.md — 등급 이름을 숫자로 교체

- [x] 1.1 frontmatter `description:` (3번째 줄)의 발동 신호 문구를 숫자로 바꾼다:
      `"semi-lower로"` → `"2로"`, `"lower로"` → `"1로"`, `"normal로 되돌려"` →
      `"4로 되돌려"`. `"모델 낮춰"`, `"토큰 아껴"`, `"지금 모델 등급 뭐야"`는 그대로 둔다.
      확인: `grep -n '^description:' .claude/skills/agent-model-tier/SKILL.md`로 새 문구가
      들어갔는지 눈으로 본다.
- [x] 1.2 본문 9번째 줄 "원래 등급(`normal`)으로 되돌아올 수 있다"를
      "원래 등급(`4/5`, 기본값)으로 되돌아올 수 있다"로 바꾼다.
- [x] 1.3 "## 등급 표" 절의 표 헤더를 `normal (원래 값)` / `semi-lower` / `lower`에서
      `1/5` / `2/5` / `4/5 (기본값)` 순서(오름차순)로 바꾼다. 행 순서(에이전트 7개)와 각
      칸의 모델 값(opus/sonnet/haiku)은 그대로 두고 **열 순서만 뒤집는다** — 기존
      `normal(1열)/semi-lower(2열)/lower(3열)`이 새로 `1/5(1열)/2/5(2열)/4/5(3열)`가
      되므로 각 칸의 실제 값도 열 순서를 따라 옮겨 적어야 한다(design.md의 새 표를 그대로
      옮기면 된다).
- [x] 1.4 표 바로 위 설명 "세 등급이 있다. 값은 이 표에 그대로 박혀 있다..." 문단에서
      `normal` 언급을 `4/5`로 바꾸고, 표 바로 아래에 "`3`과 `5`는 나중 등급 확장을 위해
      비워 둔다 — 지금은 정의되어 있지 않다"는 문장을 한 줄 추가한다(표에 빈 칸/열을
      추가하지 않는다).
- [x] 1.5 "규칙은 기계적이다" 문단에서 `semi-lower`는 특정 역할을 특별 취급하지 않는다는
      서술을 `2/5`로, "`normal`에서 opus였던 셋이 sonnet으로... `lower`는 ... 바닥값인
      haiku로"를 `4/5`/`1/5`로 바꾼다.
- [x] 1.6 "## 등급 적용" 절 1번째 줄 "사용자가 고른 등급(`normal` / `semi-lower` /
      `lower`)이 정해지면"을 "사용자가 고른 등급(`4` / `2` / `1`)이 정해지면"으로 바꾼다.
- [x] 1.7 "## 등급 적용" 절에 정의되지 않은 입력을 거부하는 단계를 새로 추가한다(기존
      1번 단계 앞에 새 0번 또는 새 1번으로 넣고 나머지 번호를 하나씩 민다): "입력이 `1`,
      `2`, `4` 중 하나가 아니면(문자열 이름, `3`, `5` 포함) 아무 파일도 건드리지 않고
      지금 쓸 수 있는 값이 `1`/`2`/`4`뿐이라고 알리고 멈춘다." (spec 델타의 "정의되지 않은
      입력을 거부한다" 시나리오에 대응)
- [x] 1.8 "## 낮추면 무엇이 나빠지는가" 절 도입부 "`lower`나 `semi-lower`를 적용하기
      전에"를 "`1`이나 `2`를 적용하기 전에"로 바꾸고, 목록 4번 항목의 "이 스킬로 `normal`을
      적용한다. `normal` 표가..."를 "이 스킬로 `4`를 적용한다. `4/5` 표가..."로 바꾼다.
- [x] 1.9 "## 지금 등급 확인"과 "## 바꾼 뒤 확인" 두 절은 리터럴 등급 이름을 쓰지 않으므로
      **손대지 않는다** — 이 change가 가장 지켜야 할 정확한 표 전체 대조 로직이 이 두 절에
      있다. 수정 후 이 두 절의 문장이 하나도 안 바뀌었는지 `git diff -- .claude/skills/
      agent-model-tier/SKILL.md`로 확인한다.
- [x] 1.10 수정을 마친 뒤 `grep -nE '\bnormal\b|semi-lower|\blower\b'
      .claude/skills/agent-model-tier/SKILL.md`를 돌려 리터럴 등급 이름이 하나도 안
      남았는지 확인한다(결과 0건이어야 한다).

## 2. README.md — 231번째 줄 갱신

- [x] 2.1 231번째 줄 "`agent-model-tier` 스킬로 `normal` / `semi-lower` / `lower` 세
      등급을 한 번에 갈 수 있다"를 "`agent-model-tier` 스킬로 `1` / `2` / `4` 세 등급을
      한 번에 갈 수 있다"로 바꾼다(Edit 부분 수정).
- [x] 2.2 `grep -nE '\bnormal\b|semi-lower|\blower\b' README.md`로 리터럴 등급 이름이
      더 없는지 확인한다(결과 0건이어야 한다). 190~200번째 줄 근처 "7개 서브에이전트" 표의
      `opus`/`sonnet`처럼 등급 이름이 아닌 모델 값 서술은 원래부터 대상이 아니므로 그대로
      둔다.

## 3. 범위 밖 확인 — 손대지 않아야 할 파일

- [x] 3.1 `.claude/agents/*.md` 7개가 이번 작업으로 하나도 바뀌지 않았는지
      `git status --short .claude/agents/`로 확인한다(로컬 등급 수정 상태가 이 change와
      무관하게 그대로 있어야 한다).
- [x] 3.2 `.claude/skills/init-sdd/SKILL.md`, `openspec/specs/distribution/
      sdd-install-script/spec.md`, `openspec/specs/distribution/init-sdd-skill/spec.md`
      세 파일이 바뀌지 않았는지 확인한다 — 이 파일들은 `agent-model-tier`라는 스킬 **이름**만
      언급하고 등급 **값**은 언급하지 않으므로 손댈 대상이 아니다.

## 4. 검증

- [x] 4.1 `bash -n install.sh`로 문법 검사(변경 없더라도 저장소 규칙상 통과 확인)를 하고,
      `install.sh`가 `agent-model-tier` 관련 문구를 담고 있다면 그 문구에 등급 이름 리터럴이
      없는지 `grep -nE '\bnormal\b|semi-lower|\blower\b' install.sh`로 확인한다.
- [x] 4.2 `openspec validate "numeric-model-tier" --strict; echo "exit=$?"`를 돌려
      종료코드가 0인지 확인한다(파이프 금지, 종료코드로만 판정).
- [x] 4.3 `openspec status --change "numeric-model-tier" --json >/dev/null; echo
      "metadata exit=$?"`로 메타데이터가 온전한지 확인한다.
- [x] 4.4 SKILL.md와 README.md 두 파일의 `git diff`를 읽고, frontmatter(`---` 두 줄과
      `name:`/`description:`)가 SKILL.md에서 온전한지, 코드펜스(```) 개수가 두 파일 모두
      짝수인지 눈으로 확인한다.
