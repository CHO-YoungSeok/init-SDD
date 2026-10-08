# evals

`claude plugin eval` 이 읽는 사례 폴더를 모아 두는 곳이다.
지금은 뼈대만 있고 실제 작업 문장과 채점 조건은 비어 있다(`TODO`).
확인한 Claude Code 버전은 2.1.294 이다. 버전이 바뀌면 `claude plugin eval init` 출력 모양이 달라질 수 있다.

## 실행 위치

`claude plugin eval` 은 `plugin.json` 이 있는 플러그인 루트에서 돈다.
이 저장소의 루트(`.claude-plugin/plugin.json` 이 있는 곳)가 플러그인 루트다. 저장소 루트에서 실행한다.

## 폴더 구조

```
evals/
├── README.md
├── lite-path-small-task/
│   ├── prompt.md
│   └── graders/criteria.md
└── direct-work-control/
    ├── prompt.md
    └── graders/criteria.md
```

- `lite-path-small-task`: 작은 작업 경로(`preparer → worker → reviewer → finalizer`)로 처리할 작은 작업. `--ablation with-without` 의 without 쪽이 곧 직접 작업이다.
- `direct-work-control`: SDD 와 상관없는 평범한 직접 요청. 플러그인이 직접 작업을 해치지 않는지 보는 대조군이다.
- `prompt.md` 머리글에는 `max_turns`, `allowed_tools` 가, `graders/criteria.md` 머리글에는 `type: llm`, `weight` 가 있다.

## 사례 추가

```
claude plugin eval init --bare <이름>
```

플러그인 루트(저장소 루트)에서 돌린다. 손으로 흉내 내지 말고 이 명령이 만든 모양을 그대로 쓴다.

## 실행

플러그인 루트에서 아래처럼 돌린다. 금액은 사용자가 정한다.

```
claude plugin eval . --ablation with-without --runs 3 --max-cost-usd <금액> --no-publish --json <json경로> --report <html경로>
```

`--no-publish` 를 빼지 않는다. 기본값은 보고서를 claude.ai에 올린다.

`--threshold` 는 임계값이라 쓰지 않는다. 임계값은 측정 뒤 사용자가 정한다.

## 실제 측정 전에 바꿀 것

- `allowed_tools` 는 bare 기본값이라 Write, Edit, Bash 가 없다. 실제 작업 사례는 도구를 넓히고 `--allow-tools` 로 허용해야 한다.
- 결과는 `evals/results/` 에 쌓이고 `.gitignore` 가 무시한다. 커밋하지 않는다.

## 기록

채점 점수는 `docs/field-validation.md` 기록 표의 품질 칸에 옮긴다.
