# Spec Delta

## REMOVED Requirements

### Requirement: finalizer의 archive 금지 근거는 실측과 일치해야 한다

**Reason**: 본문이 500자를 넘고(1.14.1 strict 실패), 시나리오 이름 "…근거를 제거한다"와 본문의 "정책은 바뀌지 않아야 한다"가
change를 진행하던 때에만 뜻이 있는 말이다. MODIFIED는 시나리오 이름을 바꿀 수 없어(1.14.1 실측) 새 헤더 두 개로 나눠 다시 넣는다.
**Migration**: 근거 두 가지와 틀린 근거 금지는 ADDED "finalizer는 실측과 맞는 두 근거로만 archive 승인 정책을 설명해야 한다"로,
승인 정책과 `--yes` 한 길은 ADDED "finalizer는 승인이 있을 때만 archive --yes 한 길로 archive해야 한다"로 옮겨 간다.

## ADDED Requirements

### Requirement: finalizer는 실측과 맞는 두 근거로만 archive 승인 정책을 설명해야 한다

`agents/finalizer.md` 5단계(archive)는 사용자 승인 없이 archive하지 않는 이유로
다음 두 가지만 근거로 들어야 한다(SHALL):
① `openspec archive`는 change 디렉터리를 옮기며 **되돌릴 수 없으므로 사용자가 정한다**,
② stdin이 없어서 `--yes` 없이는 확인 프롬프트에서 죽는다 — 그래서 승인 뒤에 돌릴 때는
반드시 `--yes`를 붙인다.
실측과 반대인 두 근거 — "손으로 sync한 뒤 돌리면 이중 적용이라 RENAMED/REMOVED가 깨진다",
"validate가 에러로 막는 change도 archive는 그냥 한다. 안전망이 아니다" — 는 없어야 한다(MUST NOT).

#### Scenario: "이중 적용" 근거가 없다

- **WHEN** 실측하면 손으로 sync한 뒤 `openspec archive --yes`가 `Specs already in sync; no files changed.`로
  안전하게 넘어가고 archive에 성공한다 (REMOVED도 손으로 지운 뒤 돌리면 경고 한 줄만 내고 성공한다)
- **THEN** finalizer.md에 "이중 적용이라 RENAMED/REMOVED가 깨진다"는 근거가 없다

#### Scenario: "안전망이 아니다" 근거가 없다

- **WHEN** 실측하면 validate가 에러로 막는 change에 대해 archive가
  `Validation failed. Please fix the errors before archiving.`로 **거부한다**
- **THEN** finalizer.md에 "validate가 막는 change도 archive는 그냥 한다"는 근거가 없다

#### Scenario: 맞는 근거는 유지하고 진짜 이유를 앞세운다

- **WHEN** finalizer가 5단계를 읽는다
- **THEN** "되돌릴 수 없어서 사용자가 정한다"가 첫 근거로 나오고, stdin 근거
  (`no answer could be read from stdin`)가 함께 남아 있다

### Requirement: finalizer는 승인이 있을 때만 archive --yes 한 길로 archive해야 한다

finalizer는 프롬프트에 `archive: 해도 됨`이 없으면 archive하지 않는다(SHALL).
archive는 승인을 받고 조사 조건(validate 성공, 미완료 작업 없음)이 맞을 때
`openspec archive "<이름>" --yes` **한 길로만** 간다(SHALL). 스캐폴드 스킬 문서의 archive
절차를 읽어 따르거나 `mv`로 직접 옮기지 않는다(MUST NOT).

#### Scenario: 승인 정책과 archive 명령

- **WHEN** finalizer가 archive 요청을 받는다
- **THEN** 프롬프트에 `archive: 해도 됨`이 없으면 조사만 하고 진행하지 않고 보고한다
- **AND** 승인이 있고 조사 조건이 맞으면 `openspec archive "<이름>" --yes`로만 archive한다
- **AND** finalizer.md에 스캐폴드 archive 스킬 이름이나 그 SKILL.md 경로가 없다
