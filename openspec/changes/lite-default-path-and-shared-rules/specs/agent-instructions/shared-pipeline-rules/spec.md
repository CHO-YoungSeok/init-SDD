## Purpose

SDD 서브에이전트 7개가 함께 지키는 규칙을 `sdd-rules` 스킬 한 곳에 두고 frontmatter로 주입해, 같은 규칙의 사본이 에이전트마다 갈라지지 않게 한다. 또 OpenSpec 스캐폴드 스킬 문서 없이 CLI 지시와 `sdd-sync` 스킬만으로 파이프라인이 돌게 한다.

## ADDED Requirements

### Requirement: 공용 규칙은 sdd-rules 스킬 한 곳에 있어야 한다

`.claude/skills/sdd-rules/SKILL.md`가 있어야 한다(SHALL). 이 파일은 서브에이전트 공용 규칙
7종을 각각 **하나의 절**로 담아야 한다(MUST): 쓰는 스킬과 그 근거, 대화형 스킬을 만났을 때,
store 처리, code-explorer 부르기, 되돌릴 수 없는 일, RESULT 한 줄 보고 형식의 공통 규칙,
파일을 Edit로 부분 수정하는 규칙. 절 제목에는 `store 처리`, `code-explorer 부르기`,
`대화형 스킬을 만났을 때`라는 글자가 그대로 들어가야 한다(SHALL).

frontmatter는 `name`과 `description`만 가져야 하며(SHALL), `allowed-tools`를 넣어서는 안
된다(MUST NOT). 이 스킬은 에이전트에 주입되는 규칙 묶음이라, 도구를 좁히면 주입받은
에이전트가 파일을 못 쓰게 될 수 있다. `description`은 비워 두지 않고, 서브에이전트 공용
규칙이며 frontmatter `skills:`로 주입된다는 것을 알 수 있게 적어야 한다(SHALL).

#### Scenario: 파일과 frontmatter

- **WHEN** `.claude/skills/sdd-rules/SKILL.md`의 frontmatter를 읽는다
- **THEN** `---`로 열고 닫히며 키가 `name: sdd-rules`와 `description:` 둘뿐이다
- **AND** `allowed-tools` 키가 없다

#### Scenario: 일곱 절이 각각 한 번씩 있다

- **WHEN** `grep -nE "^#+ (store 처리|code-explorer 부르기|대화형 스킬을 만났을 때)" .claude/skills/sdd-rules/SKILL.md`를 돌린다
- **THEN** 세 제목이 각각 정확히 한 번 나온다
- **AND** 쓰는 스킬, 되돌릴 수 없는 일, RESULT 형식, Edit 부분 수정을 다루는 절도 각각 하나씩 있다

### Requirement: 에이전트 본문에는 공용 규칙 절이 다시 나와서는 안 된다

`.claude/agents/*.md`의 본문에는 sdd-rules가 담은 공용 규칙 절이 다시 있어서는 안
된다(MUST NOT). 에이전트 본문에는 그 에이전트의 **역할**만 남긴다(SHALL).

역할에 딸린 것은 에이전트 파일에 남아야 한다(SHALL): 각 에이전트의 RESULT 상태 낱말과
역할별 필드(`branch=`, `store=`, `size=`, `scope=`, `mode=`, `tasks=`, `tests=`,
`spec_sync=` 등), preparer·designer의 마커 명령 블록, designer 1단계와 finalizer의
원본 파일 대조 규칙. sdd-rules에는 그 역할별 필드를 옮기지 않는다(MUST NOT).

#### Scenario: 반복 절 제목이 에이전트에 없다

- **WHEN** `grep -nE "^#+ (store 처리|code-explorer 부르기|대화형 스킬을 만났을 때)" .claude/agents/*.md`를 돌린다
- **THEN** 결과가 0건이다

#### Scenario: 역할별 RESULT 필드는 에이전트에 남는다

- **WHEN** preparer·reviewer·regression-verifier·worker·finalizer의 보고 형식 절을 읽는다
- **THEN** 각자의 RESULT 상태 낱말과 역할별 필드(`branch=`, `size=`, `scope=`, `mode=`, `spec_sync=` 등)가 그 파일에 있다
- **AND** sdd-rules의 RESULT 절에는 공통 형식(첫 줄, 필드 구분, 판정 낱말 붙여쓰기)만 있다

### Requirement: 공용 규칙은 frontmatter skills로 주입되어야 한다

code-explorer를 뺀 7개 에이전트 파일(preparer, analyzer, designer, worker, reviewer,
regression-verifier, finalizer)의 frontmatter `skills:`에는 `sdd-rules`가 있어야
한다(SHALL). finalizer는 `sdd-sync`도 가져야 한다(SHALL). 어느 에이전트의 `skills:`에도
`openspec-`로 시작하는 스킬 이름이 있어서는 안 된다(MUST NOT).

`code-explorer.md`에는 `skills:`를 넣지 않는다(SHALL) — 공용 규칙은 다른 에이전트를 부르고
산출물을 다루는 에이전트를 위한 것이고, code-explorer는 읽기만 하는 보조 에이전트다.

주입이 실제로 일어나는지는 새로 띄운 Claude Code 프로세스에서 확인할 수 있어야 한다(SHALL).
frontmatter `skills:`는 세션이 시작될 때 읽히므로 같은 세션 안에서는 확인할 수 없다.

#### Scenario: frontmatter의 skills 줄

- **WHEN** 7개 에이전트 파일의 frontmatter를 읽는다
- **THEN** 모두 `skills:`에 `sdd-rules`가 있고, finalizer만 `sdd-sync`도 있다
- **AND** 어디에도 `openspec-`로 시작하는 스킬 이름이 없다
- **AND** `code-explorer.md`에는 `skills:` 줄이 없다

