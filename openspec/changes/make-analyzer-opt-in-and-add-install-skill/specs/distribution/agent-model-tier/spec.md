## Purpose

서브에이전트 7개가 어느 모델로 도는지를 등급 하나로 한 번에 바꾸는 절차를 정한다.
토큰을 아끼려고 등급을 내릴 수 있고 언제든 원래 등급으로 되돌아올 수 있어야 하며,
등급을 바꾸는 일이 지침 파일을 망가뜨리지 않아야 한다.

## ADDED Requirements

### Requirement: 모델 등급 스킬은 활성 스킬로 놓여야 한다

모델 등급 전환 절차는 `.claude/skills/agent-model-tier/SKILL.md`에 있어야 한다(SHALL).
개발 중에도 바로 쓰는 도구이므로 활성 스킬이어야 한다. 동시에 이 스킬은 `install.sh`가
대상 프로젝트에 깔아 주는 **제품 5종 중 하나**이기도 하다.

frontmatter에는 `name:`과 `description:`이 있어야 하고(MUST), `description:`은 **언제
발동하는지**를 담아야 한다(MUST). 최소한 모델을 낮추라는 말, 토큰을 아끼라는 말, 등급 이름을
직접 부르는 말, 원래대로 되돌리라는 말에 걸려야 한다.

frontmatter에 `allowed-tools:` 키를 적어서는 안 된다(MUST NOT). 이 스킬은 에이전트 파일을
고쳐야 한다. 어떤 목록을 적어도 그것은 도구를 좁히는 것이다.

#### Scenario: 스킬 파일의 위치와 frontmatter

- **WHEN** `.claude/skills/agent-model-tier/SKILL.md`를 읽는다
- **THEN** 파일이 존재하고 `---`로 열리고 닫히는 frontmatter에 `name:`과 `description:`이 있다
- **AND** `allowed-tools:` 라는 키가 파일 어디에도 없다

#### Scenario: description의 발동 조건

- **WHEN** frontmatter `description:` 값을 읽는다
- **THEN** 모델을 낮추라는 말, 토큰을 아끼라는 말, 등급 이름(`semi-lower`, `lower`,
  `normal`)을 부르는 말, 되돌리라는 말이 발동 조건으로 들어 있다

### Requirement: 등급 세 개의 값 표가 스킬 안에 값으로 있어야 한다

스킬은 `normal`, `semi-lower`, `lower` 세 등급에 대해 **에이전트 7개 전부의 모델 값**을
표로 갖고 있어야 한다(SHALL). 값은 다음과 같아야 한다(MUST):

| 에이전트 | normal | semi-lower | lower |
|---|---|---|---|
| preparer | sonnet | haiku | haiku |
| analyzer | opus | sonnet | haiku |
| designer | opus | sonnet | haiku |
| worker | sonnet | haiku | haiku |
| reviewer | opus | sonnet | haiku |
| regression-verifier | sonnet | haiku | haiku |
| finalizer | sonnet | haiku | haiku |

`semi-lower`는 역할을 특별 취급하지 않는다. **각 에이전트를 한 단계씩 내린 값**이어야
한다(MUST): `opus → sonnet`, `sonnet → haiku`. 스킬은 이 규칙을 표와 함께 적어야 한다(MUST) —
규칙이 있으면 표를 손으로 고칠 때 틀리지 않는다.

`normal` 표를 빼서는 안 된다(MUST NOT). 지금 값을 읽어 기억하는 방식으로는 **이미 등급이
내려간 상태에서 되돌릴 수 없다.** 되돌리기가 되려면 원래 값이 스킬 안에 값으로 있어야 한다.

모델 값은 이 저장소가 쓰는 짧은 이름(`opus`, `sonnet`, `haiku`)이어야 한다(MUST).
전체 모델 ID를 적어서는 안 된다(MUST NOT) — 버전이 올라가면 낡는다.

#### Scenario: 세 등급 표가 다 있다

- **WHEN** `.claude/skills/agent-model-tier/SKILL.md`의 등급 표를 읽는다
- **THEN** `normal`, `semi-lower`, `lower` 세 등급이 모두 있고 각 등급마다 에이전트 7개의
  값이 빠짐없이 적혀 있다

