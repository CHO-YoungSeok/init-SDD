## Context

동기는 proposal.md "Why", 요구사항은 `specs/process/field-validation-record/spec.md` 를 본다.
이 change는 문서 3종(`docs/field-validation.md`, `evals/README.md`, 사례 2개)을 새로 만들 뿐이고 기존 파일을 바꾸지 않는다.

확인한 사실 (designer, 2026-10-08):
- `claude plugin eval init --bare <이름>` 은 플러그인/스킬 폴더가 아니면 거부된다
  (`... is not a plugin or skill folder — ... or pass --eval-dir to scaffold here on purpose`).
  저장소 루트에서 `--eval-dir evals` 를 붙이면 만들어진다. 생성물:
  `evals/<이름>/prompt.md` = frontmatter `max_turns: 10`, `allowed_tools: [Read, Glob, Grep, Skill]` + 본문 `TODO: describe what the agent should do`,
  `evals/<이름>/graders/criteria.md` = frontmatter `type: llm`, `weight: 1` + 본문 `TODO: describe what a successful response looks like`.
- `claude plugin eval` 결과는 `<plugin>/evals/results/` 에 쌓인다. 기본 판정 모델 haiku, 기본 `--runs` 3.
- 지시문 줄 수 재측정: 2,823줄 (`wc -l .claude/agents/*.md .claude/skills/orchestra/SKILL.md .claude/skills/init-sdd/SKILL.md .claude/skills/agent-model-tier/SKILL.md`).
  기준선 2,821줄(analysis.md)과 2줄 차이는 ① `fix-doc-inconsistencies` 의 수정분으로 본다.

## Goals / Non-Goals

**Goals:**
- 같은 작업을 세 비교 대상으로 했을 때 한 행에 나란히 적을 수 있는 표 1개.
- ②(경량화) 직전의 기준선을 이 양식으로 적을 수 있는 상태.

**Non-Goals:**
- 측정 실행, 임계값·목표치 결정, 평가 자동화 스크립트, `.gitignore` 수정(`evals/results/` 무시 규칙은 ③에서 플러그인 구조와 함께 정한다).

## Decisions

### D1. `docs/field-validation.md` 목차 (이 순서, 이 제목)
1. `# 실전 검증 기록 양식` + 한 단락: 이 문서가 무엇이고 언제 쓰는지. 측정은 아직 안 했다는 사실.
2. `## 비교 대상` — 표: `| 대상 | 뜻 | 지금 측정 가능 여부 |`
   - 직접 작업: SDD 파이프라인 없이 메인 세션에 바로 요청해 끝낸 작업.
   - 경량 경로: orchestra + worker + reviewer + 커밋 관문 (② 이후 생김. 그 전엔 "② 이후" 로 둔다).
   - 정식 경로: preparer → designer → worker → reviewer + regression-verifier → finalizer (analyzer는 요청 시).
3. `## 측정 항목과 수단` — 표: `| 항목 | 단위 | 측정 수단 | 재는 것 | 못 재는 것 |`
   - 품질: 판정 기준 = (a) proposal(직접 작업이면 작업 전에 적어 둔) 받아들일 조건 충족 수 `n/m`, (b) 커밋 뒤 사람이 고친 재작업 횟수, (c) `claude plugin eval` grader 점수(③ 이후). 수단: 조건 체크리스트 대조, reviewer 판정, eval 점수.
   - 소요 시간: 단위 분. 수단: 요청 시작~커밋 벽시계 시각, `/cost` 의 duration 표시. 못 재는 것: 사람이 대기·판단한 시간과 기계 시간의 구분.
   - 토큰: 단위 k 토큰. 수단: `/cost`(세션 사용량), `claude plugin details <name>`(지시문 정적 토큰 추정 — 실제 사용량 아님, ③ 이후), 세션 로그(`~/.claude/projects/` 아래 jsonl). 못 재는 것: `/cost` 가 서브에이전트 사용량을 포함하는지는 측정 때 확인해 "비고"에 적는다고 문서에 쓴다.
