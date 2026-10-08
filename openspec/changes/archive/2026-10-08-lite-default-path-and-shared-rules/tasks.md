> 채택안: 없음 (analyzer 생략 경로) — 방향은 상위 change `plugin-lite-sdd-distribution` decision.md의 1안. 기준은 proposal의 받아들일 조건과 specs 델타 9개.
> 핵심 결정: ① 큰 작업 판정 기준은 orchestra `## 큰 작업 판정` 한 절에만, preparer는 `openspec instructions design` 출력에서 읽고 `size=작음|큼`을 RESULT에 올린다. ② 공용 규칙 7절은 `sdd-rules`, sync 절차는 `sdd-sync`(finalizer 1단계 본문을 옮김) — 둘 다 frontmatter는 `name`·`description`만. ③ 스캐폴드 스킬 이름·경로는 에이전트·orchestra·sdd-*에서 0건, archive는 승인 뒤 `openspec archive "<이름>" --yes`.
> 세부(절 제목 글자, 줄 수 목표, 지우면 안 되는 문장, orchestra 줄 단위 지도)는 design.md D1~D10에 있다. **각 작업 전에 해당 D절을 읽어라.**
> 규칙: 이미 있는 파일은 Edit 부분 수정만 (Write 재작성·`sed -i` 금지). 새 파일(1.1, 1.2)만 Write. 작업에 적힌 줄 번호는 **수정 전** 기준이다 — 앞 작업으로 밀리면 글자로 찾아라.
> 순서: **## 1 을 먼저 끝낸 뒤 ## 2~11 을 병렬로, ## 12 는 마지막에 한 명이** 한다 (## 2~10이 가리킬 sdd-rules·sdd-sync가 ## 1에서 생긴다). 병렬 worker에게는 번호 묶음(## N) 단위로 나눠 준다 — **묶음 사이에 겹치는 파일이 없다** (## 2~10은 각각 한 파일, ## 1은 새 파일 2개, ## 11은 init-sdd·CLAUDE.md·README 3개).

## 1. 공용 스킬 신설 (새 파일 2개)

- [x] 1.1 `.claude/skills/sdd-rules/SKILL.md`를 design.md D3대로 만든다 — frontmatter `name: sdd-rules`·`description:` 두 키만, 절 제목 7개를 D3의 글자 그대로. 확인: `grep -nE "^#+ (store 처리|code-explorer 부르기|대화형 스킬을 만났을 때)"` 각 1건, `grep -c "allowed-tools: Bash(openspec:"` ≥1, "스킬을 못 부른다는 이유로 절대 멈추지 마라." 1건, `grep -nE "skills/openspec-|openspec-(explore|propose|apply-change|archive-change|sync-specs|update-change)|Skill. 도구가 없을 수"` 0건, `grep -c ORCA_RICH_MD` 0 (D3-7 주의 — 토큰 이름을 이어 쓰지 않는다), `wc -l` ≤ 95
- [x] 1.2 `.claude/skills/sdd-sync/SKILL.md`를 design.md D4대로 만든다 — 지금 `.claude/agents/finalizer.md` 110-175의 sync 본문을 옮겨 오고 반영 순서(RENAMED → REMOVED → MODIFIED → ADDED)·은퇴는 모든 구획 반영 뒤 판단·design.md "Purpose 갱신" 반영 규칙을 보탠다. 확인: frontmatter 두 키만, `grep -c "openspec archive"` 0, 은퇴 여섯 조건과 `retire_capabilities` 콕 집어 보고 지시 있음, `validate --specs`·`validate "<이름>"` 종료코드 확인 있음, 스캐폴드 이름 grep 0건, `wc -l` ≤ 90

## 2. preparer.md

