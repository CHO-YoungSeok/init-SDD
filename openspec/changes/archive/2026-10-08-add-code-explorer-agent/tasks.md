<!--
머리말 (analyzer 생략 경로라 decision.md 없음 — proposal.md와 design.md가 기준):
- 새 에이전트: code-explorer (.claude/agents/code-explorer.md), tools: Read/Grep/Glob/Bash만,
  Agent/Write/Edit/Skill 없음, model: haiku 한 줄.
- 기존 7개 에이전트 파일에 Agent 도구 추가 + "code-explorer를 언제 부르는지" 안내 문단 추가.
  단 code-explorer 외의 다른 서브에이전트 이름을 Agent로 부르라는 지시는 절대 넣지 않는다
  (오케스트레이터만 지휘한다는 절대 규칙에 code-explorer 하나만 예외를 낸다).
- agent-model-tier 등급 표는 7행 그대로 두고 표 아래 한 줄만 추가한다. 단 SKILL.md의
  실제 확인/검증 절차 세 곳이 `.claude/agents/*.md` **글롭**을 쓰고 있어서(실측, design.md
  Decisions 3 참고) code-explorer.md가 생기면 오판한다 — 이 글롭을 7개 파일만 도는 방식으로
  고치는 것도 이번 작업에 포함된다.
- .claude/agents/*.md 와 .claude/skills/**/SKILL.md 는 Edit 부분 수정만 한다. 전체 Write
  재작성과 sed -i 금지.
-->

## 1. code-explorer 에이전트 파일 만들기

- [x] 1.1 `.claude/agents/code-explorer.md`를 새로 만든다. frontmatter는 `---`로 열고
      닫으며 `name: code-explorer`, `description:`(코드·스펙·문서를 탐색·검색하는 역할과
      언제 불리는지), `model: haiku`(정확히 한 줄), `tools: Read, Grep, Glob, Bash`를
      담는다. `Write`, `Edit`, `NotebookEdit`, `Agent`, `Skill`은 넣지 않는다.
      본문에는 다음을 명시한다: 코드/스펙(`openspec/`)/문서를 읽고 검색해 호출한
      에이전트에게 결과를 정리해 보고하는 것이 유일한 일이라는 것; 프로젝트 코드나
      OpenSpec 산출물을 고치지 않는다는 것(MUST NOT); 파일을 새로 만들지 않는다는 것;
      `Agent` 도구가 없는 이유(호출 깊이 제한을 위한 안전 기본값)를 한 문단으로.
      확인: `.claude/agents/*.md`를 세면 8개이고, 새 파일의 `tools:` 줄에 `Read, Grep,
      Glob, Bash`만 있다.

## 2. 기존 7개 에이전트 파일에 Agent 도구와 안내 추가

- [x] 2.1 `.claude/agents/preparer.md`의 `tools:` 줄에 `Agent`를 Edit로 추가한다(기존
      도구는 그대로 둔다). 본문에 "코드베이스를 넓게 뒤지거나 찾아야 할 때 code-explorer를
      불러라. 결과를 받아서 네 일을 계속해라" 취지의 문단을 Edit로 추가한다. 이 문단에
      code-explorer 외의 다른 서브에이전트를 부르라는 말을 넣지 않는다. 확인: `tools:`에
      `Agent`가 있고, `model:` 줄과 다른 키는 바뀌지 않았다.
- [x] 2.2 `.claude/agents/analyzer.md`에 2.1과 같은 작업을 한다.
- [x] 2.3 `.claude/agents/designer.md`에 2.1과 같은 작업을 한다.
- [x] 2.4 `.claude/agents/worker.md`에 2.1과 같은 작업을 한다.
- [x] 2.5 `.claude/agents/reviewer.md`에 2.1과 같은 작업을 한다.
- [x] 2.6 `.claude/agents/regression-verifier.md`에 2.1과 같은 작업을 한다.
- [x] 2.7 `.claude/agents/finalizer.md`에 2.1과 같은 작업을 한다.
- [x] 2.8 7개 파일 전체의 frontmatter 무결성을 확인한다: 각 파일이 `---` 두 줄로 열리고
      닫히며 `name:`, `description:`, `model:`, `tools:` 키를 모두 갖고, `model:`로
      시작하는 줄이 파일마다 정확히 하나이고, `git diff -- .claude/agents/`에서 각 파일당
      `tools:` 줄과 안내 문단 삽입 부분 외에 다른 줄이 바뀌지 않았는지 눈으로 확인한다.

## 3. agent-model-tier 스킬 문서 수정

- [x] 3.1 `.claude/skills/agent-model-tier/SKILL.md`의 등급 표(`normal`/`semi-lower`/
      `lower`) 아래에 "code-explorer는 이 표 밖에 있고 항상 haiku로 고정된다. 이 스킬이
      바꾸는 대상이 아니다" 취지의 한 줄을 Edit로 추가한다. 표 자체(7행)는 늘리지 않는다.
