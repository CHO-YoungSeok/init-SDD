## Why

지금은 모든 정식 요청이 `analyzer`를 강제로 거치고, 그 뒤에 이어지는 "★사용자가 방안 선택" 관문도
같이 강제된다. 사용자가 이미 방향을 정하고 온 일에도 방안 3가지 생성과 선택 절차가 끼어든다.
사용자는 analyzer를 **호출했을 때만 도는 옵트인 단계**로 바꾸고, 그게 아니라면 파이프라인이
OpenSpec 자체 설계(propose → apply → sync/archive)를 그대로 따라가길 원한다.

또한 설치 수단인 `install.sh`가 **`CLAUDE.md` 조각 문구를 `$SNIPPET`으로 하드코딩하고 있다**
(82-96줄). 그 문구는 저장소 `CLAUDE.md`와 글자 단위로 같고 `README.md`에도 코드블록으로 한 벌
더 있다 — **같은 조각이 3벌**이다. 이 저장소는 실행 코드가 없고 지시문이 곧 제품이라,
사본이 갈라지는 것이 가장 나쁜 고장이며 이미 두 번 났다. 조각의 원본을 한 곳으로 줄인다.
`install.sh`가 깔던 제품이 4종인데 아래 세 번째 항목으로 5종이 되는 것도 함께 맞춘다.

> **경과 기록:** 이 축은 처음에 "`install.sh`를 지우고 설정 전환 스킬(`switch_skill`)로
> 대체한다"로 잡혔고 실제로 그렇게 만들어 실측까지 했다. 그 뒤 사용자가
> *"switch skill은 필요 없겠어. 제거해"* 라고 결정해 **전환 스킬은 제품에서 빠졌고
> `install.sh`가 되살아났다.** 전환기가 풀려던 문제(겹치는 설정을 보관하고 갈아타기)는
> 에이전트 설정을 각자 로컬에서 관리하면 애초에 생기지 않는다는 판단이다.
> 근거와 남은 범위는 `decision.md`의 `## 결정 변경 2026-09-11`(결정 6~8)에 있다.

셋째로, 정식 경로 한 번이 서브에이전트 여러 번 호출이고 그중 셋이 opus다. 비용을 줄이려면
지금은 에이전트 파일 7개를 하나씩 열어 `model:` 줄을 손으로 고쳐야 한다. 사용자는 이걸
**등급 하나로 한 번에 갈아 주는 스킬**로 원한다 — `normal`(지금) / `semi-lower` / `lower`.

## What Changes

- 기본 파이프라인에서 `analyzer`를 뺀다. 기본 경로는
  `preparer → designer → worker → reviewer + regression-verifier → finalizer`가 된다.
  **BREAKING**: 지금까지 모든 정식 요청에서 강제로 일어나던 "★사용자가 방안 선택" 관문이
  기본 경로에서는 더 이상 일어나지 않는다.
- `analyzer`는 사용자가 명시적으로 부를 때만 도는 옵트인 단계로 남는다. `analyzer.md` 파일
  자체는 지우지 않는다. 어떤 말을 해야 analyzer가 도는지(트리거 문구/조건)를 이번 change 안에서
  확정한다.
- `analyzer`를 실제로 호출한 경우에는 지금과 같이 방안 3가지 제시 → 사용자 선택 →
  (자기 안을 내면 재호출) 흐름이 그대로 유지된다. 이 흐름 자체를 없애는 게 아니라,
  **경로에 들어가는 조건**을 "항상"에서 "요청했을 때"로 바꾸는 것이다.
- `analyzer`를 부르는 신호는 **자연어**로 정했다 (사용자 결정, `decision.md` 결정 2).
  `"분석해줘"`, `"방안 뽑아줘"`, `"선택지 보여줘"`, `"analyzer 불러"` 같은 말이면 부른다.
  이름을 정확히 대지 않아도 된다. orchestra SKILL.md에 **판별 가능한 신호 목록과 하나의 판단
  기준, 그리고 애매할 때 기울 방향**을 적는다.
- 파이프라인 순서를 적은 곳을 새 기본 순서에 맞게 고친다:
  `.claude/skills/orchestra/SKILL.md`(frontmatter description, 파이프라인 그림, 스킬 대응표,
  "왜 propose를 안 부르나" 설명, "네가 직접 하면 안 되는 것" 절, 묻는 지점 표, 단계 축약 절),
  `CLAUDE.md`, `README.md`. `install.sh`의 `$SNIPPET` 사본은 하드코딩 자체를 없애므로
  덩달아 사라진다.
