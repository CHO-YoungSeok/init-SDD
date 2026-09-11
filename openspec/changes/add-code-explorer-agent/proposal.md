## Why

Currently, the 7 sub-agents work in a fixed sequence (preparer → analyzer → designer → worker → reviewer + regression-verifier → finalizer). Code exploration and searching are handled by analyzer, but these are general capabilities needed by multiple agents at different stages. Adding a dedicated code-explorer agent allows any sub-agent to call it directly when needed for tasks like code inspection, searching, or navigating the codebase—improving separation of concerns and enabling efficient code-focused work without going through the full pipeline.

## What Changes

- **New sub-agent**: A code-explorer agent dedicated to reading and searching code, specs, and documentation
- **Inter-agent communication**: All 7 existing sub-agents receive the `Agent` tool, enabling them to call the code-explorer when needed
- **Model tier**: The code-explorer agent is always `haiku` (excluded from the `agent-model-tier` skill's variable tier system)
- **Installation and verification**: `install.sh` checks update to 8 agents; `README.md` and other docs updated to reflect 8-agent structure

## Capabilities

**정정 (designer):** 이 저장소의 `openspec/specs/agent-instructions/`는 에이전트 이름별
디렉터리(`preparer/`, `analyzer/` 등)가 아니라 `analyzer-option-generation`,
`artifact-file-precedence-over-prompt` 같은 **주제별 capability**로 되어 있다(실측).
아래는 그 실제 구조에 맞춘 목록이다.

### New Capabilities
- `agent-instructions/code-explorer-role`: 새 code-explorer 서브에이전트 파일의 위치,
  frontmatter, 도구 구성(읽기 전용, Agent 없음), 역할과 그 경계를 정한다
- `agent-instructions/code-explorer-invocation`: 기존 7개 에이전트 파일에 `Agent` 도구를
  추가하고, code-explorer를 언제 부르는지 안내하며, 호출 범위가 code-explorer 하나로
  좁혀지게 한다

### Modified Capabilities
- `distribution/agent-model-tier`: code-explorer가 등급 표(7행) 밖에 있고 항상 haiku로
  고정된다는 것을 표 아래 한 줄로 명시한다 (표 자체는 늘리지 않는다 — 사용자 결정)
- `distribution/sdd-install-script`: "제품 5종을 깔아야 한다" 요구사항의 에이전트 개수를
  7개에서 8개로 갱신한다 (`install.sh`의 설치 확인 문구도 함께)

## Impact

- **Affected files**: 7 existing agent files get `Agent` tool added to their `tools:` frontmatter; agent-model-tier skill may need clarification; install.sh checks update (120); README.md and orchestration docs
- **Backward compatibility**: The change is additive (new agent + new tool capability for existing agents) — no breaking changes to existing specs or behavior
- **Dependencies**: No new external dependencies; remains within existing OpenSpec and Claude Code framework
- **Structure**: Introduces first instance of sub-agents calling other sub-agents (previously only orchestrator called sub-agents) — this is a deliberate architectural shift as confirmed by the user

---

## Questions for Clarification (Preparer's Notes - Not Repeating in Docs)

The orchestrator has pre-confirmed the direction, so these are resolved below. Recorded here for designer/reviewer reference:

1. **New agent name**: Orchestrator deferred to designer. Preparer suggests candidates: `code-explorer`, `code-searcher`, `codebase-inspector`. Actual name chosen at design phase.
2. **Agent-model-tier handling**: Orchestrator said "keep out of the tier system" (don't add to the 7-agent table). Designer decides if explicit documentation in SKILL.md is needed.
3. **Depth limit**: Orchestrator suggested code-explorer should NOT have `Agent` tool (cannot call other sub-agents), preventing infinite recursion. Designer confirms.
4. **Affected Specs Assessment**:
   - Currently 10 agent-instruction sub-specs exist (analyzer-option-generation, artifact-file-precedence-over-prompt, etc.)
   - These address behavior across the 7-agent pipeline
   - New agent and the "all agents can call code-explorer" pattern require:
     - 1 new spec for code-explorer agent instructions
     - 7 modified specs (one per existing agent) to document the `Agent` tool and when/how to use it
   - agent-model-tier spec already constrains to "7 agents" in multiple places; needs review for 8th agent mention

## Scope Boundaries (Preparer's Internal Notes)

**In scope for this change:**
- New agent file stub (`.claude/agents/code-explorer.md` or similar — name TBD by designer)
- Modification: 7 agent files' `tools:` lines (add `Agent`)
- Modification: agent-model-tier spec (clarify 8th agent status)
- Modification: install.sh line ~120 (update agent count check)
- Modification: README.md "7 agents" section (update to 8)
- Modification: CLAUDE.md pipeline description (if needed)
- Modification: orchestra skill (if needed)

**Out of scope:**
- Actual code-explorer agent instructions (designer writes full role/responsibilities)
- Detailed design of inter-agent call patterns (designer documents in design.md)
- Skill implementation changes (beyond agent-model-tier spec clarification)
- Testing or verification beyond openspec validate

## Acceptance Criteria

- [ ] `openspec validate` passes (new agent spec + 7 modified agent specs recognized)
- [ ] `.claude/agents/` has 8 files (7 existing + 1 new stub)
- [ ] `tools:` line in each of 7 existing agent files includes `Agent`
- [ ] `install.sh` checks for 8 agents (line ~120 updated)
- [ ] `agent-model-tier/spec.md` clarifies code-explorer is outside tier system
- [ ] README.md "7 agents" updated to "8 agents" (or similar structure reflecting new count)
- [ ] No existing agent specifications broken; all specs still validate
