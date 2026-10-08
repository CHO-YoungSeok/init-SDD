> 이 문서의 추천은 analyzer 의견이다. 사용자가 최종 선택한 안은 decision.md에 있다.
>
> 작성 경위: analyzer와 designer 모두 실행 환경의 서브에이전트 보고서 파일 쓰기 차단으로 이 파일을 남기지 못했다. 오케스트레이터가 analyzer 보고서 본문을 그대로 옮겨 적었다 (2026-10-08).

# 분석: plugin-lite-sdd-distribution

## 지금 상태 (관찰한 사실)

### 크기와 토큰 (실측)
- `wc -l`: 에이전트 8개 합계 1,679줄 (designer 311, finalizer 299, worker 242, preparer 241, reviewer 224, analyzer 175, regression-verifier 147, code-explorer 40). orchestra 459, init-sdd 540, agent-model-tier 143 → 지시문 합계 **2,821줄**. 스캐폴드 SKILL.md 6개: 1,211줄.
- 지금 파일을 플러그인 모양으로 scratchpad에 복사하고 `claude --plugin-dir <dir> plugin details sdd` 로 측정:
  - 매 세션 붙는 비용: 약 1.5k 토큰
  - 호출당(추정): orchestra 14.2k / init-sdd 13.4k / finalizer 9k / designer 8.9k / preparer 7k / worker 6.1k / reviewer 5.7k / analyzer 4k / regression-verifier 3.2k
  - 스캐폴드: explore 6.1k / sync 4.1k / propose 4k / archive 3.5k / apply 2.6k / update 2.1k
- 에이전트 frontmatter `skills: [openspec-…]` 는 스킬 본문을 통째로 주입하는데, 본문이 다시 SKILL.md를 Read하라고 시켜 같은 문서를 두 번 먹을 수 있다.
- 기본 경로 1회(analyzer 없음) 지시문 토큰 약 80k 추정.

### 에이전트마다 되풀이되는 절 (실측)
대상: 쓰는 스킬·allowed-tools 이유 / 대화형 스킬 / store 처리 / code-explorer 부르기 / 되돌릴 수 없는 일.
worker 51, preparer 50, finalizer 48, analyzer 35, reviewer 31, designer 27, regression-verifier 11 → 합계 약 250줄.

### OpenSpec CLI 관문 (scratchpad 실측)
- proposal.md + tasks.md만 있으면 `openspec instructions apply` 가 state=ready. design·specs는 필요 없다.
- `validate --strict` 는 델타 없으면 rc=1("at least one delta"). `.openspec.yaml` 에 `skip_specs: true` 면 rc=0.
- 그 상태에서 `openspec archive --yes --json` 도 rc=0.
- 즉 경량 경로를 막는 건 CLI가 아니라 orchestra SKILL.md:443-447 의 "designer 생략 금지" 지시다.

### CLI 1.12.0 vs 1.14.1 (실측)
- 실행 시간: npx 1.14.1 처음 3.2초, 이후 0.5초. 전역 1.12 0.2초.
- 명령 차이는 `version` 하나뿐. 두 버전 모두 `sync` 명령이 없다.
- `init --tools claude` 는 두 버전 모두 같은 12개 파일을 만든다. 지금 저장소의 스캐폴드 6개는 1.12 생성본과 같다. 본문은 6개 모두 32~61줄 바뀌었다.
- 1.12의 apply 막힘 안내는 설치되지 않는 `openspec-continue-change` 스킬을 가리킨다. 1.14.1은 `openspec instructions <artifact>` 를 안내해 CLI만으로 끝까지 갈 수 있다.
- 두 버전의 `instructions design` 에 design.md 생성 조건 4가지가 들어 있다.

### 이름·경로 의존 (grep 전수)
- orchestra `subagent_type`: 16곳
- 에이전트 7개의 "code-explorer 부르기" 절: 7곳
- `.claude/skills/` 경로: 약 55곳 (에이전트 안 16곳)
- `.claude/agents` 경로: 36곳 (agent-model-tier 12, init-sdd 13 포함)
- 에이전트 frontmatter `skills:`: 5곳
- 메인 spec: 15개 중 14개에 `.claude/` 약 94번
- `/tmp`: regression-verifier.md:89, init-sdd/SKILL.md:290,305, README.md:54-57,79-82,99

