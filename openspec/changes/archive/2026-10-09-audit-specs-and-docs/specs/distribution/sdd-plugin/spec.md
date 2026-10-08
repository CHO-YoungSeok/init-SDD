# Spec Delta

## MODIFIED Requirements

### Requirement: 플러그인 검증 명령 두 개를 모두 통과해야 한다

`claude plugin validate .`와 `claude plugin validate .claude-plugin/plugin.json`을 `--strict`로 **둘 다**
통과해야 한다(MUST). `marketplace.json`이 있으면 앞의 명령은 마켓플레이스 매니페스트를 보고 `plugins[0]`(source `./`)을
따라가 `plugin.json`과 에이전트·스킬도 검사한다(실측, Claude Code 2.1.294). 뒤의 명령은 그래서 중복이지만
해가 없고, Claude Code 버전에 따라 동작이 다를 수 있어 둘 다 유지한다.

#### Scenario: 두 검증 명령이 모두 통과한다

- **WHEN** 저장소 루트에서 `claude plugin validate . --strict; echo $?`와
  `claude plugin validate .claude-plugin/plugin.json --strict; echo $?`를 돌린다
- **THEN** 두 종료코드가 모두 0이다

### Requirement: 플러그인 eval 결과는 추적하지 않아야 한다

`.gitignore`에 `evals/results/`가 있어야 한다(SHALL). `claude plugin eval`이 `evals/`의 사례를
인식하는지(실행 시작까지)는 확인해 기록해야 한다(SHALL). 이 확인은 비용 상한 0.05달러(`--max-cost-usd 0.05`)
안에서 돌리고, `--json`·`--report` 출력은 저장소 밖에 둔다(SHALL). 점수 측정은 하지 않는다 — 모델 호출
비용이 들고, 실전 측정 change의 일이다.

#### Scenario: 결과 폴더 무시와 인식 확인

- **WHEN** `.gitignore`를 읽고 archive된 change `2026-10-09-convert-to-plugin`의 `verification.md`를 읽는다
- **THEN** `.gitignore`에 `evals/results/` 줄이 있다
- **AND** `claude plugin eval`이 `evals/`의 사례 이름을 인식했는지에 대한 확인 결과가 있다

## REMOVED Requirements

### Requirement: README는 플러그인 설치를 먼저 안내해야 한다

**Reason**: 시나리오 이름 "README에 다섯 가지가 있다"가 요구사항 목록(네 가지)과 맞지 않고, 시나리오가 다른 요구사항
("이 저장소는 --plugin-dir로 개발해야 한다") 몫인 `claude --plugin-dir .`까지 본다. MODIFIED는 시나리오 이름을
바꿀 수 없어(1.14.1 실측) 새 헤더로 다시 넣는다.
**Migration**: 같은 네 가지 의무가 ADDED "README는 플러그인 설치와 이전 안내를 담아야 한다"로 옮겨 간다.
`claude --plugin-dir .` 확인은 "이 저장소는 --plugin-dir로 개발해야 한다"의 시나리오가 계속 맡는다.

## ADDED Requirements

### Requirement: README는 플러그인 설치와 이전 안내를 담아야 한다

`README.md`는 다음을 담아야 한다(MUST):
- 플러그인 설치 두 줄(`/plugin marketplace add <owner/repo 또는 경로>`, `/plugin install sdd@sdd-marketplace`)
- 새 프로젝트에서 한 번 실행하는 `/sdd:init`
- 기존 방식(`install.sh`, `init-sdd`)에서 플러그인으로 옮기는 안내
- `openspec init`이 까는 스캐폴드(`.claude/commands/opsx/`, `.claude/skills/openspec-*`)가 이 파이프라인에
  필요 없다는 안내

#### Scenario: README에 플러그인 안내 네 가지가 있다

- **WHEN** `README.md`를 읽는다
- **THEN** `/plugin marketplace add`와 `/plugin install sdd@sdd-marketplace`가 있다
- **AND** `/sdd:init`과 기존 방식에서 이전하는 안내가 있다
- **AND** `.claude/commands/opsx/`와 `.claude/skills/openspec-*`가 필요 없다는 안내가 있다
