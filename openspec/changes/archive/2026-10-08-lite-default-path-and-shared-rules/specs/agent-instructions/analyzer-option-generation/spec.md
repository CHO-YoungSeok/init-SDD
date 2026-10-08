## RENAMED Requirements

- FROM: `### Requirement: 기본 경로의 designer 호출은 채택안이 없음을 명시해야 한다`
- TO: `### Requirement: analyzer 없이 부르는 designer 호출은 채택안이 없음을 명시해야 한다`

## MODIFIED Requirements

### Requirement: 기본 경로에는 analyzer와 방안 선택 관문이 없어야 한다

파이프라인의 **기본 경로**는 작은 작업 경로 `preparer → worker → reviewer → finalizer`여야
한다(SHALL). **큰 작업 경로**는 `preparer → designer → worker → reviewer +
regression-verifier(조건부) → finalizer`다. 어느 경로든 사용자가 analyzer를 부르지 않은
요청에서는 방안 3가지 생성과 "★사용자가 방안 선택" 관문이 일어나서는 안 된다(MUST NOT).
작은 작업과 큰 작업을 가르는 기준은 `agent-instructions/lite-default-path`가 정한다.

파이프라인 순서를 적은 문서는 **모두 같은 두 경로를 같은 순서로 적어야 한다**(MUST):
`.claude/skills/orchestra/SKILL.md`(frontmatter `description`, 파이프라인 그림),
`CLAUDE.md`, `README.md`. 한 곳만 고치면 나머지가 조용히 갈라진다.

`analyzer`가 사라지는 것이 아니다. `.claude/agents/analyzer.md`는 그대로 남아 있어야
하며(MUST), analyzer를 부른 경우의 방안 제시 → 선택 → 재호출 흐름도 그대로 유지되어야
한다(MUST). analyzer를 부르면 그 change는 큰 작업 경로로 간다.

#### Scenario: 세 문서의 순서 문구가 일치한다

- **WHEN** `.claude/skills/orchestra/SKILL.md`, `CLAUDE.md`, `README.md`에서 파이프라인
  순서를 적은 대목을 각각 읽는다
- **THEN** 세 곳 모두 기본(작은 작업) 경로가 `preparer` 다음 `worker`, 그 다음 `reviewer`, 그 뒤 `finalizer`다
- **AND** 세 곳 모두 큰 작업 경로가 `preparer` 다음 `designer`이고, `reviewer`와
  `regression-verifier`(조건부)가 동시에 돈 뒤 `finalizer`다
- **AND** 어느 경로에도 `analyzer`나 "사용자가 방안 선택"이 기본 단계로 끼어 있지 않다

#### Scenario: 파이프라인 그림에 방안 선택 관문이 기본 단계로 없다

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 파이프라인 그림을 읽는다
- **THEN** `[preparer]` 다음이 크기 분기이고, 작은 작업 갈래는 `[worker]`, 큰 작업 갈래는 `[designer]`로 간다
- **AND** `[analyzer]` 단계와 `★ 사용자가 안을 고른다` 줄이 기본 흐름 안에 없다
- **AND** analyzer를 부른 경우의 흐름은 별도 절(옵트인 절)에서 찾을 수 있다

#### Scenario: analyzer 파일이 남아 있다

- **WHEN** `.claude/agents/analyzer.md`를 찾는다
- **THEN** 파일이 존재한다
- **AND** frontmatter의 `name:`, `description:`, `model:`, `tools:` 키가 모두 있다

#### Scenario: 묻는 지점 표에서 방안 선택이 조건부로 내려간다

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 "사용자에게 묻는 지점" 표를 읽는다
- **THEN** 방안 선택이 무조건 `필수`가 아니라 "analyzer를 불렀을 때 필수"임을 알 수 있다
- **AND** 범위 밖 확인, 조건부 통과, 커밋 관문은 여전히 `필수`로 남아 있다

### Requirement: analyzer 없이 부르는 designer 호출은 채택안이 없음을 명시해야 한다

`.claude/skills/orchestra/SKILL.md`의 designer 호출 절차는, analyzer를 부르지 않은 큰 작업
경로(작은 작업에서 큰 작업으로 올라온 경우 포함)에서 designer 프롬프트에 `analyzer 생략: 예`와
`채택안: 없음`을 싣도록 지시해야 한다(SHALL).

이 두 줄이 빠지면 designer는 `RESULT: 설계중단 | reason=채택안 없음`으로 멈춘다.
`.claude/agents/designer.md`가 "채택안도 `analyzer 생략: 예`도 둘 다 없으면 설계를 시작하지
마라"고 규정하고 있기 때문이다. analyzer 없이 큰 작업으로 가는 것이 **예외가 아니라 평소
경로**이므로, 지휘 문서의 그 호출 예시가 이 두 줄을 가지고 있어야 한다(MUST).

