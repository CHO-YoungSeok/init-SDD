# Spec Delta

## MODIFIED Requirements

### Requirement: 지침 문서 수정은 파일을 손상시키지 않아야 한다

에이전트 지침 파일과 스킬 문서를 수정할 때는 파일 전체를 다시 쓰지 말고 필요한 부분만
부분 수정해야 한다(SHALL). 전체 재작성 경로는 리치 마크다운 편집기가 개입해
`[[ORCA_RICH_MD:...]]` 토큰 삽입, 굵게 표시가 백틱 안으로 밀림, 들여쓰기 붕괴를 일으킨
사고가 실제로 있었다.

이 규칙은 특정 파일 목록이 아니라 **그 변경이 수정한 지침 파일과 문서 파일 전부**에
적용된다(SHALL). 새로 만드는 파일은 부분 수정할 대상이 없으므로 전체 작성이 허용되지만,
아래 무결성 조건은 새 파일에도 똑같이 적용된다.

수정이 끝난 파일은 다음을 만족해야 한다(MUST): 리치 마크다운 토큰이 하나도 없고,
코드펜스 개수가 짝수이며, frontmatter가 있는 파일은 `---` 구분선과 원래 가지고 있던 키를
모두 유지한다(에이전트 파일은 `name:`, `description:`, `model:`, `tools:`).

#### Scenario: 수정 후 파일 무결성 확인

- **WHEN** 그 변경이 수정하거나 새로 만든 모든 `.md` 파일을 검사한다
- **THEN** 모든 파일의 `grep -c 'ORCA_RICH_MD'` 결과가 0이다
- **AND** 모든 파일에서 백틱 3개로 시작하는 줄(코드펜스)의 개수가 짝수다
- **AND** frontmatter를 가진 파일은 `---`로 열리고 닫히며 원래의 키를 모두 유지한다

#### Scenario: analyzer.md에서 지우지 않아야 할 규칙

- **WHEN** `agents/analyzer.md`를 읽는다
- **THEN** 다음 지시가 모두 있다: 경로를 CLI에서 얻으라는 지시,
  관찰한 사실과 추측을 구분하라는 지시, 스택이 없으면 혼자 정하지 말라는 지시,
  analysis.md 맨 위에 "추천은 analyzer 의견이고 최종 선택은 decision.md에 있다"는
  경고 줄을 남기라는 지시, 코드 수정 금지, `RESULT` 형식, 보고 형식

### Requirement: 기본 경로에는 analyzer와 방안 선택 관문이 없어야 한다

파이프라인의 **기본 경로**는 작은 작업 경로 `preparer → worker → reviewer → finalizer`여야
한다(SHALL). **큰 작업 경로**는 `preparer → designer → worker → reviewer +
regression-verifier(조건부) → finalizer`다. 어느 경로든 사용자가 analyzer를 부르지 않은
요청에서는 방안 3가지 생성과 "★사용자가 방안 선택" 관문이 일어나서는 안 된다(MUST NOT).
작은 작업과 큰 작업을 가르는 기준은 `agent-instructions/lite-default-path`가 정한다.

`agents/analyzer.md`는 그대로 남아 있어야 하며(MUST), analyzer를 부른 경우의 방안 제시 →
선택 → 재호출 흐름도 유지되어야 한다(MUST). analyzer를 부르면 그 change는 큰 작업 경로로 간다.

#### Scenario: 세 문서의 순서 문구가 일치한다

- **WHEN** `skills/orchestra/SKILL.md`, `.claude/CLAUDE.md`, `README.md`에서 파이프라인
  순서를 적은 대목을 각각 읽는다
- **THEN** 세 곳 모두 기본(작은 작업) 경로가 `preparer` 다음 `worker`, 그 다음 `reviewer`, 그 뒤 `finalizer`다
- **AND** 세 곳 모두 큰 작업 경로가 `preparer` 다음 `designer`이고, `reviewer`와
  `regression-verifier`(조건부)가 동시에 돈 뒤 `finalizer`다
- **AND** 어느 경로에도 `analyzer`나 "사용자가 방안 선택"이 기본 단계로 끼어 있지 않다

#### Scenario: 파이프라인 그림에 방안 선택 관문이 기본 단계로 없다

- **WHEN** `skills/orchestra/SKILL.md`의 파이프라인 그림을 읽는다
- **THEN** `[preparer]` 다음이 크기 분기이고, 작은 작업 갈래는 `[worker]`, 큰 작업 갈래는 `[designer]`로 간다
- **AND** `[analyzer]` 단계와 `★ 사용자가 안을 고른다` 줄이 기본 흐름 안에 없다
- **AND** analyzer를 부른 경우의 흐름은 별도 절(옵트인 절)에서 찾을 수 있다

#### Scenario: analyzer 파일이 남아 있다

