## MODIFIED Requirements

### Requirement: 모델 등급 스킬은 활성 스킬로 놓여야 한다

모델 등급 전환 절차는 `.claude/skills/agent-model-tier/SKILL.md`에 있어야 한다(SHALL).
개발 중에도 바로 쓰는 도구이므로 활성 스킬이어야 한다. 동시에 이 스킬은 `install.sh`가
대상 프로젝트에 깔아 주는 **제품 5종 중 하나**이기도 하다.

frontmatter에는 `name:`과 `description:`이 있어야 하고(MUST), `description:`은 **언제
발동하는지**를 담아야 한다(MUST). 최소한 모델을 낮추라는 말, 토큰을 아끼라는 말, 등급 번호를
직접 부르는 말, 원래대로 되돌리라는 말에 걸려야 한다.

frontmatter에 `allowed-tools:` 키를 적어서는 안 된다(MUST NOT). 이 스킬은 에이전트 파일을
고쳐야 한다. 어떤 목록을 적어도 그것은 도구를 좁히는 것이다.

#### Scenario: 스킬 파일의 위치와 frontmatter

- **WHEN** `.claude/skills/agent-model-tier/SKILL.md`를 읽는다
- **THEN** 파일이 존재하고 `---`로 열리고 닫히는 frontmatter에 `name:`과 `description:`이 있다
- **AND** `allowed-tools:` 라는 키가 파일 어디에도 없다

#### Scenario: description의 발동 조건

- **WHEN** frontmatter `description:` 값을 읽는다
- **THEN** 모델을 낮추라는 말, 토큰을 아끼라는 말, 등급 번호(`1`, `2`, `4`)를 부르는 말,
  되돌리라는 말이 발동 조건으로 들어 있다

### Requirement: 등급 세 개의 값 표가 스킬 안에 값으로 있어야 한다

스킬은 `1`, `2`, `4` (5단계 중 지금 정의된 세 등급)에 대해 **에이전트 7개 전부의 모델 값**을
표로 갖고 있어야 한다(SHALL). 값은 다음과 같아야 한다(MUST):

| 에이전트 | 1/5 | 2/5 | 4/5 (기본값) |
|---|---|---|---|
| preparer | haiku | haiku | sonnet |
| analyzer | haiku | sonnet | opus |
| designer | haiku | sonnet | opus |
| worker | haiku | haiku | sonnet |
| reviewer | haiku | sonnet | opus |
| regression-verifier | haiku | haiku | sonnet |
| finalizer | haiku | haiku | sonnet |

`3`과 `5`는 나중 등급 확장을 위해 비워 둔다(MUST) — 지금은 값이 정의되어 있지 않다. 표에
빈 칸이나 자리표시자 열을 넣어서는 안 되고(MUST NOT), 두 값이 아직 정의되지 않았다는 사실만
문장으로 적어야 한다(MUST). 정의되지 않은 값을 표에 열로 넣으면 "지금 등급을 판별할 수
있고" 요구사항의 정확한 대조(표 전체 일치)가 빈 칸과 무엇을 비교해야 할지 알 수 없게 되어
깨진다.

`2/5`는 역할을 특별 취급하지 않는다. **각 에이전트를 한 단계씩 내린 값**이어야
한다(MUST): `opus → sonnet`, `sonnet → haiku`. 스킬은 이 규칙을 표와 함께 적어야 한다(MUST) —
규칙이 있으면 표를 손으로 고칠 때 틀리지 않는다.

`4/5` 표를 빼서는 안 된다(MUST NOT). 지금 값을 읽어 기억하는 방식으로는 **이미 등급이
내려간 상태에서 되돌릴 수 없다.** 되돌리기가 되려면 기본값이 스킬 안에 값으로 있어야 한다.

모델 값은 이 저장소가 쓰는 짧은 이름(`opus`, `sonnet`, `haiku`)이어야 한다(MUST).
전체 모델 ID를 적어서는 안 된다(MUST NOT) — 버전이 올라가면 낡는다.

#### Scenario: 세 등급 표가 다 있다

- **WHEN** `.claude/skills/agent-model-tier/SKILL.md`의 등급 표를 읽는다
- **THEN** `1`, `2`, `4` 세 등급이 모두 있고 각 등급마다 에이전트 7개의 값이 빠짐없이 적혀 있다
- **AND** `3`과 `5`는 표에 열로 없고, 아직 정의되지 않았다는 문장만 있다

#### Scenario: normal 표가 실제 값과 같다

- **WHEN** `4/5` 등급의 값과 `.claude/agents/*.md` 7개의 frontmatter `model:` 값을 대조한다
- **THEN** preparer sonnet, analyzer opus, designer opus, worker sonnet, reviewer opus,
  regression-verifier sonnet, finalizer sonnet으로 모두 같다

#### Scenario: semi-lower와 lower의 값

- **WHEN** `2/5`와 `1/5` 표를 읽는다
- **THEN** `2/5`에서 analyzer·designer·reviewer가 sonnet이고
  preparer·worker·regression-verifier·finalizer가 haiku다
- **AND** `2/5`의 모든 값이 `4/5`의 같은 칸을 한 단계 내린 값이다
  (`opus → sonnet`, `sonnet → haiku`)
- **AND** `1/5`는 7개 전부 haiku다

#### Scenario: 한 단계 내리는 규칙이 적혀 있다

