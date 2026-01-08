---
description: Show and sanity-check an OpenSpec change
agent: flow
subtask: true
---

OpenSpec change: $ARGUMENTS

!`openspec show $ARGUMENTS`

Now:
- List unclear requirements or missing acceptance criteria.
- Suggest running: `openspec validate $ARGUMENTS`
- Identify 3–8 deliverable chunks that should become tk tasks.
