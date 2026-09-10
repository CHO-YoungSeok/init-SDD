# Claude Handoff Skill for Antigravity (agy)

Claude Code에서 작업하던 대화 맥락과 진행 상태를 로컬 파일시스템에서 자동으로 찾아 Antigravity(agy)로 매끄럽게 인계받는 커스텀 스킬입니다.

## 📁 파일 구조

```
~/.gemini/antigravity-cli/skills/claude-handoff/
├── SKILL.md                          # agy 에이전트 지침 및 프론트매터
├── README.md                         # 설명서 및 CLI 사용법
└── scripts/
    └── parse_claude_session.py       # Claude Code 세션 로그(.jsonl) 파서
```

## ✨ 주요 특징

1. **자동 프로젝트 감지**:
   - 현재 작업 경로(CWD)를 Claude Code의 프로젝트 디렉토리 포맷(`~/.claude/projects/-Users-...`)과 매핑하여 자동으로 찾아냅니다.
2. **유연한 세션 선택**:
   - 기본적으로 **가장 최근 세션 1개**를 자동으로 가져옵니다.
   - `-n 2`, `-n 3` 등 최근 N개 세션을 지정하거나, `--session <id>`로 특정 세션을 직접 지정할 수 있습니다.
   - `--list` 옵션으로 프로젝트의 전체 세션 이력을 확인할 수 있습니다.
3. **토큰 최적화 요약**:
   - 방대한 json/바이너리 출력은 줄이고, 사용자 요청 / Claude 최종 응답 / 실행한 도구(Bash, Edit, Task 등) 핵심만 깔끔한 Markdown으로 추출합니다.
4. **Git 작업 상태와 결합**:
   - `git diff`, `git status`와 결합하여 대화 맥락 + 실제 수정된 코드를 완벽하게 동기화합니다.

## 🚀 CLI 빠른 사용법

```bash
# 1. 가장 최근 1개 세션 가져오기 (기본)
python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py

# 2. 세션 목록 보기
python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py --list

# 3. 최근 2개 세션 가져오기
python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py -n 2

# 4. 특정 세션 ID 지정 및 대화 턴 10개 추출
python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py -s 2488dc49 --max-turns 10 --detail
```
