## Context

`.claude/skills/openspec-*` 6개(SKILL.md)와 `.claude/commands/opsx/` 6개(*.md) — 합쳐 12개
파일, 2,334줄 — 은 `openspec init --tools claude`가 매번 CLI 버전에 맞춰 다시 만들어 주는
스캐폴드다. 지금은 이 12개가 git에 커밋돼 있어서, 저장소에 특정 버전 스냅샷이 고정되고
`README.md:85`의 경고("복사하지 마라")도 실제로는 저장소에 파일이 버젓이 있는데 복사하지
말라는 모순된 문구가 됐다. 자세한 동기는 proposal.md의 "Why"를 본다.

designer가 이번에 다시 확인한 사실 (preparer의 실측을 재확인):
- 추적 중인 12개 파일 = 정확히 `.claude/skills/openspec-{apply-change,archive-change,explore,
  propose,sync-specs,update-change}/SKILL.md` 6개 + `.claude/commands/opsx/{apply,archive,
  explore,propose,sync,update}.md` 6개, 총 2,334줄. (`git ls-files` + `wc -l`로 확인)
- `.claude/skills/` 안에는 이 6개 외에 `orchestra`, `agent-model-tier`, `init-sdd` 3개가
  더 있는데 전부 `openspec-`로 시작하지 않는다. `.claude/commands/`에는 `opsx/` 하나뿐이다.
  → 아래 gitignore 패턴이 이 3개나 다른 어떤 것도 잘못 잡지 않는다.
- README.md에서 "복사하지 마라" 류 경고는 **두 군데**다 (preparer는 1곳이라 했지만
  grep으로 재확인하니 2곳이다):
  - **85번째 줄** (proposal이 고치라고 지목한 곳): "이 저장소에 들어 있는 건 1.12.0
    스냅샷일 뿐이다"라고 버전을 못박아 말하는데, 이번 변경 후에는 이 저장소가 어떤 버전도
    갖고 있지 않게(=git에 커밋된 버전이 없게) 되므로 문장 자체가 낡는다. **이 문서에서
    새 문구를 정한다 (아래 결정 참고).**
  - **267~269번째 줄**: "이 저장소의 `.claude/skills/openspec-*`은 `openspec init`이 만든
    사본이다. 대상 프로젝트에서는 복사하지 말고 `openspec init --tools claude`로 직접
    만들어라." — 이 문장은 이번 변경 후에도 **그대로 참**이다(디스크의 파일은 여전히
    로컬 `openspec init`이 만든 사본이고, 여전히 복사하면 안 된다). 고칠 필요 없음.
    tasks에는 "고치지 않아도 되는지 확인하는" 검증 작업만 넣는다.
  - `docs/example-run.md`, `docs/verification-2026-09-08.md`, `docs/final-report.md`에도
    "1.12.0"이 나오지만 전부 과거 실행 기록/검증 보고서의 사실 기록이지 "복사하지 마라"
    경고가 아니다. 손대지 않는다.
- `install.sh`는 이 12개 파일을 `cp`로 복사하지 않는다. 2단계에서 `openspec init --tools
  claude --no-animation`을 실행해 대상 프로젝트에 새로 만들게 한다(코드로 확인). 3단계
  `copy_if_absent`가 복사하는 건 agents 8개 + `orchestra` + `agent-model-tier` +
  `settings.json`뿐이다. → 12개 파일을 gitignore해도 install.sh의 동작은 바뀌지 않는다.
  (5단계 설치 확인부에서 `.claude/skills/openspec-$sk/SKILL.md` 존재 여부를 보는데, 이건
  `openspec init`이 DST에 직접 만든 파일을 보는 것이지 SRC를 안 본다.)
- `CLAUDE.md`의 `<!-- init-SDD:begin -->` ~ `<!-- init-SDD:end -->` 마커는 각각 한 번씩만
  나온다(중복 없음, 이미 해결된 상태를 재확인만 함).
- `.gitignore`는 현재 "Claude Code 개인 설정"과 "OS/편집기" 두 구획뿐이고, 이번 12개
  경로에 대한 패턴은 없다.

## Goals / Non-Goals

