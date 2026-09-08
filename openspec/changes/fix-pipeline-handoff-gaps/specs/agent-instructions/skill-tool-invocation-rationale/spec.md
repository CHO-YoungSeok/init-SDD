## Purpose

"openspec 스킬을 직접 부르지 마라"는 지침이 사실인 근거 위에 서게 한다. 지금 근거로 적힌
"`Skill` 도구가 없을 수 있다"는 이 환경에서 거짓이고, 이 저장소의 "짐작하지 마라, 실측이
정답"이라는 규칙을 스스로 어기고 있다.

## ADDED Requirements

### Requirement: 다섯 에이전트 지시문의 스킬 호출 문단은 allowed-tools 제약을 근거로 들어야 한다

`.claude/agents/preparer.md`, `.claude/agents/designer.md`, `.claude/agents/worker.md`,
`.claude/agents/finalizer.md`, `.claude/agents/analyzer.md`의 해당 블록인용 문단은
다음 세 가지를 담아야 한다(SHALL):
(a) 스킬을 부르지 말고 `.claude/skills/<이름>/SKILL.md`를 Read로 읽어 그 절차를 따를 것,
(b) 그 근거로 6개 openspec 스킬이 frontmatter에 `allowed-tools: Bash(openspec:*)`를 선언해
스킬이 도는 동안 쓸 수 있는 도구가 `openspec` 셸 명령 하나로 좁혀져 산출물 파일도 못 쓰고
코드도 못 고친다는 사실,
(c) 결론 문장 "스킬을 못 부른다는 이유로 절대 멈추지 마라."
"`Skill` 도구가 없을 수 있다"는 서술은 사실이 아니므로 다섯 파일 모두에서 제거되어야 한다(MUST).
다섯 파일의 그 문단은 **글자 단위로 같아야 한다**(SHALL). 한 곳만 갱신되면 같은 저장소 안에서
같은 자리가 서로 다른 말을 하게 되고, 그중 하나는 거짓이 된다.

#### Scenario: 거짓 근거가 사라진다

- **WHEN** 다섯 파일에서 "`Skill` 도구가 없을 수 있다"를 찾는다
- **THEN** 다섯 파일 어디에도 남아 있지 않다 (현 환경에서 다섯 에이전트 모두 frontmatter `tools:` 줄에
  `Skill`을 갖고 있다 — 실측)

#### Scenario: 진짜 근거가 들어간다

- **WHEN** 에이전트가 왜 스킬을 부르면 안 되는지 확인한다
- **THEN** `allowed-tools: Bash(openspec:*)` 때문에 스킬 실행 중 도구가 좁혀진다는 근거를 읽는다

#### Scenario: 결론 문장은 다섯 파일 모두에 그대로 남는다

- **WHEN** 에이전트가 스킬을 부르지 못하는 상황을 만난다
- **THEN** "스킬을 못 부른다는 이유로 절대 멈추지 마라."는 문장이 다섯 파일 모두에 있어 멈추지 않는다

#### Scenario: 다섯 파일의 문단이 글자 단위로 같다

- **WHEN** 다섯 파일의 해당 블록인용만 뽑아 각각 md5를 낸다
- **THEN** 다섯 값이 모두 같다 — 한 벌의 같은 문구가 다섯 곳에 동일하게 들어가 있어
  한 곳만 갱신되는 어긋남이 생기지 않는다 (개수 세기 grep으로는 "문구가 조금 다른" 경우를 못 잡는다)
