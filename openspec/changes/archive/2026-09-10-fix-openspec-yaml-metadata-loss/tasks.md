> **채택안: 1안** — 복붙 가능한 가드형 append 명령을 두 에이전트 문서에 박고,
> 확인 절에 `openspec status --json` 종료코드 게이트를 넣는다. (decision.md)
>
> **핵심 결정 세 가지**
> 1. 산문 원칙이 아니라 **그대로 복사해 실행할 명령**을 박는다. 이 change 자체가
>    "산문 지침은 해석된다"의 증거라, 대응까지 산문이면 같은 실패 자리를 남긴다.
> 2. 게이트는 `validate`와 `status --json` **둘 다**여야 한다. 역할이 다르다.
>    `status --json`은 메타데이터 파손 A~D를 **전부** 잡는 범용 게이트이고,
>    `validate --strict`는 D를 놓치는 대신 델타 자체를 검증한다.
>    (2026-09-09 재측정 확정 — 표의 C행 값이 한 번 바뀌었다. design.md 기준선 참고.)
> 3. 보존 대상은 `schema:` 하나가 아니라 **기존 키 전부**다 (`--goal`을 주면
>    `goal:` 키가 더 붙는다). 문구를 "한 줄 추가"가 아니라 "기존 키 보존 후 추가"로 쓴다.
>
> 이 저장소에는 실행 가능한 테스트 스위트가 없다. 쓸 수 있는 검증 수단은
> `bash -n install.sh`와, 임시 디렉터리에 openspec 프로젝트를 만들어 실패 모드를
> 재현하는 것뿐이다. 아래 검증 작업은 전부 그 범위 안에 있다.
>
> 아래에 적힌 행 번호는 작업 시작 시점 기준이다. 앞쪽을 고치면 뒤로 밀리니
> **행 번호가 아니라 주변 문구로 위치를 찾아라.**

## 1. 기준선 재현 (고치기 전 상태를 내 손으로 확인한다)

- [x] 1.1 스크래치 디렉터리에 임시 openspec 프로젝트를 하나 만들고
      (`openspec init` 후 `openspec new change baseline-a` 등, 실패 모드마다 별도 change),
      만들어진 `.openspec.yaml`을 `cat`으로 열어 `schema:`와 `created:` 두 줄이
      들어 있음을 확인한다. **이 저장소의 `openspec/`은 절대 건드리지 않는다.**
- [x] 1.2 실패 모드 A~E를 각각 재현하고 `validate` / `validate --strict` /
      `status --change <이름> --json` 세 명령의 **종료코드**를 표로 기록한다.
      기록한 표가 design.md "기준선: analyzer가 실측한 실패 모드 매트릭스"와
      일치하는지 대조한다. 어긋나는 칸이 있으면 **고치기 전에 보고한다**
      (설계의 전제가 틀렸다는 뜻이다).
      - A: `printf 'skip_specs: true\n' > .openspec.yaml`
      - B: 가드 없는 `>>`를 두 번 실행
      - C: 마지막 줄 개행을 지운 뒤 `printf 'skip_specs: true\n' >> ...`
      - D: `printf 'retire_capabilities: true\n' > .openspec.yaml`
      - E: design.md D1의 가드형 append
- [x] 1.3 실패 모드 E의 명령을 같은 change에 **세 번 연속** 실행하고,
      매번 종료코드가 0이며 `.openspec.yaml`에 마커 키가 정확히 한 번만
      나타나는지 `grep -c '^skip_specs:'`로 확인한다 (기대값 1).
- [x] 1.4 `retire_capabilities` 버전의 가드형 append도 같은 방식으로 돌려,
      세 명령 종료코드가 모두 0인지 확인한다. 1.2~1.4에서 확인된 정확한 명령
      문자열을 그대로 이후 작업에 옮겨 쓴다 (여기서 손으로 다시 타이핑하지 마라).

