---
name: init
description: 새 프로젝트에서 SDD 파이프라인을 한 번 세팅한다 — openspec 최소 초기화, 훅 표식 openspec/.sdd, context 초안(스택·테스트·빌드·기본 브랜치), 권한 기록(동의 뒤 settings.local.json에만). "SDD 초기화", "이 프로젝트에 SDD 세팅해줘", "openspec 시작", "sdd init" 같은 말에 쓴다.
---

# /sdd:init — 새 프로젝트에서 SDD 초기화

새 프로젝트에서 **한 번** 돌린다. 이미 초기화된 프로젝트에서 다시 돌려도 망가지지 않는다(이미 있는 것은 건너뛴다).

판단이 필요 없는 일은 실행 파일 `sdd-init`이 한다. 이 스킬은 결과를 보여 주고, 사용자에게 묻고, **동의를 받은 뒤에만** 기록 명령을 돌린다.

- 모든 명령은 대상 프로젝트의 루트(최상위 폴더)에서 돌린다.
- `sdd-init`과 `sdd-openspec`은 플러그인의 `bin/`에 있어서 PATH 이름으로 부른다.
  PATH에서 찾지 못하면 `"${CLAUDE_PLUGIN_ROOT}/bin/sdd-init"`처럼 플러그인 경로로 부른다.
- 공유 `.claude/` 파일(`.claude/settings.json` 등)과 공유 `.gitignore`는 고치지 않는다. 권한은 `.claude/settings.local.json`에만 쓴다.

## 1. openspec 초기화와 훅 표식

- 돌리기 전에 사용자에게 먼저 알린다: **`sdd-openspec`은 첫 실행 때 npm 레지스트리에서 openspec을 받는다(`sdd-init setup`이 곧바로 그 첫 실행이다).**

```bash
sdd-init setup; echo "exit=$?"
```

- 결과를 그대로 보여 준다.
- 실패하면(종료코드가 0이 아니면) 출력의 안내대로 멈춘다. 예: git 저장소가 아니거나 커밋이 하나도 없으면, 사용자에게 그것부터 하자고 말한다.
- `openspec/config.yaml`이 이미 있으면 초기화는 건너뛴다. 없으면 `sdd-openspec init --tools none --no-animation`으로
  최소한만 만든다(`openspec/config.yaml`, `openspec/specs/`, `openspec/changes/archive/`). `.claude/` 아래에는 아무것도 깔지 않는다.
- 사용자에게 한 줄로 알린다: **표식 `openspec/.sdd`가 SessionStart 훅을 켠다. 커밋하면 같은 저장소에서 플러그인을 깐 팀원에게도 켜지고, 지우면 꺼진다.**

## 2. context 초안 — 확인받은 뒤에만 쓴다

```bash
sdd-init detect; echo "exit=$?"
```

- 초안(기술 스택, 테스트 명령, 빌드 명령, 기본 브랜치)을 보여 주고 고칠 곳이 있는지 묻는다.
  "확인 필요"로 나온 칸은 사용자에게 값을 물어본다.
- **사용자가 동의한 뒤에만** `write-context`를 돌린다. 동의가 없으면 아무것도 쓰지 않는다.

```bash
sdd-init write-context; echo "exit=$?"
```

- 종료코드가 2이면 `openspec/config.yaml`에 이미 최상위 `context:`가 있어서 쓰지 않은 것이다.
  기존 `context:`와 초안을 나란히 보여 주고, 사용자가 고른 대로 Edit로 고친다(덮어쓰지 않는다).
- 사용자가 초안을 고치라고 했으면, 기록한 뒤 `openspec/config.yaml`의 `context:` 부분을 그 말대로 Edit로 고친다.
- 기록한 뒤 경고가 없는지 본다. 출력에 `Warning`이 있으면 YAML 들여쓰기가 깨진 것이다(파일 전체가 무시된다). 고친 뒤 다시 본다.

```bash
sdd-openspec context; echo "exit=$?"
```

## 3. 기본 브랜치

기본 브랜치는 2의 초안에 들어 있다(괄호 안은 어떻게 정했는지). 틀렸으면 사용자 말대로 `context:`의 그 줄을 고친다.

## 4. 권한 — 동의받은 뒤에만 기록한다

```bash
sdd-init permissions; echo "exit=$?"
```

- 추가할 권한 목록과 "`sdd-openspec`은 첫 실행 때 npm 레지스트리에서 openspec을 받는다"는 안내 줄을 그대로 보여 주고,
  이 권한(그 내려받기 포함)을 `.claude/settings.local.json`에 넣어도 되는지 묻는다.
- **사용자가 동의한 뒤에만** `write-permissions`를 돌린다. 동의가 없으면 아무것도 쓰지 않는다.

```bash
sdd-init write-permissions; echo "exit=$?"
```

- 빠진 항목만 더하고, 원래 있던 키와 항목은 그대로 둔다. 기존 파일이 JSON으로 안 읽히면 쓰지 않고 멈춘다 — 그 사실을 알린다.
- `permissions` 출력에 `.claude/settings.local.json`이 git에서 무시되지 않는다고 나왔으면 **알리기만 한다**. 공유 `.gitignore`는 고치지 않는다.

## 5. 마무리 안내

사용자에게 알린다:
- 훅(지휘 규칙 주입)은 다음 세션부터 켜진다. 지금 세션을 다시 열 필요는 없다.
- 이제 할 일을 말하면 `sdd:orchestra`가 파이프라인을 돌린다.
- `openspec init --tools claude`가 까는 `.claude/commands/opsx/`, `.claude/skills/openspec-*`는 이 파이프라인에 필요 없다.
- 표식 `openspec/.sdd`와 `openspec/` 아래 파일을 커밋할지는 사용자가 정한다(커밋하면 팀원에게도 훅이 켜진다).
