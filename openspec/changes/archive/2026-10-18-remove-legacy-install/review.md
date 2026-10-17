최종 판정: 통과 (라운드 1, 2026-10-18)

## 리뷰: remove-legacy-install
판정: 통과
판정 기록: openspec/changes/remove-legacy-install/review.md
기준으로 삼은 채택안: 없음 — decision.md 없음(analyzer 생략 경로), 기준은 proposal의 받아들일 조건 + specs 델타 + design.md D1~D7

### OpenSpec 검증
./bin/sdd-openspec validate remove-legacy-install --strict:
```text
Change 'remove-legacy-install' is valid
exit=0
```

그 밖의 검증(직접 돌림):
```text
claude plugin validate . --strict                         -> ✔ Validation passed, exit=0
claude plugin validate .claude-plugin/plugin.json --strict -> ✔ Validation passed, exit=0
bin/sdd-init rc=0 / bin/sdd-openspec rc=0 / hooks/session-start.sh rc=0
```

### 요구사항 충족
- sdd-plugin "표준 레이아웃"(MODIFIED) → 충족: `ls -A .claude` = `CLAUDE.md`, `settings.json`; `.claude/skills/` 없음. `git ls-files .claude` 두 줄 조건은 finalizer 커밋 뒤 성립(아래 참고 1).
- sdd-plugin "--plugin-dir로 개발"(MODIFIED) → 충족: `.claude/CLAUDE.md`에 표식 0건, `claude --plugin-dir .`는 `.claude/CLAUDE.md:7`·`README.md:272`, 지휘 지침·두 순서 줄·code-explorer 예외·analyzer 문장은 `.claude/CLAUDE.md:24-44`.
- sdd-plugin "에이전트는 sdd 접두사 이름으로 불러야 한다"(ADDED) → 충족: `skills/orchestra/SKILL.md:29` 한 문장만 남음, `subagent_type: "` 줄 전부 `sdd:`, `not found` 0건(orchestra·sdd-rules·agents).
- sdd-plugin "README는 플러그인 설치를 한 길로"(ADDED) → 충족: `README.md:16-24`(빠른 시작)과 `README.md:142-150`(플러그인으로 설치)에 한 줄짜리 코드블록 두 개씩, 그 뒤 `/sdd:init`(`README.md:29`, `:153`), 스캐폴드 불필요 안내 `README.md:156-157`, 설치 방식 고르기·다른 설치 방식 절 없음.
- sdd-plugin "설치 수단은 플러그인 하나뿐"(ADDED) → 충족(작업 트리 기준): 낡은 낱말 grep(tasks 5.4, `openspec/`·`docs/field-validation.md` 제외) 출력 없이 rc=1. `git ls-files '*.sh'` 한 줄 조건은 커밋 뒤 성립.
- openspec-cli-wrapper "지시문은 래퍼를 먼저"(MODIFIED) → 충족: `skills/sdd-rules/SKILL.md:19-20` 1.14.1 규칙만 남음, `PATH에 없으면` 0건(sdd-rules·orchestra), 래퍼 예시 grep 0건.
- code-explorer-invocation "sdd 접두사 이름 하나로만"(ADDED) → 충족: `skills/sdd-rules/SKILL.md` "code-explorer 부르기" 절에 `sdd:code-explorer`, 대비 규칙 두 줄 삭제 확인.
- shared-pipeline-rules 두 MODIFIED → 충족: sdd-rules `## ` 절 7개, `not found` 0건.
- project-context-completeness(MODIFIED) → 충족: `openspec/config.yaml` diff — 실행 파일·`bash -n` 대상이 `bin/sdd-openspec`, `bin/sdd-init`, `hooks/session-start.sh` 셋, `install.sh`·기존 설치 줄·dry-run 줄 삭제, `context:` 0칸 들여쓰기 유지.
- 은퇴 두 capability(sdd-install-script, init-sdd-skill) → 델타가 전부 REMOVED, `.openspec.yaml`에 `retire_capabilities: true` 있음.
- 받아들일 조건 "고친 .md 무결성" → 충족: 리치 토큰 0, 코드펜스 줄 수 CLAUDE.md 2 / README 22 / orchestra 40 / sdd-rules 0(모두 짝수), 두 SKILL frontmatter `---`·`name`·`description` 온전.