- **`CLAUDE.md` 조각을 마커 구획으로 감싼다** (`<!-- init-SDD:begin -->` ~
  `<!-- init-SDD:end -->`). 그래야 `install.sh`가 그 조각을 원본에서 기계적으로 뽑아 쓸 수 있다.
  조각 사본이 3벌(이 저장소 `CLAUDE.md`, `install.sh`의 `$SNIPPET`, `README.md` 코드블록)에서
  **1벌**로 줄어든다. **이번 change의 가장 큰 소득이다.**
- **`install.sh`는 저장소에 남는다. 두 곳을 고친다** (사용자 결정, `decision.md` 결정 6).
  - `$SNIPPET` 하드코딩(82-96줄)을 없애고 `CLAUDE.md`의 마커 구획에서 뽑아 쓰게 한다:
    `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$SRC/CLAUDE.md"`
  - 복사 대상에 `.claude/skills/agent-model-tier/`를 더한다. 원래 4종만 깔았다.
    설치 확인 절차(에이전트 7개 세기, 스킬 개수 세기)도 5종에 맞춘다.
  - 나머지 절차(전제 조건 확인, `openspec init --tools claude`, "이미 있으면 건너뛴다"는
    안전 모델, 설치 확인, 다음 할 일 안내)는 **그대로 둔다.**
- **`README.md`의 설치 절을 `install.sh` 기준으로 쓴다.** `README.md`가 `CLAUDE.md` 조각을
  코드블록으로 한 벌 더 베껴 두고 있는 것을 없애고, 대신 마커 구획에서 뽑는 `sed` 한 줄로
  대체한다.
- ~~저장소 루트에 `switch_skill/SKILL.md`를 새로 만든다~~ → **취소됐다** (사용자 결정,
  `decision.md` 결정 6: *"switch skill은 필요 없겠어. 제거해"*). 이미 만든 파일
  `switch_skill/SKILL.md`(646줄)를 **지운다.** 에이전트 설정은 사람마다 달라서 공유 저장소가
  들고 다닐 물건이 아니고, 각자 로컬에서 관리하면 전환기가 풀려던 문제가 애초에 생기지 않는다.
  ~~`install.sh`를 지운다~~ 도 함께 취소됐다 — 삭제의 근거가 "스킬이 기능상 상위집합"
  하나였고 스킬이 없어지면서 그 근거가 사라졌다.

- **서브에이전트 모델 등급 스킬을 새로 만든다** (사용자 결정 3, `decision.md`).
  `.claude/skills/agent-model-tier/SKILL.md`에 활성 스킬로 두고, 7개 에이전트의
  frontmatter `model:` 한 줄을 등급 세 개(`normal` / `semi-lower` / `lower`)로 한 번에
  갈아 준다. 토큰을 아끼려고 등급을 내리고, `normal`로 되돌릴 수 있어야 한다.
  **이 스킬이 더해져 제품이 4종에서 5종으로 늘어난다** — `install.sh`의 복사 대상과
  README의 제품 설명·설치 확인 절차도 5종에 맞춘다.

## Capabilities

### New Capabilities
- `distribution/agent-model-tier`: `.claude/skills/agent-model-tier/SKILL.md`가 제공하는
  모델 등급 전환의 요구사항 — 등급 세 개의 값 표를 스킬 안에 값으로 갖기(되돌리기 위해
  `normal`도 포함), 지금 등급 판별과 섞인 상태 보고, 양방향·반복 안전, `model:` 한 줄만
  부분 수정(전체 재작성과 `sed -i` 금지), 낮추면 조용히 나빠진다는 경고,
  `allowed-tools`를 좁히지 않음, `description`에 발동 조건 포함.
- `distribution/sdd-install-script`: `install.sh`가 제공하는 설치 절차의 요구사항 —
  전제 조건 확인, 제품 **5종** 설치(`agent-model-tier` 포함), `CLAUDE.md` 조각을 하드코딩하지
  않고 마커 구획에서 뽑아 쓰기(조각 원본 1벌), 이미 있는 파일을 덮어쓰지 않기, 설치 확인과
  다음 할 일 안내, 설치 안내가 `README.md` 한 곳에만 있기.

  > **capability 이름을 갈았다.** 처음에는 전환 스킬을 규정하는
  > `distribution/sdd-config-switch`였다. 전환 스킬이 빠졌지만 그 델타 안에 **살아남아야 하는
  > 요구사항**(조각 1벌, 제품 5종, 설치 안내 한 곳)이 섞여 있어서, 그냥 지우지 않고
  > `distribution/sdd-install-script`로 옮겨 `install.sh` 기준으로 다시 썼다.
  > 근거는 `decision.md` 결정 8. `distribution/sdd-config-switch`는 **메인 spec에 병합된 적이
  > 없어** 은퇴 대상이 아니다 (`retire_capabilities` 마커를 넣지 않는다 — 결정 7).

