> 상위 change: `plugin-lite-sdd-distribution` 의 하위 change ② (순서 ① → ④ → **②** → ③).
> 범위·결정의 근거: 상위 change의 `decision.md`, `proposal.md`, `analysis.md` (Q1~Q3, Q6).

## Why

작은 일에도 designer부터 거치게 되어 있고, 같은 규칙이 에이전트마다 되풀이되며,
에이전트가 OpenSpec 스캐폴드 SKILL.md 6개를 Read하도록 짜여 있어 그 파일이 사라지면 파이프라인이 멈춘다.
이 세 가지가 "어느 프로젝트에든 빠르게 적용"을 막는다. ③(플러그인 전환) 전에 지시문 구조부터 가볍게 한다.

현재 값 (2026-10-08 실측):
- 지시문 2,823줄 (에이전트 8개 1,680 + orchestra 459 + init-sdd 541 + agent-model-tier 143).
- 에이전트마다 되풀이되는 절(쓰는 스킬·allowed-tools 이유 / 대화형 스킬 / store 처리 / code-explorer 부르기 / 되돌릴 수 없는 일) 약 250줄.
- orchestra `.claude/skills/orchestra/SKILL.md` 443-447: "designer를 생략하면 안 된다". 작업 목록(tasks.md)을 designer만 만들기 때문이다.
- 에이전트 frontmatter `skills: [openspec-…]` 가 5개 파일에 6개 항목. 지시문 안의 `openspec-*` 스킬 참조가 43곳.
- CLI 실측(scratch 프로젝트): 1.12.0 / 1.14.1 모두 `proposal.md + tasks.md` 만 있으면 apply 가능하고,
  `instructions design` 에 design.md 생성 조건 4가지가 같은 문구로 들어 있다. 로컬 CLI는 1.12.0.
- 메인 spec의 `.claude/` 경로 112곳 (`grep -o` 합계, 상위 decision의 94는 그 뒤 spec 추가분이 빠진 값).

## What Changes

**1. 경량 기본 경로** (조건: 아래 "큰 작업" 이 아닐 때)
- 기본 경로: `preparer(proposal + tasks + 필요 시 작은 델타 또는 skip_specs) → worker → reviewer(테스트 1회 포함) → 커밋 관문 → finalizer`.
- tasks.md는 preparer가 쓴다 (`openspec instructions tasks` 지시를 따른다).
  동작이 바뀌면 작은 specs 델타까지, 안 바뀌면 `skip_specs: true`.
- **큰 작업** 판정 = `openspec instructions design` 의 design.md 생성 조건 4가지 중 하나라도 해당
  (여러 모듈에 걸침/새 패턴, 새 외부 의존/데이터 모델 큰 변경, 보안·성능·마이그레이션 복잡도, 코딩 전에 기술 결정이 필요한 모호함)
  또는 사용자의 분석 요청. 큰 작업일 때만 analyzer / designer / regression-verifier를 켠다 (지금 기본 경로가 큰 작업 경로가 된다).
- preparer가 RESULT `준비완료` 줄에 `size=작음|큼` 을 올리고 orchestra가 분기한다. 판정 기준은 orchestra 한 곳에만 적는다.
- regression-verifier는 실행 코드 + 테스트 명령이 있을 때만 켠다. 경량 경로는 reviewer가 테스트를 1회 돌린다.
- orchestra 443-447 "designer 생략 금지" 지시를 위 분기에 맞게 바꾼다.

**2. 공용 규칙 `sdd-rules` 스킬**
- 반복 절 7종(쓰는 스킬·allowed-tools 이유 / 대화형 스킬 / store 처리 / code-explorer 부르기 / 되돌릴 수 없는 일 /
  RESULT 한 줄 형식 공통 규칙 / Edit 부분 수정 규칙)을 `.claude/skills/sdd-rules/SKILL.md` 한 곳으로 모은다.
- 에이전트 frontmatter `skills:` 로 주입한다. 에이전트 본문에는 역할만 남긴다 (역할별 RESULT 필드는 에이전트에 남긴다).
- 에이전트·스킬 이름과 경로 참조, code-explorer 절을 sdd-rules 로 모아 ③의 수정 지점을 줄인다. 경로 일괄 치환은 하지 않는다 (③ 몫).

