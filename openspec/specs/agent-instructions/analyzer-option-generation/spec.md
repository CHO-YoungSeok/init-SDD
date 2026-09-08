# agent-instructions/analyzer-option-generation Specification

## Purpose

SDD 파이프라인의 `analyzer` 에이전트가 방안을 제시하는 절차를 하나로 통일하고,
사용자가 목록에 없는 자기 안을 냈을 때에도 그 절차 안에서 검증되도록,
그리고 "검증 안 된 안으로 설계 단계에 들어가지 않는다"는 안전장치가 지휘 문서에
남아 있도록 지침 문서가 갖춰야 할 조건을 정한다.

## Requirements

### Requirement: analyzer 지침에는 동작 모드 분기가 없어야 한다

`.claude/agents/analyzer.md`는 analyzer가 하는 일을 **하나의 절차**로만 기술해야 한다(SHALL).
"요구사항 + 코드베이스 → 방안 최소 3가지 + 각 안의 장단점 + 자기 의견"이 그 유일한 절차다.
프롬프트 내용에 따라 다른 절차로 갈라지는 모드 판별 지시를 두어서는 안 된다(MUST NOT).

모드 분기는 실제로 같은 일을 두 갈래로 쪼갠 것이었고, 그 대가로 지침 문서에 절 하나와
조건부 출력 필드가, 지휘 문서에 왕복 분기 하나가 붙어 있었다.

#### Scenario: frontmatter description에 평가 업무가 없다

- **WHEN** `.claude/agents/analyzer.md`의 frontmatter `description` 값을 읽는다
- **THEN** "사용자가 낸 안을 평가하는 일도 한다"는 취지의 문구가 없다
- **AND** description은 여전히 "요구사항과 코드베이스 분석 → 방안 최소 3가지 + 장단점 +
  의견"이라는 analyzer의 일을 설명한다

#### Scenario: 모드를 설명하는 절이 없다

- **WHEN** `.claude/agents/analyzer.md` 전체를 읽는다
- **THEN** `## 두 가지 모드` 절이 없다
- **AND** `## 사용자 안 평가` 절이 없다
- **AND** 파일 어디에도 `평가 모드`, `평가할 안:` 이라는 문자열이 남아 있지 않다

#### Scenario: RESULT 형식에 조건부 필드가 없다

- **WHEN** `.claude/agents/analyzer.md`의 보고 형식(`RESULT:` 줄)을 읽는다
- **THEN** `feasible=` 필드가 없다
- **AND** `change=`, `options=`, `recommend=`, `questions=` 필드는 그대로 남아 있다

### Requirement: 사용자가 낸 후보는 방안 생성 절차 안에서 같은 형식으로 평가되어야 한다

analyzer 지침의 방안 생성 절은, 프롬프트에 사용자가 낸 후보가 함께 올 수 있다는 사실과
그때 무엇을 해야 하는지를 명시해야 한다(SHALL). 이 지시는 별도 절이 아니라 방안 생성 절차
안의 짧은 규칙이어야 하며, 최소한 다음 세 가지를 담아야 한다(MUST):

1. 사용자 후보도 **안 하나로 넣어 다른 안과 같은 형식**으로 평가한다
   (무엇 / 건드릴 파일 / 장점 / 단점·위험 / 드는 힘 / 요구사항 충족)
2. **성립하지 않으면 분명히 말한다.** 무엇이 막는지 파일:줄로 짚는다.
   사용자 아이디어라고 봐주지 않는다
3. 기존 안을 지우지 말고 **번호를 이어 붙인다**

#### Scenario: 방안 생성 절의 사용자 후보 규칙

- **WHEN** `.claude/agents/analyzer.md`의 방안 생성 절(`### 3. 방안 최소 3가지 만들기`)을 읽는다
- **THEN** 프롬프트에 사용자가 낸 후보가 함께 오면 그것도 안 하나로 넣어 같은 형식으로
  평가하라는 지시가 있다
- **AND** 성립하지 않으면 무엇이 막는지 파일:줄로 짚어 분명히 말하라는 지시가 있다
- **AND** 기존 안을 지우지 말고 번호를 이어 붙이라는 지시가 있다

#### Scenario: 사용자 후보가 함께 온 프롬프트를 처리한다

- **WHEN** analyzer가 사용자 후보 하나가 함께 실린 프롬프트를 받는다
- **THEN** 평소와 같은 하나의 절차로 분석하고, 사용자 후보를 포함해 안 목록을 만든다
- **AND** 보고서의 `RESULT` 줄 형식이 사용자 후보가 없을 때와 동일하다

### Requirement: 검증 안 된 안으로 설계에 들어가지 않는 안전장치가 지휘 문서에 남아야 한다

`.claude/skills/orchestra/SKILL.md`는 사용자가 제시된 목록에 없는 자기 안을 냈을 때
**바로 designer로 넘기지 않고 analyzer를 다시 부른다**는 절차를 유지해야 한다(SHALL).
호출 형태는 평소 analyzer 호출과 같아야 하며, 사용자 후보는 별도 모드를 깨우는 키가 아니라
**추가 후보로 프롬프트에 얹어** 전달해야 한다(MUST).