4. `## 기준선 (② 경량화 전)` — 표: `| 항목 | 값 | 측정 방법 | 출처 | 실측/추정 |`
   - 지시문 줄 수 | 2,821줄 | `wc -l`(에이전트 8개 + orchestra + init-sdd + agent-model-tier) | analysis.md | 실측. 각주: 2026-10-08 재측정 2,823줄(① 반영분).
   - 세션당 고정 토큰 | 약 1.5k | 플러그인 모양 복사본에 `claude --plugin-dir <dir> plugin details sdd` | analysis.md | 실측(도구 추정치)
   - 기본 경로 1회 지시문 토큰 | 약 80k | 단계별 호출당 추정 합산 | analysis.md | 추정
   - 출처 경로는 `openspec/changes/plugin-lite-sdd-distribution/analysis.md` (archive 뒤엔 `openspec/changes/archive/*-plugin-lite-sdd-distribution/analysis.md`) 라고 적는다.
5. `## 측정 절차 (작업 1건)` — 번호 목록 5단계 이내: 작업 고르기와 받아들일 조건 먼저 적기 → 세 대상으로 각각 수행(같은 시작 커밋에서) → 항목별 값 기록 → 비고에 특이사항 → 판정은 여러 건 모인 뒤.
6. `## 기록 표` — 아래 D2 양식. 값 칸은 비운 행 3개.
7. `## 판정 규칙` — 아래 D3.
8. `## claude plugin eval 로 보조 측정` — `evals/README.md` 로 안내 1~2줄.
9. `## 한계` — 표본이 작다, 토큰 일부는 추정, 같은 작업을 세 번 하면 두 번째부터 학습 효과가 있다(순서를 바꿔 가며 하라는 권고).

### D2. 기록 표 양식 (작업 1건 = 1행)
열 순서 그대로 쓴다. 대상 약어: 직접 = D, 경량 = L, 정식 = F. 머리글 바로 아래에 약어 뜻을 한 줄 적는다.

```
| # | 날짜 | 작업 요약 | 받아들일 조건 수 | D 품질 | D 시간(분) | D 토큰(k) | L 품질 | L 시간(분) | L 토큰(k) | F 품질 | F 시간(분) | F 토큰(k) | 비고 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  |  |  |  |  |  |  |  |
```
- 품질 칸 기록 형식: `n/m, 재작업 r` (예시는 표 밖 설명 문장으로만 적고 표 안에는 넣지 않는다 — 값 칸은 비어 있어야 한다).
- 정식 경로 단계별 내역(어느 단계가 무엇을 잡았나)은 판정 규칙에 필요하므로 표 아래 `### 단계 기여 메모` 빈 표를 하나 더 둔다:
  `| # | analyzer 사용 / 결정 바뀜 | designer: worker 되돌아옴 횟수 | regression-verifier: 잡은 회귀 수 | reviewer: 반려 횟수 |` + 빈 행 1개.

### D3. 판정 규칙 문구 (표: `| # | 조건 (측정 결과) | 조치 |`)
"동등" 은 차이가 임계값 이내라는 뜻. 임계값과 "판정에 필요한 작업 건수 N" 은 규칙 표 위에 `측정 뒤 사용자가 정한다` 로 명시한다.
1. 조건: L 품질이 F 품질과 동등하고 L 의 시간·토큰이 F 보다 적다 → 조치: 경량 경로를 기본으로 유지한다. designer 는 큰 작업 조건에서만 켠다.
2. 조건: L 품질이 F 보다 낮고, 단계 기여 메모에서 그 차이가 설계 구멍(worker 되돌아옴)으로 설명된다 → 조치: designer 를 유지한다. 큰 작업 판정 조건을 넓힐지 사용자가 정한다.
3. 조건: N건 동안 regression-verifier 가 잡은 회귀가 0건 → 조치: regression-verifier 를 "실행 코드 + 테스트 명령이 있을 때만" 으로 두거나 제거를 검토한다.
4. 조건: regression-verifier 가 reviewer 가 놓친 회귀를 1건 이상 잡았다 → 조치: regression-verifier 를 유지한다.
5. 조건: analyzer 를 쓴 작업에서 방안 비교가 사용자 결정을 바꾸지 않았다(사용자가 첫 직감대로 골랐다) → 조치: analyzer 를 "사용자가 분석을 요청할 때만" 으로 유지한다.
6. 조건: analyzer 를 쓴 작업에서 방안 비교 덕분에 결정이 바뀌었다 → 조치: analyzer 를 유지하고, 큰 작업 판정 조건에 넣을지 사용자가 정한다.
7. 조건: L·F 품질이 D 와 동등하거나 낮은데 시간·토큰은 더 크다 → 조치: 그 작업 유형은 change 없는 직접 처리로 돌린다(파이프라인 밖).
8. 조건: D 품질이 L·F 보다 낮다(받아들일 조건 누락 또는 재작업 발생) → 조치: 그 작업 유형은 SDD 경로를 유지한다.
마지막 줄: "규칙끼리 충돌하면 사용자가 정한다."

