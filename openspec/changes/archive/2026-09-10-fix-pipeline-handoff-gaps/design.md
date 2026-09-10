## Context

동기와 8건의 목록은 proposal.md의 "Why" / "What Changes"에 있다. 여기서는 되풀이하지 않는다.
설계에 실제로 영향을 주는 현재 상태만 적는다.

- **손댈 대상은 8개 파일, 전부 사람이 읽는 마크다운·YAML 문구다.** (2026-09-09에 7 → 8) 실행 코드가 없어서
  "동작으로 확인"할 방법이 없다. 검증은 grep 대조 + OpenSpec CLI 실측 + 마크다운 무결성뿐이다.
- **F2의 블록인용은 원래 다섯 파일에 글자 그대로 같은 문구로 들어 있었다**
  (`preparer.md`, `designer.md`, `worker.md`, `finalizer.md`, `analyzer.md`).
  그래서 한 벌을 정해 다섯 곳에 똑같이 넣을 수 있다. 이 동일성은 우연이 아니라 유지해야 할 성질이다.
- **2026-09-09 현재 상태(실측): 네 곳만 새 문구로 바뀌었고 `analyzer.md` 하나가 옛 문구로 남았다.**
  바뀐 네 곳(`preparer.md:31-36`, `designer.md:50-55`, `worker.md:32-37`, `finalizer.md:64-69`)은
  6줄 블록의 md5가 모두 `7111c996def6a259f004dd92f1ee1dec`로 같다.
  `analyzer.md:31-34`만 옛 4줄이고, 거기 적힌 "`Skill` 도구가 없을 수 있다 (실측으로 확인됨)"는
  **사실이 아니다** — 다섯 에이전트 전부 frontmatter `tools:` 줄에 `Skill`이 있다.
- **`openspec/config.yaml`의 `context:` 자리에는 예시 주석이 `#   context: |` 형태로 들어 있다**(실측).
  `#`만 지우면 `   context: |`(3칸 들여쓰기)가 되어 값이 통째로 무시된다. 새 줄을 0칸에서 쓴다.
- **다른 change(`remove-analyzer-eval-mode`)는 끝났다** (32/32, 커밋 `6946374`). 트리 충돌
  위험이 사라졌고, 그래서 `.claude/agents/analyzer.md`가 이번 범위에 들어왔다.
  `.claude/skills/orchestra/SKILL.md`와 `docs/example-run.md`는 여전히 **건드리면 안 된다.**
