## Context

동기와 원인은 proposal.md의 "Why"에 있다. 여기서는 고친 뒤의 구조만 적는다.

이번 change가 손대는 대상은 실행 코드가 아니라 **에이전트에게 주는 지침 문서**다.
그래서 "설계"는 곧 **어떤 문장과 어떤 명령을 어느 위치에 박을 것인가**의 문제다.

제약 세 가지:

1. **실행 가능한 테스트 스위트가 없다.** 이 저장소에서 쓸 수 있는 검증 수단은
   `bash -n install.sh`와, 임시 디렉터리에 openspec 프로젝트를 만들어 실패 모드를
   직접 재현하는 것뿐이다. 그래서 tasks.md의 검증은 전부 그 두 가지 안에서 짠다.
2. **마커를 쓰는 주체는 preparer와 designer 둘뿐이다.** 나머지 문서
   (`finalizer.md`, `README.md`, `orchestra/SKILL.md`)는 "마커가 있으면 이렇게
   동작한다"는 읽는 쪽 설명이다. 그래서 쓰기 지침은 두 곳에만 박고,
   README는 사실 관계만 맞춘다.
3. **`.claude/agents/` 밑에는 새 파일을 둘 수 없다.** `install.sh:74`가
   `.claude/agents/*.md` 글롭으로 복사하는데, 거기 새 `.md`를 두면 Claude Code가
   그것을 에이전트 정의로 읽는다. 하위 디렉터리는 아예 복사되지 않는다.
   → 공통 문서를 새로 만드는 선택지(3안)가 배포 문제를 끌고 들어오는 이유다.

### 기준선: 실패 모드 매트릭스 (2026-09-09 재측정 확정판)

이 표가 이번 change의 **기준선**이다. 정량(성능·용량) 요구사항이 아니므로 측정 숫자
대신 이 종료코드 표가 "고치기 전 상태"를 나타낸다. 고친 뒤 A~E를 그대로 다시 돌려
E가 전부 0인지, 그리고 A~D가 문서의 게이트에 걸리는지 확인하면 된다.

숫자는 모두 종료코드다 (OpenSpec 1.12.0, 파이프 없이 `$?`로 수집).
**C행은 이 표에 값이 잘못 적혀 있던 자리다** (`status --json`을 0으로 적었다.
analysis.md 32~37행의 원본 표에는 1로 제대로 적혀 있었는데 옮겨 적으며 틀렸고,
아래 "읽는 법"이 그 오기를 따라갔다). worker가 작업 1.2에서 어긋남을 발견했고
제3의 환경에서 독립으로 다시 재서 worker 쪽이 맞다는 것을 확인했다. 아래가 확정판이다.

| # | 행동 | `validate` | `validate --strict` | `status --json` |
|---|---|---|---|---|
| A | `>` 덮어쓰기 → 기존 키 유실 | 1 | 1 | 1 |
| B | `>>` 두 번 실행 → 마커 키 중복 | 1 | 1 | 1 |
| C | 개행 없는 마지막 줄에 `>>` → 줄이 이어 붙음 | 1 | 1 | 1 |
| D | `retire_capabilities`를 덮어쓰기로 설정 | **0** | **0** | 1 |
| E | 가드 붙인 append (아래 관용구) | 0 | 0 | 0 |

**재현 조건 (표를 다시 돌릴 때 반드시 맞춰라):**
- **D행은 델타가 하나라도 있는 change 기준이다.** 델타가 하나도 없는 빈 change에
  `retire_capabilities`를 덮어쓰면 `validate`가 0이 아니라 1이 나온다. 그 1의 원인은
  메타데이터가 아니라 `Change must have at least one delta`다. 이 조건을 안 맞추면
  D행("validate가 통과시킨다")이 재현되지 않는다.
- A·B·C·E는 델타 유무와 무관하게 위 값이 나온다.

읽는 법:
- **C는 `validate` 출력만 보면 정상으로 오독된다.** 종료코드는 1이지만 출력에 YAML
  얘기가 한마디도 없고 `Change must have at least one delta` 하나만 나온다.
  하필 `preparer.md:154`가 바로 그 에러를 *"그건 정상이다"*라고 가르치고 있어서,
  파손이 "아직 델타가 없어서 그런 것"으로 읽힌다. → D5의 근거다.
