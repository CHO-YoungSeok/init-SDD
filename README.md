# init-SDD

**어떤 프로젝트에든 얹어서 바로 시작하는 SDD(사양 주도 개발) 초기 구조.**

`.claude/` 의 에이전트와 지휘 스킬을 얹고 `openspec init` 한 번 돌리면, 그 프로젝트의 Claude Code가
"요구사항 정리 → 설계 → 구현 → 리뷰 → 회귀 검증 → 커밋" 순서로 일하게 된다. 각 단계는 전용
서브에이전트가 맡는다. 분석과 **사용자가 방안 선택**하는 단계는 기본 경로에는 없다 —
`"분석해줘"`, `"방안 뽑아줘"`처럼 방안 비교를 요청하면 그때 열린다.

## 이게 왜 필요한가

Claude Code에게 큰 일을 그냥 맡기면, 분석과 설계와 구현이 한 덩어리로 섞여서
**어떤 방향으로 갈지 사람이 개입할 지점이 없다.** 다 끝난 뒤에야 "이게 아닌데"를 알게 된다.

이 구조는 그 지점을 만든다. 기본 경로에도 사람이 개입할 지점이 넷 있다 — **범위 밖 확인**
(요구사항 정리 직후, "그것도 해줘" 할 기회), **설계 요약 알림**(설계가 끝났을 때),
**조건부 통과 확인**(리뷰에서 지적이 남았을 때), **커밋 직전 확인**(diff 요약을 보고 확인).
사용자가 원하면 여기에 **방안 3가지를 들고 와서 사람에게 고르게 하는** 방안 선택 관문을
언제든 열 수 있다 — analyzer를 부르면 뜬다. 그 선택은 파일로 기록되고(`decision.md`),
리뷰 단계에서 "고른 대로 됐는지"를 검사한다.

## 전제 조건

