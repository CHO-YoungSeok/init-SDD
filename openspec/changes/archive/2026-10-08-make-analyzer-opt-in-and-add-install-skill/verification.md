# 임시 프로젝트 실측 검증 (묶음 10)

`switch_skill/SKILL.md` 와 `.claude/skills/agent-model-tier/SKILL.md` 는 프로그램이 아니라
**절차 문서**다. 이 저장소 안에서는 문법 검사조차 걸리지 않는다. 그래서 문서를 읽고
**임시 프로젝트에서 손으로 실행해** 문서에 빠진 단계와 안 맞는 명령을 찾았다.

**결함을 찾는 것이 목적이었고, 네 개를 찾아 `switch_skill/SKILL.md` 를 고쳤다.**

> ## ★ 먼저 읽어라 — 이 문서의 대부분은 **제거된 기능**의 실측이다 (2026-09-11 덧붙임)
>
> 아래 **갈래 ①~⑥·⑧ 과 "묶음 11 교착 수정과 재검증"** 은 모두 `switch_skill`
> (SDD 를 켜고 끄는 전환 스킬)을 실제로 돌려 본 기록이다.
> **그 기능은 2026-09-11 사용자 결정으로 제품에서 빠졌다.** `switch_skill/SKILL.md` 는
> 지워졌고, 설치는 `install.sh` 하나로 돌아갔다. 보관·맞바꾸기·상태 기록
> (`.claude/sdd-switch/`, `saved/original/`, `state.json`)도 함께 없어졌다.
> **그래서 아래 갈래 ①~⑥·⑧ 의 내용은 지금 제품과 맞지 않는다.** 지금 어떻게 설치하는지
> 알고 싶으면 `README.md` 의 "방법 1 — install.sh" 를 봐라.
>
> **그런데도 한 줄도 지우지 않고 남겨 두는 이유가 있다:**
> 이 실측이 그 스킬의 **결함 4개를 찾아낸 과정**이고, 왜 지금의 설계
> (보관하지 않고 "이미 있으면 건너뛴다", 어긋남을 자동으로 고치지 않고 알리기)를
> 골랐는지에 대한 **근거**다. 특히 묶음 11 의 교착 기록은 "깨끗한 작업 트리" 관문이
> 왜 위험했는지를 보여 준다. 기록을 지우면 그 판단의 근거가 사라진다.
>
> **갈래 ⑦(등급 한 바퀴)은 지금도 유효하다.** 그것은 `switch_skill` 이 아니라
> `.claude/skills/agent-model-tier/SKILL.md` 자체의 검증이고, 그 스킬은 제품에 남아 있다.
>
> `install.sh` 의 재검증은 이 문서 **맨 끝** 절에 따로 있다 (2026-09-11 실측).

## 머리말

| 항목 | 값 |
|---|---|
| 시험 날짜 | 2026-09-10 |
| 임시 디렉터리 A (빈 프로젝트) | `/tmp/sddtest-A-tu5GIo` |
| 임시 디렉터리 B (겹치는 설정) | `/tmp/sddtest-B-OrqXED` |
| 임시 디렉터리 C (강제 실패) | `/tmp/sddtest-C-yDFsGt` |
| 임시 디렉터리 REF (대조용 사본 보관) | `/tmp/sddtest-REF-dVgJuA` |
| `openspec --version` | `1.12.0` |
| `git --version` | `git version 2.55.0` |
| 원본 트리(`$SRC`) | `/Users/0stone_1004/orca/projects/init-SDD` |

**이 저장소는 시험 대상이 아니었다.** 모든 조작은 위 네 임시 경로 안에서만 했다.
등급 시험도 임시 프로젝트에 복사된 사본에서만 했다(작업 9.4 보존).

시작 전 원본 트리 검사(스킬 `## 찾은 트리를 쓰기 전에 검사한다`):

```
ls "$SRC"/.claude/agents/*.md | wc -l            → 7
ls "$SRC"/.claude/skills/orchestra/SKILL.md      → 있음
ls "$SRC"/.claude/skills/agent-model-tier/SKILL.md → 있음
ls "$SRC"/.claude/settings.json                  → 있음
grep -c '<!-- init-SDD:begin -->' "$SRC"/CLAUDE.md → 1
```

제품 5종 전부 통과.

---

## 요약 표 (갈래 8줄)

| 갈래 | 무엇을 봤나 | 판정 | 근거 |
|---|---|---|---|
| ① 첫 적용 (10.2) | 제품 5종 놓임, `openspec list` exit=0, 마커 구획 하나 | **합격** | 아래 갈래 ① **(제거된 기능)** |
| ② 겹치는 설정 (10.3) | 원래 파일이 `saved/original/` 에, 미리 뜬 사본과 `diff` 차이 0 | **합격** | 아래 갈래 ② **(제거된 기능)** |
| ③ 끄기 (10.4) | 원래 설정이 바이트 그대로 복귀, 마커 구획 사라짐, `openspec-*` 남음 | **합격** (스킬 수정 뒤) | 아래 갈래 ③ **(제거된 기능)** |
| ④ 반복 (10.5) | 켜기·끄기 두 번 더, `diff -r` 로 매 회차 차이 0 | **합격** | 아래 갈래 ④ **(제거된 기능)** |
| ⑤ `hadOriginal` 두 갈래 (10.6) | `false` → 지워짐 / `true` → 바이트 복귀 | **합격** | 아래 갈래 ⑤ **(제거된 기능)** |
| ⑥ 중간 실패 (10.7) | 교체로 안 넘어가고 멈춤, 원래 파일 차이 0, `state.json` 없음 | **합격** (강제 실패 성공, 스킬 보완 뒤) | 아래 갈래 ⑥ **(제거된 기능)** |
| ⑦ 등급 한 바퀴 (10.8) | `normal→semi-lower→lower→normal`, 마지막이 처음과 동일, `git diff` 가 `model:` 뿐 | **합격** | 아래 갈래 ⑦ **(유효 — agent-model-tier 는 제품에 남아 있다)** |
| ⑧ 두 스킬 겹침 (10.9) | 내려 둔 등급이 껐다 켜도 `normal` 로 안 돌아감 | **합격** | 아래 갈래 ⑧ **(제거된 기능)** |

**불합격은 없다.** 단 ③과 ⑥은 **스킬 문서를 고친 뒤에야** 합격했다. 고치기 전에는 ③이
바이트 비교에서 깨졌고 ⑥은 어느 파일 때문에 실패했는지 알 수 없었다. 아래 "찾은 결함"을 봐라.

---

## 찾은 결함 네 개와 고친 내용

### 결함 1 — 커밋 확인 명령이 만질 경로 밖까지 잡아 **첫 적용이 언제나 멈춘다**

`## 켜기` 1단계 4번의 명령이 이랬다.

```bash
git status --porcelain -- .claude CLAUDE.md
```

실측(프로젝트 A):

```
?? .claude/
```

`.claude/` 안에 걸린 것은 `openspec init` 이 깐 `openspec-*` 스킬 6개와 `/opsx` 명령 6개,
그리고 **방금 복사해 넣은 `switch_skill` 자신**이다. 셋 다 **만질 경로가 아니다.**
그런데 문서는 "출력이 있으면 멈춘다"고 하므로, 스킬을 글자 그대로 따르면 **정상적인 첫
적용이 100% 여기서 죽는다.** 사용자가 시키는 대로 커밋하면 자기 저장소에 openspec 스냅샷과
`switch_skill` 을 커밋하게 되는데, 문서가 원한 것도 그게 아니다.