- [x] 2.1 `.claude/agents/preparer.md` frontmatter: `skills:`를 `[sdd-rules]`로, `description`에 "작은 작업이면 작업 목록(tasks)까지 쓴다"를 반영. 확인: `name`·`description`·`model`·`tools` 그대로, `model:` 값 불변
- [x] 2.2 같은 파일 17-65(쓰는 스킬·블록인용·대화형·store·code-explorer)를 지우고 design.md D7-preparer의 남길 것 6줄 안팎(흐릿한 요청 처리, 되돌릴 수 있는 일, store 전용 두 줄)으로 바꾼다. 확인: 반복 절 제목 grep 0건, `openspec-` 스킬 이름 0건
- [x] 2.3 같은 파일 2단계에 테스트 명령 찾기 한 줄, 6단계 뒤에 `### 7. 크기 판정`(D1 — 네 조건 문장을 쓰지 말고 `openspec instructions design` 출력과 orchestra `큰 작업 판정` 절을 가리킨다, 애매하면 큼)을 넣는다. 확인: **preparer.md에서** `grep -nE "여러 모듈|외부 의존|마이그레이션"` 0건 (낱말 grep은 preparer.md에만 한다 — 다른 에이전트 파일엔 판정과 무관한 "마이그레이션" 줄이 있다, D10-2), `instructions design`과 `큰 작업 판정`을 가리키는 문장 있음
- [x] 2.4 같은 파일에 `### 8. (작은 작업일 때만) 작업 목록과 델타`를 D2대로 넣고, 기존 7단계 "확인"을 9단계로 번호만 바꾼 뒤 작은 작업이면 `--strict` exit=0과 `instructions apply`의 `state: ready`를 확인하라는 줄을 더한다. 확인: `openspec instructions tasks`·`skip_specs`·작은 델타 선택 지시 있음, 6단계 마커 명령 블록·`Write`/`>` 금지·두 종료코드·세 가지 진단·"skip_specs를 설정하지 않았다면" 조건이 글자 그대로 남음
- [x] 2.5 같은 파일 "하지 말아야 할 것"과 보고 형식을 D2대로 고친다 — RESULT 준비완료 줄에 `size=작음|큼`(둘 중 하나만 적는다는 말 포함), 본문에 `크기:`·`테스트 명령:` 줄, 다음 단계 문구. 중단 줄은 그대로. 확인: `grep -n "size=" .claude/agents/preparer.md`가 준비완료 줄을 보여 줌, 준비중단 줄에 `branch=` 있고 `size=` 없음, `wc -l` < 241 (목표 ≤ 230)

## 3. analyzer.md

- [x] 3.1 `.claude/agents/analyzer.md` frontmatter `skills:`를 `[sdd-rules]`로. 확인: 다른 키·`model:` 값 불변
- [x] 3.2 같은 파일 21-55를 지우고 D7-analyzer의 3줄짜리 `## 산출물 형태 참고`로 바꾸고 (제목에 `쓰는 스킬`을 쓰지 않는다 — D7 역할 전용 절 제목 규칙), "하지 말아야 할 것"의 질문 줄과 보고 형식의 2안/3안 반복을 줄인다. 확인: 반복 절 제목 0건, 스캐폴드 이름 0건, analyzer-option-generation이 요구하는 지울 수 없는 지시(경로 CLI·사실/추측·스택·경고 줄·코드 수정 금지·RESULT에 `feasible=` 없음·`### 3. 방안 최소 3가지 만들기`의 사용자 후보 3규칙)가 모두 남음, `wc -l` < 175 (목표 ≤ 130)

## 4. designer.md

- [x] 4.1 `.claude/agents/designer.md` frontmatter `skills:`를 `[sdd-rules]`로. 확인: 다른 키·`model:` 값 불변
- [x] 4.2 같은 파일 32-82를 지우고 D7-designer의 `## 산출물 쓰는 절차`(처음 만들 때 / 이미 있는 산출물을 고칠 때 — 작은 작업에서 올라온 경우 포함)로 바꾼다. 확인: 반복 절 제목 0건, `openspec-update-change`·`openspec-propose` 0건, "작은 작업에서 올라" 문구 있음
- [x] 4.3 같은 파일 본문의 남은 스캐폴드 스킬 이름(2단계 decision.md 설명, 검증 절 끝 "Dependencies are enablers" 인용)을 D7-designer대로 바꾸고, 5단계 tasks 설명을 압축한다. 확인: "반드시 지킬 것"의 채택안 없음 중단, 1단계 원본 파일 우선 3문장, `retire_capabilities` 마커 블록, 7단계 두 종료코드·진단 3가지·`--specs` 금지가 남음, 스캐폴드 이름 grep 0건, `wc -l` < 311 (목표 ≤ 235)

## 5. worker.md

- [x] 5.1 `.claude/agents/worker.md` frontmatter `skills:`를 `[sdd-rules]`로. 확인: 다른 키·`model:` 값 불변
- [x] 5.2 같은 파일 27-74를 D7-worker의 `## 구현 절차의 기준`(약 8줄)으로 바꾸고, 13행 소개 문장과 93-98(설치 안 된 스킬 안내, design.md 의도적 예외 설명)을 D7-worker대로 고친다. 확인: 반복 절 제목 0건, 스캐폴드 이름 0건, `missingArtifacts` 두 갈래·`design.md: 없음(의도적)` 예외·재작업 `all_done` 예외·체크박스 Edit 규칙·"유일하게 파일을 쓰는 에이전트"·정리 모드 예외가 남음, `wc -l` < 242 (목표 ≤ 210)

