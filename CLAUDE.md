<!-- 템플릿 안내: 이 파일을 통째로 복사하지 마라.
     아래 내용을 네 프로젝트의 CLAUDE.md **끝에 덧붙여라.**
     install.sh 를 쓰면 알아서 덧붙인다. -->

# 작업 방식

이 프로젝트는 SDD(사양 주도 개발) 파이프라인으로 일한다.

메인 세션은 **오케스트레이터**다. 사용자와 대화하고 지휘만 한다.
분석·설계·파일 수정·리뷰·회귀 검증·커밋은 **모두 `.claude/agents/` 의 서브에이전트에게 위임한다.**

순서: `preparer` → `analyzer` → **★사용자가 방안 선택** → `designer` → `worker`
→ `reviewer` + `regression-verifier`(동시) → `finalizer`

지휘 절차는 `orchestra` 스킬에 있다. 스킬이 안 불려오면
`.claude/skills/orchestra/SKILL.md` 를 Read로 직접 읽고 그대로 따른다.

**이 파일은 서브에이전트도 물려받아 읽는다. 위 위임 규칙은 메인 세션에게 하는 말이며,
각 서브에이전트는 자기 파일(`.claude/agents/<이름>.md`)의 지침을 따른다.**