### Modified Capabilities
- `agent-instructions/analyzer-option-generation`: 지금 이 spec은 "analyzer가 파이프라인 기본
  경로의 일부"라는 전제 위에서 orchestra의 파이프라인 그림, 스킬 대응표, "사용자가 자기 안을 냈을
  때 analyzer를 재호출한다"는 안전장치, README의 analyzer 설명을 규정하고 있다. analyzer가
  옵트인이 되면 이 전제가 바뀐다: 재호출 안전장치와 "안 하나로 넣어 평가한다"는 절차 자체는
  유지하되, **그 흐름이 일어나는 조건**(항상 → 사용자가 analyzer를 이미 불렀을 때만)을 반영하도록
  요구사항과 시나리오를 고친다.

## Impact

- `.claude/skills/orchestra/SKILL.md` — frontmatter `description`, 파이프라인 그림, 스킬 대응표,
  "왜 propose를 안 부르나" 설명, "네가 직접 하면 안 되는 것" 절, analyzer 호출 절차(옵트인 트리거
  조건 추가)
- `CLAUDE.md` — 파이프라인 순서 문구 + 마커 구획 추가
- `README.md` — 설치 절, 파이프라인 순서 문구, "이게 왜 필요한가", 묻는 지점, 경로 표,
  에이전트 표, "알아 둘 것". `CLAUDE.md` 조각 코드블록 제거하고 `sed` 한 줄로 대체
- `openspec/specs/agent-instructions/analyzer-option-generation/spec.md` — 델타로 갱신
- **`install.sh` — 남는다.** `$SNIPPET` 하드코딩 제거(마커 구획에서 `sed`로 뽑기),
  복사 대상에 `agent-model-tier` 추가, 설치 확인을 5종에 맞춤
- 새 파일: `.claude/skills/agent-model-tier/SKILL.md` (활성 스킬)
- 새 파일: changeRoot의 `verification.md` — 임시 프로젝트 실측 결과 (스키마 밖 파일이지만
  changeRoot 안이라 커밋되고 archive된다). **전환기 실측 절은 "이 기능은 이후 제거됐다"를
  머리에 밝히고 기록으로 남긴다** — 스킬 결함 4개를 찾아낸 과정이라 남길 값이 있다.
  갈래 ⑦(등급 한 바퀴)은 지금도 유효한 검증이다
- **삭제: `switch_skill/SKILL.md`** (646줄, 사용자 결정 6)
- 제품 구성이 4종 → **5종** (모델 등급 스킬 추가). `install.sh`의 복사 대상,
  README의 제품 설명과 설치 확인 절차가 함께 바뀐다
- 복사 대상(제품 5종): `.claude/agents/*.md` 7개, `.claude/skills/orchestra/`,
  `.claude/skills/agent-model-tier/`, `.claude/settings.json`, `CLAUDE.md` 조각.
  `install.sh`의 안전 모델은 **"이미 있으면 건너뛴다"** 그대로다 (`settings.json`이 이미
  있으면 건너뛰고 "permissions.allow 배열만 합쳐라"를 사람에게 알린다)
- 복사 대상이 아닌 것: `.claude/skills/openspec-*` 6개(openspec CLI가 깔아 주는 것이며 SDD
  전용이 아니다), `.claude/settings.local.json`(개인 설정, 이미 `.gitignore` 대상)
- **고치지 않는 것으로 확인됐다:** `openspec/config.yaml`의 `context`와 메인 spec
  `agent-instructions/project-context-completeness`가 검증 수단으로
  `bash -n install.sh` / `bash install.sh --dry-run`을 적고 있다. `install.sh`가 남으므로
  그 문장은 **참 그대로**다
