## Context

See proposal.md - Why/What Changes for motivation. 이 문서는 preparer의 가정을 검토해
확정한 결과와, 오케스트레이터가 이미 정한 결정 4가지를 실제 파일 변경으로 어떻게 옮기는지를
다룬다.

**이 change는 preparer의 spec 경로 가정을 수정한다.** preparer는 proposal.md와 보고서에서
"7개 MODIFIED: `agent-instructions/{preparer,analyzer,...}/spec.md`"라고 적었지만, 이
저장소의 `openspec/specs/agent-instructions/`는 에이전트 이름별이 아니라 **주제별
capability**로 되어 있다(`analyzer-option-generation`,
`artifact-file-precedence-over-prompt` 등 10개, 실측). proposal.md의 Capabilities 절도
같은 오류를 담고 있었으므로, 이 change에서 아래처럼 고쳤다:

- proposal.md의 "New Capabilities"를 `agent-instructions/code-explorer-agent` 하나에서
  `agent-instructions/code-explorer-role`과 `agent-instructions/code-explorer-invocation`
  둘로 나눠 적었다.
- proposal.md의 "Modified Capabilities" 목록에서 "7개 MODIFIED:
  `agent-instructions/{preparer,...}`" 서술을 지우고, 실제로 쓰는 4개 capability
  (`agent-instructions/code-explorer-role`, `agent-instructions/code-explorer-invocation`,
  `distribution/agent-model-tier`, `distribution/sdd-install-script`)로 바꿔 적었다.

## Goals / Non-Goals

**Goals:**
- 새 읽기 전용 에이전트 `code-explorer`를 추가하고, 기존 7개 에이전트가 필요할 때 그것을
  직접 부를 수 있게 한다.
- 이 구조 변경이 "오케스트레이터만 지휘한다"는 기존 원칙에서 벗어나는 부분을 `code-explorer`
  하나로만 좁힌다.
- `agent-model-tier`·`install.sh`·`README.md`가 8번째 에이전트의 존재와 성격(등급 시스템
  밖, 항상 haiku, 파이프라인 단계 아님)을 정확히 반영하게 한다.

**Non-Goals:**
- `code-explorer` 자신이 다른 에이전트를 부르는 기능 (오케스트레이터가 이미 확정:
  `Agent` 도구를 주지 않는다).
- 파이프라인 단계 순서에 `code-explorer`를 끼워 넣는 것 (CLAUDE.md/orchestra의 순서 그림은
  그대로 둔다 — 이건 파이프라인 단계가 아니라 유틸리티다).
- `agent-model-tier` 등급 표를 8행으로 늘리는 것 (사용자 결정 2: 표는 7행 그대로, 표 아래
  한 줄만 추가).
- `init-sdd`(심볼릭 링크 배포) 스킬 spec 수정 — proposal의 Impact와 오케스트레이터 지시
  어디에도 이 스킬이 언급되지 않았다. `.claude/agents/` 전체를 디렉터리째 심볼릭 링크하는
  방식이라 `code-explorer.md` 추가는 그 스킬의 동작을 바꾸지 않는다(자동으로 포함된다).
  "우려 사항"에 별도로 적는다.

## Decisions

### 1. 새 에이전트 이름과 파일 위치

`code-explorer`, 파일은 `.claude/agents/code-explorer.md` — 사용자가 확정. (decision.md는
만들지 않았다 — analyzer를 생략한 경로라 designer.md 규칙상 선택이다. 이 결정과 근거는
proposal.md의 "Questions for Clarification"과 여기 design.md에 남긴다.)

### 2. code-explorer의 tools 구성: Read, Grep, Glob, Bash만

**대안:** (a) `TodoWrite`도 추가 (regression-verifier가 갖고 있는 조합), (b) `Write`도
추가해서 스스로 메모 파일을 남기게 함.

