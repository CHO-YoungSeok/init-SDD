# Proposal

## Why

③ `convert-to-plugin`으로 저장소 루트가 플러그인 `sdd`의 루트가 됐지만, 이 저장소의 **개발 환경과 문서는 아직 복사 방식 시절 모양**이다.

- `README.md`는 ③에서 절을 덧댄 것이라 순서가 섞여 있다. 소개 문단(5행)은 "`.claude/`의 에이전트를 얹는다"로 시작한다.
  "단계 늘리기 — `.claude/agents/`에 파일 추가"(302행)와 번역 안내(340행)는 복사 방식 경로를 쓴다.
  344~352행은 이 저장소에 `openspec-*` 스캐폴드가 있다고 전제한다(③ 리뷰 참고 5).
  regression-verifier가 붙는 조건을 "테스트가 있을 때"로 줄여 적어서, 정본인 orchestra의 세 조건(큰 작업 + 실행 코드 변경 + 테스트 명령)과 다르다(② 리뷰 참고 1).
- `.claude/CLAUDE.md`는 ③에서 4줄짜리 개발자 안내만 덧붙였다. 저장소 구조, 검증 명령, 커밋 규칙이 없다.
- `openspec/config.yaml`의 `context:`는 ③ 이전 사실을 말한다. 경로가 `.claude/agents/*.md`, `.claude/skills/**/SKILL.md`이고,
  "실행 코드가 없다", "검증 수단은 `bash -n install.sh`·dry-run·OpenSpec CLI·grep **뿐**"이라고 적혀 있다.
  지금은 bash 실행 파일(`bin/sdd-openspec`, `bin/sdd-init`, `hooks/session-start.sh`)이 있고, `claude plugin validate`가 검증 수단에 들어간다.
  모든 에이전트가 이 context를 제약으로 받으므로 틀린 사실이 매 change에 퍼진다.
- 필요 없는 파일이 남아 있다. git이 무시하는 `openspec init` 스캐폴드(`.claude/skills/openspec-*` 6개, `.claude/commands/opsx/` 6개)는 ②부터 파이프라인이 쓰지 않는다.
  그런데도 이 저장소 세션에서 스킬·명령으로 실린다. sdd-rules는 "부르지도 읽지도 않는다"고 하는데 목록에는 계속 보인다.

사용자 요청: "이 프로젝트에도 그 구조를 적용시켜. 필요 없는 부분은 지우고. spec을 작성하고 검토 후 진행. `claude.md`, `readme.md`를 변화에 맞게 작성. 커밋은 작업 단위별로."
최상위 목표("openspec + orchestra 구조를 어떤 프로젝트에도 빠르게 적용")에 맞춰, 처음 오는 사람이 README만 읽고 플러그인으로 시작할 수 있게 하고,
이 저장소 자신도 그 구조로 깔끔하게 돌게 한다. 상위 기록 `plugin-lite-sdd-distribution` 다음 단계(⑤)다.

## What Changes

1. **필요 없는 파일 정리** — 아래 표의 "지운다" 항목만 지운다.
2. **`.claude/CLAUDE.md` 표식 구획 밖 다시 쓰기(구획 밖 영역을 Edit로 교체)** — 이 저장소 개발자가 일할 때 필요한 지침:
   - 저장소 구조: 플러그인 루트, `agents/`, `skills/`, `bin/`, `hooks/`, `.claude-plugin/`, `openspec/`, 기존 설치 방식 파일
   - 개발 실행: `claude --plugin-dir .`
   - 이 저장소도 SDD로 개발한다: 작은 작업·큰 작업 흐름은 표식 구획과 orchestra를 가리킨다
   - 검증 명령: `claude plugin validate . --strict`, `claude plugin validate .claude-plugin/plugin.json --strict`,
     `./bin/sdd-openspec validate "<이름>" --strict`, `bash -n`(대상: `install.sh`, `bin/*`, `hooks/*.sh`), 마크다운 무결성
   - 커밋 규칙: 작업 단위별로 나눈다
   - 표식 구획(`<!-- init-SDD:begin/end -->`)의 성격: 기존 설치 방식의 조각 원본이다. 안의 경로는 설치 대상 기준이다
