# reviewer-skip-specs-fallback Specification

## Purpose

reviewer가 `skip_specs: true`인 change를 리뷰할 때 판정 기준이 사라지지 않게 하고,
specs가 비어 있다는 이유만으로 정상 작업을 반려하지 않게 한다.

## Requirements

### Requirement: reviewer는 skip_specs change의 대체 판정 기준을 알아야 한다

`.claude/agents/reviewer.md`의 "1. 기준을 먼저 읽는다"는 specs 산출물의 `status`
(`openspec status --json`의 `artifacts[]` 배열에 있다. `artifactPaths.specs` 아래에는
없다 — 실측)가 `skipped`이거나 `artifactPaths.specs.existingOutputPaths`가
비어 있으면 그 change가
`skip_specs: true`라는 것, **그것이 정상이고 반려 사유가 아니라는 것**, 그리고 그때의
판정 기준이 proposal의 받아들일 조건 + 작업 목록 머리말이라는 것을 명시해야 한다(SHALL).
서술 방식은 `decision.md`가 없을 때의 대체 기준을 이미 적어 둔 것과 같아야 한다(SHALL).
지시문에 `skip_specs`라는 낱말이 최소 1회 등장해야 한다(SHALL).

#### Scenario: specs가 빈 배열인 change를 리뷰

- **WHEN** reviewer가 `artifactPaths.specs.existingOutputPaths`가 빈 배열인 change를 받는다
- **THEN** specs 부재를 막음으로 올리지 않고, proposal의 받아들일 조건과 작업 목록 머리말을
  기준으로 삼아 판정한다

#### Scenario: specs 델타가 있는 change는 기존 규칙 그대로

- **WHEN** `existingOutputPaths`에 델타 파일이 있다
- **THEN** 그 델타가 최종 기준이라는 기존 규칙이 그대로 적용된다 (경로는 오직 이 값에서만 가져온다)
