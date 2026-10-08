## Context

동기는 proposal.md "Why"를 본다. 여기서는 정정 6가지를 **어떤 문구로** 바꿀지만 정한다.
spec 델타는 없다(`skip_specs: true`). 기준은 proposal의 "받아들일 조건"이다.

설계 중 실제로 확인한 사실:

- `.claude/agents/code-explorer.md` 3행 description은 "다른 7개", 12행 본문만 "다른 6개"다.
  저장소 안에서 "다른 6개"가 남은 곳은 이 한 줄뿐이다.
- `.claude/agents/analyzer.md` 18행: "네가 쓰는 파일은 `analysis.md` 하나뿐이다." 그런데
  orchestra 표 83행은 "(산출물 안 씀)"이다. "산출물 안 씀"이 남은 곳도 이 한 줄뿐이다.
- `.claude/agents/reviewer.md`: 3행 description "읽기 전용이며 고치지 않고 보고한다",
  16행 "Write 권한은 `review.md`를 남기기 위한 것뿐이다". 실제 `tools:`에는 Edit도 있고
  162행·166행은 재리뷰 때 Edit으로 review.md를 고치라고 한다. 3행·16행이 그와 어긋난다.
- `/tmp` 하드코딩: regression-verifier.md 89행, init-sdd SKILL.md 290·305행,
  README.md 54·56·57·79·80·81·82·99행. `openspec/specs/` 아래에는 `/tmp` 요구가 없다
  (`grep -rln "/tmp" openspec/specs` 결과 없음).
- init-sdd SKILL.md의 같은 코드블록은 이미 `TMP="$(mktemp)"`를 쓴다. 이번 정정은 그 관례에 맞춘다.
- `openspec update` 실측 (CLI 1.12.0, `openspec init --tools claude` 후 `.claude/skills`와
  `.claude/commands`를 지운 상태):
  출력 `No configured tools found.` / `Run "openspec init" to set up tools.`, **종료코드는 0**이다.
  즉 "실패"라기보다 "아무것도 안 하고 끝난다". README 문구는 이 사실대로 쓴다.
- `install.sh`는 9행에서 자기 위치를 `BASH_SOURCE`로 찾는다. 어느 경로에 clone해도 동작한다.

## Goals / Non-Goals

**Goals:**
- 6가지 문구를 사실에 맞춘다. 동작·도구 목록·frontmatter 키는 그대로 둔다.
- 임시 경로를 `mktemp` 한 가지 방식으로 통일한다.

**Non-Goals:**
- 지정된 줄 밖의 문장 다듬기. 같은 파일 안이라도 proposal에 없는 곳은 건드리지 않는다.
- README 133행·273행의 `openspec update` 안내 변경 (스캐폴드가 있을 때는 맞는 안내다).
- `.agents/skills/claude-handoff/` 안의 SKILL.md, scripts/ 변경.

## Decisions

### D1. 임시 경로는 모두 `mktemp` 변수로 바꾼다
- 지시문(regression-verifier, init-sdd)은 `변수="$(mktemp)"`로 한 번 만들고 `"$변수"`로 쓴다.
  init-sdd 블록이 이미 `TMP="$(mktemp)"`를 쓰므로 같은 모양이 읽기 쉽다.
- 이름 충돌 방지: init-sdd 블록은 `TMP`를 이미 두 번 쓰고 덮어쓴다. 조각 보관용은 따로
  `SNIP`이라는 이름을 쓴다. `TMP`를 재사용하면 2단계의 `TMP="$(mktemp)"`가 조각 경로를 덮어써서
  4단계에서 조각을 잃는다.
- 대안 "세션별 고정 경로(`$TMPDIR/init-sdd-...`)": 이름이 고정이라 두 번 돌리면 겹친다. 버렸다.

### D2. README는 `SDD_SRC` 변수 한 개를 쓴다 (`mktemp -d`)
- README는 사람이 읽는 예시다. `"$(mktemp -d)"`를 매 줄 쓰면 읽기 어렵다. 맨 위에서 한 번
  `SDD_SRC="$(mktemp -d)/init-SDD"`로 정하고 나머지는 `"$SDD_SRC/..."`로 쓴다.
  이름이 "init-SDD 원본 위치"라는 뜻이 보인다.