### 설계 준수
- D4: `.claude/CLAUDE.md` "이 저장소도 SDD로 개발한다" 절이 목표 문안과 글자 그대로 일치, 표 행 삭제·settings.json 설명 변경, 검증 명령의 install.sh·임시 설치 줄 삭제, "표식 구획" 절과 구획 전체 삭제. 절 순서 제목 → 띄우기 → 저장소 구조 → SDD로 개발 → 검증 명령 → 커밋 규칙.
- D5: README 코드블록 분리·안내 문장, "자세한 설명은 아래 "설치"에 있다.", 필요한 것 표 OpenSpec 행, `/orchestra` 괄호, "먼저 고른다" 절 삭제와 플러그인 문단 이동(`README.md:137-138`, "(권장)" 제거), 기존 설치 방식 절 삭제("### Windows" 다음이 "### 프로젝트 규칙 심기"), `README.md:202`·커스터마이즈·OpenSpec 버전 항목 모두 설계 문안대로.
- D6: orchestra·sdd-rules·config.yaml 수정이 설계 줄 단위 지시와 일치.
- D3: 델타의 MODIFIED·ADDED 블록에 금지 낱말 글자 그대로 0건(REMOVED 블록 밖 awk 검사).
- D7: `git rm` 없이 작업 트리에서만 삭제(` D install.sh`, ` D .claude/skills/init-sdd/SKILL.md`), `.claude/skills/` 디렉터리 없음.
- README 흐름: 빠른 시작 → 왜 → 작동 방식 → 설치(플러그인 → 훅 → 권한 → 업데이트 → 팀 배포 → Windows → 프로젝트 규칙) → 커스터마이즈 → 알아 둘 것 → 개발. 지운 절을 가리키는 문구·앵커 링크 없음(`표식 구획`, `폐기 예고`, `복사·링크`, `/orchestra`, `(#…)`, `먼저 고른다`, `방법 1·2` grep 0건 — `agents/reviewer.md:150`의 `--dry-run`은 린트 옵션 설명이라 무관).

### 작업 완료 검증
체크된 18개 중 18개 실제 확인(1.1~1.3 파일·디렉터리 상태, 2.1~2.5 CLAUDE.md diff·grep, 3.1~3.6 README 본문·grep, 4.1~4.3 diff·grep, 5.1~5.5 명령 재실행). `[ ]` 남은 항목 없음.

### 되돌릴 체크 항목
없음

### 발견 사항
1. [참고] 받아들일 조건 1번(`git ls-files`에 install.sh·init-sdd 없음)과 sdd-plugin 시나리오(`git ls-files '*.sh'` = `hooks/session-start.sh` 한 줄, `git ls-files .claude` 두 줄)는 지금 `install.sh`가 아직 추적 중이라 커밋 뒤에야 성립한다(설계 D7 의도). finalizer가 커밋에 삭제를 담고(`git add -A` 대상 또는 `git rm --cached` 상당) 커밋 뒤 `git ls-files '*.sh'`로 확인해야 한다.
2. [참고] sync 뒤 메인 spec grep(tasks 5.4 후반): 지금 `openspec/specs/`의 금지 낱말 일치는 모두 은퇴 두 capability이거나, 이 델타가 MODIFIED/REMOVED하는 요구사항 안(sdd-plugin:52·68·76~100·117·124·177, shared-pipeline-rules:36, code-explorer-invocation:86, project-context-completeness:13-14, openspec-cli-wrapper:40)에 있음을 확인했다. sync·은퇴 뒤 `openspec/changes/`만 빼고 같은 grep을 다시 돌려 0건인지 finalizer가 확인한다.
3. [참고] `README.md:208` "적은 뒤 `openspec context` 를 돌려 …"는 이번 범위(D5) 밖에 남은 기존 문구다. 플러그인 사용자는 PATH에 `openspec`이 없을 수 있어 `README.md:262-264`처럼 `sdd-openspec context`가 더 맞다. 이번 change를 막을 문제는 아니다.

### 이번 change 것인지 확인 필요한 변경
없음 (`git status --short`의 변경은 만진 파일 목록과 change 폴더뿐)

### 다음 단계
finalizer에게 넘긴다: sdd-sync(MODIFIED/REMOVED/ADDED 병합) → 은퇴 두 capability 처리(커밋 관문 승인 뒤) → 메인 spec 포함 낡은 낱말 grep 재확인 → 작업 단위별 커밋(삭제 포함) → 커밋 뒤 `git ls-files '*.sh'`·`git ls-files .claude` 확인.
