## MODIFIED Requirements

### Requirement: 마커 삽입 지침은 여러 번 실행해도 안전해야 한다

파이프라인에는 같은 지침이 두 번 실행되는 경로가 실제로 있다
(worker가 designer로 되돌아오는 경우, designer가 이미 있는 산출물을 고치는 경우,
작은 작업이 큰 작업으로 올라가 designer가 preparer의 산출물을 이어받는 경우 등).
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
