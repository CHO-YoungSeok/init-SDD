# Spec Delta

## MODIFIED Requirements

### Requirement: 측정 문서가 비교 대상 3가지와 작업 1건당 1행인 기록 표 양식을 담아야 한다

`docs/field-validation.md` 는 비교 대상으로 직접 작업, SDD 작은 작업 경로, SDD 큰 작업 경로 세 가지를 정의해야 한다(MUST).
두 SDD 경로의 이름과 순서는 `skills/orchestra/SKILL.md`의 작은 작업 경로·큰 작업 경로와 같아야 한다(SHALL).
orchestra의 "경량 모드"(worker → finalizer)는 비교 대상이 아니다.
같은 문서에 작업 1건당 1행으로, 한 행 안에 세 비교 대상을 같은 측정 항목(품질 / 소요 시간 / 토큰)으로 적는
기록 표 양식이 있어야 한다(SHALL).

#### Scenario: 비교 대상 정의 확인
- **WHEN** 사람이 문서에서 비교 대상을 찾는다
- **THEN** 직접 작업 / 작은 작업 경로 / 큰 작업 경로 세 가지가 각각 무엇을 뜻하는지 적혀 있다
- **AND** 두 SDD 경로의 단계 순서가 orchestra의 작은 작업 경로·큰 작업 경로와 같다
- **AND** `docs/field-validation.md`에 "경량 경로", "정식 경로"라는 낱말이 없다

#### Scenario: 한 행에 세 대상을 같은 항목으로 기록
- **WHEN** 측정하는 사람이 작업 하나의 결과를 기록 표에 적는다
- **THEN** 그 작업이 한 행을 차지하고, 그 행 안에 세 비교 대상 각각의 품질 / 소요 시간 / 토큰 칸이 있다
- **AND** 세 대상의 칸 이름이 같은 항목으로 짝지어져 있다

## REMOVED Requirements

### Requirement: evals 폴더가 claude plugin eval 사례 뼈대와 안내 문서를 담아야 한다

**Reason**: 본문이 500자를 넘고(1.14.1 strict 실패), "전환 뒤에는 실행할 수 없다는 서술이 남아 있어서는 안 된다(MUST NOT)"가
"전환 뒤 실행할 수 없다"로도 읽히며, 시나리오 이름 "실행 불가 시점"이 본문(실행 위치)과 맞지 않는다.
MODIFIED는 시나리오 이름을 바꿀 수 없어(1.14.1 실측) 새 헤더 두 개로 나눠 다시 넣는다.
**Migration**: 사례 폴더 의무는 ADDED "evals 폴더는 bare 모양의 사례 폴더 두 개를 담아야 한다"로,
안내 문서 의무는 긍정형으로 바꿔 ADDED "evals 안내 문서는 구조와 실행 방법과 실행 위치를 알려야 한다"로 옮겨 간다.

### Requirement: 이 양식은 측정 결과 없이 비어 있는 상태로 제공되어야 한다

**Reason**: "양식을 도입하는 시점에는 측정을 돌리지 않아야 한다(MUST NOT)"와 "기록 표 값 칸은 비어 있어야 한다(MUST)"가
영구 규칙이라 첫 실측이 spec을 깬다. 기록·비교라는 Purpose와 모순된다.
**Migration**: 영구히 유효한 `evals/results/` 미추적 규칙만 ADDED "eval 실행 결과물은 저장소에 추적되지 않아야 한다"로 옮긴다.
측정 금지·빈 칸 규칙은 없앤다. 기록 표는 측정할 때 채운다.

## ADDED Requirements

### Requirement: evals 폴더는 bare 모양의 사례 폴더 두 개를 담아야 한다

저장소 루트의 `evals/` 아래에 `evals/README.md` 가 있어야 한다(SHALL).
`evals/` 아래 사례 폴더는 `claude plugin eval init --bare` 가 만드는 모양, 즉
`<사례>/prompt.md`(frontmatter `max_turns`, `allowed_tools`)와 `<사례>/graders/criteria.md`(frontmatter `type: llm`, `weight`)를
가져야 한다(MUST). 사례 폴더는 작은 작업 경로로 처리할 작은 작업 1개와 직접 작업 대조 1개, 모두 2개여야 한다(SHALL).

#### Scenario: 사례 폴더가 bare 템플릿과 같은 모양
- **WHEN** 사람이 `evals/` 아래 사례 폴더를 나열한다
- **THEN** 사례 폴더가 2개 있고, 각각 `prompt.md` 와 `graders/criteria.md` 를 가진다
- **AND** `prompt.md` frontmatter에 `max_turns`, `allowed_tools` 키가 있고 `graders/criteria.md` frontmatter에 `type: llm`, `weight` 키가 있다

### Requirement: evals 안내 문서는 구조와 실행 방법과 실행 위치를 알려야 한다

`evals/README.md` 는 사례 폴더 구조, `claude plugin eval --ablation with-without` 으로 돌리는 방법,
그리고 저장소 루트(`.claude-plugin/plugin.json` 이 있는 플러그인 루트)에서 실행한다는 사실을 적어야 한다(MUST).
실행 위치는 지금 실행할 수 있는 곳으로 적어야 한다(SHALL).

#### Scenario: README가 실행 방법과 실행 위치를 알린다
- **WHEN** 사람이 `evals/README.md` 를 읽는다
- **THEN** 사례 폴더 구조와 `claude plugin eval --ablation with-without` 실행 방법이 적혀 있다
- **AND** 저장소 루트(plugin.json 이 있는 플러그인 루트)에서 실행한다는 사실이 적혀 있다
- **AND** 사례 설명에 "경량 경로"라는 낱말이 없고 작은 작업 경로로 처리할 작업이라고 적혀 있다

### Requirement: eval 실행 결과물은 저장소에 추적되지 않아야 한다

`claude plugin eval` 실행 결과물(`evals/results/`)은 저장소에 추적되어서는 안 되며(MUST NOT),
`.gitignore` 가 `evals/results/` 를 무시해야 한다(SHALL). 로컬 실행으로 이 폴더가 생길 수 있으므로
"존재하지 않는다" 대신 "추적되지 않는다"로 확인한다.

#### Scenario: eval 결과 폴더가 추적되지 않는다
- **WHEN** 저장소 루트에서 `git ls-files evals/results` 와 `git check-ignore -q evals/results/x; echo $?` 를 돌린다
- **THEN** `git ls-files evals/results` 출력이 비어 있다
- **AND** `git check-ignore -q evals/results/x` 의 종료코드가 0이다
