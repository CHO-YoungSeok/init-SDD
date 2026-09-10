---
name: claude-handoff
description: >-
  Claude Code에서 작업하던 맥락(세션 대화 로그, 마지막 상태, 실행 도구 내역)과 현재 작업 트리의 Git 변경 사항을 로컬에서 가져와 Antigravity(agy)로 이어서 작업을 진행할 때 사용합니다. "클로드 작업 이어줘", "claude 에서 하던거 이어서 해줘", "claude handoff", "세션 가져와서 계속해" 등의 요청에 활성화됩니다.
---

# Claude Code -> Antigravity Session Handoff Skill

Claude Code 터미널에서 작업하다가 한도 도달 또는 모델 전환으로 인해 Antigravity(agy)로 넘어온 경우, 이전 대화 맥락과 작업 상태를 신속하게 인계받아 작업을 끊김 없이 이어가는 스킬입니다.

---

## 🛠️ Step 1: Claude Code 최근 세션 로그 파싱

스킬에 내장된 `parse_claude_session.py` 스크립트를 실행하여 직전 Claude Code 대화 맥락과 실행 도구 내역을 확인합니다.

### 1) 기본 실행 (가장 최근 1개 세션 가져오기)
```bash
python3 .agents/skills/claude-handoff/scripts/parse_claude_session.py
# 또는 글로벌 경로:
# python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py
```

### 2) 사용자가 세션 개수나 특정 세션을 지정한 경우
- **최근 N개 세션 확인**:
  ```bash
  python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py -n 2
  ```
- **세션 목록 전체 조회**:
  ```bash
  python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py --list
  ```
- **특정 세션 ID 직접 지정**:
  ```bash
  python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py --session <SESSION_ID_OR_PREFIX>
  ```
- **대화 턴 수 늘려서 상세 보기**:
  ```bash
  python3 ~/.gemini/antigravity-cli/skills/claude-handoff/scripts/parse_claude_session.py --max-turns 10 --detail
  ```

---

## 🔍 Step 2: 작업 트리 및 Git 상태 점검

Claude Code가 로컬 파일시스템에 남겨둔 수정 사항과 브랜치 상태를 확인합니다.

1. **현재 브랜치 및 변경 파일 확인**:
   ```bash
   git status
   ```
2. **커밋되지 않은 변경 사항(Uncommitted changes) 확인**:
   ```bash
   git diff
   ```
3. **최근 커밋 이력 확인**:
   ```bash
   git log -n 3 --oneline
   ```

---

## 📋 Step 3: Handoff 종합 브리핑 작성

Claude Code의 대화 로그와 Git 작업 트리를 종합하여 사용자에게 다음 형식으로 브리핑합니다:

1. **인계받은 세션 정보**:
   - 세션 ID, 브랜치, 마지막 작업 시각
2. **완료된 작업 (Done)**:
   - Claude Code가 완료한 태스크 및 커밋 내역
3. **중단된 지점 / 진행 중이던 작업 (In Progress)**:
   - 마지막 사용자 프롬프트와 Claude의 마지막 응답 상태
   - 미해결된 에러 또는 관문 교착 상태
4. **Antigravity가 즉시 수행할 작업 (Next Steps)**:
   - 구체적인 다음 실행 계획

---

## 🚀 Step 4: agy 작업 개시

브리핑한 Next Steps를 바탕으로 바로 수정, 테스트, 리뷰 또는 후속 작업을 착수합니다.
필요 시 서브에이전트(`research`, `self` 등)를 지휘(Orchestrate)하여 병렬로 작업을 이어갑니다.
