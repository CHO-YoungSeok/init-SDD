## REMOVED Requirements

### Requirement: 설치 스크립트는 저장소에 남아 있어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: CLAUDE.md 조각의 원본은 한 벌이어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 조각이 이미 들어갔는지 낱말 검색만으로 판별해서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 이미 있는 파일을 덮어써서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 전제 조건을 먼저 확인해야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: openspec CLI가 깔아주는 것은 건드려서는 안 된다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 복사 방식과 링크 방식 중 어느 것을 쓸지 알려 줘야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 설치 스크립트는 플러그인으로 이전하라고 안내해야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: install.sh와 init-sdd 스킬 문서는 서로를 가리켜야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: 설치 절차는 README 한 곳에 플러그인부터 서술되어야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: README의 복사 방식 설명과 설치 확인은 제품 6종과 맞아야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: README는 이미 설치한 프로젝트를 위한 갱신 안내를 담아야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: install.sh는 제품 6종을 플러그인 레이아웃에서 가져와 기존 위치에 깔아야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).

### Requirement: install.sh의 설치 확인은 제품 6종에 맞아야 한다

**Reason**: 설치는 플러그인 `sdd`와 `/sdd:init` 한 길만 쓰기로 했다(사용자 결정). 복사 방식 설치 스크립트 `install.sh`와 그것이 뽑아 쓰던 `.claude/CLAUDE.md` 조각 구획을 저장소에서 지우므로 이 capability의 요구사항은 지킬 대상이 없다.
**Migration**: 플러그인 설치는 `distribution/sdd-plugin`(README 설치 안내, 설치 수단은 플러그인 하나), 대상 프로젝트 초기화는 `distribution/sdd-init-command`, 지휘 규칙 주입은 `distribution/session-start-hook`이 맡는다. 이미 복사 방식으로 깐 프로젝트를 위한 이전 안내는 두지 않는다(사용자 결정).
