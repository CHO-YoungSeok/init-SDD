## REMOVED Requirements

### Requirement: 스킬은 이 저장소에 있고 도구를 좁혀서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 개인 소유와 openspec CLI 소유를 갈라서 링크해야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 경로를 하드코딩해서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 개인 저장소가 없으면 만들고, 프로젝트별 디렉터리 이름이 겹치면 물어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 대상 프로젝트에 이미 있는 것을 잃어서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: CLAUDE.md 조각은 원본 한 벌에서 뽑아 붙여야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 추적 여부에 따라 CLAUDE.md를 로컬에만 두는 방법이 갈라져야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: skip-worktree의 함정과 그 대처를 적어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 링크가 공유 저장소 git에 새어서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 걸었다 풀 수 있어야 하고, 풀면 원래 상태로 돌아와야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 지금 걸려 있는지 알 수 있어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 링크가 에이전트로 로드되는지는 사용자가 새 세션에서 확인해야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 복사 방식과 언제 무엇을 쓰는지 서로 가리켜야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 링크 방식은 플러그인으로 이전하라고 안내해야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: init-sdd 스킬 설명에는 부르는 말이 있고 없어진 스킬이 없어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 초기 이관 원본은 원본 저장소의 플러그인 레이아웃에서 가져와야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: openspec CLI가 까는 것과 개인 로컬 설정은 링크하지 않아야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 프로젝트별 디렉터리 이름이 겹치면 기록을 보고 다시 쓰거나 멈춰야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 추적 중인 파일은 옮기지 않고 미추적 파일은 지우지 않아야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: CLAUDE.md를 로컬에만 둘 때 공유 .gitignore를 고쳐서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 링크를 풀어도 공유 저장소는 원래대로, 개인 저장소는 그대로여야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 링크가 로드되지 않을 때 복사로 떨어지는 길을 두어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 링크가 걸린 프로젝트에서 install.sh를 돌리기 전의 위험을 적어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 링크 방식 스킬 `.claude/skills/init-sdd/`를 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`, 대상 프로젝트 초기화는 `distribution/sdd-init-command`가 맡는다. 플러그인은 대상 프로젝트 `.claude/`에 아무것도 복사하거나 링크하지 않는다. 이미 링크 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).
