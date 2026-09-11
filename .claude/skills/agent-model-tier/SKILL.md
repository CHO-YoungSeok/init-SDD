---
name: agent-model-tier
description: 서브에이전트 7개(preparer, analyzer, designer, worker, reviewer, regression-verifier, finalizer)의 모델 등급을 한 번에 갈아 준다. "모델 낮춰", "토큰 아껴", "semi-lower로", "lower로", "normal로 되돌려", "지금 모델 등급 뭐야" 같은 말에 쓴다.
---

# 에이전트 모델 등급 (agent-model-tier)

서브에이전트 7개가 어느 모델로 도는지를 등급 하나로 한 번에 바꾸는 스킬이다. 토큰을
아끼려고 등급을 내릴 수 있고, 언제든 원래 등급(`normal`)으로 되돌아올 수 있다.

바꾸는 파일은 `.claude/agents/` 안의 이 7개다:

```
.claude/agents/preparer.md
.claude/agents/analyzer.md
.claude/agents/designer.md
.claude/agents/worker.md
.claude/agents/reviewer.md
.claude/agents/regression-verifier.md
.claude/agents/finalizer.md
```

각 파일 맨 위 frontmatter(`---` 로 둘러싸인 부분)의 `model:` 줄 하나를 바꾼다. 이 줄은
파일마다 정확히 하나씩만 있다.

## 등급 표

세 등급이 있다. 값은 **이 표에 그대로 박혀 있다** — 지금 값을 읽어서 기억하는 방식이
아니다. 이미 등급을 내려 둔 상태에서 이 스킬을 처음 쓰더라도, `normal` 열의 값이 표 안에
있으므로 언제든 원래대로 돌아갈 수 있다.

| 에이전트 | normal (원래 값) | semi-lower | lower |
|---|---|---|---|
| preparer | sonnet | haiku | haiku |
| analyzer | opus | sonnet | haiku |
| designer | opus | sonnet | haiku |
| worker | sonnet | haiku | haiku |
| reviewer | opus | sonnet | haiku |
| regression-verifier | sonnet | haiku | haiku |
| finalizer | sonnet | haiku | haiku |

**규칙은 기계적이다 — 한 단계씩 내린다.**

```
opus   → sonnet
sonnet → haiku
```

`semi-lower`는 특정 역할(예: 리뷰 담당)을 특별 취급하지 않는다. `normal`에서 opus였던
셋(analyzer·designer·reviewer)이 sonnet으로, sonnet이었던 넷(preparer·worker·
regression-verifier·finalizer)이 haiku로 내려간 것뿐이다. `lower`는 한 단계 더 내린
게 아니라 **7개 전부를 바닥값인 haiku로** 맞춘 것이다.

모델 값은 항상 짧은 이름(`opus` / `sonnet` / `haiku`)만 쓴다. 날짜나 버전이 붙은 전체
모델 ID는 절대 적지 않는다 — 버전이 올라가면 그 값이 낡아서 못 쓰게 된다.

**주의:** `code-explorer` 에이전트는 이 표 밖에 있고, 항상 `haiku`로 고정된다. 이 스킬이
바꾸는 대상이 아니다.

## 지금 등급 확인

등급을 적용하기 전에, 또는 사용자가 "지금 모델 등급 뭐야"라고 물으면 먼저 이 순서로
확인한다.

1. 7개 파일을 하나씩 읽어 `^model:` 로 시작하는 줄의 값을 뽑는다.
   ```bash
   for f in .claude/agents/preparer.md .claude/agents/analyzer.md .claude/agents/designer.md .claude/agents/worker.md .claude/agents/reviewer.md .claude/agents/regression-verifier.md .claude/agents/finalizer.md; do echo "$(basename "$f") $(grep -m1 '^model:' "$f")"; done
   ```
2. 뽑은 7개 값을 위 등급 표의 `normal` / `semi-lower` / `lower` 세 열과 각각 대조한다.
3. **7개 값이 세 표 중 하나와 정확히, 한 칸도 틀리지 않고 같으면** 지금 등급은 그 표의
   이름이다. 그렇게 알린다.
4. **어느 표와도 정확히 안 맞으면 "섞인 상태"로 보고하고 멈춘다.** 가까운 등급을 짐작해서
   답하지 않는다. 대신:
   - 7개 파일의 실제 `model:` 값을 표로 그대로 보여 준다.
   - "지금 등급을 적용하면 이 값들이 사라진다"고 알린다. `normal`은 표에서 언제든
     되돌아오지만, **섞인 상태는 이 표 어디에도 기록되어 있지 않아 한 번 덮어쓰면
     복구할 수 없다.**
   - 사용자에게 이 값 목록을 보여 준 채로, 그래도 등급을 바꿀지 다시 물은 뒤에만
     진행한다.

## 등급 적용

사용자가 고른 등급(`normal` / `semi-lower` / `lower`)이 정해지면:

