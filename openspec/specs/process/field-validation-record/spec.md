# field-validation-record Specification

## Purpose

직접 작업과 SDD 작업(경량 경로 / 정식 경로)을 같은 항목(품질 / 소요 시간 / 토큰)으로 기록하고 비교해,
파이프라인의 각 단계를 남길지 뺄지를 느낌이 아니라 기록으로 정할 수 있게 하는 측정 문서와
`claude plugin eval` 사례 폴더 뼈대가 갖춰야 할 요구사항을 정한다.

## Requirements

### Requirement: 측정 문서가 측정 항목 3가지와 각 항목의 측정 수단을 담아야 한다

저장소 루트의 `docs/field-validation.md` 가 존재해야 한다(SHALL).
이 문서는 측정 항목으로 결과물 품질, 소요 시간, 토큰 세 가지를 정의해야 하며(MUST),
각 항목마다 측정 수단과 그 수단이 재는 것·재지 못하는 것을 적어야 한다(MUST).
측정 수단에는 최소한 `/cost`, `claude plugin details <name>` 의 토큰 추정, 세션 로그가 포함되어야 한다(SHALL).
품질 항목은 판정 기준(무엇을 보고 품질을 매기는지)을 함께 적어야 한다(MUST).

#### Scenario: 측정 항목과 수단 확인
- **WHEN** 사람이 `docs/field-validation.md` 를 연다
- **THEN** 품질 / 소요 시간 / 토큰 세 항목이 각각 정의되어 있다
- **AND** 각 항목에 측정 수단과 그 수단이 재는 것·재지 못하는 것이 적혀 있다
- **AND** `/cost`, `claude plugin details`, 세션 로그가 측정 수단으로 언급되어 있다

#### Scenario: 품질 판정 기준 확인
- **WHEN** 측정하는 사람이 품질 값을 기록하려 한다
- **THEN** 문서에 품질을 무엇으로 매기는지(판정 기준)가 적혀 있어 같은 기준으로 값을 적을 수 있다

### Requirement: 측정 문서가 비교 대상 3가지와 작업 1건당 1행인 기록 표 양식을 담아야 한다

`docs/field-validation.md` 는 비교 대상으로 직접 작업, SDD 경량 경로, SDD 정식 경로 세 가지를 정의해야 한다(MUST).
같은 문서에 작업 1건당 1행으로, 한 행 안에 세 비교 대상을 같은 측정 항목(품질 / 소요 시간 / 토큰)으로 적는
기록 표 양식이 있어야 한다(SHALL). 표 양식의 값 칸은 비어 있어야 한다(MUST).

#### Scenario: 비교 대상 정의 확인
- **WHEN** 사람이 문서에서 비교 대상을 찾는다
- **THEN** 직접 작업 / 경량 경로 / 정식 경로 세 가지가 각각 무엇을 뜻하는지 적혀 있다

#### Scenario: 한 행에 세 대상을 같은 항목으로 기록
- **WHEN** 측정하는 사람이 작업 하나의 결과를 기록 표에 적는다
- **THEN** 그 작업이 한 행을 차지하고, 그 행 안에 세 비교 대상 각각의 품질 / 소요 시간 / 토큰 칸이 있다
- **AND** 세 대상의 칸 이름이 같은 항목으로 짝지어져 있다

### Requirement: 측정 문서가 기준선 값을 출처와 함께 담아야 한다

`docs/field-validation.md` 는 기준선 값 칸에 다음 세 값을 적어야 한다(SHALL):
지시문 2,821줄, 세션당 약 1.5k 토큰, 기본 경로 1회 약 80k 토큰.
각 값에는 출처(상위 change `plugin-lite-sdd-distribution` 의 analysis.md)와 측정 방법을 적어야 하며(MUST),
추정값은 "추정"임을 표시해야 한다(MUST).

#### Scenario: 기준선 값과 출처 확인
- **WHEN** 사람이 문서의 기준선 칸을 읽는다
- **THEN** 2,821줄 / 약 1.5k 토큰 / 약 80k 토큰이 적혀 있다
- **AND** 각 값 옆에 출처와 측정 방법이 있다
- **AND** 약 80k 토큰 값에 "추정" 표시가 있다

### Requirement: 측정 문서가 조건과 조치가 짝인 판정 규칙을 담아야 한다

