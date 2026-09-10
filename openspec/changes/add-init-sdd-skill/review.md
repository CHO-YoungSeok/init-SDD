최종 판정: 통과 (라운드 1, 2026-09-11)

## 라운드 1 (2026-09-11)

RESULT: 통과 | change=add-init-sdd-skill | scope=만진파일 | blockers=0 | should_fix=0 | notes=2

## 리뷰: add-init-sdd-skill
판정: 통과
판정 기록: /Users/0stone_1004/orca/projects/init-SDD/openspec/changes/add-init-sdd-skill/review.md
기준으로 삼은 채택안: 없음(analyzer 생략 경로) — decision.md의 사용자가 정한 것 네 가지 + proposal.md 받아들일 조건 9개를 기준으로 삼았다.

### OpenSpec 검증
```
$ openspec validate "add-init-sdd-skill" --strict; echo "exit=$?"
Change 'add-init-sdd-skill' is valid
exit=0
```

### 요구사항 충족
specs/distribution/init-sdd-skill/spec.md의 요구사항을 하나씩 대조했다.

- "스킬은 이 저장소에 있고 도구를 좁혀서는 안 된다" → 충족. `.claude/skills/init-sdd/SKILL.md:1-4` frontmatter에 `name`/`description`만 있고 `allowed-tools` 없음. `description`에 발동 신호 여러 개 포함. `wc -l`=540, 코드펜스 44개(짝수) 재확인함.
- "개인 소유와 openspec CLI 소유를 갈라서 링크해야 한다" → 충족. `SKILL.md:75-97`에 링크 대상 4개 표와 링크하지 않는 것(`openspec-*` 6개, `commands/opsx/`) 표, `.claude/skills/`는 실제 디렉터리로 남긴다는 말, `.claude/` 통째 링크 금지 명시.
- "경로를 하드코딩해서는 안 된다" → 충족. `grep -n '/Users/' SKILL.md` 재실행, 매치 없음(exit=1). 원본/대상/개인 세 경로 모두 `SKILL.md:36-67`에서 실행 시점 산출로 서술.
- "개인 저장소가 없으면 만들고 이름이 겹치면 물어야 한다" → 충족. `SKILL.md:101-153`에 git 저장소 유무 판정, `.init-sdd-target` 짝 파일, 같다/다르다/기록없음 세 갈래 표, "덮어쓰는 길은 없다"는 말.
- "대상 프로젝트에 이미 있는 것을 잃어서는 안 된다" → 충족. `SKILL.md:155-176`에 다섯 갈래 표(없다/이 저장소 링크/다른 곳 링크/추적 중/미추적), 추적 중이면 예외 없이 멈춘다는 말, 멈출 때 대안 두 가지(개인 저장소로 옮기고 재실행 / `install.sh` 사용) 안내.
- "CLAUDE.md 조각은 원본 한 벌에서 뽑아야 한다" → 충족. `SKILL.md:223-235`에서 `sed`로 원본 마커 구획을 뽑고 조각 본문을 문서에 베끼지 않음(`grep -c '순서: '`=0으로 재확인). 빈 값이면 멈춤.
- "추적 여부에 따라 CLAUDE.md 처리가 갈라져야 한다" → 충족. `SKILL.md:253-268`에 `git ls-files --error-unmatch`로 판정 후 `.git/info/exclude`/`skip-worktree` 두 갈래, `.gitignore`는 고치지 않는다는 말.
- "skip-worktree 함정과 대처" → 충족. `SKILL.md:278-315`에 해제→보관→pull→복원→재적용 5단계가 실행 가능한 명령으로 적혀 있음.
- "링크가 공유 저장소 git에 새어서는 안 된다" → 충족. `SKILL.md:193-219`에 `.git/info/exclude`에 표시(`# init-sdd:begin`~`:end`)로 둘러 적는 절차.
- "걸었다 풀 수 있어야 하고 원래대로 돌아와야 한다" → 충족. `SKILL.md:318-382` "풀기" 절에서 링크 제거/마커 제거/skip-worktree 해제/exclude 표시 구간만 제거, 확인으로 `git status --porcelain`과 `git diff --exit-code`를 둘 다 요구.
- "지금 걸려 있는지 알 수 있어야 한다" → 충족. `SKILL.md:385-454` "상태 보기"에서 네 갈래(링크됨/실제파일/없음/끊긴 링크) 구분, `-L`을 먼저 보고 `-e`를 나중에 보는 이유까지 적음. 끊긴 링크의 위험성도 설명.
- "링크가 에이전트로 로드되는지는 사용자가 새 세션에서 확인해야 한다" → 충족. `SKILL.md:458-505` "확인된 것/확인되지 않은 것" 표로 정직하게 갈라 적고, 마지막 단계를 사용자에게 넘기며, 안 잡혔을 때 `cp -R` 대체 경로도 적음.
- "복사 방식과 서로 가리켜야 한다" → 충족. `SKILL.md:8-21`이 README.md의 "먼저 고른다" 절을 가리키고 본문을 중복 서술하지 않음. `SKILL.md:509-540` "복사 방식과 섞였을 때" 절이 살아있는 링크/끊긴 링크 각각의 위험을 표로 설명.

