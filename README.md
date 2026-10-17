# init-SDD

**어떤 프로젝트에든 얹어서 바로 시작하는 SDD(사양 주도 개발) 초기 구조.**

Claude Code 플러그인 `sdd`를 설치하고 프로젝트에서 `/sdd:init`을 한 번 돌리면, 그 프로젝트의 Claude Code가
"요구사항 정리 → 설계 → 구현 → 리뷰 → 회귀 검증 → 커밋" 순서로 일하게 된다. 각 단계는 전용 서브에이전트가 맡고,
사양과 작업 기록은 프로젝트의 `openspec/`에 쌓인다. 기본(작은 작업)은 `preparer → worker → reviewer → finalizer`이고,
큰 작업은 `preparer → designer → worker → reviewer (+ regression-verifier) → finalizer`다. `regression-verifier`(회귀 검증)는
큰 작업이고, 실행 코드가 바뀌었고, 프로젝트에 테스트 명령이 있을 때만 reviewer와 함께 붙는다(기준은 `orchestra` 스킬).
분석과 **사용자가 방안 선택**하는 단계는 기본 경로에는 없다 — `"분석해줘"`, `"방안 뽑아줘"`처럼 방안 비교를 요청하면 그때 열린다.

## 빠른 시작

Claude Code 안에서 마켓플레이스를 등록하고:

```text
/plugin marketplace add CHO-YoungSeok/init-SDD
```

플러그인을 설치한다:

```text
/plugin install sdd@sdd-marketplace
```

그 뒤 SDD를 쓸 프로젝트에서 한 번:

```text
/sdd:init
```

이제 평소처럼 말하면 된다(예: `로그인에 2단계 인증 추가해줘`). 다음 세션부터 훅이 지휘 규칙을 넣는다.
자세한 설명은 아래 "설치"에 있다.

필요한 것:

| 필요한 것 | 확인 | 없으면 |
|---|---|---|
| Claude Code | `claude --version` | [설치 안내](https://claude.com/claude-code) |
| OpenSpec CLI | `node --version`, `npx --version` (Node/npx만 있으면 된다 — `sdd-openspec`이 1.14.1을 받는다) | Node.js 설치 |
| git 저장소 | `git status` | `git init` |

## 이게 왜 필요한가

Claude Code에게 큰 일을 그냥 맡기면, 분석과 설계와 구현이 한 덩어리로 섞여서
**어떤 방향으로 갈지 사람이 개입할 지점이 없다.** 다 끝난 뒤에야 "이게 아닌데"를 알게 된다.

이 구조는 그 지점을 만든다. 작은 작업에는 사람이 개입할 지점이 셋 있다 — **범위 밖 확인**
(요구사항 정리 직후, "그것도 해줘" 할 기회), **조건부 통과 확인**(리뷰에서 지적이 남았을 때),
**커밋 직전 확인**(diff 요약을 보고 확인). 큰 작업에는 여기에 **설계 요약
알림**(설계가 끝났을 때)이 더해진다.
사용자가 원하면 여기에 **방안 3가지를 들고 와서 사람에게 고르게 하는** 방안 선택 관문을
언제든 열 수 있다 — analyzer를 부르면 뜬다. 그 선택은 파일로 기록되고(`decision.md`),
리뷰 단계에서 "고른 대로 됐는지"를 검사한다.

## 작동 방식

### 쓰는 법

```
로그인에 2단계 인증 추가해줘
```

그냥 평소처럼 말하면 된다. 오케스트레이터가 크기를 재고 알맞은 경로로 보낸다.
직접 파이프라인을 부르고 싶으면 `/sdd:orchestra` 를 쓴다.

사용자가 **반드시** 답해야 하는 지점은 세 곳이고, 상황에 따라 더 묻는다
(진행 중 change가 2개 이상일 때, 에이전트가 질문을 올렸을 때, 두 번 고쳐도 안 될 때,
중간에 취소할 때, 그리고 analyzer를 부르면 방안 선택도 물어야 한다).

1. 요구사항 정리 후 — **범위 밖** 확인 ("그것도 해줘" 할 기회. 여기서 "방안을 비교해 보고
   고르시겠어요? 아니면 바로 진행할까요?"도 함께 물어본다)
2. 조건부 통과가 나왔을 때 — 남은 지적을 지금 고칠지 정한다
3. 커밋 직전 — diff 요약을 보고 확인한다

**★ 방안 선택**(3가지 안과 각각의 장단점, 추천안을 보고 고른다)은 기본 경로에는 없다.
`"분석해줘"`, `"방안 뽑아줘"`, `"선택지 보여줘"`, `"analyzer 불러"` 같은 말로 analyzer를
부르면 그때 열린다.

작은 수정(오타, 주석)은 이 관문을 전부 건너뛰고 바로 처리된다.

### 일의 크기에 따라 경로가 갈린다

| 일 | 경로 | 서브에이전트 호출 | 묻는 횟수 |
|---|---|---|---|
| 오타·주석·이름 변경 (**동작 안 바뀜**) | worker → finalizer | 2번 | 0 |
| 작은 작업 (기본) | `preparer → worker → reviewer → finalizer` | 4번 | 3 |
| 큰 작업 | `preparer → designer → worker → reviewer (+ regression-verifier) → finalizer` | 5~6번 | 3 |
| "이거 왜 이래?" 조사 | `preparer → analyzer` (analyzer는 change가 있어야 돈다) | 2번 | 1~2 (고칠지 1번, 고치지 않고 끝나면 change 정리 1번. 고치면 3단계 방안 선택부터 큰 작업 관문이 이어진다) |

작은 작업과 큰 작업을 가르는 판정 기준은 `orchestra` 스킬에 있다 (이 문서에 옮겨 적지 않는다).
방안 비교가 필요해지면 그 자리에서 `"방안 뽑아줘"`라고 말해 analyzer를 끼워 넣으면
호출이 한 번 늘고 묻는 횟수가 4가 된다.

### 7개 서브에이전트

| 에이전트 | 하는 일 | 모델 |
|---|---|---|
| `preparer` | 요구사항 정리, 작업 브랜치 + OpenSpec change 생성, proposal 작성 (작은 작업이면 작업 목록까지) | sonnet |
| `analyzer` | 코드베이스 분석, **방안 최소 3가지 + 의견과 근거** (부를 때만 돈다) | opus |
| `designer` | 큰 작업일 때만 — specs 델타, design.md, tasks.md (analyzer를 불렀으면 결정 기록 decision.md도) | opus |
| `worker` | 구현, 파일 수정, 테스트 (코드를 만지는 유일한 에이전트) | sonnet |
| `reviewer` | 요구사항 충족·설계 준수·작업 완료 검증 (읽기 전용) | opus |
| `regression-verifier` | 기존 동작이 깨졌는지 (읽기 전용, reviewer와 병렬). 큰 작업이고, 실행 코드가 바뀌었고, 테스트 명령이 있을 때만(`orchestra` 기준) | sonnet |
| `finalizer` | 메인 spec 갱신(sync) → 커밋 | sonnet |

모델은 각 에이전트 파일의 `model:` 한 줄이 기본값이다.

### 보조 에이전트: code-explorer

위 7개 에이전트 외에 `code-explorer`라는 8번째 에이전트가 있다. 이 에이전트는 파이프라인 단계가
아니라 7개 에이전트 각자가 코드베이스를 넓게 뒤져야 할 때 직접 부르는 읽기 전용 도구다.
파이프라인 7개 표 밖의 보조 에이전트이고, `model: haiku`로 고정된다.

### 만들어지는 파일

한 번의 작업이 `openspec/changes/<change-이름>/` 에 이런 기록을 남긴다.

| 파일 | 누가 씀 | 무엇 |
|---|---|---|
| `proposal.md` | preparer | 무엇을 / 왜 + 받아들일 조건 |
| `analysis.md` | analyzer | 분석 결과와 방안 3가지 (스키마 밖 파일) |
| `decision.md` | designer | **사용자가 고른 안** (리뷰의 기준, analyzer를 불렀을 때만) |
| `specs/<capability>/spec.md` | designer (작은 작업이면 preparer) | 요구사항 변화분(델타) |
| `design.md` | designer | 어떻게 (조건부) |
| `tasks.md` | designer (작은 작업이면 preparer) | 작업 목록 |
| `review.md` | reviewer | 판정 (finalizer가 읽어 확인) |
| `.openspec.yaml` | `sdd-openspec new change` 가 만들고, preparer / designer 가 마커만 덧붙임 | spec 없는 change 표시(`skip_specs`) · capability 은퇴 표시(`retire_capabilities`) |

작업이 끝나면 `finalizer`가 델타를 `openspec/specs/` 의 메인 spec에 병합한다.
그게 이 프로젝트의 **누적된 사양**이 된다.

## 설치

### 플러그인으로 설치

에이전트와 스킬은 Claude Code 플러그인 `sdd`로 실린다. 대상 프로젝트의 `.claude/`에는
아무것도 복사하지 않는다. 에이전트 이름은 `sdd:<이름>`(예: `sdd:worker`), 스킬은 `/sdd:orchestra`, `/sdd:init`이다.

Claude Code 안에서 마켓플레이스를 등록하고:

```text
/plugin marketplace add CHO-YoungSeok/init-SDD
```

플러그인을 설치한다:

```text
/plugin install sdd@sdd-marketplace
```

로컬 복제본이 있으면 `/plugin marketplace add <복제본 경로>`로 등록해도 된다.
그 뒤 SDD를 쓸 프로젝트에서 `/sdd:init`을 한 번 돌린다. `openspec/`을 초기화하고, `openspec/config.yaml`의
`context:` 초안과 권한 목록을 보여 주고 동의를 받은 뒤에 기록한다.

`sdd-openspec init --tools claude`가 까는 `.claude/commands/opsx/`와 `.claude/skills/openspec-*`는 이 파이프라인에
필요 없다(지워도, 남겨도 된다). `/sdd:init`은 `--tools none`으로 초기화해서 그것들을 깔지 않는다.

### 훅 켜기·끄기

`/sdd:init`이 만드는 표식 파일 `openspec/.sdd`가 있는 프로젝트에서만 SessionStart 훅이
지휘 규칙과 점검 결과를 넣는다. 켜는 것도 끄는 것도 다음 세션부터 적용된다.
표식을 커밋하면 같은 저장소에서 플러그인을 깐 팀원에게도 켜진다.
그 프로젝트에서 끄려면 표식을 지운다. 모든 프로젝트에서 끄려면 `/plugin disable sdd`.

### 권한

`/sdd:init`은 권한 목록을 보여 주고 동의를 받은 뒤 `.claude/settings.local.json`에만 빠진 줄을 더한다. 공유 `.claude/settings.json`은 고치지 않는다.

훅 점검은 프로젝트의 두 파일(`.claude/settings.json`, `.claude/settings.local.json`)만 본다. 권한을 전역 `~/.claude/settings.json`에 두었다면 "권한에 Bash(sdd-openspec:*)가 없다" 경고는 무시해도 된다.

### 업데이트

```bash
claude plugin marketplace update sdd-marketplace
claude plugin update sdd@sdd-marketplace
```

그 뒤 Claude Code를 다시 시작한다(Claude Code 2.1.294의 `--help`로 확인한 명령). 새 판을 낼 때는
`.claude-plugin/plugin.json`의 `version`을 올린다.

### 팀 배포

프로젝트 `.claude/settings.json`에 `extraKnownMarketplaces`와 `enabledPlugins`를 넣으면
팀원이 그 저장소를 신뢰할 때 플러그인 설치를 안내받는다.

```json
{
  "extraKnownMarketplaces": {
    "sdd-marketplace": { "source": { "source": "github", "repo": "CHO-YoungSeok/init-SDD" } }
  },
  "enabledPlugins": { "sdd@sdd-marketplace": true }
}
```

### Windows

훅과 `bin/`의 실행 파일이 bash 스크립트라 bash(Git Bash 또는 WSL)가 필요하다.

### 프로젝트 규칙 심기 (빼먹으면 에이전트가 스택을 스스로 고른다)

`/sdd:init`이 초안을 보여 주고 동의 뒤 적는다. 나중에 고칠 때는 아래처럼 손으로 적는다.

`openspec/config.yaml` 에 `context:` 를 적어라.

> **주의: 줄 맨 앞에(들여쓰기 없이) 새로 적어라.** 예시 주석에서 `#` 만 지우면 들여쓰기가 남아
> YAML이 깨지고, openspec은 **경고만 내고 그 파일을 통째로 무시한다**(종료코드는 0이라 눈치채기 어렵다).
> 적은 뒤 `sdd-openspec context` 를 돌려 `Warning` 이 없는지 확인해라.

```yaml
context: |
  기술 스택: <언어/프레임워크>
  테스트 명령: <실제 명령>
  빌드 명령: <실제 명령>
  기본 브랜치: <이름>
  관례: <있으면>
```

**여기가 프로젝트 사정이 모든 에이전트에게 전달되는 유일한 통로다.**
에이전트 파일을 고치는 것보다 이게 낫다. 비워 두면 빈 프로젝트에서 analyzer가 스택을 발명한다.

## 커스터마이즈

플러그인으로 깐 파일은 업데이트 때 새 판으로 바뀐다. 오래 쓸 수정은 이 저장소를 포크해서 고치고,
`claude --plugin-dir <포크 경로>`로 띄우거나 포크를 마켓플레이스로 등록해 쓴다.

- **모델 바꾸기** — 각 에이전트 파일(`agents/<이름>.md`)의 `model:` 한 줄이 기본값이다. 바꾸려면 그 줄을 고친다.
- **단계 늘리기** — `agents/`에 파일 하나 추가하고 `skills/orchestra/SKILL.md`의 파이프라인에 배선한다
- **프로젝트 규칙 주입** — `openspec/config.yaml` 의 `context:` 와 `rules:`.
  거기 적은 내용이 모든 산출물 작성에 제약으로 들어간다. 에이전트 파일을 고치는 것보다 이게 낫다
- **스킬 추가** — 쓰면서 필요한 걸 `skills/`에 늘려 간다. 이 구조는 그걸 전제로 만들었다

## 알아 둘 것

- **`openspec/` 을 `.claude/` 밑으로 옮기지 마라.** OpenSpec은 현재 위치에서 **위로** 올라가며
  `openspec/` 을 찾는다. `.claude/openspec/` 에 두면 저장소 루트에서 `no_openspec_root` 가 나고
  모든 에이전트의 첫 명령이 실패한다.
- **서브에이전트는 사용자에게 직접 물을 수 없다.** 질문은 보고서에 담겨 오케스트레이터를 거친다.
  그래서 범위 밖 확인·방안 선택 같은 관문이 메인 세션에 있다.
- **에이전트는 openspec 스킬을 부르지도 읽지도 않는다.** `sdd-openspec instructions` 출력과 공용 규칙
  `sdd-rules`, spec 병합 절차 `sdd-sync`를 따른다.
- **되돌릴 수 없는 일은 에이전트가 하지 않는다.** `git push`, `sdd-openspec archive`는
  사용자가 명시적으로 요청해야 한다. 메인 spec 파일 삭제(capability 은퇴)는 커밋 확인 때 은퇴 대상을 보여 주고,
  사용자가 커밋을 승인한 change에서만 finalizer가 한다.
- **작은 작업 한 번은 서브에이전트 4번 호출이고, 큰 작업은 5~6번이다** (designer·reviewer가 opus).
  analyzer를 부르면 한 번 늘어난다(그때는 analyzer도 opus). 느리고 토큰을 많이 쓴다. 오타 수정에는 자동으로
  경량 모드(worker → finalizer)가 쓰인다. 비용이 부담되면 해당 에이전트 파일들의 `model:` 을 손으로 내려라.
- **대화형 세션에서만 제대로 돈다.** 범위 밖 확인, 커밋 직전 확인 같은 필수 질문이 대화형
  질문이라 `claude -p` 같은 비대화형 실행에서는 그 관문들이 뜨지 않는다.
- **기존 코드가 있는 프로젝트는 처음에 spec이 0개다. 그게 맞다.** change를 하나씩 돌리면서
  건드리는 부분만 spec으로 쌓인다. 코드베이스 전체를 미리 문서화하지 않아도 된다.
- `sdd-openspec init --tools claude`로 초기화하면 `/opsx:propose` 같은 명령 6개도 깔린다(`/sdd:init`은 깔지 않는다).
  **그걸 직접 쓰면 리뷰 단계가 사라진다.** analyzer를 부른 경우라면
  결정 기록(decision.md)과 방안 선택 관문까지 함께 건너뛰게 된다. 평소엔 그냥 말로 시켜라.
- 에이전트 파일과 이 문서는 **한국어**다. 파이프라인도 한국어로 말한다.
  다른 언어로 쓰려면 포크에서 `agents/*.md`와 `skills/{orchestra,sdd-rules,sdd-sync,init}/SKILL.md`를 번역하고,
  산출물 언어는 `sdd-openspec init --language <언어>` 로 정한다.
- **OpenSpec 버전:** 플러그인은 `sdd-openspec`이 1.14.1을 고정해 실행한다.
  버전이 올라 명령이 바뀌어도 에이전트는 `sdd-openspec instructions` 출력을 정답으로 삼아 대부분 따라간다.
- **버전 확인:**
  ```bash
  sdd-openspec --version    # 1.14.1
  ```
  에이전트 파일이 가정한 CLI 세부와 실제 출력이 다르면 정답은 `sdd-openspec status --change <이름> --json`의 실제 출력이다.
  에이전트 파일도 전부 "경로와 상태는 CLI에서 얻는다. 짐작하거나 하드코딩하지 마라"고 말한다.

## 개발 (이 저장소를 고칠 때)

저장소 루트가 플러그인 `sdd`의 루트다. 고칠 때는 저장소 루트에서 이렇게 띄운다.

```bash
claude --plugin-dir .
```

에이전트는 `agents/`, 스킬은 `skills/`가 원본이다. `--plugin-dir`이 같은 이름으로 설치된 플러그인보다 우선한다.
이 저장소의 프로젝트 지침 파일은 `.claude/CLAUDE.md`다(루트는 플러그인 루트라 `CLAUDE.md`를 두지 않는다).
검증 명령과 커밋 규칙은 `.claude/CLAUDE.md`에 있다.