3. **표식 구획 안** — 계약(아래 "지켜야 할 spec 계약")을 지킨다. regression-verifier 조건 문구만 정본과 어긋나지 않게 고친다(가정 A3).
4. **`README.md` 다시 짜기** — 플러그인 우선 순서로 절을 옮기고 고친다. 방법은 **절 단위 Edit를 위에서부터** 한다(전체 Write 재작성 금지 — 아래 계약의 `analyzer-option-generation` "지침 문서 수정은 파일을 손상시키지 않아야 한다"):
   1. 무엇인가(한 문단)
   2. 빠른 시작: 설치 두 줄 + `/sdd:init`
   3. 이게 왜 필요한가
   4. 작동 방식: 작은/큰 작업 경로, 사용자 개입 지점, 에이전트 표, code-explorer, 만들어지는 파일
   5. 훅·권한·업데이트·팀 배포·Windows
   6. 기존 설치 방식(`install.sh`, `init-sdd`) — 폐기 예고, 고르는 표, 이전 안내
   7. 커스터마이즈(플러그인 경로 기준)
   8. 알아 둘 것
   9. 개발

   ③ 리뷰 참고 5와 ② 리뷰 참고 1을 반영한다.
5. **`openspec/config.yaml` `context:` 갱신** — ③ 이후 사실에 맞춘다:
   - 플러그인 레이아웃 경로
   - bash 실행 파일이 있지만 테스트 스위트·빌드·CI는 없다는 것
   - 검증 수단에 `claude plugin validate` 두 명령과 `bin/`·`hooks/` 스크립트의 `bash -n`을 더한다
   - 기존 항목(한국어·쉬운 말, Edit 부분 수정만)은 유지한다
6. **spec 델타** — `agent-instructions/project-context-completeness`의 "context에 담을 최소 내용" 요구를 위 사실에 맞게 MODIFIED한다.
   README·CLAUDE.md 고쳐 쓰기는 기존 요구사항을 바꾸지 않는다(아래 계약을 그대로 지킨다).

### 필요 없는 부분 전수 조사 (지울지/둘지)

| 경로 | 추적 | 판정 | 근거 |
|---|---|---|---|
| `.claude/skills/openspec-apply-change/`, `openspec-archive-change/`, `openspec-explore/`, `openspec-propose/`, `openspec-sync-specs/`, `openspec-update-change/` | 무시됨(미추적) | **지운다** | ②부터 파이프라인이 안 쓴다(sdd-rules). 이 저장소 세션에 스킬로 실려 헷갈린다. README 344~352행이 이것을 전제로 해서 README 고쳐 쓰기와 함께 정리한다. `openspec init --tools claude`로 언제든 다시 생긴다 |
| `.claude/commands/opsx/`(6개) 와 빈 부모 `.claude/commands/` | 무시됨(미추적) | **지운다** | 같은 이유. README "알아 둘 것"이 "직접 쓰면 결정 기록과 리뷰가 사라진다"고 경고하는 그 명령이다 |
| `.gitignore`의 `.claude/skills/openspec-*/`, `.claude/commands/opsx/` 줄 | 추적 | 둔다 | 누가 `openspec init --tools claude`를 다시 돌려도 커밋되지 않게 막는 장치다 |
| `.agents/skills/claude-handoff/` | 추적 | 둔다 | SDD와 무관. ①에서 "지우지 않고 안내만"으로 정했고(상위 decision 핵심 결정 2), 안내는 그 폴더 README 첫 줄에 있다 |
| `.agents/skills/`(빈 디렉터리) | — | 해당 없음 | 지금은 비어 있지 않다(`claude-handoff`가 있다). `find . -type d -empty`(`.git` 제외) 결과 0건 |
| `install.sh`, `.claude/skills/init-sdd/` | 추적 | 둔다 | 사용자 결정: 실전 검증 뒤 제거 |
| `.claude/settings.json` | 추적 | 둔다 | `install.sh` 복사 원본, `/sdd:init` 권한 목록 원본(`bin/sdd-init` `list_permissions`), 이 저장소 개발 권한을 겸한다 |
| `docs/field-validation.md` | 추적 | 둔다 | 메인 spec `process/field-validation-record`가 요구한다 |
| `evals/` | 추적 | 둔다 | 같은 spec이 요구한다 |
| `bin/sdd-init`, `bin/sdd-openspec`, `hooks/`, `.claude-plugin/`, `agents/`, `skills/` | 추적 | 둔다 | 플러그인 본체 |
| `openspec/.sdd` | 추적 | 둔다 | 이 저장소의 훅 표식(메인 spec `session-start-hook`, ③ 받아들일 조건) |
| `LICENSE` | 추적 | 둔다 | — |