#### Scenario: 기본 designer 호출 예시

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 designer 호출 절차와 그 프롬프트 예시를 읽는다
- **THEN** analyzer를 부르지 않은 경우의 예시에 `analyzer 생략: 예`가 들어 있다
- **AND** 같은 예시에 `채택안: 없음`이 들어 있고, 기준이 proposal의 받아들일 조건임을 알 수 있다
- **AND** 이 두 줄이 빠지면 designer가 멈춘다는 이유가 함께 적혀 있다

#### Scenario: analyzer를 부른 경우의 designer 호출 예시

- **WHEN** 같은 절에서 analyzer를 불러 사용자가 안을 고른 경우의 예시를 읽는다
- **THEN** `사용자가 고른 안:`이 들어 있다
- **AND** `analyzer 생략: 예`가 들어 있지 않다

### Requirement: 사용자 문서에 없어진 모드가 남아 있지 않아야 한다

파이프라인을 설명하는 사용자 문서는 존재하지 않는 동작을 설명해서는 안 된다(MUST NOT).
단, 날짜가 박힌 검증 기록처럼 **과거 시점의 상태를 보존하는 문서**는 대상이 아니다.

analyzer가 옵트인이 되었으므로, "모든 정식 요청이 방안 선택 관문을 거친다"는 서술도 이
규칙의 대상이다(SHALL). 특히 `README.md`가 그 관문을 "이 구조의 존재 이유"로 적고 있는
대목은 사실과 맞게 고쳐야 한다. **관문을 없애는 것이 아니므로** "관문이 사라졌다"고 적어서도
안 된다(MUST NOT) — analyzer를 부르면 그대로 뜬다는 것이 정확한 서술이다.

기본 경로가 작은 작업 경로가 되었으므로, 사용자가 개입하는 지점도 작은 작업과 큰 작업을
**나눠** 적어야 한다(SHALL). 작은 작업에는 designer가 없어 결정 기록(decision.md)과 설계 요약
알림이 없다. 작은 작업에도 결정 기록 개입 지점이 있다고 적어서는 안 된다(MUST NOT).

#### Scenario: 예제 실행 문서

- **WHEN** `docs/example-run.md`에서 사용자가 자기 안을 내는 대목을 읽는다
- **THEN** "평가 모드"라는 표현이 없다
- **AND** analyzer를 다시 불러 그 안을 후보로 넣고 실제로 성립하는지 코드로 확인하며,
  안 되면 안 된다고 말한다는 취지가 남아 있다
- **AND** 그 예시가 analyzer를 부른 경우의 흐름이라는 것이 문서 안에서 드러난다

#### Scenario: README 재확인

- **WHEN** `README.md`를 읽는다
- **THEN** analyzer가 별도 평가 모드를 가진다는 취지의 문구가 없다
- **AND** 에이전트 표의 analyzer 설명이 "코드베이스 분석, 방안 최소 3가지 + 의견과 근거"로
  남아 있고, 옵트인(부를 때만 돈다)임을 알 수 있는 표시가 함께 있다

#### Scenario: README의 "이게 왜 필요한가"

- **WHEN** `README.md`의 "이게 왜 필요한가" 절을 읽는다
- **THEN** 방안 선택 관문이 모든 요청에서 **강제로** 일어난다고 적혀 있지 않다
- **AND** 그 관문을 원할 때 열 수 있다는 것을 알 수 있다
- **AND** 작은 작업(기본 경로)에 남아 있는 개입 지점이 범위 밖 확인, 리뷰, 커밋 관문이라는 것을 알 수 있다
- **AND** 큰 작업에서는 여기에 결정 기록(설계 요약 알림)이 더해진다는 것을 알 수 있고,
  결정 기록이 작은 작업의 개입 지점으로 적혀 있지 않다

#### Scenario: README의 경로 표와 묻는 횟수

- **WHEN** `README.md`의 "일의 크기에 따라 경로가 갈린다" 표와 "반드시 답해야 하는 지점"
  목록을 읽는다
- **THEN** 새 기능·리팩터링의 기본 경로에 analyzer가 들어 있지 않고, 서브에이전트 호출
  횟수가 그 경로의 실제 개수와 맞다
- **AND** 방안 선택이 반드시 답해야 하는 지점이 아니라 analyzer를 불렀을 때 열리는 지점으로
  적혀 있다