**3. 스캐폴드 SKILL.md 6개 의존 제거**
- 에이전트·orchestra가 `.claude/skills/openspec-*/SKILL.md` 를 Read하는 구조를 없애고 `openspec instructions <artifact>` 출력만 따른다.
- sync 절차만 요약해 `.claude/skills/sdd-sync/SKILL.md` 로 내장한다. archive는 `openspec archive --yes`(사용자 승인 뒤). explore 의존은 삭제.
- frontmatter `skills: [openspec-…]` 5곳(6개 항목)을 걷어낸다.
- 1.14.1 기준 `instructions` 동작을 전제로 쓴다. CLI 고정(`bin/sdd-openspec`)은 ③.

**4. 따라 바뀌는 설치·문서** (안 하면 설치본에서 파이프라인이 깨진다)
- `install.sh`, `init-sdd` 스킬: 복사·링크 목록에 `sdd-rules`, `sdd-sync` 추가, "openspec 공식 스킬 6개 존재 확인"을 필수에서 뺀다.
- `CLAUDE.md` 조각의 순서 문장, `README.md` 의 기본 경로·설치 확인·`openspec-*` 의존 서술을 새 경로에 맞춘다.

**BREAKING:** 기본 경로가 designer·regression-verifier를 건너뛴다. 큰 작업은 이전과 같은 경로를 탄다.
이미 설치한 프로젝트는 `sdd-rules`·`sdd-sync` 스킬이 없으면 에이전트가 규칙을 못 받는다. `install.sh`는 이미 있는 에이전트 파일을 건너뛰므로,
두 스킬을 추가하고 에이전트 파일을 새 판과 비교해 옮겨야 한다 (설치본 안내에 적는다).

## 범위 안 / 범위 밖

범위 안: 위 What Changes 1~4, 영향받는 메인 spec 델타, 줄 수 측정과 보고.

범위 밖:
- 플러그인 파일(`.claude-plugin/`, `agents/`·`skills/` 이동, `hooks/`, `bin/`, `/sdd-init`) — ③
- agent-model-tier 삭제 — ③ (②에서는 줄 수 합계에 그대로 포함)
- `.claude/` 경로 일괄 치환과 이름 접두사(`sdd:`) 변경 — ③
- 에이전트 업무 로직 재설계. 역할은 그대로 두고 중복 제거와 분기만 한다.
- CLI 1.14.1 고정 래퍼. 실제 프로젝트 측정 실행.

## 받아들일 조건

경로는 모두 저장소 루트 기준. "에이전트 8개" = `.claude/agents/*.md`.

경량 경로·분기
- [ ] `grep -n "size=" .claude/agents/preparer.md` 에 `size=작음|큼` 이 RESULT `준비완료` 줄 형식으로 있다.
- [ ] orchestra에 "큰 작업" 판정 절이 **한 곳**에 있고 design 조건 4가지와 "분석 요청"이 모두 적혀 있다.
      `grep -c "큰 작업" .claude/skills/orchestra/SKILL.md` 가 1 이상이며 다른 에이전트 파일에는 판정 기준 문장이 없다 (preparer는 판정 절차를 따르되 기준 4가지 문장은 orchestra를 가리킨다 — design 단계에서 위치 확정).
- [ ] `grep -n "designer를 생략하면 안 된다" .claude/skills/orchestra/SKILL.md` 결과 0건.
- [ ] 기본(작음) 경로 순서가 orchestra·CLAUDE.md·README 세 곳에서 같다 (`preparer → worker → reviewer → finalizer`, 큰 작업은 `designer`·`regression-verifier` 추가).
- [ ] regression-verifier 호출 조건(실행 코드 + 테스트 명령)이 orchestra에 적혀 있고, reviewer.md에 경량 경로 테스트 1회 지시가 있다.
- [ ] preparer.md가 tasks.md 작성(`openspec instructions tasks`)과 델타/`skip_specs` 선택을 지시한다. 마커 명령 블록(기존 키 보존·멱등·종료코드 2개 확인)은 그대로 남는다.
- [ ] mktemp 프로젝트에서 CLI로 재현: `proposal.md + tasks.md` + (a) `skip_specs: true` 또는 (b) 작은 델타로
      `openspec validate "<이름>" --strict` rc=0, `openspec instructions apply --change "<이름>" --json` 의 `state` 가 `ready`.
      로컬 1.12.0 과 `npx -y @fission-ai/openspec@1.14.1` 양쪽 결과를 보고한다.

