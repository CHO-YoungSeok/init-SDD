## Purpose

designer가 프롬프트에 손으로 옮겨 적힌 요약보다 원본 산출물 파일을 우선하게 해서,
옮겨 적다 틀린 숫자가 설계와 구현까지 그대로 흘러가는 것을 막는다.

## ADDED Requirements

### Requirement: designer는 프롬프트 요약보다 원본 파일을 우선해야 한다

`.claude/agents/designer.md`의 1단계(입력 다시 읽기)는 다음 세 가지를 명시해야 한다(SHALL):
프롬프트에 실려 온 숫자·표·인용과 `analysis.md`의 내용이 다르면 **파일이 맞다는 것**,
기준선 숫자처럼 설계가 기대는 값은 반드시 `analysis.md`에서 다시 읽어야 한다는 것,
다르면 그 사실을 보고서에 적어야 한다는 것.
이는 `finalizer.md`에 이미 있는 같은 취지의 방어(프롬프트의 "판정: 통과" 한 줄을 믿지 말고
`review.md`를 직접 읽어라)와 짝을 이룬다.

#### Scenario: 프롬프트의 값과 파일의 값이 다르다

- **WHEN** designer가 프롬프트에서 본 수치와 `analysis.md`에 적힌 수치가 서로 다르다
- **THEN** `analysis.md`의 값을 채택하고, 두 값이 달랐다는 사실을 보고서에 적는다

#### Scenario: 기준선 숫자를 설계에 옮긴다

- **WHEN** 정량 요구사항이라 design.md에 기준선 숫자를 기록해야 한다
- **THEN** 프롬프트에 적힌 숫자를 그대로 옮기지 않고 `analysis.md`에서 다시 읽어 온다

#### Scenario: 받는 쪽 두 곳에 같은 방어가 있다

- **WHEN** 파이프라인에서 프롬프트 요약을 신뢰해야 하는지 판단하는 자리를 찾는다
- **THEN** designer(analysis.md 대조)와 finalizer(review.md 대조) 양쪽에 같은 취지의 규칙이 있다