- `docs/example-run.md` — 추적 제외된 로컬 문서지만 "지금 이렇게 돈다"를 설명하는 문서이고
  기존 메인 spec의 시나리오가 이 파일을 이름으로 지목하고 있어, 파이프라인 순서 대목을 함께
  고친다 (커밋되지는 않는다). `docs/final-report.md`와 `docs/verification-2026-09-08.md`는
  **날짜가 박힌 과거 기록이라 고치지 않는다.**

## Acceptance Criteria

- [ ] 기본 경로(`analyzer`를 부르지 않은 일반 요청)가
      `preparer → designer → worker → reviewer + regression-verifier → finalizer` 순서로
      진행되고, 방안 선택 관문이 일어나지 않는다 — orchestra SKILL.md, README.md, CLAUDE.md의
      순서 문구가 모두 이 순서와 일치한다 (grep 대조)
- [ ] analyzer를 부르는 옵트인 트리거(사용자가 어떤 말을 하면 도는지)가 orchestra SKILL.md에
      명시되어 있고, 실제로 그 트리거로 analyzer를 호출하는 절차가 남아 있다
- [ ] analyzer를 실제로 호출한 경우 방안 3가지 제시 → 사용자 선택 → 자기 안 제시 시 재호출
      흐름이 그대로 동작한다 (기존 `agent-instructions/analyzer-option-generation`의 관련
      시나리오가 옵트인 조건 위에서도 유지된다)
- [ ] `analyzer.md` 파일은 삭제되지 않고 남아 있다
- [ ] 기본 경로에서 designer를 부르는 프롬프트 예시에 `analyzer 생략: 예`와
      `채택안: 없음`이 들어 있다 (없으면 designer가 `설계중단 | reason=채택안 없음`으로 멈춘다)
- [ ] **`CLAUDE.md` 조각이 저장소 전체에 딱 한 벌만 있다.** `install.sh`의 `$SNIPPET` 사본과
      `README.md`의 코드블록 사본이 둘 다 없어졌고, 남은 한 벌은 `CLAUDE.md`의 마커 구획
      (`<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->`) 안에 있다 (grep으로 파일 수를 센다)
- [ ] **`install.sh`가 저장소에 있다.** `bash -n install.sh`가 종료코드 0이고,
      임시 프로젝트에서 `bash install.sh --dry-run`과 실제 설치가 둘 다 성공한다
- [ ] **`install.sh`에 `$SNIPPET` 하드코딩이 없다.** 조각 문구를 파일 안에 베껴 적는 대신
      `sed -n '/<!-- init-SDD:begin -->/,/<!-- init-SDD:end -->/p' "$SRC/CLAUDE.md"` 형태로
      마커 구획에서 뽑아 쓴다. 실측으로 **뽑힌 내용이 `CLAUDE.md`의 구획과 같은지** 확인한다
- [ ] **`install.sh`가 제품 5종을 깐다.** 복사 대상에 `.claude/skills/agent-model-tier/`가
      있고, 임시 프로젝트에 실제로 복사되는 것을 실측으로 확인한다
- [ ] `install.sh`의 설치 확인 절차가 5종에 맞다 (에이전트 7개 세기, `orchestra`와
      `agent-model-tier` 존재 확인, openspec 스킬 6개 확인)
- [ ] **`install.sh`가 조각이 이미 들어갔는지를 낱말 검색만으로 정하지 않는다.**
      마커 구획을 지문으로 쓰고, 세 갈래(마커 있음 → 건너뜀 / 마커도 낱말도 없음 → 덧붙임 /
      마커는 없고 낱말만 있음 → **넣지 않고 알림**)로 나눈다. 같은 프로젝트에 두 번 돌려도
      마커 구획이 정확히 하나인 것을 실측으로 확인한다
- [ ] `switch_skill/SKILL.md`가 저장소에 없다 (사용자 결정 6으로 제거됐다)
- [ ] `.claude/skills/agent-model-tier/SKILL.md`가 있고, `normal` / `semi-lower` / `lower`
      세 등급의 값 표가 **7개 에이전트 전부에 대해 스킬 안에 값으로** 적혀 있다
      (`normal`도 포함 — 없으면 되돌릴 수 없다)
- [ ] `normal` 표의 값이 지금 실제 값과 같다: preparer sonnet, analyzer opus, designer opus,
      worker sonnet, reviewer opus, regression-verifier sonnet, finalizer sonnet
- [ ] `semi-lower`는 각 에이전트를 **한 단계 내린** 값이다 (`opus → sonnet`,
      `sonnet → haiku`): analyzer·designer·reviewer는 sonnet,
      preparer·worker·regression-verifier·finalizer는 haiku. 그 규칙이 표와 함께 적혀 있다
