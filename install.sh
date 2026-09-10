#!/usr/bin/env bash
# init-SDD 설치 스크립트
# 대상 프로젝트 루트에서 실행한다. 기존 파일을 덮어쓰지 않는다.
#
#   bash install.sh              # 설치
#   bash install.sh --dry-run    # 무엇을 할지만 보여준다
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST="$(pwd)"
DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

say()  { printf '%s\n' "$*"; }
run()  { if [[ $DRY -eq 0 ]]; then eval "$@"; fi; }
fail() { printf '오류: %s\n' "$*" >&2; exit 1; }

[[ "$SRC" == "$DST" ]] && fail "init-SDD 저장소 안에서 실행했다. 설치할 프로젝트로 이동해서 실행해라."

say "init-SDD 설치"
say "  원본: $SRC"
say "  대상: $DST"
[[ $DRY -eq 1 ]] && say "  (--dry-run: 아무것도 바꾸지 않는다)"
say ""

# --- 1. 전제 조건 ---
say "1. 전제 조건 확인"
command -v git >/dev/null || fail "git이 없다."
git -C "$DST" rev-parse --git-dir >/dev/null 2>&1 || fail "git 저장소가 아니다. 먼저 'git init'을 해라."
# 커밋이 하나도 없으면 preparer가 브랜치를 만들 수 없다
if ! git -C "$DST" log -1 >/dev/null 2>&1; then
  fail "커밋이 하나도 없다. 'git commit --allow-empty -m init' 으로 초기 커밋을 만든 뒤 다시 실행해라."
fi
say "   git 저장소: ok (커밋 있음)"

command -v claude >/dev/null || say "   경고: claude CLI가 없다. 설치 후 사용해라."

if ! command -v openspec >/dev/null; then
  fail "openspec CLI가 없다. 'npm i -g @fission-ai/openspec' 로 설치한 뒤 다시 실행해라."
fi
OS_VER="$(openspec --version 2>/dev/null | tr -d '\r')"
say "   openspec: $OS_VER"
case "$OS_VER" in
  1.[0-9].*|1.1[01].*|0.*) say "   경고: 1.12 이상을 권한다. 지금 버전에서는 일부 명령이 다를 수 있다." ;;
esac

# --- 2. OpenSpec 초기화 ---
say ""
say "2. OpenSpec 초기화"
if [[ -f "$DST/openspec/config.yaml" ]]; then
  say "   이미 있다 (openspec/config.yaml). 건너뛴다."
else
  say "   openspec init --tools claude 실행"
  run "openspec init --tools claude --no-animation"
fi

# --- 3. 에이전트와 스킬 복사 (덮어쓰지 않는다) ---
say ""
say "3. 에이전트와 지휘 스킬 복사"
SKIPPED=()
copy_if_absent() {  # $1=원본 상대경로  $2=대상 상대경로
  local s="$SRC/$1" d="$DST/$2"
  if [[ -e "$d" ]]; then
    SKIPPED+=("$2")
    say "   [있음, 건너뜀] $2"
  else
    run "mkdir -p \"\$(dirname \"$d\")\""
    run "cp -R \"$s\" \"$d\""
    if [[ $DRY -eq 1 ]]; then say "   [복사 예정] $2"; else say "   [복사] $2"; fi
  fi
}

