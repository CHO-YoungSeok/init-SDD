---
name: init-sdd
description: 개인 agentic 설정(서브에이전트 8개, orchestra·sdd-rules·sdd-sync 스킬, 권한 설정)을 별도의 개인 git 저장소에 두고, 공유 프로젝트의 `.claude/` 안에서는 그것을 심볼릭 링크로 가리키게 해 준다. "개인 설정을 별도 저장소로 분리해줘", "링크 방식으로 SDD 깔아줘", "링크로 연결해줘", "연결 풀어줘", "원래대로 되돌려줘", "지금 연결돼 있어?", "링크 상태 봐줘" 같은 말에 쓴다.
---

# 링크 방식으로 SDD 얹기 (init-sdd)

## 이 스킬이 무엇인가 — 복사 방식과 어떻게 다른가

**플러그인이 권장 설치 방식이다.** 이 스킬(링크 방식)과 `install.sh`(복사 방식)는 기존 설치 방식으로 남아 있다.
플러그인 설치 안내는 `README.md`의 `## 설치` 절에 있다 — 여기에 다시 적지 않는다.
이미 링크를 건 프로젝트를 플러그인으로 옮기려면 [풀기](#풀기)로 링크를 푼 뒤 플러그인을 설치한다.
링크와 플러그인을 함께 두면 같은 에이전트가 두 이름(`sdd:<이름>`, `<이름>`)으로 실린다.

기존 설치 방식은 두 가지다.

- **복사 방식** — `install.sh`. 파일을 대상 프로젝트 안으로 복사해 넣는다. 그 파일은
  대상 프로젝트의 공유 git 저장소에 커밋될 수 있는 자리에 놓인다.
- **링크 방식** — **이 스킬이다.** 개인 설정은 **개인 git 저장소** 한 곳에만 두고,
  공유 프로젝트의 `.claude/` 안에는 그것을 가리키는 **심볼릭 링크**만 놓는다.
  개인 파일이 공유 저장소에 남지 않는다.

**어떤 때 어느 것을 쓰는지 고르는 안내는 이 저장소 `README.md`의 `## 설치` 맨 앞에 있다.**
거기 한 곳에만 있다. 이 문서에 그 표를 다시 옮겨 적지 마라 — 같은 문구의 사본이 갈라지는
것이 이 저장소에서 가장 나쁜 고장이고 이미 두 번 났다. 사용자가 "어느 걸 써야 해?"라고
물으면 `README.md`의 그 절을 보여줘라.

이 스킬은 세 가지를 한다. 사용자의 말에 따라 해당 절로 간다.

| 사용자가 하는 말 | 가는 곳 |
|---|---|
| "연결해줘", "링크 방식으로 깔아줘" | [걸기](#걸기) |
| "풀어줘", "원래대로 돌려줘" | [풀기](#풀기) |
| "지금 연결돼 있어?", "상태 봐줘" | [상태 보기](#상태-보기) |

**무엇을 하든 원칙은 하나다: 원래 있던 것을 잃지 않는 것이 링크를 거는 것보다 우선한다.**
못 하겠으면 멈추고 사실을 말한다. 짐작해서 옮기거나 덮어쓰지 않는다.

---

## 먼저: 경로 세 개를 알아낸다

경로를 문서에 박아 두지 않는다. 실행할 때마다 알아낸다. 아래 세 값을 정하고 사용자에게
보여준 뒤 시작한다.

| 이름 | 무엇 | 알아내는 법 |
|---|---|---|
| `원본` | 이 init-SDD 복제본 | 이 `SKILL.md`가 있는 위치에서 위로 올라가며 `install.sh`와 `.claude/CLAUDE.md`가 **함께** 있는 디렉터리를 찾는다 |
| `대상` | SDD를 얹을 공유 프로젝트 | 기본값은 현재 작업 디렉터리. **사용자에게 확인한다** |
| `개인` | 개인 agentic 저장소 | 기본값 `~/work-space/agentic`을 **권하되 실행 시점에 사용자에게 확인한다** |

`원본`을 찾는 방법. 스킬이 불릴 때 알려 주는 기준 디렉터리에서 시작한다.

```bash
d="<이 스킬 파일이 있는 디렉터리>"
SRC=""
while [[ "$d" != "/" ]]; do
  if [[ -f "$d/install.sh" && -f "$d/.claude/CLAUDE.md" ]]; then SRC="$d"; break; fi
  d="$(dirname "$d")"
done
[[ -n "$SRC" ]] || echo "원본을 못 찾았다 — 사용자에게 init-SDD 복제본 경로를 물어라"
```

`install.sh` 하나만 보고 판단하지 않는다. `.claude/CLAUDE.md`까지 함께 보는 이유는 조각을 뽑을
원본이 실제로 거기 있어야 하기 때문이다. **못 찾으면 짐작하지 말고 사용자에게 묻는다.**

`개인` 경로는 **사용자 것이다.** `~/work-space/agentic`은 권하는 기본값일 뿐이고, 사용자가
다른 경로를 주면 그것을 쓴다. 한 번 정한 뒤로는 아래 모든 단계에서 그 값을 변수로만 쓴다.
절차 중간에 기본값을 다시 적어 넣지 마라.

`프로젝트` 이름(개인 저장소 안의 디렉터리 이름)의 기본값은 **대상 프로젝트 디렉터리의
이름**이다 (`basename "$대상"`).

---

## 링크 대상 — 골라서 링크한다

**`.claude/`를 통째로 링크하지 마라.** 그 안에는 소유자가 다른 것이 섞여 있다.

### 링크하는 것 (개인 소유) — 정확히 다섯 개

| 대상 프로젝트의 자리 | 가리킬 곳 | 종류 |
|---|---|---|
| `<대상>/.claude/agents` | `<개인>/<프로젝트>/agents` | 디렉터리 |
| `<대상>/.claude/skills/orchestra` | `<개인>/<프로젝트>/skills/orchestra` | 디렉터리 |
| `<대상>/.claude/skills/sdd-rules` | `<개인>/<프로젝트>/skills/sdd-rules` | 디렉터리 |
| `<대상>/.claude/skills/sdd-sync` | `<개인>/<프로젝트>/skills/sdd-sync` | 디렉터리 |
| `<대상>/.claude/settings.json` | `<개인>/<프로젝트>/settings.json` | 파일 |

링크는 **절대 경로로** 만든다. 상대 경로 링크는 대상 프로젝트가 옮겨지면 끊기지만, 절대
경로는 개인 저장소가 옮겨질 때만 끊긴다. 개인 저장소는 한 번 정하는 것이라 더 안정적이다.

### 링크하지 않는 것

| 무엇 | 왜 |
|---|---|
| `.claude/skills/openspec-*` (6개: explore, propose, update-change, apply-change, sync-specs, archive-change) | `openspec init --tools claude`가 **사용자의 CLI 버전에 맞는 것**을 대상 프로젝트에 직접 깐다. 개인 저장소가 들고 다닐 물건이 아니다 |
| `.claude/commands/opsx/` | 같은 이유. openspec CLI가 깐다 |
| `.claude/settings.local.json` | 개인 로컬 설정이고 이미 추적 제외 대상이다. **만들지도 고치지도 지우지도 않는다** |

`.claude/skills/` **자체는 실제 디렉터리로 남긴다.** 그것까지 링크하면 `openspec-*` 6개가
개인 저장소로 끌려간다. `skills/` 안의 세 개만 링크한다. 같은 이유로 `.claude/` 통째 링크는
금지다.

---

## 걸기

### 1단계 — 개인 저장소를 준비한다

`개인` 경로에 git 저장소가 있는지 본다.

```bash
git -C "$개인" rev-parse --git-dir >/dev/null 2>&1
```

| 판정 | 무엇을 하는가 |
|---|---|
| git 저장소가 아니다 (또는 경로가 없다) | 디렉터리를 만들고 `git init` 한 뒤 최초 커밋을 만든다 |
| 이미 git 저장소다 | **그것을 쓴다. `git init`을 다시 돌리지 않는다** |

```bash
mkdir -p "$개인"
git -C "$개인" init
git -C "$개인" commit --allow-empty -m "init: 개인 agentic 설정 저장소"
```

원격(GitHub 등)에 올리는 것은 하지 않는다. 원하면 사용자가 직접 하면 된다 — 올려 두면
다른 컴퓨터에서는 복제한 뒤 링크만 다시 걸면 된다.

### 2단계 — 프로젝트별 디렉터리를 정한다

개인 저장소 안에 대상 프로젝트별 디렉터리를 둔다. 이름의 기본값은 대상 폴더 이름이다.
같은 이름이 이미 있을 수 있으니, 각 디렉터리는 자기가 어느 대상을 위한 것인지 적어 둔다.

```bash
echo "$대상" > "$개인/$프로젝트/.init-sdd-target"   # 대상의 절대 경로 한 줄
```

같은 이름의 디렉터리가 **이미 있을 때** 세 갈래다.

| 상황 | 무엇을 하는가 |
|---|---|
| `.init-sdd-target`의 값이 지금 대상과 **같다** | 그 디렉터리를 **다시 쓴다** (재실행, 다른 컴퓨터에서 복원) |
| `.init-sdd-target`의 값이 **다르다** | **멈추고 다른 이름을 묻는다.** 이름만 같은 다른 프로젝트다 |
| `.init-sdd-target`이 **없다** | **멈추고 사용자에게 확인한다.** 사람이 손으로 만든 것일 수 있다 |

**덮어쓰는 길은 없다.** 짐작으로 덮어쓰면 다른 프로젝트의 에이전트 설정을 잃는다.

디렉터리가 새로 생긴 것이면 원본에서 한 번 채운다 (초기 이관). 그 뒤로는 개인 저장소가
원본이고, 다른 프로젝트도 같은 것을 가리킨다.

```bash
mkdir -p "$개인/$프로젝트/skills"
cp -R "$SRC/agents"                "$개인/$프로젝트/agents"
cp -R "$SRC/skills/orchestra"      "$개인/$프로젝트/skills/orchestra"
cp -R "$SRC/skills/sdd-rules"      "$개인/$프로젝트/skills/sdd-rules"
cp -R "$SRC/skills/sdd-sync"       "$개인/$프로젝트/skills/sdd-sync"
cp    "$SRC/.claude/settings.json" "$개인/$프로젝트/settings.json"
```

### 3단계 — 자리가 비어 있는지 본다 (링크를 만들기 **전에** 다섯 자리 모두)

판정할 때 `-e`와 `-L`을 **함께** 본다. **끊긴 링크는 `-e`가 거짓이다.** `-L`을 안 보면
끊긴 링크가 "없다"로 판정되어 그 위에 링크를 만들려다 실패한다.

| 그 자리의 상태 | 판정 방법 | 무엇을 하는가 |
|---|---|---|
| 없다 | `[[ ! -e "$p" && ! -L "$p" ]]` | 링크를 만든다 |
| **이 개인 저장소**를 가리키는 링크다 | `[[ -L "$p" ]]` 이고 `readlink "$p"`가 정해진 곳과 같다 | 이미 걸려 있다. **그대로 둔다** |
| **다른 곳**을 가리키는 링크다 | `[[ -L "$p" ]]` 이고 `readlink`가 다르다 | **멈추고 어디를 가리키는지 알린다** |
| 실제 파일·디렉터리이고 git이 **추적 중**이다 | `git -C "$대상" ls-files -- "<상대경로>"`에 결과가 있다 | **멈추고 보고한다. 절대 옮기지 않는다** |
| 실제 파일·디렉터리이고 **미추적**이다 | 위가 빈 출력이다 | 알린 뒤, **사용자가 명시적으로 그러라고 하면** `<경로>.init-sdd-backup-<시각>`으로 비켜 둔다. 지우지 않는다 |

**추적 중이면 예외 없이 멈춘다.** 추적 중인 것을 옮기면 공유 저장소에 **삭제로 나타난다.**
팀이 커밋해 둔 `.claude/agents/`를 옮기고 누군가 `git commit -a`를 하면 팀 전체가 그것을
잃는다.

멈출 때는 다음에 할 수 있는 것을 **함께 알린다.**

1. 그 내용을 개인 저장소로 옮긴(또는 합친) 뒤 이 절차를 다시 돌린다.
2. 링크 방식을 쓰지 않고 **복사 방식**(`install.sh`)을 그대로 쓴다.

### 4단계 — 링크를 만든다

다섯 자리 모두 3단계를 통과한 뒤에만 만든다.

```bash
P="$개인/$프로젝트"
mkdir -p "$대상/.claude/skills"          # skills/ 는 실제 디렉터리로 둔다
ln -s "$P/agents"                  "$대상/.claude/agents"
ln -s "$P/skills/orchestra"        "$대상/.claude/skills/orchestra"
ln -s "$P/skills/sdd-rules"        "$대상/.claude/skills/sdd-rules"
ln -s "$P/skills/sdd-sync"         "$대상/.claude/skills/sdd-sync"
ln -s "$P/settings.json"           "$대상/.claude/settings.json"
```

`ln -sf`를 쓰지 마라. `-f`는 이미 있는 것을 지운다. 이미 있는 자리는 3단계가 이미 걸렀으니
`-f`가 필요할 일이 없고, 필요해 보이면 그건 3단계를 건너뛴 것이다.

### 5단계 — 링크가 공유 저장소 git에 새지 않게 막는다

만든 링크는 공유 저장소에서 보면 **미추적 파일**이다. 그대로 두면 `git status`에 나타나고
`git add -A`에 딸려 커밋된다. 링크는 추적되지 않는 파일이라 **`.git/info/exclude`가 통한다.**
(추적 중인 `CLAUDE.md`에는 통하지 않는다 — 6단계를 봐라. 이것이 두 갈래로 갈리는 이유다.)

`.git/info/exclude`는 그 컴퓨터의 그 복제본에만 있는 파일이라 커밋되지 않는다. 그래서
공유 저장소를 건드리지 않고 개인 파일을 숨길 수 있다. **`.gitignore`는 고치지 않는다** —
그건 추적되는 공유 파일이라 고치는 순간 그 변경 자체가 커밋 대상이 된다.

적을 때 표시로 둘러싼다. 풀 때 그 사이만 지우면 **사용자가 원래 적어 둔 줄은 하나도
건드리지 않는다** (예: 그 프로젝트가 이미 적어 둔 `docs/` 같은 줄).

```bash
cat >> "$대상/.git/info/exclude" <<'EOF'
# init-sdd:begin
.claude/agents
.claude/skills/orchestra
.claude/skills/sdd-rules
.claude/skills/sdd-sync
.claude/settings.json
CLAUDE.md
EOF
echo "# init-sdd:end" >> "$대상/.git/info/exclude"
```

`CLAUDE.md` 줄은 **그 파일이 미추적일 때만** 넣는다 (6단계의 판정 결과에 따른다). 추적
중이면 넣어도 아무 효과가 없고, 넣어 두면 막혔다고 착각하게 만든다.

### 6단계 — `CLAUDE.md`: 조각을 붙이고, 그 변경을 공유 git에서 뺀다

#### (a) 조각은 원본 한 벌에서 뽑는다

조각 문구를 이 문서에 베껴 적지 않는다. 원본 `.claude/CLAUDE.md`의 마커 구획에서 뽑는다.
조각 원본이 저장소 전체에 한 벌인 것은 `install.sh`도 지키는 요구사항이다.

```bash
SNIPPET="$(sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$SRC/.claude/CLAUDE.md")"
[[ -n "$SNIPPET" ]] || echo "멈춘다: 원본 .claude/CLAUDE.md 의 마커(init-SDD:begin ~ init-SDD:end)를 확인해라"
```

**뽑은 값이 비면 멈춘다.** 빈 값을 붙이면 "성공했다"고 말하면서 아무 지시문도 안 들어가고,
사용자는 파이프라인이 왜 안 도는지 알 수 없게 된다.

#### (b) 대상에 넣을지 판정한다 — 세 갈래

| 대상 `CLAUDE.md`의 상태 | 무엇을 하는가 |
|---|---|
| 마커(`<!-- init-SDD:begin -->`)가 이미 있다 | **넣지 않는다.** 이미 들어가 있다고 알린다 (두 번 들어가면 안 된다) |
| 마커도 없고 옛 낱말(`오케스트레이터`)도 없다 | 끝에 **덧붙인다.** 기존 내용은 그대로 둔다. 파일이 없으면 새로 만든다 |
| 마커는 없는데 옛 낱말이 있다 | **넣지 않고 사실만 알린다.** 예전 방식으로 깔았을 수도 있고 사용자가 우연히 그 낱말을 썼을 수도 있어서 구별할 수 없다 |

붙일 때는 **임시 파일에 쓴 뒤 옮긴다. `sed -i`를 쓰지 마라.** 남의 프로젝트 파일이다.

```bash
TMP="$(mktemp)"
cat "$대상/CLAUDE.md" > "$TMP"
printf '\n\n%s\n' "$SNIPPET" >> "$TMP"
mv "$TMP" "$대상/CLAUDE.md"
```

#### (c) 그 변경을 공유 git에서 뺀다 — **추적 여부로 갈라진다**

`.git/info/exclude`는 **추적되지 않는 파일만** 막는다. 이미 커밋된 `CLAUDE.md`에는 전혀
통하지 않는다. 통한다고 믿으면 사용자는 막혔다고 생각하고 조각이 든 `CLAUDE.md`를 커밋한다.
그래서 **먼저 판정한다.**

```bash
git -C "$대상" ls-files --error-unmatch CLAUDE.md >/dev/null 2>&1   # 종료코드 0이면 추적 중
```

| 판정 | 쓰는 수단 | 되돌리는 법 |
|---|---|---|
| 추적 안 됨 (또는 파일이 아직 없다) | `.git/info/exclude`에 `CLAUDE.md` 한 줄 (5단계에서 함께 적는다) | 그 줄을 지운다 |
| 이미 추적 중 | `git -C "$대상" update-index --skip-worktree CLAUDE.md` | `--no-skip-worktree` |

`.gitignore`는 어느 갈래에서도 고치지 않는다.

### 7단계 — 확인하고 사용자에게 넘긴다

`git -C "$대상" status --porcelain`을 절차 전과 비교한다. 같아야 한다. 다르면 무엇이
남았는지 사용자에게 그대로 말한다. 그리고 마지막으로 [새 세션에서 확인하기](#새-세션에서-확인하기)를
안내한다. 이 단계를 빼면 안 된다 — 링크가 실제로 에이전트로 잡히는지는 아직 확인되지 않았다.

---

## skip-worktree의 함정 — 반드시 알려 줘라

`skip-worktree`를 걸어 두면 **팀원이 그 파일을 고쳐 push한 변경을 받지 못한다.** pull이
막히거나 조용히 그 변경을 건너뛴다. 그리고 사용자는 그 사실조차 모른다. 그래서 `CLAUDE.md`가
추적 중인 프로젝트에 이 절차를 돌렸다면, 아래 다섯 단계를 **함께 알려 준다.**
`git pull`을 하기 전에 이 순서로 한다.

```bash
# 1) 해제
git -C "$대상" update-index --no-skip-worktree CLAUDE.md

# 2) 조각 구획을 떼어 따로 보관한다 (또는 git stash)
SNIP="$(mktemp)"   # 4) 단계까지 같은 터미널에서 이어서 한다
sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$대상/CLAUDE.md" > "$SNIP"
TMP="$(mktemp)"
awk '
  /<!-- init-SDD:begin -->/ { inblk=1 }
  inblk==0 { buf[++n]=$0 }
  /<!-- init-SDD:end -->/   { inblk=0 }
  END { while (n>0 && buf[n]=="") n--; for (i=1;i<=n;i++) print buf[i] }
' "$대상/CLAUDE.md" > "$TMP" && mv "$TMP" "$대상/CLAUDE.md"

# 3) 받는다
git -C "$대상" pull

# 4) 조각을 다시 끝에 붙인다
TMP="$(mktemp)"
cat "$대상/CLAUDE.md" > "$TMP"
printf '\n\n%s\n' "$(cat "$SNIP")" >> "$TMP"
mv "$TMP" "$대상/CLAUDE.md"

# 5) 재적용
git -C "$대상" update-index --skip-worktree CLAUDE.md
```

이 함정을 없앨 방법은 없다. 추적되는 파일을 로컬에서만 다르게 두려면 이 수단밖에 없다.
할 수 있는 것은 **알려 주는 것**과 [상태 보기](#상태-보기)가 지금 걸려 있는지 보여주는
것이다.

---

## 풀기

걸었던 것을 전부 되돌린다. **네 가지를 다 해야** 공유 저장소가 절차 전과 같아진다.

### 1) 링크 다섯 개를 없앤다 — 링크만 없앤다

```bash
for p in .claude/agents .claude/skills/orchestra .claude/skills/sdd-rules .claude/skills/sdd-sync .claude/settings.json; do
  if [[ -L "$대상/$p" ]]; then rm "$대상/$p"; echo "링크 제거: $p"; fi
done
```

`[[ -L ]]`일 때만 지운다. 실제 파일·디렉터리면 그건 이 스킬이 만든 것이 아니니 손대지 않는다.
`rm -rf`를 쓰지 마라 — 디렉터리 링크에 `rm -rf`를 쓰면 링크가 아니라 **가리키던 개인 저장소
내용**이 날아갈 수 있다.

목록 밖 옛 링크도 푼다. 이전 판이 만든 링크가 `.claude/skills/` 아래에 남아 있을 수 있다 — 위 다섯 목록에 없고
개인 저장소를 가리키는 링크만 골라 알리고 지운다.

```bash
P="$개인/$프로젝트"
for f in "$대상"/.claude/skills/*; do
  n="$(basename "$f")"
  case "$n" in orchestra|sdd-rules|sdd-sync) continue ;; esac
  if [[ -L "$f" ]]; then
    case "$(readlink "$f")" in "$P"/*) rm "$f"; echo "목록 밖 옛 링크 제거: .claude/skills/$n" ;; esac
  fi
done
```

**개인 저장소는 지우지 않는다.** 다른 프로젝트도 그것을 쓴다. 프로젝트별 디렉터리와 git
이력을 그대로 남긴다.

### 2) `CLAUDE.md`의 마커 구획을 떼어 낸다

`sed -i` 없이 임시 파일로 한다. 구획을 지운 뒤 **끝의 빈 줄까지 정리해야** 원본과 글자
하나까지 같아진다 (덧붙일 때 앞에 빈 줄 두 개를 넣었기 때문이다).

```bash
TMP="$(mktemp)"
awk '
  /<!-- init-SDD:begin -->/ { inblk=1 }
  inblk==0 { buf[++n]=$0 }
  /<!-- init-SDD:end -->/   { inblk=0 }
  END { while (n>0 && buf[n]=="") n--; for (i=1;i<=n;i++) print buf[i] }
' "$대상/CLAUDE.md" > "$TMP" && mv "$TMP" "$대상/CLAUDE.md"
```

`CLAUDE.md`가 조각뿐이었다면(이 스킬이 새로 만든 경우) 빈 파일이 남는다. 그때는 사용자에게
알리고 지울지 물어라. 스스로 지우지 마라.

### 3) `skip-worktree` 표시를 해제한다

```bash
git -C "$대상" update-index --no-skip-worktree CLAUDE.md 2>/dev/null || true
```

### 4) `.git/info/exclude`에서 **스킬이 적은 줄만** 지운다

표시 사이만 지운다. 사용자가 원래 적어 둔 줄은 그대로 둔다.

```bash
TMP="$(mktemp)"
awk '
  /^# init-sdd:begin$/ { inblk=1; next }
  /^# init-sdd:end$/   { inblk=0; next }
  inblk==0 { print }
' "$대상/.git/info/exclude" > "$TMP" && mv "$TMP" "$대상/.git/info/exclude"
```

### 확인

```bash
git -C "$대상" status --porcelain     # 절차를 돌리기 전과 같아야 한다
git -C "$대상" diff --exit-code       # 추적 파일 내용이 원래와 같아야 한다 (종료코드 0)
```

둘 중 하나라도 다르면 **무엇이 남았는지 그대로 말한다.** "다 풀었다"고 말하지 마라.

---

## 상태 보기

지금 이 프로젝트가 링크 방식으로 걸려 있는지 보여준다. 네 가지를 다 본다.

### 1) 링크 자리 다섯 개 — 네 갈래로 구분한다

```bash
for p in .claude/agents .claude/skills/orchestra .claude/skills/sdd-rules .claude/skills/sdd-sync .claude/settings.json; do
  f="$대상/$p"
  if   [[ -L "$f" && -e "$f" ]]; then echo "$p : 링크됨 -> $(readlink "$f")"
  elif [[ -L "$f" ]];            then echo "$p : ★ 끊긴 링크 -> $(readlink "$f") (가리키는 곳이 없다)"
  elif [[ -e "$f" ]];            then echo "$p : 실제 파일·디렉터리 (링크 아님)"
  else                                echo "$p : 없음"
  fi
done
```

`-L`을 먼저 보고 `-e`를 나중에 보는 순서가 중요하다. **끊긴 링크는 `-e`가 거짓**이라
`-e`만 보면 "없음"으로 잘못 나온다.

목록 밖 옛 링크도 찾는다. 위 다섯 목록에 없는데 개인 저장소를 가리키는 링크가 `.claude/skills/` 아래에 있으면
이전 판이 만든 것이다. 알리기만 하고, 걷어 내는 것은 [풀기](#풀기)가 한다.

```bash
P="$개인/$프로젝트"
for f in "$대상"/.claude/skills/*; do
  n="$(basename "$f")"
  case "$n" in orchestra|sdd-rules|sdd-sync) continue ;; esac
  if [[ -L "$f" ]]; then
    case "$(readlink "$f")" in "$P"/*) echo ".claude/skills/$n : 목록 밖 옛 링크 -> $(readlink "$f") (풀기로 걷어 낸다)" ;; esac
  fi
done
```

**끊긴 링크는 따로, 눈에 띄게 알린다.** 개인 저장소를 아직 복제하지 않은 새 컴퓨터, 개인
저장소를 옮기거나 이름을 바꾼 경우에 이 상태가 된다. 이때 **에이전트가 하나도 로드되지
않는데 링크는 걸려 있어서 겉으로는 정상처럼 보인다.** 이것이 이 절차에서 가장 알아채기
어려운 고장이고, [복사 방식과 섞였을 때](#복사-방식과-섞였을-때)의 위험도 여기서 온다.
끊긴 링크를 찾으면 이렇게 알려 준다: 개인 저장소를 복제·복구해서 제자리에 두거나,
아니면 [풀기](#풀기)로 링크를 걷어라.

### 2) `CLAUDE.md`의 마커와 추적 여부

```bash
grep -qF 'init-SDD:begin' "$대상/CLAUDE.md" 2>/dev/null && echo "CLAUDE.md : 조각 있음" || echo "CLAUDE.md : 조각 없음"
git -C "$대상" ls-files --error-unmatch CLAUDE.md >/dev/null 2>&1 && echo "  git 추적 중" || echo "  미추적"
```

### 3) `skip-worktree` 표시

`git ls-files -v`에서 **`S`로 시작하는 줄**이 `skip-worktree`가 걸린 파일이다.

```bash
git -C "$대상" ls-files -v CLAUDE.md | grep -q '^S' \
  && echo "skip-worktree : 걸려 있음 (팀의 CLAUDE.md 변경을 받지 못한다)" \
  || echo "skip-worktree : 걸려 있지 않음"
```

걸려 있으면 [함정](#skip-worktree의-함정--반드시-알려-줘라)도 함께 다시 알려 준다.

### 4) `.git/info/exclude`의 표시 구간

```bash
grep -q '^# init-sdd:begin$' "$대상/.git/info/exclude" 2>/dev/null \
  && sed -n '/^# init-sdd:begin$/,/^# init-sdd:end$/p' "$대상/.git/info/exclude" \
  || echo "exclude : init-sdd 구간 없음"
```

### 5) 공유 저장소가 조용한지

```bash
git -C "$대상" status --porcelain
```

링크가 exclude로 잘 막혀 있으면 링크에 대한 줄이 하나도 없다. **막히지 않았을 때 출력 모양은
프로젝트 상태에 따라 다르다** (실측으로 확인한 것이다).

| `.claude/` 안에 추적되는 파일이 | `git status --porcelain`에 보이는 것 |
|---|---|
| **있다** (`openspec init`을 이미 돌린 프로젝트는 항상 이쪽) | 링크가 **항목별로 한 줄씩** 뜬다: `?? .claude/agents`, `?? .claude/settings.json` 등 다섯 줄 |
| **없다** (`.claude/` 전체가 미추적) | `?? .claude/` **한 줄로 접힌다** |

`?? .claude/` 한 줄만 찾으면 실제 프로젝트에서는 놓친다. **`.claude/`로 시작하는 줄이
하나라도 있는지**를 보고, 있으면 5단계의 exclude가 빠졌거나 경로가 어긋난 것이다.

---

## 새 세션에서 확인하기

**심볼릭 링크로 놓인 `.claude/agents/`가 Claude Code에서 실제로 에이전트로 로드되는지는
아직 확인되지 않았다.** 확인된 것과 확인되지 않은 것을 갈라 놓는다. 확인되지 않은 것을
확인된 것처럼 말하지 마라.

| 실측으로 확인된 것 (파일시스템·git 수준) | 확인되지 **않은** 것 |
|---|---|
| 링크가 만들어지고 절대 경로로 걸린다 | Claude Code가 링크된 `.claude/agents/`를 **에이전트로 로드하는지** |
| 셸 글롭(`.claude/agents/*.md`)이 링크를 통과하고 `cat`으로 내용이 읽힌다 | 링크된 `.claude/skills/orchestra/`가 **스킬 목록에 뜨는지** |
| `.claude/skills/`가 실제 디렉터리로 남는다 | |
| `.git/info/exclude`로 링크가 `git status`에서 사라진다 | |
| `skip-worktree`를 건 동안 `CLAUDE.md` 변경이 `git status`에 안 나타난다 | |
| 풀면 `git status`와 파일 내용이 절차 전과 같아진다 | |

서브에이전트는 새 Claude Code 세션을 띄울 수 없다. 그래서 **마지막 확인은 사용자가 한다.**

1. 대상 프로젝트에서 Claude Code를 **새 세션으로** 다시 연다 (설정을 읽는 시점이 세션 시작이다).
2. 서브에이전트가 잡히는지 본다: 에이전트 목록에 8개(`preparer`, `analyzer`, `designer`,
   `worker`, `reviewer`, `regression-verifier`, `finalizer`, `code-explorer`)가 보이는지.
3. 스킬이 잡히는지 본다: 스킬 목록에 `orchestra`, `sdd-rules`, `sdd-sync`가 보이는지.
4. 실제로 한 번 불러 본다: `/orchestra` 를 쳐 보고 응답이 오는지.

### 안 잡혔을 때 — 복사로 떨어진다

링크로 인식되지 않으면 링크 방식의 이점 중 "한 곳만 고치면 모든 프로젝트에 반영된다"는
잃는다. 그래도 **개인 파일이 공유 저장소에 새지 않는 것은 지켜진다** — exclude는 미추적
복사물에도 통한다.

```bash
# 1) 링크를 푼다 (위 "풀기"의 1)번만)
for p in .claude/agents .claude/skills/orchestra .claude/skills/sdd-rules .claude/skills/sdd-sync .claude/settings.json; do
  [[ -L "$대상/$p" ]] && rm "$대상/$p"
done

# 2) 개인 저장소에서 복사한다
P="$개인/$프로젝트"
mkdir -p "$대상/.claude/skills"
cp -R "$P/agents"                  "$대상/.claude/agents"
cp -R "$P/skills/orchestra"        "$대상/.claude/skills/orchestra"
cp -R "$P/skills/sdd-rules"        "$대상/.claude/skills/sdd-rules"
cp -R "$P/skills/sdd-sync"         "$대상/.claude/skills/sdd-sync"
cp    "$P/settings.json"           "$대상/.claude/settings.json"

# 3) 복사된 경로도 .git/info/exclude 에 적는다 (경로가 같으므로 "걸기" 5단계와 같은 줄이다)
```

복사된 뒤에는 **개인 저장소와 대상 프로젝트에 사본이 두 벌 생긴다.** 개인 저장소 쪽을
고쳤으면 다시 복사해야 반영된다는 것을 사용자에게 알려 줘라.

---

## 복사 방식과 섞였을 때

한 프로젝트에서 링크를 걸어 둔 뒤 `install.sh`(복사 방식)를 돌리는 경우다.
`install.sh`의 `copy_if_absent`는 `[[ -e "$d" ]]`로만 판단한다. `-L`을 보지 않는다.
그래서 결과가 링크의 상태에 따라 갈린다 (실측으로 확인한 것이다).

| 링크의 상태 | `[[ -e ]]` | `install.sh`에서 일어나는 일 |
|---|---|---|
| **살아 있는 링크** | 참 | 복사하지 않고 `[있음, 건너뜀]`으로 넘어간다. **안전하다.** 링크를 덮어쓰지 않는다 |
| **끊긴 디렉터리 링크** | 거짓 | 복사 3단계의 `mkdir -p "$(dirname "$d")"`가 `File exists`로 **실패한다.** 링크는 있는데 가리키는 곳이 없어서 `mkdir -p`가 만들 수도, 있다고 넘어갈 수도 없다 |
| **끊긴 파일 링크**, 가리키는 곳의 부모 디렉터리가 없다 | 거짓 | `cp`가 `No such file or directory`로 실패한다 |
| **끊긴 파일 링크**, 부모 디렉터리는 있다 | 거짓 | **조용히 성공한다.** `cp`가 링크를 따라가 **개인 저장소 자리에 파일을 만든다** |

`install.sh`는 `set -euo pipefail`이라 실패하면 **거기서 죽는다.** 끊긴 디렉터리 링크가
있으면 **install이 3단계(에이전트와 스킬 복사)에서 죽어** 절반만 깔린 채 끝난다.

마지막 줄이 더 나쁘다. 공유 프로젝트에 들어가야 할 `settings.json`이 조용히 개인 저장소
자리에 가서 앉는다. 실패도 경고도 없다.

### 그래서 무엇을 하는가

**핵심 방어는 [상태 보기](#상태-보기)가 끊긴 링크를 직접 찾아 알려 주는 것이다.**
"개인 저장소가 제자리에 있는지 확인해라"는 안내만으로는 부족하다 — 끊긴 파일 링크는
부모 디렉터리는 있고 **파일만 없는** 경우(개인 저장소를 복제했지만 그 프로젝트별 디렉터리를
아직 안 만든 경우 등)에도 생기는데, 사용자 눈에는 저장소가 "제자리에 있는" 것처럼 보인다.
사람의 눈으로는 구별이 안 된다. 상태 보기가 `-L`과 `-e`를 함께 봐서 잡아 줘야 한다.

- 링크가 걸린 프로젝트에서 `install.sh`를 돌리기 전에 **[상태 보기](#상태-보기)를 먼저
  돌려라.** 끊긴 링크가 하나라도 있으면 install을 돌리지 마라.
- 끊긴 링크를 찾았으면 먼저 고친다: 개인 저장소를 제자리에 복제·복구하거나,
  [풀기](#풀기)로 링크를 걷은 뒤에 `install.sh`를 돌린다.
- `install.sh` 자체가 `-L`을 함께 보게 고치는 것은 복사 동작 변경이라 이 스킬의 일이 아니다.
