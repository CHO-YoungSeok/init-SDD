> 경로: analyzer 생략 (방안 비교 없음). 기준은 proposal.md 받아들일 조건과 `specs/process/field-validation-record/spec.md`.
> 핵심 결정: 문서 목차·표 양식·판정 규칙 문구는 design.md D1~D3 을 그대로 따른다. 사례 폴더는 `claude plugin eval init --bare` 로 만들고 frontmatter 는 손대지 않는다(D4).
> 하지 않는 것: 측정 실행, `claude plugin eval` 실행, 임계값·목표 숫자 기입, 기존 파일(에이전트·스킬·README·CLAUDE.md·.gitignore) 수정.

## 1. 측정 문서 `docs/field-validation.md`

- [x] 1.1 `docs/` 디렉터리를 만들고 `docs/field-validation.md` 를 design.md D1 의 목차 1~9 순서·제목대로 작성한다. 확인: `grep -n '^## ' docs/field-validation.md` 가 비교 대상 / 측정 항목과 수단 / 기준선 / 측정 절차 / 기록 표 / 판정 규칙 / claude plugin eval / 한계 8개 절을 이 순서로 보여 준다
- [x] 1.2 "비교 대상" 표에 직접 작업 / 경량 경로 / 정식 경로 3행을 D1-2 의 뜻으로 적고, 경량 경로의 측정 가능 여부를 "② 이후" 로 적는다. 확인: 세 대상 이름이 표에 각 1번씩 있다
- [x] 1.3 "측정 항목과 수단" 표에 품질 / 소요 시간 / 토큰 3행을 D1-3 대로 적는다 (품질 판정 기준 a·b·c, `/cost`, `claude plugin details <name>`, 세션 로그, 각 수단의 재는 것·못 재는 것, `/cost` 서브에이전트 포함 여부는 측정 때 확인). 확인: `grep -c -E '/cost|plugin details|세션 로그' docs/field-validation.md` 가 3 이상
- [x] 1.4 "기준선" 표에 2,821줄 / 약 1.5k 토큰 / 약 80k 토큰을 측정 방법·출처(`openspec/changes/plugin-lite-sdd-distribution/analysis.md` 와 archive 뒤 경로)·실측/추정 구분과 함께 적고, 2,823줄 재측정 각주를 단다. 값은 `analysis.md` 62~65행에서 다시 읽어 옮긴다. 확인: `grep -n -E '2,821|1\.5k|80k|추정' docs/field-validation.md`
- [x] 1.5 "측정 절차" 를 D1-5 의 5단계 이내 번호 목록으로 적는다. 확인: 번호 목록 항목 5개 이하
- [x] 1.6 "기록 표" 를 D2 의 14열 양식 그대로 넣고 값 칸이 빈 행 3개(#1~3)를 둔다. 표 위에 약어(D/L/F) 뜻과 품질 칸 기록 형식(`n/m, 재작업 r`)을 표 밖 문장으로 적고, 아래에 `### 단계 기여 메모` 빈 표(5열, 빈 행 1개)를 둔다. 확인: 기록 표의 각 행이 `|` 15개를 가지며 # 열 외 값 칸이 비어 있다
- [x] 1.7 "판정 규칙" 을 D3 의 `| # | 조건 (측정 결과) | 조치 |` 표 8행으로 적고, 표 위에 "동등 임계값과 판정에 필요한 작업 건수 N 은 측정 뒤 사용자가 정한다", 표 아래에 "규칙끼리 충돌하면 사용자가 정한다" 를 적는다. 확인: analyzer / designer / regression-verifier 가 조치 열에 각각 1번 이상 나오고, `grep -n '측정 뒤 사용자가 정한다'` 가 1건 이상, `grep -n -E '[0-9]+ ?%'` 결과가 없다(새 목표 숫자 없음)
- [x] 1.8 "claude plugin eval 로 보조 측정" 절(evals/README.md 안내 1~2줄)과 "한계" 절(표본 작음, 일부 추정, 학습 효과 → 대상 순서 바꿔 가며)을 적는다. 확인: 두 절 존재

## 2. `evals/` 사례 폴더 뼈대

- [x] 2.1 저장소 루트에서 `claude plugin eval init --bare lite-path-small-task --eval-dir evals` 와 `claude plugin eval init --bare direct-work-control --eval-dir evals` 를 실행한다. 확인: `find evals -type f | sort` 가 `evals/direct-work-control/graders/criteria.md`, `evals/direct-work-control/prompt.md`, `evals/lite-path-small-task/graders/criteria.md`, `evals/lite-path-small-task/prompt.md` 4개를 보여 준다
- [x] 2.2 네 파일의 frontmatter 는 그대로 두고 본문 `TODO:` 줄만 design.md D4 의 사례별 설명(자리 설명 + 측정 때 채울 `TODO`)으로 바꾼다. 확인: `prompt.md` 두 개에 `max_turns: 10`, `allowed_tools: [Read, Glob, Grep, Skill]`, `criteria.md` 두 개에 `type: llm`, `weight: 1` 이 그대로 있다
- [x] 2.3 `evals/README.md` 를 D4 의 목차(지금은 실행할 수 없다 / 폴더 구조 / 사례 추가 / 실행 / 실제 측정 전에 바꿀 것 / 기록)대로 작성하고, 확인한 Claude Code 버전 2.1.294 를 적는다. 확인: `grep -n -E 'with-without|plugin.json|convert-to-plugin|2\.1\.294' evals/README.md` 가 각각 나온다

## 3. 검증

- [x] 3.1 측정을 돌리지 않았음을 확인한다. 확인: `test ! -e evals/results` 성공, 기록 표·단계 기여 메모 값 칸이 비어 있음, `git status --short` 에 새 파일(`docs/`, `evals/`)과 이 change 폴더 외 변경이 없음
- [x] 3.2 마크다운 무결성을 확인한다. 확인: 새 `.md` 5개 각각 코드펜스(```) 수가 짝수, 사례 파일 4개의 frontmatter 가 `---` 로 열고 닫힘
- [x] 3.3 `openspec validate "add-field-validation-record" --strict; echo "exit=$?"` 가 `exit=0`, `openspec status --change "add-field-validation-record" --json >/dev/null; echo "metadata exit=$?"` 가 `metadata exit=0`