- [ ] `lower`는 7개 전부 haiku다
- [ ] 모델 값은 짧은 이름(`opus` / `sonnet` / `haiku`)으로 적혀 있고, 전체 모델 ID가
      박혀 있지 않다
- [ ] 지금 어느 등급인지 스킬로 확인할 수 있고, 어느 표와도 안 맞는 섞인 상태를 짐작하지 않고
      7개의 실제 값과 함께 보고한다
- [ ] 등급 적용이 양방향이고 몇 번을 해도 안전하다 (같은 등급을 다시 적용하면 아무것도
      바뀌지 않고, `normal`로 언제든 되돌아온다)
- [ ] 스킬 절차에 **`model:` 한 줄만 Edit으로 고치라는 지시와 전체 재작성·`sed -i` 금지**가
      적혀 있다
- [ ] 등급을 낮추면 무엇이 나빠지는지 경고가 스킬에 담겨 있고, 그 근거가 이 저장소 문서
      (`orchestra/SKILL.md`의 worker 판단 관련 서술, `README.md`의 비용 안내)에서 온 것임을
      알 수 있다
- [ ] `agent-model-tier` 스킬의 `allowed-tools`가 파일 쓰기를 막을 만큼 좁게 선언되어 있지 않다
- [ ] `agent-model-tier` 스킬의 `description`에 발동 조건("모델 낮춰", "토큰 아껴",
      "semi-lower로", "normal로 되돌려" 같은 말)이 들어 있다
- [ ] 등급을 갈아도 각 에이전트 파일의 frontmatter가 온전하다 (`---` 두 줄, `name:`,
      `description:`, `model:`, `tools:` 유지, `model:` 줄이 파일마다 정확히 하나)
- [ ] `install.sh`가 이미 있는 파일을 **덮어쓰지 않는다.** 겹치는 파일은 건너뛰고
      건너뛴 목록과 원본 경로를 사용자에게 알린다 (기존 안전 모델 그대로다)
- [ ] `install.sh`는 `.claude/settings.local.json`을 만들거나 고치지 않고, `.gitignore`에
      한 줄을 더하라는 안내만 한다 (기존 동작 그대로다)
- [ ] `install.sh`가 `.claude/skills/openspec-*` 6개와 `.claude/commands/opsx/`를
      복사하지 않는다. `openspec init --tools claude`가 깔게 한다
- [ ] **`install.sh`를 지우지 않고 남기기로 한 근거가 `decision.md`에 기록된다** (결정 6:
      삭제의 근거가 "스킬이 기능상 상위집합"이었고 그 스킬이 빠지면서 근거가 사라졌다)
- [ ] **`switch_skill`을 뺀 근거가 `decision.md`에 기록된다** (사용자 결정 6)
- [ ] **`distribution/sdd-config-switch` capability를 어떻게 처리했는지와
      `retire_capabilities` 마커 판단이 기록된다** (결정 7·8: 메인 spec에 병합된 적이 없어
      은퇴 대상이 아니다 → 마커를 넣지 않는다)
- [ ] `README.md`만 읽고 `install.sh`로 설치하는 흐름(clone → 대상 프로젝트로 이동 →
      `bash install.sh` → `CLAUDE.md` 합치기 확인 → 새 세션)을 알 수 있다
- [ ] **`install.sh` 재검증 결과가 changeRoot의 `verification.md`에 기록된다.** 최소 네 가지:
      ① `bash -n install.sh` 종료코드 0 ② 임시 프로젝트에서 `bash install.sh --dry-run`
      ③ 임시 프로젝트에서 실제 설치 — **조각이 마커 구획에서 제대로 뽑혀 들어갔는지**
      (`CLAUDE.md`의 구획과 대조) ④ **`agent-model-tier`가 복사됐는지**
- [ ] **`verification.md`의 전환기 실측 절이 지워지지 않고 남아 있고, 머리에 "이 기능은 이후
      제거됐다"가 밝혀져 있다.** 갈래 ⑦(`agent-model-tier` 등급 한 바퀴)은 지금도 유효한
      검증이므로 유효로 남는다
- [ ] 시험은 **임시 디렉터리에서만** 하고 끝나고 치운다. 이 저장소와 사용자의 다른 프로젝트를
      대상으로 삼지 않는다. 시험 뒤 이 저장소에 흔적이 없고
      `git diff --stat -- .claude/agents/`가 비어 있다
