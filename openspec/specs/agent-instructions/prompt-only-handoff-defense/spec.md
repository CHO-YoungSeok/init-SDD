# prompt-only-handoff-defense Specification

## Purpose

파일이 아니라 프롬프트로만 오가는 정보(사용자가 고른 안, 만진 파일 목록)가 빠졌을 때,
받는 에이전트가 다른 값으로 조용히 메우지 않고 멈추거나 명시적으로 드러내게 한다.

## Requirements

### Requirement: designer는 채택안이 프롬프트에 없으면 멈춰야 한다

`.claude/agents/designer.md`의 중단 사유 목록에 "채택안 없음"(또는 동등한 표현)이 있어야
한다(SHALL). 프롬프트에 `사용자가 고른 안:`도 `analyzer 생략: 예`도 **둘 다 없으면**
designer는 설계를 시작하지 말고 `RESULT: 설계중단 | change=<이름> | reason=채택안 없음`으로
멈춰야 한다(MUST). analyzer의 추천안을 사용자의 선택으로 대체해서는 안 된다(MUST NOT).

#### Scenario: 두 신호가 모두 없다

- **WHEN** designer가 받은 프롬프트에 `사용자가 고른 안:`도 `analyzer 생략: 예`도 없다
- **THEN** `RESULT: 설계중단 | change=<이름> | reason=채택안 없음`으로 멈춘다
- **AND** `analysis.md`의 추천안을 사용자의 선택으로 삼아 진행하지 않는다

#### Scenario: analyzer를 건너뛴 버그 수정 경로

- **WHEN** 프롬프트에 `analyzer 생략: 예`만 있고 `사용자가 고른 안:`이 없다
- **THEN** 이는 정당하게 채택안이 없는 경로이므로 designer는 정상 진행한다

#### Scenario: 사용자가 안을 고른 정상 경로

- **WHEN** 프롬프트에 `사용자가 고른 안:`이 있다
- **THEN** designer는 정상 진행한다

### Requirement: reviewer와 regression-verifier는 만진 파일 목록이 없어도 멈추지 않고 드러내야 한다

`.claude/agents/reviewer.md`와 `.claude/agents/regression-verifier.md`는 각각, 프롬프트에
`만진 파일` 목록이 없을 때의 처리를 명시해야 한다(SHALL). 목록이 없다는 이유로 멈춰서는
안 되며(MUST NOT), 전체 diff를 범위로 삼되 그렇게 했다는 사실을 보고서에 한 줄로 적고(SHALL),
RESULT 첫 줄에 `scope=전체diff`를 남겨야 한다(SHALL). 이 필드 이름은 두 파일에서 동일해야
한다(MUST).

#### Scenario: reviewer가 목록 없이 리뷰한다

- **WHEN** reviewer의 프롬프트에 `만진 파일` 목록이 없다
- **THEN** 전체 diff를 범위로 삼고, "만진 파일 목록을 못 받아서 전체 diff를 범위로 삼았다.
  다른 change의 변경이 섞였을 수 있다"는 취지의 한 줄을 보고서에 적는다
- **AND** 그 상태에서 발견한 "설계에 없는 변경"을 막음으로 올리지 않고
  기존 "이번 change 것인지 확인 필요한 변경" 절에 넣는다
- **AND** RESULT 첫 줄에 `scope=전체diff`를 남긴다

#### Scenario: regression-verifier가 목록 없이 검증한다

- **WHEN** regression-verifier의 프롬프트에 `만진 파일` 목록이 없다
- **THEN** 전체 diff를 범위로 삼고 그 사실을 보고서에 한 줄로 적는다
- **AND** 그 상태에서 원인을 가르지 못한 것은 막음이 아니라 "원인 구분 못 함"에 넣는다
- **AND** RESULT 첫 줄에 `scope=전체diff`를 남긴다

#### Scenario: 두 파일의 표시 필드 이름이 같다

- **WHEN** 오케스트레이터가 두 보고서의 첫 줄을 같은 방식으로 읽는다
- **THEN** 두 파일 모두 `scope=전체diff`라는 같은 필드 이름을 쓰고 있어 한 가지 규칙으로 해석된다
