#!/usr/bin/env bash
# sdd 플러그인 SessionStart 훅.
# 프로젝트에 표식 openspec/.sdd 가 있을 때만 지휘 규칙과 빠른 점검 결과를 낸다.
# set -e 를 쓰지 않는다 — 점검 하나가 실패해도 세션 시작을 막지 않고 exit 0 으로 끝나야 한다.
# 네트워크를 쓰거나 npx를 실행하지 않는다(command -v 와 grep 만 쓴다).

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

# 표식이 없으면 아무것도 출력하지 않는다(openspec/ 만 있는 프로젝트도 조용하다).
[ -f "$ROOT/openspec/.sdd" ] || exit 0

# 지휘 규칙 (8줄 이하. 절차 본문은 sdd:orchestra 스킬에 있다)
cat <<'RULES'
[SDD] 이 프로젝트는 SDD 파이프라인(openspec/)으로 일한다. (sdd 플러그인 SessionStart 훅)
- 메인 세션은 오케스트레이터다. 사용자와 대화하고 지휘만 한다.
- 분석·설계·파일 수정·리뷰·커밋은 직접 하지 말고 sdd: 서브에이전트(sdd:preparer, sdd:worker 등)에게 위임한다.
- 일을 처리해 달라는 요청이 오면 먼저 sdd:orchestra 스킬을 불러 그 절차를 따른다.
- 분석·방안 비교를 요청받았을 때만 sdd:analyzer를 넣고, 사용자가 방안을 고르게 한다.
- 지휘 절차의 본문은 sdd:orchestra 스킬에 있다. 이 훅은 요약만 넣는다.
RULES

# 점검 — 문제가 있는 것만 한 줄씩 알린다.
problems=0

if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  echo "[SDD 점검] node/npx가 PATH에 없다 — sdd-openspec이 돌지 않는다."
  problems=$((problems + 1))
fi

if ! grep -qs 'sdd-openspec' "$ROOT/.claude/settings.json" "$ROOT/.claude/settings.local.json"; then
  echo "[SDD 점검] 권한에 Bash(sdd-openspec:*)가 없다 — /sdd:init 으로 추가할 수 있다."
  problems=$((problems + 1))
fi

for t in "$ROOT"/openspec/changes/*/tasks.md; do
  [ -f "$t" ] || continue
  case "$t" in */changes/archive/*) continue;; esac
  if grep -qE '^[[:space:]]*- \[[xX]\]' "$t" && ! grep -qE '^[[:space:]]*- \[ \]' "$t"; then
    name="$(basename "$(dirname "$t")")"
    echo "[SDD 점검] 끝났지만 archive 안 된 change: $name"
    problems=$((problems + 1))
  fi
done

if [ "$problems" -eq 0 ]; then
  echo "[SDD 점검] 이상 없음"
fi

exit 0
