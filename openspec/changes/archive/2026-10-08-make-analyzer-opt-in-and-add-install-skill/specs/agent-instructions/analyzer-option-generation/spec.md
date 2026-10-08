## ADDED Requirements

### Requirement: 기본 경로에는 analyzer와 방안 선택 관문이 없어야 한다

파이프라인의 **기본 경로**는 `preparer → designer → worker → reviewer +
regression-verifier → finalizer` 여야 한다(SHALL). 사용자가 analyzer를 부르지 않은 일반
요청에서는 방안 3가지 생성과 "★사용자가 방안 선택" 관문이 일어나서는 안 된다(MUST NOT).

파이프라인 순서를 적은 문서는 **모두 이 순서와 같은 순서를 적어야 한다**(MUST):
`.claude/skills/orchestra/SKILL.md`(frontmatter `description`, 파이프라인 그림),
`CLAUDE.md`, `README.md`. 한 곳만 고치면 나머지가 조용히 갈라진다.

`analyzer`가 사라지는 것이 아니다. `.claude/agents/analyzer.md`는 그대로 남아 있어야
하며(MUST), analyzer를 부른 경우의 방안 제시 → 선택 → 재호출 흐름도 그대로 유지되어야
한다(MUST).

#### Scenario: 세 문서의 순서 문구가 일치한다

- **WHEN** `.claude/skills/orchestra/SKILL.md`, `CLAUDE.md`, `README.md`에서 파이프라인
  순서를 적은 대목을 각각 읽는다
- **THEN** 세 곳 모두 `preparer` 다음이 `designer`이고, 그 사이에 `analyzer`나
  "사용자가 방안 선택"이 끼어 있지 않다
- **AND** 세 곳 모두 `reviewer`와 `regression-verifier`가 동시에 돌고 그 뒤가 `finalizer`다

#### Scenario: 파이프라인 그림에 방안 선택 관문이 기본 단계로 없다

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 파이프라인 그림을 읽는다
- **THEN** `[preparer]` 다음 단계가 `[designer]`다
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

### Requirement: analyzer를 부르는 신호와 판단 기준이 지휘 문서에 적혀 있어야 한다

`.claude/skills/orchestra/SKILL.md`는 analyzer를 **언제 부르는지**를 사람이 보고 판별할 수
있는 형태로 적어야 한다(SHALL). "사용자가 원하면 부른다" 같은 애매한 문장만 적어서는
안 된다(MUST NOT) — 그렇게 적으면 실제로 아무도 부르지 않는다.

최소한 다음 세 가지를 모두 담아야 한다(MUST):

1. **신호 목록** — 사용자가 실제로 할 수 있는 말의 예시. 자연어이며 에이전트 이름을
   정확히 대지 않아도 걸리는 말들을 포함한다
   (예: `"분석해줘"`, `"방안 뽑아줘"`, `"선택지 보여줘"`, `"analyzer 불러"`)
2. **하나의 판단 기준** — 그 신호들이 공통으로 뜻하는 것. 목록에 없는 말이 왔을 때
   판단할 수 있게 하는 문장이어야 한다
3. **애매할 때 기울 방향** — 부를지 안 부를지 모호할 때 어느 쪽으로 가는지, 그리고 그때
   사용자에게 무엇을 하는지

#### Scenario: 신호 목록이 실제 문구로 적혀 있다

- **WHEN** `.claude/skills/orchestra/SKILL.md`에서 analyzer를 부르는 조건을 적은 절을 읽는다
- **THEN** 사용자가 할 수 있는 말이 따옴표로 인용된 예시 목록으로 있다
- **AND** 그 목록에 `분석`, `방안`, `선택지`, `analyzer` 각각을 담은 말이 최소 하나씩 있다
- **AND** 에이전트 이름을 정확히 대지 않아도 걸린다는 것이 명시되어 있다

#### Scenario: 목록에 없는 말도 판단할 수 있다

- **WHEN** 같은 절에서 판단 기준 문장을 읽는다
- **THEN** 신호 목록에 없는 말이 왔을 때 부를지 말지를 그 문장 하나로 판단할 수 있다
- **AND** 그 기준은 "사용자가 방향을 아직 정하지 않고 고를 거리를 달라고 하는가"를
  묻는 형태다

#### Scenario: 애매할 때의 기본값

- **WHEN** 같은 절에서 애매한 경우의 지시를 읽는다
- **THEN** 부를지 말지 애매하면 **부르지 않는다**고 적혀 있다
- **AND** 그때 사용자에게 방안 비교를 해볼지 한 줄로 물어보는(권하는) 지점이 함께 적혀 있다
- **AND** 그렇게 기울인 이유가 한 문장으로 적혀 있다

### Requirement: 기본 경로의 designer 호출은 채택안이 없음을 명시해야 한다

`.claude/skills/orchestra/SKILL.md`의 designer 호출 절차는, analyzer를 부르지 않은 기본
경로에서 designer 프롬프트에 `analyzer 생략: 예`와 `채택안: 없음`을 싣도록 지시해야
한다(SHALL).

이 두 줄이 빠지면 designer는 `RESULT: 설계중단 | reason=채택안 없음`으로 멈춘다.
`.claude/agents/designer.md`가 "채택안도 `analyzer 생략: 예`도 둘 다 없으면 설계를 시작하지
마라"고 규정하고 있기 때문이다. 기본 경로가 analyzer 없는 경로가 되면서 이 조합이 **예외가
아니라 평소 경로**가 되므로, 지휘 문서의 기본 호출 예시가 이 두 줄을 가지고 있어야 한다(MUST).

