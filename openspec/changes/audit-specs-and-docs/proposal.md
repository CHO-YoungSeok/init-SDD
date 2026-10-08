# Proposal

## Why

플러그인 전환(③)과 자기 적용(⑤)이 끝난 뒤 메인 spec 21개와 문서·지시문을 전수 검수했다.
그 결과 고칠 것이 여럿 나왔다.

- **메인 spec이 1.14.1 strict 검증을 통과하지 못한다.** `./bin/sdd-openspec validate --all --strict`는 exit 1이고 spec 9개가 실패한다.
  실패 원인은 500자를 넘는 요구사항 28개다. 플러그인이 고정한 CLI가 1.14.1이므로 이 저장소의 정본 검증이 깨져 있다.
- **spec이 없는 파일과 옛 사실을 가리킨다.** 없는 `docs/example-run.md`를 시나리오가 읽는다.
  Purpose 두 개가 이미 고친 문제를 "지금 문제"로 적고 있다. "유일한 수단" 같은 거짓 문장이 있고, 옛 저장소 경로와 옛 CLI 버전(1.12.0 양쪽 확인)이 남아 있다.
  시나리오 이름이 본문과 안 맞고("7종", "5종", "실행 불가 시점"), 측정을 영구히 막는 MUST NOT 문장도 있다.
- **지시문끼리 모순이 있다.** 그중 셋은 파이프라인을 실제로 멈출 수 있다.
  - orchestra의 "설계 수정" designer 프롬프트에 `analyzer 생략: 예`도 고른 안도 없어서, designer가 규칙대로 `설계중단`한다.
  - orchestra의 "조사 요청 → analyzer만"은 change 없이 analyzer를 부르는 길인데, analyzer는 change가 있어야 돈다.
  - sdd-rules는 "capability 은퇴 = 보고만"이라고 하는데 sdd-sync는 조건이 맞으면 메인 spec을 지운다.
- **문서가 오래된 서술을 담고 있다.** "N번 타자", "decision.md가 항상 생긴다", 에이전트 7개 목록, 커밋 꼬리말 하드코딩, README 훅 문장 순서 같은 것들이다.

사용자 요청: "전반적으로 문서와 파일들을 검토하라. spec이 잘 작성되었나 검수하라. 수정이 필요하면 spec을 작성해서 spec을 검토하고 진행하라.
commit message를 각 작업 단위별로 잘 끊어서 넣도록 하라." 사용자는 "묻지 말고 진행"을 위임했다. 판단은 아래 "가정"에 추천 기본값으로 남긴다.

## What Changes

1. **메인 spec 요구사항 나누기**: 500자를 넘는 요구사항 28개를 나눈다. 같은 요구사항의 헤더와 살아남는 시나리오 이름은 지킨다.
   나머지 내용은 새 요구사항(ADDED)이나 시나리오로 옮긴다. 근거·경위 설명은 짧게 줄여도 되지만, SHALL/MUST 의무를 잃어서는 안 된다.
2. **spec 내용 바로잡기**(발견 목록의 "델타 spec" 행): 없는 파일 참조, 거짓 문장, 옛 경로·버전, 본문과 안 맞는 시나리오 이름, 측정 금지 MUST NOT,
   change 진행 중에만 뜻이 있는 문장, decision.md 서술을 고친다. 시나리오 이름을 바꾸는 곳은 CLI 제약(E2)에 맞는 방식을 designer가 실측해서 고른다.