specs/distribution/sdd-install-script/spec.md (ADDED 1개):
- "복사 방식과 링크 방식 중 어느 것을 쓸지 알려 줘야 한다" → 충족. `README.md`에 "### 먼저 고른다" 절 추가(+19줄, `git diff -- README.md install.sh`로 재확인), `install.sh:169`에 안내 한 줄 추가, 복사 대상 목록·마커 추출 로직은 그대로(diff에 그 부분 변경 없음). `bash -n install.sh` exit=0, `bash install.sh --dry-run`을 임시 프로젝트에서 재실행해 새 안내 줄 출력 확인함.

proposal.md `## Impact` 받아들일 조건 9개도 모두 위 항목들로 커버되며 개별로 어긋난 것을 찾지 못했다. `git diff --stat`으로 이번 change가 손댄 기존 추적 파일이 `README.md`(+19/-0)와 `install.sh`(+1/-0) 뿐임을 재확인했다(에이전트 7개의 `model:` 변경은 범위 밖으로 이미 분리됨).

### 설계 준수
design.md의 D1~D11 결정을 모두 SKILL.md에서 확인했다. 특히:
- D5(정확히 4개만 링크, `.claude/skills/`는 실제 디렉터리) → `SKILL.md:71-97` 일치.
- D7(추적 중이면 예외 없이 멈춤, `-e`와 `-L`을 함께 봄) → `SKILL.md:155-176`, `389-403` 일치.
- D8(exclude 표시로 둘러싸기) → `SKILL.md:193-219`, `361-372` 일치.
- D9(확인/미확인 갈라 적기, 사용자에게 마지막 단계 넘김) → `SKILL.md:458-505` 일치.
- D10(고르는 안내 본문은 README 한 곳, install.sh/스킬은 가리키는 말만) → README.md diff와 SKILL.md 둘 다 일치.
- D11(allowed-tools 없음) → 확인함.

decision.md의 "링크 대상 — 골라서 링크한다" 표(`.claude/settings.json` 포함 4개, `openspec-*`/`commands/opsx` 제외, `settings.local.json` 절대 건드리지 않음)도 SKILL.md와 spec.md에 정확히 반영되어 있다. 채택안과 다르게 간 부분을 찾지 못했다(analyzer 생략 경로라 decision.md가 유일한 채택 기준).

### worker가 판정을 요청한 두 가지

**1. 줄 번호 참조를 SKILL.md 안에서는 서술형으로 바꾼 것** → 적절하다고 판정한다.
실제로 design.md(`:271`)와 tasks.md의 `install.sh:73-78`, `:84-93`, `:91`, `:93`, `:96-112`, `:120` 참조는 현재 `install.sh`와 대조한 결과 전부 정확히 일치했다(design.md/tasks.md 자체는 어긋나지 않았다 — 프롬프트가 언급한 "install.sh:69" 표현은 design.md·tasks.md·decision.md 어디에서도 찾지 못했다. grep으로 재확인함). 다만 **SKILL.md 본문**(최종 사용자 산출물, 다른 프로젝트에 복사돼 쓰일 문서)에는 애초에 줄 번호 참조가 하나도 없고(`SKILL.md:518` "복사 3단계의 `mkdir -p ...`"처럼 서술형), 이는 design.md/tasks.md(이 저장소 안에서만 쓰이는 내부 설계 기록)와 SKILL.md(배포되는 산출물)의 성격이 다르다는 점에서 타당한 선택이다. 줄 번호는 install.sh가 조금만 바뀌어도 깨지므로, 남의 프로젝트에서도 읽히는 문서에 안 쓴 것은 합리적이다.