#### Scenario: normal 표가 실제 값과 같다

- **WHEN** `normal` 등급의 값과 `.claude/agents/*.md` 7개의 frontmatter `model:` 값을 대조한다
- **THEN** preparer sonnet, analyzer opus, designer opus, worker sonnet, reviewer opus,
  regression-verifier sonnet, finalizer sonnet으로 모두 같다

#### Scenario: semi-lower와 lower의 값

- **WHEN** `semi-lower`와 `lower` 표를 읽는다
- **THEN** `semi-lower`에서 analyzer·designer·reviewer가 sonnet이고
  preparer·worker·regression-verifier·finalizer가 haiku다
- **AND** `semi-lower`의 모든 값이 `normal`의 같은 칸을 한 단계 내린 값이다
  (`opus → sonnet`, `sonnet → haiku`)
- **AND** `lower`는 7개 전부 haiku다

#### Scenario: 한 단계 내리는 규칙이 적혀 있다

- **WHEN** 등급 표 근처의 설명을 읽는다
- **THEN** `semi-lower`가 각 에이전트를 한 단계 내린 것이라는 규칙(`opus → sonnet`,
  `sonnet → haiku`)이 적혀 있다
- **AND** 특정 역할을 특별 취급한다는 서술이 없다

#### Scenario: 모델 값의 표기

- **WHEN** 세 표의 모델 값을 읽는다
- **THEN** 값이 `opus`, `sonnet`, `haiku` 중 하나이고, 날짜나 버전이 붙은 전체 모델 ID가 없다

### Requirement: 지금 등급을 판별할 수 있고 섞인 상태를 짐작해서는 안 된다

스킬은 지금 어느 등급인지 알려 주는 동작을 제공해야 한다(SHALL). 판별은 에이전트 파일 7개의
frontmatter `model:` 값을 읽어 등급 표와 대조하는 방식이어야 한다(MUST).

7개 값이 어느 표와도 정확히 맞지 않으면 **"섞인 상태"로 보고해야 한다**(SHALL).
그때 어느 등급에 가깝다고 짐작해서는 안 되며(MUST NOT), 7개의 실제 값을 그대로 보여 준 뒤
사용자가 등급을 고르게 해야 한다(MUST).

섞인 상태에서 등급을 적용하면 사용자가 손으로 맞춰 둔 값이 사라진다. 그 사실과, 지금 값
목록을 사용자가 남겨 둘 수 있게 먼저 보여 주어야 한다(MUST) — `normal`은 표에서 되돌아오지만
섞인 상태는 어디에도 기록되지 않는다.

#### Scenario: 등급이 표와 정확히 맞을 때

- **WHEN** 7개 파일의 `model:` 값이 `normal` 표와 모두 같은 상태에서 등급을 조회한다
- **THEN** 지금 등급이 `normal`이라고 알려 준다

#### Scenario: 섞인 상태

- **WHEN** 사용자가 `worker`만 손으로 haiku로 고쳐 둔 상태에서 등급을 조회한다
- **THEN** 어느 등급이라고 답하지 않고 "섞인 상태"라고 보고한다
- **AND** 에이전트 7개의 실제 `model:` 값을 그대로 보여 준다
- **AND** 등급을 적용하면 그 값이 사라진다는 것을 알린다

### Requirement: 등급 적용은 양방향이고 몇 번을 해도 같은 결과여야 한다

세 등급 사이를 어느 방향으로든 옮길 수 있어야 한다(SHALL). 특히 `normal`로 되돌아오는 길이
항상 있어야 한다(MUST).

이미 적용된 등급을 다시 적용하는 것은 아무것도 바꾸지 않는 동작이어야 한다(MUST).
같은 등급을 두 번, 세 번 적용해도 결과가 같아야 한다(MUST).

#### Scenario: 같은 등급을 다시 적용한다

- **WHEN** 지금 `lower`인 상태에서 `lower`를 다시 적용한다
- **THEN** 파일이 하나도 바뀌지 않는다
- **AND** 이미 그 등급이라는 것을 알린다

