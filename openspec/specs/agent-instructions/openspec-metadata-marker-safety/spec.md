# agent-instructions/openspec-metadata-marker-safety Specification

## Purpose

SDD 파이프라인의 에이전트가 change의 `.openspec.yaml`에 `skip_specs` 또는
`retire_capabilities` 마커를 설정할 때, `openspec new change`가 이미 만들어 둔
기존 메타데이터를 하나도 잃지 않고, 그 결과를 CLI 종료코드로 확인하도록
지침 문서가 갖춰야 할 조건을 정한다.

## Requirements

### Requirement: 마커 삽입 지침은 기존 키를 전부 보존해야 한다

마커를 설정하라고 지시하는 에이전트 지침 문서는, `<changeRoot>/.openspec.yaml`이
`openspec new change`에 의해 **이미 만들어져 있는 파일**이라는 사실을 명시하고,
그 파일의 **기존 키를 하나도 지우지 않은 채** 마커만 덧붙이도록 지시해야 한다(SHALL).
보존 대상은 `schema:` 하나가 아니라 `created:`, `goal:` 등 그 파일에 있는 모든 키다.
지침은 해석 여지가 없도록 **그대로 복사해 실행할 수 있는 명령**의 형태여야 하며(SHALL),
같은 절에서 `Write` 도구 사용과 셸 `>` 리다이렉트를 이 파일에 대해 금지해야 한다(MUST).

#### Scenario: preparer가 skip_specs를 설정하는 지침

- **WHEN** `.claude/agents/preparer.md`의 `skip_specs: true` 설정 지침을 읽는다
- **THEN** `.openspec.yaml`이 이미 존재하는 파일임이 명시되어 있다
- **AND** 기존 키를 전부 보존한 채 마커만 덧붙이는, 복사해 바로 실행할 수 있는
  명령 코드블록이 들어 있다
- **AND** 같은 절에 `Write` 도구와 셸 `>` 리다이렉트 금지가 적혀 있다

#### Scenario: designer가 retire_capabilities를 설정하는 지침

- **WHEN** `.claude/agents/designer.md`의 `retire_capabilities: true` 설정 지침을 읽는다
- **THEN** preparer와 동일한 형태의 보존 문구·명령 코드블록·금지 문구가 들어 있다

#### Scenario: 지침대로 실행하면 기존 키가 살아남는다

- **WHEN** `schema:`, `created:`, `goal:` 세 키가 들어 있는 `.openspec.yaml`에
  지침에 적힌 명령을 그대로 실행한다
- **THEN** 세 키가 모두 그대로 남아 있고 마커 줄이 하나 추가되어 있다
- **AND** `openspec validate "<이름>"`, `openspec validate "<이름>" --strict`,
  `openspec status --change "<이름>" --json`이 모두 종료코드 0이다

### Requirement: 마커 삽입 지침은 여러 번 실행해도 안전해야 한다

파이프라인에는 같은 지침이 두 번 실행되는 경로가 실제로 있다
(worker가 designer로 되돌아오는 경우, `openspec-update-change` 경로 등).
따라서 지침에 박힌 명령은 멱등해야 한다(MUST). 마커 키가 이미 있으면 아무것도 하지
않아야 하고, 파일의 마지막 줄에 개행이 없더라도 마커가 앞 줄에 이어 붙지 않아야 한다.

#### Scenario: 같은 명령을 세 번 실행한다

- **WHEN** 지침에 적힌 마커 삽입 명령을 같은 change에 대해 세 번 연속 실행한다
- **THEN** 매번 종료코드가 0이다
- **AND** `.openspec.yaml`에 마커 키가 정확히 한 번만 나타난다

#### Scenario: 마지막 줄에 개행이 없는 파일

- **WHEN** 마지막 줄이 개행으로 끝나지 않는 `.openspec.yaml`에 지침의 명령을 실행한다
- **THEN** 마커가 앞 줄에 이어 붙지 않고 독립된 줄로 들어간다
- **AND** `openspec status --change "<이름>" --json`이 마커가 반영된 상태를 보고한다
  (`skip_specs`의 경우 `specs` 산출물이 `skipped`)

### Requirement: 마커 설정 결과는 CLI 종료코드로 확인해야 한다

마커를 설정하는 에이전트의 확인 절은 `openspec validate`의 종료코드만이 아니라
`openspec status --change "<이름>" --json`의 **종료코드도** 확인하도록 지시해야 한다(SHALL).
`status`는 메타데이터 파손을 거르는 범용 게이트이고, `validate`는 델타 자체를 검증하는
별개의 게이트다. 두 명령은 역할이 달라 서로를 대신하지 못한다.

`status` 게이트가 반드시 필요한 이유는 두 가지다. 첫째, `retire_capabilities`를 잘못
설정해 기존 키를 잃은 경우 `validate --strict`는 종료코드 0으로 그냥 통과하고
`status`만 종료코드 1이 된다. 둘째, 마커가 앞 줄에 이어 붙어 YAML이 깨진 경우
`validate`는 종료코드 1을 내지만 출력에 YAML 파손을 알려주는 문구가 전혀 없어
"아직 델타가 없어서 그렇다"로 오독되며, 파손을 실제로 드러내는 것은 `status`뿐이다.

