## REMOVED Requirements

### Requirement: 모델 등급 스킬은 활성 스킬로 놓여야 한다

**Reason**: 플러그인으로 설치하면 에이전트 파일이 플러그인 캐시 폴더에 놓인다. 그 파일의 `model:` 줄을 직접 고치는 이 스킬의 전제가 무너진다(사용자 결정, 상위 change `plugin-lite-sdd-distribution` decision.md).
**Migration**: 모델을 바꾸려면 플러그인 에이전트 파일 대신 사용자 쪽 설정(Claude Code의 서브에이전트 모델 설정)을 쓴다. 기존 설치본에 남은 `.claude/skills/agent-model-tier/`는 지워도 된다.

### Requirement: 등급 세 개의 값 표가 스킬 안에 값으로 있어야 한다

**Reason**: 스킬 자체를 없앤다(위와 같은 이유).
**Migration**: 없음. 에이전트별 기본 모델은 각 에이전트 파일의 `model:` 한 줄에 그대로 있다.

### Requirement: 지금 등급을 판별할 수 있고 섞인 상태를 짐작해서는 안 된다

**Reason**: 스킬 자체를 없앤다.
**Migration**: 지금 모델은 각 에이전트 파일의 `model:` 줄을 직접 읽어 확인한다.

### Requirement: 등급 적용은 양방향이고 몇 번을 해도 같은 결과여야 한다

**Reason**: 스킬 자체를 없앤다.
**Migration**: 없음.

### Requirement: 등급을 갈 때 `model:` 한 줄만 고쳐야 한다

**Reason**: 스킬 자체를 없앤다.
**Migration**: 없음.

### Requirement: 등급을 낮추면 무엇이 나빠지는지 경고해야 한다

**Reason**: 스킬 자체를 없앤다.
**Migration**: 없음.

### Requirement: code-explorer는 등급 표 밖에 있어야 하고 표 자체는 늘어나지 않아야 한다

**Reason**: 등급 표가 없어진다. code-explorer의 `model: haiku` 고정은 메인 spec `agent-instructions/code-explorer-role`이 계속 요구한다.
**Migration**: 없음.
