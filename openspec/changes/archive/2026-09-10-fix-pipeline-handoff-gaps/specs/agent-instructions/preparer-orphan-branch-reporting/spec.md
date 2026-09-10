## Purpose

preparer가 중단할 때 이미 만들어 둔 브랜치의 존재가 항상 보고서 첫 줄에 드러나게 해서,
오케스트레이터가 아무도 모르는 고아 브랜치를 남긴 채 다음 단계로 넘어가지 않게 한다.

## ADDED Requirements

### Requirement: preparer의 중단 보고에는 브랜치 상태가 항상 있어야 한다

`.claude/agents/preparer.md`의 중단 RESULT 형식 줄(`RESULT: 준비중단 | ...`)은
`branch=<브랜치 이름 또는 none>` 필드를 포함해야 한다(SHALL). 지시문은 이 필드가 왜
필요한지 — 브랜치를 4단계에서, change를 5단계에서 만들기 때문에 5단계에서 멈추면
브랜치만 남는다 — 를 한 줄 근거로 함께 밝혀야 한다(SHALL).

#### Scenario: 이름 충돌로 change 생성 단계에서 멈춤

- **WHEN** preparer가 브랜치를 만든 뒤 `Error: Change '...' already exists`로 5단계에서 멈춘다
- **THEN** 중단 RESULT 줄에 `branch=<그 브랜치 이름>`이 들어가 오케스트레이터가 브랜치의 존재를 안다

#### Scenario: 브랜치를 만들기 전에 멈춤

- **WHEN** preparer가 브랜치를 만들기 전 단계(미커밋 변경, 초기 커밋 없음 등)에서 멈춘다
- **THEN** 중단 RESULT 줄에 `branch=none`이 들어간다

#### Scenario: 필드가 필요한 이유가 문서에 남아 있다

- **WHEN** 다음 사람이 이 필드를 지워도 되는지 판단하려 한다
- **THEN** 브랜치(4단계)가 change(5단계)보다 먼저 만들어진다는 근거가 지시문에 적혀 있어 지우면 안 됨을 안다