### D4. `evals/` 구조
```
evals/
├── README.md
├── lite-path-small-task/
│   ├── prompt.md
│   └── graders/criteria.md
└── direct-work-control/
    ├── prompt.md
    └── graders/criteria.md
```
- 사례 폴더는 worker 가 저장소 루트에서 `claude plugin eval init --bare <이름> --eval-dir evals` 로 만든다(손으로 흉내 내지 않는다 — 모양이 bare 템플릿과 같아야 하므로). 만든 뒤 frontmatter 는 **그대로 두고**, 본문 `TODO:` 줄만 아래 설명으로 바꾼다.
  - `lite-path-small-task/prompt.md` 본문: 경량 경로로 처리할 작은 작업(파일 1~2개, 동작 변경 작음) 자리라는 설명 + `TODO: 실제 작업 문장은 측정 때 정한다`.
  - `lite-path-small-task/graders/criteria.md` 본문: 받아들일 조건 충족 여부로 채점한다는 설명 + `TODO: 조건 목록은 측정 때 채운다`.
  - `direct-work-control/prompt.md` 본문: SDD 를 언급하지 않는 평범한 직접 요청 자리. 목적은 플러그인이 켜져 있어도 직접 작업이 느려지거나 파이프라인으로 끌려가지 않는지 보는 대조군(with/without 점수가 동등해야 정상) + `TODO`.
  - `direct-work-control/graders/criteria.md` 본문: 요청한 결과가 맞는지 + 묻지 않은 OpenSpec change 를 만들지 않았는지 + `TODO`.
- 이유: `--ablation with-without` 이 이미 "플러그인 없음" 팔을 돌리므로 사례 1의 without 팔이 곧 직접 작업이다. 사례 2는 반대 방향(플러그인이 직접 작업을 해치지 않는가)을 잰다.
- `evals/README.md` 목차: `# evals` / `## 지금은 실행할 수 없다` (plugin.json 이 있는 플러그인 루트에서만 돈다 → ③ `convert-to-plugin` 뒤) / `## 폴더 구조` / `## 사례 추가` (`claude plugin eval init --bare <이름>`; ③ 전엔 `--eval-dir evals` 필요) / `## 실행` (`claude plugin eval . --ablation with-without --runs 3 --max-cost-usd <금액> --json <json경로> --report <html경로>`, 금액은 사용자가 정함. `--threshold` 는 임계값이라 쓰지 않는다 — 측정 뒤 사용자가 정한다) / `## 실제 측정 전에 바꿀 것` (`allowed_tools` 는 bare 기본값이라 Write/Edit/Bash 가 없다 → 실제 작업 사례는 넓히고 `--allow-tools` 로 허용해야 함; 결과는 `evals/results/` 에 쌓인다) / `## 기록` (`docs/field-validation.md` 기록 표의 품질 칸에 점수를 옮긴다).

### D5. 대안과 버린 이유
- `case.yaml` 형식: CLI 가 둘 다 읽지만 받아들일 조건이 bare 템플릿 모양을 요구하므로 버렸다.
- 기록 표를 대상별 3행으로: "작업 1건당 1행" 조건(상위 조건 9)에 어긋나 버렸다.
- 기록 표를 CSV 파일로 분리: 기록 장소가 두 군데가 되어 버렸다.

## Risks / Trade-offs

- [`/cost` 가 서브에이전트 토큰을 포함하는지 미확인] → 문서에 "측정 때 확인해 비고에 적는다" 로 남긴다. 세션 로그를 보조 수단으로 둔다.
- [bare 템플릿 `allowed_tools` 로는 실제 작업 사례가 돌지 않는다] → README "실제 측정 전에 바꿀 것" 에 적는다. 이 change 에서는 bare 모양 유지가 조건이다.
- [`claude plugin eval init` 출력 형식이 Claude Code 버전에 따라 바뀔 수 있다] → README 에 확인한 버전(2.1.294)을 적는다.