#### Scenario: designer의 검증 절

- **WHEN** `.claude/agents/designer.md`의 검증 절을 읽는다
- **THEN** `openspec status --change "<이름>" --json`의 종료코드를 확인하라는
  지시가 있고, 0이 아니면 메타데이터가 깨진 것이라는 설명이 함께 있다

#### Scenario: preparer의 확인 절

- **WHEN** `.claude/agents/preparer.md`의 확인 절을 읽는다
- **THEN** `validate`와 `status --change ... --json`의 종료코드를 모두 확인하라는
  지시가 있다

#### Scenario: 메타데이터가 깨진 채 검증을 돌린다

- **WHEN** `retire_capabilities`를 덮어쓰기로 설정해 `schema:` 키가 사라진 change에
  대해 지침의 확인 절을 그대로 실행한다
- **THEN** `status --change ... --json`이 종료코드 1을 내어 파손이 드러난다
- **AND** `validate --strict`는 종료코드 0으로 통과하므로 그 게이트만으로는
  파손이 드러나지 않는다

#### Scenario: 마커가 앞 줄에 이어 붙어 YAML이 깨진 change

- **WHEN** 마커가 앞 줄 끝에 이어 붙어 한 줄에 키가 두 개가 된 `.openspec.yaml`을
  가진 change에 대해 지침의 확인 절을 그대로 실행한다
- **THEN** `status --change ... --json`이 종료코드 1과 함께 YAML 파싱 실패를 알리는
  메시지를 내어 파손이 드러난다
- **AND** `validate` 쪽 출력만으로는 파손을 알 수 없다 (종료코드는 1이지만
  남는 메시지가 델타 없음 에러 하나뿐이다)

### Requirement: 진단 절차는 특정 에러 문구에 기대지 않아야 한다

확인 절의 진단 안내는 하나의 에러 문구를 찾으라고 하는 대신, 파일 자체를 확인하는
일반화된 절차여야 한다(SHALL). 실패 모드마다 나오는 문구가 다르고
(덮어쓰기는 `schema: Invalid input`, 키 중복은 `not valid YAML`),
줄이 이어 붙은 경우에는 **어느 명령을 보느냐에 따라 원인 문구가 있기도 하고 없기도
하다** — `status --json`에는 YAML 파싱 실패가 찍히지만 `validate` 출력에는
원인을 알려주는 문구가 아예 나오지 않기 때문이다.

#### Scenario: 진단 절차의 내용

- **WHEN** preparer.md와 designer.md의 확인 절 진단 안내를 읽는다
- **THEN** `.openspec.yaml`을 직접 열어 ① 기존 키가 전부 살아 있는지
  ② 마커 키가 중복되지 않았는지 ③ 마커가 앞 줄에 붙어 있지 않은지를
  확인하라는 절차가 적혀 있다
- **AND** 특정 에러 문구 하나에만 의존하는 안내가 아니다

### Requirement: 델타 없음 에러를 조건 없이 정상이라고 가르치지 않아야 한다

`Change must have at least one delta`로 인한 종료코드 1은 마커를 설정하지 않은
경우에만 정상이다. 마커를 설정했는데도 같은 에러가 나오면 마커가 반영되지 않은
것이므로, 지침은 이 두 경우를 구분해서 설명해야 한다(SHALL).
마커가 앞 줄에 이어 붙어 YAML이 깨진 경우 `validate`가 남기는 **유일한** 에러가
바로 이 문구여서, 조건 없이 "정상"이라고 가르치면 파손을 정상으로 판정하게 된다.

#### Scenario: preparer 확인 절의 exit=1 해석

- **WHEN** `.claude/agents/preparer.md`의 확인 절에서 델타 없음 에러 설명을 읽는다
- **THEN** 마커를 설정하지 않았을 때만 정상이라는 조건이 붙어 있다
- **AND** `skip_specs`를 설정했는데도 이 에러가 나오면 마커가 반영되지 않은 것이니
  `.openspec.yaml`을 확인하라는 안내가 함께 있다

### Requirement: 사용자 문서가 마커 파일의 성격을 정확히 설명해야 한다

`README.md`의 change 산출물 표에서 `.openspec.yaml` 항목은, 그 파일이
`openspec new change`가 만들어 둔 파일이고 에이전트는 거기에 마커를 **덧붙인다**는
사실이 드러나게 적어야 한다(SHALL).

#### Scenario: README의 산출물 표

- **WHEN** `README.md`의 change 산출물 표에서 `.openspec.yaml` 줄을 읽는다
- **THEN** 그 파일을 에이전트가 새로 만드는 것이 아니라 기존 파일에 마커를
  덧붙인다는 사실을 알 수 있다
