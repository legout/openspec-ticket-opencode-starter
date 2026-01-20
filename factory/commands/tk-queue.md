---
description: Show tk ready/blocked and suggest next work (queue management)
argument-hint: [--next|--all|--change <id>]
---

# /tk-queue

**Arguments:** $ARGUMENTS

Parse from $ARGUMENTS (flags take precedence; positional supported for backward compatibility):
- `--next`: Recommend ONE ticket (default)
- `--all`: List ALL ready tickets
- `--change <id>`: Filter to specific OpenSpec change
- Positional fallback: `next|all|<change-id>`

## Steps

1. **Gather queue status**:
   - Ready tickets: `tk ready`
   - Blocked tickets: `tk blocked`

2. **Check for active worktrees** (exclude from recommendations)

3. **Filter by change** if `--change` flag present

4. **Generate missing file predictions** (`files-modify`, `files-create`) and update ticket frontmatter (edit `.tickets/<id>.md`)
   - Use the **tk-frontmatter** skill for edits.

5. **Detect overlaps** and add dependencies with `tk dep` to serialize conflicts

6. **Output recommendations**

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

**ALLOWED:** `tk ready`, `tk blocked`, `tk show`, `tk query`, `tk dep`
**ALLOWED (metadata only):** update ticket frontmatter fields `files-modify` / `files-create`
**FORBIDDEN:** `tk start`, `tk close`, editing code files

**STOP here. This command does not start work.**
