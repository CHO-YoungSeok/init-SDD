# 결정 기록

- 채택한 안: 1안 — 플러그인 전면 전환 + 자기완결 (스캐폴드 대신 CLI instructions, 공용 규칙은 sdd-rules 스킬, 조건부 SessionStart 훅, bin/sdd-openspec = `npx -y @fission-ai/openspec@1.14.1`, 경량 경로 tasks는 preparer가 씀)
- 결정한 사람: 사용자 (오케스트라를 통해)
- 결정 날짜: 2026-10-08
- analyzer 추천안: 동일 (1안)

## 채택 이유
"openspec + orchestra 구조를 어떠한 프로젝트에도 빠르게 적용"이 최우선이다.
1안만 받아들일 조건 10개를 전부 채우고, OpenSpec 스캐폴드 SKILL.md가 디스크에서 사라져
파이프라인이 깨진 사고를 구조적으로 없앤다 (스캐폴드에 아예 기대지 않으므로).

## 사용자가 덧붙인 말
- change는 4개로 쪼갠다. 순서 ① 불일치 수정 → ④ 실전 검증 양식 → ② 경량화+공용 규칙+스캐폴드 의존 제거 → ③ 플러그인 전환. (analyzer Q5 표 그대로)
- openspec 고정 버전 1.14.1.
- agent-model-tier 스킬은 없앤다 (스킬 + 관련 spec 삭제, ③에서 처리).
- 기존 설치 방식(install.sh, init-sdd)은 이번엔 "플러그인으로 이전" 안내만 넣는다. 제거는 실전 검증 뒤 다음 change.
- 권한: `/sdd-init` 이 추가할 권한 목록을 보여주고, 동의하면 `settings.local.json` 에 기록한다.

## 채택하지 않은 안과 그 이유
(analysis.md "방안 요약"에서 옮김)
- 2안 플러그인 껍데기 + `.claude/` 유지 + 스캐폴드 의존: 스캐폴드 실종 사고가 그대로 남고 "어디든 빠르게 적용" 목표를 어긴다.
- 3안 플러그인 없이 경량화만: 설치 두 줄(`/plugin marketplace add`, `/plugin install`) 조건을 못 채운다.
- 4안 1안 + 커밋마다 archive: 되돌릴 수 없는 archive가 매 커밋에 붙고, 업무 규칙을 재설계해야 해서 범위 밖이다.

## 핵심 결정

### 1. change 분할 (이 change는 상위 기록)
이 change `plugin-lite-sdd-distribution` 은 **코드·지시문을 직접 고치지 않는다.**
하위 change 4개를 묶는 상위 기록이다. 실제 수정은 하위 change 각각이 preparer부터 정식 경로로 한다.

| 순서 | 하위 change 이름 | 한 줄 요약 |
|---|---|---|
| ① | `fix-doc-inconsistencies` | 이미 확인된 불일치 6건 수정 |
| ④ | `add-field-validation-record` | 실전 검증 측정 양식 + `claude plugin eval` 사례 폴더 뼈대 |
| ② | `lite-default-path-and-shared-rules` | 경량 기본 경로, 공용 규칙(sdd-rules), 스캐폴드 의존 제거 |
| ③ | `convert-to-plugin` | 플러그인 구조 전환, sdd-openspec 래퍼, /sdd-init, agent-model-tier 삭제 |

- **병행 금지.** 앞 change가 archive된 뒤 다음 change의 preparer를 시작한다.
- 이유: ①이 먼저여야 ②의 diff가 깨끗하다. ④가 ② 앞이면 줄이기 전 기준선을 잴 수 있다.
  ②가 이름·경로 참조를 sdd-rules로 모아 두면 ③이 작아진다.

### 2. 오케스트레이터가 정한 기본값 (사용자 확인 없이 정한 값 — 하위 change에서 뒤집을 수 있다)
- **경량 경로의 specs:** 동작이 바뀌면 preparer가 작은 specs 델타까지 쓴다. `skip_specs: true` 는 동작이 바뀌지 않을 때만 쓴다.
- **경량 경로의 tasks.md:** preparer가 쓴다 (worker가 쓰면 자기 숙제를 자기가 채점하게 되고, orchestra는 산출물을 직접 만들지 않는다).
- **큰 작업 판정:** CLI `instructions design` 의 design.md 생성 조건 4가지 + "사용자가 분석 요청". preparer가 RESULT에 `size=작음|큼` 을 적고 orchestra가 분기한다.
- **경량 경로 회귀 검증:** regression-verifier 대신 reviewer가 테스트를 1회 돌린다. regression-verifier는 실행 코드 + 테스트 명령이 있을 때만 켠다.
- **플러그인 이름(에이전트 접두사):** `sdd` (에이전트는 `sdd:worker` 꼴이 된다).
- **`.agents/skills/claude-handoff/`:** 지우지 않고 둔다. README에 "SDD와 무관"이라는 안내만 남긴다.
- **이 저장소 개발 방식:** `claude --plugin-dir .` 로 개발한다. 마켓플레이스 설치는 릴리스 점검용으로만 쓴다.
- **④의 범위:** 표 양식 문서 + `claude plugin eval` 사례 폴더 뼈대까지만. 실제 측정 실행은 범위 밖.

