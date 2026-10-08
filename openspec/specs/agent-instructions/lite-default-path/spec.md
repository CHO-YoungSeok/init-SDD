# agent-instructions/lite-default-path Specification

## Purpose

작은 일은 designer와 regression-verifier 없이 preparer가 proposal과 작업 목록까지 쓰고 worker → reviewer → finalizer로 끝나게 하고, 큰 작업일 때만 설계·회귀 검증 단계를 켜는 분기 규칙을 정한다.

## Requirements

### Requirement: 기본 경로는 작은 작업 경로여야 한다

파이프라인의 기본 경로는 `preparer → worker → reviewer → 커밋 관문 → finalizer`여야
한다(SHALL). 이 경로에서 preparer는 proposal과 작업 목록(tasks.md)을 쓰고, 동작이 바뀌면
작은 specs 델타를, 동작이 안 바뀌면 `.openspec.yaml`의 `skip_specs: true`를 쓴다(SHALL).
design.md는 만들지 않는다.

큰 작업일 때만 designer를 켜고, 그때의 경로는
`preparer → designer → worker → reviewer (+ regression-verifier) → 커밋 관문 → finalizer`다(SHALL).
analyzer는 어느 경로에도 기본으로 들어가지 않는다 — 사용자가 분석을 요청할 때만 부른다.

동작이 안 바뀌는 아주 작은 수정(오타·주석·이름)은 지금처럼 `worker(모드: 경량) →
finalizer(모드: 경량 커밋)`으로 간다. 이 경로는 바뀌지 않는다.

#### Scenario: orchestra 파이프라인 그림

- **WHEN** `.claude/skills/orchestra/SKILL.md`의 파이프라인 그림을 읽는다
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
- **AND** 위 두 시나리오의 결과를 로컬 CLI(1.12.0)와 `npx -y @fission-ai/openspec@1.14.1` 양쪽에서 확인해 보고한다
- **AND** 네트워크가 없어 `npx`가 실패하면 그 출력을 그대로 붙여 1.14.1 쪽을 "못 함"으로 보고한 것으로 이 조건을 충족한 것으로 본다

### Requirement: 큰 작업 판정 기준은 orchestra 한 곳에만 있어야 한다

"큰 작업" 판정 기준은 `.claude/skills/orchestra/SKILL.md`의 한 절에만 적혀야 한다(SHALL).
그 절은 `openspec instructions design`이 design.md를 만들 조건으로 드는 네 가지
(여러 모듈에 걸치거나 새 구조 패턴, 새 외부 의존이나 데이터 모델의 큰 변경, 보안·성능·
마이그레이션 복잡도, 코딩 전에 기술 결정이 필요한 모호함)와 "사용자가 분석·방안 비교를
요청했다"를 모두 담아야 한다(MUST). 하나라도 해당하면 큰 작업이다. 애매하면 큰 작업으로
판정한다(SHALL) — 작은 작업 경로에는 설계 단계가 없어서, 잘못 판정하면 worker가 막힌다.

판정은 preparer가 한다(SHALL). preparer.md에는 네 가지 기준 문장을 다시 적지 않고, 기준을
`openspec instructions design --change "<이름>" --json`의 `instruction`에서 읽으며 정본이
orchestra의 그 절이라는 것을 가리킨다(SHALL). 다른 에이전트 파일에도 판정 기준 문장이 있어서는
안 된다(MUST NOT).

#### Scenario: orchestra에 판정 절이 있다

- **WHEN** `grep -c "큰 작업" .claude/skills/orchestra/SKILL.md`를 돌리고 그 절을 읽는다
- **THEN** 1 이상이다
- **AND** 네 가지 조건과 "분석 요청"이 모두 한 절 안에 적혀 있다
- **AND** 애매하면 큰 작업으로 본다는 지시가 있다

#### Scenario: 에이전트 파일에 기준 사본이 없다

- **WHEN** `.claude/agents/*.md`에서 네 가지 조건을 적은 문장을 찾는다
- **THEN** 없다
- **AND** preparer.md는 판정 기준을 CLI의 `instructions design` 출력과 orchestra 절에서 얻으라고 가리킨다

### Requirement: preparer는 크기 판정을 RESULT 첫 줄에 올려야 한다

`.claude/agents/preparer.md`의 `준비완료` RESULT 형식 줄에는 `size=작음|큼` 필드가
있어야 한다(SHALL). orchestra는 이 값으로 경로를 가른다(SHALL). 중단 RESULT
(`RESULT: 준비중단 | ...`)의 형식은 바꾸지 않는다(MUST NOT) — `branch=` 필드가 그대로 있어야 한다.

preparer는 보고서 본문에 이 프로젝트의 테스트 명령(없으면 "없음")을 적어야 한다(SHALL).
orchestra가 regression-verifier를 켤지 정할 때 쓴다.

#### Scenario: 준비완료 줄에 size가 있다

