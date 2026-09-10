# 결정 기록

- 채택한 안: 1안 — 복붙 가능한 가드형 append 명령을 두 문서에 박고, 확인 절에 `openspec status --json` 종료코드 게이트를 넣는다
- 결정한 사람: 사용자 (오케스트라를 통해)
- 결정 날짜: 2026-09-08
- analyzer 추천안: 1안 (동일)

## 채택 이유

사용자가 말한 그대로 옮긴다.

> 이 change 자체가 "산문 지침은 해석된다"의 증거다. 원인이 모호함인데 대응까지 산문이면
> 같은 실패 자리를 남긴다. 실측으로 A~D를 전부 막는 관용구를 이미 확보했으니 그걸 그대로 박는다.
> 4안의 게이트는 1안이 흡수한다.

## 채택하지 않은 안과 그 이유

analysis.md 5절에서 옮긴다.

- **2안 (도구 무관 서술형 원칙)** — 산문은 해석된다. 이 change 자체가 산문 지침을 글자대로
  따르다 사고 난 사례라, 같은 계열의 대응은 재발 확률이 높다. 실패 모드 B(키 중복)·C(개행 없는
  끝줄)를 원칙만으로는 예방하지 못하고 사후 검출로만 막는다.
- **3안 (공통 절차 파일을 만들고 두 에이전트가 Read로 참조)** — 읽기 한 홉이 늘어난다.
  이 저장소는 "스킬을 못 불러서 안 따랐다"로 이미 한 번 데였다. 마커는 change당 한 번 쓰는
  드문 경로라 더 잘 잊는다. 새 파일은 `install.sh`의 `copy_if_absent` 특성상 기존 설치본에
  안 깔려 업그레이드 구멍도 생긴다. 중복 지점이 3곳을 넘어가면 이 판단이 뒤집힌다.
- **4안 (확인 게이트만 강제)** — 예방이 아니라 사후 검출이라 매번 한 번 깨뜨렸다 고치는
  왕복이 생기고, 복구 중 또 덮어쓸 수 있다. proposal의 "구체적 방법이 들어간다" 조건도
  만족하지 못한다. **버리는 것이 아니라 1안 안에 흡수한다** — status 종료코드 게이트가 그것이다.

## 핵심 결정

1. **예방(명령 못 박기) + 검출(status 종료코드 게이트)을 함께 넣는다.**
   analyzer가 실측으로 검증한 가드형 append 관용구를 두 에이전트 문서에 그대로 박고,
   확인 절에는 `openspec status --change "<이름>" --json` 종료코드 게이트를 넣는다.

2. **못 박을 관용구는 이 형태다** (실측 검증, 3번 돌려도 한 줄이고 exit=0).
   ```bash
   f="<changeRoot>/.openspec.yaml"
   grep -q '^skip_specs:' "$f" || printf '\nskip_specs: true\n' >> "$f"
   ```
   앞의 `\n`이 실패 모드 C(개행 없는 끝줄)를, `grep -q` 가드가 B(키 중복)를,
   `>>`가 A/D(덮어써서 기존 키 유실)를 막는다. designer 쪽은 `retire_capabilities`로 같은 형태다.

3. **표현은 "한 줄 추가"가 아니라 "기존 키를 전부 보존한 채 추가"로 한다.**
   `--goal`을 주면 `goal:` 키가 하나 더 붙는다(실측). 보존 대상은 `schema:` 하나가 아니다.

4. **Write 도구와 셸 `>` 리다이렉트를 이 파일에 대해 금지로 명시한다.**
   analyzer가 "실제 사고 경로는 Bash `>`가 더 그럴듯하다"고 봤고, 둘 다 막아야 한다.

5. **진단 힌트는 문구 하나가 아니라 세 가지 실패 모드를 모두 짚는 절차로 일반화한다.**
   `schema: Invalid input` 문구만으로는 B(다른 문구)·C(`validate` 출력에 원인 문구 없음)·
   D(validate 통과)를 못 잡는다.
   → proposal의 받아들일 조건 3번을 designer가 먼저 고친다.