지우는 두 항목은 git이 무시하는 미추적 파일이다. 그래서 `git rm` 대상이 아니고 커밋 diff에도 나오지 않는다.
삭제는 되돌릴 수 없는 일이므로 tasks에 **경로를 글자 그대로** 적고, 오케스트레이터가 정리 모드 worker에게 맡긴다.
경로는 이 7개다: `.claude/skills/openspec-apply-change`, `.claude/skills/openspec-archive-change`, `.claude/skills/openspec-explore`,
`.claude/skills/openspec-propose`, `.claude/skills/openspec-sync-specs`, `.claude/skills/openspec-update-change`, `.claude/commands`.

## 지켜야 할 spec 계약 (고쳐 쓰기가 깨면 안 되는 메인 spec 요구사항)

`grep -rn 'README\|CLAUDE\.md' openspec/specs`로 전수 조사했다.

**`README.md`**
- `distribution/sdd-plugin`
  - 설치 두 줄(`/plugin marketplace add`, `/plugin install sdd@sdd-marketplace`), `/sdd:init`, `claude --plugin-dir .`
  - 기존 방식에서 이전하는 안내
  - `.claude/commands/opsx/`·`.claude/skills/openspec-*`가 필요 없다는 안내
  - 업데이트 절차 단락, `extraKnownMarketplaces`·`enabledPlugins` 팀 배포 단락, Windows bash 한 줄
- `distribution/session-start-hook`: `openspec/.sdd`가 훅을 켠다는 설명, 표식 삭제·`/plugin disable sdd`로 끄는 법, 커밋하면 팀원에게도 켜진다는 사실
- `distribution/sdd-install-script`
  - `## 설치` 절 맨 앞에 세 방식(플러그인 권장이 먼저, 복사 `install.sh`, 링크 `init-sdd`)을 고르는 표
  - "방법 1 — install.sh"·"방법 2 — 손으로"가 남는다
  - 복사 흐름(복제 → 이동 → `bash install.sh` → `CLAUDE.md` 합쳐졌는지 확인 → 새 세션), `--dry-run`
  - `openspec-*`·`opsx/`는 복사하지 말고 `openspec init`이 깔게 하라는 경고
  - 제품 설명·손 설치 복사 명령·"설치 확인"에 `orchestra`·`sdd-rules`·`sdd-sync`가 있고 다른 스킬은 없다. 설치 확인이 `openspec-*` 6개를 필수로 요구하지 않는다
  - 이미 설치한 프로젝트 안내(두 스킬 새로 넣기, 에이전트 파일을 새 판과 비교해 옮기기, `install.sh` 재실행으로는 안 바뀐다, 남은 모델 등급 스킬은 지워도 된다)
  - `순서:` 줄과 조각 코드블록을 싣지 않고, 마커 구획을 `sed`로 뽑아 붙이는 방법을 적는다
  - 설치 안내 본문은 README 한 곳에만 둔다
