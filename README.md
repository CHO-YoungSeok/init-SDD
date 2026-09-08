# init-SDD

**어떤 프로젝트에든 얹어서 바로 시작하는 SDD(사양 주도 개발) 초기 구조.**

`.claude/` 하나만 복사하면, 그 프로젝트의 Claude Code가
"요구사항 정리 → 분석 → **사용자가 방안 선택** → 설계 → 구현 → 리뷰 → 회귀 검증 → 커밋"
순서로 일하게 된다. 각 단계는 전용 서브에이전트가 맡는다.

## 이게 왜 필요한가

Claude Code에게 큰 일을 그냥 맡기면, 분석과 설계와 구현이 한 덩어리로 섞여서
**어떤 방향으로 갈지 사람이 개입할 지점이 없다.** 다 끝난 뒤에야 "이게 아닌데"를 알게 된다.

이 구조는 그 지점을 강제로 만든다. 분석이 끝나면 **방안 3가지를 들고 와서 사람에게 고르게 한다.**
그 선택이 파일로 기록되고, 리뷰 단계에서 "고른 대로 됐는지"를 검사한다.

## 전제 조건

| 필요한 것 | 확인 | 없으면 |
|---|---|---|
| Claude Code | `claude --version` | [설치 안내](https://claude.com/claude-code) |
| OpenSpec CLI | `openspec --version` (1.12 이상) | `npm i -g openspec` 또는 `brew install openspec` |
| git 저장소 | `git status` | `git init` |

## 설치

### 방법 1 — 스크립트 (권장)

```bash
git clone https://github.com/CHO-YoungSeok/init-SDD.git /tmp/init-SDD
cd /path/to/your-project
bash /tmp/init-SDD/install.sh --dry-run   # 무엇을 할지 먼저 본다
bash /tmp/init-SDD/install.sh             # 설치
```

스크립트는 **기존 파일을 절대 덮어쓰지 않는다.** 이미 있으면 건너뛰고 끝에 목록으로 알려준다.
`CLAUDE.md`는 덮어쓰지 않고 **끝에 덧붙인다.** 두 번 실행해도 안전하다.

### 방법 2 — 손으로

```bash
cd /path/to/your-project

# OpenSpec 초기화 (openspec/ 디렉터리와 공식 스킬 6개를 만든다)
openspec init --tools claude

# 에이전트와 지휘 스킬 복사
cp -r /tmp/init-SDD/.claude/agents .claude/
cp -r /tmp/init-SDD/.claude/skills/orchestra .claude/skills/
cp /tmp/init-SDD/.claude/commands/orchestra.md .claude/commands/
```

`.claude/skills/openspec-*` 은 복사하지 마라. `openspec init`이 설치된 CLI 버전에 맞는 것을 만든다.

### CLAUDE.md 는 복사하지 말고 **합쳐라**

대상 프로젝트에 이미 `CLAUDE.md`가 있으면 덮어쓰면 안 된다. 아래 내용을 **끝에 덧붙인다.**
(`install.sh`는 이걸 알아서 해준다)

```markdown
# 작업 방식

이 프로젝트는 SDD(사양 주도 개발) 파이프라인으로 일한다.

메인 세션은 **오케스트레이터**다. 사용자와 대화하고 지휘만 한다.
분석·설계·파일 수정·리뷰·회귀 검증·커밋은 **모두 `.claude/agents/` 의 서브에이전트에게 위임한다.**
지휘 절차는 `orchestra` 스킬을 따른다.
```

### 이름이 겹칠 수 있는 파일

복사 전에 대상 프로젝트에 같은 이름이 있는지 확인해라. 있으면 덮어쓰지 말고 내용을 확인해라.

- `CLAUDE.md` → 위 안내대로 **합친다**
- `.claude/agents/{preparer,analyzer,designer,worker,reviewer,regression-verifier,finalizer}.md`
- `.claude/skills/orchestra/`
- `.claude/commands/orchestra.md`

## 쓰는 법

```
로그인에 2단계 인증 추가해줘
```

그냥 평소처럼 말하면 된다. 오케스트레이터가 크기를 재고 알맞은 경로로 보낸다.
직접 파이프라인을 부르고 싶으면 `/orchestra <할 일>`.

진행 중에 사용자가 답해야 하는 지점은 **네 곳**이다.

1. 요구사항 정리 후 — **범위 밖** 확인 ("그것도 해줘" 할 기회)
2. **★ 방안 선택** — 3가지 안과 각각의 장단점, 추천안을 보고 고른다
3. 조건부 통과가 나왔을 때 — 남은 지적을 지금 고칠지 정한다
4. 커밋 직전 — diff 요약을 보고 확인한다

작은 수정(오타, 주석)은 이 관문을 전부 건너뛰고 바로 처리된다.

## 7개 서브에이전트

| 에이전트 | 하는 일 | 모델 |
|---|---|---|
| `preparer` | 요구사항 정리, 작업 브랜치 + OpenSpec change 생성, proposal 작성 | sonnet |
| `analyzer` | 코드베이스 분석, **방안 최소 3가지 + 의견과 근거** | opus |
| `designer` | 결정 기록(decision.md), specs 델타, design.md, tasks.md | opus |
| `worker` | 구현, 파일 수정, 테스트 (코드를 만지는 유일한 에이전트) | sonnet |
| `reviewer` | 요구사항 충족·설계 준수·작업 완료 검증 (읽기 전용) | opus |
| `regression-verifier` | 기존 동작이 깨졌는지 (읽기 전용, reviewer와 병렬) | sonnet |
| `finalizer` | 메인 spec 갱신(sync) → 커밋 | sonnet |

모델은 각 에이전트 파일의 `model:` 한 줄로 바꿀 수 있다.

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

작업이 끝나면 `finalizer`가 델타를 `openspec/specs/` 의 메인 spec에 병합한다.
그게 이 프로젝트의 **누적된 사양**이 된다.

## 커스터마이즈

- **모델 바꾸기** — 에이전트 파일의 `model:` 한 줄
- **단계 늘리기** — `.claude/agents/` 에 파일 하나 추가하고 `orchestra` 스킬의 파이프라인에 배선
- **프로젝트 규칙 주입** — `openspec/config.yaml` 의 `context:` 와 `rules:`.
  거기 적은 내용이 모든 산출물 작성에 제약으로 들어간다. 에이전트 파일을 고치는 것보다 이게 낫다
- **스킬 추가** — 쓰면서 필요한 걸 `.claude/skills/` 에 늘려간다. 이 구조는 그걸 전제로 만들었다

## 알아 둘 것

- **`openspec/` 을 `.claude/` 밑으로 옮기지 마라.** OpenSpec은 현재 위치에서 **위로** 올라가며
  `openspec/` 을 찾는다. `.claude/openspec/` 에 두면 저장소 루트에서 `no_openspec_root` 가 나고
  모든 에이전트의 첫 명령이 실패한다.
- **서브에이전트는 사용자에게 직접 물을 수 없다.** 질문은 보고서에 담겨 오케스트레이터를 거친다.
  그래서 방안 선택 같은 관문이 메인 세션에 있다.
- **되돌릴 수 없는 일은 에이전트가 하지 않는다.** `git push`, `openspec archive`,
  메인 spec 파일 삭제는 사용자가 명시적으로 요청해야 한다.
- OpenSpec CLI 1.12 기준으로 만들었다. 버전이 올라 명령이 바뀌면, 에이전트는
  `.claude/skills/openspec-*/SKILL.md` (openspec이 직접 깔아준 문서)를 정답으로 삼도록
  되어 있어서 대부분 자동으로 따라간다.
- **이 저장소의 `.claude/skills/openspec-*` 은 `openspec init`이 만든 사본이다.**
  대상 프로젝트에서는 복사하지 말고 `openspec init --tools claude`로 직접 만들어라
  (위 설치 절차 3번). 그래야 설치된 CLI 버전과 맞는 문서가 깔린다.
  CLI를 올린 뒤에는 `openspec update`로 그 문서들을 갱신해라.