> **그룹 1 결과 (2026-09-09, 완료됨 — 다시 돌리지 마라):**
> 1.2에서 **C행이 어긋났다.** 표에는 `status --json`이 0이라고 적혀 있었지만 실측은 1이다.
> 제3의 환경에서 독립 재측정해 worker 쪽이 맞다는 것을 확인했고, design.md·proposal.md의
> 표와 "읽는 법", decision.md의 게이트 근거를 실측대로 고쳤다. **결론(두 게이트를 다 넣는다)은
> 그대로다.** 아래 2~5번 작업은 고쳐진 표를 기준으로 진행한다.
> 재현 조건 하나 더: **D행은 델타가 하나라도 있는 change 기준**이다 (빈 change에서는
> `validate`가 델타 없음 때문에 1이 되어 D가 재현되지 않는다).

## 2. `.claude/agents/preparer.md` 수정

- [x] 2.1 6단계의 "`<changeRoot>/.openspec.yaml`에 `skip_specs: true` 한 줄을
      추가하고" 문장(146행 부근)을 교체한다. 새 문구에는 다음이 모두 들어가야 한다:
      ① `.openspec.yaml`은 `openspec new change`가 **이미 만들어 둔 파일**이라는 사실
      ② **기존 키를 하나도 지우지 말 것**(`schema:` 하나가 아니라 `created:`,
      `goal:` 등 전부) ③ design.md D1의 가드형 append 코드블록 그대로
      ④ 이 파일에 `Write` 도구와 셸 `>` 리다이렉트 **금지**.
      검증: 수정 후 그 절을 읽어 ①~④가 모두 눈에 보이는지 확인한다.
- [x] 2.2 7단계 "확인" 절(150~156행 부근)에 design.md D3의 두 종료코드 게이트를
      넣는다. `openspec validate "<이름>"` 종료코드와
      `openspec status --change "<이름>" --json >/dev/null` 종료코드를 **둘 다**
      찍어 보라고 적고, `status` 쪽이 0이 아니면 `.openspec.yaml` 메타데이터가
      깨진 것이라고 설명한다. 파이프를 붙이면 종료코드가 바뀐다는 주의를 함께 적는다.
      **`validate` 출력만 보고 판정하지 말라는 말을 함께 적는다** — 마커가 앞 줄에
      이어 붙은 경우 `validate`에는 델타 없음 에러 하나만 나와서 정상으로 오독된다.
      검증: 적어 넣은 명령 두 줄을 그대로 이 change에 실행해 실제로 동작하는지 본다.
- [x] 2.3 같은 확인 절에 design.md D4의 **일반화된 진단 절차**를 넣는다.
      `cat "<changeRoot>/.openspec.yaml"`로 파일을 열어 ① 기존 키 생존
      ② 마커 키 중복 없음 ③ 마커가 앞 줄에 이어 붙지 않음 세 가지를 보라고 적는다.
      특정 에러 문구 하나에 의존하는 안내를 넣지 않는다.
      검증: 진단 절차 세 항목이 각각 실패 모드 A/D·B·C에 대응하는지 확인한다.
- [x] 2.4 154행의 "아직 델타가 없어서 실패할 수 있다(`exit=1`). 그건 정상이다"에
      조건을 붙인다 (design.md D5). 마커를 설정하지 **않은** 경우에만 정상이고,
      `skip_specs`를 넣었는데도 이 에러가 나오면 마커가 반영되지 않은 것이니
      `.openspec.yaml`을 확인하라는 취지로 바꾼다. **문장을 지우지 말고 조건을 붙인다.**
      검증: 154행과 바로 다음 줄(155)을 이어 읽었을 때 같은 exit=1을 서로 반대로
      해석하지 않는지 확인한다.

## 3. `.claude/agents/designer.md` 수정

