최종 판정: 통과 (라운드 1, 2026-09-09)

## 리뷰: fix-pipeline-handoff-gaps
판정: 통과
판정 기록: openspec/changes/fix-pipeline-handoff-gaps/review.md
기준으로 삼은 채택안: 방안 비교 없음 (`analyzer 생략: 예`) — decision.md
범위: 프롬프트의 `만진 파일` 8개로 좁혔다. `git status --short`의 변경 파일과 정확히 일치한다
(추가로 바뀐 파일 없음).
기준 문서: proposal 받아들일 조건 11개 + design.md D1~D6 + decision.md(맨 아래 "범위 변경 2026-09-09"가
최신) + specs 델타 8개(10 Requirements).

### OpenSpec 검증
```
$ openspec validate "fix-pipeline-handoff-gaps" --strict
Change 'fix-pipeline-handoff-gaps' is valid
exit=0

$ openspec status --change "fix-pipeline-handoff-gaps" --json
isPlanningComplete: true / isComplete: true / 산출물 4종 전부 done
```
델타 8개는 전부 `## ADDED Requirements`뿐이고 RENAMED/REMOVED가 없다. 8개 capability 이름이
메인 spec(`openspec/specs/agent-instructions/`: `analyzer-option-generation`,
`openspec-metadata-marker-safety`)과 겹치지 않는다 → finalizer의 sync가 순수 추가로 끝난다.

### 요구사항 충족 (specs 델타 10개 Requirement)
1. worker-blocked-state-disambiguation → 충족. `.claude/agents/worker.md:79-86`.
   `missingArtifacts` 유무로 두 갈래. `missingArtifacts` 3회 등장, "작업 목록에 체크박스가 없다" 존재,
   무한 왕복 이유도 적혀 있음. 기존 `design.md: 없음(의도적)` 예외 `worker.md:89` 유지됨.
2. preparer-orphan-branch-reporting → 충족. `.claude/agents/preparer.md:210`에
   `branch=<만든 브랜치 또는 none>` 필드. 이유 한 줄은 `preparer.md:116-119`
   ("브랜치(4단계)를 change(5단계)보다 먼저 만들기 때문에 … 브랜치만 남는다").
   Scenario 3(다음 사람이 지워도 되는지 판단) 요구인 "근거가 문서에 남아 있다"도 만족.
3. reviewer-skip-specs-fallback → 충족. `.claude/agents/reviewer.md:66-70`.
   `skip_specs` 1회 등장, "정상이고 반려 사유가 아니다", 대체 기준(proposal 받아들일 조건 + 작업 목록
   머리말) 명시. 바로 아래 decision.md 부재 규칙(`reviewer.md:74-76`)과 같은 서술 방식 — SHALL 충족.
4. prompt-only-handoff-defense / designer 중단 → 충족. `.claude/agents/designer.md:25-30`(반드시 지킬 것)
   + `designer.md:263`(RESULT `reason=` 목록에 `채택안 없음`). "둘 다 없으면" 조건, "둘 중 하나만 있으면
   정상 진행", analysis.md 추천안 대체 금지 이유 모두 있음.
5. prompt-only-handoff-defense / reviewer·rv 만진 파일 부재 → 충족.
   `reviewer.md:106-112`, `regression-verifier.md:45-49`. 둘 다 "멈추지 마라 → 전체 diff → 보고서에 한 줄 →
   막음 아님 → `scope=전체diff`" 순서로 같은 처리. 넣을 자리도 각자 맞다
   (reviewer는 "이번 change 것인지 확인 필요한 변경" 절, rv는 4단계 "원인 구분 못 함").
   필드 이름 동일성: 두 파일 모두 `scope=전체diff` 2회 / `scope=만진파일` 1회, `범위=`·`diff_scope=` 0건.
   RESULT 줄도 같은 자리(`change=` 바로 뒤)에 같은 형태 —
   `reviewer.md:175`, `regression-verifier.md:109`.
6. artifact-file-precedence-over-prompt → 충족. `.claude/agents/designer.md:90-94`.
   1단계(입력 다시 읽기) 안, `읽을 것 (모두 디스크에서):` 목록 바로 앞 = 설계가 지정한 자리.
   세 가지(파일이 맞다 / 기준선 값은 analysis.md에서 다시 읽는다 / 다르면 보고서에 적는다) 다 있고
   finalizer의 짝 방어 언급도 있음.
7. finalizer-archive-rationale-accuracy → 충족. `.claude/agents/finalizer.md:212-216`.
   `이중 적용` 0건, `안전망이 아니다` 0건. 남은 근거는 ①되돌릴 수 없음(첫 번째) ②stdin — 정확히 둘뿐.
   `stdin` 2회, `openspec-archive-change` 4회로 정책·결론 문단과 조사용 bash 블록 그대로 유지됨.
   (proposal 조건 7은 2026-09-09에 design D3에 맞춰 "삭제"로 정렬됐다. 지금 파일이 그 새 조건과 맞다.)
