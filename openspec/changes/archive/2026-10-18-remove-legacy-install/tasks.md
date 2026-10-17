# Tasks

채택안: 없음 — analyzer 생략, 기준은 proposal의 받아들일 조건과 specs 델타.
핵심 결정: (1) 설치 수단은 플러그인 하나 — `install.sh`와 `.claude/skills/init-sdd/`를 지우고 대비 규칙·이전 안내를 모두 걷어 낸다.
(2) `.claude/CLAUDE.md`는 표식을 없애고 구획 본문을 "이 저장소도 SDD로 개발한다" 절에 이 저장소 기준 경로(`agents/`, `skills/orchestra/SKILL.md`, `sdd:<이름>`)로 합친다 — 목표 문안은 design.md D4.
(3) 메인 spec은 finalizer가 sync한다. worker는 `openspec/` 아래를 고치지 않는다(단 `openspec/config.yaml`은 고친다).

모든 명령은 저장소 루트(`/Users/0stone_1004/work-space/init-SDD`)에서 돌리고 종료코드로 판정한다. 파이프를 붙이지 않는다.
`.md`·`config.yaml`은 Edit로 부분 수정한다(전체 Write 재작성·`sed -i` 금지). 줄 번호는 수정 전 기준이니 인용한 문장으로 위치를 찾는다.

## 1. 기존 설치 방식 파일 지우기

- [x] 1.1 `install.sh` 파일을 지운다(`rm install.sh`, `git rm`이나 커밋은 하지 않는다). 확인: `test -e install.sh; echo "rc=$?"`가 `rc=1`, `git status --short install.sh`가 ` D install.sh`.
- [x] 1.2 `.claude/skills/init-sdd/` 디렉터리를 통째로 지운다(`rm -r .claude/skills/init-sdd`). 확인: `test -e .claude/skills/init-sdd; echo "rc=$?"`가 `rc=1`, `git status --short .claude/skills`가 ` D .claude/skills/init-sdd/SKILL.md` 한 줄.
- [x] 1.3 비게 된 `.claude/skills/` 디렉터리를 지운다(`rmdir .claude/skills` — 비어 있지 않으면 실패하니 그때는 멈추고 남은 파일을 보고한다). 확인: `test -e .claude/skills; echo "rc=$?"`가 `rc=1`, `ls -A .claude`가 `CLAUDE.md`, `settings.json` 둘뿐.

## 2. `.claude/CLAUDE.md`를 표식 없는 이 저장소 지침으로 바꾸기 (design.md D4)

- [x] 2.1 저장소 구조 표에서 `install.sh`, `.claude/skills/init-sdd/` 행을 지우고, `.claude/settings.json` 행 설명을 `이 저장소의 개발 권한. \`/sdd:init\` 권한 목록의 원본이다`로 고친다. 확인: `grep -n 'settings.json' .claude/CLAUDE.md`의 표 행에 `install`이 없다.
- [x] 2.2 "## 이 저장소도 SDD로 개발한다" 절을 design.md D4의 목표 문안 그대로 바꾼다(구획 본문을 이 절에 합치고, "구획 안의 `.claude/agents/` … 경로는 설치 대상 프로젝트 기준이다" 글머리표를 없앤다). 확인: `grep -nE '^순서: |^큰 작업이면 |오케스트레이터|code-explorer|analyzer|agents/<이름>.md' .claude/CLAUDE.md`에 여섯 가지가 모두 나오고, `grep -c '\.claude/agents/' .claude/CLAUDE.md`가 `0`.
- [x] 2.3 "## 검증 명령" 절의 `bash -n` 반복문에서 `install.sh`를 빼고(`for f in bin/sdd-init bin/sdd-openspec hooks/session-start.sh; do …`), "`install.sh`나 아래 표식 구획을 고쳤으면 …" 글머리표와 그 다음 줄 "이 저장소 안에서는 돌리지 않는다."를 지운다. 확인: `grep -c 'install' .claude/CLAUDE.md`가 `0`.
- [x] 2.4 "## 표식 구획" 절 전체와 `<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->` 구획(두 표식 줄 포함)을 지운다. 확인: `grep -cE 'init-SDD:(begin|end)|표식 구획' .claude/CLAUDE.md`가 `0`, `grep -n '^#' .claude/CLAUDE.md`의 절 순서가 제목 → 띄우기 → 저장소 구조 → 이 저장소도 SDD로 개발한다 → 검증 명령 → 커밋 규칙, `grep -c 'claude --plugin-dir \.' .claude/CLAUDE.md`가 1 이상.
- [x] 2.5 `.claude/CLAUDE.md` 마크다운 무결성: `grep -c 'ORCA_RICH''_MD' .claude/CLAUDE.md`가 `0`, `grep -c '^```' .claude/CLAUDE.md`가 짝수.