- `distribution/init-sdd-skill`: 고르는 안내 본문이 README에 있다(스킬이 가리킨다)
- `agent-instructions/analyzer-option-generation`
  - "이게 왜 필요한가" 절: 관문을 강제로 적지 않는다. 원할 때 열 수 있다. 작은 작업 개입 지점(범위 밖 확인, 리뷰, 커밋 관문)과 큰 작업에 더해지는 결정 기록(설계 요약 알림)을 나눠 적는다
  - "일의 크기에 따라 경로가 갈린다" 표와 "반드시 답해야 하는 지점" 목록: 기본 경로에 analyzer가 없고 호출 횟수가 맞으며, 방안 선택은 analyzer를 불렀을 때 열리는 지점이다
  - 에이전트 표의 analyzer 설명이 "코드베이스 분석, 방안 최소 3가지 + 의견과 근거"이고 옵트인 표시가 있다. "평가 모드" 문구가 없다
  - 파이프라인 두 경로의 순서가 orchestra·`.claude/CLAUDE.md`와 같다
- `agent-instructions/code-explorer-role`: code-explorer를 7개 표 **밖의** 보조 에이전트로 설명한다. 모델 등급 스킬 언급이 없다
- `agent-instructions/openspec-metadata-marker-safety`: 산출물 표의 `.openspec.yaml` 줄이 "`new change`가 만들고 에이전트는 마커를 덧붙인다"를 드러낸다

**README·`.claude/CLAUDE.md`·`openspec/config.yaml` 공통**
- `agent-instructions/analyzer-option-generation` "지침 문서 수정은 파일을 손상시키지 않아야 한다": 이미 있는 지침·문서 파일은 전체 재작성하지 않고 부분 수정한다(SHALL).
  적용 범위가 "그 변경이 수정한 지침 파일과 문서 파일 전부"라 이 change가 고치는 세 파일 모두에 걸린다. 끝난 뒤 리치 마크다운 토큰 0·코드펜스 짝수(MUST)

**`.claude/CLAUDE.md`**
- `distribution/sdd-plugin`: `claude --plugin-dir .`와 "이 저장소도 SDD로 개발한다"가 있다. `<!-- init-SDD:begin -->`·`<!-- init-SDD:end -->`가 각각 한 번. 루트 `CLAUDE.md`는 없다
- `distribution/sdd-install-script`: `openspec/` 밖에서 `^순서:` 줄을 가진 파일은 `.claude/CLAUDE.md` 하나뿐이다. 구획을 `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p'`로 뽑을 수 있다
- `agent-instructions/analyzer-option-generation`: 구획 안 두 경로 순서가 orchestra·README와 같다
- `distribution/init-sdd-skill`: 원본 탐색 조건 `install.sh` + `.claude/CLAUDE.md`를 유지한다(위치를 옮기지 않는다)

## 받아들일 조건

모든 명령은 저장소 루트에서 돌리고 종료코드로 판정한다.

**정리**
- [ ] `ls -d .claude/skills/openspec-* .claude/commands 2>/dev/null | wc -l` → 0
- [ ] `git status --short`에 삭제 때문에 생긴 줄이 없다(무시된 파일이었으므로). `git ls-files .claude` 출력이 `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/skills/init-sdd/SKILL.md` 세 줄 그대로다
- [ ] `.gitignore`에 `.claude/skills/openspec-*/`와 `.claude/commands/opsx/` 줄이 남아 있다(`grep -c` 각 1)
- [ ] `test -f install.sh && test -f .claude/skills/init-sdd/SKILL.md && test -d .agents/skills/claude-handoff && test -f docs/field-validation.md; echo $?` → 0