**선택:** Read, Grep, Glob, Bash만. 근거:
- preparer의 가정(Read/Grep/Glob/Bash, Write/Edit 없음)이 타당하다고 판단해 그대로 확정한다.
- `TodoWrite`는 여러 단계에 걸친 작업을 추적하는 도구다. `code-explorer`는 한 번 불려서
  탐색하고 결과를 보고한 뒤 끝나는 단발성 호출이 기본 사용 패턴이라(호출한 에이전트가 이미
  자기 TodoWrite로 진행을 추적하고 있다), 자체 TodoWrite가 필요한 경우가 드물다. 필요하면
  다음 change에서 추가할 수 있다 — 지금 안 주는 쪽이 안전 기본값에 더 가깝다.
- `Write`/`Edit`는 명시적으로 배제한다. `code-explorer`는 산출물을 만들지 않는
  `reviewer`/`regression-verifier` 패턴을 따른다 — 이 저장소에 이미 읽기 전용 에이전트
  선례가 둘 있다(참고 실물).
- `Agent`는 오케스트레이터가 이미 확정한 안전 기본값(호출 깊이 제한)이라 배제한다.
- `Skill`은 안 준다 — `code-explorer`는 OpenSpec 산출물을 만들거나 고치는 일이 없어서
  `openspec-*` 스킬을 쓸 일이 없다.

### 3. model: haiku, 등급 표 밖 — 그리고 SKILL.md의 실제 순회 방식을 실측해 바로잡는다

사용자 결정 2 그대로 표는 8행으로 늘리지 않고, 표 아래에 "code-explorer는 등급 표 밖,
항상 haiku" 한 줄만 추가한다.

**오케스트레이터의 가정과 다른 점 (실측):** 오케스트레이터는 "그 스킬은 지금 7개 파일을
이름으로 순회한다(design 이전 change에서 그렇게 확정됐다)"고 전제했지만,
`.claude/skills/agent-model-tier/SKILL.md`를 직접 읽어 보면 "바꾸는 파일" 목록은 7개
이름을 **글로 나열**한 것일 뿐, 실제 확인/검증 절차 세 곳은 전부 **글롭**을 쓴다:

```
for f in .claude/agents/*.md; do echo "$(basename "$f") $(grep -m1 '^model:' "$f")"; done
```
(지금 등급 확인 1단계, "바꾼 뒤 확인" 2·3단계에도 같은 글롭이 쓰인다)