### 플러그인 도구 (claude 2.1.294)
- 지금 frontmatter 그대로 `claude plugin validate` 통과 (author 없음 경고만).
- `--plugin-dir`, `plugin details`, `plugin eval`, `plugin tag` 있음.
- `plugin eval --ablation with-without` 는 같은 과제를 플러그인 있음/없음으로 비교한다. ④의 "직접 작업과 SDD 작업 비교"와 같은 모양.

### 그 밖
- reviewer.md:5 의 Edit은 재리뷰 때 review.md 수정용(:161-166). "읽기 전용" 문구가 부정확한 쪽.
- agent-model-tier는 `.claude/agents/*.md` 의 `model:` 줄을 직접 고친다. 플러그인은 캐시 폴더에서 읽히므로 고쳐도 업데이트 때 덮인다.

## 추측 / 확인 못 한 것 (③ 첫 작업에서 `--plugin-dir` 실험으로 확인)
- 플러그인 에이전트 본문에서 `${CLAUDE_PLUGIN_ROOT}` 치환 여부 (스킬·명령은 문서상 된다)
- 플러그인 에이전트 `skills:` 항목에 접두사(`sdd:sdd-rules`) 필요 여부
- `subagent_type: "worker"` 접두사 없는 이름이 플러그인 에이전트로 풀리는지
- plugin.json에 agents/skills 경로 직접 지정 가능 여부
- `tools: Agent(code-explorer)` 로 호출 대상을 도구 수준에서 좁힐 수 있는지
- 마켓플레이스 설치본과 `--plugin-dir` 동시 로드 시 우선순위
- SessionStart 훅이 넣은 지시를 메인 세션이 CLAUDE.md만큼 따르는지

## 기준선 측정값
- 지시문 2,821줄 (스캐폴드 1,211줄 별도)
- 매 세션 붙는 토큰 약 1.5k (스캐폴드 포함 약 1.9k)
- 기본 경로 1회 약 80k 토큰 (추정)
- openspec 실행: 전역 1.12 0.2초 / npx 1.14.1 처음 3.2초, 이후 0.5초

## 기존 spec과 부딪히는 곳
- `skill-tool-invocation-rationale`: "스캐폴드 SKILL.md를 Read한다" 규칙 → MODIFIED/REMOVED 대상.
- `agent-model-tier` (요구사항 7개): 파일 직접 수정 전제가 플러그인에서 무너진다.
- `sdd-install-script`, `init-sdd-skill`: "이전 안내"만 소폭 수정. `/tmp` 수정은 init-sdd-skill과 대조.
- `code-explorer-invocation`, `code-explorer-role`: 7개/6개 숫자 문구.
- 메인 spec `.claude/` 경로 약 94곳: 표준 레이아웃 이동 시 전부 낡는다.

## 7개 핵심 질문 답

**Q1. designer 없이 tasks.md는 누가 만드나 → preparer.** 경량 경로에서 proposal + tasks를 쓴다. 동작이 바뀌면 작은 델타, 안 바뀌면 `skip_specs: true`. worker가 쓰면 자기 숙제를 자기가 채점. orchestra는 산출물 직접 금지 규칙에 걸린다. "큰 작업" 판정은 CLI의 design 조건 4가지 + "analyzer 요청". preparer가 RESULT에 `size=작음|큼`, orchestra가 분기. regression-verifier는 실행 코드와 테스트 명령이 있을 때만; 경량 경로에서는 reviewer가 테스트 1회.

**Q2. 스캐폴드 6개 의존 제거 → CLI `instructions` 만 따르기 + sync 절차만 요약 내장(`sdd-sync`).** 사본 내장은 1,211줄 증가와 버전마다 32~61줄 어긋남. archive는 `openspec archive --yes`. explore는 뺀다. frontmatter `skills:` 5곳 제거 시 시작 비용 최대 10.1k(preparer) 감소.