**2. design.md R1 (a)의 표현을 안 고친 것** → note로 남긴다. 고칠 필요 없다.
design.md `Risks/Trade-offs R1`의 완화책 (a) 문구("개인 저장소가 제자리에 있는지 확인해라")는 그대로지만, 최종 산출물인 `SKILL.md:530-534`에서 "'개인 저장소가 제자리에 있는지 확인해라'는 안내만으로는 부족하다"고 **명시적으로 그 표현의 한계를 지적**하고, 실제 핵심 방어(상태 보기의 끊긴 링크 탐지)로 대체해 서술했다. design.md는 설계 당시의 사고 과정을 남기는 내부 기록이고, 이후 더 나은 결론(SKILL.md 본문)으로 넘어간 경위 자체가 design.md 문면에 드러나 있어 독자가 오도되지 않는다. 사용자가 실제로 읽고 따르는 문서(SKILL.md)가 이미 강화된 표현을 쓰고 있으므로 design.md까지 고칠 실익이 적다.

### 작업 완료 검증
tasks.md 체크된 32개(1.1~4.4) 중 최종 산출물과 직접 대조 가능한 항목(2.1~4.4, 20개)을 실제로 확인했다. 실측 절(1.1~1.7)은 설계 단계에서 임시 디렉터리로 수행되고 흔적이 남지 않는 성격이라 문서(SKILL.md, design.md R1/R2/R3)에 반영된 결과로 간접 확인했으며, design.md의 실측 표(R1의 `[[ -e ]]`/`cp` 결과 표, R2의 exclude 실측, R3의 8개/7개 글롭 유출)가 이 저장소의 실제 상태(`git ls-files .claude/agents | wc -l` = 7, `ls .claude/agents/*.md | wc -l`은 미추적 `agy.md` 포함 시 8)와 논리적으로 일치해 신뢰할 만하다. 안 된 것을 찾지 못했다.

### 되돌릴 체크 항목
없음.

### 발견 사항
1. [참고] design.md `## Risks / Trade-offs` R1의 완화책 (a) 문구가 SKILL.md에서 더 강한 표현으로 대체되었음에도 design.md 자체는 안 고쳐졌다. 위 "worker가 판정을 요청한 것 2"에서 다룸. 고치지 않아도 무방하다.
2. [참고] `openspec/changes/add-init-sdd-skill/decision.md:68-70`과 design.md의 install.sh 줄 번호 참조(`:73-78`, `:84-93`, `:91`, `:93`, `:96-112`, `:120`)는 현재 install.sh와 전부 정확히 일치하지만, 이 저장소 내부 문서이므로 앞으로 install.sh가 바뀌면 (SKILL.md와 달리) 어긋날 수 있다는 점은 그대로 남는 구조적 특성이다. 문제로 올리는 것은 아니고, 다음에 install.sh를 고칠 일이 있으면 참고하라는 정도다.

### 이번 change 것인지 확인 필요한 변경
없음. `git diff --stat`으로 확인한 추적 파일 변경은 `README.md`(+19)와 `install.sh`(+1)뿐이고 프롬프트의 "만진 파일" 목록과 정확히 일치한다. `.claude/agents/*.md` 7개의 `model:` 변경은 프롬프트가 이미 "범위 밖 — blocker로 올리지 마라"로 분류했고, diff 내용도 `model:` 한 줄씩만 바뀐 것으로 확인해 그 분류가 맞다고 판단했다.

### 다음 단계
통과. finalizer에게 넘긴다. regression-verifier의 병렬 검증 결과와 합쳐 최종 커밋 여부를 판단하면 된다.
