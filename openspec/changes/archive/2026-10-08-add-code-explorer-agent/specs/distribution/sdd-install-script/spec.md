## MODIFIED Requirements

### Requirement: 제품 5종을 깔아야 한다

`install.sh`가 대상 프로젝트에 넣는 제품은 **5종**이어야 한다(SHALL):
`.claude/agents/*.md` 8개, `.claude/skills/orchestra/`,
`.claude/skills/agent-model-tier/`, `.claude/settings.json`, 그리고 `CLAUDE.md`의 조각.

`.claude/agents/*.md`의 개수는 7개에서 8개로 늘었다(`code-explorer.md`가 새로 더해졌다).
복사 로직은 `.claude/agents/*.md` 글롭을 그대로 쓰므로 새 파일이 자동으로 복사 대상에
들어간다(MUST) — 복사 대상 목록 자체를 고칠 필요는 없다. 단 **설치 확인 문구는 개수를
하드코딩**하고 있으므로(`"에이전트: ${N_AGENTS}개 (7이어야 한다)"`), 이 문구는 8로
고쳐야 한다(SHALL).

`.claude/skills/agent-model-tier/`는 이번에 새로 더해지는 것이다. 그 전까지는 4종만 깔았다.
이것도 대상 프로젝트에서 실제로 쓰는 도구이므로 빠지면 안 된다.

설치 확인 절차도 5종에 맞아야 한다(MUST): 에이전트 파일 개수 확인(8이어야 한다),
`orchestra`와 `agent-model-tier` 스킬 존재 확인, openspec 공식 스킬 6개 존재 확인.

#### Scenario: 복사 대상 목록

- **WHEN** `install.sh`의 복사 부분을 읽는다
- **THEN** `.claude/agents/`의 `.md` 파일들, `.claude/skills/orchestra`,
  `.claude/skills/agent-model-tier`, `.claude/settings.json`이 모두 대상으로 적혀 있다

#### Scenario: 모델 등급 스킬이 실제로 복사된다

- **WHEN** 빈 임시 프로젝트에서 실제로 설치를 돌린다
- **THEN** `.claude/skills/agent-model-tier/SKILL.md`가 그 프로젝트에 생긴다
- **AND** 내용이 이 저장소의 원본과 같다

#### Scenario: 설치 확인이 5종을 본다

- **WHEN** 설치가 끝난 뒤 스크립트가 내는 확인 부분을 읽는다
- **THEN** 에이전트 개수(8이어야 한다)가 나온다
- **AND** `orchestra`와 `agent-model-tier` 스킬이 깔렸는지 확인한 결과가 나온다
- **AND** openspec 공식 스킬 6개 중 빠진 것이 있으면 그 이름과 복구 명령을 알려 준다

#### Scenario: 임시 프로젝트에 8개 에이전트가 실제로 깔린다

- **WHEN** `mktemp -d`로 만든 빈 임시 프로젝트에서 `bash install.sh`를 실제로 돌린다
  (이 저장소나 `~/work-space/`가 아닌 임시 디렉터리에서)
- **THEN** `.claude/agents/*.md`가 8개 생기고, 그 안에 `code-explorer.md`가 있다
- **AND** 설치 확인 절에 "에이전트: 8개 (8이어야 한다)"가 출력된다
