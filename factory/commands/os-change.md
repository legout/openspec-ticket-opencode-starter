---
description: View OpenSpec change status (view-only)
argument-hint: [change-id]
---

# /os-change

**Arguments:** $ARGUMENTS

Parse from $ARGUMENTS:
- If empty: list all changes
- If present: show specific change details

## Steps

### If no change-id:

1. List all active changes: `openspec list`
2. Show summary table

### If change-id provided:

1. Show change details: `openspec show <change-id>`
2. Show linked tickets: `tk query '.external_ref == "openspec:<change-id>"'`
3. Summarize progress

## Output Format

```
## Change: <change-id>

### Proposal
<summary from proposal.md>

### Progress
- Tasks: 3/5 complete
- Tickets: 2 ready, 1 in-progress, 2 blocked

### Tickets
- <id>: <title> (status)

### Next Step
Run `/tk-queue` to see ready tickets.
```

## Contract

**ALLOWED:** `openspec list`, `openspec show`, `tk query`
**FORBIDDEN:** Modifying anything - this is view-only

**STOP here. This command is view-only.**