- [x] 3.1 5단계 specs 델타 절의 "`retire_capabilities: true`를 추가하고"
      문장(158행 부근)을 교체한다. 내용은 2.1과 같되 키 이름만
      `retire_capabilities`로 바꾼다 (①~④ 모두 포함).
      검증: preparer.md 2.1의 결과물과 나란히 놓고 읽어 **같은 사실을 말하는지**
      확인한다 (키 이름 외에 내용이 갈라지면 안 된다).
- [x] 3.2 7단계 "검증" 절(187~200행 부근)에
      `openspec status --change "<이름>" --json >/dev/null; echo "metadata exit=$?"`를
      추가하고, **왜 `validate --strict`만으로는 부족한지**를 한 줄로 적는다
      (`retire_capabilities`를 잘못 넣으면 `validate --strict`가 exit=0으로 통과하고
      `status`만 exit=1이 된다). 두 게이트의 **역할이 다르다**는 것도 한 줄로 적는다:
      `status`는 메타데이터 파손 게이트(A~D 전부), `validate --strict`는 델타 검증
      게이트. 기존 `validate --strict` 게이트와 파이프 주의는 그대로 살린다.
      검증: 그 명령 두 줄을 이 change에 그대로 실행해 동작을 확인한다.
- [x] 3.3 같은 검증 절에 2.3과 동일한 일반화된 진단 절차를 넣는다.
      검증: preparer.md 쪽 진단 절차와 항목이 일치하는지 대조한다.

## 4. `README.md` 수정

- [x] 4.1 182행의 `.openspec.yaml` 표 한 줄을, `openspec new change`가 만들어 둔
      파일에 에이전트가 마커를 **덧붙인다**는 사실이 드러나게 고친다 (design.md D6).
      표의 열 구조와 다른 줄은 건드리지 않는다.
      검증: 표가 여전히 정렬된 마크다운 표로 렌더링되는지, 그 줄만 바뀌었는지
      `git diff README.md`로 확인한다.

## 5. 검증

- [x] 5.1 1.2에서 만든 임시 프로젝트에서, **문서에 실제로 박힌 명령 문자열을
      복사해** 다시 실행한다 (문서에서 복붙 — 기억으로 다시 타이핑하지 마라).
      `skip_specs`와 `retire_capabilities` 두 경우 모두
      `validate` / `validate --strict` / `status --json` 세 종료코드가 전부 0인지
      확인한다. 하나라도 0이 아니면 2.1 또는 3.1의 코드블록에 오타가 있는 것이다.
- [x] 5.2 같은 명령을 세 번 반복 실행해도 마커 키가 하나만 남고 종료코드가 0인지
      (`grep -c` 기대값 1) 다시 확인한다 — 문서 안의 문자열 기준 멱등성 확인이다.
- [x] 5.3 개행 없이 끝나는 `.openspec.yaml`에 문서의 명령을 실행해,
      마커가 앞 줄에 붙지 않고 독립된 줄로 들어가는지 확인한다
      (`tail -2` 육안 + `status --change ... --json`이 종료코드 0이고 `specs` 산출물이
      `skipped`가 되는지 확인). 판정은 `status` 종료코드로 한다 — 줄이 붙었을 때
      `validate` 출력에는 YAML 파손 흔적이 남지 않는다.
- [x] 5.4 `bash -n install.sh` 실행 후 종료코드가 0인지 확인한다
      (`bash -n install.sh; echo "exit=$?"`). 이 change는 install.sh를 건드리지
      않으므로 회귀 없음 확인용이다.
- [x] 5.5 proposal.md "받아들일 조건" 8개 항목을 하나씩 대조하며 체크한다.
      충족하지 못한 항목이 있으면 무엇이 왜 남았는지 보고서에 적는다.
- [x] 5.6 `git diff --stat`으로 바뀐 파일이 `.claude/agents/preparer.md`,
      `.claude/agents/designer.md`, `README.md` **셋뿐인지** 확인한다
      (openspec 산출물 제외). 스크래치의 임시 openspec 프로젝트가 저장소 안에
      들어오지 않았는지도 함께 본다.
