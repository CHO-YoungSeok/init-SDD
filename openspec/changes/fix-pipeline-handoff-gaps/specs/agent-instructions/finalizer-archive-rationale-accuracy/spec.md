## Purpose

finalizer가 "archive CLI를 직접 돌리지 마라"는 옳은 정책을 실측과 어긋나는 근거로
뒷받침하지 않게 한다. 틀린 근거를 남겨 두면 다음 사람이 그걸 믿고 잘못 판단한다.

## ADDED Requirements

### Requirement: finalizer의 archive 금지 근거는 실측과 일치해야 한다

`.claude/agents/finalizer.md` 5단계(archive)는 다음 두 가지만 근거로 들어야 한다(SHALL):
① `openspec archive`는 change 디렉터리를 옮기며 **되돌릴 수 없으므로 사용자가 정한다**,
② stdin이 없어서 `--yes` 없이는 확인 프롬프트에서 죽는다.
실측과 반대인 두 근거 — "손으로 sync한 뒤 돌리면 이중 적용이라 RENAMED/REMOVED가 깨진다",
"validate가 에러로 막는 change도 archive는 그냥 한다. 안전망이 아니다" — 는 제거되어야 한다(MUST).
정책 자체(사용자 확인 없이 archive하지 않는다)와 `openspec-archive-change` 절차 한 길로만
간다는 결론은 바뀌지 않아야 한다(SHALL).

#### Scenario: "이중 적용" 근거를 제거한다

- **WHEN** 실측하면 손으로 sync한 뒤 `openspec archive --yes`가 `Specs already in sync; no files changed.`로
  안전하게 넘어가고 archive에 성공한다 (REMOVED도 손으로 지운 뒤 돌리면 경고 한 줄만 내고 성공한다)
- **THEN** finalizer.md에 "이중 적용이라 RENAMED/REMOVED가 깨진다"는 근거가 남아 있지 않다

#### Scenario: "안전망이 아니다" 근거를 제거한다

- **WHEN** 실측하면 validate가 에러로 막는 change에 대해 archive가
  `Validation failed. Please fix the errors before archiving.`로 **거부한다**
- **THEN** finalizer.md에 "validate가 막는 change도 archive는 그냥 한다"는 근거가 남아 있지 않다

#### Scenario: 맞는 근거는 유지하고 진짜 이유를 앞세운다

- **WHEN** finalizer가 5단계를 읽는다
- **THEN** "되돌릴 수 없어서 사용자가 정한다"가 첫 근거로 나오고, stdin 근거
  (`no answer could be read from stdin`)가 함께 남아 있다

#### Scenario: 정책과 결론은 그대로다

- **WHEN** finalizer가 archive 요청을 받는다
- **THEN** `openspec archive` CLI를 직접 돌리지 않고 `openspec-archive-change` 절차 한 길로만 가며,
  사용자 확인이 필요한 지점에서는 진행하지 않고 보고한다