3. **Purpose 갱신**: `project-context-completeness`와 `skill-tool-invocation-rationale` 두 개다. 델타로 바꿀 수 없으므로 design.md "Purpose 갱신" 목록에 올린다(sdd-sync 예외).
4. **지시문 Edit**(델타 없음): agents/*.md, skills/orchestra·sdd-rules의 모순과 낡은 서술을 고친다(발견 목록의 "지시문 Edit" 행).
5. **문서 Edit**: README.md, docs/field-validation.md, .claude/skills/init-sdd/SKILL.md의 낡은 서술을 고친다(발견 목록의 "문서 Edit" 행).
6. **커밋을 작업 단위별로 나눈다**: 아래 "받아들일 조건" 8.

### 발견 목록

심각도: 높음 = 파이프라인이 멈추거나 정본 검증이 깨짐 / 중간 = 사실과 다르거나 모순 / 낮음 = 표현·정리.
방식: **델타** = spec 델타 / **Purpose** = design.md Purpose 갱신 목록 / **지시문** = agents·skills Edit / **문서** = README·docs·init-sdd Edit.
알려진 후보 15개는 `K번호`로 표시했다.

#### A. spec 품질 (델타가 필요한 것)

| # | 위치 | 문제 | 심각도 | 판정 | 방식 |
|---|---|---|---|---|---|
| 1 (K1) | 메인 spec 9개(analyzer-option-generation 3, code-explorer-invocation 1, finalizer-archive-rationale-accuracy 1, lite-default-path 3, shared-pipeline-rules 3, skill-tool-invocation-rationale 1, init-sdd-skill 10, sdd-install-script 5, field-validation-record 1) | 500자 초과 요구사항 28개 → 1.14.1 `validate --all --strict` exit 1 | 높음 | 고침 | 델타 |
| 2 (K4) | `agent-instructions/analyzer-option-generation/spec.md:127-133` | 시나리오 "예제 실행 문서"가 없는 `docs/example-run.md`를 읽는다. 확인할 수 없는 시나리오다 | 높음 | 고침(시나리오 제거, 필요한 취지는 README 확인 시나리오에 둔다) | 델타 |
| 3 | `analyzer-option-generation/spec.md:124-125, 148-149` | "큰 작업은 결정 기록(decision.md)이 더해진다"고 적혀 있다. 실제로는 analyzer를 불렀을 때만 생긴다(orchestra:266, designer:108) | 중간 | 고침 | 델타 (+문서 #31) |
| 4 | `analyzer-option-generation/spec.md:83, 135`, `finalizer-archive-rationale-accuracy/spec.md:24, 30`, `shared-pipeline-rules/spec.md:28` | 시나리오 이름이 본문과 안 맞는다("파이프라인 그림의 화살표", "…근거를 제거한다", "일곱 절이 각각 한 번씩 있다", "README 재확인") | 낮음 | 고침 | 델타 |
| 5 | `code-explorer-invocation:30-35`, `analyzer-option-generation:160-189`, `lite-default-path:20, 97`, `finalizer-archive-rationale-accuracy:19` | "변경 전과 대조", "군살을 뺀 뒤", "제거된 문장은 보고되어 있다"처럼 change 진행 중에만 뜻이 있는 문장. 메인 spec에서는 확인할 수 없다 | 낮음 | 고침(지금 상태로 확인되는 문장으로) | 델타 |
| 6 | `lite-default-path/spec.md:40-41` | "로컬 CLI(1.12.0)와 npx 1.14.1 양쪽"으로 확인하라는 옛 기준. 지금은 `sdd-openspec`(1.14.1) 하나다 | 중간 | 고침 | 델타 |
| 7 | `shared-pipeline-rules/spec.md:100` | 시나리오 전제가 이 저장소의 `.claude/skills/openspec-*` 6개를 지우는 것이다. 그 디렉터리는 이제 없다 | 중간 | 고침(임시 프로젝트 기준으로) | 델타 |
| 8 | `shared-pipeline-rules/spec.md:154` | "서브에이전트를 부를 때는 `sdd:<이름>`"이 아무 에이전트나 불러도 되는 것처럼 읽힌다. 대상은 `sdd:code-explorer`다 | 낮음 | 고침 | 델타 |
| 9 (K3) | `distribution/sdd-install-script/spec.md:14-17` | "`bash -n`·dry-run이 유일한 수단이고 config context가 그렇게 규정한다"는 거짓이다. context는 수단 6가지를 적는다 | 중간 | 고침 | 델타 |
| 10 (K6) | `sdd-install-script/spec.md:269, 328` | 시나리오 이름 "README가 5종을 말한다"(본문은 스킬 3개), "설치 확인이 7종을 본다"(제품은 6종). 269는 275 "README가 공용 스킬 두 개도 말한다"와 거의 겹친다. 본문에 "CLI가 막아 이름을 둔다"는 메타 문장이 있다 | 중간 | 고침(이름 맞춤·겹침 합치기·메타 문장 제거) | 델타 |
| 11 | `sdd-install-script/spec.md:62-67` | "`순서:` 줄을 담은 파일이 정확히 하나"는 `grep -rl '순서:'`로 재면 2개(`skills/sdd-sync/SKILL.md:25` "반영 순서:")가 나온다. 확인 패턴이 모호하다 | 낮음 | 고침(정확한 패턴) | 델타 |
| 12 (K7) | `process/field-validation-record/spec.md:83-84, 91` | "전환 뒤에는 실행할 수 없다는 서술이 남아 있어서는 안 된다(MUST NOT)"가 "전환 뒤 실행할 수 없다"로도 읽힌다. 84행은 메타 문장이고, 시나리오 이름 "실행 불가 시점"은 본문(실행 위치)과 안 맞는다. (알려진 후보의 "11행"은 실제로 83행이다) | 중간 | 고침(긍정형 SHALL로) | 델타 |
| 13 | `field-validation-record/spec.md:33, 98-99` | "양식을 도입하는 시점에는 측정을 돌리지 않아야 한다(MUST NOT)", "기록 표 값 칸은 비어 있어야 한다(MUST)"가 영구 규칙이다. 첫 실측이 spec을 깬다. Purpose(기록·비교)와 모순된다 | 중간 | 고침(`evals/results/` 미추적 규칙만 영구로, 빈 칸 규칙은 없앤다) | 델타 |
| 14 | `field-validation-record/spec.md:5, 31, 37, 80` + `docs/field-validation.md:12-13`, `evals/README.md:25`, `evals/lite-path-small-task/prompt.md:6` | "경량 경로 / 정식 경로"가 orchestra 용어(작은 작업 경로 / 큰 작업 경로 / 경량 모드)와 다르다. 문서의 정의(orchestra+worker+reviewer)는 어느 쪽과도 맞지 않는다 | 중간 | 고침(orchestra 용어로 맞춤. Purpose 문장은 Purpose 갱신 목록에) | 델타 + 문서 |
| 15 | `distribution/session-start-hook/spec.md:21` | 셸에서 훅을 직접 돌리는 것을 "사람이 훅을 검증하는 유일한 수단"이라고 하는데, 41-44행 시나리오는 실제 세션으로 검증한다 | 낮음 | 고침("유일한" 삭제) | 델타 |
| 16 | `distribution/sdd-plugin/spec.md:154-159` | 시나리오 "README에 다섯 가지가 있다"인데 요구사항 목록은 4개다. `--plugin-dir`는 다른 요구사항 몫이다 | 낮음 | 고침 | 델타 |
| 17 | `sdd-plugin/spec.md:36, 184`, `init-sdd-skill/spec.md:387` | "관문 1.3 실측", "이 change의 검증 기록", "이 change의 산출물" 같은 change 안 참조가 메인 spec에 남았다 | 낮음 | 고침(archive 이름을 적거나 지움) | 델타 |
| 18 | `init-sdd-skill/spec.md:110-111` | 옛 저장소 절대 경로 `/Users/0stone_1004/orca/projects/init-SDD`와 "곧 옮겨질 예정"이 남았다(이미 옮겼다) | 낮음 | 고침(경로 글자는 빼고 규칙만 둔다) | 델타 |
| 19 | `distribution/sdd-init-command/spec.md:11, 25` | 11행 "문서에서는 '`/sdd:init`(초기화)'로 적는다"는 대상 문서가 없어 확인할 수 없고, 따르는 파일도 0개다. 25행은 `openspec/` 유무, 30행·`bin/sdd-init:42`는 `config.yaml` 유무를 기준으로 삼아 서로 다르다 | 낮음 | 고침 | 델타 |
| 20 (K2) | `agent-instructions/project-context-completeness/spec.md:5-6` | Purpose가 "지금은 `context:` 밑이 전부 주석이라…"인데 이미 채워져 있다 | 중간 | 고침 | Purpose |
| 21 | `agent-instructions/skill-tool-invocation-rationale/spec.md:5-7` | Purpose가 "지금 근거로 적힌 'Skill 도구가 없을 수 있다'"라고 하는데 그 문장은 이미 지워졌다(grep 0건) | 중간 | 고침 | Purpose |
| 22 (K5) | `prompt-only-handoff-defense`, `artifact-file-precedence-over-prompt`, `openspec-metadata-marker-safety` | `.claude/agents/designer.md` 같은 저장소 기준 옛 경로가 있다는 후보 | — | **해당 없음**: 실측 결과 이미 고쳐졌다(`command grep -n '\.claude/'` 세 파일 0건, exit=1) | — |
| 23 | 접두사 대비 규칙(`code-explorer-invocation:83-97`, `shared-pipeline-rules:147-163`, `sdd-plugin:71-89`), CLI 대비 규칙(`shared-pipeline-rules:152-153`, `openspec-cli-wrapper:39-52`), 기본 경로 정의(`analyzer-option-generation:191-205`, `lite-default-path:9-21`), 두 이름 경고(spec 3곳) | 같은 규칙이 여러 capability에 겹친다. 지금은 서로 맞는다 | 낮음 | **둔다**: 모순이 없다. 소유자를 정리하면 diff가 크고, 대비 규칙은 기존 설치 방식을 없애는 change에서 함께 지워진다 | — |
| 24 | `code-explorer-role/spec.md:58` | `.claude/`를 code-explorer가 고치면 안 되는 예로 든다 | 낮음 | **둔다**: 사용자 프로젝트 기준으로는 맞고, code-explorer에게 쓰기 도구가 없다 | — |
| 25 | spec 첫 줄 제목 형식 제각각(`code-explorer-role`의 제목이 `# code-explorer Specification`), 시나리오 명령이 `openspec …`로 적힘 | 표기 불일치 | 낮음 | **둔다**: 델타로 제목을 못 바꾼다. 명령은 부분 문자열로 맞는다 | — |
| 26 (K13) | `session-start-hook/spec.md:80` ↔ `hooks/session-start.sh:30` | 권한 점검이 프로젝트 파일 두 개만 본다. 전역 `~/.claude/settings.json`에 권한을 둔 사람에게 "권한 없음"이 잘못 뜬다. 부분 문자열 grep이라 deny 줄도 통과한다. 파일은 spec대로다 | 중간 | **둔다(동작)**: 훅 동작 변경은 범위 밖이므로 후속 change 후보로 남긴다. 대신 README 권한 절에 "전역 설정에 두었으면 이 경고는 무시해도 된다"는 한 줄을 더한다(문서 #36) | 문서 |
| 27 | `sdd-install-script/spec.md:156` ↔ `install.sh:44-46`, `:186-190`, `install.sh:167` | 복사 방식은 openspec "1.12 이상"을 권하지만 파이프라인은 1.14.1을 전제한다. `openspec init --tools claude`가 필요 없는 스캐폴드를 깐다. 끝 안내에 "권장" 낱말이 없다 | 중간 | **둔다**: install.sh 동작 변경은 범위 밖이다(폐기 예고, 사용자 결정: 실전 검증 뒤 제거). 후속 후보로 남긴다 | — |

#### B. 지시문·문서 (델타 없음)

| # | 위치 | 문제 | 심각도 | 판정 | 방식 |
|---|---|---|---|---|---|
| 28 | `skills/orchestra/SKILL.md:382` | "설계 수정이 필요해졌을 때" designer 프롬프트에 `사용자가 고른 안:`도 `analyzer 생략: 예`도 없다. designer.md:25 규칙대로 `설계중단 reason=채택안 없음`으로 멈춘다. "decision.md의 채택안도 갱신"은 decision.md가 없는 경로를 빠뜨린다 | 높음 | 고침 | 지시문 |
| 29 | `skills/orchestra/SKILL.md:466` | "조사 요청 → analyzer만". analyzer는 change 이름과 changeRoot가 있어야 돈다(analyzer.md:31-38) | 높음 | 고침(preparer → analyzer 순서로 적는다. analyzer에 조사 모드를 새로 만드는 일은 범위 밖) | 지시문 |
| 30 (K10) | `skills/sdd-rules/SKILL.md:63` ↔ `skills/sdd-sync/SKILL.md:34-46`, `README.md:361`, `agents/designer.md:43, 145` | sdd-rules는 capability 은퇴를 "보고만"이라 하고 예외가 없다. sdd-sync는 여섯 조건이 맞으면 finalizer가 메인 spec을 지운다. 마커는 designer가 사용자 승인 없이 넣는다 | 높음 | 고침(sdd-rules에 "finalizer가 sdd-sync 여섯 조건을 다 만족하고, 커밋 관문에서 사용자가 승인한 change일 때만" 예외를 적는다. README 361도 맞춘다) | 지시문 + 문서 |
| 31 | `README.md:44-46, 96, 370`, `skills/orchestra/SKILL.md:68, 88, 104`, `agents/reviewer.md:174`, `agents/designer.md:238` | 큰 작업이면 decision.md가 생긴다고 적었다. 실제로는 analyzer를 불렀을 때만 생긴다. reviewer 보고 형식에는 decision.md가 없을 때의 값이 없다 | 중간 | 고침 | 문서 + 지시문 |
| 32 (K9) | `agents/designer.md:3, 13-14, 27-28, 64-66, 108, 231, 238` | `analyzer 생략: 예`를 "버그 수정처럼 / (원인이 명확한 버그 등)"으로 설명하지만, 이것은 analyzer 없는 큰 작업 전부의 평소 경로다. "3번 타자, 사용자가 고른 방안을 받아서"라고 적었다. analysis.md를 늘 읽고, 보고 형식이 `채택안=<N안>`만 받는다 | 중간 | 고침 | 지시문 |
| 33 | `agents/analyzer.md:3, 13`, `agents/worker.md:3, 33`, `agents/reviewer.md:3` | "2번/4번/5번 타자"(analyzer는 opt-in이고 작은 작업은 순서가 다르다). analyzer가 "코드베이스 탐색/검색도 맡는다"고 하는데 그것은 code-explorer 몫이다. worker는 "7개 중 유일하게 파일을 쓰는 에이전트"라고 하는데 다른 에이전트도 산출물을 쓴다 | 중간 | 고침 | 지시문 |
| 34 (K8) | `agents/reviewer.md:129-130` | "(없으면 프로젝트에서 찾음)"과 "명령이 없으면 '테스트 없음'"이 서로 모호하다. 테스트 명령은 preparer가 찾는다 | 중간 | 고침(`없음`이면 찾지 않고 "테스트 없음") | 지시문 |
| 35 (K11) | `agents/finalizer.md:116` | 커밋 꼬리말이 `Co-Authored-By: Claude <noreply@anthropic.com>`로 고정돼 있다. 실제 커밋(최근 8개)은 하네스가 준 모델명 줄을 쓴다 | 낮음 | 고침("하네스·사용자가 지정한 attribution 줄을 쓰고, 없을 때만 기본 줄") | 지시문 |
| 36 (K12) | `README.md:171-175`, `skills/init/SKILL.md:78` | "다음 세션부터 훅이 지휘 규칙을 넣는다."가 "끄려면 …" 뒤에 와서 "다시 켜진다"로 읽힌다 | 낮음 | 고침(문장을 켜기 설명 바로 뒤로 옮기고, 켜기·끄기 모두 다음 세션부터라고 적는다) + #26의 한 줄 | 문서 |
| 37 (K15) | `skills/sdd-rules/SKILL.md:76`, `agents/analyzer.md:18, 92-97`, `agents/reviewer.md:134` | 하네스가 "보고서 파일" Write를 막은 사례(analysis.md)가 있다. "(지침이 정한 산출물은 예외)"만으로는 analysis.md·review.md·verification.md가 그 예외라는 것이 드러나지 않는다 | 중간 | 고침(sdd-rules에 "analysis.md·review.md·verification.md·decision.md는 다음 에이전트가 읽는 파이프라인 산출물이다. 보고서 파일이 아니다"를 한 줄 적는다. 막히면 보고서에 막힌 사실을 적는다) | 지시문 |
| 38 | `agents/regression-verifier.md:102` | 보고 양식이 "stash 대조했으면 그 결과"라고 하는데 53·79행은 `git stash`를 금지한다 | 중간 | 고침(`git show <기준커밋>:<파일>` 대조) | 지시문 |
| 39 | `agents/preparer.md:22` | `openspec store list --json`. 다른 곳은 전부 `sdd-openspec`이다 | 중간 | 고침 | 지시문 |
| 40 | `skills/orchestra/SKILL.md:40` | 보고 예시 RESULT 줄에 reviewer가 늘 내는 `tests=`가 없다 | 낮음 | 고침 | 지시문 |
| 41 | `README.md:66-67` | "아니면 바로 설계로 갈까요?". 작은 작업에는 설계 단계가 없다. orchestra:180은 "바로 진행할까요?"다 | 낮음 | 고침 | 문서 |
| 42 | `README.md:84` | 조사 요청 → "analyzer 1번" (#29와 같은 문제) | 높음 | 고침 | 문서 |
| 43 | `README.md:293` vs `:304`, `.claude/skills/init-sdd/SKILL.md:3, 514` | 에이전트 파일 목록이 7개다(code-explorer 빠짐). 확인 명령은 8을 기대한다 | 낮음 | 고침 | 문서 |
| 44 | `README.md:331-333` vs `bin/sdd-init:137-140` | context 예시 라벨이 다르다(`Tech stack / 테스트 / 빌드` vs `기술 스택 / 테스트 명령 / 빌드 명령`) | 낮음 | 고침(README를 bin에 맞춘다) | 문서 |
| 45 | `docs/field-validation.md:12, 21, 26, 85` | "② 이후", "③ 이후" 표시가 끝난 단계를 가리킨다 | 낮음 | 고침(#14와 함께) | 문서 |
| 46 | `docs/field-validation.md:32` | 기준선에 `agent-model-tier`, "에이전트 8개"가 있다 | 낮음 | **둔다**: 그 시점 기준선 기록이다. 필요하면 "플러그인 전 파일 기준" 한 마디만 덧붙인다(designer 재량) | — |
| 47 (K14) | `README.md:384-394` ↔ `.claude/CLAUDE.md:3-9` | 개발 띄우기 설명(`--plugin-dir .`)이 두 곳에 있다. 모순은 아니다 | 낮음 | **둔다**: `sdd-plugin` spec이 README에 `claude --plugin-dir .`를 요구한다. 겹치는 양이 몇 줄뿐이다 | — |
| 48 | `evals/*/prompt.md:3` | `allowed_tools`에 `Agent`가 없어서 플러그인 켠 실행이 위임을 못 할 수 있다 | 낮음 | **둔다**: 실전 측정은 범위 밖이다. 측정 change에서 판단한다(후속 후보) | — |

### 고칠 것 나누기

- **델타가 필요한 것**: #1~#19 (그리고 #14의 spec 쪽). Purpose 갱신은 #20, #21, #14의 Purpose 문장.
- **델타 없이 Edit**: #28~#45 (지시문 #28~#35·#37~#40, 문서 #31·#36·#41~#45, #26의 README 한 줄).
- **둔다**: #22(이미 고쳐짐), #23~#25, #26(동작), #27, #46~#48. 근거는 표에 있다. 후속 후보는 #26·#27·#48이다.

## 받아들일 조건

- [ ] 1. `./bin/sdd-openspec validate --all --strict; echo "exit=$?"` → **exit=0**(1.14.1 기준 실패 0개). 지금은 exit=1, 13 passed / 9 failed(22 items).
      change가 진행 중일 때(델타 반영 전)와 sync 뒤 메인 spec 기준 모두에서 잰다.
- [ ] 2. `./bin/sdd-openspec validate "audit-specs-and-docs" --strict` → exit=0.
- [ ] 3. 메인 spec 요구사항 본문 500자 초과가 0개다. 재는 방법: 저장소 루트에서 spec마다 `./bin/sdd-openspec show <전체 id> --type spec --json --no-scenarios`의 각 `requirements[].text` 길이.
      전체 id는 `openspec/specs/` 아래 경로다(예: `agent-instructions/lite-default-path`, 짧은 이름은 exit 1). 21개 전부를 잰다(design.md 결정 8의 6).
- [ ] 4. 나눈 요구사항의 원래 헤더와 시나리오가 없어지지 않는다. 메인 spec 전체 시나리오 개수가 줄지 않는다. 일부러 지우거나 합친 #2·#10은 예외이며 개수를 보고한다.
      원래 요구사항 본문의 SHALL/MUST 의무가 빠지지 않는다. 나눈 쪽 어딘가에 남아 있는지 designer 대조표로 확인한다.
- [ ] 5. 발견 목록 "고침" 항목마다 반영 여부를 확인했다. 각 행의 위치를 grep해 문제 문구가 0건이거나, 고친 문구가 들어갔다. "둔다" 항목은 근거가 이 표에 남아 있다.
- [ ] 6. `command grep -rn 'example-run' openspec/specs` → 0건. `command grep -rn 'orca/projects' openspec/specs` → 0건. `command grep -n '유일한 수단' openspec/specs/distribution/sdd-install-script/spec.md` → 0건.
- [ ] 7. 고친 `.md` 파일 전부 무결성: 리치 마크다운 토큰 0개, 코드펜스 줄 수 짝수, frontmatter `---` 두 줄과 원래 키 유지.
      `claude plugin validate . --strict` exit=0, `claude plugin validate .claude-plugin/plugin.json --strict` exit=0.
- [ ] 8. **커밋이 작업 단위별로 나뉜다.** 최소 단위: ① change 산출물(proposal·specs·design·tasks), ② 지시문(agents·skills) 수정, ③ 문서(README·docs·init-sdd) 수정, ④ 메인 spec sync(Purpose 갱신 포함), ⑤ archive.
      한 커밋에 서로 다른 단위가 섞이지 않는다. `git log --stat`으로 확인한다. 각 메시지는 기존 관례(`type(scope): 한국어 서술`)를 따른다.
- [ ] 9. 플러그인 실행 파일(`bin/*`, `hooks/*`, `install.sh`)은 바뀌지 않는다: `git diff --stat <시작커밋>.. -- bin hooks install.sh .claude-plugin` → 빈 출력.

## 범위 밖

- 플러그인 동작 변경: `bin/*`, `hooks/session-start.sh`, `.claude-plugin/*`, `install.sh` 코드 수정(#26·#27은 후속 후보로만 남긴다)
- `install.sh`·`.claude/skills/init-sdd/` 삭제(사용자 결정: 실전 검증 뒤)
- 실전 측정(`claude plugin eval` 실행, 기록 표 채우기), eval 사례 설계 변경(#48)
- 새 기능: analyzer 조사 모드 신설, 겹치는 spec 규칙의 소유자 통합(#23)
- 상위 기록 change `plugin-lite-sdd-distribution`의 산출물 수정

## 가정 (사용자가 "묻지 말고 진행"을 위임해 추천 기본값으로 정함)

- G1. 실제 메인 spec은 21개다(요청의 "23개"는 세는 방식 차이로 본다). `validate --all`의 22 items = spec 21 + 진행 중 change 1.
- G2. 요구사항을 나눌 때 근거·경위 문단은 줄이거나 시나리오 바깥 설명으로 옮겨도 된다. SHALL/MUST 의무와 시나리오는 지킨다.
- G3. 시나리오 이름을 바꿔야 하는 곳(#4·#10·#12)은 designer가 1.14.1로 실측해 고른다. MODIFIED로 이름이 바뀌는지 보고, 막히면(E2) REMOVED + ADDED(새 헤더)로 바꾼다.
      둘 다 비용이 크면 그 시나리오만 이름을 두고, 본문 메타 문장을 지우는 선에서 멈춘다.
- G4. capability 은퇴 예외(#30)는 "커밋 관문의 사용자 승인 = 은퇴 승인"으로 본다. orchestra 커밋 관문 알림에 은퇴 대상을 보여 주는 문구가 필요하면 designer가 함께 넣는다.
- G5. 조사 요청(#29·#42)은 "preparer → analyzer"로 적는다. analyzer에 change 없는 모드를 만드는 것보다 변경이 작다.
- G6. "경량 경로 / 정식 경로"(#14)는 orchestra 용어(작은 작업 경로 / 큰 작업 경로)로 맞춘다. orchestra의 "경량 모드"(worker → finalizer)와 헷갈리지 않게 한다.
- G7. 이 change는 브랜치 `plugin-lite-sdd-distribution`에서 진행한다(오케스트레이터 지시). 상위 기록 change와 겹치는 것은 질문으로 올리지 않는다.

## Capabilities

### New Capabilities

없음.

### Modified Capabilities

- `agent-instructions/analyzer-option-generation`: 긴 요구사항 3개 나누기, `docs/example-run.md` 시나리오 제거, decision.md 서술(analyzer를 불렀을 때만), 시나리오 이름 맞춤, 진행 중에만 뜻이 있는 문장 정리
- `agent-instructions/code-explorer-invocation`: 긴 요구사항 1개 나누기, "변경 전과 대조" 문장 정리
- `agent-instructions/finalizer-archive-rationale-accuracy`: 긴 요구사항 1개 나누기, 시나리오 이름 맞춤
- `agent-instructions/lite-default-path`: 긴 요구사항 3개 나누기, CLI 두 버전 확인 기준을 `sdd-openspec`으로
- `agent-instructions/shared-pipeline-rules`: 긴 요구사항 3개 나누기, 시나리오 전제(임시 프로젝트)·이름, `sdd:code-explorer` 표현
- `agent-instructions/skill-tool-invocation-rationale`: 긴 요구사항 1개 나누기 (Purpose는 갱신 목록)
- `distribution/init-sdd-skill`: 긴 요구사항 10개 나누기, 옛 절대 경로·change 안 참조 제거
- `distribution/sdd-install-script`: 긴 요구사항 5개 나누기, "유일한 수단" 거짓 문장, 시나리오 이름("5종"·"7종")과 겹침, `순서:` 확인 패턴
- `distribution/sdd-plugin`: "다섯 가지" 시나리오와 요구사항 목록 맞춤, change 안 참조 제거
- `distribution/sdd-init-command`: 확인할 수 없는 표기 규칙, 초기화 판단 기준(`config.yaml`) 맞춤
- `distribution/session-start-hook`: "유일한 수단" 표현
- `process/field-validation-record`: 긴 요구사항 1개 나누기, MUST NOT 긍정형으로, 영구 측정 금지·빈 칸 규칙 정리, 비교 대상 용어를 orchestra에 맞춤

Purpose만 바뀌는 `agent-instructions/project-context-completeness`는 델타 없이 design.md "Purpose 갱신" 목록으로 처리한다.
`skill-tool-invocation-rationale`과 `field-validation-record`의 Purpose도 같은 목록에 올린다.

## Impact

- 메인 spec 12개(델타) + Purpose 3개, 지시문 `agents/{analyzer,designer,finalizer,preparer,regression-verifier,reviewer,worker}.md`, `skills/{orchestra,sdd-rules}/SKILL.md`,
  문서 `README.md`, `docs/field-validation.md`, `evals/README.md`, `evals/lite-path-small-task/prompt.md`, `.claude/skills/init-sdd/SKILL.md`, `skills/init/SKILL.md`
- 실행 파일·플러그인 선언은 바뀌지 않는다.
- 지시문은 Edit 부분 수정만 한다(config context).
