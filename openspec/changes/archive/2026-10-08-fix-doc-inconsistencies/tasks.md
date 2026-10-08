채택안: 없음 (analyzer 생략 경로, 기준은 proposal의 받아들일 조건)
핵심 결정: 임시 경로는 모두 `mktemp` 변수로 통일한다 (지시문은 `before`/`SNIP`, README는 `SDD_SRC="$(mktemp -d)/init-SDD"`).
정확한 바꿀 문구는 design.md "D3. 파일별 정확한 문구"에 있다. 그 문자열을 그대로 쓴다.
`.claude/agents/*.md`, `.claude/skills/**/SKILL.md`는 **Edit 부분 수정만** 한다 (Write 전체 재작성, `sed -i` 금지).
`openspec/changes/plugin-lite-sdd-distribution/`는 건드리지 않는다.

## 1. 에이전트·스킬 지시문 정정

- [x] 1.1 `.claude/agents/code-explorer.md` 12행의 "다른 6개"를 "다른 7개"로 Edit한다 (design D3-(1)). 확인: `grep -n "다른 [67]개" .claude/agents/code-explorer.md` 결과 두 줄(3행, 12행)이 모두 "7개"
- [x] 1.2 `.claude/skills/orchestra/SKILL.md` 83행 analyzer 행을 design D3-(2) 문구로 Edit한다. 확인: `grep -n "산출물 안 씀" .claude/skills/orchestra/SKILL.md` 결과 없음, `grep -n "^| analyzer" .claude/skills/orchestra/SKILL.md`에 `analysis.md`가 보이고 `|`가 4개
- [x] 1.3 `.claude/agents/reviewer.md` 3행 description 끝과 16행을 design D3-(3) 문구로 각각 Edit한다. 확인: `grep -n "review.md 외에는" .claude/agents/reviewer.md`가 3행과 16행을 보여 주고, `sed -n 5p .claude/agents/reviewer.md`가 `tools: Read, Grep, Glob, Bash, Write, Edit, TodoWrite, Agent` 그대로
- [x] 1.4 `.claude/agents/regression-verifier.md` 89행을 design D3-(4-a)의 두 줄(들여쓰기 4칸)로 Edit한다. 확인: `grep -n "/tmp" .claude/agents/regression-verifier.md` 결과 없음, `grep -n 'before="$(mktemp)"' .claude/agents/regression-verifier.md` 한 줄
- [x] 1.5 `.claude/skills/init-sdd/SKILL.md` 290행을 design D3-(4-b)의 두 줄(`SNIP="$(mktemp)"` + sed)로, 305행의 `cat /tmp/init-sdd-snippet.txt`를 `cat "$SNIP"`로 Edit한다. 확인: `grep -n "/tmp" .claude/skills/init-sdd/SKILL.md` 결과 없음, `grep -n 'SNIP' .claude/skills/init-sdd/SKILL.md`가 세 줄(정의, sed, printf)

## 2. README 정정

- [x] 2.1 `README.md` 방법 1 코드블록(53~58행)을 design D3-(4-c)의 `SDD_SRC` 다섯 줄로 Edit한다. 확인: 해당 블록에 `SDD_SRC="$(mktemp -d)/init-SDD"`와 `bash "$SDD_SRC/install.sh" --dry-run`이 있다
- [x] 2.2 `README.md` 방법 2 코드블록에서 `cd /path/to/your-project` 앞에 `SDD_SRC` 정의 + clone 두 줄을 넣고, 79~82행의 `/tmp/init-SDD/`를 `"$SDD_SRC"/`로 Edit한다 (뒤 주석 유지). 확인: 그 블록에 `/tmp`가 없고 `"$SDD_SRC"/.claude/`가 네 줄
- [x] 2.3 `README.md` 99행 CLAUDE.md 합치기 줄을 design D3-(4-c)의 `"$SDD_SRC"/CLAUDE.md ... # 방법 2와 같은 터미널에서` 문구로 Edit한다. 확인: `grep -n "/tmp" README.md` 결과 없음
- [x] 2.4 `README.md` 85~90행의 스캐폴드 인용 블록을 design D3-(5) 문구로 Edit한다. 확인: `grep -n "사라질 수 있다" README.md`, `grep -n "로 다시 만든다" README.md`, `grep -n "No configured tools found" README.md`가 각각 한 줄 이상 찾고, `grep -n "남아 있을 수 있지만" README.md` 결과는 없다

## 3. claude-handoff 안내

- [x] 3.1 `.agents/skills/claude-handoff/README.md` 1행 제목 아래에 빈 줄 + design D3-(6)의 인용 한 줄을 Edit으로 넣는다. 확인: `grep -n "SDD 파이프라인과 무관" .agents/skills/claude-handoff/README.md` 한 줄, `git status --short .agents/`에 README.md만 수정으로 나온다 (SKILL.md, scripts/ 변경 없음)

## 4. 전체 확인

- [x] 4.1 `grep -n "/tmp" .claude/agents/regression-verifier.md .claude/skills/init-sdd/SKILL.md README.md` 결과가 비어 있음을 확인한다
- [x] 4.2 수정한 7개 파일의 마크다운 무결성을 확인한다: 각 파일 `grep -c '^\s*```'` 값이 짝수, `.claude/agents/*.md`·`SKILL.md`는 1행과 frontmatter 닫는 `---`가 그대로이고 `name:`/`description:`/`tools:` 키가 남아 있다
- [x] 4.3 `git diff --stat`에 proposal "Impact"의 7개 파일만 나오는지 확인한다 (`openspec/changes/plugin-lite-sdd-distribution/`은 다른 작업이 쓰는 미추적 디렉터리라 diff에 안 나온다. 이 작업에서 열지도 고치지도 않는다)
- [x] 4.4 `openspec validate fix-doc-inconsistencies --strict; echo "exit=$?"`와 `openspec status --change fix-doc-inconsistencies --json >/dev/null; echo "exit=$?"`가 모두 `exit=0`임을 확인한다
