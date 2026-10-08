## Why

지시문과 문서 곳곳에 서로 어긋나는 문구가 있다. 에이전트나 사용자가 그대로 믿고 따르면 헷갈리거나
사실과 다른 행동을 하게 된다. 플러그인 전환 등 큰 작업(상위 작업 `plugin-lite-sdd-distribution`)에
들어가기 전에, 동작은 그대로 두고 문구만 사실에 맞게 바로잡아 둔다.

## What Changes

동작 변경 없는 문서 정정 6가지.

1. `.claude/agents/code-explorer.md`: 본문 12행 "다른 6개"를 실제 호출 허용 에이전트 수인 7개로 맞춘다
   (frontmatter description은 이미 7개). 관련 spec 문구는 이미 7개라서 대조만 한다.
2. `.claude/skills/orchestra/SKILL.md` 표(약 83행): analyzer의 "산출물 안 씀"을 사실에 맞게 고친다
   (analyzer는 `analysis.md`를 쓴다).
3. `.claude/agents/reviewer.md` 앞부분의 "읽기 전용" 설명: Edit 도구는 재리뷰 때 review.md를 고치는
   용도이므로 "review.md 외에는 고치지 않는다"로 정확히 쓴다. 도구 목록은 바꾸지 않는다.
4. `/tmp` 하드코딩을 `mktemp` 또는 세션별 임시 경로로 바꾼다:
   `.claude/agents/regression-verifier.md`(89행), `.claude/skills/init-sdd/SKILL.md`(290, 305행),
   `README.md`(54-57, 79-82, 99행). init-sdd-skill spec과 대조한다.
5. `README.md` 85행 부근: "스캐폴드가 디스크엔 남아 있을 수 있다"를 "사라질 수 있고
   `openspec init --tools claude`로 복구한다"로 정정하고, `openspec update`는
   "No configured tools found"로 실패한다는 사실을 적는다.
6. `.agents/skills/claude-handoff/README.md`: "이 디렉터리는 Antigravity용이며 SDD 파이프라인과
   무관하다"는 안내 한 줄을 추가한다. 다른 파일은 그대로 둔다.

## Capabilities

### New Capabilities
없음.

### Modified Capabilities
없음. 요구사항(spec 수준 동작)이 바뀌는 항목이 없다. `code-explorer-role`, `code-explorer-invocation`은
이미 "7개"로 적혀 있어 지시문 쪽을 spec에 맞추는 것이다. `init-sdd-skill` spec에는 `/tmp` 경로 요구가
없다(대조 확인). 그래서 `.openspec.yaml`에 `skip_specs: true`를 설정했다.

## Impact

- 수정 파일(문서·지시문만): `.claude/agents/code-explorer.md`, `.claude/agents/reviewer.md`,
  `.claude/agents/regression-verifier.md`, `.claude/skills/orchestra/SKILL.md`,
  `.claude/skills/init-sdd/SKILL.md`, `README.md`, `.agents/skills/claude-handoff/README.md`.
- `.claude/agents/*.md`, `SKILL.md`는 Edit 부분 수정만 한다.
- 코드, 도구 목록, 동작은 바뀌지 않는다.

## 범위 밖

에이전트 도구 변경, 경량화, 플러그인 전환, agent-model-tier 삭제(하위 change ③), 상위 기록
디렉터리 `openspec/changes/plugin-lite-sdd-distribution/` 수정.

## 받아들일 조건

- [ ] `grep -n "다른 [67]개" .claude/agents/code-explorer.md` 결과가 모두 7개다
- [ ] orchestra 표의 analyzer 행이 `analysis.md`를 쓴다는 사실과 일치한다
- [ ] reviewer.md 설명이 "review.md 외에는 고치지 않는다"는 뜻이고 `tools:` 줄은 그대로다
- [ ] 세 파일(regression-verifier, init-sdd SKILL, README)에 `/tmp/` 하드코딩이 남지 않는다
      (`grep -n "/tmp" ...`로 확인)
- [ ] README의 스캐폴드 설명이 "사라질 수 있다 / `openspec init --tools claude`로 복구 /
      `openspec update` 실패(No configured tools found)"를 담는다
- [ ] claude-handoff README에 SDD와 무관하다는 안내가 있고 같은 디렉터리의 다른 파일은 안 바뀌었다
- [ ] 수정한 마크다운의 frontmatter와 코드펜스 개수가 온전하다
- [ ] `openspec validate fix-doc-inconsistencies`와 `openspec status` 종료코드가 0이다

## 세운 가정

- spec이 이미 "7개"라서 spec 델타는 필요 없다고 판단했다.
- 임시 경로 대체 방식(`mktemp` vs 세션별 경로)은 designer가 정한다.
