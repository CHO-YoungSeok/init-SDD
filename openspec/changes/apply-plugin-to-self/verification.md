# 통합 검증 (묶음 5)

검증한 날: 2026-10-09. worker(정식 모드)가 돌렸다. openspec은 `./bin/sdd-openspec` 1.14.1, PATH의 `openspec`은 1.12.0이다.
모든 명령은 저장소 루트에서 돌렸고, 성공·실패는 종료코드로 판정했다.

## 5.1~5.9 결과

| 작업 | 결과 | 핵심 출력 |
|---|---|---|
| 5.1 시작 HEAD | 통과 | `6018683184894eed603cc59caf2654919239e83b` / status: `M .claude/CLAUDE.md`, `M README.md`, `M openspec/config.yaml`, `?? openspec/changes/apply-plugin-to-self/` |
| 5.2 묶음 1~4 다시 확인 | 통과 | 아래 "5.2 자세히" |
| 5.3 설치 조각 실측 | 통과 | dry-run exit=0, 실행 전후 status diff rc=0 / 실제 install exit=0 / 구획 want·got diff rc=0 / `init-SDD:begin` 1 / `.claude/agents` 8 |
| 5.4 플러그인 검증 | 통과 | 두 명령 다 exit=0, `✔ Validation passed`. `CLAUDE.md at the plugin root` 경고 0 |
| 5.5 스크립트 | 통과 | `bash -n` install.sh, bin/sdd-init, bin/sdd-openspec, hooks/session-start.sh 모두 rc=0 / 훅 exit=0, `[SDD 점검] 이상 없음` 1건 |
| 5.6 OpenSpec | 통과 | change validate: 1.14.1 exit=0, 1.12.0 exit=0 / status exit=0 / `validate --all --strict` exit=1, `Totals: 14 passed, 9 failed (23 items)`(기준선 9 이하), `✓ spec/agent-instructions/project-context-completeness` |
| 5.7 지침 로드 탐침 | 통과(첫 시도) | exit=0, 답: "검증 명령은 저장소 루트에서 돌리고 종료코드로 판정한다. 테스트 스위트·빌드·CI는 없다." grep 1건. 추가 탐침은 하지 않았다 |
| 5.8 무결성 | 통과 | 리치 마크다운 토큰 0, 코드펜스 줄 수: README 24, .claude/CLAUDE.md 2, design.md 18, proposal.md 0, spec.md 0, tasks.md 0 / `command grep -rl ... '^순서:' .` → `./.claude/CLAUDE.md` 한 줄 |
| 5.9 끝 HEAD | 통과 | `6018683184894eed603cc59caf2654919239e83b`(5.1과 같다) / status는 5.1과 같은 네 줄 |

## 5.2 자세히

- 1.1: `bash -c` 안에서 `ls -d .claude/skills/openspec-* .claude/commands | wc -l` → 0
- 1.2: `git ls-files .claude` → `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/skills/init-sdd/SKILL.md` / .gitignore 두 줄 각 1 / test rc=0
- 2.1: diff --stat가 config.yaml 하나 / `^context: |` 1 / `.claude/agents` 0
- 2.2: context exit=0, Warning 0 / instructions exit=0 / 있어야 할 키 7개 True, 없어야 할 `.claude/agents/*.md`·`실행 코드가 없는` 둘 다 없음
- 2.3: 1.14.1, 1.12.0 둘 다 `Change 'apply-plugin-to-self' is valid`, exit=0
- 3.2: 구획 diff가 `10c10` 한 줄(`(테스트가 있을 때, 동시)` → `(조건부, 동시)`)뿐
- 3.3: 루트 `CLAUDE.md` 없음(rc=1), `.claude/CLAUDE.md` 있음 / 구획 밖 키워드 12개 모두 1 이상 / `^순서:` 1이고 두 줄 글자가 같음 / 구획 안 `analyzer` 줄은 "분석·방안 비교를 요청할 때만" 한 줄 / 토큰 0, 펜스 2
- 4.7: 목차 일치(아래 설명 참고) / `## 빠른 시작`(12행)이 `## 설치`(128행)보다 앞 / `## 설치` 다음 줄 `### 먼저 고른다 — 플러그인인가, 복사 방식인가, 링크 방식인가` / M1 `1c1`·`38c38`·`47c47`·`58c58` / M2 `10a11` / M3 rc=0 / M4는 E3·E4에서 계획한 차이만 / M5는 옛 336~355행 다섯 곳과 끝 빈 줄 하나만
- 4.8: K1~K26과 받아들일 조건 목록의 키워드 모두 1 이상
- 4.9: 금지 키워드 전부 0 / `.claude/agents` 줄은 215·239·255·256·293·304행(기존 설치 방식 하위 절)과 343행(커스터마이즈 "복사·링크 방식이면")뿐 / regression-verifier 조건은 8~9행과 99행에서 세 조건을 다 적고 `orchestra`를 가리킨다 / K24 `모델 등급` 0 / 토큰 0, 펜스 24

## 4.7 목차 diff 두 곳

design.md 236~264행의 목차와 README의 제목 줄을 diff하면 두 곳이 다르게 나온다. 둘 다 실제 차이는 아니다.

1. `2d1 (굵은 한 줄 + 소개 한 문단)`: design 쪽 목차에 있는 설명 줄이고, 제목이 아니다.
2. `22a22,23`: README 251·254행의 `# OpenSpec 초기화 ...`, `# 에이전트와 지휘 스킬, ...`이다. "방법 2 — 손으로" 코드블록 안의 셸 주석이 제목 grep에 잡혔다.

진짜 제목의 순서와 글자는 목차와 같다.

## 원본 출력 위치 (scratchpad, 세션이 끝나면 사라질 수 있다)

`/private/tmp/claude-501/-Users-0stone-1004-work-space-init-SDD/5584cf33-ec34-4527-843b-f700b5292cd5/scratchpad/` 아래:

- `v5.RkqJPe/`: ctx.out, ins.json(2.2), b_old.txt·b_new.txt(3.2), outside.txt(3.3), toc_*.txt(4.7), m.sh·m.out(M1~M5), pv1.out·pv2.out(5.4), hook.out(5.5), all.out(5.6), probe.out(5.7)
- `proj.eIfLLU/`: 5.3 임시 프로젝트
- `out.EqFbr4/`: 5.3 결과(dry.out, inst.out, st_before·st_after.txt, want.txt, got.txt)