8. skill-tool-invocation-rationale → 충족. **직접 재측정했다.**
   ```
   for f in preparer designer worker finalizer analyzer; do grep '^> ' .claude/agents/$f.md | md5; done
   preparer  7111c996def6a259f004dd92f1ee1dec
   designer  7111c996def6a259f004dd92f1ee1dec
   worker    7111c996def6a259f004dd92f1ee1dec
   finalizer 7111c996def6a259f004dd92f1ee1dec
   analyzer  7111c996def6a259f004dd92f1ee1dec
   ```
   다섯 값이 기준값과 모두 같다. 다섯 파일 모두 `^> ` 줄이 정확히 6줄이라 md5가 그 블록만 덮는다는
   전제도 확인했다. 옛 문구 `도구가 없을 수 있다`는 `.claude/agents/` 전체에서 0건
   (`.claude/skills/orchestra/SKILL.md:71`에 남아 있으나 명시적 범위 밖 — 아래 참고 1).
   블록 시작 줄: preparer:31 / designer:50 / worker:32 / finalizer:64 / analyzer:31.
9. project-context-completeness (context 채움) → 충족. **두 증거 모두 직접 확인했다.**
   ```
   openspec context 2>&1 | grep -c 'Warning'   → 0
   openspec instructions proposal --change "fix-pipeline-handoff-gaps" --json
     → context key present: True, len=645
       '지시문 저장소' True / 'bash -n install.sh' True / 'Edit 부분 수정' True
       '한국어' True / 'grep 대조' True
   ```
   spec이 요구한 네 항목(실행 코드 없는 지시문 저장소 / 검증 수단 / 한국어 쉬운 말 / Edit 부분 수정)이
   전달되는 값 안에 전부 있다.
10. project-context-completeness (들여쓰기) → 충족. `grep -c '^context:' openspec/config.yaml` = 1
    (0칸 시작). 블록 스칼라 내용만 2칸. 예시 주석 블록은 지워지지 않고 그대로 남아 있다
    (`openspec/config.yaml:1-10`), 새 줄은 그 다음·`# Per-artifact rules` 앞 = D4가 지정한 자리.

### 설계 준수
- D1 파일별 묶음 → 지켜짐. 8개 파일 각각 한 묶음.
- D2 F2 한 벌 다섯 곳 글자 그대로 → 지켜짐(md5 5개 일치). 결론 문장 유지, 거짓 근거 3종
  ("도구가 없을 수 있다" / "실측으로 확인됨" / "실제로 있으면 불러도 된다") 전부 제거.
- D3 F1 근거 블록만 교체, 순서 되돌릴수없음→stdin → 지켜짐.
- D4 config.yaml 0칸 + 예시 주석 보존 → 지켜짐.
- D5 무결성 → 코드펜스가 기준선과 완전히 같다:
  preparer 16 / designer 10 / worker 6 / reviewer 8 / regression-verifier 6 / finalizer 10 /
  analyzer 4 / config.yaml 0 — 전부 짝수, 전부 기준선과 동일.
  `grep -rn 'ORCA_RICH_MD' .claude/` 0건. frontmatter 7개 파일 전부 온전
  (`analyzer.md`만 `skills:` 줄이 하나 더 있는 것이 원래 모습 — 유지됨).
- D6 F3 두 명령 → 둘 다 통과(위 9번).
- decision.md "범위 변경 2026-09-09" 채택안(analyzer.md 범위 편입, 조건 7 = 삭제)대로 됐다.
  앞쪽 "analyzer.md를 절대 건드리지 않는다" 문장은 그 절이 이긴다고 명시돼 있어 위반이 아니다.
- L5가 세 자리에서 서로 다른 형태로 들어간 것(designer는 멈춤, reviewer/rv는 드러냄)은 decision.md
  답 1과 일치한다. **의도된 차이이며 각자 자리에서 타당하다** — designer는 ★사용자 선택 관문이라
  추측으로 메우면 안 되고, reviewer/rv는 목록 부재가 정상일 수 있어 멈추면 파이프라인이 막힌다.

### 새로 들어간 reviewer 규칙이 실제로 쓸 만한가 (내가 그 지침의 당사자다)
- `만진 파일` 부재 처리(`reviewer.md:106-112`): **판단 가능하다.** 무엇을 범위로 삼고, 발견한 것을
  어느 절에 넣고, RESULT에 무엇을 남길지가 다 정해져 있다. 가리키는 "이번 change 것인지 확인 필요한 변경"
  절이 보고 형식 템플릿에 실재한다(`reviewer.md:194` 부근).
- `scope=` 필드(`reviewer.md:175-178`): **판단 가능하다.** 목록을 받은 경우(`scope=만진파일`)와
  못 받은 경우(`scope=전체diff`)가 둘 다 정의돼 있어 빈틈이 없다.