- "방법 2 — 손으로" 블록은 현재 clone 줄 없이 `/tmp/init-SDD`가 있다고 가정한다. 변수는
  셸이 바뀌면 사라지므로, 방법 2 블록 맨 앞에도 같은 두 줄(변수 + clone)을 넣어 **블록 혼자로
  완결**되게 한다. CLAUDE.md 합치기 블록(99행)은 방법 2의 이어지는 단계이므로 "같은 터미널에서"라는
  주석만 붙인다.
- 대안 `~/init-SDD`: 가장 읽기 쉽지만 두 번째 실행 때 "already exists"로 clone이 실패하고
  홈에 찌꺼기를 남긴다. 버렸다.

### D3. 파일별 정확한 문구
아래 "현재 → 바꿀 문구"를 그대로 쓴다. worker는 Edit 도구로 해당 문자열만 바꾼다.

**(1) `.claude/agents/code-explorer.md` 12행**
- 현재: `너는 다른 6개 에이전트가 코드베이스를 넓게 뒤져야 할 때 그들이 직접 부르는 보조 에이전트다.`
- 바꿀 것: `너는 다른 7개 에이전트가 코드베이스를 넓게 뒤져야 할 때 그들이 직접 부르는 보조 에이전트다.`

**(2) `.claude/skills/orchestra/SKILL.md` 83행 (표의 analyzer 행)**
- 현재: `| analyzer | \`openspec-explore\` | 분석 + 방안 3가지 (산출물 안 씀) — **요청했을 때만 부른다** |`
- 바꿀 것: `| analyzer | \`openspec-explore\` | 분석 + 방안 3가지 → \`analysis.md\` (그 밖의 산출물은 안 씀) — **요청했을 때만 부른다** |`
- 표의 칸 수(`|` 4개)는 그대로다.

**(3) `.claude/agents/reviewer.md`**
- 3행 description 끝:
  `읽기 전용이며 고치지 않고 보고한다.` → `review.md 외에는 고치지 않고 보고한다.`
  (description 앞부분과 `name:`/`model:`/`tools:` 줄은 그대로)
- 16행:
  `Write 권한은 \`review.md\`를 남기기 위한 것뿐이다. **다른 파일은 절대 쓰지 마라.**`
  → `Write/Edit 권한은 \`review.md\`를 남기고 재리뷰 때 고치기 위한 것뿐이다. **review.md 외에는 절대 고치지 마라.**`

**(4-a) `.claude/agents/regression-verifier.md` 89행 (들여쓴 코드블록 안)**
- 현재: `    git show <기준커밋>:<파일> > /tmp/before.txt      # 변경 전 내용만 꺼내 본다`
- 바꿀 것 (두 줄, 들여쓰기 4칸 유지):
  ```
      before="$(mktemp)"                              # 임시 파일 (경로를 고정하지 않는다)
      git show <기준커밋>:<파일> > "$before"            # 변경 전 내용만 꺼내 본다
  ```

**(4-b) `.claude/skills/init-sdd/SKILL.md` 290행, 305행**
- 290행 현재:
  `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$대상/CLAUDE.md" > /tmp/init-sdd-snippet.txt`
- 바꿀 것 (두 줄):
  ```
  SNIP="$(mktemp)"   # 4) 단계까지 같은 터미널에서 이어서 한다
  sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$대상/CLAUDE.md" > "$SNIP"
  ```
- 305행 현재: `printf '\n\n%s\n' "$(cat /tmp/init-sdd-snippet.txt)" >> "$TMP"`
- 바꿀 것: `printf '\n\n%s\n' "$(cat "$SNIP")" >> "$TMP"`

