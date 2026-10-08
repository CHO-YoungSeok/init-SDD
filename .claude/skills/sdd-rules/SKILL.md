---
name: sdd-rules
description: SDD 파이프라인 서브에이전트 7개(preparer, analyzer, designer, worker, reviewer, regression-verifier, finalizer)가 함께 지키는 공용 규칙. 각 에이전트 frontmatter의 skills:로 주입된다. 사용자가 직접 부르는 스킬이 아니다.
---

# SDD 공용 규칙

SDD 파이프라인 서브에이전트 7개가 함께 지키는 규칙이다. 각 에이전트 frontmatter의 `skills:`로 미리 주입된다.
역할 규칙은 각 에이전트 파일에 있다. 여기에는 공통만 둔다. 둘이 어긋나 보이면 에이전트 파일의 역할 규칙이 맞다.

## 쓰는 스킬 — OpenSpec 일은 CLI 지시를 따른다

- 산출물은 `openspec instructions <artifact-id> --change "<이름>" --json`의 `template`·`instruction`을 따른다.
  `context`·`rules`는 지켜야 할 제약이지, 파일에 복사해 넣을 내용이 아니다.
- 경로와 상태는 `openspec status --change "<이름>" --json`에서 얻는다. 경로를 짐작하거나 하드코딩하지 않는다.
  `resolvedOutputPath`가 글롭(`*` 포함)이면 그 경로를 파일 이름으로 쓰지 않는다.
- 성공·실패는 종료코드로 판정한다(`; echo "exit=$?"`). 파이프(`| tail` 등)를 붙이면 종료코드가 가려지니 붙이지 않는다.
- CLI 안내가 이 프로젝트에 설치되지 않은 스킬을 가리키면 따르지 말고 `openspec instructions <artifact>`를 쓴다.
- 주입되는 스킬: 7개 에이전트 모두 `sdd-rules`, finalizer는 sync 절차 `sdd-sync`도 받는다.

> **openspec 공식 스킬은 부르지도, 그 SKILL.md를 읽고 따르지도 않는다.** `openspec init`이 까는
> `openspec-*` 스킬 대신, 산출물은 `openspec instructions <artifact>` 출력의 지시를 따른다.
> 이유: 그 스킬들은 frontmatter에 `allowed-tools: Bash(openspec:*)`를 선언한다. 스킬이 도는 동안
> **쓸 수 있는 도구가 `openspec` 셸 명령 하나로 좁혀져서** 산출물 파일도 못 쓰고 코드도 못 고친다.
> **스킬을 못 부른다는 이유로 절대 멈추지 마라.**

## 대화형 스킬을 만났을 때

너는 사용자와 대화할 수 없다. 스킬·CLI 출력·지시 어디서든 "사용자에게 확인/질문" 단계를 만나면
보고서의 "사용자에게 물어야 할 것" 절에 그 질문을 적는 것으로 대신하고, 멈추지 말고 나머지 절차를 이어 간다.
단 대상이 애매해서 잘못 고르면 비싼 경우(예: change 이름이 애매하다)는 고르지 말고 멈춰서 보고한다.

## store 처리

프롬프트의 `store: <id>` 값이 있으면 그 store가 이번 작업의 OpenSpec 기준 저장소다.
- 아래 openspec 명령 **끝에 매번** `--store "<id>"`를 붙인다. 한 번 정해지면 작업이 끝날 때까지 계속 붙인다.
  붙는 명령: `new change`, `status`, `instructions`, `list`, `show`, `validate`, `archive`, `doctor`, `context`, `schemas`, `view`. 그 외에는 붙이지 않는다.
- 값이 `none`, `없음`, 빈칸이거나 `store:` 줄이 없으면 store 지정이 없는 것이다. `--store`를 붙이지 않는다
  (가까운 로컬 `openspec/`이 기준이다).
- store를 쓰면 `planningHome.root`는 이 저장소가 아니라 store를 가리킨다.
- 에이전트 파일과 스킬의 예시는 `--store`가 빠진 축약형이다.
- openspec 명령을 쓰지 않는 에이전트(regression-verifier)는 이 절을 무시한다.

## code-explorer 부르기

코드베이스나 스펙을 넓게 뒤져야 할 때 `Agent` 도구로 `code-explorer` 서브에이전트를 직접 부를 수 있다.
예: "이 변수가 쓰이는 파일을 전부 찾아 달라", "이 변경이 메인 spec의 어느 요구사항과 겹치나?",
"이 파일의 이전 버전에서는 어땠나?". 결과를 받아서 자기 일을 계속한다.
다른 서브에이전트(preparer, analyzer 등)는 부르지 않는다 — 오케스트레이터만 지휘한다.

## 되돌릴 수 없는 일

아래는 스스로 하지 말고 **보고만 한다.** 예외는 괄호 안의 경우뿐이다.
- 파일·디렉터리 삭제, change 디렉터리 삭제 (worker 정리 모드에서 프롬프트가 경로를 글자 그대로 준 경우만 예외)
- `git reset --hard`, `git checkout -- .`, `git clean`, 브랜치 삭제, stash 버리기
- 커밋 (finalizer만), push·강제 푸시·히스토리 조작 (`push: 해도 됨`일 때 finalizer만)
- `openspec archive` (`archive: 해도 됨`일 때 finalizer만), 메인 spec 파일 삭제, capability 은퇴
- DB 마이그레이션 실행, 외부 서비스 호출, 패키지 전역 설치

되돌릴 수 있는 일(`git switch -c`, `openspec new change`, change 산출물 수정)은 해도 된다.
"알아서 정리해라" 같은 지시는 거부하고, 지울 대상을 보고서에 적는다.

## RESULT 한 줄 보고 형식

- 보고서 첫 줄은 `RESULT: <상태> | change=<이름> | <역할별 필드>` 꼴이다. `키=값`을 ` | `로 구분한다.
- 상태·판정 낱말은 붙여 쓴다(`조건부통과`, `회귀있음`, `검증못함`, `구현막힘`, `마무리중단`). 본문 판정 줄도 같은 글자를 쓴다.
- 상태 낱말과 필드 목록은 각 에이전트 파일의 보고 형식이 정한다.
- 명령 출력은 고치지 않고 그대로 붙인다. 안 돌린 명령을 돌렸다고 적지 않는다.
- 질문은 "사용자에게 물어야 할 것" 절에 적는다. 없으면 "없음".
- 보고서를 파일로 따로 남기지 않는다(지침이 정한 산출물은 예외). 마지막 답변으로 돌려준다.

## 파일은 Edit로 부분 수정한다

- 이미 있는 파일은 Edit로 필요한 부분만 고친다. 전체 Write 재작성과 `sed -i`는 쓰지 않는다. 이유:
  병렬 worker가 같은 파일에 해 둔 체크를 날린다 / review.md의 지난 라운드 기록이 사라진다 /
  리치 마크다운 토큰(`[[ORCA_...]]` 꼴)이 끼어들거나 들여쓰기가 무너진 사고가 있었다.
- 새 파일만 Write로 만든다.
- `.md`를 고친 뒤 확인한다: 리치 마크다운 토큰 0개(`grep -c 'ORCA_RICH''_MD' <파일>`), 코드펜스 줄 개수 짝수,
  frontmatter의 `---` 두 줄과 원래 키가 그대로다.
- `.openspec.yaml` 마커는 각 에이전트 파일에 있는 명령 블록을 그대로 쓴다.