- [ ] 시험 결과가 **커밋되는 자리**(`openspec/changes/<change>/verification.md`)에 있다.
      `docs/` 아래는 추적 제외라 쓰지 않는다
- [ ] `openspec validate`가 이 change에 대해 통과한다
- [ ] 수정한 각 마크다운 파일에 `ORCA_RICH_MD` 토큰이 없고 코드펜스 개수가 짝수다

## Out of Scope

- `split-repo-tracking-scope` change가 건드리는 파일과 내용 (보류 중인 별개 작업, 건드리지 않는다)
- analyzer 자체의 내부 절차(방안 만드는 방식, RESULT 형식 등)를 바꾸는 것 — 이번엔 **언제
  불리는지**만 바꾼다
- `designer`·`worker`·`reviewer`·`regression-verifier`·`finalizer`의 내부 절차 변경.
  **단 모델 등급 스킬이 `model:` 한 줄을 바꾸는 것은 여기 해당하지 않는다** — 절차가 아니라
  어느 모델로 도는지를 바꾸는 것이고, 그 스킬을 실제로 실행하는 것은 이번 구현 범위가 아니다
  (스킬 문서를 만드는 것까지다)
- `install.sh`가 `openspec init`이 깔아주는 openspec 공식 스킬 6개를 복사하는 것
  (README가 이미 "그건 복사하지 말고 openspec init이 깔게 하라"고 명시하고 있다 — 이 규칙은
  유지한다)
- `docs/` 아래 문서의 추적 방식(`.git/info/exclude`) 자체를 바꾸는 것
- `.claude/settings.local.json`을 만들거나 고치는 것 (개인 설정이라 손대지 않는다)
- **`install.sh`의 안전 모델을 바꾸는 것.** "이미 있으면 건너뛴다"를 그대로 둔다.
  겹치는 설정을 보관하고 갈아타는 전환 모델은 이번 change에서 **빠졌다** (사용자 결정 6)
- **설정 전환 기능 일체** — 보관 칸, 상태 기록, 켜기/끄기, 양방향 전환.
  `switch_skill`과 함께 범위에서 나갔다

## Assumptions

- ~~"analyzer는 호출했을 때만 동작"의 정확한 트리거~~ → **사용자가 정했다**: 자연어 신호로
  부른다 (`decision.md` 결정 2, `design.md`의 "analyzer를 언제 부르는가").
- ~~`switch_skill`이 서브에이전트를 활용하는 구조라는 가정~~ → **더 이상 해당하지 않는다.**
  전환 스킬 자체가 범위에서 빠졌다 (사용자 결정 6).
- `.openspec.yaml`에는 `skip_specs`를 설정하지 않는다 — 이번 change는 실제로 동작(파이프라인
  경로, 설치 절차)이 바뀌므로 spec 델타가 있어야 한다.
- `.openspec.yaml`에 `retire_capabilities`도 **넣지 않는다** — 지울 메인 spec이 없다
  (`decision.md` 결정 7). 기존 두 키(`schema:`, `created:`)를 그대로 둔다.
- `install.sh`를 되살리는 원본은 `git show HEAD:install.sh`다. 이 브랜치는 커밋이 없고
  `git rm`만 스테이징된 상태라 `HEAD`와 `master`의 파일이 바이트까지 같다 (`md5` 대조로 확인).

## 사용자에게 물어야 할 것 (둘 다 답을 받았다 — `decision.md` 참고)

1. ~~`install.sh`를 이번에 지우는가, 남겨 두는가?~~ → **남긴다** (2026-09-11 재결정,
   `decision.md` 결정 6). 처음에는 "지운다"였고 근거는 "전환 스킬이 기능상 상위집합"이었다.
   사용자가 *"switch skill은 필요 없겠어. 제거해"* 라고 정하면서 그 근거가 사라졌고,
   지우면 **설치 수단이 하나도 안 남는다.** 대신 조각 하드코딩을 없애고 5종을 깔게 고친다.
2. ~~analyzer를 부르는 정확한 트리거는 무엇인가?~~ → **자연어 신호로 부른다.**
   `"분석해줘"`, `"방안 뽑아줘"`, `"선택지 보여줘"`, `"analyzer 불러"` 같은 말이면 부르고,
   이름을 정확히 대지 않아도 된다. 신호 목록·판단 기준·애매할 때 기울 방향을 orchestra
   SKILL.md에 적는다.