`design.md` 267줄은 "**만질 경로들이** 커밋되지 않은 변경을 갖고 있는지 확인"이라고 적고
있으므로, 이건 설계와 문서가 어긋난 것이다. 명령을 설계 문장에 맞게 좁혔다.

```bash
git status --porcelain -- \
  .claude/agents .claude/skills/orchestra .claude/skills/agent-model-tier \
  .claude/settings.json CLAUDE.md
```

경로가 아직 없어도 이 명령은 **빈 출력에 종료코드 0** 이다(실측 확인). 프로젝트 B에서
대조:

```
좁힌 명령  → (빈 출력) exit=0        ← 진행 가능
넓은 명령  → ?? .claude/commands/
              ?? .claude/skills/      ← 멈춤
```

### 결함 2 — 마커 구획을 **빈 줄과 함께** 붙이면 끄기가 원래 파일로 못 돌아간다

`## 켜기` 4단계는 "파일 끝에 구획을 붙인다"까지만 적고 **이음새를 정하지 않았다.**
보기 좋으라고 구획 앞에 빈 줄 하나를 두는 것이 자연스러운 선택인데, `## 끄기` 4단계는
`begin` 부터 `end` **줄만** 뺀다. 그러면 그 빈 줄이 남아 **원래 파일과 바이트가 달라진다.**
작업 10.4 의 합격 기준이 정확히 "바이트 단위 복귀"이므로 이 상태로는 갈래 ③이 불합격이다.

고친 내용: 4단계에 "**붙일 때 빈 줄을 새로 넣지 마라**"와 그 이유를 못박고, 파일이 개행으로
끝나지 않을 때 더하는 개행 한 바이트는 **끄기 보고에 적으라**고 했다. 그리고 `## 끄기`
4단계에 **구획을 뺀 뒤 `saved/original/CLAUDE.md` 와 바이트 비교하고, 다르면 덮어쓰지 말고
차이를 보고하라**는 검증을 더했다(스킬의 "어긋남을 자동으로 고치지 않는다"와 같은 태도).

고친 규칙대로 다시 붙인 뒤 실측(프로젝트 B):

```
구획을 빼면 원래 파일과 바이트 동일 → 되돌리기 가능
CLAUDE.md 구획 뺀 뒤 saved/original 과 바이트 동일
```

### 결함 3 — `CLAUDE.md` 를 `saved/sdd/` 에 어떻게 담고 되돌리는지가 **정해져 있지 않았다**

`## 끄기` 3단계는 "SDD 파일을 `saved/sdd/` 에 복사한다. **켜기의 3단계와 같은 방식이다**"라고
했다. 켜기 3단계는 `CLAUDE.md` 를 **파일 전체**로 떠 두라고 한다. 그 말을 그대로 따르면
`saved/sdd/CLAUDE.md` 에 **사용자가 쓴 문장까지 섞여 들어간다.** 그런데 결정 14는 "켤 때
`saved/sdd/` 에 보관물이 있으면 그것을 되돌린다"고 한다 — 파일 전체를 되돌리면
**SDD가 꺼져 있던 동안 사용자가 고친 자기 문장이 사라진다.**

최소 재현(스크래치패드):

```
[켜진 상태]   # 우리 팀 규칙 / 사람 문장 A / <구획>
[끈 뒤]       # 우리 팀 규칙 / 사람 문장 A
[사용자가 고침] # 우리 팀 규칙 / 사람 문장 A 를 B 로 고쳤다
[다시 켠 뒤]  # 우리 팀 규칙 / 사람 문장 A / <구획>
→ 사용자가 꺼진 동안 고친 문장('B 로 고쳤다')이 사라졌다.
```

이건 이 스킬의 안전 성질("원래 설정을 절대 잃지 않는다")이 깨지는 지점이다.

고친 내용:
- `## 끄기` 3단계에 **`kind: marker-block` 만 예외 — 파일 전체가 아니라 구획만 담는다**를
  넣고 명령(`sed -n ... > saved/sdd/CLAUDE.md.block`)을 적었다. `.block` 확장자를 붙인
  이유도 적었다 — 이름이 같으면 나중에 "파일 전체 사본"으로 다시 오해한다.
- `## 켜기` 4단계에 **`CLAUDE.md` 는 파일을 통째로 되돌리지 않는다**를 넣고, 되돌리기가
  "그 구획을 지금 파일에 넣는 것"임을 못박았다.

### 결함 4 — 보관이 `mkdir` 에서 깨지면 **어느 원본 파일 때문인지 보고에 안 나온다**

`## 켜기` 3단계는 "어떤 파일에서 실패했는지 경로로 보고한다"고 하지만, 적힌 명령 순서는
`mkdir -p` → `cp` → `cmp` 이고 **`mkdir` 이 먼저 실패할 수 있다는 말이 없다.** 프로젝트 C
에서 보관 칸을 `chmod 500` 으로 막고 켜기를 시도했더니 셸이 낸 말은 이것뿐이었다.

```
mkdir: .claude/sdd-switch/saved/original/.claude: Permission denied
```

**만들려던 보관 칸 경로만 있고, 지키려던 원본 파일이 없다.** 작업 10.7 합격 기준 (b)가
"어느 파일에서 실패했는지 보고한다"이므로 이대로는 불합격이다.

고친 내용: 3단계에 "실패는 `cmp`·`diff` 뿐 아니라 `mkdir` 과 `cp` 에서도 난다"를 넣고,
보고에 **① 지키려던 원본 경로 ② 실패한 명령 ③ 셸이 낸 말** 세 가지를 함께 적으라고 했다.
그대로 고쳐 다시 돌린 결과:

```
보관 실패 — 지키려던 원본: .claude/agents/preparer.md /
  실패한 명령: mkdir -p .claude/sdd-switch/saved/original/.claude/agents /
  셸: mkdir: .claude/sdd-switch/saved/original/.claude: Permission denied
```

---

## 갈래별 실행 기록

### 갈래 ① 첫 적용 (작업 10.2) — 합격

대상: `/tmp/sddtest-A-tu5GIo`. `git init` + `git commit --allow-empty -m init` +
`openspec init --tools claude --no-animation` (exit=0, 스킬 6개 + `/opsx` 명령 6개 생성)
후 `switch_skill/` 을 `.claude/skills/` 로 복사하고 켜기 절차를 실행했다.

**실측 사실 하나:** `openspec init --tools claude` 는 `CLAUDE.md` 도 `.claude/settings.json`
도 만들지 않는다. 그래서 켜기 1단계 안에서 `openspec init` 이 3단계 뒤에 도는 순서 때문에
`hadOriginal` 값이 낡아지는 문제는 **일어나지 않는다.** (미리 의심했던 지점이라 적어 둔다)

| 합격 기준 | 실측 |
|---|---|
| (a) `.claude/agents/*.md` 7개 | `7` |
| (b) `orchestra/SKILL.md` | 있음 |
| (c) `agent-model-tier/SKILL.md` | 있음 |
| (d) `.claude/settings.json` | 있음 (326 바이트) |
| (e) `CLAUDE.md` 마커 구획 정확히 하나 | `begin`=1, `end`=1 |
| (f) `openspec list` 종료코드 | `openspec exit=0` |
| (g) `state.json` 의 `active` | `sdd` |
| (h) `.gitignore` 에 `.claude/sdd-switch/` | `1:.claude/sdd-switch/` |