**(4-c) `README.md`**
- 방법 1 블록(53~58행) 전체를 아래로:
  ```bash
  SDD_SRC="$(mktemp -d)/init-SDD"              # 받을 임시 폴더 (매번 새로 만든다)
  git clone --depth 1 https://github.com/CHO-YoungSeok/init-SDD.git "$SDD_SRC"
  cd /path/to/your-project
  bash "$SDD_SRC/install.sh" --dry-run         # 무엇을 할지 먼저 본다
  bash "$SDD_SRC/install.sh"                   # 설치
  ```
- 방법 2 블록: `cd /path/to/your-project` **앞에** 두 줄을 넣는다.
  ```bash
  SDD_SRC="$(mktemp -d)/init-SDD"              # 받을 임시 폴더
  git clone --depth 1 https://github.com/CHO-YoungSeok/init-SDD.git "$SDD_SRC"
  ```
  그리고 79~82행의 `/tmp/init-SDD/` 를 `"$SDD_SRC"/` 로 바꾼다. 예:
  `cp -r "$SDD_SRC"/.claude/agents .claude/` (뒤의 주석은 그대로)
- 99행: `sed -n '/init-SDD:begin/,/init-SDD:end/p' "$SDD_SRC"/CLAUDE.md >> CLAUDE.md   # 방법 2와 같은 터미널에서`

**(5) `README.md` 85~90행 인용 블록 (스캐폴드 설명)**
- 현재 문장 중 `로컬 디스크에는 남아 있을 수 있지만 그건 이 저장소를 마지막에 \`openspec init\`한 사람의 CLI 버전에 맞춰진 것일 뿐이다.` 부분이 틀렸다.
- 인용 블록 전체를 아래로 바꾼다:
  ```
  > **`.claude/skills/openspec-*` 와 `.claude/commands/opsx/` 는 이 저장소에 git으로
  > 커밋돼 있지 않다.** `openspec init`이 네 CLI 버전에 맞춰 만들어 주는 파일이라 추적하지
  > 않는다(`.gitignore` 참고). 그래서 clone한 사본에는 **없고**, 이미 있던 작업 폴더에서도
  > 사라질 수 있다. 없어졌으면 `openspec init --tools claude`로 다시 만든다.
  > `openspec update`로는 복구되지 않는다 — 스킬 폴더가 없으면 `No configured tools found.`만
  > 출력하고 아무것도 만들지 않는다 (종료코드는 0이라 성공처럼 보이니 주의).
  > 대상 프로젝트에서도 복사하지 말고 `openspec init --tools claude`를 직접 돌려서 네 CLI
  > 버전에 맞는 걸 새로 만들어라.
  ```

**(6) `.agents/skills/claude-handoff/README.md`**
- 1행 제목(`# Claude Handoff Skill for Antigravity (agy)`) 바로 아래, 빈 줄 하나를 두고 인용 한 줄을 넣는다:
  `> 이 디렉터리는 Antigravity(agy)용 스킬이며 이 저장소의 SDD 파이프라인과 무관하다. SDD 설치 대상이 아니다.`
- 같은 디렉터리의 `SKILL.md`, `scripts/`는 건드리지 않는다.

## Risks / Trade-offs

- [README 방법 2·CLAUDE.md 블록이 `SDD_SRC` 변수에 기대 셸을 새로 열면 빈 값이 된다]
  → 방법 2 블록은 clone 줄을 직접 갖게 해 혼자 완결되고, 99행에는 "같은 터미널에서" 주석을 단다.
- [`mktemp`로 만든 임시 파일/폴더가 남는다] → OS 임시 폴더 안이라 정리 대상이다.
  지우는 줄을 추가하면 예시가 길어져서 넣지 않았다.
- [reviewer description이 바뀌면 에이전트 목록 화면의 설명 문구가 바뀐다] → 뜻은 더 정확해질 뿐이고
  `tools:` 줄은 그대로라 권한·동작은 같다.
- [`openspec update` 종료코드 0은 CLI 1.12.0 실측값이다. 버전이 바뀌면 달라질 수 있다]
  → README 문구는 "출력 문구"를 중심으로 쓰고 종료코드는 주의 문구로만 남긴다.