- [x] 3.2 SKILL.md 안에서 `.claude/agents/*.md` **글롭**을 쓰는 세 곳(지금 등급 확인의
      1단계 bash 블록, "바꾼 뒤 확인"의 2단계·3단계 bash 블록 — 정확한 위치는 파일을
      직접 읽고 찾는다)을 code-explorer.md를 걸러내는 방식으로 고친다. 방법은 문서
      맨 위에 이미 나열된 7개 파일 이름을 도는 것으로 바꾸거나, 글롭 결과에서
      `code-explorer.md`를 제외하는 필터(예: `grep -v code-explorer.md`)를 추가하는 것
      중 하나를 고른다 — 결과가 7개만 순회하면 된다. `git diff -- .claude/agents/`로
      대상 파일이 바뀌지 않는 것과는 별개로, 이 3.2는 SKILL.md 자체의 bash 코드블록을
      고치는 작업이다.
- [x] 3.3 고친 뒤 실제로 등급 조회를 돌려 확인한다: 지금 저장소의 `.claude/agents/*.md`
      7개가 `normal` 표와 같은 상태에서(로컬 등급 수정이 있다면 그 상태 그대로)
      `code-explorer.md`를 추가한 뒤 SKILL.md의 "지금 등급 확인" bash 블록을 그대로
      실행해서, 결과 목록에 `code-explorer.md`가 나오지 않고 7개만 나오는 것을 확인한다.

## 4. install.sh 수정

- [x] 4.1 `install.sh:120` 근처의 `say "   에이전트: ${N_AGENTS}개 (7이어야 한다)"`를
      `(8이어야 한다)`로 Edit한다.
- [x] 4.2 `install.sh:73` 근처의 `for f in "$SRC"/.claude/agents/*.md; do copy_if_absent
      ...`가 글롭이라 `code-explorer.md`도 자동으로 복사 대상에 들어가는지 코드를 읽어
      확인한다(고칠 필요는 없을 가능성이 높다 — 확인만 한다).
- [x] 4.3 `bash -n install.sh`로 문법을 확인한다(종료코드 0).
- [x] 4.4 `mktemp -d`로 만든 빈 임시 디렉터리에서만(이 저장소나 `~/work-space/`는 건드리지
      않는다) `git init` + 초기 커밋 후 `bash install.sh`를 실제로 돌려, `.claude/agents/`
      에 8개 파일(`code-explorer.md` 포함)이 깔리고 설치 확인 절에 "에이전트: 8개
      (8이어야 한다)"가 출력되는 것을 확인한다.

## 5. README.md 수정

- [x] 5.1 `README.md`의 "## 7개 서브에이전트" 절 아래(표는 그대로 7행 유지)에
      `code-explorer`를 설명하는 짧은 절이나 문단을 추가한다. 등급 표(7개 대상) 밖에
      있고, 파이프라인 단계가 아니라 7개 에이전트가 필요할 때 직접 부르는 보조
      에이전트라는 성격이 드러나게 쓴다.
- [x] 5.2 README.md 안에 서브에이전트 개수를 명시하는 다른 자리(설치 확인 절 등)가
      있으면 8개 기준으로 맞는지 확인한다. 없으면 건드리지 않는다.

## 6. CLAUDE.md / orchestra SKILL.md에 예외 한 줄 추가 (파이프라인 순서는 그대로)

- [x] 6.1 `CLAUDE.md`의 `<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->` 구획 안,
      "순서: ..." 줄은 그대로 두고 그 근처에 "code-explorer는 파이프라인 단계가 아니라
      각 에이전트가 필요할 때 직접 부르는 보조 에이전트다" 취지의 한 줄을 Edit로
      추가한다. 이 구획이 install.sh가 뽑아 쓰는 유일한 원본이므로 다른 파일에는
      같은 문구를 베끼지 않는다.
- [x] 6.2 `.claude/skills/orchestra/SKILL.md`의 "## 절대 규칙" 절(1~5번) 바로 뒤에,
      "code-explorer는 7개 에이전트가 직접 부를 수 있는 유일한 예외다. 이 규칙들은 여전히
      오케스트레이터 자신에게 적용된다"는 취지의 한 줄을 Edit로 추가한다. 절대 규칙
      5개 항목 자체는 고치지 않는다.

## 7. 최종 검증

- [x] 7.1 `openspec validate "add-code-explorer-agent" --strict`를 돌려 종료코드가 0인
      것을 확인한다.
- [x] 7.2 `openspec status --change "add-code-explorer-agent" --json`을 돌려
      `isPlanningComplete`(또는 `isComplete`)가 true인 것을 확인한다.
- [x] 7.3 실제로 한 에이전트 파일(예: worker.md)의 관점에서 code-explorer 호출 문단이
      말이 되는지 다시 읽어 보고, 다른 6개 파일과 문구가 크게 어긋나지 않는지 확인한다.
- [x] 7.4 `.claude/agents/*.md` 8개 전부에서 `grep -c '^model:'`이 모두 1인지,
      `grep -c '^tools:'`이 모두 1인지 확인한다.