- **WHEN** 등급 표 근처의 설명을 읽는다
- **THEN** `2/5`가 각 에이전트를 한 단계 내린 것이라는 규칙(`opus → sonnet`,
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
목록을 사용자가 남겨 둘 수 있게 먼저 보여 주어야 한다(MUST) — 기본값(`4/5`)은 표에서
되돌아오지만 섞인 상태는 어디에도 기록되지 않는다.

#### Scenario: 등급이 표와 정확히 맞을 때

- **WHEN** 7개 파일의 `model:` 값이 `4/5` 표와 모두 같은 상태에서 등급을 조회한다
- **THEN** 지금 등급이 `4/5`라고 알려 준다

#### Scenario: 섞인 상태

- **WHEN** 사용자가 `worker`만 손으로 haiku로 고쳐 둔 상태에서 등급을 조회한다
- **THEN** 어느 등급이라고 답하지 않고 "섞인 상태"라고 보고한다
- **AND** 에이전트 7개의 실제 `model:` 값을 그대로 보여 준다
- **AND** 등급을 적용하면 그 값이 사라진다는 것을 알린다

### Requirement: 등급 적용은 양방향이고 몇 번을 해도 같은 결과여야 한다

세 등급 사이를 어느 방향으로든 옮길 수 있어야 한다(SHALL). 특히 기본값(`4/5`)으로
되돌아오는 길이 항상 있어야 한다(MUST).

이미 적용된 등급을 다시 적용하는 것은 아무것도 바꾸지 않는 동작이어야 한다(MUST).
같은 등급을 두 번, 세 번 적용해도 결과가 같아야 한다(MUST).

사용자는 이제 등급을 숫자로만 지정할 수 있다(MUST) — 문자열 이름(예: `normal`,
`semi-lower`, `lower`)으로는 더 이상 등급을 고를 수 없다(MUST NOT), 하위 호환이 없다.
스킬은 `1`, `2`, `4` 외의 값(문자열 등급 이름, `3`, `5`, 그 밖의 숫자)을 등급으로
받아들여서는 안 된다(MUST NOT). 그런 입력이 오면 아무 파일도 바꾸지 않고(MUST), 지금
쓸 수 있는 값이 `1`, `2`, `4`뿐이라고 알려야 한다(MUST).

#### Scenario: 같은 등급을 다시 적용한다

- **WHEN** 지금 `1`인 상태에서 `1`을 다시 적용한다
- **THEN** 파일이 하나도 바뀌지 않는다
- **AND** 이미 그 등급이라는 것을 알린다

#### Scenario: 내렸다가 되돌린다

- **WHEN** `4`에서 `1`로 내리고 다시 `4`로 되돌린다
- **THEN** 7개 파일의 `model:` 값이 처음 `4` 상태와 같다

#### Scenario: 정의되지 않은 입력을 거부한다

- **WHEN** 사용자가 `normal`처럼 문자열 이름이나 `3`, `5`를 등급으로 요청한다
- **THEN** 스킬은 아무 파일도 바꾸지 않는다
- **AND** 지금 쓸 수 있는 값이 `1`, `2`, `4`뿐이라고 알린다

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
3. 낮춘 등급으로 큰 일을 돌리지 말라는 권고, 그리고 기본값(`4/5`)으로 되돌리는 방법

#### Scenario: 경고 내용

- **WHEN** `.claude/skills/agent-model-tier/SKILL.md`의 경고 절을 읽는다
- **THEN** `worker`가 약해지면 멈출 줄 아는 판단이 약해진다는 서술이 있다
- **AND** `reviewer`·`designer`가 약해질 때의 영향이 적혀 있다
- **AND** 기본값(`4/5`)으로 되돌리는 방법이 함께 적혀 있다

#### Scenario: 낮출 때 사용자에게 알린다

- **WHEN** 사용자가 `1/5`(가장 낮은 등급)를 적용한다
- **THEN** 바꾸기 전에 그 경고를 사용자에게 보여 준다

### Requirement: code-explorer는 등급 표 밖에 있어야 하고 표 자체는 늘어나지 않아야 한다

`code-explorer`가 새로 생겨도 `.claude/skills/agent-model-tier/SKILL.md`의 `1/5` /
`2/5` / `4/5` 등급 표는 여전히 에이전트 7개 행만 가져야 한다(MUST NOT 늘어남).
`code-explorer`는 이 스킬이 순회하는 대상이 아니고 언제나 `haiku`로 고정된다.

표 아래(또는 표와 같은 절 안)에 "`code-explorer`는 등급 표 밖, 항상 haiku"라는 취지의
한 줄 안내가 있어야 한다(SHALL). 스킬의 등급 판별·전환 절차는 `.claude/agents/code-explorer.md`의
`model:` 줄을 읽거나 고치지 않아야 한다(MUST NOT) — 이 스킬이 순회하는 파일 목록은 기존
7개 에이전트 파일 그대로다.

#### Scenario: 등급 표는 7행 그대로다

- **WHEN** 변경 뒤 `.claude/skills/agent-model-tier/SKILL.md`의 `1/5`/`2/5`/`4/5`
  표를 읽는다
- **THEN** 각 표가 여전히 7행이고 `code-explorer` 행이 없다

#### Scenario: 표 밖이라는 한 줄 안내가 있다

- **WHEN** 표 근처의 서술을 읽는다
- **THEN** `code-explorer`는 등급 표 밖에 있고 항상 `haiku`로 고정된다는 문장이 있다

#### Scenario: 등급 전환이 code-explorer를 건드리지 않는다

- **WHEN** 등급을 `4/5`에서 `1/5`로, 다시 `4/5`로 되돌린다
- **THEN** `.claude/agents/code-explorer.md`의 `model:` 값은 두 전환 전체에 걸쳐 `haiku`로
  바뀌지 않는다
- **AND** `git diff`로 봤을 때 `code-explorer.md`는 등급 전환의 변경 대상에 없다