**`.claude/CLAUDE.md`**
- [ ] `test -e CLAUDE.md; echo $?` → 1, `test -f .claude/CLAUDE.md; echo $?` → 0
- [ ] `grep -c '<!-- init-SDD:begin -->' .claude/CLAUDE.md` → 1, `grep -c '<!-- init-SDD:end -->' .claude/CLAUDE.md` → 1
- [ ] `grep -c 'claude --plugin-dir \.' .claude/CLAUDE.md` ≥ 1, "SDD로 개발" 문구가 있다
- [ ] 구획 밖에 아래가 모두 있다(각각 `grep -c` ≥ 1)
  - `claude plugin validate . --strict`
  - `claude plugin validate .claude-plugin/plugin.json --strict`
  - `sdd-openspec validate`
  - `bash -n`
  - 커밋을 작업 단위로 나눈다는 규칙
  - `agents/`, `skills/`, `bin/`, `hooks/`, `.claude-plugin/` 구조 설명
- [ ] `command grep -rl --exclude-dir=.git --exclude-dir=openspec '^순서:' .` → `./.claude/CLAUDE.md` 한 줄뿐 (이 환경의 `grep`은 ugrep 래퍼라 `./`를 붙이지 않으므로 `command grep`으로 돌린다)
- [ ] 구획 안 순서 줄 두 개가 orchestra frontmatter 경로와 같다
  - 작은: `preparer` → `worker` → `reviewer` → `finalizer`
  - 큰: `preparer` → `designer` → `worker` → `reviewer` + `regression-verifier`(조건부, 동시) → `finalizer`
  - 구획 안에 `analyzer`가 기본 단계로 없다
- [ ] 빈 `mktemp -d` 임시 프로젝트(커밋 하나)에서 아래를 확인한다
  - `bash install.sh --dry-run` → exit 0
  - 실제 `bash install.sh` 뒤 대상 `CLAUDE.md`의 구획과 이 저장소 `.claude/CLAUDE.md`의 구획을 `diff` → rc=0
- [ ] 새 `claude -p --plugin-dir .` 프로세스가 `.claude/CLAUDE.md` 구획 밖에만 있는 새 문장 하나를 파일 읽기 도구 없이 인용한다(지침이 실린다)

**`README.md`**
- [ ] 위 "지켜야 할 spec 계약 — README" 항목을 하나씩 grep으로 대조해 전부 있다. 최소한 각 `grep -c` ≥ 1:
  - `/plugin marketplace add`, `/plugin install sdd@sdd-marketplace`, `/sdd:init`, `claude --plugin-dir .`
  - `.claude/commands/opsx/`, `.claude/skills/openspec-*`
  - `extraKnownMarketplaces`, `enabledPlugins`, `/plugin disable sdd`, `openspec/.sdd`, `Windows`
  - `install.sh --dry-run`, `init-sdd`, `sdd-rules`, `sdd-sync`, `code-explorer`, `.openspec.yaml`
  - `## 설치`, `이게 왜 필요한가`, `일의 크기에 따라 경로가 갈린다`, `방법 1 — install.sh`, `방법 2 — 손으로`, `설치 확인`
- [ ] `grep -c '^순서:' README.md` → 0, `grep -c '평가 모드' README.md` → 0, `grep -ci 'agent-model-tier' README.md` → 0
- [ ] 복사 방식 시절 경로 표현이 없다
  - 소개 문단이 플러그인 기준이다(`.claude/`의 에이전트를 얹는다는 서술 없음)
  - "단계 늘리기"·번역 안내가 `agents/`·`skills/` 기준이다
  - `grep -n 'grep generatedBy' README.md` → 0건
  - 이 저장소에 `openspec-*` 사본이 있다는 서술이 없다
  - `.claude/agents/`는 복사·링크 방식 설명 안에서만 쓰인다
- [ ] regression-verifier 조건을 적은 곳은 정본(orchestra)과 같은 세 조건으로 적거나 orchestra를 가리킨다. "테스트가 있을 때"만으로 줄여 쓴 곳이 없다
- [ ] 첫 화면 순서: 소개 한 문단 → 빠른 시작(설치 두 줄 + `/sdd:init`)이 `## 설치`의 고르는 표·기존 방식보다 앞에 나온다.
  단, `## 설치` 절 맨 앞에 고르는 표가 있어야 한다는 계약은 지킨다. 빠른 시작을 `## 설치` 안 첫머리에 둘지 별도 절로 둘지는 designer가 정한다