#### Scenario: 기본 designer 호출 예시

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 designer 호출 절차와 그 프롬프트 예시를 읽는다
- **THEN** analyzer를 부르지 않은 경우의 예시에 `analyzer 생략: 예`가 들어 있다
- **AND** 같은 예시에 `채택안: 없음`이 들어 있고, 기준이 proposal의 받아들일 조건임을 알 수 있다
- **AND** 이 두 줄이 빠지면 designer가 멈춘다는 이유가 함께 적혀 있다

#### Scenario: analyzer를 부른 경우의 designer 호출 예시

- **WHEN** 같은 절에서 analyzer를 불러 사용자가 안을 고른 경우의 예시를 읽는다
- **THEN** `사용자가 고른 안:`이 들어 있다
- **AND** `analyzer 생략: 예`가 들어 있지 않다

## MODIFIED Requirements

### Requirement: 검증 안 된 안으로 설계에 들어가지 않는 안전장치가 지휘 문서에 남아야 한다

`.claude/skills/orchestra/SKILL.md`는 **analyzer를 불러 사용자가 안을 고르는 중일 때**,
사용자가 제시된 목록에 없는 자기 안을 냈으면 **바로 designer로 넘기지 않고 analyzer를 다시
부른다**는 절차를 유지해야 한다(SHALL). 호출 형태는 평소 analyzer 호출과 같아야 하며,
사용자 후보는 별도 모드를 깨우는 키가 아니라 **추가 후보로 프롬프트에 얹어** 전달해야
한다(MUST).

이 안전장치는 **analyzer를 부른 경우에만** 걸리는 것이다. analyzer를 부르지 않은 기본
경로에는 방안 목록 자체가 없으므로 "목록에 없는 자기 안"이라는 상황이 생기지 않는다.
이 조건을 문서에 분명히 적어야 한다(MUST) — 조건 없이 적으면 기본 경로에서도 analyzer를
불러야 하는 것처럼 읽힌다.

그 절차가 왜 필요한지를 설명하는 근거 문장("검증 안 된 안을 설계하면 worker가 벽에
부딪힌다")은 지워서는 안 된다(MUST NOT). 그것이 이 안전장치의 존재 이유다.

#### Scenario: 파이프라인 그림의 화살표

- **WHEN** `.claude/skills/orchestra/SKILL.md`에서 analyzer를 부른 경우의 흐름(안 선택 다음)을
  읽는다
- **THEN** 사용자가 자기 안을 내면 analyzer를 다시 부르고 다시 고르게 한다는 흐름이 남아 있다
- **AND** `(평가 모드)`라는 표기가 없다
- **AND** 이 흐름이 analyzer를 부른 경우에만 해당한다는 것을 알 수 있다

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

- **WHEN** `.claude/skills/orchestra/SKILL.md`만 읽고 "analyzer를 부른 뒤 사용자가 목록에
  없는 안을 냈을 때 무엇을 하는가"를 찾는다
- **THEN** 답이 문서 안에 있다 (analyzer를 다시 불러 그 안을 후보로 평가받는다)

### Requirement: 사용자 문서에 없어진 모드가 남아 있지 않아야 한다

파이프라인을 설명하는 사용자 문서는 존재하지 않는 동작을 설명해서는 안 된다(MUST NOT).
단, 날짜가 박힌 검증 기록처럼 **과거 시점의 상태를 보존하는 문서**는 대상이 아니다.

analyzer가 옵트인이 되었으므로, "모든 정식 요청이 방안 선택 관문을 거친다"는 서술도 이
규칙의 대상이다(SHALL). 특히 `README.md`가 그 관문을 "이 구조의 존재 이유"로 적고 있는
대목은 사실과 맞게 고쳐야 한다. **관문을 없애는 것이 아니므로** "관문이 사라졌다"고 적어서도
안 된다(MUST NOT) — analyzer를 부르면 그대로 뜬다는 것이 정확한 서술이다.

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
- **AND** 그 관문을 원할 때 열 수 있다는 것과, 기본 경로에서도 남아 있는 개입 지점
  (범위 밖 확인, 결정 기록, 리뷰, 커밋 관문)이 무엇인지 알 수 있다

#### Scenario: README의 경로 표와 묻는 횟수

- **WHEN** `README.md`의 "일의 크기에 따라 경로가 갈린다" 표와 "반드시 답해야 하는 지점"
  목록을 읽는다
- **THEN** 새 기능·리팩터링의 기본 경로에 analyzer가 들어 있지 않고, 서브에이전트 호출
  횟수가 그 경로의 실제 개수와 맞다
- **AND** 방안 선택이 반드시 답해야 하는 지점이 아니라 analyzer를 불렀을 때 열리는 지점으로
  적혀 있다

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

- **WHEN** 군살을 뺀 뒤의 `.claude/agents/analyzer.md`를 읽는다
- **THEN** 다음 지시가 모두 남아 있다: 경로를 CLI에서 얻으라는 지시,
  관찰한 사실과 추측을 구분하라는 지시, 스택이 없으면 혼자 정하지 말라는 지시,
  analysis.md 맨 위에 "추천은 analyzer 의견이고 최종 선택은 decision.md에 있다"는
  경고 줄을 남기라는 지시, 코드 수정 금지, `RESULT` 형식, 보고 형식
- **AND** 제거된 문장은 무엇을 왜 뺐는지 확인할 수 있게 보고되어 있다