**Q3. 공용 규칙 위치 → `sdd-rules` 스킬로 만들고 `skills:` 로 주입.** 경로를 쓰지 않으므로 `.claude/` 구조와 플러그인 양쪽에서 같게 돈다. 대비책은 `bin/sdd-rules` 출력. CLAUDE.md 대신 SessionStart 훅, `[ -d openspec ]` 일 때만 지휘 규칙 5줄 주입(사용자 범위 설치라 모든 프로젝트에서 훅이 돌기 때문). 플러그인 settings의 `agent` 키는 모든 세션을 바꾸므로 탈락.

**Q4. 이름 접두사 영향.** 범위는 위 grep 결과. ②에서 이름표와 code-explorer 절을 sdd-rules로 모으면 ③에서 고칠 곳이 몇 군데로 준다. agent-model-tier는 재설계 필요 → 사용자 결정으로 삭제.

**Q5. 4개 change 순서 → ① 불일치 → ④ 양식 → ② 경량+공용 규칙+스캐폴드 의존 제거 → ③ 플러그인.**

| change | 만지는 것 | capability |
|---|---|---|
| ① | code-explorer.md, orchestra 표 1줄, reviewer 설명, `/tmp` → `mktemp`, README:85, `.agents/` | MOD code-explorer-role/-invocation, init-sdd-skill |
| ④ | `docs/field-validation.md` (새), `evals/` 뼈대 | ADD process/field-validation-record |
| ② | 에이전트 8개, orchestra, `.claude/skills/sdd-rules/` (새), `sdd-sync/` (새) | ADD shared-pipeline-rules, lite-default-path / MOD skill-tool-invocation-rationale 등 |
| ③ | `.claude-plugin/*`, `agents/`·`skills/` 이동, `hooks/`, `bin/sdd-openspec`, `/sdd-init`, README·install.sh·CLAUDE.md | ADD sdd-plugin, openspec-cli-wrapper, sdd-init-command / MOD 설치·init-sdd / REMOVED agent-model-tier |

이유: ①이 먼저여야 ②의 diff가 깨끗하다. ④가 ② 앞이면 줄이기 전 파이프라인을 기준선으로 잴 수 있다. ②가 이름·경로 참조를 모아 두면 ③이 작아진다. 같은 작업 트리에서 병행하지 않는다.

**Q6. 에이전트당 100줄 → 3개만 가능.** 반복 절만 빼면 약 1,450줄(평균 180). 스캐폴드 의존 제거 + 공통 보고 틀까지 하면 약 1,140줄. 100줄 근처는 code-explorer 40, regression-verifier 약 100, analyzer 약 120. designer·worker·finalizer·preparer는 150~200줄이 바닥("업무 로직 재설계 안 함" 범위 제약).

**Q7. 저장소 구조와 dogfooding → 저장소 루트를 플러그인 루트로, 개발은 `claude --plugin-dir .`.** 하위 폴더 + 심볼릭 링크, 또는 `.claude/` 원본 + 경로 지정 방식은 dogfood 이름(`worker`)과 실제 이름(`sdd:worker`)이 달라 orchestra가 한쪽에서 깨진다. 로컬 마켓플레이스 설치는 릴리스 직전 점검용. 함정: ③ 도중 `.claude/agents` 가 옮겨지면 다음 세션에 에이전트가 없다 → 파일 이동은 ③의 마지막 작업, README에 개발용 실행법을 먼저 적는다.

## 방안

### 1안: 플러그인 전면 전환 + 자기완결 (추천)
저장소 루트를 플러그인 루트로. 스캐폴드 대신 `sdd-openspec instructions` + sync 요약 하나. 공용 규칙은 sdd-rules 스킬. CLAUDE.md 대신 조건부 SessionStart 훅. `bin/sdd-openspec` = `npx -y @fission-ai/openspec@1.14.1`. 경량 경로 tasks는 preparer. 분할은 Q5 표.
- 장점: 사용자 프로젝트 `.claude/` 를 안 건드림. 스캐폴드 실종 사고가 구조적으로 사라짐. CLI 하나 고정으로 지시도 고정. 에이전트 시작 토큰 감소. dogfood 이름이 실제와 같음.
- 단점·위험: CLI 1.14.1로 상향. 미확인 항목이 ③의 성패를 가름 → ③ 첫 작업을 짧은 실험으로. 메인 spec 경로 표기 정리 필요. 이 저장소 개발 방식 변경. `/opsx:*` 명령 사라짐.
- 드는 힘: 큼. 요구사항 충족: 조건 10개 모두 가능 (100줄 목표는 Q6대로 일부만 달성하고 이유 보고).

