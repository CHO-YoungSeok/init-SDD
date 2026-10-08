## Context

이 change는 순수 문서 변경이다(코드도 런타임도 없다). `.claude/agents/*.md` 7개 파일의
실제 `model:` 값과 적용 로직(각 파일 한 줄만 Edit)은 이번에 건드리지 않는다 — 등급을
가리키는 **이름표만** 문자열(`normal`/`semi-lower`/`lower`)에서 숫자(`N/5`)로 바뀐다.
동기와 범위는 `proposal.md`를 본다.

손댈 파일 3개, 모두 preparer가 이미 실측했다:
1. `.claude/skills/agent-model-tier/SKILL.md` — 등급 이름이 나오는 모든 곳
2. `openspec/specs/distribution/agent-model-tier/spec.md` — 메인 spec (이 change의
   specs 델타가 정의한다, 병합은 finalizer)
3. `README.md` 231번째 줄 — `agent-model-tier` 스킬 소개 한 줄

`.claude/commands/` 아래에는 `/agent-model-tier`라는 슬래시 명령 파일이 없다(확인함:
`.claude/commands/`에는 `opsx/` 하위 6개 파일만 있고 이 스킬과 무관하다). `/agent-model-tier
<값>`은 슬래시 명령이 아니라 스킬의 자연어 발동 신호 예시일 뿐이다 — 손볼 파일이 하나
늘지 않는다.

`.claude/skills/init-sdd/SKILL.md`, `openspec/specs/distribution/sdd-install-script/spec.md`,
`openspec/specs/distribution/init-sdd-skill/spec.md` 세 파일도 `agent-model-tier`라는
**스킬 이름**을 언급하지만, `normal`/`semi-lower`/`lower` 같은 **등급 값**은 언급하지 않는다
(재확인함, grep 결과 0건). 손댈 대상이 아니다.

## Goals / Non-Goals

**Goals:**
- 등급을 가리키는 모든 표기를 문자열 이름에서 `N/5` 숫자로 바꾼다(발동 신호, 절차, 표,
  예시, 경고, 메인 spec 요구사항, README 안내문 전부).
- "지금 등급 확인" 절차의 **정확한 표 전체 대조** 방식(섞인 상태 판별)을 그대로 보존한다.
- 하위 호환 없이 숫자만 받는다는 것을 스킬 절차와 spec 양쪽에 반영한다.

**Non-Goals:**
- `.claude/agents/*.md` 7개의 실제 `model:` 값이나 적용 로직을 바꾸는 것 (이름표만 바뀜)
- `code-explorer`를 등급 표에 넣는 것 (여전히 표 밖, haiku 고정)
- `3`과 `5`에 실제 값을 채우는 것 (자리만 예약)

## Decisions

### 1. 매핑과 표 순서: 1 → 2 → 4 오름차순, 3·5는 빈칸 없이 문장으로만 예약

`1=lower(전부 haiku), 2=semi-lower, 4=normal(기본값), 3·5=미정`은 사용자가 이미 확정한
값이라 그대로 쓴다. 표의 **열 순서**는 오름차순(`1/5 → 2/5 → 4/5`)으로 정한다 — "숫자가
클수록 토큰 소비가 크다"는 사용자 설명과 방향이 맞고, 기존 표(`normal → semi-lower → lower`,
사실상 내림차순)를 그대로 뒤집는 것보다 숫자를 읽는 자연스러운 순서를 따르는 편이 낫다.

`3`과 `5`는 **표에 열로 넣지 않는다.** 대신 표 바로 아래에 "3과 5는 나중 확장을 위해
비워 둔다, 지금은 정의되어 있지 않다"는 문장 하나를 둔다.

대안으로 "표에 `3/5 (예약됨)`처럼 빈 칸 열을 넣는 방식"도 검토했지만 기각했다: "지금 등급
확인" 절차는 **7개 값이 표 하나와 정확히 일치하는지**를 기계적으로 대조하는 안전장치다(이
저장소가 이전에 느슨한 낱말 매칭으로 실패를 겪고 마커 기반으로 바꾼 전례가 있다는 지시를
따름). 빈 칸 열은 "무엇과 비교해야 정확히 맞는 것인지"가 없어서 이 대조 로직에 특수 케이스를
만든다. 문장으로만 예약하면 대조 대상 표는 여전히 값이 꽉 찬 3개(`1/5`, `2/5`, `4/5`)뿐이라
로직이 안 바뀐다.