## 6. reviewer.md

- [x] 6.1 `.claude/agents/reviewer.md` frontmatter `tools:` 줄 다음에 `skills: [sdd-rules]`를 넣는다. 확인: `name`·`description`·`model`·`tools` 그대로
- [x] 6.2 같은 파일 33-62(쓰는 스킬·store·code-explorer)를 D7-reviewer의 `## 기준 문서` 4줄로 바꾸고, 82행 괄호를 "(analyzer를 안 부른 경로)"로 고친다. 확인: 반복 절 제목 0건, `skills/openspec-` 0건, skip_specs 대체 기준과 만진 파일 없음 처리가 남음
- [x] 6.3 같은 파일에 D5의 작은 작업 테스트 1회 지시(새 소절 + "네 일이 아닌 것"·"하지 말아야 할 것" 예외 + 보고 형식 `### 테스트 (1회)` + RESULT `tests=`)를 넣는다. 확인: `grep -n "테스트: 1회"`·`grep -n "tests="` 결과 있음, `wc -l` < 224 (목표 ≤ 205)

## 7. regression-verifier.md

- [x] 7.1 `.claude/agents/regression-verifier.md` frontmatter `tools:` 줄 다음에 `skills: [sdd-rules]`를 넣고, 29-38(store·code-explorer)을 지운다. 확인: frontmatter 키 유지, 반복 절 제목 0건
- [x] 7.2 같은 파일 도입부·2단계·"하지 말아야 할 것"을 D7-regression-verifier대로 압축하고 "큰 작업이고 테스트 명령이 있을 때만 불린다" 한 줄을 넣는다. 확인: 만진 파일 없음 → 전체diff·`scope=전체diff`·"원인 구분 못 함", `git stash` 금지와 이유, `mktemp` 대조, RESULT 형식이 남음, `wc -l` < 148 (목표 ≤ 110)

## 8. finalizer.md

- [x] 8.1 `.claude/agents/finalizer.md` frontmatter `skills:`를 `[sdd-rules, sdd-sync]`로. 확인: 다른 키·`model:` 값 불변
- [x] 8.2 같은 파일 "먼저 확인할 것"의 regression 문단에 D5의 `regression 판정: 생략(...)` 처리를 넣는다 (이유 세 가지 — 작은 작업 / 테스트 명령 없음 / 실행 코드 변경 없음 — 어느 것이든 `생략(`이 글자로 있으면 진행) (줄이 아예 없으면 멈추는 규칙은 그대로). 확인: "생략(" 처리 문장과 "회귀 검증 안 거침" 멈춤 문장이 둘 다 있음
- [x] 8.3 같은 파일 60-106(code-explorer·쓰는 스킬·블록인용·대화형·store)을 3~5줄 `## 단계별로 쓰는 도구`(sync = 주입된 sdd-sync, archive = 5단계, 커밋 = git)로 바꾸고 (제목에 `쓰는 스킬`을 쓰지 않는다 — D7 역할 전용 절 제목 규칙), 1단계 sync 본문 110-175를 "주입된 `sdd-sync` 절차대로" 6~8줄로 바꾼다 (본문은 1.2에서 sdd-sync로 옮겨졌다). 확인: 반복 절 제목 0건, `grep -n "^## 쓰는 스킬" .claude/agents/finalizer.md` 0건, 스캐폴드 이름 0건, `sync불일치` 중단 지시 남음
- [x] 8.4 같은 파일 5단계 archive를 D7-finalizer대로 다시 쓰고 "하지 말아야 할 것"·보고 형식의 관련 줄을 맞춘다. 확인: 근거 ①(되돌릴 수 없음)이 먼저, ② stdin 문구 `no answer could be read from stdin` 남음, `openspec archive "<이름>" --yes` 한 길, "이중 적용"·"안전망이 아니다" 근거 없음, "Sync now" 문단 없음, review.md 직접 확인·최종 판정 줄·조건부통과 대조·경량/WIP 예외 남음, `wc -l` < 299 (목표 ≤ 215)

## 9. orchestra SKILL.md