- `skip_specs` 대체 기준(`reviewer.md:66-70`): **판단 가능하다.** 다만 아래 참고 3 참고.

### 작업 완료 검증
`tasks.md` 체크박스: `[x]` 33개, `[ ]` 0개. 다음을 실제 파일로 재확인했다 —
1.2/1.3 기준선(코드펜스·ORCA·context 부재 → 지금 존재), 2.1·2.2, 3.1·3.2·3.3, 4.1·4.2·4.3·4.4,
5.1·5.2·5.3, 6.1·6.2, 7.1·7.2, 8.1·8.2·8.3, 9.1·9.2·9.4·9.5·9.6·9.7·9.8, 10.1(①②③④).
**허위 체크 없음.** 9.3은 "F2 네 곳"으로 적혀 있으나 10절 머리말이 확인 ①(다섯 곳 md5)로
확장한다고 명시했고 그 다섯 곳이 실제로 통과하므로 유효하다.
`bash -n install.sh` → exit=0 (조건 11).

### 되돌릴 체크 항목
없음

### 발견 사항
1. [참고] `.claude/skills/orchestra/SKILL.md:71` — 이번에 없애려던 거짓 문장
   ("이 환경의 서브 에이전트에게는 `Skill` 도구가 없을 수 있다")이 저장소에 아직 한 곳 남아 있다.
   이 파일은 design.md Non-Goals가 "읽지도 고치지도 않는다"고 명시한 범위 밖이고, spec 델타도
   다섯 에이전트 파일만 요구하므로 **이번 change의 결함이 아니다.** 후속 change 거리로만 적어 둔다.
2. [참고] `.claude/skills/orchestra/SKILL.md:32` — reviewer RESULT 예시가
   `RESULT: 통과 | change=add-2fa | blockers=0 | ...`로 새 `scope=` 필드를 반영하지 않는다.
   필드가 늘어난 것이라 오케스트레이터가 읽는 데 지장은 없다(예시일 뿐이다). 같은 이유로 범위 밖.
   1번과 함께 orchestra 쪽 후속 change에서 처리하는 것이 맞다.
3. [참고] `.claude/agents/reviewer.md:66` — "`specs`의 `status`가 `skipped`이거나"에서 `status`는
   실제로는 `openspec status --json`의 `artifacts[]` 배열에 있고 `artifactPaths.specs` 아래에는 없다
   (이번에 직접 JSON을 떠서 확인했다). 다만 이 문장은 `artifactPaths.specs.existingOutputPaths` 항목의
   하위 서술이라 오해할 여지가 조금 있다. **실사용에는 지장이 없다** — 두 번째 조건
   ("`existingOutputPaths`가 비어 있으면")만으로도 판정이 성립한다. designer가 decision.md
   "범위 변경" 3절에서 이 문장을 검토한 뒤 "틀리지 않았다, worker 작업을 추가하지 않는다"로
   이미 판단했으므로 반려 사유로 올리지 않는다.
4. [참고] `.claude/agents/worker.md:88-92` — "CLI나 다른 스킬이 …" 문단과
   "예외: `design.md: 없음(의도적)`" 문단이 두 갈래 하위 항목 **뒤에** 놓여, 겉보기에는 두 갈래 모두에
   걸리는 것처럼 보인다. 실제로는 예외 문장 자체가 "막힌 이유가 design 하나뿐이면"이라 첫째 갈래
   (`missingArtifacts`에 값 있음)에서만 성립해 스스로 범위를 한정한다. 마크다운 들여쓰기(2칸)도
   변경 전과 같아 구조가 깨지지 않았다. 문체 정리는 이번 Non-Goals다.

### 이번 change 것인지 확인 필요한 변경
없음. `git status --short`의 수정 파일이 프롬프트의 만진 파일 8개와 정확히 일치한다.
범위 밖 지정 4개(`.claude/skills/orchestra/SKILL.md`, `docs/example-run.md`, `README.md`,
`.claude/settings.json`)는 전부 무변경. 미추적 항목은 change 디렉터리
(`openspec/changes/fix-pipeline-handoff-gaps/`) 하나뿐이다.
`git diff --stat`: 8 files, +94 / -25 — 전량 재작성 흔적 없음(조건 10 = Edit 부분 수정만).

### 산출물 형태 점검 (openspec-propose 기준)
`context` / `rules` / `<project_context>` 블록이 산출물 파일에 복사돼 들어간 곳 **없음.**
`design.md:109`의 `context: |`는 D4가 지정하는 확정 YAML 내용(코드블록 안)이라 정상이다.

### 다음 단계
finalizer에게 넘긴다. sync 대상은 신규 capability 8개(ADDED 전용, RENAMED/REMOVED 없음)라
메인 spec에 순수 추가로 병합된다. 참고 1·2는 별도 후속 change로 올릴 것을 권한다.
