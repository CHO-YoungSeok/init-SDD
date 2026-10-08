# Tasks

채택안: 없음(analyzer 생략) — 기준은 proposal의 받아들일 조건 1~9와 가정 G1~G7(전부 채택), 발견 표 48행의 판정.
핵심 결정:
- 메인 spec의 긴 요구사항(실측 28개)은 델타로 나눈다. 델타는 이미 써 두었고(specs/), 메인 spec 반영은 finalizer가 sync로 한다. **worker는 `openspec/specs/`를 건드리지 않는다.**
- 시나리오 이름을 바꿔야 하는 9개 요구사항은 1.14.1이 MODIFIED를 막아(실측) REMOVED + ADDED(새 헤더)로 갈아 끼운다(design.md 결정 2).
- 지시문·문서는 design.md 결정 6·7 표의 "찾을 글자 → 바꿀 글자"를 Edit로 하나씩 반영한다. 전체 Write 재작성·`sed -i` 금지.

커밋 단위 대응(커밋은 finalizer가 한다): ① change 산출물 = 이 디렉터리 / ② 지시문 = 묶음 2 / ③ 문서 = 묶음 3 / ④ 메인 spec sync / ⑤ archive.
병렬: **묶음 2와 묶음 3은 파일이 겹치지 않아 동시에 해도 된다.** 묶음 2 안에서도 2.1~2.7(`agents/`)과 2.8~2.10(`skills/`)은 서로 다른 파일이다.
묶음 4는 2·3이 끝난 뒤에 한다.

## 1. 시작 기준 기록 (파일 수정 없음)

- [x] 1.1 `git rev-parse HEAD`를 기록한다. 값이 `5df62b21b69a7a5e07396552373fa7eef10cb731`이고, `git status --short` 출력이 `?? openspec/changes/audit-specs-and-docs/` 한 줄뿐인지 확인한다(다르면 멈추고 보고). 이 값이 "시작 커밋"이다 — 4.6 범위 밖 diff와 finalizer의 sync 대조 원본(design.md 결정 8의 4(a) `git archive <시작커밋> openspec`)이 이 값을 쓴다.
- [x] 1.2 저장소 루트에서 `./bin/sdd-openspec validate --all --strict; echo "exit=$?"`를 돌려 지금 값(exit=1, 메인 spec 9개 실패)을 보고서에 그대로 적는다. 이 단계에서는 실패가 정상이다(메인 spec은 sync 전이다).

## 2. 지시문 Edit (커밋 단위 ②, design.md 결정 6)

각 작업 뒤 그 파일에서 바꾼 글자 `command grep -cF '<바꿀 글자의 특징 부분>' <파일>`이 1 이상, 찾을 글자가 0인지 확인한다.

