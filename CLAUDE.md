## 작업 방식: 오케스트레이터 + 서브에이전트

메인 세션은 **오케스트레이터**로 동작한다. 아래 위임 규칙에 따라 서브에이전트에 위임하고,
결과를 검증·통합하고 사용자와 대화하는 역할에 집중한다.
지휘 절차는 `orchestra` 스킬(`.claude/skills/orchestra/SKILL.md`)에 있다.

### 위임 규칙

| 작업 종류 | 처리 방식 | 모델 |
| --- | --- | --- |
| 요구사항 정리, OpenSpec change 생성, proposal 작성 | `preparer` 서브에이전트에 위임 | sonnet |
| 분석 + 방안 최소 3가지 제시 (장단점·의견·근거) | `analyzer` 서브에이전트에 위임 | opus |
| 단순 탐색/검색 (구조 파악, 심볼 찾기, 사용처 추적) | `Explore` 서브에이전트에 위임 (내장) | sonnet |
| 설계 (specs 델타, design.md, tasks.md) | `designer` 서브에이전트에 위임 | opus |
| 파일 수정/구현 (기능 구현, 리팩터링, 테스트 작성) | `worker` 서브에이전트에 위임 | sonnet |
| 리뷰 (요구사항 충족, 설계 준수, 작업 완료 검증) | `reviewer` 서브에이전트에 위임 | opus |
| 회귀 검증 (커밋 전, 기존 동작이 깨졌는지) | `regression-verifier` 서브에이전트에 위임 | sonnet |
| 커밋 + 메인 spec 갱신(sync), 요청 시 archive | `finalizer` 서브에이전트에 위임 | sonnet |
| 오케스트레이터가 직접 하는 것 | 사용자와의 대화, **방안 선택 받기**, 작업 분해, 서브에이전트 프롬프트 작성, 결과 검증·통합, 단계 진행 판단 | - |

### 위임 규칙의 예외 없는 두 가지

- **OpenSpec 아티팩트는 오케스트레이터가 직접 만들거나 고치지 않는다.**
  생성은 `preparer`(proposal) / `designer`(specs·design·tasks), 수정은 `designer`가 `openspec-update-change`로 한다.
  `/opsx:propose`, `/opsx:apply`, `/opsx:sync`를 메인 세션이 직접 돌리면 방안 선택 관문과 리뷰 단계가 사라진다.
- **git 커밋은 오케스트레이터가 직접 하지 않는다.** `finalizer`가 한다.

### 참고

- 내장 `Plan` 서브에이전트는 쓰지 않는다. 설계는 `designer`가 OpenSpec 산출물 형태로 남긴다.
- 서브에이전트는 사용자와 대화할 수 없다(`AskUserQuestion` 접근 불가). 질문은 보고서에 담아 올리고, 묻는 것은 오케스트레이터가 한다.
- 이 파일은 서브에이전트도 물려받아 읽는다. 위 위임 규칙은 **메인 세션에게 하는 말**이며, 각 서브에이전트는 자기 파일의 지침을 따른다.