- **현재 기준선**(변경 전 실측, 회귀 대조용):
  - `grep -c 'ORCA_RICH_MD'` — 8개 대상 파일 모두 `0`
  - 코드펜스(`^``` `) 개수 — preparer 16 / designer 10 / worker 6 / reviewer 8 /
    regression-verifier 6 / finalizer 10 / analyzer 4. **전부 짝수.**
    (`analyzer 4`는 2026-09-09 범위 추가 때 잰 값이다. 그 파일은 아직 이번 change로 안 바뀌었다.)
  - `openspec instructions proposal --json` 응답에 `context` 키 **없음** (이번에 생겨야 한다)

## Goals / Non-Goals

**Goals:**

- 요구사항 8건을 각각 정해진 한 파일 안에서 끝내서, **한 파일 = 한 작업 묶음**이 되게 한다
  (F2만 예외적으로 5개 파일에 같은 문구가 들어간다).
- 모든 수정을 **`Edit` 부분 수정**으로만 한다. 문서 전체 구조는 손대지 않는다.
- 각 요구사항마다 **grep 한 줄로 확인 가능한 증거**를 남긴다. 실행 코드가 없어서 이게 유일한 검증이다.

**Non-Goals:**

- 지시문의 **문체·구조 정리**는 하지 않는다. 이번에 고치는 문장만 고친다.
- 8개 파일의 다른 결함을 발견해도 이번 change에서 고치지 않는다. 보고만 한다.
- **`.claude/skills/orchestra/SKILL.md`, `docs/example-run.md`는 읽지도 고치지도 않는다.**
  `remove-analyzer-eval-mode` 소관이고 이번 8건과 관계없다. 열어 보고 "고쳐야겠다"는
  판단조차 하지 마라.
  (`.claude/agents/analyzer.md`는 2026-09-09에 **범위 안으로 들어왔다** — D2 참고.
  그 change가 끝나 충돌이 사라졌다.)
- `.claude/settings.json`의 권한 확대, `README.md` 갱신, 오케스트레이터(orchestra/SKILL.md) 쪽 규칙.

## Decisions

### D1. 파일별로 묶는다 (요구사항별이 아니라)

`designer.md`는 요구사항 두 건(L5-designer, L9)을, `reviewer.md`도 두 건(L4, L5-reviewer)을 받는다.
요구사항 단위로 작업을 쪼개면 같은 파일을 두 worker가 동시에 열어 충돌한다.
→ **한 파일에 대한 모든 수정을 한 작업 묶음으로 만든다.** 묶음끼리는 파일이 겹치지 않으므로
병렬 worker에게 묶음 단위로 나눠 줄 수 있다.

*대안(요구사항 단위 묶음)을 버린 이유:* 병렬 실행 시 편집 충돌 위험이 실제로 있고,
이 change의 핵심 위험은 "문서가 망가지는 것"이라 충돌을 감수할 이유가 없다.

### D2. F2 표준 문구는 한 벌을 정해 **다섯 곳**에 **글자 그대로** 넣는다

아래가 확정 문구다. 다섯 파일(`preparer.md`, `designer.md`, `worker.md`, `finalizer.md`,
`analyzer.md`)의 기존 4줄 블록인용을 이것으로 통째로 바꾼다.
바꿀 때 앞뒤 빈 줄과 들여쓰기는 원래대로 둔다.

**앞의 네 파일은 이미 바뀌어 있다** (6줄 블록 md5 `7111c996def6a259f004dd92f1ee1dec`).
남은 건 `analyzer.md` 하나다 (2026-09-09 범위 추가). **글자 단위로 같아야 하므로 새로
타이핑하지 말고, 이미 바뀐 파일에서 그 6줄을 그대로 떠다 붙인다.** 다 넣은 뒤 다섯 파일의
md5가 모두 위 값과 같은지 대조한다 — 이게 "다섯 곳이 같다"의 유일한 증거다.

```
> **읽어서 따르는 것이 기본이다.** openspec 스킬은 **부르지 말고**
> **`.claude/skills/<스킬이름>/SKILL.md` 를 Read로 읽고 그 절차를 그대로 따른다.**
> 이유: 6개 openspec 스킬은 frontmatter에 `allowed-tools: Bash(openspec:*)` 를 선언한다.
> 스킬을 실제로 호출하면 그 스킬이 도는 동안 **쓸 수 있는 도구가 `openspec` 셸 명령 하나로 좁혀져서**
> 산출물 파일도 못 쓰고 코드도 못 고친다. 읽어서 따르면 결과는 같고 도구 제약이 없다.
> **스킬을 못 부른다는 이유로 절대 멈추지 마라.**
```

바뀐 점: 거짓 근거("`Skill` 도구가 없을 수 있다", "실측으로 확인됨", "실제로 있으면 불러도 된다")를
빼고 진짜 근거(`allowed-tools` 제약)를 넣었다. **결론 문장은 글자 그대로 유지된다.**

*왜 "불러도 된다"까지 지우나:* `allowed-tools` 제약이 근거라면 부르는 게 실제로 손해다.
"불러도 된다"를 남기면 근거와 결론이 어긋난다.

*대안(파일마다 조금씩 다른 문구)을 버린 이유:* 다섯 곳이 동일해야 한 번에 대조할 수 있다.
달라지면 다음에 한 곳만 고쳐지는 어긋남이 생긴다 — **`analyzer.md`에서 실제로 그 일이 났다.**
그래서 검증을 눈대중이 아니라 **md5 대조**로 못박는다.

### D3. F1은 정책을 건드리지 않고 **근거 블록만** 교체한다

`finalizer.md:210-215`의 "이유:" 목록 3항목을 2항목으로 바꾼다. 그 아래
"→ **`openspec-archive-change` 절차 한 길로만 간다.** ..." 이후 문단과 조사용 `bash` 블록은
**그대로 둔다.** 근거 순서는 되돌릴 수 없음 → stdin 순이다 (진짜 이유를 앞세운다).

*틀린 근거를 "실측과 다름" 주석으로 남기는 대안을 버린 이유:* 지시문은 읽고 바로 따르는 문서다.
반박이 붙은 근거를 남기면 다음 사람이 반박을 놓치고 그걸 근거로 쓴다. 지운다.

**2026-09-09**: `proposal.md`의 받아들일 조건 7번이 여기와 어긋나 있었다 — 두 근거를
"교정 문구로 고쳐 놓기"를 요구했다. 바로 위에서 기각한 대안이다. **조건 7을 이 결정에 맞춰
"삭제되어 있다"로 고쳤다.** spec 델타(`finalizer-archive-rationale-accuracy`)는 처음부터
"제거되어야 한다"로 적혀 있어서 손대지 않았다. 어긋난 건 proposal 한 곳뿐이었다.

### D4. `config.yaml`의 `context:`는 예시 주석을 고치지 않고 **새 줄을 0칸에서 추가**한다

확정 내용:

```
context: |
  이 저장소는 실행 코드가 없는 "지시문 저장소"다. SDD 파이프라인의 서브에이전트 지시문
  (.claude/agents/*.md), 스킬 문서(.claude/skills/**/SKILL.md), 설치 스크립트(install.sh),
  문서(docs/, README.md)로만 이뤄져 있다. 빌드 산출물도 런타임도 없다.

  테스트 스위트·빌드·CI가 없다. 검증은 다음 네 가지로만 한다:
  - bash -n install.sh (문법 검사), bash install.sh --dry-run
  - OpenSpec CLI 실측 (openspec validate --strict / status / instructions / context).
    출력만 보지 말고 종료코드로 판정한다.
  - grep 대조 (문구가 실제로 들어갔는지, 여러 파일에 같은 문구가 유지되는지)
  - 마크다운 무결성 눈검사 (frontmatter 온전, 코드펜스 개수 짝수)

  문서는 전부 한국어로 쓴다. 어려운 용어를 피하고 누구나 이해할 수 있는 쉬운 말을 쓴다.

  .claude/agents/*.md 와 .claude/skills/**/SKILL.md 는 Edit 부분 수정만 한다.
  전체 Write 재작성과 sed -i 는 금지다 (전체 재작성으로 마크다운이 망가진 사고가 있었다).
```

- **`context:` 는 줄 맨 앞(0칸).** 블록 스칼라 내용은 2칸 들여쓴다. 빈 줄은 그대로 둬도 된다.
- 넣을 자리: 기존 "# Project context (optional)" 예시 주석 블록 **바로 다음**,
  "# Per-artifact rules (optional)" 주석 앞. 예시 주석은 그대로 둔다 (다음 사람이 형식을 참고한다).
- 내용 안에 콜론(`:`)이 여럿 있지만 블록 스칼라 안이라 안전하다. 따옴표를 붙이지 마라.

### D5. 검증은 "문구가 들어갔나"(grep)와 "구조가 안 망가졌나"(무결성)를 **따로** 본다

문서 change라 회귀는 두 가지 모습으로만 온다: ① 넣어야 할 문구가 안 들어감 ② 편집하다 문서가 깨짐.
②는 grep으로 안 잡힌다. 그래서 무결성 검사를 별도 작업으로 둔다:
frontmatter 5줄(`---`, `name:`, `description:`, `model:`, `tools:`) 온전 /
코드펜스 개수 짝수 (기준선과 동일해야 한다) / `grep -c 'ORCA_RICH_MD'` 가 0.

`ORCA_RICH_MD`는 이 저장소 파일에 절대 들어가면 안 되는 편집 도구 흔적이다. 기준선이 전부 0이므로
0이 아니면 곧바로 사고다.

### D6. F3 검증은 두 명령을 **둘 다** 돌린다. `openspec context` 하나로는 부족하다

`context:` 키가 들여쓰기되면 `Warning: could not parse ... ignoring it.`이 나오는데
**종료코드는 0이다**(실측). 종료코드만 보면 통과처럼 보인다.
→ ① `openspec context` 출력에 `Warning`이 없는지 (문자열 검사)
   ② `openspec instructions proposal --change "fix-pipeline-handoff-gaps" --json` 응답에
      `context` 키가 실제로 생기는지. **②가 진짜 증거다.** ①만 통과하고 ②가 실패할 수 있다.

## Risks / Trade-offs

- **[전체 재작성으로 문서가 망가진다]** → 이번 세션에 실제로 일어났다.
  8개 파일 전부에 대해 `Write`와 `sed -i`를 **금지**하고 `Edit` 부분 수정만 쓴다. 작업 목록에 박아 뒀다.
  사후 확인으로 코드펜스 개수와 frontmatter 무결성을 기준선과 대조한다.
- **[다른 change와 같은 트리에서 충돌]** → `remove-analyzer-eval-mode`가 끝나(커밋 `6946374`)
  충돌 위험은 사라졌다. 남은 금지 파일은 `orchestra/SKILL.md`와 `docs/example-run.md` 둘이고,
  작업 목록의 마지막 검증에서 `git status --short`로 그 둘이 바뀌지 않았는지 확인한다.
- **[F2 다섯 곳 중 일부만 바뀐다]** → 다섯 곳을 한 작업 묶음이 아니라 각 파일 묶음에 나눠 넣기
  때문에 일부만 반영될 수 있다. **이번에 실제로 일어났다** — 네 곳만 바뀌고 `analyzer.md`가 남았다.
  검증 작업에서 다섯 파일의 해당 6줄 블록 **md5를 대조**한다. `grep -c` 개수 세기만으로는
  "문구가 조금 다른" 경우를 못 잡는다.
- **[YAML을 고치다 config.yaml 전체가 깨진다]** → `openspec context`와
  `openspec instructions ... --json`이 곧바로 실패하므로 즉시 드러난다.
  또한 `config.yaml`이 깨지면 이 저장소의 모든 openspec 명령이 영향을 받으니 이 작업을 마지막에 둔다.
- **[내가 나 자신(`designer.md`)의 지시문을 고친다]** → 이번 change의 worker가 `designer.md`를
  고친다. 편집 시점에는 이미 설계가 끝나 있으므로 이번 사이클에는 영향이 없고, 다음 사이클부터 적용된다.
  대신 **문서를 고치면서 자기 판단으로 다른 문장까지 다듬지 않도록** 작업 목록에 범위를 못박았다.
- **[받아들일 조건 2개가 spec으로 안 옮겨감]** → "8개 파일 모두 Edit 부분 수정" 과
  "`bash -n install.sh` 통과"는 시스템 동작 계약이 아니라 작업 절차·회귀 검증 항목이다.
  spec에 넣지 않고 작업 목록의 검증 작업으로 넣었다. reviewer가 놓치지 않도록
  proposal의 받아들일 조건에 그대로 남아 있다.

## Migration Plan

없다. 실행 코드도 저장 데이터도 없다. 되돌리려면 `git checkout -- <파일>` 하나면 된다.
다만 커밋 전이므로 **worker는 되돌리기 명령을 스스로 돌리지 않는다.**
