# 이 저장소를 고칠 때 (개발자 안내)

- 이 저장소는 플러그인 `sdd`의 루트다. `claude --plugin-dir .`로 띄운다.
- 이 저장소도 SDD로 개발한다. 에이전트 원본은 `agents/`, 스킬 원본은 `skills/`에 있다.
- 아래 표식 구획은 기존 설치 방식(`install.sh`, `init-sdd`)이 뽑아 쓰는 조각 원본이다. 그 안의 `.claude/agents/`,
  `.claude/skills/orchestra/SKILL.md` 경로는 설치 대상 프로젝트 기준이다. 이 저장소에서는 `agents/`, `skills/orchestra/SKILL.md`로
  읽고, 에이전트 이름에는 `sdd:`를 붙인다(예: `sdd:worker`).
- 표식 구획 안은 고치지 않는다.

<!-- 템플릿 안내: 이 파일을 통째로 복사하지 마라.
     아래 내용을 네 프로젝트의 CLAUDE.md **끝에 덧붙여라.**
     install.sh 를 쓰면 알아서 덧붙인다. -->

<!-- init-SDD:begin -->
# 작업 방식

이 프로젝트는 SDD(사양 주도 개발) 파이프라인으로 일한다.

메인 세션은 **오케스트레이터**다. 사용자와 대화하고 지휘만 한다.
분석·설계·파일 수정·리뷰·회귀 검증·커밋은 **모두 `.claude/agents/` 의 서브에이전트에게 위임한다.**

순서: `preparer` → `worker` → `reviewer` → `finalizer` (기본 — 작은 작업)
큰 작업이면 `preparer` → `designer` → `worker` → `reviewer` + `regression-verifier`(테스트가 있을 때, 동시) → `finalizer`.
작은 작업/큰 작업 판정 기준은 `orchestra` 스킬에 있다.

분석·방안 비교를 요청할 때만 `analyzer` 를 부른다. 그때 **★사용자가 방안 선택** 관문이 열린다.

**예외:** `code-explorer` 보조 에이전트는 7개 에이전트가 코드베이스를 넓게 뒤져야 할 때 직접 부를 수 있다. 
다른 서브에이전트는 오케스트레이터만 부를 수 있다.

지휘 절차는 `orchestra` 스킬에 있다. 스킬이 안 불려오면
`.claude/skills/orchestra/SKILL.md` 를 Read로 직접 읽고 그대로 따른다.

**이 파일은 서브에이전트도 물려받아 읽는다. 위 위임 규칙은 메인 세션에게 하는 말이며,
각 서브에이전트는 자기 파일(`.claude/agents/<이름>.md`)의 지침을 따른다.**
<!-- init-SDD:end -->