공용 규칙·스캐폴드 의존 제거
- [ ] `.claude/skills/sdd-rules/SKILL.md`, `.claude/skills/sdd-sync/SKILL.md` 가 있고 frontmatter는 `name`·`description` 만 (`allowed-tools` 없음).
- [ ] 반복 절이 에이전트 본문에 없다: `grep -nE "^#+ (store 처리|code-explorer 부르기|대화형 스킬을 만났을 때)" .claude/agents/*.md` 0건,
      같은 절 제목이 sdd-rules 에는 각각 정확히 1번.
- [ ] 7개 에이전트(code-explorer 제외) frontmatter `skills:` 에 `sdd-rules` 가 있고 finalizer만 `sdd-sync` 도 있다.
      `grep -rnE "skills/openspec-|openspec-(explore|propose|apply-change|archive-change|sync-specs|update-change)" .claude/agents .claude/skills/orchestra .claude/skills/sdd-rules .claude/skills/sdd-sync` 0건.
      (init-sdd·agent-model-tier·README 의 "openspec-* 는 CLI가 까는 것" 설명은 대상 아님 — README 는 아래 별도 확인.)
- [ ] 스캐폴드 없이 돈다: 저장소를 mktemp에 복사해 `.claude/skills/openspec-*` 6개를 지운 사본에서
      `openspec instructions proposal|specs|design|tasks|apply --change <이름> --json` 이 모두 rc=0 이고,
      finalizer 지시의 archive 단계(`openspec archive --yes`)가 skip_specs change에서 rc=0 이다.
- [ ] sdd-sync 가 sync 절차(델타 읽기 → 메인 spec 반영 → 확인)를 담고 `openspec archive` 를 직접 돌리라고 하지 않는다 (archive는 finalizer가 사용자 승인 뒤에만).
- [ ] 새 세션에서 7개 에이전트가 sdd-rules 를 실제로 받는지 확인한 방법과 결과가 review.md 에 있다
      (frontmatter `skills:` 주입은 세션 시작 때 읽히므로 이 세션에서는 검증 불가 — 새 세션 필요).

줄 수 (기준선 2,823줄, 새 파일 포함)
- [ ] `wc -l` 합계(에이전트 8개 + orchestra + init-sdd + agent-model-tier + sdd-rules + sdd-sync)가 **2,823 미만**. 숫자를 review.md에 남긴다.
- [ ] 에이전트 8개 합계가 1,680 미만이고 **각 에이전트가 자기 기준선(analyzer 175, code-explorer 40, designer 311, finalizer 299, preparer 241, regression-verifier 148, reviewer 224, worker 242)보다 짧다** (code-explorer 는 같아도 됨).
- [ ] 목표: code-explorer ≤ 40, regression-verifier ≤ 110, analyzer ≤ 130, 나머지 4개 ≤ 200~230. 못 맞추면 파일별 실제 줄 수와 이유를 보고한다 (analysis Q6: designer·worker·finalizer·preparer는 150~200줄이 바닥).