#### Scenario: 내렸다가 되돌린다

- **WHEN** `normal`에서 `lower`로 내리고 다시 `normal`로 되돌린다
- **THEN** 7개 파일의 `model:` 값이 처음 `normal` 상태와 같다

### Requirement: 등급을 갈 때 `model:` 한 줄만 고쳐야 한다

스킬 절차는 에이전트 파일의 **frontmatter `model:` 한 줄만** 부분 수정하라고 지시해야
한다(SHALL). 파일 전체를 다시 쓰는 방식과 `sed -i` 같은 제자리 치환을 금지한다고 적어야
한다(MUST). 전체 재작성 경로에서 리치 마크다운 토큰 삽입과 들여쓰기 붕괴가 일어난 사고가
실제로 있었고, 스킬을 쓰는 쪽이 이 규칙을 모르면 지침 파일을 망친다.

등급을 갈고 난 뒤 각 에이전트 파일은 다음을 만족해야 한다(MUST): frontmatter가 `---` 두 줄을
유지하고 `name:`, `description:`, `model:`, `tools:` 키를 모두 갖고 있으며, `model:`로
시작하는 줄이 파일마다 정확히 하나이고, 리치 마크다운 토큰이 없다.

#### Scenario: 스킬에 적힌 제약

- **WHEN** `.claude/skills/agent-model-tier/SKILL.md`의 파일 고치는 방법을 적은 절을 읽는다
- **THEN** `model:` 한 줄만 부분 수정하라고 적혀 있다
- **AND** 전체 재작성 금지와 `sed -i` 금지가 적혀 있고 그 이유가 함께 있다

#### Scenario: 등급을 간 뒤의 파일 무결성

- **WHEN** 등급을 갈고 난 뒤 `.claude/agents/*.md` 7개를 검사한다
- **THEN** 각 파일의 frontmatter가 `---`로 열리고 닫히며 `name:`, `description:`, `model:`,
  `tools:` 키를 모두 갖고 있다
- **AND** 각 파일에서 `model:`로 시작하는 줄이 정확히 하나다
- **AND** `grep -c 'ORCA_RICH_MD'` 결과가 모두 0이다

#### Scenario: 등급 변경의 diff 범위

- **WHEN** 등급을 갈고 `git diff`를 본다
- **THEN** 바뀐 줄이 `model:` 줄들뿐이다

### Requirement: 등급을 낮추면 무엇이 나빠지는지 경고해야 한다

스킬은 등급을 낮출 때 무엇이 나빠지는지 사용자에게 알려야 한다(SHALL). 이 실패 모드는
**조용하다** — 에러가 나지 않고 정해진 동작이 조금씩 줄어드는 방식으로 나타나므로,
사용자가 미리 알지 못하면 원인을 등급에서 찾지 못한다.

경고에는 최소한 다음이 들어가야 한다(MUST):

1. `worker`가 약해지면 **멈출 줄 아는 판단**이 약해져 정해진 동작을 조용히 줄인다는 것
   (`.claude/skills/orchestra/SKILL.md`가 이미 같은 이유로 작업이 많을 때 worker를 opus로
   올리라고 적고 있다)
2. `reviewer`와 `designer`가 약해지면 판정과 설계의 질이 내려간다는 것
   (`README.md`가 비용이 부담되면 이 셋을 내리라고 안내하는 것과 같은 자리다)
3. 낮춘 등급으로 큰 일을 돌리지 말라는 권고, 그리고 `normal`로 되돌리는 방법

#### Scenario: 경고 내용

- **WHEN** `.claude/skills/agent-model-tier/SKILL.md`의 경고 절을 읽는다
- **THEN** `worker`가 약해지면 멈출 줄 아는 판단이 약해진다는 서술이 있다
- **AND** `reviewer`·`designer`가 약해질 때의 영향이 적혀 있다
- **AND** `normal`로 되돌리는 방법이 함께 적혀 있다

#### Scenario: 낮출 때 사용자에게 알린다

- **WHEN** 사용자가 `lower`를 적용한다
- **THEN** 바꾸기 전에 그 경고를 사용자에게 보여 준다