`openspec-*` 6개도 전부 제자리에 있었다. 원래 아무것도 없었으므로 `managed[]` 11개 전부
`hadOriginal: false`.

### 갈래 ② 겹치는 설정 (작업 10.3) — 합격

대상: `/tmp/sddtest-B-OrqXED`. 켜기 전에 세 파일을 심어 커밋했다.
사람이 쓴 문장이 든 `CLAUDE.md`, 우리와 다른 `.claude/settings.json`(`pytest`/`ruff` 권한 +
`env.MY_TEAM`), 우리와 이름은 같고 내용은 다른 `.claude/agents/preparer.md`.
**켜기 전에 세 파일을 `/tmp/sddtest-REF-dVgJuA/B-before/` 에 사본으로 떠 뒀다.**

상태 판별 실측: 지문 1 = 0, 지문 2 = 0, 지문 3 = `preparer.md` 하나(우리 이름 중 1개, 3 미만)
→ **"처음 적용"**. 단 겹치는 세 파일은 파일 단위로 `hadOriginal: true` 로 잡혔다
(`cmp` 로 원본 트리와 다름을 확인). 스킬 169-172줄의 "이어받기와 보관은 같은 프로젝트 안에서
파일마다 갈릴 수 있다"가 실제로 그렇게 굴러갔다.

| 합격 기준 | 실측 |
|---|---|
| (a) 세 파일이 `saved/original/` 아래 같은 상대 경로 | `saved/original/.claude/agents/preparer.md`, `saved/original/.claude/settings.json`, `saved/original/CLAUDE.md` |
| (b) 떠 둔 사본과 `diff` 차이 0 | `diff -r REF/B-before saved/original` → **차이 0** |
| (c) `managed` 에서 셋이 `hadOriginal: true` | `preparer.md True / settings.json True / CLAUDE.md True` |
| (d) 사람이 쓴 문장 그대로 | `4:줄바꿈은 LF 로 맞춘다. 사람이 손으로 쓴 이 문장은 절대 사라지면 안 된다.` |

보관은 `cp -p` 뒤 `cmp -s` 로 파일마다 바이트 비교했고 셋 다 통과했다.

### 갈래 ③ 끄기 (작업 10.4) — 합격 (결함 2 고친 뒤)

같은 프로젝트 B. **결함 2 때문에 처음에는 바이트 복귀가 깨졌다.** 스킬을 고친 규칙(빈 줄
넣지 않음)대로 구획을 다시 붙이고 끄기를 실행했다.

| 합격 기준 | 실측 |
|---|---|
| (a) 세 파일이 켜기 전 사본과 `diff` 차이 0 | `diff -r REF/B-before <지금>` → **차이 0** |
| (b) 마커 구획 없음 | `begin` 개수 = 0 |
| (c) `hadOriginal:false` 것들 지워짐 + 빈 디렉터리 없음 | `.claude/agents` 에 `preparer.md` 하나만, `orchestra`·`agent-model-tier` 둘 다 없음, `find -type d -empty` 빈 출력 |
| (d) `state.json` 의 `active` | `original` (`managed`는 `[]` 로 비움) |
| (e) `openspec/` 과 `openspec-*` 6개 남음 | `openspec` 있음, `openspec-*` = 6, `openspec list` exit=0 |

(e)의 "결과 보고에 그 문장이 있는가"는 스킬 `## 끄기` 6단계에 그대로 적혀 있다 —
"★ `openspec/`과 `.claude/skills/openspec-*` 6개는 그대로 남는다. 이것은 고장이 아니다."

되돌린 뒤 `saved/original/` 의 사본은 지워 `saved/original` 에 남은 파일이 0이 됐다
(스킬 445-446줄의 "낡은 사본을 남기지 않는다").

### 갈래 ④ 반복 (작업 10.5) — 합격

프로젝트 B에서 켜기 → 끄기를 **두 번 더** 반복했다. 회차마다 `.git` 과 `.claude/sdd-switch`
를 뺀 트리 전체를 `tar` 로 떠서 1회차와 `diff -r` 로 대조했다.

| 합격 기준 | 회차 2 | 회차 3 |
|---|---|---|
| (a) 켠 직후가 첫 켜기 직후와 차이 0 | **차이 0** | **차이 0** |
| (b) 끈 직후가 켜기 전 원본과 차이 0 | **차이 0** (첫 끄기 직후와도 차이 0) | **차이 0** |
| (c) 마커 구획이 언제나 정확히 하나 | `1` | `1` |
| (d) `saved/` 에 회차마다 쌓이는 쓰레기 없음 | `saved/sdd` 11개 고정, `saved/original` 0개 | 같음 |

회차 2·3의 켜기 로그가 11개 경로 전부 **`saved/sdd 에서`** 라고 찍혔다 — 결정 14대로
원본 트리에서 새로 복사하지 않았다는 증거다.

### 갈래 ⑤ `hadOriginal` 두 갈래 (작업 10.6) — 합격

**`false` 갈래** — 프로젝트 A(원래 아무것도 없던 쪽)에서 끄기를 실행했다.
`managed` 11개의 `hadOriginal` 집합이 `{False}` 임을 먼저 확인했다.

```
되돌림: 0 지움: 11
빈 디렉터리 지움: .claude/agents
→ .claude/agents 디렉터리 자체가 없음
→ CLAUDE.md 지워짐
→ settings.json 지워짐
orchestra / agent-model-tier: No such file or directory
```

남아야 할 것은 남았다: `openspec/`, `openspec-*` 6개, `switch_skill`, `/opsx` 명령 6개.
`openspec list` exit=0.

**`true` 갈래** — 갈래 ③(프로젝트 B)에서 이미 밟았다. `preparer.md`·`settings.json`·
`CLAUDE.md` 셋이 켜기 전 사본과 `diff` 차이 0으로 **바이트 그대로** 돌아왔다.

| 합격 기준 | 실측 |
|---|---|
| (a) `false` 갈래에서 지워짐 | 위 로그 (`지움: 11`, 빈 디렉터리까지 정리) |
| (b) `true` 갈래에서 바이트 그대로 복귀 | 갈래 ③ (a) — `diff` 차이 0 |
| (c) 두 갈래가 따로 기록됨 | 이 절이 그 기록이다 |

### 갈래 ⑥ 중간 실패 (작업 10.7) — 합격 (강제 실패 **성공**, 결함 4 고친 뒤)

대상: `/tmp/sddtest-C-yDFsGt` (B와 같은 방식으로 겹치는 세 파일을 심고 커밋).
`.claude/sdd-switch/saved/original` 을 미리 만들고 `chmod 500` 으로 쓰기를 막았다.

**강제로 깨는 데 성공했다.** 막힌 것을 먼저 확인했다.

```
dr-x------  .claude/sdd-switch/saved/original
touch: .claude/sdd-switch/saved/original/probe: Permission denied
mkdir: .claude/sdd-switch/saved/original/.claude: Permission denied
```

