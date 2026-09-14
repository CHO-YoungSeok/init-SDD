## Why

`.claude/skills/openspec-*` 6개와 `.claude/commands/opsx/` 6개(합 12개 파일, 2,334줄)는 `openspec init --tools claude`가 다시 만들어 주는 CLI 스캐폴드다. 저장소에 특정 버전 스냅샷만 들어 있고, 각 사용자의 CLI 버전에 맞는 것을 `openspec init`이 깔아 준다. git 추적에서 빼면 저장소 크기가 줄고, 누군가가 이 파일들을 실수로 복사할 위험을 없앤다. 동시에 `.gitignore`로 다시 올라오는 것을 방지하고, README 경고도 "지금 이 저장소에는 없다. openspec init이 깔아 준다"는 취지로 현실을 반영하게 된다.

## What Changes

1. `git rm --cached`로 12개 파일을 git 추적에서 제거 (디스크의 실제 파일은 그대로 둔다)
2. `.gitignore`에 `.claude/skills/openspec-*/`과 `.claude/commands/opsx/` 패턴 추가
3. `README.md` 85줄 경고 문구를 "이 저장소에는 애초에 없다. `openspec init`이 깔아 준다" 취지로 수정
4. `.openspec.yaml`에 `skip_specs: true` 마커 설정 (요구사항 변화가 없는 순수 정리)

## Capabilities

### New Capabilities
(없음 - 동작 변화 없음)

### Modified Capabilities
(없음 - 요구사항 변화 없음. 순수 정리)

## Impact

- 저장소 크기 감소 (2,334줄의 CLI 스캐폴드가 추적에서 제거)
- 설치 시 사용자의 OpenSpec CLI 버전에 정확히 맞는 파일이 깔린다 (버전 미스매치 가능성 없음)
- 파이프라인 에이전트(designer, reviewer, worker 등)는 여전히 이 파일들을 읽을 수 있다 (디스크에 있음)
- `README.md`의 경고가 명확해진다: "복사하지 마라 (이미 없다)"

---

**받아들일 조건**:
- [ ] 12개 파일이 `git status`에서 `D` (deleted from tracking)로 표시됨
- [ ] `.gitignore` 추가 후 `git status -s`가 깨끗함
- [ ] README.md 경고가 적절히 수정됨
- [ ] `openspec validate` 통과 (skip_specs 마커로 zero-delta 검증 우회)
- [ ] 파이프라인이 여전히 이 파일들을 정상 읽음 (파일이 디스크에 있으므로)
