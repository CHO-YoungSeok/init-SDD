# Spec Delta

## MODIFIED Requirements

### Requirement: 기본 경로는 작은 작업 경로여야 한다

파이프라인의 기본 경로는 `preparer → worker → reviewer → 커밋 관문 → finalizer`여야
한다(SHALL). 이 경로에서 preparer는 proposal과 작업 목록(tasks.md)을 쓰고, 동작이 바뀌면
작은 specs 델타를, 동작이 안 바뀌면 `.openspec.yaml`의 `skip_specs: true`를 쓴다(SHALL).
design.md는 만들지 않는다.

큰 작업일 때만 designer를 켜고, 그때의 경로는
`preparer → designer → worker → reviewer (+ regression-verifier) → 커밋 관문 → finalizer`다(SHALL).
analyzer는 어느 경로에도 기본으로 들어가지 않는다 — 사용자가 분석을 요청할 때만 부른다.

동작이 안 바뀌는 아주 작은 수정(오타·주석·이름)은 `worker(모드: 경량) →
finalizer(모드: 경량 커밋)`으로 간다(SHALL).

#### Scenario: orchestra 파이프라인 그림

- **WHEN** `skills/orchestra/SKILL.md`의 파이프라인 그림을 읽는다
- **THEN** preparer 다음에 크기(`size=`)로 갈라지는 분기가 있다
- **AND** 작은 작업 갈래는 `[worker]`로 바로 가고, 큰 작업 갈래에만 `[designer]`가 있다

#### Scenario: proposal과 tasks만으로 구현 단계가 열린다 (skip_specs)

- **WHEN** 임시 프로젝트에서 `proposal.md`와 `tasks.md`만 있고 `.openspec.yaml`에 `skip_specs: true`가 있는 change를 만든다
- **THEN** `openspec validate "<이름>" --strict`가 종료코드 0이다
- **AND** `openspec instructions apply --change "<이름>" --json`의 `state`가 `ready`다

#### Scenario: proposal과 tasks와 작은 델타로 구현 단계가 열린다

- **WHEN** 같은 방식으로 `proposal.md`, `tasks.md`, 요구사항 하나짜리 specs 델타만 있는 change를 만든다
- **THEN** `openspec validate "<이름>" --strict`가 종료코드 0이다
- **AND** `openspec instructions apply --change "<이름>" --json`의 `state`가 `ready`다
- **AND** 위 두 시나리오의 결과를 플러그인이 고정한 `sdd-openspec`(1.14.1)으로 확인한다
- **AND** 네트워크가 없어 `sdd-openspec`(npx)이 실패하면 그 출력을 그대로 붙여 "못 함"으로 보고한 것으로 이 조건을 충족한 것으로 본다

### Requirement: 큰 작업 판정 기준은 orchestra 한 곳에만 있어야 한다

"큰 작업" 판정 기준은 `skills/orchestra/SKILL.md`의 한 절에만 적혀야 한다(SHALL).
그 절은 `openspec instructions design`이 design.md를 만들 조건으로 드는 네 가지
(여러 모듈에 걸치거나 새 구조 패턴, 새 외부 의존이나 데이터 모델의 큰 변경, 보안·성능·
마이그레이션 복잡도, 코딩 전에 기술 결정이 필요한 모호함)와 "사용자가 분석·방안 비교를
요청했다"를 모두 담아야 한다(MUST). 하나라도 해당하면 큰 작업이다. 애매하면 큰 작업으로
판정한다(SHALL) — 작은 작업 경로에는 설계 단계가 없어서, 잘못 판정하면 worker가 막힌다.

#### Scenario: orchestra에 판정 절이 있다

- **WHEN** `grep -c "큰 작업" skills/orchestra/SKILL.md`를 돌리고 그 절을 읽는다
- **THEN** 1 이상이다
- **AND** 네 가지 조건과 "분석 요청"이 모두 한 절 안에 적혀 있다
- **AND** 애매하면 큰 작업으로 본다는 지시가 있다

#### Scenario: 에이전트 파일에 기준 사본이 없다

- **WHEN** `agents/*.md`에서 네 가지 조건을 적은 문장을 찾는다
- **THEN** 없다
- **AND** preparer.md는 판정 기준을 CLI의 `instructions design` 출력과 orchestra 절에서 얻으라고 가리킨다

### Requirement: 작은 작업일 때 preparer가 작업 목록을 써야 한다

`size=작음`일 때 preparer는 `openspec instructions tasks --change "<이름>" --json`의 지시대로
작업 목록을 써야 한다(SHALL). 동작(요구사항)이 바뀌면 `openspec instructions specs` 지시대로
작은 specs 델타를 쓰고, 안 바뀌면 `skip_specs: true` 마커를 넣는다(SHALL). 마지막에
`openspec validate "<이름>" --strict`와 `openspec status --change "<이름>" --json`의 종료코드를
둘 다 확인한다(SHALL).

`size=큼`일 때는 proposal까지만 쓴다(SHALL). specs·design·tasks는 designer가 쓴다.

