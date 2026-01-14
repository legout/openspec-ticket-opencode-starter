---
description: Show tk ready/blocked and suggest next work (view-only)
argument-hint: [--next|--all|--change <id>]
allowed-tools: Bash(tk:*), Bash(openspec:*), Read
---

# /tk-queue $@

Parse flags:
- `--next`: Recommend ONE ticket (default)
- `--all`: List ALL ready tickets
- `--change <id>`: Filter to specific OpenSpec change

## Current Context

Ready tickets:
!`tk ready`

Blocked tickets:
!`tk blocked`

Active worktrees:
!`ls -d .worktrees/*/ 2>/dev/null || echo "No active worktrees"`

## Steps

1. **Gather queue status**
2. **Check for active worktrees** (exclude from recommendations)
3. **Filter by change** if `--change` flag
4. **Output recommendations**

## Output Format

**For `--next` (default):**
```
## Recommended Ticket

- ID: <ticket-id>
- Title: <title>
- Rationale: <why this one>

### Next Step
Run `/tk-start <ticket-id>` to begin.
```

**For `--all`:**
```
## Ready Tickets

| ID | Title | Status |
|----|-------|--------|
| <id> | <title> | Ready |

### Next Step
Run `/tk-start <id>` or `/tk-start <id1> <id2> --parallel 2`
```

## Contract

**ALLOWED:** `tk ready`, `tk blocked`, `tk show`, `tk query`
**FORBIDDEN:** `tk start`, `tk close`, editing files

**STOP here. This command is view-only. Wait for `/tk-start`.**