`code-explorer.md`가 `.claude/agents/`에 생기면 이 글롭이 **8개**를 모아 등급 표(7개 값)와
대조하게 되어, 이미 `normal`이어도 "섞인 상태"로 오판한다. 이는 사용자 결정 2("표 밖,
항상 haiku")가 실제로 성립하려면 반드시 고쳐야 하는 결함이고, 이미 써 둔
`distribution/agent-model-tier` 스펙 델타의 요구사항("판별·전환 절차는
`code-explorer.md`를 읽거나 고치지 않아야 한다")을 지키려면 필요한 수정이다. 새 요구사항을
늘리는 것이 아니라 방금 쓴 요구사항을 실제로 만족시키는 구현이므로 tasks.md에 수정
작업으로 넣는다(문서 한 줄 추가로 안 끝난다는 점을 보고서의 "우려 사항"에도 남긴다).

**수정 방법:** 세 곳의 글롭(`.claude/agents/*.md`)을 SKILL.md 위쪽에 이미 나열된 7개
파일 이름을 도는 방식으로 바꾸거나, `code-explorer.md`를 걸러내는 필터를 더한다. 어느
쪽이든 결과(7개만 순회)가 같아야 한다 — 구체적 구현은 worker가 고른다.

### 4. "모든 에이전트가 호출할 수 있다" = 7개 에이전트 각자가 code-explorer를 직접 호출

오케스트레이터가 이미 확정. **이 저장소의 원칙("오케스트레이터만 지휘하고 서브에이전트는
직접 일한다")에서 벗어나는 구조 변경**이며, 사용자가 명시적으로 요청했다.

**이 이탈을 좁히는 방법:** `.claude/skills/orchestra/SKILL.md`의 "절대 규칙" 5개
(오케스트레이터가 직접 파일을 고치지 않는다/리뷰하지 않는다/커밋하지 않는다/설계하지
않는다/산출물을 만들거나 고치지 않는다는 것 — **전부 오케스트레이터 자신에 대한 규칙**)는
그대로 남는다. 이번 변경이 여는 구멍은 **다른 층위**다: "서브에이전트는 서로를 부르지
않는다"는 지금까지 명시된 적 없는 암묵적 관행이었고, 이번에 그 관행에 "7개 에이전트는
`code-explorer` 하나만 예외적으로 부를 수 있다"는 좁은 구멍을 낸다. `code-explorer-invocation`
capability의 세 번째 요구사항(`서브에이전트 간 호출 범위는 code-explorer 하나로 좁아야
한다`)이 이걸 강제한다 — 7개 파일 어디에도 `code-explorer` 외의 다른 서브에이전트 이름을
`Agent`로 부르라는 지시가 있으면 안 된다.

`orchestra/SKILL.md`에는 이 예외가 "절대 규칙" 절 근처에 한 줄로 드러나야 한다 — 그래야
다음 사람이 "절대 규칙 5개"를 읽고 "서브에이전트는 서로 못 부른다"고 짐작한 뒤
`code-explorer` 호출을 보고 모순이라 오인하지 않는다. 이건 기존 capability가 없는 스킬
문서라 spec 요구사항으로 강제하지 않고 tasks.md의 작업 항목으로 지시한다(아래 "spec으로
옮기지 못한 것" 참고).

### 5. 안내 문단을 넣는다 (도구만 주지 않는다)

analyzer 옵트인 change에서 얻은 교훈("정해 놓지 않으면 아무도 안 부른다")을 그대로
적용한다. 7개 파일 각각에 "코드베이스를 넓게 뒤져야 할 때 code-explorer를 불러라. 결과를
받아서 네 일을 계속해라" 취지의 한 문단을 Edit로 추가한다. `code-explorer-invocation`
capability의 두 번째 요구사항이 이를 강제한다.

### 6. capability 분리: code-explorer-role vs code-explorer-invocation

**대안:** 하나의 capability(`agent-instructions/code-explorer-agent`, proposal 원안)로
합친다.

**선택:** 둘로 나눈다. 근거: 이 저장소의 기존 capability들은 하나의 좁은 행동 관심사를
다룬다(`skill-tool-invocation-rationale`은 5개 파일에 걸친 "한 문단이 똑같아야 한다"는
관심사 하나, `worker-blocked-state-disambiguation`은 worker 하나의 한 가지 판단 규칙).
`code-explorer` 자신이 무엇인지(파일 존재, frontmatter, 도구, 역할 경계)와, 기존 7개가
그것을 어떻게 부르는지(도구 추가, 안내 문단, 호출 범위 제한)는 서로 다른 파일 집합에
걸리는 서로 다른 관심사라 나누는 것이 이 저장소의 기존 패턴과 더 맞는다. 다음 change에서
둘 중 하나만 건드릴 일이 생기면(예: `code-explorer`에 도구를 하나 더 주는 변경) 델타가
그 capability 하나로 끝난다.

### 7. distribution/sdd-install-script를 MODIFIED로 건드린다

기존 요구사항 "제품 5종을 깔아야 한다"에 `.claude/agents/*.md` **7개**라는 숫자와
"에이전트 개수(7이어야 한다)" 확인 문구가 이미 박혀 있었다(실측: 기존 spec.md 원문).
이 숫자를 8로 바꾸는 것은 새 요구사항이 아니라 기존 요구사항의 **값 변경**이므로 MODIFIED로
다루고, `openspec instructions specs` 규칙대로 기존 requirement 블록 전체(모든 Scenario
포함)를 복사해 옮긴 뒤 숫자만 고쳤다. 복사 대상 목록(글롭) 자체는 안 바뀐다는 것도
Scenario로 남겼다 — `install.sh:73`의 `for f in "$SRC"/.claude/agents/*.md` 글롭이
자동으로 8개를 복사하므로, 고칠 곳은 설치 확인 문구(`install.sh:120` 근처, 실측 필요)
하나뿐이다.

## spec으로 옮기지 못한 것

- `CLAUDE.md`·`orchestra/SKILL.md`의 파이프라인 순서 서술에 code-explorer를 끼워 넣지
  않는다는 것, 그리고 "절대 규칙" 절 근처에 예외를 한 줄 남긴다는 것은 이 저장소에 그
  문서들을 다루는 기존 capability가 없어서(spec-driven capability는
  `.claude/agents/*.md`와 `.claude/skills/agent-model-tier/SKILL.md`만 다룬다) 새
  capability를 만들지 않고 tasks.md의 작업 항목으로만 지시한다. 요구사항을 늘리지 말라는
  지시와, 기존 저장소가 orchestra 스킬 문서 자체를 spec 대상으로 삼은 적이 없다는 사실을
  근거로 판단했다.
- `init-sdd`(심볼릭 링크) 스킬의 spec — proposal Impact와 오케스트레이터 지시 어디에도
  없어 손대지 않았다. Purpose 문단의 "서브에이전트 7개"라는 서술이 이제 8개를 가리키게
  되지만, 그 스킬은 `.claude/agents/` 디렉터리 전체를 심볼릭 링크하는 방식이라 동작은
  바뀌지 않는다 — 숫자 서술 하나가 실제와 살짝 어긋나는 정도이고, 이 change의 범위(Impact에
  나열된 파일들) 밖이라 건드리지 않았다. "우려 사항"에 적는다.

## Risks / Trade-offs

- [Risk] 서브에이전트가 서브에이전트를 부르는 첫 사례라, 실제로 돌려 보기 전에는 Claude
  Code 런타임이 이 호출을 기대대로 처리하는지(예: 중첩 호출의 컨텍스트 전달, 병렬 처리 중
  호출 등) 이 저장소의 실측 수단(grep, validate, install.sh --dry-run)만으로는 확인할 수
  없다. → Mitigation: tasks.md에 "실제로 한 서브에이전트에서 code-explorer를 불러
  동작을 확인" 작업을 넣어 최소 1회 실측한다. 그 이상의 런타임 검증(여러 에이전트가 동시에
  부르는 경우 등)은 이 change의 범위를 넘는다고 보고 다음 사용에서 문제가 드러나면 후속
  change로 넘긴다.
- [Risk] 7개 파일에 안내 문단을 추가하며 frontmatter나 기존 문단을 실수로 건드릴 수 있다
  (Edit 부분 수정이라 가능성은 낮지만, `tools:` 줄과 본문 삽입 위치가 파일마다 다르다).
  → Mitigation: tasks.md에 파일마다 "frontmatter 온전성(코드펜스·`---`·다른 키 무변경)
  확인" 작업을 넣는다.
- [Risk] `agent-model-tier` 스킬이 8번째 파일 때문에 오작동한다 — **실측으로 확인됨**
  (Decisions 3 참고). SKILL.md의 확인/검증 절차 세 곳이 `.claude/agents/*.md` 글롭을
  써서 `code-explorer.md`까지 순회하면, 8개 값을 7행짜리 표와 대조하다 항상 "섞인 상태"로
  오판한다. → Mitigation: tasks.md에 이 세 글롭을 7개 파일만 도는 방식으로 고치는 작업과,
  고친 뒤 실제로 등급 조회를 돌려 오판이 사라졌는지 확인하는 작업을 넣는다.

## Migration Plan

되돌릴 수 없는 구조 변경은 없다. 새 파일 하나 추가 + 기존 7개 파일의 부분 수정(Edit)이라
worker가 반려되면 그 Edit만 되돌리면 된다. 별도 마이그레이션 절차는 필요 없다.