- **C의 YAML 파손을 실제로 드러내는 것은 `status --change <이름> --json`이다.**
  파일이 `created: 2026-09-09skip_specs: true`가 되어 한 줄에 콜론이 두 개라
  YAML 파싱이 반드시 깨지고, `status`가 exit=1과 함께
  `Invalid YAML in metadata file: Nested mappings are not allowed in compact mappings`를
  출력한다.
- **`status --change <이름> --json`은 A·B·C·D를 전부 잡는다.** 메타데이터 파손을
  거르는 범용 게이트는 이쪽 하나다.
- **`validate --strict`는 D를 못 잡는다** (exit=0). 그래도 델타 자체를 검증하는
  별개의 목적이 있어 확인 절에서 빼지 않는다.
- → **두 게이트를 함께 둔다. 역할이 다르다.** `status`는 메타데이터 파손용,
  `validate --strict`는 델타 검증용이다.

부수적으로 확인된 사실:
- `--goal`을 주면 `.openspec.yaml`에 `goal:` 키가 하나 더 생긴다.
  → 보존 대상을 `schema:` 하나로 적으면 안 된다. "기존 키 전부"로 적어야 한다.
- `retire_capabilities`는 `status`/`show`/`list`의 JSON 어디에도 값이 노출되지 않는다.
  값을 되읽어 확인할 방법이 없다. 종료코드가 유일한 판정 수단이다.

## Goals / Non-Goals

**Goals:**

- 마커를 넣는 두 지침을 **해석 여지가 0인 복붙 명령**으로 바꿔 A~D를 예방한다.
- 두 문서의 확인 절에 `validate` + `status --json` **두 종료코드 게이트**를 넣어,
  예방을 빠져나간 경우에도 다음 단계로 넘어가지 못하게 한다.
- 진단 안내를 특정 에러 문구가 아닌 **파일 확인 절차**로 일반화한다.
- 세 문서(`preparer.md`, `designer.md`, `README.md`)의 `.openspec.yaml` 설명을
  서로 어긋나지 않게 맞춘다.

**Non-Goals:**

- `.claude/settings.json`의 `permissions.allow` 확대 — 사용자가 명시적으로 제외했다.
- 상류 OpenSpec CLI에 마커용 플래그 요청 — 이번 범위 밖.
- 공통 절차 문서를 새로 만들어 두 에이전트가 참조하게 하는 것(3안) — decision.md 참고.
- `finalizer.md`, `orchestra/SKILL.md`의 마커 언급 — 읽는 쪽 설명이라 사실이 안 바뀐다.

## Decisions

### D1. 문서에 박을 관용구는 가드형 append 한 줄이다

preparer.md에 들어갈 형태:

```bash
f="<changeRoot>/.openspec.yaml"
grep -q '^skip_specs:' "$f" || printf '\nskip_specs: true\n' >> "$f"
```

designer.md에 들어갈 형태 (키 이름만 다르고 구조는 같다):

```bash
f="<changeRoot>/.openspec.yaml"
grep -q '^retire_capabilities:' "$f" || printf '\nretire_capabilities: true\n' >> "$f"
```

세 조각이 각각 하나씩 막는다.

| 조각 | 막는 실패 모드 |
|---|---|
| `>>` (덮어쓰기 아님) | A, D — 기존 키 유실 |
| `grep -q ... \|\|` 가드 | B — 재실행 시 키 중복 |
| `printf` 앞의 `\n` | C — 개행 없는 마지막 줄에 이어 붙음 |

파일이 이미 개행으로 끝나 있으면 빈 줄이 하나 생기는데 YAML에서 무해하다
(analyzer 실측: exit=0, `specs` 산출물이 `skipped`가 된다).

**왜 Edit 도구가 아니라 셸 명령인가 (2안 대신):** Edit의 `old_string`은 파일 내용을
읽어야 정해지는데 `created:` 날짜가 매번 다르고 `--goal`이 있으면 마지막 줄이 또
달라진다. 절차가 실제로는 2~3스텝이라 짧지 않고, 그 사이에 해석 여지가 다시 생긴다.
셸 한 줄은 change 이름만 바꿔 그대로 붙여 넣으면 끝난다.

**대가:** 같은 형태가 두 파일에 중복된다. 지금은 쓰는 주체가 둘뿐이라 감수한다.
세 번째 마커가 생기면 3안(공통 문서)으로 갈아타는 것이 맞다 — decision.md에 적어 뒀다.

