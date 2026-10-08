# Spec Delta

## MODIFIED Requirements

### Requirement: 스킬 호출 근거 문단은 sdd-rules 한 곳에서 allowed-tools 제약을 근거로 들어야 한다

"openspec 스킬을 왜 부르지 않는가"를 설명하는 문단은 `skills/sdd-rules/SKILL.md`의
쓰는 스킬 절 **한 곳에만** 있어야 한다(SHALL). `agents/preparer.md`,
`agents/designer.md`, `agents/worker.md`, `agents/finalizer.md`,
`agents/analyzer.md`에는 그 문단의 사본이 있어서는 안 된다(MUST NOT). 에이전트는
frontmatter `skills:`로 sdd-rules를 주입받는다.

"`Skill` 도구가 없을 수 있다"는 서술은 사실이 아니므로 sdd-rules와 다섯 에이전트 파일 어디에도
있어서는 안 된다(MUST NOT).

#### Scenario: 거짓 근거가 사라진다

- **WHEN** sdd-rules와 다섯 에이전트 파일에서 "`Skill` 도구가 없을 수 있다"를 찾는다
- **THEN** 어디에도 남아 있지 않다

#### Scenario: 진짜 근거가 들어간다

- **WHEN** 에이전트가 왜 openspec 스킬을 부르지 않는지 확인한다
- **THEN** sdd-rules에서 `allowed-tools: Bash(openspec:*)` 때문에 스킬 실행 중 도구가 좁혀진다는 근거를 읽는다
- **AND** 대신 `openspec instructions <artifact>` 출력을 따르라는 지시를 읽는다

#### Scenario: 결론 문장은 sdd-rules에 있다

- **WHEN** 에이전트가 스킬을 부르지 못하는 상황을 만난다
- **THEN** 주입받은 sdd-rules에 "스킬을 못 부른다는 이유로 절대 멈추지 마라."는 문장이 있어 멈추지 않는다

#### Scenario: 문단이 한 벌뿐이다

- **WHEN** `grep -c "allowed-tools: Bash(openspec:"`를 다섯 에이전트 파일과 sdd-rules에 각각 돌린다
- **THEN** sdd-rules에서만 1 이상이고, 다섯 에이전트 파일은 모두 0이다
- **AND** 다섯 에이전트 파일 어디에도 스캐폴드 SKILL.md를 Read로 읽으라는 지시가 없다

## ADDED Requirements

### Requirement: 스킬 호출 근거 문단은 대신 따를 것과 근거와 결론을 함께 담아야 한다

sdd-rules의 스킬 호출 근거 문단은 다음 세 가지를 담아야 한다(SHALL):
(a) `openspec init`이 까는 openspec 스킬은 부르지도, 그 SKILL.md를 읽고 따르지도 않으며,
산출물은 `openspec instructions <artifact>` 출력의 지시를 따를 것,
(b) 그 근거로 openspec 스킬이 frontmatter에 `allowed-tools: Bash(openspec:*)`를 선언해
스킬이 도는 동안 쓸 수 있는 도구가 `openspec` 셸 명령 하나로 좁혀져 산출물 파일도 못 쓰고
코드도 못 고친다는 사실,
(c) 결론 문장 "스킬을 못 부른다는 이유로 절대 멈추지 마라."

#### Scenario: 세 요소가 한 문단에 있다

- **WHEN** `skills/sdd-rules/SKILL.md`의 "쓰는 스킬" 절에서 openspec 스킬을 부르지 않는 이유를 적은 인용 문단을 읽는다
- **THEN** openspec 스킬을 부르지도 읽고 따르지도 않는다는 지시가 있다
- **AND** `allowed-tools: Bash(openspec:*)` 근거가 있다
- **AND** "스킬을 못 부른다는 이유로 절대 멈추지 마라."가 있다
