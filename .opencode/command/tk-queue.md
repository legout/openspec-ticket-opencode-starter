---
description: Show tk ready/blocked and pick next work item
agent: flow
subtask: true
---

Ready:
!`tk ready`

Blocked:
!`tk blocked`

Pick ONE ready ticket to do next (or the smallest unblock step if none are ready).
Output:
- ticket id
- why it’s next
- 5–10 line implementation plan
- suggested `tk start <id>` command
