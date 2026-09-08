## Why

`openspec new change <이름>` (OpenSpec 1.12.0)은 `<changeRoot>/.openspec.yaml`을
이미 만들어 둔다 (`schema: spec-driven`, `created: <날짜>` 두 줄. `--goal`을 주면
`goal:` 키가 하나 더 붙는다 — 실측). 그런데
`.claude/agents/preparer.md`(6단계, `skip_specs: true`)와
`.claude/agents/designer.md`(5단계 specs 델타 절, `retire_capabilities: true`)는
"파일에 한 줄을 추가하라"고만 적혀 있어서, 파일이 이미 존재한다는 사실도
기존 키를 지우면 안 된다는 사실도 알려주지 않는다.

에이전트가 이 지침을 문자 그대로 따라 `Write`로 파일을 새로 쓰거나 셸 `>`로
덮어쓰면(예: `printf 'skip_specs: true\n' > .openspec.yaml`) 기존 `schema:` 줄이
사라지고, `openspec validate`가 다음 에러로 막힌다 (실측 재현, exit=1):

```
✗ [ERROR] .openspec.yaml: skip_specs is set but .openspec.yaml is not valid
  change metadata, so the marker is not honored. Fix the metadata
  (schema: Invalid input: expected string, received undefined)
✗ [ERROR] file: Change must have at least one delta. ...
```

임시 openspec 프로젝트에서 실패 모드를 전부 재현한 결과, 덮어쓰기는
**네 가지 실패 모드 중 하나**일 뿐이고 나머지 셋은 지금 문서로는 아무도 못 잡는다는
사실이 드러났다. 아래가 2026-09-09 재측정으로 확정된 값이다
(OpenSpec 1.12.0, 파이프 없이 `$?`로 수집한 종료코드. C행은 최초 측정이 틀렸던
자리이며, 제3의 환경에서 독립 재측정해 바로잡았다).

| # | 행동 | `validate` | `--strict` | `status --json` |
|---|---|---|---|---|
| A | `>` 덮어쓰기 → 기존 키 유실 | 1 | 1 | 1 |
| B | `>>` 두 번 실행 → 키 중복 | 1 | 1 | 1 |
| C | 개행 없는 마지막 줄에 `>>` → 줄이 붙음 | 1 | 1 | 1 |
| D | `retire_capabilities`를 덮어쓰기로 설정 | **0** | **0** | 1 |
| E | 가드 붙인 append | 0 | 0 | 0 |

재현 조건: **D행은 델타가 하나라도 있는 change 기준이다.** 델타가 없는 빈 change에서는
`validate`가 1이 되는데, 그 원인은 메타데이터가 아니라 `Change must have at least one
delta`다. A·B·C·E는 델타 유무와 무관하다.

- **C**는 `validate` 출력만 보면 정상으로 오독된다. 종료코드는 1이지만 출력에 YAML
  얘기가 한마디도 없고 `Change must have at least one delta` 하나만 나오는데,
  `preparer.md:154`가 바로 그 에러를 *"그건 정상이다"*라고 가르치고 있다.
  YAML 파손을 실제로 드러내는 것은 `status --change <이름> --json`이다
  (exit=1 + `Invalid YAML in metadata file: Nested mappings are not allowed ...`).
- **D**는 `validate --strict`가 exit=0으로 통과한다. designer.md의 검증 절은
  `validate --strict` 종료코드만 보라고 못 박아 두어서, 깨진 메타데이터가
  designer를 그냥 통과해 finalizer까지 간다.
- 정리하면 **`status --json`이 A~D를 전부 잡는 범용 게이트**이고,
  `validate --strict`는 D를 놓치는 대신 델타 자체를 검증한다. 역할이 달라서 둘 다 둔다.

즉 결함은 openspec CLI가 아니라 두 에이전트 문서의 지침 문구에 있다:
"파일이 이미 있고, 기존 키를 하나도 지우면 안 된다"는 전제를 빠뜨렸고,
그 결과를 잡아낼 확인 게이트도 빠져 있다.

## What Changes

- `.claude/agents/preparer.md` 6단계의 `skip_specs: true` 지침을, 실측으로 검증된
  **가드형 append 명령 코드블록**으로 바꾼다. `.openspec.yaml`이
  `openspec new change`가 이미 만들어 둔 파일임을 명시하고, **기존 키를 전부 보존한 채**
  마커만 덧붙이도록 한다 (`schema:` 하나가 아니라 `created:`·`goal:` 등 전부).
  `Write` 도구와 셸 `>` 리다이렉트는 이 파일에 대해 **금지**로 명시한다.
- `.claude/agents/designer.md` 5단계 specs 델타 절의 `retire_capabilities: true`
  지침도 같은 형태의 코드블록으로 바꾼다.
- 두 문서의 확인 절에 **`openspec status --change "<이름>" --json` 종료코드 게이트**를
  넣는다. 이것이 A~D를 모두 걸러내는 유일한 범용 게이트다.
  `validate --strict`는 D를 놓치므로 이것만으로는 부족하지만, 델타 자체를 검증하는
  별개의 목적이 있어 함께 둔다.
