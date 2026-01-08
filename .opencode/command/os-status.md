---
description: Show active OpenSpec changes and next step
agent: flow
subtask: true
---

Active OpenSpec changes:
!`openspec list`

If there are changes, pick the most relevant and:
1) show it (`openspec show <change>`)
2) say whether it’s ready to apply (needs validate? missing acceptance criteria?)
If there are no changes, suggest a change-id and the exact next step to create a proposal.