**Goals:**
- 12개 파일을 git 추적에서만 빼고(`git rm --cached`), 디스크 파일은 그대로 둔다.
- `.gitignore`로 다시 추적되거나 `??`로 걸리는 일이 없게 한다.
- README의 낡은 경고 문구를 현실과 맞게 고친다.
- 이 정리 작업 자체가 다른 change나 스킬을 실수로 건드리지 않는다는 것을 검증한다.

**Non-Goals:**
- 요구사항/동작 변경 없음 (proposal이 이미 `skip_specs: true`로 명시).
- `install.sh`, 에이전트 파일, 다른 스킬 문서의 내용을 고치지 않는다.
- README.md 267~269줄, docs/의 "1.12.0" 언급을 고치지 않는다(이미 정확함).

## Decisions

### 1. `.gitignore`에 추가할 패턴과 위치
파일 끝에 새 구획으로 추가한다 (기존 두 구획 형식을 따라 주석 한 줄 + 패턴):

```gitignore

# openspec init 이 CLI 버전에 맞춰 다시 만들어 주는 스캐폴드 (버전 스냅샷을 고정하지 않는다)
.claude/skills/openspec-*/
.claude/commands/opsx/
```

**이유**: `.claude/skills/openspec-*/`는 디렉터리 6개 전부와 그 안의 `SKILL.md`를 함께
잡는다(트레일링 슬래시로 디렉터리 패턴). `.claude/commands/opsx/`도 마찬가지로 디렉터리
전체를 잡는다. 둘 다 파일 앞머리에 `/`가 없지만 `.gitignore`가 저장소 루트에 있고 패턴
중간에 `/`가 있으므로(`.claude/...`) 루트 기준으로 앵커링된다 — 저장소 어디에서든
`.claude/skills/openspec-*`가 아니면 매치되지 않는다 (예: `openspec/changes/**`는
경로가 `.claude/`로 시작하지 않으므로 절대 안 걸린다).

**대안이었지만 안 쓴 것**: 12개 파일을 하나하나 나열하는 패턴. 더 명시적이지만 CLI가
파일을 추가/개명하면(예: 스킬이 하나 늘면) 매번 `.gitignore`를 갱신해야 한다. 디렉터리
패턴은 `openspec update`가 파일을 더 만들어도 그대로 커버한다.

### 2. `git rm --cached`는 명시적 파일 목록으로, 글롭이 아니라 12개를 나열
셸 글롭(`.claude/skills/openspec-*`)이나 `-r` 재귀 삭제로 뭉뚱그리지 않고, 아래처럼
12개 경로를 그대로 나열해서 실행한다 (tasks.md에 그대로 옮긴다):

```bash
git rm --cached \
  .claude/skills/openspec-apply-change/SKILL.md \
  .claude/skills/openspec-archive-change/SKILL.md \
  .claude/skills/openspec-explore/SKILL.md \
  .claude/skills/openspec-propose/SKILL.md \
  .claude/skills/openspec-sync-specs/SKILL.md \
  .claude/skills/openspec-update-change/SKILL.md \
  .claude/commands/opsx/apply.md \
  .claude/commands/opsx/archive.md \
  .claude/commands/opsx/explore.md \
  .claude/commands/opsx/propose.md \
  .claude/commands/opsx/sync.md \
  .claude/commands/opsx/update.md
```

**이유**: `--cached`를 빠뜨리면 작업 트리 파일까지 지워진다 — 이게 가장 위험한 실수라
proposal과 프롬프트가 강조한 부분이다. 파일을 하나하나 적으면 `--cached`를 빠뜨렸을 때도
"뭘 지우려 했는지"가 명령어에 고정돼 있어 사고 범위가 이 12개로 제한된다(글롭이었다면
`openspec-*`에 매칭되는 다른 무언가가 미래에 생겨도 같이 딸려 들어간다).

### 3. README.md:85 새 문구
기존 문구는 "저장소에 1.12.0 스냅샷이 들어 있다"고 단정하는데, 이번 변경 후에는 git이
어떤 버전도 갖고 있지 않다(파일이 커밋되지 않으므로). 하지만 로컬 디스크에는 여전히
파일이 있을 수 있다(이미 `openspec init`을 돌려본 체크아웃이라면). 이 두 가지를 모두
정확히 담아야 한다. 아래 문구로 교체한다 (기존과 같은 인용문 3줄 구조 유지):