preparer.md의 마커 명령 블록(기존 키 보존, 멱등, 두 종료코드 확인, `.openspec.yaml` 직접
열어 세 가지 확인)은 그대로 남아야 한다(MUST).

#### Scenario: preparer가 tasks와 델타 선택을 지시한다

- **WHEN** `agents/preparer.md`를 읽는다
- **THEN** `size=작음`일 때 `openspec instructions tasks`로 작업 목록을 쓰라는 지시가 있다
- **AND** 동작이 바뀌면 작은 델타, 안 바뀌면 `skip_specs: true`를 고르라는 지시가 있다
- **AND** `size=큼`이면 proposal까지만 쓴다는 지시가 있다

#### Scenario: 마커 명령 블록이 그대로다

- **WHEN** preparer.md의 `skip_specs` 마커 절을 읽는다
- **THEN** `grep -q '^skip_specs:' "$f" || printf '\nskip_specs: true\n' >> "$f"` 명령 블록과 `Write`·`>` 금지 문구가 있다
- **AND** 확인 절에 `validate`와 `status --change ... --json` 두 종료코드를 모두 확인하라는 지시가 있다

### Requirement: 회귀 검증 단계는 조건이 맞을 때만 켜야 한다

orchestra는 regression-verifier를 **큰 작업이면서 실행 코드가 바뀌었고 프로젝트에 테스트
명령이 있을 때만** 불러야 한다(SHALL). 이 조건을 orchestra에 적어야 한다(MUST).
실행 코드가 바뀌었는지는 orchestra가 worker 보고서의 만진 파일 목록으로 판단한다(SHALL).

작은 작업 경로에서는 reviewer가 프로젝트의 테스트 명령을 **한 번** 돌려 결과를 review.md와
RESULT에 남긴다(SHALL). `agents/reviewer.md`에 이 지시가 있어야 한다(MUST).
테스트 명령이 없으면 돌리지 않고 "테스트 없음"으로 적는다.

#### Scenario: orchestra에 호출 조건이 있다

- **WHEN** `skills/orchestra/SKILL.md`에서 regression-verifier 호출 조건을 찾는다
- **THEN** "실행 코드 + 테스트 명령"이 있을 때만 부른다는 조건이 적혀 있다

#### Scenario: reviewer가 작은 작업에서 테스트를 한 번 돌린다

- **WHEN** `agents/reviewer.md`를 읽는다
- **THEN** 프롬프트가 테스트를 맡기면 프로젝트 테스트 명령을 한 번 돌리고 결과를 review.md와 RESULT의 `tests=`에 남기라는 지시가 있다

#### Scenario: 회귀 판정 줄이 없으면 finalizer가 멈춘다

- **WHEN** finalizer 프롬프트에 `regression 판정:` 줄이 아예 없다 (경량 커밋·WIP 커밋 모드가 아님)
- **THEN** finalizer는 커밋하지 않고 "회귀 검증 안 거침"으로 보고한다
- **AND** `regression 판정: 생략(작은 작업)`이 있으면 그 사실을 보고서에 적고 진행한다

## ADDED Requirements

### Requirement: 크기 판정은 preparer가 하고 에이전트 파일에 기준 사본을 두지 않아야 한다

작은 작업과 큰 작업의 판정은 preparer가 한다(SHALL). preparer.md에는 네 가지 기준 문장을 다시
적지 않고, 기준을 `openspec instructions design --change "<이름>" --json`의 `instruction`에서 읽으며
정본이 orchestra의 그 절이라는 것을 가리킨다(SHALL). 다른 에이전트 파일에도 판정 기준 문장이
있어서는 안 된다(MUST NOT).

#### Scenario: preparer가 판정을 맡는다

- **WHEN** `agents/preparer.md`를 읽는다
- **THEN** 크기를 판정해 RESULT의 `size=`로 올리라는 지시가 있다
- **AND** 판정 기준의 정본이 orchestra의 절이라는 것을 가리킨다

### Requirement: 회귀 검증을 생략하면 finalizer 프롬프트에 생략 이유를 적어야 한다

regression-verifier를 부르지 않았으면 orchestra는 finalizer 프롬프트에
`regression 판정: 생략(<이유>)`을 글자로 적어 보내야 한다(SHALL). 이유는 `작은 작업`,
`테스트 명령 없음`, `실행 코드 변경 없음`(큰 작업이지만 만진 파일에 실행 코드가 없음) 중 하나다.
finalizer는 이 줄이 있으면 회귀 판정 없이 진행하고, `regression 판정:` 줄이 **아예 없으면**
멈춘다(SHALL).

#### Scenario: finalizer 호출 예시에 생략 이유 세 가지가 있다

- **WHEN** `skills/orchestra/SKILL.md`의 커밋 관문 절에서 finalizer 호출 예시를 읽는다
- **THEN** `regression 판정:` 줄에 `생략(작은 작업)`, `생략(테스트 명령 없음)`, `생략(실행 코드 변경 없음)`이 있다
- **AND** 이 줄을 빼지 말라는 지시가 있다
