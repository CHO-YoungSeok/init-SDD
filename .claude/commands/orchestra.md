---
description: 서브 에이전트 파이프라인(preparer→analyzer→designer→worker→reviewer→finalizer)으로 작업을 처리한다
---

`orchestra` 스킬을 불러서 그 지침대로 이 요청을 처리해라.

요청: $ARGUMENTS

인자가 비어 있으면, 지금까지의 대화 맥락에서 처리할 일을 찾아라. 그것도 없으면 사용자에게 무엇을 할지 물어라.