### D2. 금지는 두 가지를 다 적는다 — `Write` 도구와 셸 `>`

analyzer는 실제 사고 경로가 Write 도구인지 셸 `>`인지 확정하지 못했고,
현재 하니스의 Write는 "읽지 않은 기존 파일 덮어쓰기는 실패한다"이므로
**셸 리다이렉트가 더 그럴듯한 경로**라고 봤다. 한쪽만 금지하면 진짜 구멍이 남는다.
그래서 두 문서 모두에 "이 파일에는 `Write` 도구도 셸 `>`도 쓰지 마라"를 함께 적는다.

### D3. 확인 게이트는 `validate` + `status --json` 두 개다

기준선 표 그대로다. 하나만 두면 안 되는 이유는 **두 명령의 역할이 다르기 때문**이다.

- `status --change "<이름>" --json` → **메타데이터 파손 게이트.** A·B·C·D를 전부
  종료코드 1로 잡는다. 마커 작업의 성패는 이 종료코드로 판정한다.
- `validate` / `validate --strict` → **델타 검증 게이트.** 메타데이터 파손 중 D를
  못 잡으므로(exit=0) 이것만 보면 안 되지만, 델타 자체의 형식과 시나리오 누락은
  이쪽만 잡는다. 그래서 빼지 않는다.

preparer 확인 절에 들어갈 형태:

```bash
openspec validate "<이름>"; echo "validate exit=$?"
openspec status --change "<이름>" --json >/dev/null; echo "metadata exit=$?"
cat "<changeRoot>/.openspec.yaml"
```

designer 검증 절에 들어갈 형태 (기존 `validate --strict` 게이트에 status를 더한다):

```bash
openspec validate "<이름>" --strict; echo "exit=$?"
openspec status --change "<이름>" --json >/dev/null; echo "metadata exit=$?"
```

`>/dev/null`을 붙이는 이유는 JSON 본문이 아니라 **종료코드만** 필요하기 때문이다.
파이프(`| tail` 등)를 붙이면 종료코드가 바뀌므로 붙이지 않는다 — 이 주의는
designer.md에 이미 있고 그대로 살린다.

### D4. 진단은 문구 매칭이 아니라 파일 확인 절차로 적는다

실패 모드마다 에러 문구가 다르고(A: `schema: Invalid input`,
B: `the file is not valid YAML`), C는 **어느 명령을 보느냐에 따라 문구가 있기도 하고
없기도 하다** — `status --json`에는 `Invalid YAML in metadata file: ...`이 나오지만
`validate` 출력에는 원인 문구가 아예 없다. 문구 하나를 힌트로 적으면 나머지를 놓친다.
그래서 확인 절에 `cat`으로 파일을 열어 세 가지를 보라고 적는다.

1. `openspec new change`가 만든 기존 키(`schema:` 등)가 전부 살아 있는가 → A/D
2. 마커 키가 두 번 나오지 않는가 → B
3. 마커가 앞 줄 끝에 이어 붙어 있지 않은가 (`created: ...skip_specs: true`) → C

### D5. preparer.md:154는 조건을 붙여 고친다 (문장을 지우지 않는다)

지금 문장은 *"아직 델타가 없어서 실패할 수 있다(`exit=1`). 그건 정상이다"*이고,
바로 다음 줄(155)이 "마커를 넣었으면 통과한다"로 사실상 반대 얘기를 한다.
두 줄이 같은 exit=1을 서로 다르게 해석하는 상태다.

이 문장이 실제로 위험한 이유는 기준선 표 C행이 보여준다. 실패 모드 C에서
`validate`가 내는 **유일한** 에러가 바로 이 문장이 "정상이다"라고 가르치는 그 에러다.
즉 지금 문구를 그대로 따르면 깨진 메타데이터를 눈앞에 두고 "정상"이라고 판정하게 된다.

문장을 지우는 대신 **조건을 붙인다**: 마커를 설정하지 **않은** 경우에만 정상이고,
`skip_specs`를 넣었는데도 이 에러가 나오면 마커가 반영되지 않은 것이니
`.openspec.yaml`을 확인하라고 이어 붙인다. 154와 155를 한 덩어리로 읽히게 만든다.

