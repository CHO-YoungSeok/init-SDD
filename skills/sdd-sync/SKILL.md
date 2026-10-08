---
name: sdd-sync
description: change의 델타 spec을 메인 spec(openspec/specs/)에 병합하는 절차. finalizer가 frontmatter skills:로 주입받아 커밋 전에 따른다. archive는 하지 않는다.
---

# sdd-sync — 델타 spec을 메인 spec에 병합한다

바뀐 것 중 **앞으로도 유효한 규칙**을 메인 spec에 반영한다. 커밋보다 먼저 한다. 손으로 대충 덮어쓰지 말고 아래 순서대로 **병합**한다.

## 1. 경로
- `sdd-openspec status --change "<이름>" --json`에서 `planningHome.root`를 확인한다(store면 store를 가리킨다).
  메인 spec은 `<planningHome.root>/openspec/specs/` 아래다. **경로를 하드코딩하지 마라.**
- 델타 spec 경로는 **오직** `artifactPaths.specs.existingOutputPaths`에서만 가져온다. 다른 산출물에서 추측하지 마라.
  없거나 비어 있으면 "sync할 델타 없음"으로 보고하고 끝낸다(`skip_specs: true`인 change가 정상적으로 이렇게 된다).

## 2. 규칙 스냅샷
```bash
sdd-openspec instructions specs --change "<이름>" --json
```
**이 명령이 실패하거나(종료코드≠0) JSON이 깨지면, 메인 spec을 하나도 쓰지 말고 멈추고 보고한다.**
"규칙 없음"으로 넘기지 마라. 정상 응답에 `rules`가 없으면 그건 정말 규칙이 없는 것이다. `rules` 문장을 파일에 베껴 넣지 마라.

## 3. 델타마다 구획 반영
델타를 읽고 → `<planningHome.root>/openspec/specs/<capability-path>/spec.md`를 읽는다(새 capability면 없다).
**반영 순서: RENAMED → REMOVED → MODIFIED → ADDED** (CLI의 archive 적용과 같은 순서. MODIFIED는 바뀐 새 이름으로 찾는다).

- `## RENAMED Requirements` → FROM:/TO: 대로 이름을 바꾼다. 새 이름으로만 남아야 한다.
- `## REMOVED Requirements` → 메인 spec에서 그 요구사항 블록 전체를 지운다.
- `## MODIFIED Requirements` → **해당 요구사항만** 델타 블록으로 바꾼다. 전체를 통째로 덮어쓰지 마라.
  델타의 MODIFIED 블록은 **살아남는 시나리오까지 통째로** 담고 있다. 델타가 말하지 않은 요구사항은 메인의 순서대로 그대로 둔다.
- `## ADDED Requirements` → 없으면 추가하고, 이미 있으면 델타대로 갱신한다.
- 새 capability: `# <capability> Specification` → `## Purpose`(델타의 Purpose 본문 그대로) → `## Requirements`.

**capability 은퇴:** 그 델타의 **모든 구획을 반영한 뒤** 요구사항이 0개일 때만 판단한다.
REMOVED + ADDED로 요구사항을 갈아 끼우는 델타가 중간에 0개가 된 것은 은퇴가 아니다.
아래가 **전부** 맞을 때만 `spec.md`(그리고 비게 된 디렉터리)를 지운다:
① 이번 실행에서 지운 결과로 요구사항이 0개가 됐다
② 남은 부분이 정상이다 (`## Purpose`가 있다)
③ 원래부터 비어 있던 spec이 아니다 (지운 게 없으면 아무것도 바꾸지 마라)
④ 파일의 다른 모든 줄이 제목/Purpose/Requirements 헤더/요구사항 본문으로 설명된다
⑤ change의 `.openspec.yaml`에 `retire_capabilities: true`가 있다
⑥ 그 `spec.md`가 진짜 specs root 안에 있다 (심링크를 따라 밖의 파일을 지우지 마라)

**하나라도 안 맞으면 메인 spec을 건드리지 말고** 그 capability의 sync를 멈추고 무엇이 막았는지 보고한다.
⑤ `retire_capabilities: true`만 없으면 그걸 콕 집어 보고한다 — 사용자가 그 한 줄만 추가하면 된다.
**빈 `## Requirements` 섹션을 절대 남기지 마라.**

## 4. 메인 spec 형식
- 델타 파일을 그대로 복사하지 마라. 메인에는 `## ADDED/MODIFIED/REMOVED/RENAMED Requirements` 헤더가 **절대 들어가지 않는다.**
  sync 후에는 모든 요구사항이 하나의 `## Requirements` 아래 있다.
- 구조: `# <capability> Specification` → `## Purpose` → `## Requirements` → `### Requirement: …` → `#### Scenario: …`
- Purpose: 메인 spec에 이미 `## Purpose`가 있으면 **그게 정본이다.** 델타의 Purpose로 덮지 마라.
  새 capability일 때만 델타의 Purpose를 옮긴다. 없을 때만 짧은 TBD를 넣고 **TBD를 남겼다고 보고한다.**
  Purpose는 **50자 이상**. `sdd-openspec validate --specs`가 placeholder·too brief를 경고로 잡는다(`exit=0`이어도 보고).
- **예외 — Purpose 갱신 목록:** change의 `design.md`에 "Purpose 갱신" 목록이 있으면, 그 목록에 적힌 capability의
  메인 Purpose를 목록의 문장으로 직접 고치고 고친 사실을 보고한다. 목록이 없으면 기존 capability의 Purpose는 건드리지 않는다.
- sync는 **여러 번 돌려도 같은 결과**여야 한다.

## 5. 재대조와 검증
`existingOutputPaths`의 **모든** 델타에 대해 다시 대조한다:
ADDED 요구사항이 메인에 있다 / MODIFIED가 변경을 담고 나머지 시나리오는 그대로다 / REMOVED가 사라졌다 / RENAMED가 새 이름으로만 있다.
하나라도 안 맞으면 **커밋하지 말고** 무엇이 다른지 보고한다.

```bash
sdd-openspec validate --specs; echo "exit=$?"      # 메인 spec 검증. 이 단계에서는 이게 맞는 명령이다
sdd-openspec validate "<이름>"; echo "exit=$?"      # change(델타) 검증
```
**종료코드로 판정한다.** 성공 `0` / 실패 `1`. 경고만 있으면 `0`이다. 파이프(`| tail` 등)를 붙이지 마라.
둘 중 하나라도 `1`이면 **커밋하지 말고 보고한다.**

## 6. 보고 항목 (finalizer 보고서 "spec 갱신" 절에 적는다)
- 메인 spec 경로마다 ADDED n / MODIFIED n / REMOVED n / RENAMED n
- 재대조 결과 (전부 일치 / 불일치와 내용)
- 두 validate 명령의 출력과 종료코드 그대로
- 남긴 TBD, 고친 Purpose(Purpose 갱신 목록), 은퇴했거나 막힌 capability와 이유

archive는 이 스킬의 일이 아니다 — finalizer 5단계가 사용자 승인 뒤에만 한다.