- 두 문서의 확인 절 진단 힌트를 **일반화**한다. 특정 에러 문구 하나가 아니라
  파일을 직접 확인하는 절차로 적는다: ① 기존 키가 전부 살아 있는가
  ② 마커 키가 중복되지 않았는가 ③ 마지막 줄에 붙어 버리지 않았는가.
- `.claude/agents/preparer.md:154`의 *"아직 델타가 없어서 실패할 수 있다(`exit=1`).
  그건 정상이다"* 문구를 고친다. 마커를 넣지 않은 경우에만 정상이며,
  `skip_specs`를 넣었는데도 이 에러가 나오면 마커가 안 먹은 것이니
  `.openspec.yaml`을 확인하라는 취지로 바꾼다.
- `README.md:182`의 `.openspec.yaml` 표 한 줄을, "`openspec new change`가 만들어 둔
  파일에 마커를 **덧붙인다**"는 사실이 드러나게 맞춘다.

**범위 밖**: `.claude/settings.json`의 `permissions.allow` 확대(`Bash(printf:*)` 등)는
이번에 하지 않는다. 상류 OpenSpec CLI에 마커용 플래그를 요청하는 것도 하지 않는다.

**BREAKING**: 없음. 에이전트 지침 문서와 README만 수정하며 기존 워크플로우의 산출물
형식이나 외부 인터페이스는 바뀌지 않는다.

## Capabilities

### New Capabilities
- `agent-instructions/openspec-metadata-marker-safety`: preparer/designer
  에이전트가 `.openspec.yaml`에 `skip_specs`/`retire_capabilities` 마커를
  설정할 때, `openspec new change`가 이미 만들어 둔 기존 메타데이터를 전부
  보존해야 한다는 요구사항, 그리고 그 결과를 CLI 종료코드로 확인해야 한다는
  요구사항을 문서화한다.

### Modified Capabilities
(없음 — 이 저장소에는 아직 등록된 메인 spec이 없다.)

## Impact

- 영향 파일 (3개, 코드 수정 없음 — 지침 문서와 README 문구만 수정):
  - `.claude/agents/preparer.md` (6단계 마커 지침, 7단계 확인 절, 154행)
  - `.claude/agents/designer.md` (5단계 specs 델타 절, 7단계 검증 절)
  - `README.md` (182행 `.openspec.yaml` 표 한 줄)
- 영향 범위: 이 두 에이전트가 앞으로 만드는 모든 change에서
  `skip_specs`/`retire_capabilities` 마커를 쓸 때 실패 모드 A~D가 예방되고,
  그래도 새어 나가면 확인 절의 종료코드 게이트가 잡는다.
- 받아들일 조건 (승인 기준):
  - [ ] preparer.md 6단계에 `.openspec.yaml`이 이미 존재한다는 사실과,
        **기존 키를 전부 보존한 채** 마커를 덧붙이는 복붙 가능한 명령이 들어간다.
        `Write` 도구와 셸 `>` 금지가 함께 명시된다.
  - [ ] designer.md 5단계 specs 델타 절의 `retire_capabilities: true` 지침에도
        동일한 형태의 명령과 금지 문구가 들어간다.
  - [ ] 두 문서의 확인 절에 **일반화된 진단 절차**가 들어간다. 특정 에러 문구
        하나에 기대지 않고, 실패 모드 A~D를 모두 짚는다:
        `.openspec.yaml`을 직접 확인해 ① 기존 키 생존 ② 마커 키 중복 없음
        ③ 마지막 줄에 붙지 않음을 보고, `validate`와 `status --json`
        **두 종료코드를 모두** 확인한다.
  - [ ] designer.md 7단계 검증 절에 `openspec status --change "<이름>" --json`의
        **종료코드 확인**이 들어간다 (실패 모드 D는 `validate --strict`가
        exit=0으로 통과하므로 이것 없이는 잡히지 않는다. `status`는 A~D를 전부 잡는
        메타데이터 파손 게이트다).
  - [ ] preparer.md 154행이 "델타가 없어서 나는 exit=1은 정상이지만,
        `skip_specs`를 넣었는데도 이 에러가 나오면 마커가 안 먹은 것"이라는
        취지로 바뀐다.
  - [ ] README.md 182행 표에 마커를 "덧붙인다"(기존 파일 보존)는 사실이 드러난다.
  - [ ] 임시 디렉터리에 openspec 프로젝트를 만들어 실패 모드 **A~E를 재현**했을 때,
        문서에 박힌 관용구(E)가 `validate`·`validate --strict`·`status --json`
        **세 종료코드 모두 exit=0**이고, 같은 명령을 3번 반복해도 마커 줄이
        하나만 남는다(멱등).
  - [ ] `bash -n install.sh` 통과 (회귀 없음 확인용. 이 change는 install.sh를
        건드리지 않지만 이 저장소에 실행 가능한 테스트 스위트가 없어 쓸 수 있는
        표준 확인 수단이다).
- 가정: 이 저장소에는 아직 메인 spec이 하나도 없으므로 (`openspec list --specs`
  결과 0개), 이번 capability는 "바뀌는" 것이 아니라 "새로 생기는" 것으로 분류한다.
- 사용자에게 물어야 할 것: 없음. (재현 절차와 원인이 실측으로 명확하고,
  범위 관련 질문 4건은 사용자가 이미 답했다 — decision.md 참고)