**config.yaml / spec**
- [ ] `./bin/sdd-openspec instructions proposal --change apply-plugin-to-self --json`의 `context`에 아래가 있다
  - `agents/`, `skills/`, `claude plugin validate`, `bash -n`, 한국어·쉬운 말, Edit 부분 수정
  - `.claude/agents/*.md`라는 옛 경로가 없다
- [ ] `./bin/sdd-openspec context` 출력에 `Warning: could not parse`가 없다
- [ ] 델타 `agent-instructions/project-context-completeness`(MODIFIED)가 있다. `./bin/sdd-openspec validate apply-plugin-to-self --strict` → exit 0

**공통**
- [ ] `claude plugin validate . --strict` → 0, `claude plugin validate .claude-plugin/plugin.json --strict` → 0
- [ ] `bash -n install.sh bin/sdd-init bin/sdd-openspec hooks/session-start.sh` 각각 rc=0. `CLAUDE_PROJECT_DIR="$PWD" bash hooks/session-start.sh` → exit 0이고 `[SDD 점검] 이상 없음`
- [ ] 수정·새로 만든 `.md` 전부: 리치 마크다운 토큰 0, 코드펜스 줄 수 짝수, frontmatter 온전
- [ ] 커밋을 작업 단위로 나눈다(finalizer). 예: 정리(커밋 없음 — 무시된 파일) / config+spec / `.claude/CLAUDE.md` / README / change 산출물

## 범위 밖

- spec·문서 전수 검수, 긴 요구사항(>500자) 분할 — ⑥ `audit-specs-and-docs`.
  지금 `./bin/sdd-openspec validate --all --strict`가 긴 요구사항 경고로 exit 1이다(기준선). 이번 change가 그 수를 늘리지만 않으면 된다
- 메인 spec `analyzer-option-generation`이 가리키는 없는 파일 `docs/example-run.md` 정리 — ⑥
- `install.sh`, `init-sdd` 삭제(실전 검증 뒤)
- 실전 측정(`plugin eval` 점수, 실제 프로젝트 작업)
- 에이전트·스킬 지시문(`agents/`, `skills/`) 내용 변경과 `bin/`·`hooks/` 동작 변경
- 상위 기록 `plugin-lite-sdd-distribution`의 tasks 체크와 archive
- 공식 마켓플레이스 등록
- `.claude/settings.json` 권한 항목 변경(가정 A4)

## 가정 (사용자 위임으로 preparer가 정한 추천 기본값 — designer가 근거를 들어 뒤집을 수 있다)

- **A1 브랜치:** 새로 만들지 않고 `plugin-lite-sdd-distribution`에서 이어 간다(오케스트레이터 지시).
- **A2 스캐폴드 삭제:** 무시된 스캐폴드 12개 파일(7개 경로)을 지운다. `.gitignore` 줄은 남긴다.
  이 저장소에서 `/opsx:*` 명령과 `openspec-*` 스킬이 사라지며, 필요하면 `openspec init --tools claude`로 다시 만든다(오케스트레이터 결정: 사용자 "필요 없는 부분은 지워라").
  README의 "필요 없다(지워도, 남겨도 된다)" 안내는 그대로 맞다.
- **A3 표식 구획 안 수정 범위:** 구획 안은 기존 설치 방식 사용자에게 붙는 조각이라 되도록 손대지 않는다.
  다만 regression-verifier 괄호 "(테스트가 있을 때, 동시)"는 정본과 어긋나서(② 리뷰 참고 1) "(조건부, 동시)"처럼 정본을 가리키는 꼴로 고친다.
  구획 안 `.claude/agents/`, `.claude/skills/orchestra/SKILL.md` 경로는 설치 대상 기준이라 그대로 둔다.
  템플릿 안내 주석(구획 밖)은 고쳐 쓸 때 남길지 designer가 정한다.