| 합격 기준 | 실측 |
|---|---|
| (a) 교체 단계로 안 넘어가고 멈춤 | 종료코드 1. `.claude/agents` 에 `preparer.md` 하나뿐, `orchestra`·`agent-model-tier` 없음, `CLAUDE.md` 마커 = 0, `.gitignore` 없음 |
| (b) 어느 파일에서 실패했는지 보고 | 처음에는 **못 했다(결함 4)**. 스킬을 고친 뒤 → `보관 실패 — 지키려던 원본: .claude/agents/preparer.md / 실패한 명령: mkdir -p ... / 셸: Permission denied` |
| (c) 원래 자리 파일이 하나도 안 바뀜 | `diff -r REF/C-before <지금>` → **차이 0** (두 번의 시도 모두) |
| (d) `state.json` 안 만들어짐 | `ls: .claude/sdd-switch/state.json: No such file or directory` |

끝으로 `chmod 700` 으로 권한을 되돌리고 같은 켜기를 다시 돌려 성공했다
(`agents=7`, 마커 1, `active=sdd`) — 실패 원인이 권한이었고 절차 자체는 온전함을 확인한
것이다. **`chmod` 로 바꿔 둔 권한은 남기지 않았다.**

### 갈래 ⑦ 등급 한 바퀴 (작업 10.8) — 합격

프로젝트 A를 다시 켜고, 7개 파일의 `model:` 값과 파일 사본을
`/tmp/sddtest-REF-dVgJuA/A-tier-start/` 에 떠 둔 뒤 `normal → semi-lower → lower → normal`
을 차례로 적용했다. 값 변경은 스킬이 요구하는 대로 **`model:` 한 줄만 부분 수정(Edit)** 으로
했다 — 파일 전체 재작성과 `sed -i` 는 쓰지 않았다.

시작 값(= `normal` 열):
`preparer sonnet / analyzer opus / designer opus / worker sonnet / reviewer opus /
regression-verifier sonnet / finalizer sonnet` — 4.2 표와 일치.

| 합격 기준 | 실측 |
|---|---|
| (a) 각 단계 7개 값이 표와 한 칸도 안 다름 | `semi-lower` ✅ / `lower` ✅ / `normal` ✅ (세 단계 모두 프로그램으로 표와 대조) |
| (b) 마지막 `normal` 이 시작 값과 같음 | `diff -r REF/A-tier-start .claude/agents` → **차이 0**. 원본 트리와도 차이 0 |
| (c) frontmatter `---` 두 줄 + 네 키 유지 | 7개 파일 모두 `name:`·`description:`·`model:`·`tools:` 4/4 |
| (d) `^model:` 줄이 파일마다 정확히 하나 | 7개 모두 `1` |
| (e) 코드펜스 짝수, `ORCA_RICH_MD` 0 | 7개 모두 짝수(4/10/10/16/6/8/6), `ORCA_RICH_MD` 전부 0 |
| (f) `git diff` 에서 바뀐 줄이 `model:` 뿐 | 단계마다 확인. `semi-lower`: 7파일 `7 insertions(+), 7 deletions(-)`, 전부 `±model:` / `lower`: `±model:` 3쌍 / `normal`: `±model:` 7쌍 |
| (g) 같은 등급 두 번이면 아무것도 안 바뀜 | "지금 등급 확인" 절차가 `semi-lower` 로 판정 → 무동작. `shasum` 7개 재대조 → **해시 그대로** |

`semi-lower → lower` 에서는 이미 `haiku` 인 4개 파일을 건드리지 않았고, `git diff` 에도
바뀐 파일이 `analyzer`·`designer`·`reviewer` 셋만 나왔다 — 스킬의 "이미 값이 같은 파일은
건드리지 않는다"가 지켜졌다.

### 갈래 ⑧ 두 스킬 겹침 / 결정 14 (작업 10.9) — 합격

등급을 `lower` 로 내려 둔 채(7개 전부 `haiku`) 프로젝트 A에서 SDD를 끄고 다시 켰다.
대조 기준: **원본 트리는 언제나 `normal`** 이다(`analyzer opus`, `preparer sonnet` …).

```
[끈 뒤 saved/sdd 에 보관된 값]  7개 전부 model: haiku
[다시 켜기 로그]                11개 경로 전부 "saved/sdd 에서"
[다시 켠 뒤 값]                 7개 전부 model: haiku
```

| 합격 기준 | 실측 |
|---|---|
| (a) 다시 켠 뒤 7개가 `lower` 표와 같음 | 전부 `haiku` ✅ |
| (b) 원본 트리의 `normal` 로 말없이 안 돌아감 | 원본은 `opus`/`sonnet` 인데 결과는 `haiku` → 돌아가지 않았다 |
| (c) `saved/sdd/` 보관물을 되돌린 것임을 확인 | 켜기 로그가 경로마다 `saved/sdd 에서` 로 찍힘 |

결정 14가 문서에 제대로 반영되어 있다. `normal` 로 돌아가지 않았으므로 스킬을 고칠 일이
없었다.

---

## 고치지 않고 남긴 것 — designer 가 판단할 지점 하나

**끄기의 "깨끗한 작업 트리" 요구가 켜기가 만든 변경에 걸린다.**

`design.md` 267줄은 켜기·끄기 **둘 다** 진행 전에 만질 경로의 커밋되지 않은 변경을 확인하고
있으면 멈추라고 한다. 그런데 켜기가 끝난 직후 만질 경로는 **반드시** 더러운 상태다 —
켜기가 방금 바꿔 놓았기 때문이다. 프로젝트 B 실측:

```
 M .claude/agents/preparer.md
 M .claude/settings.json
 M CLAUDE.md
?? .claude/agents/analyzer.md   (…나머지 5개…)
?? .claude/skills/agent-model-tier/
?? .claude/skills/orchestra/
```

