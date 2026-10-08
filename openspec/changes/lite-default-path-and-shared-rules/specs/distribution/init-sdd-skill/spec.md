## MODIFIED Requirements

### Requirement: 개인 소유와 openspec CLI 소유를 갈라서 링크해야 한다

스킬은 `.claude/`를 통째로 링크해서는 안 된다(MUST NOT). 그 안에는 소유자가 다른 것이
섞여 있다. **개인 소유만 골라서** 링크해야 한다(SHALL).

링크 대상은 정확히 여섯 개다(SHALL):

| 경로 | 종류 |
|---|---|
| `.claude/agents/` | 디렉터리 |
| `.claude/skills/orchestra/` | 디렉터리 |
| `.claude/skills/agent-model-tier/` | 디렉터리 |
| `.claude/skills/sdd-rules/` | 디렉터리 |
| `.claude/skills/sdd-sync/` | 디렉터리 |
| `.claude/settings.json` | 파일 |

`.claude/skills/sdd-rules/`와 `.claude/skills/sdd-sync/`는 에이전트가 frontmatter `skills:`로
주입받는 스킬이라 에이전트와 함께 다녀야 한다. 빠지면 링크된 에이전트가 공용 규칙과 sync
절차를 받지 못한다.

`.claude/skills/openspec-*`(6개)와 `.claude/commands/opsx/`는 링크 대상에서 **제외해야
한다**(MUST NOT link). `openspec init --tools claude`가 사용자의 CLI 버전에 맞는 것을 대상
프로젝트에 직접 깔아 주는 물건이다.

`.claude/skills/` 자체는 **실제 디렉터리로 남아야 하며**(SHALL), 그 안의 네 개만 링크가
된다. `.claude/settings.local.json`은 만들지도 고치지도 지우지도 않아야 한다(MUST NOT) —
개인 로컬 설정이고 이미 추적 제외 대상이다.

#### Scenario: 문서가 소유를 갈라 적는다

- **WHEN** 스킬 문서에서 링크 대상 목록을 읽는다
- **THEN** 위 여섯 개가 링크 대상으로 적혀 있다
- **AND** `openspec-*` 6개와 `commands/opsx/`가 **링크하지 않는 것**으로 적혀 있고 그 이유
  (openspec CLI가 깐다)가 함께 적혀 있다
- **AND** `.claude/` 통째 링크를 하지 말라는 말이 명시돼 있다
- **AND** `settings.local.json`은 건드리지 않는다고 적혀 있다

#### Scenario: 링크를 걸어도 openspec 스킬이 그대로 남는다

- **WHEN** 임시 프로젝트에 절차를 돌린 뒤 `.claude/skills/`를 본다
- **THEN** `.claude/skills/`는 심볼릭 링크가 아닌 실제 디렉터리다
- **AND** `openspec-*` 스킬 디렉터리들이 실제 디렉터리로 그대로 있다
- **AND** `orchestra`, `agent-model-tier`, `sdd-rules`, `sdd-sync`만 심볼릭 링크다

### Requirement: 걸었다 풀 수 있어야 하고, 풀면 원래 상태로 돌아와야 한다

스킬은 링크를 거는 절차와 **푸는 절차를 둘 다 가져야 한다**(SHALL). 푸는 절차는 다음을
전부 되돌려야 한다(MUST):

- 만든 심볼릭 링크 여섯 개를 없앤다 (링크만 없앤다 — 링크가 가리키던 개인 저장소의 내용은
  건드리지 않는다)
- `CLAUDE.md`의 마커 구획을 떼어 낸다
- `git update-index --no-skip-worktree CLAUDE.md`로 표시를 해제한다
- `.git/info/exclude`에 스킬이 적어 넣은 줄만 지운다 (사용자가 원래 적어 둔 줄은 그대로 둔다)

푼 뒤에는 공유 저장소가 절차를 돌리기 **전과 같아야 한다**(SHALL): 추적 파일 내용이 같고
`git status`가 같다. 개인 저장소의 내용은 지워지지 않아야 한다(MUST NOT) — 다른 프로젝트도
그것을 쓴다.

#### Scenario: 걸었다 풀면 제자리로 돌아온다

- **WHEN** 임시 프로젝트에 절차를 돌리고, 파일 목록과 `git status`를 기록한 뒤 푸는 절차를
  돌린다
- **THEN** 링크 여섯 개가 사라진다
- **AND** `CLAUDE.md`가 절차 전 내용과 같고 `skip-worktree` 표시가 해제돼 있다
- **AND** `.git/info/exclude`가 절차 전과 같다
- **AND** `git status`가 절차 전과 같다

#### Scenario: 풀어도 개인 저장소는 남는다

- **WHEN** 푸는 절차를 돌린 뒤 개인 저장소를 본다
- **THEN** 프로젝트별 디렉터리와 그 안의 파일이 그대로 있다
- **AND** 개인 저장소의 git 이력이 그대로 있다

### Requirement: 지금 걸려 있는지 알 수 있어야 한다

스킬은 현재 연결 상태를 보여주는 절차를 가져야 한다(SHALL). 다음을 모두 보여야 한다(MUST):

- 링크 대상 여섯 개 각각이 **링크됨(어디를 가리키는지) / 실제 파일·디렉터리 / 없음 /
  끊긴 링크** 중 무엇인지
- `CLAUDE.md`에 마커 구획이 있는지
- `CLAUDE.md`에 `skip-worktree` 표시가 걸려 있는지
- `.git/info/exclude`에 스킬이 적은 줄이 있는지

**끊긴 링크**(가리키는 곳이 없는 링크)를 따로 알려야 한다(MUST). 개인 저장소를 아직 복제하지
않은 새 컴퓨터에서 이 상태가 되고, 그 상태에서는 에이전트가 하나도 로드되지 않는데 링크는
걸려 있어서 겉으로는 정상처럼 보인다.

#### Scenario: 상태 확인이 네 갈래를 구분한다

- **WHEN** 상태 확인 절차를 읽는다
- **THEN** 링크 대상 여섯 개 모두에 대해 링크됨·실제 파일·없음·끊긴 링크 네 갈래를 구분하는 방법이 적혀 있다
- **AND** `CLAUDE.md` 마커·`skip-worktree`·`.git/info/exclude`도 함께 확인한다

#### Scenario: 끊긴 링크를 잡아낸다

- **WHEN** 링크를 걸어 둔 뒤 개인 저장소 디렉터리 이름을 바꿔 링크를 끊고 상태 확인을 돌린다
- **THEN** 그 링크가 끊겼다고 알린다
- **AND** 개인 저장소를 복제·복구하거나 링크를 풀라고 알려 준다