### 2. 하위 호환 없음을 spec에 반영하는 범위: 새 Requirement를 만들지 않고 기존 Requirement에 시나리오 하나만 추가

proposal의 "What Changes"는 "하위호환 제거: 문자열은 더 이상 안 먹힘"을 명시한다. 이걸 spec에
전혀 반영하지 않으면 proposal이 말한 동작이 검증 대상에서 빠진다. 그렇다고 새
`### Requirement:`를 만들면(브리핑의 "요구사항을 늘리지 마라" 지시와 충돌할 수 있어) 대신
**이미 이름 표기 때문에 MODIFIED되는 기존 요구사항**("등급 적용은 양방향이고 몇 번을 해도
같은 결과여야 한다")에 **시나리오 하나**("정의되지 않은 입력을 거부한다")만 추가하는 선에서
멈췄다. 요구사항 개수는 늘지 않고, proposal이 명시한 동작은 검증 가능해진다.

이 판단에 자신이 100% 있는 건 아니다 — 우려 사항에 적어 둔다.

### 3. SKILL.md의 "지금 등급 확인" 절차: 로직은 그대로, 이름표만 교체

`SKILL.md`의 "지금 등급 확인" 4단계 절차(파일 읽기 → 표 대조 → 정확히 맞으면 알림 → 안 맞으면
"섞인 상태") 자체는 **한 글자도 바꾸지 않는다.** 표의 열 헤더만 `normal/semi-lower/lower`에서
`4/5(기본값)/2/5/1/5`로 바뀌고, 그 결과 보고 문구("지금 등급은 `normal`입니다" →
"지금 등급은 `4/5`입니다")만 바뀐다. 이렇게 하면 이 change가 가장 조심해야 할 안전장치
(정확한 표 전체 대조)를 실수로 느슨하게 만들 위험이 없다.

### 4. README.md는 231번째 줄 한 곳만

`normal`/`semi-lower`/`lower`라는 리터럴이 나오는 곳은 README.md 전체에서 231번째 줄
("`agent-model-tier` 스킬로 `normal` / `semi-lower` / `lower` 세 등급을...")뿐이다
(정규식 `\bnormal\b|semi-lower|\blower\b`로 재확인함). 그 줄만 숫자로 바꾼다:
"`agent-model-tier` 스킬로 `1` / `2` / `4` 세 등급을 한 번에 갈 수 있다." 그 외
줄(190~200번째 줄 "7개 서브에이전트" 표의 opus/sonnet 등)은 등급 이름이 아니라 기본값
자체를 설명하는 것이라 안 건드린다.

### 5. 델타 spec에서 시나리오 제목 두 개는 문자열 그대로 남는다 (도구 제약)

`openspec validate --strict`는 MODIFIED 요구사항 블록이 **원래 spec에 있던 시나리오 이름을
전부 포함하는지** 이름 기준으로 대조한다(`validator.js`의 "scenario-loss" 검사, 이름을
바꾸는 문법은 없다 — Requirement 단위의 `RENAMED`만 있고 Scenario 단위 rename은 없다).
그래서 `normal 표가 실제 값과 같다`, `semi-lower와 lower의 값` 두 시나리오는 **제목은
원래 문자열 그대로 두고 본문(WHEN/THEN)만 숫자로** 바꿨다. 제목까지 숫자로 바꾸면
"시나리오를 빠뜨렸다"는 에러로 `validate --strict`가 거부한다(실제로 겪음, exit=1 →
제목을 되돌리고 exit=0).

## Risks / Trade-offs

- [사용자가 습관적으로 `/agent-model-tier normal`이라고 칠 수 있다] → 이번 change의 의도적
  선택(하위 호환 없음)이다. 완화책은 스킬이 거부 응답에서 지금 쓸 수 있는 값(`1`, `2`, `4`)을
  분명히 알려 주는 것뿐이다(spec에 반영함).
- [`3`과 `5`를 나중에 채울 때 표에 열을 추가해야 한다] → 지금은 문장으로만 예약해 뒀으므로
  나중 change가 표 구조를 한 번 바꿔야 한다. 구조가 안정적이길 바라는 것보다, 지금 실제로
  없는 값을 표에 억지로 넣지 않는 쪽이 "정확한 대조" 안전장치를 덜 위험하게 한다고 판단했다.
- [decision.md 없음] → 이 change는 `analyzer 생략: 예`로 진행됐다(원인/방향이 이미 확정돼
  방안 비교가 필요 없는 경로). 기준은 `proposal.md`의 받아들일 조건이다.