그래서 켠 다음 곧바로 끄려고 하면 **끄기는 언제나 멈춘다.** 설계가 든 이유("사용자가 자기
변경과 전환 변경을 구분할 수 없게 된다")는 이 경우에 해당하지 않는다 — 걸린 변경이 전부
전환이 만든 것이다. 게다가 켜기 6단계 보고에는 "이 변경을 커밋해 두라"는 안내가 없어서,
사용자는 막힌 채로 다음에 무엇을 할지 알 수 없다.

**이 시험에서는 설계를 따랐다** — 회차마다 전환 변경을 커밋하고 나서 끄기를 돌렸고, 그렇게
하면 절차는 온전히 굴러간다(갈래 ③④⑤⑧이 그 증거다). 고치는 방향은 둘 중 하나로 보이는데,
어느 쪽인지는 설계 결정이라 손대지 않았다.

1. 켜기 6단계 보고에 "**전환으로 생긴 변경을 커밋해 두라**"는 안내를 더한다 (설계 유지).
2. 끄기에서는 이 확인을 **멈춤이 아니라 알림**으로 내린다 — 물러나는 SDD 파일은 어차피
   3단계에서 `saved/sdd/` 로 보관되고 바이트 비교까지 하므로, git이 지켜 줄 것이 따로 없다.

## 치운 것 (작업 10.10)

아래 네 경로를 `rm -rf` 로 지웠다. 지운 결과는 이 문서 아래 "지운 뒤 확인"에 있다.

- `/tmp/sddtest-A-tu5GIo`
- `/tmp/sddtest-B-OrqXED`
- `/tmp/sddtest-C-yDFsGt`
- `/tmp/sddtest-REF-dVgJuA`

`chmod 500` 으로 막아 뒀던 `/tmp/sddtest-C-yDFsGt/.claude/sdd-switch/saved/original` 은
지우기 전에 `chmod 700` 으로 되돌려 놓았다.

### 지운 뒤 확인

```
ls -d /tmp/sddtest-A-tu5GIo   → No such file or directory
ls -d /tmp/sddtest-B-OrqXED   → No such file or directory
ls -d /tmp/sddtest-C-yDFsGt   → No such file or directory
ls -d /tmp/sddtest-REF-dVgJuA → No such file or directory
```

## 이 저장소에 시험 흔적이 없는지 (작업 10.12)

```
git status --short
 M .claude/skills/orchestra/SKILL.md
 M CLAUDE.md
 M README.md
D  install.sh
?? .claude/skills/agent-model-tier/
?? openspec/changes/make-analyzer-opt-in-and-add-install-skill/
?? switch_skill/

git diff --stat -- .claude/agents/
(빈 출력)
```

임시 파일은 하나도 없다. 위 목록은 전부 이번 change 의 산출물과 제품이다.
`.claude/agents/` 는 **한 줄도 바뀌지 않았다**(작업 9.4 와 같은 확인) — 등급 시험은
임시 프로젝트에 복사된 사본에서만 했다.

## 실측 뒤 고친 것 — 끄기 관문 교착과 재검증 (묶음 11)

시험 날짜: 2026-09-10 (묶음 10과 같은 날 이어서)
임시 디렉터리: `/tmp/sdd-reverify.db978F` (대조용 사본: `/tmp/sdd-reverify-snap.Rh0R97`) — 둘 다 작업 11.9에서 지웠다.
`openspec --version` = 1.12.0

### 무엇이 교착이었나

묶음 10에서 나온 결함이다. 원래 설계는 **켜기와 끄기 둘 다** 진행 전에 만질 경로 5개의
커밋되지 않은 변경을 확인하고 있으면 멈추게 했다. 그런데 **켜기 자신이 그 5개 경로를
더럽힌다.** 그래서 켠 직후에 끄면 끄기가 **언제나** 멈춘다.
"일단 켜 보고 아니면 되돌리자"는 가장 흔한 첫 사용 흐름이 막힌다.

이번 시험에서 켠 직후 상태를 그대로 찍은 것이 그 증거다.

```
git status --porcelain -- .claude/agents .claude/skills/orchestra \
  .claude/skills/agent-model-tier .claude/settings.json CLAUDE.md
 M .claude/agents/preparer.md
 M .claude/settings.json
 M CLAUDE.md
?? .claude/agents/analyzer.md
?? .claude/agents/designer.md
?? .claude/agents/finalizer.md
?? .claude/agents/regression-verifier.md
?? .claude/agents/reviewer.md
?? .claude/agents/worker.md
?? .claude/skills/agent-model-tier/
?? .claude/skills/orchestra/
```

### 어떻게 정했나 (`decision.md` 결정 5)

- **켜기: 관문을 유지한다.** 대상은 만질 경로 5개뿐이고, 6단계 보고에
  **"전환으로 생긴 변경을 커밋해 두라"** 안내를 더한다.
- **끄기: 같은 확인을 하되 멈추지 않고 알리기만 한다.**

**방향마다 다른 이유 — git 이 지켜 주는 것이 다르다.** 켜기는 사용자 작업 트리에만 있는
파일을 밀어내고, 그 원본이 가는 `saved/original/` 은 git 추적 제외라 **유일한 사본**이다.
켜기 전 커밋이 두 번째 사본을 만든다. 반면 끄기가 물러나게 하는 것은 전부 켜기가 놓은
파일이고 `saved/sdd/` 에 바이트 비교까지 거쳐 보관되므로 git 이 따로 지켜 줄 것이 없다.

스킬에 옮긴 자리는 네 곳이다 (작업 11.1~11.4, 모두 `switch_skill/SKILL.md`).

| 작업 | 고친 자리 | 무엇으로 |
|---|---|---|
| 11.1 | `## 끄기` 1단계 3번 | "있으면 멈춘다" → **알리고 진행한다** + 안 멈추는 이유 + 보는 경로 5개 명시 |
| 11.2 | `## 켜기` 6단계 보고 | **"전환으로 생긴 변경을 커밋해 두라"** 안내와 실제 명령 두 줄 |
| 11.3 | `## 켜기` 1단계 4번 | 관문은 그대로 두고, 근거를 낡은 것에서 **비대칭 근거**로 갈았다 |
| 11.4 | `## 끄기` 6단계 보고 | **"관리 목록에 없는 경로에 사용자가 만든 파일은 그대로 남는다"** |

### 재검증 3건 (작업 11.5~11.7)

두 스킬은 절차 문서라서 "돌려 본다"는 곧 **문서에 적힌 단계를 임시 프로젝트에서 손으로
실행해 본다**는 뜻이다. 묶음 10과 같은 방식으로 했다.

준비: `mktemp -d` → `git init` → `git commit --allow-empty -m init` →
`openspec init --tools claude --no-animation` → 겹치는 설정 세 개를 심고
(**사람이 쓴 문장이 든 `CLAUDE.md`**, 다른 `.claude/settings.json`,
내용이 다른 `.claude/agents/preparer.md`) 한 번 커밋 → `switch_skill/` 을
프로젝트 `.claude/skills/` 로 복사 → 켜기 전 사본을 대조용으로 떠 둠.

| 재검증 | 무엇을 봤나 | 판정 |
|---|---|---|
| 11.5 갈래 ③ 끄기 | 켠 뒤 **커밋하지 않고 곧바로** 끄기 | **합격** (a~d 모두) |
| 11.6 갈래 ④ 반복 | **한 번도 커밋하지 않고** 켜기·끄기 2회 더 | **합격** (a~e 모두) |
| 11.7 켜기 관문 | 사용자 변경을 커밋하지 않은 채 켜기 | **합격** (a~c 모두, 종료코드 2로 멈춤) |

#### 11.5 — 켠 직후 커밋 없이 끄기 (갈래 ③)

끄기 1단계가 **멈추지 않고** 이렇게 알리고 진행했다.

```
=== 끄기 1단계 검사 ===
보관물 확인 통과
알림: 만질 경로에 커밋되지 않은 변경이 있다 (멈추지 않고 진행한다)
 M .claude/agents/preparer.md
 M .claude/settings.json
 M CLAUDE.md
?? .claude/agents/analyzer.md   (…6개 더)
이유: 물러나는 것은 전부 켜기가 놓은 파일이고 saved/sdd/ 에 바이트 비교까지 거쳐 보관된다
...
OFF DONE
exit=0
```

합격 기준별 실측:

- **(a) 멈추지 않고 진행된다** — 합격. 종료코드 0, `OFF DONE` 까지 감. (교착 전에는 여기서 멈췄다)
- **(b) 알림이 전달된다** — 합격. 위 "알림:" 줄과 더러운 경로 목록, 그리고 안 멈추는 이유까지 나온다.
- **(c) 원래 설정 세 파일이 켜기 전 사본과 `diff` 차이 0** — 합격.
  ```
  diff <사본>/CLAUDE.md      CLAUDE.md                  → 차이 0
  diff <사본>/settings.json  .claude/settings.json      → 차이 0
  diff <사본>/preparer.md    .claude/agents/preparer.md → 차이 0
  ```
- **(d) 마커 구획이 없고 사용자 문장이 살아 있다** — 합격.
  `grep -c 'init-SDD:begin' CLAUDE.md` = **0**,
  `grep -c '이 문장은 사람이 쓴 것이다' CLAUDE.md` = **1**.
  끈 뒤 `CLAUDE.md` 는 심어 둔 4줄 그대로였다.

덧붙여, 끄기 보고에 11.4에서 더한 문장이 실제로 찍혔고 지운 것·되돌린 것이 따로 나왔다.
`hadOriginal: false` 인 8개(에이전트 6개 + 스킬 2개)는 지워지고 빈 디렉터리도 남지 않았으며
(`.claude/agents` 에는 되돌린 `preparer.md` 만 남음), `openspec/` 과
`.claude/skills/openspec-*` 6개는 그대로 남았다.

#### 11.6 — 한 번도 커밋하지 않고 켜기·끄기 2회 더 (갈래 ④)

**묶음 10의 갈래 ④는 회차마다 커밋하고 돌렸으므로 이 경로는 이번에 처음 밟았다.**
전체 시험 동안 커밋은 준비 단계의 두 개(`init`, `우리 원래 설정`)뿐이고
전환 뒤에는 한 번도 커밋하지 않았다(`git log --oneline` 2줄).

- **(a) 매 회차가 멈추지 않고 끝난다** — 합격. 켜기 3회·끄기 3회 모두 `ON DONE`/`OFF DONE`.
  2·3회차 켜기의 관문 판정은 `커밋되지 않은 변경 없음 (관문 통과)` 였다.
  **이것이 이 수정이 통하는 까닭이다:** 끄기가 5개 경로를 커밋된 원래 상태로 정확히
  돌려놓기 때문에, 커밋을 하지 않아도 다음 켜기의 관문이 저절로 깨끗해진다.
- **(b) 켠 직후 상태가 매번 첫 켜기 직후와 `diff -r` 차이 0** — 합격 (2회차·3회차 모두).
  ```
  diff -r <on1>/.claude/agents                     .claude/agents                     → 0
  diff -r <on1>/.claude/skills/orchestra           .claude/skills/orchestra           → 0
  diff -r <on1>/.claude/skills/agent-model-tier    .claude/skills/agent-model-tier    → 0
  cmp    <on1>/.claude/settings.json               .claude/settings.json              → 0
  cmp    <on1>/CLAUDE.md                           CLAUDE.md                          → 0
  ```
  2·3회차 켜기는 `교체(보관물 되돌림)` 으로 `saved/sdd/` 에서 되돌아왔고
  `CLAUDE.md` 조각의 출처도 `보관물` 이었다(결정 14 경로).
- **(c) 끈 직후 상태가 매번 켜기 전 원본과 차이 0** — 합격 (2회차·3회차 모두).
  `CLAUDE.md`·`settings.json`·`.claude/agents` 전부 차이 0.
- **(d) 마커 구획이 언제나 정확히 하나** — 합격. 켠 뒤 매번 `1`, 끈 뒤 매번 `0`.
  회차가 늘어도 두 번 들어가지 않았다.
- **(e) `saved/` 아래에 회차마다 쌓이는 쓰레기가 없다** — 합격.
  끈 직후 `saved/` 의 파일 개수가 2회차·3회차 모두 **11개로 같았다**
  (에이전트 7 + `settings.json` + 스킬 2 + `CLAUDE.md.block`).
  되돌린 보관물은 `saved/original/` 에서 지워져 켠 뒤에는 `saved/original` 자체가 사라졌다.

  **관찰 하나 (고장은 아니다):** 켜기 4단계가 `saved/sdd/` 의 보관물을 되돌린 뒤
  `saved/sdd/.claude/agents` 와 `saved/sdd/.claude/skills` 가 **빈 디렉터리로 남는다.**
  회차마다 늘지 않고(항상 그 둘) 다음 끄기가 같은 자리에 다시 채우므로 판정에는 영향이
  없다. 스킬 문서는 "되돌린 보관물은 `saved/sdd/` 에서 지운다"까지만 요구하고 빈 부모
  디렉터리 정리는 요구하지 않는다. 정리 문구를 더할지는 취향 문제로 남겨 둔다.

#### 11.7 — 켜기 관문은 여전히 걸리는지 (과잉 수정 안전장치)

꺼진 상태에서 만질 경로 하나(`CLAUDE.md`)에 사용자 변경을 만들고 커밋하지 않은 채 켜기.

```
git status --porcelain -- <5경로>
 M CLAUDE.md

(켜기 실행)
STOP: 만질 경로에 커밋되지 않은 변경이 있다. 먼저 커밋하거나 치워 달라.
 M CLAUDE.md
on exit=2
```

- **(a) 켜기가 멈춘다** — 합격. 1단계 4번에서 종료코드 2로 멈췄다. 3단계(보관)·4단계(교체)에 들어가지 않았다.
- **(b) 커밋/치우기를 요청한다** — 합격. 위 문장이 그것이다.
- **(c) 파일이 하나도 바뀌지 않는다** — 합격.
  ```
  diff -r <직전사본>/.claude/agents  .claude/agents         → 차이 0
  cmp <직전사본>/.claude/settings.json .claude/settings.json → 차이 0
  cmp <직전사본>/CLAUDE.md            CLAUDE.md              → 차이 0
  cmp <직전사본>/state.json .claude/sdd-switch/state.json    → 차이 0 (active 는 "original" 그대로)
  ls -d .claude/skills/orchestra .claude/skills/agent-model-tier → 둘 다 No such file or directory
  ```

**즉 11.1 이 끄기만 내렸고 켜기까지 내리지 않았다.** (여기서 안 멈췄다면 되돌려야 했다)

### 치운 것 (작업 11.9)

- `/tmp/sdd-reverify.db978F`
- `/tmp/sdd-reverify-snap.Rh0R97` (대조용 사본)

`chmod` 로 권한을 막은 시험은 이번 묶음에서 하지 않았으므로 되돌릴 권한도 없다.
지운 뒤 확인 결과는 아래 "지운 뒤 확인 (11.9)"에 있다.

### 지운 뒤 확인 (11.9)

```
ls -d /tmp/sdd-reverify.db978F      → No such file or directory
ls -d /tmp/sdd-reverify-snap.Rh0R97 → No such file or directory
```

`chmod` 로 쓰기를 막아 둔 자리는 없었다
(`find <임시>/.claude/sdd-switch ! -perm -u+w` 가 빈 출력).

이 저장소 확인:

```
git status --short
 M .claude/skills/orchestra/SKILL.md
 M CLAUDE.md
 M README.md
D  install.sh
?? .agents/
?? .claude/skills/agent-model-tier/
?? openspec/changes/make-analyzer-opt-in-and-add-install-skill/
?? switch_skill/

git diff --stat -- .claude/agents/
(빈 출력)
```

`.claude/agents/` 는 이번에도 한 줄도 바뀌지 않았다. 시험이 만든 임시 파일도 없다
(시험은 `/tmp/sdd-reverify.*` 안에서만 했고 그 둘은 위에서 지웠다).

**단, 묶음 10 때는 없던 `?? .agents/` 가 목록에 새로 있다.** 안에 있는 것은
`.agents/skills/claude-handoff/` 이고 다른 도구(Antigravity 로 작업을 넘기는 스킬)가
놓은 것이다. 이번 change 와 이번 시험이 만든 것이 아니고 이번 change 의 범위 밖이라
**지우지 않고 그대로 두었다.** 커밋에 섞이면 안 되므로 finalizer 가 스테이징할 때
빼야 한다.

---

# `install.sh` 재검증 (묶음 12.13 — 2026-09-11 실측)

`switch_skill` 이 제품에서 빠지고 `install.sh` 가 되살아났다. 되살린 뒤 두 곳을 고쳤으므로
(조각을 `CLAUDE.md` 마커 구획에서 뽑기, 판별을 낱말에서 마커로) **다시 돌려 봤다.**
아래는 실제로 실행한 명령과 그 출력이다.

## 시험 머리말

| 항목 | 값 |
|---|---|
| 시험 날짜 | 2026-09-11 |
| `openspec --version` | `1.12.0` |
| 원본 트리(`$SRC`) | `/Users/0stone_1004/orca/projects/init-SDD` |
| 임시 A (빈 프로젝트 → 첫 설치·재실행) | `/tmp/sdd-i-A.QOVrMe` |
| 임시 B (사람이 쓴 `CLAUDE.md` 있음) | `/tmp/sdd-i-B.tMa3Sf` |
| 임시 C (마커 없이 `오케스트레이터` 만 있음) | `/tmp/sdd-i-C.4rOYtj` |
| 임시 D (가짜 원본 — 마커를 지움) | `/tmp/sdd-i-D.uAiHF6` |
| 임시 E (가짜 원본 — `CLAUDE.md` 없음) | `/tmp/sdd-i-E.t1nHj6` |
| 가짜 원본 트리(`FSRC`) | `/tmp/sdd-i-FSRC.v9tMsK` |

**이 저장소는 시험 대상이 아니었다.** 모든 설치는 위 `mktemp -d` 경로 안에서만 했고,
사용자의 다른 프로젝트는 건드리지 않았다. 여섯 경로 모두 12.14 에서 지웠다.

## 요약 표

| # | 무엇을 봤나 | 판정 |
|---|---|---|
| 1 | 문법 (`bash -n`) | **합격** |
| 2 | 마른 실행이 아무것도 바꾸지 않는지 | **합격** |
| 3 | 조각이 마커 구획에서 제대로 뽑혀 원본과 `diff` 차이 0 | **합격** |
| 4 | `agent-model-tier` 가 복사되고 원본과 `diff` 차이 0 | **합격** |
| 5 | 판별 — `CLAUDE.md` 가 없음 → 새로 만든다 | **합격** |
| 6 | 판별 — 마커가 있음 → 건너뛴다 (두 번 안 들어간다) | **합격** |
| 7 | 판별 — 마커도 낱말도 없음 → 끝에 덧붙인다 | **합격** |
| 8 | 판별 — 마커는 없고 낱말만 있음 → **넣지 않고 알린다** | **합격** |
| 9 | 새 실패 모드 — 조각을 못 뽑으면 멈추는지 | **합격** (두 갈래 다) |
| 10 | 안전장치 — 저장소 안에서 실행하면 거부하는지 | **합격** |

**불합격 없음.** 눈에 걸린 것 하나는 아래 "고치지 않고 적어 두는 것"에 있다.

## 1. 문법 — 합격

```
bash -n install.sh; echo "exit=$?"
exit=0
```

## 10. 안전장치: 저장소 안에서 실행 — 합격 (먼저 확인했다)

```
(저장소 루트에서) bash install.sh --dry-run
오류: init-SDD 저장소 안에서 실행했다. 설치할 프로젝트로 이동해서 실행해라.
exit=1
```

`$SRC == $DST` 거부가 여전히 돈다. 이 저장소에 설치가 쏟아질 경로가 막혀 있다.

## 2. 마른 실행 — 합격

임시 A 를 `git init` + `git commit --allow-empty -m init` 으로 준비하고 돌렸다.

```
bash "$SRC/install.sh" --dry-run
...
2. OpenSpec 초기화
   openspec init --tools claude 실행
3. 에이전트와 지휘 스킬 복사
   [복사 예정] .claude/agents/analyzer.md   ... (7개)
   [복사 예정] .claude/skills/orchestra
   [복사 예정] .claude/skills/agent-model-tier
   [복사 예정] .claude/settings.json
4. CLAUDE.md
   없다. 새로 만든다.
5. 설치 확인
   (--dry-run: 확인은 건너뛴다)
dry-run exit=0
```

전후 대조 — 파일 목록과 `git status --porcelain` 둘 다 차이가 없다.

```
diff (전 파일목록) (후 파일목록)   → 파일목록 diff exit=0
diff (전 git status) (후 git status) → git status diff exit=0
git status --porcelain 실제 내용     → [] (빈 출력)
```

**아무것도 바꾸지 않았다.** `[복사 예정]` 이라는 말투도 실제 실행(`[복사]`)과 구별된다.

## 3. 실제 설치와 조각 뽑기 — 합격

같은 임시 A 에서 실제 설치. `exit=0`, 5단계 확인이 이렇게 나왔다.

```
5. 설치 확인
   에이전트: 7개 (7이어야 한다)
   orchestra 스킬: ok
   agent-model-tier 스킬: ok
   OpenSpec 스킬 6개: ok
   openspec 동작: ok
```

대상 `CLAUDE.md` 는 19줄이고 첫 줄이 `<!-- init-SDD:begin -->`, 마지막 줄이
`<!-- init-SDD:end -->` 다. 저장소 구획과 바이트 대조:

```
sed -n '/init-SDD:begin/,/init-SDD:end/p' "$SRC/CLAUDE.md" > src.block
sed -n '/init-SDD:begin/,/init-SDD:end/p' CLAUDE.md        > dst.block
diff src.block dst.block   → 구획 diff exit=0
begin=1  end=1
'템플릿 안내' 개수 = 0
```

**마커 두 줄까지 그대로 들어갔고, 그 위의 "템플릿 안내" 주석은 새어 들어가지 않았다.**
조각 사본이 `install.sh` 안에 없다는 것이 실제로 확인된 셈이다 — 스크립트는 뽑는 방법만
갖고 있고, 문구는 저장소 `CLAUDE.md` 한 곳에서 온다.

들어간 조각이 요구사항 1 의 결과(analyzer 옵트인)를 담고 있는 것도 함께 확인됐다.

```
순서: `preparer` → `designer` → `worker` → `reviewer` + `regression-verifier`(동시)
→ `finalizer`

분석·방안 비교를 요청할 때만 `analyzer` 를 부른다. ...
```

## 4. `agent-model-tier` 복사 — 합격

```
ls -l .claude/skills/agent-model-tier/SKILL.md   → 있음 (7491 바이트)
diff -r "$SRC/.claude/skills/agent-model-tier" .claude/skills/agent-model-tier
  → agent-model-tier diff exit=0
줄수: 대상 136 / 원본 136
```

곁들여 나머지 제품도 대조했다. 전부 차이 0.

```
diff -r orchestra   → exit=0
diff -r agents      → exit=0   (7개)
diff settings.json  → exit=0
ls .claude/skills   → agent-model-tier, openspec-* 6개, orchestra
```

제품 5종이 모두 제자리에 놓였다.

## 5~8. 판별 네 갈래 — 모두 합격

### 갈래 (a) `CLAUDE.md` 가 없다 → 새로 만든다

임시 A 의 첫 설치가 그 경로였다. `없다. 새로 만든다.` → 19줄 파일이 생겼다 (위 3번).

### 갈래 (b) 마커가 있다 → 건너뛴다

같은 임시 A 에 설치를 **두 번 더** 돌렸다.

```
4. CLAUDE.md
   이미 들어가 있다 (마커 <!-- init-SDD:begin --> 를 찾았다). 건너뛴다.

exit=0
init-SDD:begin 개수 = 1      (두 번 들어가지 않았다)
줄수 = 19
md5  before=b9eb1658fb906171c1b00c93b35315ca
     after =b9eb1658fb906171c1b00c93b35315ca
```

3단계도 전부 `[있음, 건너뜀]` 이었고, 끝에 건너뛴 파일 10개의 목록과 **저장소 쪽 원본
경로**가 함께 나왔다. 안전 모델("이미 있으면 덮어쓰지 않고 알린다")이 그대로 돈다.

### 갈래 (c) 마커도 낱말도 없다 → 끝에 덧붙인다

임시 B 에 사람이 쓴 `CLAUDE.md` 를 심어 두고 돌렸다.

```
# 우리 팀 규칙

테스트는 pytest 로 돌린다.
```

```
4. CLAUDE.md
   이미 있다. 끝에 덧붙인다 (기존 내용은 그대로 둔다).
exit=0

'우리 팀 규칙' = 1,  'pytest' = 1     ← 사람 문장이 그대로 살아 있다
diff src.block (붙은 구획)  → 구획 diff exit=0
```

### 갈래 (d) 마커는 없고 `오케스트레이터` 만 있다 → 넣지 않고 알린다

임시 C 에 `메인 세션은 오케스트레이터 역할을 한다.` 한 줄이 든 `CLAUDE.md` 를 심었다.

```
4. CLAUDE.md
   넣지 않았다. 마커는 없는데 '오케스트레이터' 라는 낱말이 이미 있다.
     예전 방식으로 이미 깔았거나, 사용자가 우연히 그 낱말을 쓴 것일 수 있다.
     스크립트가 둘을 구별할 수 없어서 조각을 넣지 않았다. 직접 확인해라.
     구획을 뽑아 보는 명령: sed -n '/init-SDD:begin/,/init-SDD:end/p' "$SRC/CLAUDE.md"
     넣어야 한다면 그 뒤에 >> "/tmp/sdd-i-C.4rOYtj/CLAUDE.md" 를 붙여 끝에 덧붙여라.
exit=0

md5  before=f3dd941297e37b5f28aace8d0597a40f
     after =f3dd941297e37b5f28aace8d0597a40f   ← 한 바이트도 안 바뀌었다
begin 개수 = 0,  줄수 = 3
```

**짐작하지 않고 사실만 알렸고, 사용자 파일을 건드리지 않았다.** 알려 준 명령은 그대로
복사해 쓸 수 있는 형태다(경로가 채워져 나온다).

## 9. 새 실패 모드 — 조각을 못 뽑으면 멈춘다 (두 갈래 다 합격)

`sed` 로 바꾸면서 생긴 새 실패 모드다. 빈 값을 붙이면 스크립트가 "성공"이라 말하면서
아무 지시문도 안 넣고 사용자는 깔렸다고 믿는다. 실제로 막히는지 **가짜 원본 트리**
(`FSRC` — 제품 5종을 복사해 두고 `CLAUDE.md` 만 망가뜨린 것)를 만들어 확인했다.

### (a) 원본에서 마커 두 줄이 지워진 경우 — 임시 D

```
grep -v 'init-SDD:begin\|init-SDD:end' "$SRC/CLAUDE.md" > "$FSRC/CLAUDE.md"
bash "$FSRC/install.sh"

4. CLAUDE.md
오류: CLAUDE.md 에서 init-SDD 구획을 뽑지 못했다.
      /tmp/sdd-i-FSRC.v9tMsK/CLAUDE.md 의 마커(<!-- init-SDD:begin --> ~ <!-- init-SDD:end -->)를
      확인해라.
exit=1

ls CLAUDE.md → No such file or directory     ← 빈 조각이 안 들어갔다
```

### (b) 원본 `CLAUDE.md` 자체가 없는 경우 — 임시 E

```
rm -f "$FSRC/CLAUDE.md"
bash "$FSRC/install.sh"

4. CLAUDE.md
오류: 원본이 없다: /tmp/sdd-i-FSRC.v9tMsK/CLAUDE.md .
      init-SDD 저장소를 통째로 받았는지 확인해라.
exit=1

ls CLAUDE.md → No such file or directory
```

두 갈래 모두 **종료코드 1 로 멈추고, 어느 파일의 무엇이 문제인지 경로째로 알린다.**
"성공이라 말하면서 아무것도 안 넣는" 경로는 막혔다.

## 고치지 않고 적어 두는 것 (설계 범위 밖이라 손대지 않았다)

**조각을 못 뽑아 멈추는 지점이 3단계(복사) 뒤에 있다.** 그래서 위 (a)·(b) 에서 멈출 때
대상 프로젝트에는 이미 `openspec init` 결과와 제품 4종이 들어간 상태였다. 조각만 빠진
"덜 깔린" 상태다.

**해롭지는 않다** — 종료코드 1 과 오류 문구가 나오므로 사용자가 실패를 안다. 마커를 고쳐
다시 돌리면 이미 있는 것은 건너뛰고 `CLAUDE.md` 만 채운다(갈래 (b) 로 확인됨). 조용히
잃는 것도 없다. 이 저장소의 안전 모델("최악이 덜 깔린 채로 무엇이 덜 됐는지 알려 주는 것")
안에 있다.

**그래도 더 좋은 형태는 있다:** 조각 뽑기와 빈 값 검사를 **1단계 전제 조건**으로 올리면
아무것도 쓰기 전에 멈춘다(fail-fast). `design.md` 결정 1·7 과 작업 12.3 은 그 검사를
4단계에 두라고 적고 있어서 **이번에는 옮기지 않았다.** 옮길지는 designer 가 정할 일이다.

## 치움 (작업 12.14)

시험이 쓴 임시 경로 여섯 개를 지웠다. 지우기 전에 경로가 모두 `/tmp/sdd-i-*` 형태인지
한 줄씩 확인했다.

```
rm -rf /tmp/sdd-i-A.QOVrMe      (420K)
       /tmp/sdd-i-B.tMa3Sf      (420K)
       /tmp/sdd-i-C.4rOYtj      (420K)
       /tmp/sdd-i-D.uAiHF6      (416K)
       /tmp/sdd-i-E.t1nHj6      (416K)
       /tmp/sdd-i-FSRC.v9tMsK   (160K)

ls -d /tmp/sdd-i-*   → no matches found      (남은 것 없음)
```

대조용으로 쓴 작은 파일들(`/tmp/sdd-i-*.txt`, `*.block`, `*.md5before`)도 함께 지웠다.

이 저장소에 시험 흔적이 없다.

```
git status --short
 M .claude/skills/orchestra/SKILL.md
 M CLAUDE.md
 M README.md
 M install.sh
?? .agents/
?? .claude/skills/agent-model-tier/
?? openspec/changes/make-analyzer-opt-in-and-add-install-skill/

git diff --stat -- .claude/agents/
(빈 출력)
```

임시 경로가 목록에 없고, `.claude/agents/` 는 이번에도 한 줄도 바뀌지 않았다(작업 9.4 보존).
`?? .agents/` 는 묶음 11 에서 적은 그대로 다른 도구가 놓은 것이고 이번 change 밖이라
그대로 두었다.