```markdown
> **`.claude/skills/openspec-*` 와 `.claude/commands/opsx/` 는 이 저장소에 git으로
> 커밋돼 있지 않다.** `openspec init`이 네 CLI 버전에 맞춰 만들어 주는 파일이라 추적하지
> 않는다(`.gitignore` 참고). 로컬 디스크에는 남아 있을 수 있지만 그건 이 저장소를 마지막에
> `openspec init`한 사람의 CLI 버전에 맞춰진 것일 뿐이다. 그대로 복사하지 말고, 대상
> 프로젝트에서 `openspec init --tools claude`를 직접 돌려서 네 CLI 버전에 맞는 걸 새로
> 만들어라.
```

**버린 대안**: 프롬프트가 예시로 준 "이 저장소에는 없다"는 문구는 그대로 쓰지 않는다.
디스크에는 실제로 파일이 있어서(디렉터리 자체가 사라지는 게 아니라 git 추적만 빠짐)
"없다"라고 하면 파이프라인 에이전트가 그 파일을 읽고 있다는 사실(proposal Impact 3번째
줄)과 모순돼 보인다. "git으로 커밋돼 있지 않다"가 더 정확하다.

### 4. 실행 순서: `git rm --cached` 먼저, `.gitignore` 추가는 그다음
순서를 바꿔도 최종 상태는 같지만(추적 중인 파일은 gitignore 패턴만으로는 안 빠진다),
`git rm --cached`를 먼저 하면 각 단계 직후 `git status`로 중간 상태를 확인하기 쉽다
(1단계 후: 12개가 `D`로 보임 → 2단계 후: `D` 표시가 사라지고 `git status -s`가 깨끗함).

## Risks / Trade-offs

- **[위험] gitignore 패턴이 의도치 않게 다른 걸 잡는다** → 이미 확인함: `.claude/skills/`
  안에 `openspec-`로 시작하는 건 이 6개뿐이고, `.claude/commands/` 안엔 `opsx/` 하나뿐이다.
  worker는 패턴 추가 후 `git status --ignored`로 정확히 12개 경로(디렉터리 6개 +
  `opsx/` 디렉터리 1개, 안에 파일 6개)만 나오는지 재확인한다.
- **[위험] `--cached`를 빠뜨려 디스크 파일이 삭제된다** → tasks.md 첫 작업에 굵게 경고를
  적고, 실행 직후 `ls`로 디스크 파일 존재를 확인하는 작업을 바로 뒤에 붙인다. 만약
  실수로 지워졌다면 아직 커밋 전이므로 `git checkout HEAD -- <path>`로 복구 가능
  (worker가 참고할 수 있게 tasks.md에 복구 명령을 남겨 둔다).
- **[위험] `openspec validate --all --strict`가 이번 변경과 무관한 이유로 실패해 있을 수
  있다** → tasks 첫머리에서 변경 전 기준선으로 한 번 돌려 현재도 통과하는지 확인하고,
  README/gitignore 작업 후 다시 돌려 상태가 그대로인지 비교한다(회귀 여부 판단 기준).
- **[트레이드오프] 이 change의 산출물(`openspec/changes/stop-tracking-openspec-cli-
  scaffolds/`)은 gitignore 패턴 경로(`.claude/...`) 밖이라 영향 없음** — 그래도 tasks에
  `git status`로 change 산출물이 여전히 `??`(추적 안 된 새 파일, 정상)로 보이는지 확인하는
  항목을 넣는다. finalizer가 나중에 커밋할 대상이 이 change 산출물이기 때문이다.

## Migration Plan

롤백 전략: 이 change는 아직 커밋 전이므로, 뭔가 잘못되면 `git status`로 스테이지된 것이
없는지 확인한 뒤 `git rm --cached`로 인한 인덱스 변화는 `git reset` 계열 없이도
`git add <path>`로 다시 추적시킬 수 있다(디스크 파일이 살아있는 한 언제든 되돌릴 수 있음).
`.gitignore`/`README.md` 수정은 일반 텍스트 되돌리기(Edit로 원래 문구 복원)로 충분하다.
finalizer가 커밋하기 전까지는 전부 워킹 트리 상태라 위험이 낮다.
