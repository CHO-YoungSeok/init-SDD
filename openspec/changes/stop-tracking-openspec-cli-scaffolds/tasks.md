<!--
채택안: 없음 (analyzer 생략 경로 — 원인/범위가 명확한 정리 작업). 기준은 proposal.md의
"받아들일 조건"이다. decision.md는 만들지 않았다 (analyzer 생략 경로).

핵심 결정 (자세한 내용은 design.md):
- .gitignore는 12개를 하나씩 나열하지 않고 디렉터리 패턴 2줄로 잡는다
  (`.claude/skills/openspec-*/`, `.claude/commands/opsx/`).
- git rm --cached는 12개 경로를 명시적으로 나열해서 실행한다 (글롭·-r 금지, --cached 필수).
- README.md:85 경고 문구는 "이 저장소에는 없다"가 아니라 "git으로 커밋돼 있지 않다.
  디스크엔 남아 있을 수 있다"로 고친다 — 파이프라인이 여전히 디스크 파일을 읽는다는
  사실과 모순되지 않게.
- README.md:267~269의 비슷한 문구는 이미 정확하므로 고치지 않는다 (확인만 한다).
-->

## 1. 기준선 확인 (변경 전)

- [x] 1.1 `git status -s`와 `git status --ignored -s` 출력을 기록해 둔다 (이번 변경으로
      바뀌는 부분과 원래부터 있던 변경 — 등급 수정 7개, `.agents/scripts/`,
      `.claude/agents/agy.md`, 이 change 산출물 — 을 구분하기 위한 기준선).
- [x] 1.2 `openspec validate --all --strict; echo "exit=$?"` 를 실행해 종료코드를 기록한다
      (메인 spec 15개가 지금도 통과하는지 — 이번 변경과 무관한 실패를 나중에 이번 변경
      탓으로 잘못 돌리지 않기 위한 기준선).
- [x] 1.3 `git ls-files .claude/skills/ .claude/commands/opsx/ | grep -E
      '^\.claude/(skills/openspec-|commands/opsx/)'` 로 지금 추적 중인 12개 파일 목록을
      다시 확인한다. 정확히 12개(스킬 6 + 명령 6)여야 한다.

## 2. git 추적 해제

- [x] 2.1 **`--cached`를 반드시 포함해서** 아래 12개 경로에 `git rm --cached`를 실행한다.
      **`--cached`를 빠뜨리면 디스크 파일이 삭제된다 — 절대 빠뜨리지 마라.**
      ```bash
      git rm --cached \
        .claude/skills/openspec-apply-change/SKILL.md \
        .claude/skills/openspec-archive-change/SKILL.md \
        .claude/skills/openspec-explore/SKILL.md \
        .claude/skills/openspec-propose/SKILL.md \
        .claude/skills/openspec-sync-specs/SKILL.md \
        .claude/skills/openspec-update-change/SKILL.md \
        .claude/commands/opsx/apply.md \
        .claude/commands/opsx/archive.md \
        .claude/commands/opsx/explore.md \
        .claude/commands/opsx/propose.md \
        .claude/commands/opsx/sync.md \
        .claude/commands/opsx/update.md
      ```
      완료 기준: 명령이 오류 없이 끝나고, `git status -s`에서 이 12개가 `D `(스테이지된
      삭제)로 보인다.
- [x] 2.2 디스크에 파일이 실제로 남아 있는지 확인한다 (파일 12개 전부, 예시로 최소
      아래 둘은 반드시 확인):
      ```bash
      ls -la .claude/skills/openspec-explore/SKILL.md
      ls -la .claude/commands/opsx/apply.md
      ```
      완료 기준: 12개 전부 존재하고 내용이 비어 있지 않다(0바이트가 아니다).
      **만약 하나라도 사라졌다면** `git checkout HEAD -- <경로>`로 즉시 복구하고, 2.1로
      돌아가 `--cached`가 빠진 원인을 고친 뒤 다시 실행한다.

## 3. .gitignore 갱신 + 패턴 검증

- [x] 3.1 `.gitignore` 끝에 아래 구획을 추가한다 (기존 두 구획 뒤에, 빈 줄로 구분):
      ```gitignore

      # openspec init 이 CLI 버전에 맞춰 다시 만들어 주는 스캐폴드 (버전 스냅샷을 고정하지 않는다)
      .claude/skills/openspec-*/
      .claude/commands/opsx/
      ```
      완료 기준: `git diff .gitignore`에 이 3줄(+빈 줄)만 추가로 보인다.
- [x] 3.2 `git status --ignored -s`를 실행해 새로 `!!`(ignored)로 잡히는 경로가 정확히
      `.claude/skills/openspec-apply-change/`, `-archive-change/`, `-explore/`,
      `-propose/`, `-sync-specs/`, `-update-change/`, `.claude/commands/opsx/` 뿐인지
      확인한다. 완료 기준: 이 7개 경로 외에 다른 새 `!!` 항목이 없다(`orchestra`,
      `agent-model-tier`, `init-sdd`, `openspec/changes/**`가 걸리면 실패).
- [x] 3.3 `git status -s`를 실행해 12개 파일이 더는 `D`나 `??`로 보이지 않는지 확인한다
      (완전히 사라져야 정상 — 추적 해제됐고 gitignore가 다시 걸러낸다).

