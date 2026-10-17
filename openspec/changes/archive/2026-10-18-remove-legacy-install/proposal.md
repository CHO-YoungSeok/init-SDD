# Proposal

## Why

이제 설치는 플러그인 `sdd` + `/sdd:init` 한 길만 쓴다. 기존 설치 방식(복사 방식 `install.sh`, 링크 방식
`.claude/skills/init-sdd/`)은 "폐기 예고" 상태로 남아 README·지시문·사양 곳곳에 대비 문구와 요구사항을 퍼뜨리고 있다.
사용자가 README 코멘트로 "기존 설치방식은 필요 없으니 검토하고 제거해라, sdd:init 방식만 쓴다"고 정했다.
같은 코멘트에서 README "빠른 시작"의 플러그인 설치 두 줄을 코드블록 두 개로 나누라고 했다.

## What Changes

- **BREAKING** `install.sh`와 `.claude/skills/init-sdd/`(링크 방식 스킬)를 저장소에서 지운다. 복사·링크 방식으로는 더 설치할 수 없다.
- README:
  - "빠른 시작"과 "플러그인으로 설치"의 `/plugin marketplace add ...`, `/plugin install sdd@sdd-marketplace` 두 줄을 한 줄씩 코드블록 두 개로 나눈다.
  - "기존 설치 방식 (폐기 예고)" 절 전체(이전 안내, 방법 1·2, CLAUDE.md 합치기, 이름이 겹칠 수 있는 파일, 설치 확인, 이미 설치한 프로젝트 안내)를 지운다.
  - 설치 방식 고르기 절(세 방식 표와 복사·링크 설명)을 플러그인 한 길에 맞게 정리한다.
  - "다른 설치 방식(복사·링크)" 안내, 필요한 것 표의 "복사·링크 방식" 확인·설치 문구, `/orchestra` 괄호 안내, 프로젝트 규칙 심기·커스터마이즈·OpenSpec 버전 절의 복사·링크 문구를 지운다.
- `.claude/CLAUDE.md`:
  - `<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->` 표식과 "표식 구획" 절의 규칙(구획 밖 표식 금지, 구획 수정 시 install.sh 임시 설치 확인 등)을 없앤다. 표식 문자열은 훅·`bin/sdd-init`·`/sdd:init` 어디에서도 쓰지 않는다(확인함). 지휘 지침 내용은 이 저장소 세션에 계속 필요하므로 표식 없는 일반 절로 남긴다.
  - 저장소 구조 표의 `install.sh`, `.claude/skills/init-sdd/` 행과 `.claude/settings.json` 설명의 "install.sh의 복사 원본" 문구, 검증 명령의 `bash -n install.sh`와 임시 프로젝트 설치 확인 줄을 정리한다.
- 지시문의 기존 설치 방식 대비 문구를 지운다:
  - `skills/orchestra/SKILL.md`: 접두사 없는 이름으로 다시 부르는 대비 규칙, `sdd-openspec`이 PATH에 없으면 `openspec`으로 바꿔 치는 문구.
  - `skills/sdd-rules/SKILL.md`: "쓰는 스킬" 절의 `sdd-openspec`이 없을 때 대비 문구, "code-explorer 부르기" 절의 접두사 없는 `code-explorer` 대비 규칙.
  - (`agents/*.md`, `skills/sdd-sync`, `skills/init`, `bin/`, `hooks/`에는 해당 문구가 없음을 확인했다.)
- `openspec/config.yaml`의 `context:`에서 `install.sh`, 기존 설치 방식 줄, `bash install.sh --dry-run` 검증 수단을 뺀다.
- 사양: 기존 설치 방식만을 위한 capability 두 개를 은퇴시키고, 대비 규칙·조각 원본 유지·install.sh 언급을 담은 요구사항을 고친다.

## Capabilities

### New Capabilities

(없음)

### Modified Capabilities

- `distribution/sdd-install-script`: 요구사항 전부 제거 → capability 은퇴(install.sh·복사 방식·CLAUDE.md 조각 원본 한 벌·복사/링크 선택 안내·README 복사 방식 절차/갱신 안내 등). README 설치 절차 요구사항 중 플러그인 쪽에 남길 것이 있으면 `distribution/sdd-plugin`으로 옮긴다.
- `distribution/init-sdd-skill`: 요구사항 전부 제거 → capability 은퇴(링크 방식 스킬).
- `distribution/sdd-plugin`: "표준 레이아웃"(`.claude/skills/init-sdd/`에 남는다·추적 스킬은 `init-sdd`뿐 → `.claude/skills/`에 추적 스킬이 없다), "sdd 접두사 이름으로 부르고 접두사 없는 이름으로 대비"(대비 규칙 제거), "frontmatter skills 접두사 없는 이름"(기존 설치본 근거 문구), "--plugin-dir로 개발"(표식 구획이 남아야 한다는 MUST 제거), "README 플러그인 설치와 이전 안내"(기존 방식 이전 안내 항목 제거, 설치 두 줄이 별도 코드블록).
- `distribution/openspec-cli-wrapper`: "지시문은 래퍼를 먼저 써야 한다"에서 `sdd-openspec`이 없을 때 `openspec`으로 대체하는 규칙 제거(1.14.1 이상이면 `openspec`을 써도 된다는 규칙은 남긴다).
- `agent-instructions/code-explorer-invocation`: "code-explorer를 부르는 이름은 플러그인 접두사를 따라야 한다"에서 접두사 없는 이름 대비 규칙 제거.
- `agent-instructions/shared-pipeline-rules`: "공용 규칙은 frontmatter skills로 주입"의 기존 설치본 근거 문구, "openspec 호출 표기와 에이전트 이름 규칙은 sdd-rules 한 곳에"의 두 대비 규칙과 `not found` 시나리오.
- `agent-instructions/project-context-completeness`: context가 담아야 할 실행 파일·검증 수단에서 `install.sh`, `bash install.sh --dry-run` 제거.

