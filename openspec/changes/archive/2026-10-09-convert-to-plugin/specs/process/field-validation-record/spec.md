## MODIFIED Requirements

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
