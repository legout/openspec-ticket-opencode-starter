---
description: Show details of an OpenSpec change and suggest ticket chunks [ulw]
agent: os-tk-agent
---

OpenSpec change: $ARGUMENTS

!`openspec show $ARGUMENTS`

Now:
- List unclear requirements or missing acceptance criteria.
- Suggest running: `openspec validate $ARGUMENTS`
- Identify 3–8 deliverable chunks that should become tk tasks.

STOP here. Wait for user to run `/tk-bootstrap` or refine the spec.