## 3. README 정리 (design.md D5)

- [x] 3.1 "빠른 시작"의 설치 코드블록을 한 줄짜리 `text` 코드블록 두 개(`/plugin marketplace add CHO-YoungSeok/init-SDD` / `/plugin install sdd@sdd-marketplace`)로 나누고 앞 문장을 D5대로 고친다. 같은 절의 "다른 설치 방식(복사·링크)과 자세한 설명은 …" 문장과 필요한 것 표 OpenSpec CLI 행의 복사·링크 칸을 D5대로 고친다.
- [x] 3.2 "### 쓰는 법"의 괄호 "(복사·링크 방식으로 깐 프로젝트는 `/orchestra`)"를 지운다.
- [x] 3.3 "### 먼저 고른다 — 플러그인인가, 복사 방식인가, 링크 방식인가" 절을 지우고, 그 안의 플러그인 설명 문단을 "### 플러그인으로 설치" 절 첫 문단으로 옮긴다. 절 제목의 "(권장)"을 뗀다. 그 절의 설치 코드블록도 3.1과 같은 모양으로 둘로 나눈다.
- [x] 3.4 "### 기존 설치 방식 (폐기 예고)" 절부터 "**Claude Code를 새 세션으로 다시 열어야** 새 에이전트와 스킬이 잡힌다." 줄까지 통째로 지운다(하위 절 기존 방식에서 옮기기, 방법 1·2, CLAUDE.md 합치기, 이름이 겹칠 수 있는 파일, 설치 확인, 이미 설치한 프로젝트 안내 포함). 확인: "### Windows" 절 바로 다음 `###` 제목이 "### 프로젝트 규칙 심기 …"다.
- [x] 3.5 "프로젝트 규칙 심기" 첫 문장, "커스터마이즈" 첫 문단 끝 문장, "알아 둘 것"의 OpenSpec 버전·버전 확인 항목을 D5대로 고친다.
- [x] 3.6 README 확인: (a) `grep -n -B1 -A1 '^/plugin ' README.md`에서 `/plugin` 줄 네 개 각각의 바로 앞 줄이 ` ```text `, 바로 뒤 줄이 ` ``` `다. (b) `grep -cE 'install[.]sh|init-sd[d]|복사 방[식]|링크 방[식]|기존 설[치]|init-SDD:(begin|end)|복사·링크' README.md`가 `0`. (c) `grep -c '/sdd:init' README.md`가 1 이상, `grep -c '\.claude/commands/opsx/' README.md`가 1 이상, `grep -c 'claude --plugin-dir \.' README.md`가 1 이상, `grep -c 'extraKnownMarketplaces' README.md`가 1 이상. (d) `grep -c 'ORCA_RICH''_MD' README.md`가 `0`, `grep -c '^ *```' README.md`가 짝수.

## 4. 지시문 두 개와 config.yaml (design.md D6)

