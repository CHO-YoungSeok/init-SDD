> 채택안: 1안 — 플러그인 전면 전환 + 자기완결 (decision.md).
> 이 change는 하위 change 4개를 묶는 **상위 기록**이다. 여기서 코드·지시문을 직접 고치지 않는다.
> 각 항목은 해당 하위 change를 preparer부터 정식 경로로 돌려 **archive까지 끝내면** 체크한다.
> 순서 ① → ④ → ② → ③, 병행 금지. 하위 change의 범위·담당 조건은 proposal.md 표를 따른다.

## 1. ① fix-doc-inconsistencies

- [x] 1.1 하위 change `fix-doc-inconsistencies` 완료: 불일치 6건이 고쳐졌거나 보류 사유가 적혀 있고(조건 7), `openspec validate "fix-doc-inconsistencies" --strict` exit=0, 해당 change archive 완료 (`openspec/changes/archive/*-fix-doc-inconsistencies` 존재로 확인)

## 2. ④ add-field-validation-record

- [x] 2.1 하위 change `add-field-validation-record` 완료: `docs/field-validation.md` 양식으로 품질 / 소요 시간 / 토큰을 직접 작업·SDD 작업 같은 항목으로 기록할 수 있고(조건 9), `evals/` 사례 폴더 뼈대가 있으며, validate --strict exit=0, 해당 change archive 완료 (archive 폴더 존재로 확인)

## 3. ② lite-default-path-and-shared-rules

- [x] 3.1 하위 change `lite-default-path-and-shared-rules` 완료: 스캐폴드 SKILL.md 없이 파이프라인이 돌고(조건 3), 기본 경로로 작은 작업을 끝까지 돌릴 수 있고 tasks.md는 preparer가 쓰며(조건 4), 큰 작업 조건 규칙이 orchestra 한 곳에 있고(조건 5), 반복 규칙이 sdd-rules 한 곳에만 있으며 `wc -l` 지시문 총합이 2,821줄보다 적고(조건 6), validate --strict exit=0, 해당 change archive 완료 (archive 폴더 존재로 확인)

## 4. ③ convert-to-plugin

- [x] 4.1 하위 change `convert-to-plugin` 완료: 설치 두 줄 + `/sdd-init` 한 번으로 시작하는 실측 절차가 문서에 있고(조건 1), `sdd-openspec --version` 이 1.14.1을 출력하며(조건 2), 권한 목록 안내·동의 시 `settings.local.json` 기록과 SessionStart 훅이 있고(조건 8), agent-model-tier 스킬·spec이 삭제됐고, 메인 spec `.claude/` 경로가 decision.md "핵심 결정 4" 규칙대로 처리됐으며, `bash -n install.sh` 통과, validate --strict exit=0, 해당 change archive 완료 (archive 폴더 존재로 확인)

## 5. 상위 change 마무리

- [x] 5.1 받아들일 조건 10개를 proposal.md 표의 담당 하위 change 결과와 대조해 전부 충족(또는 보류 사유 기록)됐는지 확인하고, `openspec validate "plugin-lite-sdd-distribution" --strict` exit=0 확인
  - 후속(같은 사용자 지시로 이어 붙임): ⑤ `apply-plugin-to-self`, ⑥ `audit-specs-and-docs` 도 archive 완료(2026-10-09). 지시문 총합 2,698줄(< 2,821), 1.14.1 `validate --all --strict` 실패 0.