- [x] 9.1 `.claude/skills/orchestra/SKILL.md` description(3행)과 파이프라인 그림(48-69)을 D8대로 고친다. 확인: 그림에 `size=` 분기, 작은 작업 갈래 `[worker]`, 큰 작업 갈래에만 `[designer]`, `[analyzer]`·`★ 사용자가 안을 고른다`가 기본 흐름 밖
- [x] 9.2 같은 파일 71-103을 D8의 `## 단계별로 따르는 지시`로 바꾸고, `/opsx:*` 직접 금지 절(105-112)의 108-109 문장만 D8대로 작은 작업에 맞게 고친다. 확인: `grep -nE "skills/openspec-|openspec-(explore|propose|apply-change|archive-change|sync-specs|update-change)"` 이 절에서 0건, `/opsx:*` 직접 금지 규칙과 "그냥 opsx로 빨리 해줘" 예외는 그대로, 108-109에 "큰 작업이면 결정 기록(decision.md)도"가 있음
- [x] 9.3 같은 파일 0단계 뒤에 `## 큰 작업 판정` 절을 D1·D5대로 넣는다. 확인: 네 조건 + 분석 요청이 한 절에, "애매하면 큰 작업", regression-verifier 조건("실행 코드" + "테스트 명령"), `grep -c "큰 작업"` ≥ 1
- [x] 9.4 같은 파일 1·4·5·6·7단계와 201-203행을 D8대로 고친다 (size 분기, 질문 문구, designer 제목과 ① 라벨, worker `design.md: 없음(의도적)`, 작은 작업 reviewer 프롬프트, 332행 커밋 관문 이유 문장, finalizer `regression 판정:` 줄 — 생략 이유 세 가지와 "실행 코드 여부는 worker의 만진 파일 목록으로" 판단 주체 포함). 확인: 4단계 ① 예시에 `analyzer 생략: 예`·`채택안: 없음`·멈춤 이유 그대로, ② 예시에 `사용자가 고른 안:` 있고 `analyzer 생략` 없음, `생략(실행 코드 변경 없음)` 있음, 332행 근처에 "작은 작업이면" 있음
- [x] 9.5 같은 파일 "흐름을 벗어나는 상황들"(364-370, 388, 410)과 "단계를 줄여도 되는 경우"(440-451)를 D6·D8대로 고친다. 확인: `grep -n "designer를 생략하면 안 된다"` 0건, 작은 작업 → 큰 작업 올리기 프롬프트에 `analyzer 생략: 예`·`채택안: 없음`·"이미 있다" 줄, 파일 전체 스캐폴드 이름 grep 0건, "절대 규칙"과 code-explorer 예외 문장 그대로, `wc -l` ≤ 470

## 10. install.sh

- [x] 10.1 `install.sh`를 D9대로 고친다 — 복사 대상에 `sdd-rules`·`sdd-sync`, 설치 확인 루프 4개 스킬, openspec 공식 스킬 6개 확인 블록(136-148) 삭제, "다음 할 일"에 기존 설치 안내 한 줄. 확인: `bash -n install.sh` rc=0, `CLAUDE.md` 조각 처리부(80-112)와 `copy_if_absent` 함수 불변

## 11. 문서와 링크 스킬

- [x] 11.1 `.claude/skills/init-sdd/SKILL.md`의 링크 대상을 D9의 여섯 경로로 맞춘다 (description, 표, 제목의 개수 낱말, 179행 "네 자리 모두", cp·ln·exclude 줄, 풀기·상태 보기·복사로 떨어지기의 `for` 목록, 새 세션 확인 스킬 목록). 확인: 세 `for p in` 줄이 같은 여섯 경로를 같은 순서로 가짐, "네 개"/"네 자리"가 링크 대상 개수를 말하는 곳에 남지 않음, frontmatter `name`·`description`만, 코드펜스 짝수
- [x] 11.2 `CLAUDE.md` 마커 구획 13-14행을 D9의 세 줄로 바꾼다. 확인: `grep -rln "^순서:" --exclude-dir=openspec .`이 `./CLAUDE.md` 하나, 마커 줄 두 개 그대로
- [x] 11.3 `README.md`를 D9 목록대로 부분 수정한다 (전면 재작성 금지). 확인: 기본(작은 작업) 경로와 큰 작업 경로 순서가 orchestra·CLAUDE.md와 같음, 네 조건 문장을 적지 않고 orchestra를 가리킴, `sdd-rules`·`sdd-sync`가 손 설치 명령과 설치 확인 둘 다에 있음, `agent-model-tier`·`orchestra`도 둘 다에 있음, "이미 설치한 프로젝트" 안내에 두 스킬 추가 + 에이전트 파일을 새 판으로 교체(비교해 옮김)가 둘 다 있음, "이게 왜 필요한가"의 개입 지점이 작은 작업(범위 밖 확인·리뷰·커밋 관문)과 큰 작업(+ 결정 기록/설계 요약)으로 나뉘어 있고 작은 작업에 결정 기록이 없음, "`Skill` 도구가 없을 수 있다" 0건, `openspec-*`·`commands/opsx/`를 복사하지 말라는 경고 남음, `^순서:` 줄 없음