### D6. README.md:182는 표 한 줄만 손댄다

지금 줄:

```
| `.openspec.yaml` | preparer / designer | spec 없는 change 표시(`skip_specs`) · capability 은퇴 표시(`retire_capabilities`) |
```

"누가 씀" 칸이 `preparer / designer`라서 **에이전트가 만드는 파일처럼 읽힌다.**
실제로는 `openspec new change`가 만들고 에이전트는 마커만 덧붙인다.
표 구조와 다른 줄은 건드리지 않고, 이 한 줄에서 그 사실이 드러나게만 고친다.

## 손댈 파일과 역할

| 파일 | 위치 | 무엇을 |
|---|---|---|
| `.claude/agents/preparer.md` | 146행 부근 (6단계 `skip_specs` 지침) | D1 관용구 + D2 금지 문구로 교체 |
| `.claude/agents/preparer.md` | 150~156행 (7단계 확인 절) | D3 두 종료코드 게이트 + D4 진단 절차 추가 |
| `.claude/agents/preparer.md` | 154행 | D5 조건 붙이기 |
| `.claude/agents/designer.md` | 158행 부근 (5단계 specs 델타 절) | D1 관용구 + D2 금지 문구로 교체 |
| `.claude/agents/designer.md` | 187~200행 (7단계 검증 절) | D3 status 종료코드 게이트 + D4 진단 절차 추가 |
| `README.md` | 182행 | D6 표 한 줄 |

행 번호는 지금 기준이며, 앞쪽을 고치면 뒤로 밀린다. worker는 행 번호가 아니라
**주변 문구로 위치를 찾아라.**

## 하위 호환

- 산출물 형식, CLI 사용법, `install.sh` 배포 목록 어느 것도 바뀌지 않는다.
  세 파일 모두 이미 배포 대상에 들어 있다 (`.claude/agents/*.md` 글롭, README는
  저장소 문서).
- 이미 만들어진 change의 `.openspec.yaml`은 건드리지 않는다. 이번 수정은
  **앞으로 만들어질 change**에만 영향을 준다.
- 되돌리려면 세 파일의 문서 수정을 되돌리면 된다. 상태나 데이터가 남지 않는다.

## Risks / Trade-offs

- **[중복이 갈라진다]** 같은 관용구가 preparer.md와 designer.md 두 곳에 산다.
  → 완화: 마커를 쓰는 주체가 이 둘뿐이고, 형태가 키 이름 하나만 다르다.
  세 번째 마커가 생기면 3안으로 옮기라고 decision.md에 남겨 뒀다.
- **[권한 프롬프트]** `printf ... >>`는 `.claude/settings.json`의 allow 목록에 없어서
  실행 시 확인을 받을 수 있다. → 완화: allow 확대는 사용자가 범위에서 뺐다.
  프롬프트는 흐름을 잠깐 멈출 뿐 파일을 깨뜨리지 않는다. 실제로 서브에이전트를
  멈춰 세운다는 사실이 확인되면 2안(Edit 기반)으로 재검토한다.
- **[셸 의존]** 지침에 셸 명령을 못 박으면 Bash 도구가 없는 에이전트에는 못 쓴다.
  → 완화: preparer/designer 둘 다 `tools:`에 Bash가 있다 (각 파일 5행).
- **[문서 문체]** 이 저장소는 원칙 서술형으로 쓰여 있어서 셸 명령 코드블록이
  튄다는 지적이 가능하다. → 완화: 두 문서 모두 이미 `openspec ...` 명령 코드블록을
  쓰고 있어 형식 자체는 새롭지 않다.
- **[검증이 재현 시나리오뿐]** 자동 테스트가 없어서 "문서가 고쳐졌다"는 사람이 읽어
  판정해야 한다. → 완화: 관용구의 정확성만큼은 임시 openspec 프로젝트에서
  A~E를 다시 돌려 기계적으로 확인한다. tasks.md가 그 절차를 담는다.

## Migration Plan

배포 절차가 따로 없다. 세 파일을 고치고 커밋하면 끝이다.
기존 설치본은 `install.sh`가 `.claude/agents/*.md`를 복사하는 경로를 통해 갱신되며,
새 파일이 생기지 않으므로 `copy_if_absent`로 인한 업그레이드 구멍도 없다.
되돌리기는 커밋 되돌리기 하나로 끝난다.