그 절차가 왜 필요한지를 설명하는 근거 문장("검증 안 된 안을 설계하면 worker가 벽에
부딪힌다")은 지워서는 안 된다(MUST NOT). 그것이 이 안전장치의 존재 이유다.

#### Scenario: 파이프라인 그림의 화살표

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 파이프라인 그림에서 안 선택 다음 줄을 읽는다
- **THEN** 사용자가 자기 안을 내면 analyzer를 다시 부르고 다시 고르게 한다는 흐름이 남아 있다
- **AND** `(평가 모드)`라는 표기가 없다

#### Scenario: 사용자 자기 안 처리 절의 호출 예시

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 "사용자가 목록에 없는 자기 안을 냈을 때"
  절과 그 안의 `Agent(subagent_type: "analyzer", ...)` 예시를 읽는다
- **THEN** 프롬프트에 `평가할 안:` 이라는 키가 없다
- **AND** 사용자 후보가 추가 후보임을 알 수 있는 형태(예: `사용자가 낸 안:`)로 실려 있고,
  나머지 프롬프트 구성이 평소 analyzer 호출과 같다
- **AND** "평가 모드로 다시 부른다"가 아니라 "다시 부른다"로 적혀 있다

#### Scenario: 안전장치의 근거 문장

- **WHEN** 같은 절을 읽는다
- **THEN** "검증 안 된 안을 설계하면 worker가 벽에 부딪힌다"는 이유 문장이 남아 있다
- **AND** analyzer가 "성립하지 않는다"고 하면 그 근거를 사용자에게 그대로 전하고 다시
  고르게 하라는 지시가 남아 있다

#### Scenario: 문서를 읽고 사용자 안 처리 방법을 알 수 있다

- **WHEN** `.claude/skills/orchestra/SKILL.md`만 읽고 "사용자가 목록에 없는 안을 냈을 때
  무엇을 하는가"를 찾는다
- **THEN** 답이 문서 안에 있다 (analyzer를 다시 불러 그 안을 후보로 평가받는다)

### Requirement: 사용자 문서에 없어진 모드가 남아 있지 않아야 한다

파이프라인을 설명하는 사용자 문서는 존재하지 않는 동작을 설명해서는 안 된다(MUST NOT).
단, 날짜가 박힌 검증 기록처럼 **과거 시점의 상태를 보존하는 문서**는 대상이 아니다.

#### Scenario: 예제 실행 문서

- **WHEN** `docs/example-run.md`에서 사용자가 자기 안을 내는 대목을 읽는다
- **THEN** "평가 모드"라는 표현이 없다
- **AND** analyzer를 다시 불러 그 안을 후보로 넣고 실제로 성립하는지 코드로 확인하며,
  안 되면 안 된다고 말한다는 취지가 남아 있다

#### Scenario: README 재확인

- **WHEN** `README.md`를 읽는다
- **THEN** analyzer가 별도 평가 모드를 가진다는 취지의 문구가 없다
- **AND** 에이전트 표의 analyzer 설명이 "코드베이스 분석, 방안 최소 3가지 + 의견과 근거"로
  남아 있다

### Requirement: 지침 문서 수정은 파일을 손상시키지 않아야 한다

에이전트 지침 파일과 스킬 문서를 수정할 때는 파일 전체를 다시 쓰지 말고 필요한 부분만
부분 수정해야 한다(SHALL). 전체 재작성 경로는 리치 마크다운 편집기가 개입해
`[[ORCA_RICH_MD:...]]` 토큰 삽입, 굵게 표시가 백틱 안으로 밀림, 들여쓰기 붕괴를 일으킨
사고가 실제로 있었다.

수정이 끝난 파일은 다음을 만족해야 한다(MUST): 리치 마크다운 토큰이 하나도 없고,
코드펜스 개수가 짝수이며, 에이전트 파일의 frontmatter가 `---` 구분선과 `name:`,
`description:`, `model:`, `tools:` 키를 모두 유지한다.

#### Scenario: 수정 후 파일 무결성 확인

- **WHEN** 수정을 마친 `.claude/agents/analyzer.md`, `.claude/skills/orchestra/SKILL.md`,
  `docs/example-run.md`를 검사한다
- **THEN** 세 파일 모두 `grep -c 'ORCA_RICH_MD'` 결과가 0이다
- **AND** 세 파일 모두 백틱 3개로 시작하는 줄(코드펜스)의 개수가 짝수다
- **AND** `.claude/agents/analyzer.md`의 frontmatter가 `---`로 열리고 닫히며
  `name:`, `description:`, `model:`, `tools:` 키를 모두 가지고 있다

#### Scenario: analyzer.md에서 지우지 않아야 할 규칙

- **WHEN** 군살을 뺀 뒤의 `.claude/agents/analyzer.md`를 읽는다
- **THEN** 다음 지시가 모두 남아 있다: 경로를 CLI에서 얻으라는 지시,
  관찰한 사실과 추측을 구분하라는 지시, 스택이 없으면 혼자 정하지 말라는 지시,
  analysis.md 맨 위에 "추천은 analyzer 의견이고 최종 선택은 decision.md에 있다"는
  경고 줄을 남기라는 지시, 코드 수정 금지, `RESULT` 형식, 보고 형식
- **AND** 제거된 문장은 무엇을 왜 뺐는지 확인할 수 있게 보고되어 있다