6. **designer 검증 절에 `openspec status --change "<이름>" --json` 종료코드 확인을 추가한다.**
   `status`는 메타데이터 파손 A~D를 **전부** exit=1로 잡는 범용 게이트다
   (2026-09-09 재측정 확정). 특히 D(retire_capabilities 덮어쓰기)는 `validate --strict`가
   exit=0으로 통과해 버려서 `status` 없이는 아예 안 잡힌다.
   지금 designer.md 어디에도 status 종료코드를 보라는 말이 없다.
   `validate --strict`는 그대로 두되 역할이 다르다 — 델타 자체의 검증용이다.

7. **preparer.md:154의 "델타가 없어서 나는 exit=1은 정상이다" 문구를 고친다.**
   실패 모드 C(마커가 앞 줄에 이어 붙어 YAML이 깨진 경우)에서 `validate`가 남기는
   **유일한** 에러가 바로 그 문구다. 지금대로면 파손을 "정상"으로 오독한다.

8. **범위를 3파일로 늘린다** — `.claude/agents/preparer.md`, `.claude/agents/designer.md`,
   `README.md`(182행 표 한 줄). README 표에 "`openspec new change`가 만들어 둔 파일에
   마커를 덧붙인다"는 사실이 드러나게 맞춘다. → proposal의 Impact/What Changes도 함께 고친다.

## 사용자가 명시적으로 제외한 것

- `.claude/settings.json`의 `permissions.allow` 확대(`Bash(printf:*)` 등)는 이번 범위에 넣지 않는다.
  (analyzer 질문 2번 → 사용자 답: 하지 않는다)
- 상류 OpenSpec CLI에 `--skip-specs` 플래그를 요청하는 것도 이번 범위 밖이다.
  (analyzer 질문 3번 → 별도 언급 없음, 기본값 유지)

## 실측 정정 2026-09-09 (채택안은 그대로 1안)

worker가 작업 1.2(기준선 재현)를 돌리다 design.md·proposal.md 실패 모드 표의
**C행이 실측과 어긋난다**는 것을 발견했다. (analysis.md 32~37행의 원본 표에는 C의
`status --json`이 1로 제대로 적혀 있다 — proposal/design으로 옮겨 적는 과정에서
0으로 잘못 들어갔고, 거기 딸린 "읽는 법" 문장이 그 오기를 따라갔다.) 오케스트레이터가 제3의 환경에서 독립으로
다시 재서 worker 쪽이 맞다는 것을 확인했다. analyzer의 최초 측정이 틀렸다.

- 표에 적혀 있던 값: C의 `status --json` = **0** (→ "status는 C를 못 잡는다")
- 실측 확정값: C의 `status --json` = **1**. 파일이
  `created: 2026-09-09skip_specs: true`가 되어 한 줄에 콜론이 두 개라 YAML 파싱이 깨지고,
  `status`가 `Invalid YAML in metadata file: Nested mappings are not allowed in compact
  mappings at line 2, column 10`을 낸다.
- 대신 C에서 오독을 부르는 쪽은 `validate`다. exit=1이지만 출력에 YAML 얘기가
  한마디도 없고 `Change must have at least one delta` 하나만 나온다.

**결론은 바뀌지 않는다 — 두 게이트를 다 넣는다.** 다만 근거가 바뀌었다.

- `status --change <이름> --json` → A·B·C·D를 **전부** 잡는다. 메타데이터 파손의 범용 게이트.
- `validate --strict` → D를 못 잡는다. 그래도 델타 자체를 검증하는 다른 목적이 있어 필요하다.

핵심 결정 7(preparer.md:154 문구 수정)의 근거도 그대로 살아 있다. 오히려 더 선명해졌다 —
C에서 `validate`가 내는 유일한 에러가 바로 그 문구가 "정상이다"라고 가르치는 그 에러다.

부수 확인: **D행은 델타가 하나라도 있는 change 기준이다.** 델타가 없는 빈 change에
`retire_capabilities`를 덮어쓰면 `validate`가 1이 되는데, 원인은 메타데이터가 아니라
`Change must have at least one delta`다. 재현 조건을 표에 단서로 붙였다.