### 2안: 플러그인 껍데기 + `.claude/` 원본 유지 + 스캐폴드 계속 의존 (버전 고정)
- 장점: 파일 이동 없음, spec 경로 94곳 유지, 행동 변화 위험 최소.
- 단점: `/sdd-init` 이 사용자 프로젝트에 12개 파일을 써서 "공유 저장소 `.claude/` 안 건드림" 목표를 어김. 스캐폴드 실종 사고 그대로. 공용 규칙 경로가 사용자 프로젝트에 없어 `${CLAUDE_PLUGIN_ROOT}` 치환에 기대야 함(미확인). 경로 지정 지원 미확인. dogfood 이름 불일치.
- 드는 힘: 보통. 요구사항 충족: 부분.

### 3안: 플러그인 없이 경량화만
①②④는 1안과 같고 ③ 대신 install.sh를 한 줄 설치로.
- 장점: 플러그인 미확인 위험 없음. 경량화 효과 동일. 드는 힘 최소.
- 단점: "설치 두 줄" 미충족. 팀 저장소 `.claude/` 계속 오염. 업데이트 수단 없음.
- 요구사항 충족: 플러그인 관련 조건 3개 미충족.

### 4안: 1안 + CLI만 쓰는 극단형 (sync를 `openspec archive` 로 대체)
- 장점: 버전 어긋남 위험 최소. finalizer 100줄 근처 가능.
- 단점: 되돌릴 수 없는 archive가 모든 커밋에 낌. archive 전까지 메인 spec이 낡음. "업무 로직 재설계" 범위 밖에 걸림. `finalizer-archive-rationale-accuracy` 등 spec과 충돌.
- 요구사항 충족: 형식상 충족, 범위 밖 항목 건드림.

## analyzer 추천: 1안
기준: proposal 목표 충족 > 사고 재발 방지 > 드는 힘.
1. 조건 10개를 모두 채우는 건 1안과 4안뿐.
2. 스캐폴드 실종 사고를 구조적으로 없애는 것도 1안과 4안뿐.
3. 1.14.1은 `instructions` 만으로 끝까지 간다(실측). 사본 내장 없이 sync 요약 하나로 4안 이득 대부분을 얻으면서 업무 규칙은 유지.
4. ② → ③ 순서 덕에 ③이 작아지고, ③에서 막혀도 ②까지의 성과는 남는다.
5. `plugin details`, `validate`, `eval` 로 효과를 숫자로 확인 가능.

뒤집히는 조건: ③ 실험에서 `skills:` 주입과 `${CLAUDE_PLUGIN_ROOT}` 치환이 둘 다 안 되면 `bin/sdd-rules` 방식으로, 그래도 불편하면 3안. 1.12에 묶여야 하면 2안. archive를 커밋마다 해도 되면 4안. 배포가 급하지 않으면 3안으로 ②까지만.

## analyzer가 올린 질문과 처리 (decision.md 참조)
1. 경량 경로 동작 변경 시 델타 작성 여부 → 작은 델타를 쓴다.
2. openspec 1.14.1 상향 → 예.
3. 플러그인 이름 → `sdd`.
4. agent-model-tier → 없앤다.
5. 경량 경로에서 reviewer가 테스트 1회 → 예.
6. `.agents/skills/claude-handoff/` → "SDD와 무관" 안내만 남기고 둔다.
7. 이 저장소는 `claude --plugin-dir .` 로만 개발 → 예.
8. ④는 표 양식 + eval 뼈대 최소 → 예.