| 필요한 것 | 확인 | 없으면 |
|---|---|---|
| Claude Code | `claude --version` | [설치 안내](https://claude.com/claude-code) |
| OpenSpec CLI | `openspec --version` (1.12 이상) | `npm i -g @fission-ai/openspec` 또는 `brew update && brew install openspec` |
| git 저장소 | `git status` | `git init` |

## 설치

### 방법 1 — install.sh (권장)

```bash
git clone --depth 1 https://github.com/CHO-YoungSeok/init-SDD.git /tmp/init-SDD
cd /path/to/your-project
bash /tmp/init-SDD/install.sh --dry-run     # 무엇을 할지 먼저 본다
bash /tmp/init-SDD/install.sh               # 설치
```

그 다음 Claude Code를 **새 세션으로** 다시 연다. 그래야 새 에이전트와 스킬이 잡힌다.

**`--dry-run` 을 먼저 돌려 봐라.** 남의 프로젝트에 파일을 쓰는 스크립트다. `--dry-run` 은
무엇을 복사할지와 무엇을 건너뛸지만 보여주고 **아무것도 바꾸지 않는다.**

이미 겹치는 설정(`CLAUDE.md`, `.claude/agents/`, `.claude/settings.json` 등)이 있으면
**덮어쓰지 않고 건너뛴다.** 건너뛴 파일은 끝에 목록으로 알려 주고, 저장소 쪽 원본 경로도
함께 알려 준다 — 필요한 내용은 직접 보고 옮기면 된다. `CLAUDE.md` 는 예외로, 없으면 새로
만들고 이미 있으면 지시문 조각을 **끝에 덧붙인다** (기존 내용은 그대로 둔다).

### 방법 2 — 손으로

```bash
cd /path/to/your-project

# OpenSpec 초기화 (openspec/ 디렉터리와 공식 스킬 6개 + /opsx 명령 6개를 만든다)
openspec init --tools claude          # 산출물 언어를 정하려면 --language ko (또는 en)

# 에이전트와 지휘 스킬, 모델 등급 스킬 복사
cp -r /tmp/init-SDD/.claude/agents .claude/
cp -r /tmp/init-SDD/.claude/skills/orchestra .claude/skills/
cp -r /tmp/init-SDD/.claude/skills/agent-model-tier .claude/skills/
cp /tmp/init-SDD/.claude/settings.json .claude/      # 권한 프롬프트를 줄인다. 이미 있으면 내용을 확인하고 옮겨라
```

> **`.claude/skills/openspec-*` 와 `.claude/commands/opsx/` 는 복사하지 마라.**
> 이 저장소에 들어 있는 건 1.12.0 스냅샷일 뿐이다. `openspec init`이 네 CLI 버전에 맞는 걸 깔아 준다.
> `cp -r init-SDD/.claude/* .claude/` 를 하면 오래된 걸로 덮어쓴다.

### CLAUDE.md 는 복사하지 말고 **합쳐라**

대상 프로젝트에 이미 `CLAUDE.md`가 있으면 덮어쓰면 안 된다. 이 저장소 `CLAUDE.md`의
`<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->` 구획만 뽑아 **끝에 덧붙인다.**
(`install.sh` 를 쓰면 알아서 해준다)

```bash
sed -n '/init-SDD:begin/,/init-SDD:end/p' /tmp/init-SDD/CLAUDE.md >> CLAUDE.md
```

### 이름이 겹칠 수 있는 파일

`install.sh` 로 설치하면 이 문제를 스크립트가 처리한다 — **이미 있으면 덮어쓰지 않고
건너뛰고**, 끝에 건너뛴 파일 목록과 저장소 쪽 원본 경로를 함께 알려 준다. 잃는 것이 없다.
최악의 경우가 "설치가 덜 된 채로, 무엇이 덜 됐는지 알려 주는 것"이다.

"방법 2 — 손으로"로 설치할 때는 사람이 직접 이 규칙을 지켜야 한다. 복사 전에 대상
프로젝트에 같은 이름이 있는지 확인하고, 있으면 덮어쓰지 말고 내용을 확인해라.

- `CLAUDE.md` → 위 안내대로 **합친다**
- `.claude/agents/{preparer,analyzer,designer,worker,reviewer,regression-verifier,finalizer}.md`
- `.claude/skills/orchestra/`
- `.claude/skills/agent-model-tier/`
- `.claude/settings.json` → 이미 있으면 **덮어쓰지 말고 내용을 직접 확인해서 필요한 줄을
  옮겨라** (`install.sh` 도 이 파일은 합치지 않는다. JSON 을 합치면 키가 겹칠 때 한쪽을
  버려야 하고, 어느 쪽을 버렸는지 사용자가 알 수 없다. 그래서 건너뛰고 원본 경로만 알려 준다)

### 설치 확인

```bash
ls .claude/agents | wc -l                              # 7
ls .claude/skills                                      # openspec-* 6개 + orchestra + agent-model-tier
ls .claude/skills/openspec-{explore,propose,update-change,apply-change,sync-specs,archive-change}/SKILL.md
ls .claude/skills/agent-model-tier/SKILL.md
openspec list                                          # 에러 없이 돌아야 한다
```

스킬이 하나라도 없으면 (전역 설정에 따라 안 깔릴 수 있다):
```bash
openspec config set delivery both
openspec config set profile core
openspec update --force
```

**Claude Code를 새 세션으로 다시 열어야** 새 에이전트와 스킬이 잡힌다.

### 프로젝트 규칙 심기 (빼먹으면 에이전트가 스택을 스스로 고른다)

`openspec/config.yaml` 에 `context:` 를 적어라.

> **주의: 줄 맨 앞에(들여쓰기 없이) 새로 적어라.** 예시 주석에서 `#` 만 지우면 들여쓰기가 남아
> YAML이 깨지고, openspec은 **경고만 내고 그 파일을 통째로 무시한다**(종료코드는 0이라 눈치채기 어렵다).
> 적은 뒤 `openspec context` 를 돌려 `Warning` 이 없는지 확인해라.

```yaml
context: |
  Tech stack: <언어/프레임워크>
  테스트: <실제 명령>
  빌드: <실제 명령>
  관례: <있으면>
```

**여기가 프로젝트 사정이 모든 에이전트에게 전달되는 유일한 통로다.**
에이전트 파일을 고치는 것보다 이게 낫다. 비워 두면 빈 프로젝트에서 analyzer가 스택을 발명한다.

## 쓰는 법

```
로그인에 2단계 인증 추가해줘
```

그냥 평소처럼 말하면 된다. 오케스트레이터가 크기를 재고 알맞은 경로로 보낸다.
직접 파이프라인을 부르고 싶으면 `/orchestra` 를 쓴다.

사용자가 **반드시** 답해야 하는 지점은 세 곳이고, 상황에 따라 더 묻는다
(진행 중 change가 2개 이상일 때, 에이전트가 질문을 올렸을 때, 두 번 고쳐도 안 될 때,
중간에 취소할 때, 그리고 analyzer를 부르면 방안 선택도 물어야 한다).

1. 요구사항 정리 후 — **범위 밖** 확인 ("그것도 해줘" 할 기회. 여기서 "방안을 비교해 보고
   고르시겠어요? 아니면 바로 설계로 갈까요?"도 함께 물어본다)
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
| 새 기능·리팩터링·원인이 뻔한 버그 | 기본 경로: `preparer → designer → worker → reviewer + regression-verifier → finalizer` | 6번 | 3 |
| "이거 왜 이래?" 조사 | analyzer 1번 | 1번 | 0 |

`원인이 뻔한 버그`는 더 이상 예외 경로가 아니다 — 기본 경로 자체가 analyzer 없이 도는
경로가 됐으므로, "새 기능·리팩터링"과 같은 줄이다. 방안 비교가 필요해지면 그 자리에서
`"방안 뽑아줘"`라고 말해 analyzer를 끼워 넣으면 7번 호출, 묻는 횟수 4가 된다.

## 7개 서브에이전트

| 에이전트 | 하는 일 | 모델 |
|---|---|---|
| `preparer` | 요구사항 정리, 작업 브랜치 + OpenSpec change 생성, proposal 작성 | sonnet |
| `analyzer` | 코드베이스 분석, **방안 최소 3가지 + 의견과 근거** (부를 때만 돈다) | opus |
| `designer` | 결정 기록(decision.md), specs 델타, design.md, tasks.md | opus |
| `worker` | 구현, 파일 수정, 테스트 (코드를 만지는 유일한 에이전트) | sonnet |
| `reviewer` | 요구사항 충족·설계 준수·작업 완료 검증 (읽기 전용) | opus |
| `regression-verifier` | 기존 동작이 깨졌는지 (읽기 전용, reviewer와 병렬) | sonnet |
| `finalizer` | 메인 spec 갱신(sync) → 커밋 | sonnet |

모델은 각 에이전트 파일의 `model:` 한 줄로 바꿀 수 있고, `agent-model-tier` 스킬을 쓰면
7개를 한 번에 갈 수 있다.

## 만들어지는 파일

한 번의 작업이 `openspec/changes/<change-이름>/` 에 이런 기록을 남긴다.

| 파일 | 누가 씀 | 무엇 |
|---|---|---|
| `proposal.md` | preparer | 무엇을 / 왜 + 받아들일 조건 |
| `analysis.md` | analyzer | 분석 결과와 방안 3가지 (스키마 밖 파일) |
| `decision.md` | designer | **사용자가 고른 안** (리뷰의 기준) |
| `specs/<capability>/spec.md` | designer | 요구사항 변화분(델타) |
| `design.md` | designer | 어떻게 (조건부) |
| `tasks.md` | designer | 작업 목록 |
| `review.md` | reviewer | 판정 (finalizer가 읽어 확인) |
| `.openspec.yaml` | `openspec new change` 가 만들고, preparer / designer 가 마커만 덧붙임 | spec 없는 change 표시(`skip_specs`) · capability 은퇴 표시(`retire_capabilities`) |

작업이 끝나면 `finalizer`가 델타를 `openspec/specs/` 의 메인 spec에 병합한다.
그게 이 프로젝트의 **누적된 사양**이 된다.

## 커스터마이즈

- **모델 바꾸기** — `agent-model-tier` 스킬로 `normal` / `semi-lower` / `lower` 세 등급을
  한 번에 갈 수 있다. 손으로 에이전트 파일 하나씩 `model:` 줄을 고쳐도 된다.
- **단계 늘리기** — `.claude/agents/` 에 파일 하나 추가하고 `orchestra` 스킬의 파이프라인에 배선
- **프로젝트 규칙 주입** — `openspec/config.yaml` 의 `context:` 와 `rules:`.
  거기 적은 내용이 모든 산출물 작성에 제약으로 들어간다. 에이전트 파일을 고치는 것보다 이게 낫다
- **스킬 추가** — 쓰면서 필요한 걸 `.claude/skills/` 에 늘려간다. 이 구조는 그걸 전제로 만들었다

## 알아 둘 것

- **`openspec/` 을 `.claude/` 밑으로 옮기지 마라.** OpenSpec은 현재 위치에서 **위로** 올라가며
  `openspec/` 을 찾는다. `.claude/openspec/` 에 두면 저장소 루트에서 `no_openspec_root` 가 나고
  모든 에이전트의 첫 명령이 실패한다.
- **서브에이전트는 사용자에게 직접 물을 수 없다.** 질문은 보고서에 담겨 오케스트레이터를 거친다.
  그래서 범위 밖 확인·방안 선택 같은 관문이 메인 세션에 있다.
- **서브에이전트에게는 `Skill` 도구가 없을 수 있다.** 그래서 에이전트들은 OpenSpec 스킬을
  "부르는" 대신 `.claude/skills/<이름>/SKILL.md` 를 읽고 그 절차를 따르도록 되어 있다.
  결과는 같다. 그래서 `openspec init` 으로 그 문서들을 깔아 두는 게 중요하다.
- **되돌릴 수 없는 일은 에이전트가 하지 않는다.** `git push`, `openspec archive`,
  메인 spec 파일 삭제는 사용자가 명시적으로 요청해야 한다.
- **기본 경로 한 번은 서브에이전트 6번 호출이다** (designer·reviewer가 opus). analyzer를
  부르면 7번이 된다(그때는 analyzer도 opus). 느리고 토큰을 많이 쓴다. 오타 수정에는 자동으로
  경량 경로가 쓰인다. 비용이 부담되면 `agent-model-tier` 스킬로 등급을 내리거나, 해당
  파일들의 `model:` 을 손으로 내려라.
- **대화형 세션에서만 제대로 돈다.** 범위 밖 확인, 커밋 직전 확인 같은 필수 질문이 대화형
  질문이라 `claude -p` 같은 비대화형 실행에서는 그 관문들이 뜨지 않는다.
- **기존 코드가 있는 프로젝트는 처음에 spec이 0개다. 그게 맞다.** change를 하나씩 돌리면서
  건드리는 부분만 spec으로 쌓인다. 코드베이스 전체를 미리 문서화하지 않아도 된다.
- `openspec init` 이 `/opsx:propose` 같은 명령 6개도 깔아 준다.
  **그걸 직접 쓰면 결정 기록(decision.md)과 리뷰 단계가 사라진다.** analyzer를 부른 경우라면
  방안 선택 관문까지 함께 건너뛰게 된다. 평소엔 그냥 말로 시켜라.
- 에이전트 파일과 이 문서는 **한국어**다. 파이프라인도 한국어로 말한다.
  다른 언어로 쓰려면 `.claude/agents/*.md` 와 `.claude/skills/orchestra/SKILL.md` 를 번역하고,
  산출물 언어는 `openspec init --language <언어>` 로 정한다.
- OpenSpec CLI 1.12 기준으로 만들었다. 버전이 올라 명령이 바뀌면, 에이전트는
  `.claude/skills/openspec-*/SKILL.md` (openspec이 직접 깔아준 문서)를 정답으로 삼도록
  되어 있어서 대부분 자동으로 따라간다.
- **이 저장소의 `.claude/skills/openspec-*` 은 `openspec init`이 만든 사본이다.**
  대상 프로젝트에서는 복사하지 말고 `openspec init --tools claude`로 직접 만들어라
  (위 "방법 2 — 손으로" 참고). 그래야 설치된 CLI 버전과 맞는 문서가 깔린다.
  CLI를 올린 뒤에는 `openspec update`로 그 문서들을 갱신해라.
- **버전 확인:**
  ```bash
  openspec --version
  grep generatedBy .claude/skills/openspec-propose/SKILL.md
  ```
  둘이 다르면 에이전트 파일에 적힌 CLI 세부(산출물 의존 관계, 에러 문구, JSON 키)가 틀릴 수 있다.
  그때 정답은 **`openspec status --change <이름> --json` 의 실제 출력**이다.
  에이전트 파일도 전부 "경로와 상태는 CLI에서 얻는다. 짐작하거나 하드코딩하지 마라"고 말한다.