### 3. 기술 결정 (1안 내용)
- **스캐폴드 의존 제거:** OpenSpec 스캐폴드 SKILL.md 6개를 Read하지 않는다. 산출물은 `openspec instructions <artifact>` 지시만 따른다.
  sync 절차만 `sdd-sync` 스킬로 요약 내장한다. archive는 `openspec archive --yes`. explore는 뺀다.
  에이전트 frontmatter의 `skills: [openspec-…]` 5곳을 걷어낸다.
- **공용 규칙:** `sdd-rules` 스킬 한 곳에 모으고 에이전트 frontmatter `skills:` 로 주입한다.
  주입이 안 되면 대비책은 `bin/sdd-rules` 출력.
- **CLAUDE.md 대체:** 플러그인 루트 CLAUDE.md는 로드되지 않으므로 SessionStart 훅을 쓴다.
  `[ -d openspec ]` 일 때만 지휘 규칙 약 5줄을 주입한다.
- **openspec CLI:** `bin/sdd-openspec` = `npx -y @fission-ai/openspec@1.14.1`. 사용자 PATH의 구버전과 겹치지 않도록 이름을 다르게 둔다.
- **권한:** 플러그인은 permissions를 배포할 수 없다. `/sdd-init` 이 추가할 권한 목록을 보여주고, 사용자가 동의하면 `settings.local.json` 에 기록한다.
- **저장소 배치:** 저장소 루트 = 플러그인 루트. `.claude/agents`·`.claude/skills` 를 `agents/`·`skills/` 로 옮기는 일은 ③의 **마지막** 작업으로 둔다
  (도중에 옮기면 다음 세션에 에이전트가 없다). README에 `claude --plugin-dir .` 실행법을 먼저 적는다.
- **기존 설치 방식:** install.sh / init-sdd는 남기고 "플러그인으로 이전" 안내만 넣는다. 제거는 실전 검증 뒤 별도 change.
- **agent-model-tier:** 스킬과 메인 spec `distribution/agent-model-tier` 를 ③에서 삭제한다
  (플러그인 캐시 폴더의 `model:` 줄을 직접 고치는 전제가 무너짐). 델타는 `## REMOVED Requirements` 로 7개 전부 지우고
  ③의 `.openspec.yaml` 에 `retire_capabilities: true` 를 넣는다.

### 4. 메인 spec의 `.claude/` 경로 94곳 처리 규칙
메인 spec 15개 중 14개에 `.claude/` 경로가 약 94번 나온다 (designer가 `grep -c` 로 다시 셈: 합계 94).
③에서 파일이 `agents/`·`skills/` 로 옮겨지면 전부 낡는다. 처리 규칙은 아래와 같다.

1. **표기 전환:** ③부터 새로 쓰거나 고치는 요구사항·Scenario는 경로 대신 **역할 이름**으로 적는다.
   예: `.claude/agents/worker.md` → "worker 에이전트 파일", `.claude/skills/orchestra/SKILL.md` → "orchestra 스킬".
   경로를 꼭 적어야 하면 플러그인 루트 기준 상대 경로(`agents/worker.md`)로 적는다.
2. **델타 범위:** ③의 specs 델타는 **요구사항이 실제로 바뀌는 capability만** MODIFIED / ADDED / REMOVED 한다.
   단순 경로 치환만 필요한 capability는 델타를 만들지 않는다 (요구사항을 지어내지 않는다).
3. **단순 경로 치환은 ③의 sync 때 한꺼번에:** ③의 finalizer가 sync할 때 나머지 메인 spec의 `.claude/` 경로를
   역할 이름으로 일괄 치환한다. 요구사항의 의미는 바꾸지 않는다. 치환 전후 `grep -c '\.claude/'` 수를 ③의 review/commit 기록에 남긴다.
   (단, `.claude/settings.local.json` 처럼 플러그인 전환 뒤에도 실제로 남는 사용자 프로젝트 경로는 그대로 둔다.)
4. ①·④·②에서는 경로를 일괄 치환하지 않는다. 그 사이에 고치는 요구사항도 기존 경로 표기를 유지해 diff를 작게 둔다.

### 5. ③ 첫 작업의 실험 관문
③의 첫 작업은 analysis.md "미확인" 7개를 `claude --plugin-dir` 실험으로 확인하는 것이다.
**skills 주입과 `${CLAUDE_PLUGIN_ROOT}` 치환이 둘 다 안 되면** `bin/sdd-rules` 출력 방식으로 바꾸고,
그래도 불편하면 3안으로 돌아갈지 사용자에게 다시 묻는다 (analyzer가 적은 뒤집히는 조건).
