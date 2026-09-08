# worker-blocked-state-disambiguation Specification

## Purpose

worker가 OpenSpec의 `blocked` 상태를 원인별로 갈라 보고하게 해서, 오케스트레이터가
"산출물이 빠졌다"는 잘못된 신호를 받고 designer에게 헛되이 되돌려 보내는 무한 왕복을 막는다.

## Requirements

### Requirement: worker는 blocked 상태를 원인별로 구분해 보고해야 한다

`.claude/agents/worker.md`의 정식 모드 1단계는, `openspec instructions apply`가 돌려준
`state: "blocked"`를 `missingArtifacts` 값의 유무로 **두 갈래로 나눠** 보고하도록
worker에게 지시해야 한다(SHALL). 지시문에는 `missingArtifacts`라는 낱말이 최소 1회
등장해야 한다(SHALL).

#### Scenario: 산출물이 실제로 빠진 경우

- **WHEN** worker가 `state: "blocked"`이면서 `missingArtifacts`에 값이 있는 상태를 만난다
- **THEN** 지시문에 따라 "산출물이 빠졌다"로 보고하고, 스스로 만들지 않는다 (현행 문구 그대로)

#### Scenario: 파일은 있는데 체크박스가 0개인 경우

- **WHEN** `state: "blocked"`인데 `missingArtifacts`가 비어 있다 (실측 응답: `tasks: []`, `progress.total: 0`)
- **THEN** worker는 **"작업 목록에 체크박스가 없다"**로 정확히 보고한다
- **AND** 이 경우를 "산출물 누락"으로 보고하지 않는다 (그렇게 보고하면 designer가 "이미 다 있다"고
  답해 무한 왕복이 된다)

#### Scenario: design.md를 의도적으로 건너뛴 change

- **WHEN** 프롬프트에 `design.md: 없음(의도적)`이 있고 막힌 이유가 design 하나뿐이다
- **THEN** worker는 멈추지 않고 진행한다 (기존 예외 규칙이 그대로 남아 있다)