## 12. 검증 (1~11 완료 뒤, 결과는 보고서 "검증 결과"에 출력 그대로)

- [x] 12.1 OpenSpec: `openspec validate "lite-default-path-and-shared-rules" --strict; echo "exit=$?"`와 `openspec status --change "lite-default-path-and-shared-rules" --json >/dev/null; echo "exit=$?"`가 둘 다 0
- [x] 12.2 grep 대조 (D10-2): 반복 절 제목 에이전트 0건·sdd-rules 각 1건, 스캐폴드 참조 0건(`.claude/agents .claude/skills/orchestra .claude/skills/sdd-rules .claude/skills/sdd-sync`), 7개 에이전트 `skills:`에 `sdd-rules`·finalizer만 `sdd-sync`·code-explorer에 `skills:` 없음, `allowed-tools: Bash(openspec:` 이 sdd-rules에만, `designer를 생략하면 안 된다` 0건, 네 조건 문장은 preparer.md에서 `grep -nE "여러 모듈|외부 의존|마이그레이션"` 0건, 다른 에이전트 파일은 걸린 줄을 읽어 판정 기준 문장인지 문장 단위로 판단 (regression-verifier.md "마이그레이션" 줄은 무관 — D10-2), `grep -n "^## 쓰는 스킬" .claude/agents/*.md` 0건
- [x] 12.3 무결성: 1~11에서 만지거나 만든 모든 `.md`에 `grep -c ORCA_RICH_MD` 0, 백틱 3개로 시작하는(들여쓰기 포함) 줄 개수 짝수, 에이전트 8개 frontmatter에 `name`·`description`·`model`·`tools`, sdd-rules·sdd-sync·init-sdd frontmatter에 `allowed-tools` 없음, `git diff --stat -- .claude/agents/code-explorer.md .claude/skills/agent-model-tier` 변경 없음
- [x] 12.4 줄 수: `wc -l .claude/agents/*.md .claude/skills/{orchestra,init-sdd,agent-model-tier,sdd-rules,sdd-sync}/SKILL.md` 합계 < 2,823, 에이전트 8개 합계 < 1,680, 각 에이전트 < 기준선(code-explorer는 40 이하). 파일별 숫자와 목표 대비를 표로 보고하고, 목표(D7 표) 미달 파일은 이유를 적는다
- [x] 12.5 작은 작업 CLI 재현 (D10-4, mktemp): change A(skip_specs)·B(작은 델타) 각각 `validate --strict` rc와 `instructions apply`의 `state`를 로컬 1.12.0과 `npx -y @fission-ai/openspec@1.14.1` 양쪽으로 보고 (npx 실패 시 출력과 함께 "못 함")
- [x] 12.6 스캐폴드 없이 (D10-5, mktemp 사본): `openspec-*` 6개를 지운 사본에서 `instructions proposal|specs|design|tasks|apply` 다섯 rc가 모두 0, skip_specs·작업 완료 change의 `openspec archive <이름> --yes` rc=0
- [x] 12.7 설치 (D10-6, mktemp): `bash -n install.sh` rc=0, `--dry-run` 출력에 `sdd-rules`·`sdd-sync` 복사 예정, 실제 설치 후 두 SKILL.md가 원본과 `cmp` 같음, 설치 확인 출력에 "에이전트: 8개"와 네 스킬 ok, openspec 공식 스킬 경고 없음
- [x] 12.8 sdd-rules 주입 (D10-7, mktemp 사본에서 새 `claude -p` 프로세스 — **`claude -p "<프롬프트>" --allowedTools "Agent"` 순서로 프롬프트를 플래그 앞에 둔다**, 반대로 두면 `--allowedTools`가 프롬프트를 삼켜 실패): 실행 전 기대 문장이 sdd-rules에만 있는지 `grep -rnF`로 확인, 8개 에이전트 각각의 출력 표를 보고 (7개 = 기대 문장, code-explorer = NONE). 실패해도 고치지 말고 그대로 보고한다
- [x] 12.9 메인 spec 경로 수 기준선 기록: `grep -ro '\.claude/' openspec/specs | wc -l` 값(지금 112)을 보고 — sync 뒤 값(임시 사본 실측 152, ③의 기준선)은 finalizer가 확인한다