## 4. README.md 경고 문구 정리

- [x] 4.1 `README.md` 85~87번째 줄의 인용문을 아래로 교체한다 (Edit로 부분 수정,
      전체 Write 금지):
      ```markdown
      > **`.claude/skills/openspec-*` 와 `.claude/commands/opsx/` 는 이 저장소에 git으로
      > 커밋돼 있지 않다.** `openspec init`이 네 CLI 버전에 맞춰 만들어 주는 파일이라 추적하지
      > 않는다(`.gitignore` 참고). 로컬 디스크에는 남아 있을 수 있지만 그건 이 저장소를 마지막에
      > `openspec init`한 사람의 CLI 버전에 맞춰진 것일 뿐이다. 그대로 복사하지 말고, 대상
      > 프로젝트에서 `openspec init --tools claude`를 직접 돌려서 네 CLI 버전에 맞는 걸 새로
      > 만들어라.
      ```
      완료 기준: `grep -n "1.12.0 스냅샷" README.md`가 더는 안 걸린다.
- [x] 4.2 `grep -rniE "복사하지|do not copy|don't copy|실수로 복사" README.md docs/`로
      비슷한 경고 문구가 README.md 267~269번째 줄 외에 더 있는지 재확인한다 (preparer는
      "1곳"이라 했지만 designer가 재확인한 결과 267~269번째 줄에도 하나 더 있다 — 이건
      "이 저장소의 사본은 openspec init이 만든 것이니 대상 프로젝트에서 복사하지 말고
      직접 만들어라"는 내용으로, 이번 변경 후에도 그대로 참이라 **고치지 않는다.**
      완료 기준: grep 결과가 85번째 줄(방금 고친 새 문구)과 267~269번째 줄(기존 그대로)
      외에 새로운 곳을 찾으면, 그 문구도 "git에 커밋돼 있지 않다" 취지로 맞는지 판단해서
      필요하면 고치고 tasks에 없던 항목이라는 점을 worker 보고에 남긴다.
- [x] 4.3 `docs/example-run.md`, `docs/verification-2026-09-08.md`, `docs/final-report.md`
      의 "1.12.0" 언급은 과거 실행/검증 기록이라 손대지 않는다는 것을 확인만 한다
      (`grep -n "1.12.0" docs/*.md`로 위치 재확인, 내용은 편집하지 않는다).

## 5. install.sh 영향 없음 확인

- [x] 5.1 `bash -n install.sh`로 문법 오류가 없는지 확인한다 (완료 기준: 종료코드 0,
      출력 없음).
- [x] 5.2 `mktemp -d`로 임시 디렉터리를 만들고, 그 안에서 `git init && git commit
      --allow-empty -m init`으로 최소 git 저장소를 만든 뒤, 거기서
      `bash <이 저장소 절대경로>/install.sh --dry-run`을 실행한다. **`mktemp -d`로 만든
      디렉터리만 쓰고, 이 저장소나 `~/work-space/`는 절대 건드리지 마라.**
      완료 기준: "2. OpenSpec 초기화"와 "3. 에이전트와 지휘 스킬 복사" 단계가 오류 없이
      끝난다(실제로 파일을 만들진 않아도 `--dry-run` 로그에 `openspec init --tools claude
      --no-animation`과 agents/orchestra/agent-model-tier 복사 예정 로그가 찍힌다).
      이번 변경이 gitignore한 12개 파일에 대한 `cp` 로그가 없어야 정상이다(원래도 없었다 —
      회귀가 아니라 기존 동작 재확인).
- [x] 5.3 임시 디렉터리를 정리한다(`rm -rf <mktemp로 만든 경로>`).

## 6. 전체 검증

- [x] 6.1 `openspec validate --all --strict; echo "exit=$?"`를 다시 실행해 1.2에서 기록한
      기준선과 같은 결과(같은 종료코드, 실패했다면 같은 실패 목록)인지 비교한다.
      완료 기준: 기준선 대비 새로 깨진 것이 없다.
- [x] 6.2 `openspec validate "stop-tracking-openspec-cli-scaffolds" --strict;
      echo "exit=$?"` 를 실행해 이 change 자체가 통과하는지 확인한다 (완료 기준: exit=0).
- [x] 6.3 `openspec status --change "stop-tracking-openspec-cli-scaffolds" --json
      >/dev/null; echo "metadata exit=$?"` 를 실행해 `.openspec.yaml`이 멀쩡한지 확인한다
      (완료 기준: exit=0). 이번 change는 `.openspec.yaml`을 직접 고치지 않으므로 깨질
      일은 없지만, 다른 파일 수정이 실수로 이 파일을 건드리지 않았는지 마지막으로
      확인하는 차원이다.
- [x] 6.4 `git status -s`를 최종적으로 실행해, 바뀐 내용이 다음 범위 안에만 있는지
      확인한다: `.gitignore`(수정), `README.md`(수정), 12개 파일의 추적 해제(더 이상
      `git status`에 안 보임), `openspec/changes/stop-tracking-openspec-cli-scaffolds/`
      (`??`, 정상 — 이 change의 산출물). 기준선(1.1)에 있던 관련 없는 항목들(등급 수정
      7개, `.agents/scripts/`, `.claude/agents/agy.md`)은 손대지 않았어야 한다.
