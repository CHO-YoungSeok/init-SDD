## Why

등급 이름을 문자열(`normal`, `semi-lower`, `lower`)에서 숫자 표기(N/5 형식)로 통일한다.
현재는 사용자가 `/agent-model-tier normal` 처럼 문자열로만 호출할 수 있는데, 숫자로 바꾸면
더 명확하고 일관된 인터페이스를 제공할 수 있다. 예를 들어 `/agent-model-tier 4` 처럼
숫자가 크기 관계를 직관적으로 드러낸다.

## What Changes

- **SKILL.md**: 등급 이름을 숫자로 변경
  - 발동 신호, 설명, 절차, 예시에서 `normal` → `4`, `semi-lower` → `2`, `lower` → `1`
  - 하위호환 제거: 사용자는 이제 숫자로만 호출해야 함 (문자열은 더 이상 안 먹힘)
  
- **메인 spec** (`openspec/specs/distribution/agent-model-tier/spec.md`): 요구사항 업데이트
  - 등급 값의 형식 변경 (문자열 → 숫자)
  - 하위호환 없음을 명시

- **README.md**: 가이드 문구 업데이트
  - 등급 이름이 나오는 부분을 숫자로 변경

## Capabilities

### New Capabilities

### Modified Capabilities

- `distribution/agent-model-tier`: 등급 값 형식이 문자열에서 숫자(N/5)로 변경되고, 하위호환이 없어진다

## Impact

- **SKILL.md**: 스킬 파일의 모든 설명과 절차가 숫자 기반으로 변경됨
- **메인 spec**: 요구사항 문서가 숫자 표기로 업데이트됨
- **README.md**: 사용자 가이드가 숫자 표기로 업데이트됨
- **사용자 인터페이스**: `/agent-model-tier` 호출이 이제 숫자만 받음

---

## 받아들일 조건

- [ ] SKILL.md의 모든 등급 이름이 N/5 형식으로 변경됨 (발동신호, 절차, 예시, 경고 전부)
- [ ] 메인 spec의 요구사항이 숫자 표기로 업데이트됨  
- [ ] README.md의 등급 관련 문구가 숫자로 변경됨
- [ ] 문서 일관성이 유지됨 (모든 문서가 같은 숫자 표기 사용)

## 지금 코드 상태

- SKILL.md: 등급 이름이 문자열로 박혀있음 (절차 설명, 예시, 경고 모두)
- 메인 spec: 요구사항에 문자열 등급 이름이 명시되어 있음
- README.md: 라인 231에서 문자열 등급 이름 언급
- 실제 에이전트 파일들은 로컬 수정 상태 (손댈 대상 아님)

## 내가 세운 가정

- 매핑은 사용자가 이미 확정함: 1/5=lower, 2/5=semi-lower, 4/5=normal, 3/5와 5/5는 미래 예약
- 하위호환 없음: 이제 숫자로만 호출 가능
- 실제 모델 값(opus/sonnet/haiku)은 바뀌지 않음, 이름표만 변함
- 과거 change 기록(openspec/changes/*)과 archived된 파일들은 손댈 대상 아님