- **A4 `.claude/settings.json`:** `Bash(sdd-init:*)`를 더하지 않는다.
  - 이 파일은 `/sdd:init`이 사용자 프로젝트에 쓰는 권한 목록의 원본이기도 하다. 더하면 `sdd-init-command` 동작이 바뀐다.
  - 이 저장소는 이미 초기화돼 있다(`openspec/.sdd`).
  - `--plugin-dir .`로 띄우면 `sdd-openspec`이 PATH에 있어 기존 `Bash(sdd-openspec:*)`로 충분하다.
- **A5 config.yaml context는 spec 변경이다:** 메인 spec `project-context-completeness`가 "검증 수단은 … 뿐"과 "실행 코드가 없다"를 **요구사항 글자로** 정한다.
  그래서 context만 고치면 spec과 어긋난다. MODIFIED 델타로 함께 바꾼다(요구사항 헤더는 그대로). README·CLAUDE.md 고쳐 쓰기는 동작 변경이 아니므로 델타를 만들지 않는다.
- **A6 README 고쳐 쓰기 방식:** Write로 새로 쓰지 않고 **절 단위 Edit로 위에서부터** 바꾼다(design.md D4 "Edit 순서" E1~E6).
  메인 spec `analyzer-option-generation` "지침 문서 수정은 파일을 손상시키지 않아야 한다"가 이미 있는 지침·문서 파일의 전체 재작성을 막고,
  적용 범위가 그 변경이 수정한 지침·문서 파일 전부라 README도 들어간다(설계 검토 반려 사항 반영).
  절을 옮기는 곳은 새 자리 Edit 삽입 → 옛 자리 Edit 삭제로 하고, `git show HEAD:README.md` 원문과 `diff`로 계획한 차이만 남았는지 본다. 끝난 뒤 무결성 검사와 계약 grep을 반드시 돌린다.
- **A7 README 원격 주소:** 지금 쓰는 `CHO-YoungSeok/init-SDD`를 그대로 쓴다.
- **A8 커밋 단위:** finalizer가 작업 단위별로 나눠 커밋한다.

## Capabilities

### New Capabilities
(없음)

### Modified Capabilities
- `agent-instructions/project-context-completeness`: "config.yaml의 context에 프로젝트 사정이 채워져 있어야 한다"가 context에 담을 최소 내용을 플러그인 전환 뒤 사실로 바꾼다.
  - "실행 코드가 없는 지시문 저장소" → 지시문 저장소이고 실행 파일은 bash 스크립트뿐
  - "검증은 `bash -n install.sh`·dry-run·OpenSpec CLI·grep뿐" → 여기에 `claude plugin validate` 두 명령과 `bin/`·`hooks/` 스크립트의 `bash -n`을 더한다
  - 지시문 경로는 플러그인 레이아웃(`agents/`, `skills/`) 기준으로 적는다

## Impact

- 수정(모두 Edit 부분 수정): `.claude/CLAUDE.md`(구획 밖 교체, 구획 안은 A3 범위만), `README.md`(절 단위 Edit로 재배치·수정), `openspec/config.yaml`(`context:`만)
- 삭제(미추적·무시된 파일, 정리 모드): 위 7개 경로
- 델타: `openspec/changes/apply-plugin-to-self/specs/agent-instructions/project-context-completeness/spec.md`(designer)
- 바뀌지 않는 것: `agents/`, `skills/`, `bin/`, `hooks/`, `.claude-plugin/`, `install.sh`, `.claude/skills/init-sdd/`, `.claude/settings.json`, `.gitignore`
- 영향받는 사람:
  - 기존 복사·링크 설치 사용자는 다음 설치 때 조각의 regression-verifier 괄호 문구 하나만 달라진다(A3)
  - 이 저장소 세션에서는 `openspec-*` 스킬과 `/opsx:*` 명령이 더 이상 보이지 않는다. 필요하면 `openspec init --tools claude`로 다시 만든다