- [x] 2.1 `agents/designer.md` — 결정 6의 #30(147줄) 1건, #32 7건(3, 13-14, 27-28, 66, 108, 231, 235줄), #31 1건(238줄 보고 양식). 확인: `command grep -c 'analyzer를 불렀을 때만. 생략 경로면' agents/designer.md` → 1, `command grep -c '번 타자\|원인이 명확한 버그 등\|버그 수정처럼' agents/designer.md` → 0, `command grep -c '채택안=<N안/없음>' agents/designer.md` → 1, `command grep -c '은퇴 예약일 뿐' agents/designer.md` → 1.
- [x] 2.2 `agents/analyzer.md` — #33 2건(3, 13줄), #37 1건(93줄). 확인: `command grep -c '번 타자\|탐색/검색도' agents/analyzer.md` → 0, frontmatter `description`에 "방안을 최소 3가지"가 그대로 있다.
- [x] 2.3 `agents/worker.md` — #33 2건(3, 33줄). 확인: `command grep -c '번 타자\|7개 중 유일하게' agents/worker.md` → 0.
- [x] 2.4 `agents/reviewer.md` — #33(3줄), #34(129-130줄), #37(134줄), #31(174줄). 확인: `command grep -c '번 타자\|없으면 프로젝트에서 찾음' agents/reviewer.md` → 0, `command grep -c 'tests=없음' agents/reviewer.md` → 1 이상.
- [x] 2.5 `agents/finalizer.md` — #35(115줄). 확인: `command grep -c 'attribution' agents/finalizer.md` → 1 이상, 기본 줄 `Co-Authored-By: Claude <noreply@anthropic.com>`이 코드펜스 안에 그대로 있다.
- [x] 2.6 `agents/regression-verifier.md` — #38(102줄). 확인: `command grep -c 'stash 대조' agents/regression-verifier.md` → 0.
- [x] 2.7 `agents/preparer.md` — #39(22줄). 확인: `command grep -c 'sdd-openspec store list --json' agents/preparer.md` → 1, `` command grep -c '`openspec store list' agents/preparer.md `` → 0.
- [x] 2.8 `skills/orchestra/SKILL.md` — #40(40줄), #31(68줄 그림, 88줄 표, 103-105줄), #30·G4(커밋 관문 확인 줄 다음에 새 줄), #28(블록 A: 382줄 코드펜스 안 한 줄 교체 + 펜스 뒤 목록 추가), #29(466줄 + 이어지는 한 줄). 확인: `command grep -c '\[designer\]  decision.md\|(큰 작업만) decision.md' skills/orchestra/SKILL.md` → 0, `command grep -c 'analyzer를 불렀으면 decision.md\|analyzer를 불렀을 때만 decision.md' skills/orchestra/SKILL.md` → 2, `command grep -c '고치지 않고 끝나면 "사용자가 중간에 취소할 때"' skills/orchestra/SKILL.md` → 1, `command grep -c '"알아서 해" 뒤에는 은퇴 대상을' skills/orchestra/SKILL.md` → 1, `command grep -c 'tests=안맡음 | blockers=0' skills/orchestra/SKILL.md` → 1, `command grep -c 'analyzer만\.' skills/orchestra/SKILL.md` → 0, `command grep -c 'retire_capabilities: true' skills/orchestra/SKILL.md` → 1 이상, `LC_ALL=C awk '/^## 설계 수정이 필요해졌을 때/,/^\*\*작은 작업에서 올라올 때/' skills/orchestra/SKILL.md | command grep -c 'analyzer 생략: 예'` → 2 이상(예시 줄 + 목록 줄).
- [x] 2.9 `skills/sdd-rules/SKILL.md` — #30(63줄), #37(76줄). 확인: `command grep -c '^## ' skills/sdd-rules/SKILL.md` → 7(절 수 그대로), `command grep -c 'not found' skills/sdd-rules/SKILL.md` → 1, `command grep -n '1.14.1' skills/sdd-rules/SKILL.md`로 나온 줄이 모두 "쓰는 스킬" 절 안, `command grep -c '은퇴 여섯 조건' skills/sdd-rules/SKILL.md` → 1, `command grep -c '사전 승인으로 본다' skills/sdd-rules/SKILL.md` → 1.
- [x] 2.10 `skills/init/SKILL.md` — #36(78줄). 확인: `command grep -c '새 세션을 열 필요는 없다. 다음 세션부터' skills/init/SKILL.md` → 0.
- [x] 2.11 묶음 2에서 고친 `.md` 10개 무결성: 파일마다 `command grep -c 'ORCA_RICH''_MD' <파일>` → 0, `command grep -c '^```' <파일>` 짝수, frontmatter `---` 두 줄과 원래 키(에이전트는 `name`·`description`·`model`·`tools`·`skills`, 스킬은 `name`·`description`)가 그대로다.
- [x] 2.12 구현 리뷰 재작업(design.md 결정 6 #29, 결정 7 #42·#31 118줄): `skills/orchestra/SKILL.md` 조사 줄을 "(고치면 3단계(방안 선택)부터 이어 간다)"로, `README.md` 84줄 묻는 횟수 칸과 118줄 decision.md 행을 결정 7 표대로 고친다. 확인: `command grep -c '고치면 크기 판정대로 이어 간다' skills/orchestra/SKILL.md` → 0, `command grep -c '고치면 3단계(방안 선택)부터 이어 간다' skills/orchestra/SKILL.md` → 1, `command grep -c '고치면 3단계 방안 선택부터' README.md` → 1, `command grep -c '리뷰의 기준, analyzer를 불렀을 때만' README.md` → 1, 두 파일에 2.11 무결성 세 검사.

## 3. 문서 Edit (커밋 단위 ③, design.md 결정 7)

- [x] 3.1 `README.md` — #31(45-46, 96, 370-371줄), #30(360-361줄), #41(66-67줄), #42(84줄), #36(블록 B, 171-175줄), #26(권한 절 끝 한 줄), #43(293줄), #44(331-334줄). 확인: `command grep -c '바로 설계로 갈까요\|analyzer 1번\|Tech stack\|\*\*결정 기록\*\*과' README.md` → 0, `command grep -c 'finalizer,code-explorer}.md' README.md` → 1, `command grep -c '켜는 것도 끄는 것도 다음 세션부터' README.md` → 1, `command grep -c '기본 브랜치: <이름>' README.md` → 1, `command grep -c 'preparer → analyzer' README.md` → 1 이상, `command grep -c '큰 작업일 때만 — 결정 기록(decision.md)' README.md` → 0, `command grep -c '(analyzer를 불렀으면 결정 기록 decision.md도)' README.md` → 1, `command grep -c '1~2 (고칠지 1번' README.md` → 1.
- [x] 3.2 `.claude/skills/init-sdd/SKILL.md` — #43(3, 514-515줄). 확인: `command grep -c '서브에이전트 7개\|에이전트 목록에 7개' .claude/skills/init-sdd/SKILL.md` → 0, `command grep -c '`code-explorer`)가 보이는지' .claude/skills/init-sdd/SKILL.md` → 1.
- [x] 3.3 `docs/field-validation.md` — #14·#45(3, 12-13 + 표 뒤 한 줄, 21, 26, 51, 72, 85줄). 확인: `command grep -c '경량 경로\|정식 경로\|③ 이후\|② 이후\|전환(③)' docs/field-validation.md` → 0, `command grep -c '경량 모드(worker → finalizer' docs/field-validation.md` → 1.
- [x] 3.4 `evals/README.md`(25줄)와 `evals/lite-path-small-task/prompt.md`(6줄) — #14. 확인: `command grep -c '경량 경로' evals/README.md evals/lite-path-small-task/prompt.md` → 둘 다 0, prompt.md frontmatter(`max_turns`, `allowed_tools`)가 그대로다.
- [x] 3.5 묶음 3에서 고친 `.md` 5개 무결성: 2.11과 같은 세 검사(`.claude/skills/init-sdd/SKILL.md`는 `name`·`description`, prompt.md는 `max_turns`·`allowed_tools` 키).

## 4. 통합 검증 (묶음 2·3 뒤)

**안전 규칙 (이 묶음의 모든 명령에 적용):**
- 셸 변수 이름은 ASCII만 쓴다(`d`, `repo`, `start_head`). 한글 변수 금지.
- 스크립트는 `set -eu`로 시작하고, 디렉터리 이동은 `cd "$d" || exit 1` 꼴로만 한다.
- 실험·사본은 **자기 세션 scratchpad 안의 `mktemp -d`** 에서만 만든다. 저장소 안에 임시 파일을 만들지 않는다.
- 저장소에서 `git reset`, `git init`, `git commit`, `git stash`, `git checkout -- .` 금지. 사본 안에서만 git을 만진다.
- 묶음 시작과 끝에 `git rev-parse HEAD`를 찍어 같은지 대조한다(1.1의 값과도 같아야 한다).

**환경 주의 (macOS):**
- 이 셸의 `grep`은 함수로 덮여 있다. 경로·개수 비교에는 반드시 `command grep`을 쓴다.
- 한글이 든 패턴을 awk로 다룰 때는 `LC_ALL=C awk ...`.
- 빈 glob이 될 수 있는 패턴(`openspec/changes/*/tasks.md` 등)은 `bash -c '...'` 안에서 돌린다(zsh는 빈 glob에서 에러).
- macOS `wc -l` 출력에는 앞 공백이 붙는다. 비교 전에 `tr -d ' '`로 지운다.
- `grep -c`는 0건이면 종료코드 1이다. `set -eu` 안에서 0이 기대값이면 `n=$(command grep -c ... || true)`로 받는다.

- [x] 4.1 change 검증 두 게이트: `./bin/sdd-openspec validate audit-specs-and-docs --strict; echo "exit=$?"` → exit=0, `openspec validate audit-specs-and-docs --strict; echo "exit=$?"`(PATH 1.12.0) → exit=0, `./bin/sdd-openspec status --change audit-specs-and-docs --json >/dev/null; echo "metadata exit=$?"` → 0. 출력을 그대로 보고서에 붙인다.
- [x] 4.2 sync 모의(받아들일 조건 1·3·4): scratchpad `mktemp -d` 사본 `d`에 `cp -R <저장소 절대경로>/openspec "$d/"` 후 `rm -rf "$d/openspec/changes/plugin-lite-sdd-distribution"`(이 시점 저장소 `openspec/specs/`는 sync 전이라 작업트리 복사로 된다), `cd "$d" || exit 1` 뒤 사본에서 `<저장소 절대경로>/bin/sdd-openspec archive audit-specs-and-docs --yes; echo "exit=$?"` → 0. 이어서 사본에서 같은 `<저장소 절대경로>/bin/sdd-openspec`으로 (a) `validate --all --strict` → exit=0, (b) 모든 spec의 `show <전체 id> --type spec --json --no-scenarios`(전체 id = `openspec/specs/` 아래 경로, 예: `agent-instructions/lite-default-path`. 목록은 `cd "$d/openspec/specs" && find . -name spec.md | sed 's|^\./||; s|/spec\.md$||'`)에서 `requirements[].text` 길이 500 초과 0개(`jq -r '.requirements[] | select((.text|length) > 500) | .text[0:40]'` 출력 0줄), (c) `cat "$d"/openspec/specs/*/*/spec.md | command grep -c '^#### Scenario:'` → 238(파일별 개수가 아니라 합계 한 줄. 저장소 쪽 지금 값 220보다 크다), (d) design.md 결정 2 표의 지운 헤더 9개가 사본 메인 spec에 0건이고 새 헤더가 모두 있다. 수치를 보고서에 적는다.
- [x] 4.3 발견 목록 grep 대조(받아들일 조건 5·6): 저장소에서 `command grep -rn 'example-run' openspec/specs` → 0건, `command grep -rn 'orca/projects' openspec/specs` → 0건은 **sync 뒤 finalizer 몫**이므로 여기서는 4.2 사본 `"$d"/openspec/specs`에 대해 돌려 0건임을 확인한다. 같은 사본에서 `command grep -n '유일한 수단' "$d"/openspec/specs/distribution/sdd-install-script/spec.md` → 0건, `command grep -rn '5종을 말한다\|7종을 본다\|실행 불가 시점\|관문 1.3' "$d"/openspec/specs` → 0건.
- [x] 4.4 지시문·문서가 메인 spec 시나리오를 깨지 않았는지(델타 반영 뒤 기준): `command grep -rlE '^순서: ' --exclude-dir=openspec --exclude-dir=.git .` → `./.claude/CLAUDE.md` 한 줄, `command grep -rnE "skills/openspec-|openspec-(explore|propose|apply-change|archive-change|sync-specs|update-change)" agents skills/orchestra skills/sdd-rules skills/sdd-sync` → 0건, `command grep -c 'allowed-tools: Bash(openspec:' agents/preparer.md agents/designer.md agents/worker.md agents/finalizer.md agents/analyzer.md` → 모두 0, 7개 에이전트의 `tools:` 줄에 `Agent`가 있고 `model:` 줄이 하나씩 있다.
- [x] 4.5 플러그인 검증: `claude plugin validate . --strict; echo "exit=$?"`와 `claude plugin validate .claude-plugin/plugin.json --strict; echo "exit=$?"` → 둘 다 exit=0.
- [x] 4.6 범위 밖과 HEAD(받아들일 조건 9): `git diff --stat 5df62b21b69a7a5e07396552373fa7eef10cb731 -- bin hooks install.sh .claude-plugin` → 빈 출력, `git rev-parse HEAD`가 1.1 값과 같다, `git status --short`에 나오는 파일이 묶음 2·3의 15개 파일과 `openspec/changes/audit-specs-and-docs/`뿐이다(`openspec/specs/` 변경 0).

## Workflow follow-up

- finalizer가 design.md "결정 8" 블록을 따른다: ① change 산출물 → ② 지시문 → ③ 문서 커밋, ④ sync(Purpose 갱신 목록 포함) 뒤 저장소에서 `./bin/sdd-openspec validate --all --strict` exit=0 확인 후 커밋.
- 사용자가 승인하면 ⑤ `sdd-openspec archive audit-specs-and-docs --yes`로 archive하고 커밋한다(손 sync 뒤라 "Specs already in sync"가 나와야 한다).
- `git log --stat`으로 다섯 커밋이 단위별로 나뉘었는지 확인한다(받아들일 조건 8).
- 후속 change 후보로 남긴 것: #26(훅 권한 점검 범위), #27(install.sh 버전 안내), #48(eval `allowed_tools`).