- **WHEN** `agents/analyzer.md`를 찾는다
- **THEN** 파일이 존재한다
- **AND** frontmatter의 `name:`, `description:`, `model:`, `tools:` 키가 모두 있다

#### Scenario: 묻는 지점 표에서 방안 선택이 조건부로 내려간다

- **WHEN** `skills/orchestra/SKILL.md`의 "사용자에게 묻는 지점" 표를 읽는다
- **THEN** 방안 선택이 무조건 `필수`가 아니라 "analyzer를 불렀을 때 필수"임을 알 수 있다
- **AND** 범위 밖 확인, 조건부 통과, 커밋 관문은 여전히 `필수`로 남아 있다

## REMOVED Requirements

### Requirement: 검증 안 된 안으로 설계에 들어가지 않는 안전장치가 지휘 문서에 남아야 한다

**Reason**: 본문이 500자를 넘고(1.14.1 strict 실패), 시나리오 이름 "파이프라인 그림의 화살표"가 본문과 맞지 않는다.
MODIFIED는 시나리오 이름을 바꿀 수 없어(1.14.1 실측) 새 헤더 두 개로 나눠 다시 넣는다.
**Migration**: 같은 의무와 시나리오가 ADDED 요구사항 "analyzer를 부른 뒤 목록 밖 사용자 안은 analyzer를 다시 불러 검증해야 한다"와
"목록 밖 사용자 안의 재검증은 analyzer를 부른 경우에만 걸린다고 적혀야 한다"로 옮겨 간다.

### Requirement: 사용자 문서에 없어진 모드가 남아 있지 않아야 한다

**Reason**: 본문이 500자를 넘고, 시나리오 "예제 실행 문서"가 없는 `docs/example-run.md`를 읽으며,
"큰 작업에는 결정 기록이 더해진다"는 서술이 사실과 다르다(decision.md는 analyzer를 불렀을 때만 생긴다).
시나리오를 지우거나 이름을 바꾸려면 MODIFIED로는 안 되어(1.14.1 실측) 새 헤더 두 개로 다시 넣는다.
**Migration**: 의무는 ADDED 요구사항 "사용자 문서는 없는 동작과 강제 관문을 설명해서는 안 된다"와
"사용자 문서는 작은 작업과 큰 작업의 개입 지점을 나눠 적어야 한다"로 옮겨 간다. 시나리오 "예제 실행 문서"는 확인할 대상 파일이 없어 지운다.

## ADDED Requirements

### Requirement: 파이프라인 순서를 적은 문서는 같은 두 경로를 같은 순서로 적어야 한다

파이프라인 순서를 적은 문서는 **모두 같은 두 경로를 같은 순서로 적어야 한다**(MUST):
`skills/orchestra/SKILL.md`(frontmatter `description`, 파이프라인 그림),
`.claude/CLAUDE.md`, `README.md`. 한 곳만 고치면 나머지가 조용히 갈라진다.

#### Scenario: orchestra 설명 줄도 같은 두 경로를 적는다

- **WHEN** `skills/orchestra/SKILL.md`의 frontmatter `description` 값을 읽는다
- **THEN** 작은 작업이 `preparer → worker → reviewer → finalizer` 순서로 적혀 있다
- **AND** 큰 작업에는 designer·regression-verifier가 더 붙는다는 것을 알 수 있다
- **AND** analyzer는 분석·방안 비교를 요청했을 때만 넣는다고 적혀 있다

### Requirement: analyzer를 부른 뒤 목록 밖 사용자 안은 analyzer를 다시 불러 검증해야 한다

`skills/orchestra/SKILL.md`는 **analyzer를 불러 사용자가 안을 고르는 중일 때**,
사용자가 제시된 목록에 없는 자기 안을 냈으면 **바로 designer로 넘기지 않고 analyzer를 다시
부른다**는 절차를 유지해야 한다(SHALL). 호출 형태는 평소 analyzer 호출과 같아야 하며,
사용자 후보는 별도 모드를 깨우는 키가 아니라 **추가 후보로 프롬프트에 얹어** 전달해야
한다(MUST).