1. 위 "지금 등급 확인"을 먼저 한다. 이미 그 등급이면 **아무 파일도 건드리지 않고**
   "이미 `<등급>`입니다"라고 알리고 끝낸다.
2. 섞인 상태였다면, 사용자가 그래도 진행하라고 확인한 뒤에만 다음 단계로 간다.
3. 7개 파일 각각에 대해, 등급 표에서 그 파일에 해당하는 값을 찾아 **`model:` 한 줄만**
   Edit(부분 수정)으로 고친다.

   **★ 반드시 `model:` 한 줄만 Edit으로 고친다. 파일 전체를 Write로 다시 쓰거나
   `sed -i` 로 제자리 치환하지 마라.** 이미 값이 같은 파일은 건드리지 않는다.

   이유: 이 규칙은 이 저장소(`openspec/config.yaml`의 `context`)의 규칙이고, 전체
   재작성 방식으로 지침 파일의 들여쓰기가 무너지고 이상한 토큰이 섞여 들어간 사고가
   실제로 있었다. **이 스킬은 대상 프로젝트로 복사되어 나갈 수 있고, 그쪽
   `config.yaml`에는 이 규칙이 안 쓰여 있을 수 있다.** 그래서 이 규칙을 스킬 절차
   안에 직접 적어 둔다 — 이 스킬을 쓰는 쪽이 규칙을 모르면 에이전트 파일 7개를
   망가뜨린다.

## 바꾼 뒤 확인

등급을 다 적용한 뒤 아래 세 가지를 확인하고, 문제가 있으면 그대로 보고한다.

1. **바뀐 줄이 `model:` 줄들뿐인지** — `git diff -- .claude/agents/` 를 보고, 바뀐
   줄이 전부 `model:` 로 시작하는 줄인지 확인한다. 다른 줄이 바뀌었으면 잘못된
   것이다.
2. **frontmatter가 온전한지** — 각 파일이 `---` 두 줄로 열리고 닫히며, `name:`,
   `description:`, `model:`, `tools:` 네 키를 모두 그대로 갖고 있는지 확인한다.
   ```bash
   for f in .claude/agents/preparer.md .claude/agents/analyzer.md .claude/agents/designer.md .claude/agents/worker.md .claude/agents/reviewer.md .claude/agents/regression-verifier.md .claude/agents/finalizer.md; do sed -n '1,/^---$/{/^---$/!p}' "$f" | head -20; echo "--- $f 끝"; done
   ```
3. **`model:` 줄이 파일마다 정확히 하나인지** — 아래 명령의 두 번째 칸이 모든 파일에서
   1이어야 한다.
   ```bash
   for f in .claude/agents/preparer.md .claude/agents/analyzer.md .claude/agents/designer.md .claude/agents/worker.md .claude/agents/reviewer.md .claude/agents/regression-verifier.md .claude/agents/finalizer.md; do echo "$(basename "$f") $(grep -c '^model:' "$f")"; done
   ```

## 낮추면 무엇이 나빠지는가

**`lower`나 `semi-lower`를 적용하기 전에, 아래 경고를 사용자에게 먼저 보여 준다.**
등급을 낮췄을 때 무슨 일이 생기는지 모르고 쓰면, 나중에 문제가 생겨도 원인을 등급에서
찾지 못한다.

이 실패 모드는 **조용하다.** 에러가 나지 않는다. 정해진 동작이 조금씩, 눈에 안 띄게
줄어드는 방식으로 나타난다.

1. **`worker`가 약해지면 "멈출 줄 아는 판단"이 약해진다.** `.claude/skills/orchestra/
   SKILL.md`는 이미 이렇게 적고 있다 — "작업이 10개를 넘거나 여러 모듈에 걸치면
   worker를 opus로 올려라. worker에게 필요한 건 코드 작성이 아니라 멈출 줄 아는
   판단이고, 그게 약하면 정해진 동작을 조용히 줄인다." 등급을 낮춘 채로 worker를
   돌리면 같은 위험이 더 자주 일어난다.
2. **`reviewer`와 `designer`가 약해지면 판정과 설계의 질이 내려간다.** `README.md`가
   "비용이 부담되면 이 셋(analyzer·designer·reviewer)을 sonnet으로 내려라"고 안내하는
   자리가 바로 여기다. `semi-lower`가 정확히 그 안내와 같은 동작이다.
3. **낮춘 등급으로 큰 일(새 기능, 여러 모듈에 걸친 변경)을 돌리지 마라.** 등급을
   낮춘 채로는 작은 수정·반복 작업 정도로만 쓰는 게 안전하다.
4. **되돌리는 방법은 언제나 같다** — 이 스킬로 `normal`을 적용한다. `normal` 표가
   이 파일 안에 값으로 있으므로 몇 번을 오갔든 정확히 원래 값으로 돌아간다.