`docs/field-validation.md` 는 판정 규칙을 담아야 하며(SHALL), 각 규칙은 조건(측정 결과)과
그에 따른 조치(어떤 단계를 유지 / 제거 / 조건부로 둘지)를 짝으로 적어야 한다(MUST).
판정 대상 단계에는 최소한 analyzer, designer, regression-verifier 가 포함되어야 한다(SHALL).
문서는 목표 숫자(예: 토큰 몇 % 절감)를 새로 정해서는 안 되며(MUST NOT),
임계값이 필요한 자리에는 "측정 뒤 사용자가 정한다"고 적어 비워 두어야 한다(MUST).

#### Scenario: 조건과 조치가 짝으로 적혀 있음
- **WHEN** 사람이 판정 규칙을 읽는다
- **THEN** 각 규칙에 조건과 조치가 함께 적혀 있다
- **AND** analyzer, designer, regression-verifier 각각에 대한 규칙이 있다

#### Scenario: 임계값을 지어내지 않음
- **WHEN** 판정 규칙에 임계값(동등으로 볼 차이, 판정에 필요한 작업 건수 등)이 필요하다
- **THEN** 그 자리에는 숫자 대신 "측정 뒤 사용자가 정한다"가 적혀 있다
- **AND** 문서 어디에도 새로 정한 절감 목표 숫자가 없다

### Requirement: evals 폴더가 claude plugin eval 사례 뼈대와 안내 문서를 담아야 한다

저장소 루트의 `evals/` 아래에 `evals/README.md` 가 있어야 한다(SHALL).
`evals/` 아래 사례 폴더는 `claude plugin eval init --bare` 가 만드는 모양, 즉
`<사례>/prompt.md`(frontmatter `max_turns`, `allowed_tools`)와 `<사례>/graders/criteria.md`(frontmatter `type: llm`, `weight`)를
가져야 한다(MUST). 사례 폴더는 경량 경로로 처리할 작은 작업 1개와 직접 작업 대조 1개, 모두 2개여야 한다(SHALL).
`evals/README.md` 는 사례 폴더 구조, `claude plugin eval --ablation with-without` 으로 돌리는 방법,
그리고 저장소 루트(`.claude-plugin/plugin.json` 이 있는 플러그인 루트)에서 실행한다는 사실을 적어야 한다(MUST).
플러그인 전환(`convert-to-plugin`) 뒤에는 실행할 수 없다는 서술이 남아 있어서는 안 된다(MUST NOT).
시나리오 이름은 원문을 지킨다. 전환 뒤 "실행 불가 시점"은 "실행 위치"로 읽는다.

#### Scenario: 사례 폴더가 bare 템플릿과 같은 모양
- **WHEN** 사람이 `evals/` 아래 사례 폴더를 나열한다
- **THEN** 사례 폴더가 2개 있고, 각각 `prompt.md` 와 `graders/criteria.md` 를 가진다
- **AND** `prompt.md` frontmatter에 `max_turns`, `allowed_tools` 키가 있고 `graders/criteria.md` frontmatter에 `type: llm`, `weight` 키가 있다

#### Scenario: README가 실행 방법과 실행 불가 시점을 알린다
- **WHEN** 사람이 `evals/README.md` 를 읽는다
- **THEN** 사례 폴더 구조와 `claude plugin eval --ablation with-without` 실행 방법이 적혀 있다
- **AND** 저장소 루트(plugin.json 이 있는 플러그인 루트)에서 실행한다는 사실이 적혀 있고, "아직 플러그인이 아니라 실행할 수 없다"는 서술은 없다

### Requirement: 이 양식은 측정 결과 없이 비어 있는 상태로 제공되어야 한다

측정 양식을 도입하는 시점에는 실제 측정을 돌리지 않아야 하며(MUST NOT),
`docs/field-validation.md` 의 기록 표 값 칸은 비어 있어야 한다(MUST). 채워진 값은 기준선 값 칸뿐이어야 한다(SHALL).
`claude plugin eval` 실행 결과물(`evals/results/`)은 저장소에 추적되어서는 안 되며(MUST NOT),
`.gitignore` 가 `evals/results/` 를 무시해야 한다(SHALL). 플러그인 전환 뒤에는 로컬 실행으로 이 폴더가 생길 수 있으므로
"존재하지 않는다" 대신 "추적되지 않는다"로 확인한다.

#### Scenario: 값 칸이 비어 있음
- **WHEN** 사람이 양식 도입 직후의 `docs/field-validation.md` 기록 표를 본다
- **THEN** 작업 행의 값 칸이 비어 있고 기준선 값 칸만 채워져 있다
- **AND** `git ls-files evals/results` 출력이 비어 있고 `git check-ignore -q evals/results/x` 의 종료코드가 0이다