그 절차가 왜 필요한지를 설명하는 근거 문장("검증 안 된 안을 설계하면 worker가 벽에
부딪힌다")은 지워서는 안 된다(MUST NOT). 그것이 이 안전장치의 존재 이유다.

#### Scenario: analyzer를 부른 경우의 재호출 흐름

- **WHEN** `skills/orchestra/SKILL.md`에서 analyzer를 부른 경우의 흐름(안 선택 다음)을
  읽는다
- **THEN** 사용자가 자기 안을 내면 analyzer를 다시 부르고 다시 고르게 한다는 흐름이 남아 있다
- **AND** `(평가 모드)`라는 표기가 없다
- **AND** 이 흐름이 analyzer를 부른 경우에만 해당한다는 것을 알 수 있다

#### Scenario: 사용자 자기 안 처리 절의 호출 예시

- **WHEN** `skills/orchestra/SKILL.md`의 "사용자가 목록에 없는 자기 안을 냈을 때"
  절과 그 안의 `Agent(subagent_type: "sdd:analyzer", ...)` 예시를 읽는다
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

- **WHEN** `skills/orchestra/SKILL.md`만 읽고 "analyzer를 부른 뒤 사용자가 목록에
  없는 안을 냈을 때 무엇을 하는가"를 찾는다
- **THEN** 답이 문서 안에 있다 (analyzer를 다시 불러 그 안을 후보로 평가받는다)

### Requirement: 목록 밖 사용자 안의 재검증은 analyzer를 부른 경우에만 걸린다고 적혀야 한다

목록 밖 사용자 안을 analyzer로 다시 검증하는 안전장치는 **analyzer를 부른 경우에만**
걸린다. `skills/orchestra/SKILL.md`는 이 조건을 분명히 적어야 한다(MUST) — 조건 없이 적으면
기본 경로에서도 analyzer를 불러야 하는 것처럼 읽힌다. analyzer를 부르지 않은 기본 경로에는
방안 목록 자체가 없으므로 "목록에 없는 자기 안"이라는 상황이 생기지 않는다.

#### Scenario: 기본 경로에서는 재호출 절차가 걸리지 않는다

- **WHEN** `skills/orchestra/SKILL.md`의 "사용자가 목록에 없는 자기 안을 냈을 때" 절을 읽는다
- **THEN** 이 절차가 analyzer를 불러 사용자가 안을 고르는 중일 때만 해당한다고 적혀 있다
- **AND** analyzer를 부르지 않은 경로에서 이 절차 때문에 analyzer를 불러야 한다고 읽히는 문장이 없다

### Requirement: 사용자 문서는 없는 동작과 강제 관문을 설명해서는 안 된다

파이프라인을 설명하는 사용자 문서는 존재하지 않는 동작을 설명해서는 안 된다(MUST NOT).
날짜가 박힌 검증 기록처럼 **과거 시점의 상태를 보존하는 문서**는 대상이 아니다.

"모든 요청이 방안 선택 관문을 거친다"는 서술도 이 규칙의 대상이다(SHALL). `README.md`가 그
관문을 "이 구조의 존재 이유"로 적는 대목은 사실과 맞아야 한다. **관문을 없앤 것이 아니므로**
"관문이 사라졌다"고 적어서도 안 된다(MUST NOT) — analyzer를 부르면 그대로 뜬다.

#### Scenario: README에 평가 모드와 강제 관문이 없다

- **WHEN** `README.md`를 읽는다
- **THEN** analyzer가 별도 평가 모드를 가진다는 취지의 문구가 없다
- **AND** 에이전트 표의 analyzer 설명이 "코드베이스 분석, 방안 최소 3가지 + 의견과 근거"로
  남아 있고, 옵트인(부를 때만 돈다)임을 알 수 있는 표시가 함께 있다

#### Scenario: README의 경로 표와 묻는 횟수

- **WHEN** `README.md`의 "일의 크기에 따라 경로가 갈린다" 표와 "반드시 답해야 하는 지점"
  목록을 읽는다
- **THEN** 새 기능·리팩터링의 기본 경로에 analyzer가 들어 있지 않고, 서브에이전트 호출
  횟수가 그 경로의 실제 개수와 맞다
- **AND** 방안 선택이 반드시 답해야 하는 지점이 아니라 analyzer를 불렀을 때 열리는 지점으로
  적혀 있다

### Requirement: 사용자 문서는 작은 작업과 큰 작업의 개입 지점을 나눠 적어야 한다

사용자가 개입하는 지점은 작은 작업과 큰 작업을 **나눠** 적어야 한다(SHALL). 작은 작업에는
designer가 없어 설계 요약 알림이 없다. 결정 기록(decision.md)은 analyzer를 불러 사용자가
안을 골랐을 때만 생긴다. 작은 작업이나 analyzer를 부르지 않은 큰 작업에 결정 기록 개입 지점이
있다고 적어서는 안 된다(MUST NOT).

#### Scenario: README의 "이게 왜 필요한가"

- **WHEN** `README.md`의 "이게 왜 필요한가" 절을 읽는다
- **THEN** 방안 선택 관문이 모든 요청에서 **강제로** 일어난다고 적혀 있지 않다
- **AND** 그 관문을 원할 때 열 수 있다는 것을 알 수 있다
- **AND** 작은 작업(기본 경로)에 남아 있는 개입 지점이 범위 밖 확인, 리뷰, 커밋 관문이라는 것을 알 수 있다
- **AND** 큰 작업에서는 설계 요약 알림이 더해진다는 것을 알 수 있다
- **AND** 결정 기록(decision.md)이 analyzer를 불러 안을 골랐을 때만 생긴다는 것을 알 수 있고,
  작은 작업이나 analyzer 없는 큰 작업의 개입 지점으로 적혀 있지 않다