- **WHEN** `grep -n "size=" .claude/agents/preparer.md`를 돌린다
- **THEN** `RESULT: 준비완료` 형식 줄에 `size=작음|큼`이 있다

#### Scenario: 중단 줄은 그대로다

- **WHEN** preparer.md의 `RESULT: 준비중단` 형식 줄을 읽는다
- **THEN** `branch=` 필드가 있고 `size=` 필드는 없다

### Requirement: 작은 작업일 때 preparer가 작업 목록을 써야 한다

`size=작음`일 때 preparer는 `openspec instructions tasks --change "<이름>" --json`의 지시대로
작업 목록을 써야 한다(SHALL). 동작(요구사항)이 바뀌면 `openspec instructions specs` 지시대로
작은 specs 델타를 쓰고, 안 바뀌면 `skip_specs: true` 마커를 넣는다(SHALL). 마지막에
`openspec validate "<이름>" --strict`와 `openspec status --change "<이름>" --json`의 종료코드를
둘 다 확인한다(SHALL).

`size=큼`일 때는 지금처럼 proposal까지만 쓴다(SHALL). specs·design·tasks는 designer가 쓴다.

preparer.md의 마커 명령 블록(기존 키 보존, 멱등, 두 종료코드 확인, `.openspec.yaml` 직접
열어 세 가지 확인)은 그대로 남아야 한다(MUST).

#### Scenario: preparer가 tasks와 델타 선택을 지시한다

- **WHEN** `.claude/agents/preparer.md`를 읽는다
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

작은 작업 경로에서는 reviewer가 프로젝트의 테스트 명령을 **한 번** 돌려 결과를 review.md와
RESULT에 남긴다(SHALL). `.claude/agents/reviewer.md`에 이 지시가 있어야 한다(MUST).
테스트 명령이 없으면 돌리지 않고 "테스트 없음"으로 적는다.

실행 코드가 바뀌었는지는 orchestra가 worker 보고서의 만진 파일 목록으로 판단한다(SHALL).

regression-verifier를 부르지 않았으면 orchestra는 finalizer 프롬프트에
`regression 판정: 생략(<이유>)`을 글자로 적어 보내야 한다(SHALL). 이유는 `작은 작업`,
`테스트 명령 없음`, `실행 코드 변경 없음`(큰 작업이지만 만진 파일에 실행 코드가 없음) 중 하나다. finalizer는 이 줄이 있으면
회귀 판정 없이 진행하고, `regression 판정:` 줄이 **아예 없으면** 지금처럼 멈춘다(SHALL).

#### Scenario: orchestra에 호출 조건이 있다

- **WHEN** `.claude/skills/orchestra/SKILL.md`에서 regression-verifier 호출 조건을 찾는다
- **THEN** "실행 코드 + 테스트 명령"이 있을 때만 부른다는 조건이 적혀 있다

#### Scenario: reviewer가 작은 작업에서 테스트를 한 번 돌린다

- **WHEN** `.claude/agents/reviewer.md`를 읽는다
- **THEN** 프롬프트가 테스트를 맡기면 프로젝트 테스트 명령을 한 번 돌리고 결과를 review.md와 RESULT의 `tests=`에 남기라는 지시가 있다

#### Scenario: 회귀 판정 줄이 없으면 finalizer가 멈춘다

- **WHEN** finalizer 프롬프트에 `regression 판정:` 줄이 아예 없다 (경량 커밋·WIP 커밋 모드가 아님)
- **THEN** finalizer는 커밋하지 않고 "회귀 검증 안 거침"으로 보고한다
- **AND** `regression 판정: 생략(작은 작업)`이 있으면 그 사실을 보고서에 적고 진행한다

### Requirement: designer 생략 금지 지시가 없어야 하고, 작은 작업의 설계 구멍은 큰 작업으로 올려야 한다

orchestra에서 "designer를 생략하면 안 된다"는 지시는 없어야 한다(MUST NOT). 작업 목록을
preparer도 쓰게 되었으므로 그 이유가 사라졌다.

작은 작업 경로에서 worker가 설계 구멍을 들고 오거나 사용자가 분석을 요청하면, orchestra는
그 change를 큰 작업으로 올려 designer를 불러야 한다(SHALL). 이때 designer는 preparer가 쓴
산출물을 **이미 있는 산출물을 고치는 절차**로 이어받는다.

#### Scenario: 생략 금지 문구가 없다

- **WHEN** `grep -n "designer를 생략하면 안 된다" .claude/skills/orchestra/SKILL.md`를 돌린다
- **THEN** 결과가 0건이다

#### Scenario: 작은 작업이 큰 작업으로 올라간다

- **WHEN** orchestra에서 작은 작업 경로의 worker가 설계 구멍을 보고한 경우의 지시를 읽는다
- **THEN** 큰 작업으로 올려 designer를 부르라는 지시가 있다
- **AND** designer 프롬프트에 preparer가 쓴 산출물이 이미 있다는 사실이 실린다