## Impact

- 지우는 파일: `install.sh`, `.claude/skills/init-sdd/SKILL.md`(디렉터리째).
- 고치는 파일: `README.md`, `.claude/CLAUDE.md`, `skills/orchestra/SKILL.md`, `skills/sdd-rules/SKILL.md`, `openspec/config.yaml`.
- 메인 spec: 위 7개 capability(그중 2개 은퇴 — change `.openspec.yaml`에 `retire_capabilities` 마커 필요, 실제 삭제는 커밋 관문 승인 뒤 finalizer).
- 이미 복사·링크 방식으로 깐 사용자는 이 저장소에서 이전 안내를 더 받지 못한다(사용자 결정: 필요 없음).
- 건드리지 않는 것: `bin/`, `hooks/`, `skills/init`, `skills/sdd-sync`, `agents/*.md`, `.claude-plugin/`, `.gitignore`, `openspec/changes/archive/`.

## 받아들일 조건

- [ ] `install.sh`와 `.claude/skills/init-sdd/`가 저장소에 없다(`git ls-files`에 안 나온다).
- [ ] README "빠른 시작"과 "플러그인으로 설치"에서 `/plugin marketplace add ...`와 `/plugin install sdd@sdd-marketplace`가 각각 다른 코드블록에 한 줄씩 있다.
- [ ] `git ls-files` 중 `openspec/changes/archive/`와 은퇴 대상 spec을 뺀 파일에서 `install.sh`, `init-sdd`(스킬 이름), `복사 방식`, `링크 방식`, `기존 설치`, `init-SDD:begin`, `init-SDD:end`가 나오지 않는다(`docs/field-validation.md`의 과거 측정 기록 각주는 예외로 남겨도 된다).
- [ ] `skills/orchestra/SKILL.md`와 `skills/sdd-rules/SKILL.md`에 접두사 없는 이름 대비 규칙과 `sdd-openspec`이 PATH에 없을 때의 대비 문구가 없다. `sdd:<이름>` 호출 예시와 "1.14.1 이상이면 `openspec`을 써도 된다" 규칙은 남아 있다.
- [ ] `.claude/CLAUDE.md`에 표식 문자열이 없고, 지휘 지침(작업 방식) 내용은 남아 있으며, 저장소 구조 표·검증 명령에 `install.sh`가 없다.
- [ ] `openspec/config.yaml`의 context에 `install.sh`가 없고 `./bin/sdd-openspec instructions proposal --change remove-legacy-install --json` 응답에 `context` 키가 있다.
- [ ] `claude plugin validate . --strict`와 `claude plugin validate .claude-plugin/plugin.json --strict`가 둘 다 exit 0.
- [ ] `./bin/sdd-openspec validate remove-legacy-install --strict`가 exit 0.
- [ ] `bin/sdd-init`, `bin/sdd-openspec`, `hooks/session-start.sh`의 `bash -n`이 모두 rc=0.
- [ ] 고친 `.md`마다 리치 마크다운 토큰 0개, 코드펜스 줄 수 짝수, frontmatter 온전.

## 범위 밖

- `openspec/changes/archive/` 안의 과거 기록은 고치지 않는다.
- `docs/field-validation.md`의 과거 기준선 측정값(각주의 `init-sdd` 언급 포함)은 측정 당시 사실이라 고치지 않는다.
- `.claude/settings.json`의 내용(권한 목록)은 바꾸지 않는다 — `/sdd:init` 권한 목록의 원본이고, `Bash(openspec:*)`는 1.14.1 이상 `openspec` 직접 사용 규칙 때문에 남긴다. 설명 문구만 고친다.
- `bin/`, `hooks/`, `skills/init`, `skills/sdd-sync`, `agents/*.md`의 동작 변경.
- 이미 복사·링크 방식으로 설치한 프로젝트를 위한 이전 도구나 이전 안내 문서 새로 만들기.
- 플러그인 버전(`plugin.json`의 `version`) 올리기.

## 세운 가정

- "기존 방식에서 플러그인으로 옮기는 안내"도 함께 지운다(사용자: "다른건 필요 없잖아"). `sdd-plugin` 요구사항에서 그 항목을 뺀다.
- `.claude/CLAUDE.md`의 지휘 지침 본문은 표식만 걷어 내고 일반 절로 남긴다. 구획 안의 `.claude/agents/` 같은 설치 대상 기준 경로 설명은 이 저장소 기준(`agents/`, `skills/orchestra/SKILL.md`, `sdd:` 이름)으로 고쳐도 된다 — 세부는 designer가 정한다.
- 은퇴하는 두 capability의 요구사항 중 플러그인 쪽에 여전히 의미 있는 것(예: "`openspec init`이 까는 스캐폴드는 필요 없다" 안내, 설치 절차가 README 한 곳에 플러그인부터 서술)은 `distribution/sdd-plugin`에 이미 있거나 그쪽으로 옮긴다.