#### Scenario: 새 프로세스에서 주입을 확인한다

- **WHEN** 저장소 사본에서 새 `claude -p` 프로세스를 띄워, 각 에이전트에게 sdd-rules에만 있는 문장을 인용하게 한다
- **THEN** 7개 에이전트는 그 문장을 인용하고, code-explorer는 인용하지 못한다
- **AND** 그 방법과 결과가 change의 `review.md`에 남아 있다

### Requirement: 파이프라인은 OpenSpec 스캐폴드 스킬 문서에 기대지 않아야 한다

에이전트 파일, orchestra 스킬, sdd-rules, sdd-sync는 `openspec init`이 까는 스캐폴드 스킬
문서(`.claude/skills/openspec-*/SKILL.md`)를 읽으라고 지시해서는 안 된다(MUST NOT).
산출물은 `openspec instructions <artifact> --change "<이름>" --json` 출력의 지시를
따르고(SHALL), spec 병합은 `sdd-sync` 스킬을, archive는 `openspec archive` CLI를 쓴다(SHALL).

스캐폴드 스킬 디렉터리가 디스크에서 사라져도 파이프라인이 멈추지 않아야 한다(SHALL).

#### Scenario: 스캐폴드 참조가 없다

- **WHEN** `grep -rnE "skills/openspec-|openspec-(explore|propose|apply-change|archive-change|sync-specs|update-change)" .claude/agents .claude/skills/orchestra .claude/skills/sdd-rules .claude/skills/sdd-sync`를 돌린다
- **THEN** 결과가 0건이다

#### Scenario: 스캐폴드를 지운 사본에서 CLI 지시가 모두 나온다

- **WHEN** 저장소를 임시 디렉터리에 복사하고 `.claude/skills/openspec-*` 6개를 지운 뒤, 시험용 change에 `openspec instructions proposal|specs|design|tasks|apply --change <이름> --json`을 돌린다
- **THEN** 다섯 명령이 모두 종료코드 0이다

#### Scenario: 스캐폴드 없이 archive 단계가 돈다

- **WHEN** 같은 사본에서 `skip_specs: true`이고 작업이 모두 끝난 시험용 change에 finalizer 지시의 archive 명령(`openspec archive "<이름>" --yes`)을 돌린다
- **THEN** 종료코드가 0이다

### Requirement: sdd-sync 스킬은 sync 절차만 담고 archive를 하지 않아야 한다

`.claude/skills/sdd-sync/SKILL.md`가 있어야 하며(SHALL), frontmatter는 `name`과
`description`만 가져야 한다(SHALL, `allowed-tools` 없음). 이 스킬은 change의 델타 spec을
메인 spec에 병합하는 절차를 담아야 한다(MUST): 델타 경로를
`artifactPaths.specs.existingOutputPaths`에서만 얻기, 규칙 스냅샷
(`openspec instructions specs`) 실패 시 멈추기, `ADDED`/`MODIFIED`/`REMOVED`/`RENAMED`
구획별 병합, 메인 spec의 `## Purpose`는 정본으로 두고 새 capability일 때만 델타의 Purpose를
옮기기, capability 은퇴의 여섯 조건, 병합 뒤 재대조와 `openspec validate --specs`·
`openspec validate "<이름>"` 종료코드 확인.

Purpose 처리에는 예외가 하나 있다(SHALL): change의 `design.md`에 "Purpose 갱신" 목록이 있으면,
그 목록에 적힌 capability의 메인 Purpose를 목록의 문장으로 고치고 고친 사실을 보고한다.
델타 형식에는 기존 capability의 Purpose를 바꾸는 구획이 없어서, 요구사항이 바뀌어 Purpose가
틀리게 된 경우 이 목록이 유일한 통로다. 목록이 없으면 기존 capability의 Purpose를 건드리지
않는다(MUST NOT).

이 스킬은 `openspec archive`를 실행하라고 지시해서는 안 된다(MUST NOT). archive는 되돌릴 수
없어서 finalizer가 사용자 승인을 받은 뒤에만 한다.

#### Scenario: sync 절차가 들어 있다

- **WHEN** `.claude/skills/sdd-sync/SKILL.md`를 읽는다
- **THEN** 델타 읽기 → 구획별 메인 spec 반영(ADDED/MODIFIED/REMOVED/RENAMED) → Purpose 처리 → 재대조 → validate 종료코드 확인의 순서가 있다
- **AND** 은퇴 여섯 조건 중 `retire_capabilities: true`가 빠지면 그 사실을 콕 집어 보고하라는 지시가 있다

#### Scenario: design.md의 Purpose 갱신 목록을 따른다

- **WHEN** 같은 파일에서 Purpose 처리 규칙을 읽는다
- **THEN** 메인 spec의 Purpose가 정본이고 새 capability일 때만 델타 Purpose를 옮긴다는 규칙이 있다
- **AND** change의 `design.md`에 "Purpose 갱신" 목록이 있으면 그 문장으로 메인 Purpose를 고치고 보고하라는 예외가 있다
- **AND** 목록이 없으면 기존 capability의 Purpose를 건드리지 않는다는 것을 알 수 있다

#### Scenario: archive를 돌리지 않는다

- **WHEN** 같은 파일에서 archive에 관한 문장을 찾는다
- **THEN** `openspec archive`를 실행하라는 지시가 없다
- **AND** archive가 이 스킬의 일이 아니라는 것을 알 수 있다