for f in "$SRC"/.claude/agents/*.md; do
  copy_if_absent ".claude/agents/$(basename "$f")" ".claude/agents/$(basename "$f")"
done
copy_if_absent ".claude/skills/orchestra" ".claude/skills/orchestra"
copy_if_absent ".claude/skills/agent-model-tier" ".claude/skills/agent-model-tier"
copy_if_absent ".claude/settings.json" ".claude/settings.json"

# --- 4. CLAUDE.md 는 합친다 ---
say ""
say "4. CLAUDE.md"
# 조각 원본은 이 저장소 CLAUDE.md 의 마커 구획 한 곳뿐이다. 여기에 문구를 베껴 두지 않는다.
MARK_BEGIN='<!-- init-SDD:begin -->'
MARK_END='<!-- init-SDD:end -->'
EXTRACT_CMD="sed -n '/init-SDD:begin/,/init-SDD:end/p' \"$SRC/CLAUDE.md\""
# 예전 방식(마커가 없던 때)으로 깔았는지 짐작하는 데만 쓰는 낱말. 한 곳에만 적는다.
OLD_WORD='오케스트레이터'

[[ -f "$SRC/CLAUDE.md" ]] || fail "원본이 없다: $SRC/CLAUDE.md . init-SDD 저장소를 통째로 받았는지 확인해라."
SNIPPET="$(sed -n "/$MARK_BEGIN/,/$MARK_END/p" "$SRC/CLAUDE.md")"
# 빈 값을 붙이면 "성공"이라 말하면서 아무 지시문도 안 들어간다. 그러면 멈춘다.
[[ -n "$SNIPPET" ]] || fail "CLAUDE.md 에서 init-SDD 구획을 뽑지 못했다. $SRC/CLAUDE.md 의 마커($MARK_BEGIN ~ $MARK_END)를 확인해라."

# 판별은 마커로 한다. 낱말은 사람이 쓰는 말이라 지문으로 약하다.
if [[ ! -f "$DST/CLAUDE.md" ]]; then
  say "   없다. 새로 만든다."
  if [[ $DRY -eq 0 ]]; then printf '%s\n' "$SNIPPET" > "$DST/CLAUDE.md"; fi
elif grep -qF "$MARK_BEGIN" "$DST/CLAUDE.md" 2>/dev/null; then
  say "   이미 들어가 있다 (마커 $MARK_BEGIN 를 찾았다). 건너뛴다."
elif grep -qF "$OLD_WORD" "$DST/CLAUDE.md" 2>/dev/null; then
  # 예전 방식으로 깔았을 수도 있고, 사용자가 우연히 그 낱말을 썼을 수도 있다.
  # 스크립트가 둘을 구별할 수 없으므로 짐작하지 않고 넣지 않은 채 사실만 알린다.
  say "   넣지 않았다. 마커는 없는데 '$OLD_WORD' 라는 낱말이 이미 있다."
  say "     예전 방식으로 이미 깔았거나, 사용자가 우연히 그 낱말을 쓴 것일 수 있다."
  say "     스크립트가 둘을 구별할 수 없어서 조각을 넣지 않았다. 직접 확인해라."
  say "     구획을 뽑아 보는 명령: $EXTRACT_CMD"
  say "     넣어야 한다면 그 뒤에 >> \"$DST/CLAUDE.md\" 를 붙여 끝에 덧붙여라."
else
  say "   이미 있다. 끝에 덧붙인다 (기존 내용은 그대로 둔다)."
  if [[ $DRY -eq 0 ]]; then printf '\n\n%s\n' "$SNIPPET" >> "$DST/CLAUDE.md"; fi
fi

# --- 5. 설치 확인 ---
say ""
say "5. 설치 확인"
if [[ $DRY -eq 1 ]]; then say "   (--dry-run: 확인은 건너뛴다)"; fi
if [[ $DRY -eq 0 ]]; then
  N_AGENTS=$(ls "$DST/.claude/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
  say "   에이전트: ${N_AGENTS}개 (7이어야 한다)"
  # 우리 스킬 2개 (지휘 + 모델 등급). 하나라도 없으면 제품이 덜 깔린 것이다.
  OURS_MISSING=()
  for ours in orchestra agent-model-tier; do
    if [[ -f "$DST/.claude/skills/$ours/SKILL.md" ]]; then
      say "   $ours 스킬: ok"
    else
      OURS_MISSING+=("$ours")
    fi
  done
  if [[ ${#OURS_MISSING[@]} -gt 0 ]]; then
    say "   경고: init-SDD 스킬이 빠졌다: ${OURS_MISSING[*]}"
    for ours in "${OURS_MISSING[@]}"; do
      say "     원본: $SRC/.claude/skills/$ours"
    done
  fi
  MISSING=()
  for sk in explore propose update-change apply-change sync-specs archive-change; do
    [[ -f "$DST/.claude/skills/openspec-$sk/SKILL.md" ]] || MISSING+=("openspec-$sk")
  done
  if [[ ${#MISSING[@]} -gt 0 ]]; then
    say "   경고: OpenSpec 스킬이 빠졌다: ${MISSING[*]}"
    say "     전역 설정 때문일 수 있다. 아래를 실행해라:"
    say "       openspec config set delivery both"
    say "       openspec config set profile core"
    say "       openspec update --force"
  else
    say "   OpenSpec 스킬 6개: ok"
  fi
  openspec list >/dev/null 2>&1 && say "   openspec 동작: ok" || say "   경고: openspec list 가 실패했다."
fi

# --- 결과 ---
say ""
say "설치 끝."
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  say ""
  say "이미 있어서 건너뛴 파일이 있다. 필요하면 직접 비교해서 합쳐라:"
  for p in "${SKIPPED[@]}"; do say "  - $p   (원본: $SRC/$p)"; done
fi
say ""
say "다음 할 일:"
say "  1. openspec/config.yaml 에 context: 를 적어라 — 기술 스택·테스트·빌드 명령."
say "     (여기가 프로젝트 사정이 에이전트에게 전달되는 유일한 통로다. 비우면 스택을 스스로 고른다)"
say "     주의: 줄 맨 앞에(들여쓰기 없이) 새로 적어라. 예시 주석에서 # 만 지우면 들여쓰기가"
say "     남아 YAML이 깨지고, openspec은 경고만 내고 그 파일을 통째로 무시한다."
say "     적은 뒤 'openspec context' 로 Warning 이 없는지 확인해라."
say "  2. .gitignore 에 .claude/settings.local.json 한 줄을 더해라 (개인 설정)."
say "  3. Claude Code를 새 세션으로 다시 열어라 (새 에이전트·스킬이 잡힌다)."
say "  4. 개인 설정을 공유 저장소에 남기고 싶지 않으면 링크 방식(init-sdd 스킬)도 있다 — 고르는 안내는 $SRC/README.md 의 '먼저 고른다' 절에 있다."
say ""
say "그 다음 그냥 할 일을 말하면 된다. 예: \"로그인 기능 추가해줘\""
say "파이프라인을 직접 부르려면: /orchestra <할 일>"