- [x] 4.1 `skills/orchestra/SKILL.md`: "**에이전트 이름:**" 문단을 "아래 호출 예시는 플러그인 이름 `sdd:<이름>`을 쓴다." 한 문장만 남기고, "메인 세션이 직접 치는 `sdd-openspec` 명령(…)은 … `openspec`으로 바꿔 친다." 줄을 지운다. 확인: `grep -cE 'not found|PATH에 없으면|기존 설[치]|install[.]sh|init-sd[d]' skills/orchestra/SKILL.md`가 `0`, `grep -n 'subagent_type: "' skills/orchestra/SKILL.md`의 모든 줄이 `sdd:`로 시작, frontmatter `---` 두 줄과 `name`·`description` 키가 그대로, `grep -c 'ORCA_RICH''_MD'`가 `0`, 코드펜스 줄 수 짝수.
- [x] 4.2 `skills/sdd-rules/SKILL.md`: "쓰는 스킬" 절의 "`sdd-openspec`이 PATH에 없으면(…) `openspec`을 쓰고 그 버전을 보고서에 적는다." 부분을 지워 1.14.1 이상 규칙에서 문장이 끝나게 하고, "code-explorer 부르기" 절의 `not found` 대비 규칙 두 줄을 지운다. 확인: `grep -cE 'not found|PATH에 없으면|기존 설[치]|install[.]sh|init-sd[d]' skills/sdd-rules/SKILL.md`가 `0`, `grep -c '1.14.1 이상이면' skills/sdd-rules/SKILL.md`가 `1`, `grep -c 'sdd:code-explorer' skills/sdd-rules/SKILL.md`가 1 이상, `grep -c '^## ' skills/sdd-rules/SKILL.md`가 `7`, frontmatter 키가 `name`·`description` 둘뿐, `grep -c 'ORCA_RICH''_MD'`가 `0`, 코드펜스 줄 수 짝수.
- [x] 4.3 `openspec/config.yaml` `context:`: 실행 파일 줄의 `, install.sh`, "기존 설치 방식(폐기 예고)" 줄, `bash install.sh --dry-run` 줄을 지우고 `bash -n` 줄을 `  - bash -n bin/sdd-init bin/sdd-openspec hooks/session-start.sh (문법 검사)`로 고친다. 확인: `grep -cE 'install[.]sh|init-sd[d]|기존 설[치]' openspec/config.yaml`이 `0`, `grep -n '^context:' openspec/config.yaml`이 0칸 들여쓰기, `./bin/sdd-openspec context; echo "exit=$?"` 출력에 `Warning`이 없다, `./bin/sdd-openspec instructions proposal --change remove-legacy-install --json > "$TMPDIR/ctx.json"; echo "exit=$?"` 뒤 `python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print("context" in d)' "$TMPDIR/ctx.json"`가 `True`.

## 5. 통합 검증 (받아들일 조건 전체)

- [x] 5.1 플러그인 검증: `claude plugin validate . --strict; echo "exit=$?"`와 `claude plugin validate .claude-plugin/plugin.json --strict; echo "exit=$?"`가 둘 다 `exit=0`.
- [x] 5.2 OpenSpec 검증: `./bin/sdd-openspec validate "remove-legacy-install" --strict; echo "exit=$?"`가 `exit=0`, `./bin/sdd-openspec status --change "remove-legacy-install" --json >/dev/null; echo "metadata exit=$?"`가 `metadata exit=0`.
- [x] 5.3 셸 문법: `for f in bin/sdd-init bin/sdd-openspec hooks/session-start.sh; do bash -n "$f"; echo "$f rc=$?"; done`가 세 줄 모두 `rc=0`.
- [x] 5.4 낡은 낱말 grep(받아들일 조건 3번, 대소문자 구분): `git ls-files | grep -vE '^openspec/|^docs/field-validation[.]md$' | while IFS= read -r f; do [ -f "$f" ] && printf '%s\0' "$f"; done | xargs -0 grep -nE 'install[.]sh|init-sd[d]|복사 방[식]|링크 방[식]|기존 설[치]|init-SDD:(begin|end)'; echo "rc=$?"`가 출력 없이 `rc=1`(일치 없음)이다. `openspec/`은 worker 단계에서 뺀다 — `openspec/config.yaml`은 4.3에서 따로 봤고, 메인 spec은 finalizer sync 뒤에 `openspec/changes/`만 빼고 같은 grep을 다시 돌려 0건이어야 한다(finalizer·reviewer 몫으로 결과를 보고한다).
- [x] 5.5 지운 파일 확인(받아들일 조건 1번의 worker 단계 대응): `git status --short`에 ` D install.sh`와 ` D .claude/skills/init-sdd/SKILL.md`가 있고, 이 change 밖에서 바뀐 파일은 `README.md`, `.claude/CLAUDE.md`, `skills/orchestra/SKILL.md`, `skills/sdd-rules/SKILL.md`, `openspec/config.yaml`뿐이다(`agents/`, `bin/`, `hooks/`, `skills/init`, `skills/sdd-sync`, `.claude-plugin/`, `.gitignore`, `.claude/settings.json`, `docs/`, `openspec/specs/`, `openspec/changes/archive/`는 그대로). `git ls-files`에서 빠지는 것은 finalizer 커밋 뒤에 확인한다.