spec·설치·무결성
- [ ] `openspec validate "lite-default-path-and-shared-rules" --strict` rc=0, `openspec status --change "lite-default-path-and-shared-rules" --json` rc=0.
- [ ] 아래 "Modified Capabilities" 의 부딪히는 요구사항이 델타로 처리됐고, 처리 안 한 것은 보류 사유가 있다.
- [ ] `bash -n install.sh` 통과. `bash install.sh --dry-run` 출력(또는 mktemp 설치)에 `sdd-rules`, `sdd-sync` 가 복사 대상으로 나온다. init-sdd 링크 목록에도 있다.
- [ ] 수정·신규 `.md` 전부: `grep -c ORCA_RICH_MD` 0, 코드펜스(```로 시작하는 줄) 개수 짝수, 에이전트 frontmatter 의 `name`·`description`·`model`·`tools` 유지.
- [ ] 메인 spec `.claude/` 경로 일괄 치환을 하지 않았다: `grep -ro '\.claude/' openspec/specs | wc -l` 가 델타 sync 로 늘어나는 만큼 외에 줄지 않는다 (기준선 112).

## 기존 spec과 부딪히는 곳 (전수 확인: 메인 spec 16개 중 아래 해당)

| capability | 부딪히는 요구사항 | 처리 |
|---|---|---|
| `agent-instructions/skill-tool-invocation-rationale` | "다섯 에이전트 지시문의 스킬 호출 문단은 allowed-tools 제약을 근거로" — 스캐폴드 Read 규칙·5개 파일 글자 단위 동일·md5 시나리오 | MODIFIED (근거는 sdd-rules 한 곳으로, 스캐폴드 Read 규칙 삭제) |
| `agent-instructions/analyzer-option-generation` | "기본 경로에는 analyzer와 방안 선택 관문이 없어야 한다" (기본 경로 = designer·regression-verifier 포함, 세 문서 순서 일치), "기본 경로의 designer 호출은 채택안이 없음을 명시", "사용자 문서에 없어진 모드가 남아 있지 않아야 한다"의 README 시나리오(기본 경로에도 결정 기록 개입 지점) | MODIFIED (기본 경로를 경량 경로로, designer 호출 요구는 큰 작업 경로 한정, README 개입 지점을 작은 작업/큰 작업으로 나눔). 이 capability 의 나머지(analyzer 모드 분기 없음, 사용자 후보, 신호 목록, 파일 무결성, 지우지 말아야 할 규칙)는 유지 |
| `agent-instructions/code-explorer-invocation` | "각 에이전트 파일에는 code-explorer를 언제 부르는지 안내가 있어야 한다" — 안내가 sdd-rules 로 이동 | MODIFIED (안내 위치를 sdd-rules + frontmatter 주입으로). "Agent 도구 보유", "호출 범위는 code-explorer 하나" 는 유지 |
| `agent-instructions/finalizer-archive-rationale-accuracy` | "`openspec-archive-change` 절차 한 길로만" | MODIFIED (정책은 그대로, 절차 이름을 `openspec archive --yes` 승인 뒤 한 길로) |
| `distribution/sdd-install-script` | "제품 5종을 깔아야 한다"(스킬 2개 → 4개), 설치 확인의 "openspec 공식 스킬 6개 존재 확인", README "이미 설치한 프로젝트" 안내 | REMOVED + ADDED("제품 7종") + MODIFIED (기존 설치는 두 스킬 추가 + 에이전트 파일 새 판으로 교체) |
| `distribution/init-sdd-skill` | 링크 대상이 `orchestra`·`agent-model-tier` 둘뿐이라는 서술들 ("둘만 링크한다" 시나리오) | MODIFIED (`sdd-rules`·`sdd-sync` 추가) |
| `agent-instructions/openspec-metadata-marker-safety` | 마커 명령은 preparer.md·designer.md 에 남긴다 → 요구사항 그대로. 본문 예시 "`openspec-update-change` 경로"는 설명용 괄호 | MODIFIED (designer 단계에서 확인: 괄호 예시만 "designer가 이미 있는 산출물을 고치는 경우, 작은 작업이 큰 작업으로 올라가는 경우"로 바꾼다. 마커 명령·종료코드 규칙은 그대로) |
| `agent-instructions/prompt-only-handoff-defense` | designer 채택안 없음 중단, `scope=전체diff` | 델타 없음 (큰 작업 경로에서 그대로). RESULT 공통 규칙을 옮겨도 이 필드는 해당 에이전트에 남긴다 |
| `agent-instructions/preparer-orphan-branch-reporting` | 중단 RESULT 의 `branch=` | 델타 없음 (`size=` 는 `준비완료` 줄에만 추가, 중단 줄 형식 불변) |
| `agent-instructions/reviewer-skip-specs-fallback`, `worker-blocked-state-disambiguation`, `artifact-file-precedence-over-prompt`, `project-context-completeness` | 지침 내용은 역할 로직 | 델타 없음 (줄 이동·삭제 시 해당 문구 보존 확인) |
| `agent-instructions/code-explorer-role` | code-explorer 본문은 안 건드림 | 델타 없음 |
| `distribution/agent-model-tier` | 에이전트 frontmatter `model:` 한 줄 수정 전제 — `skills:` 줄 변경과 무관 | 델타 없음 (③에서 삭제) |
| `process/field-validation-record` | 기준선 2,821줄 + 각주 | 델타 없음 (②가 줄인 뒤 값은 측정 양식 행으로 기록 — 이 change 에서는 review.md 에 남김) |

designer·regression-verifier "필수"를 말하는 요구사항은 위 `analyzer-option-generation` 의 두 요구사항뿐이다.
(같은 capability 의 "사용자 문서에 없어진 모드가 남아 있지 않아야 한다"는 designer 필수를 말하지는 않지만, README 시나리오가
기본 경로에도 결정 기록 개입 지점을 요구해 작은 작업과 부딪힌다 — 구현 전 설계 검토에서 발견, 같이 MODIFIED.)
`grep -rlE "designer|regression-verifier" openspec/specs` 로 나온 9개 spec 전부 읽어 확인했다:
나머지 8개는 designer가 하는 일(채택안·원본 파일 우선) 또는 등급 표·측정 판정 규칙·설명 문구라서
"기본 경로가 designer를 거친다"를 요구하지 않는다 (`field-validation-record` 의 판정 규칙은 단계별 켜기/끄기 기준이라 경량 경로와 충돌하지 않음).
`artifact-file-precedence-over-prompt` 는 designer 1단계와 finalizer의 review.md 대조 규칙이므로 줄이는 중에도 보존해야 한다.

## Capabilities

### New Capabilities
- `agent-instructions/shared-pipeline-rules`: 에이전트 공용 규칙(쓰는 스킬 근거·대화형 스킬·store 처리·code-explorer 부르기·되돌릴 수 없는 일·RESULT 공통 형식·Edit 부분 수정)이 `sdd-rules` 스킬 한 곳에만 있고 frontmatter `skills:` 로 주입되며, sdd-sync 가 스캐폴드 없이 sync 절차를 담는다.
- `agent-instructions/lite-default-path`: 기본 경로가 경량 경로(preparer가 proposal+tasks, worker, reviewer 테스트 1회, 커밋 관문, finalizer)이고, "큰 작업" 판정과 `size=작음|큼` 분기, regression-verifier 호출 조건이 orchestra 한 곳에 있다.

### Modified Capabilities
- `agent-instructions/skill-tool-invocation-rationale`: 스캐폴드 SKILL.md Read 규칙을 없애고 근거 문단을 sdd-rules 한 곳으로.
- `agent-instructions/analyzer-option-generation`: 기본 경로 정의와 designer 호출 요구, README 개입 지점을 작은/큰 작업으로 나눔.
- `agent-instructions/code-explorer-invocation`: code-explorer 안내 위치를 에이전트 파일에서 sdd-rules 로.
- `agent-instructions/finalizer-archive-rationale-accuracy`: archive 절차 이름을 스캐폴드 스킬에서 `openspec archive --yes` 로.
- `distribution/sdd-install-script`: 설치 제품과 설치 확인 목록에 sdd-rules·sdd-sync 추가, 공식 스킬 6개 존재 확인 제외.
- `distribution/init-sdd-skill`: 링크·복사 대상에 sdd-rules·sdd-sync 추가.
- `agent-instructions/openspec-metadata-marker-safety`: "여러 번 실행" 요구사항의 설명용 괄호에서 스캐폴드 스킬 이름을 빼고 새 재실행 경로(작은 작업 → 큰 작업)를 적는다.

## Impact

- 수정: `.claude/agents/*.md` 8개(주로 7개), `.claude/skills/orchestra/SKILL.md`, `.claude/skills/init-sdd/SKILL.md`, `install.sh`, `CLAUDE.md`, `README.md`.
- 신규: `.claude/skills/sdd-rules/SKILL.md`, `.claude/skills/sdd-sync/SKILL.md`.
- 메인 spec 델타 9개 (신규 2 + 수정 7).
- 같은 파일을 건드리는 진행 중 change: 없음 (상위 기록 change `plugin-lite-sdd-distribution` 은 지시문을 직접 고치지 않는다).
- 외부 의존: 없음 (로컬 CLI 1.12.0 으로 진행, 1.14.1 은 `npx` 로 대조만).

## 내가 세운 가정
- **확정:** `install.sh`·`init-sdd`·README·CLAUDE.md 수정은 범위 안이다. 새 스킬 두 개를 설치 경로가 모르면 설치본의 에이전트가 규칙을 못 받는다. (상위 decision 표에는 빠져 있었으나, 구현 전 설계 검토 뒤 오케스트레이터가 사용자 위임으로 확정했다.)
- 스킬 `sdd-rules` 는 `skills:` 주입 전용이라 사용자가 직접 부르지 않는다. 그래도 `description` 은 비워 두지 않고, frontmatter에 `allowed-tools` 는 쓰지 않는다 (init-sdd-skill spec 과 같은 이유).
- 큰 작업 판정은 preparer가 한다 (design 조건 4가지를 요구사항 정리 중에 판단). 애매하면 **큼** 쪽으로 기운다 (경량 경로는 설계 단계가 없어서 틀리면 worker가 막힌다). — design 단계에서 확정.
- 줄 수 합계는 새 스킬 2개를 **포함**해서 센다 (빼면 줄었다는 숫자가 속임수가 된다).
- ② 완료 뒤 ④ 양식에 실측 행을 채우는 일은 이 change 에서 하지 않는다 (측정 실행은 상위 범위 밖).
