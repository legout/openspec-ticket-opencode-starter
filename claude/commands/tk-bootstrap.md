---
description: Design and create tk epic + 3-8 chunky task tickets
argument-hint: <change-id> "<epic-title>" [--yes]
allowed-tools: Bash(tk:*), Bash(openspec:*), Read, Grep, Glob, Edit, Write
---

# /tk-bootstrap $1 $2 [--yes]

Parse arguments:
- `$1`: change-id (required)
- `$2`: epic-title (required, quoted string)
- `--yes`: execute (without it, preview only)

## Current Context

OpenSpec change details:
!`openspec show $1`

## Execution Modes

**Preview Mode (no `--yes`):**
- Design the ticket structure (3-8 chunky tickets)
- Output exact `tk create` and `tk dep` commands
- DO NOT EXECUTE any commands
- End with: "Re-run with `--yes` to execute"

**Execute Mode (`--yes` present):**
- Design and EXECUTE all commands
- Show final state with `tk ready`

## Ticket Creation Pattern

```bash
# Create epic
tk create --type epic --external-ref "openspec:$1" --title "$2"

# Create tasks (capture epic ID first)
tk create --type task --parent <epic-id> --title "<task>" --acceptance "<criteria>"
# Include frontmatter fields:
# files-modify: [path1, path2]
# files-create: [path3]

# Add dependencies
tk dep <blocked-id> <blocker-id>
```

If `tk create` cannot set frontmatter, edit the created ticket file in `.tickets/<id>.md` to add `files-modify` / `files-create`.
Use the **tk-frontmatter** skill when editing ticket frontmatter.

## Ticket Design Guidelines

Create 3-8 chunky tickets covering:
| Layer | Example |
|-------|---------|
| Data | "Database schema for User entity" |
| Backend | "User CRUD API endpoints" |
| Frontend | "User management UI" |
| Tests | "E2E tests for user workflows" |
| Docs | "API documentation" |

## File Predictions

For each task, predict likely `files-modify` and `files-create` values. Use conservative guesses to avoid conflicts.

## Output Format

```
## Tickets Created

### Epic
- ID: <epic-id>
- Title: $2
- External ref: openspec:$1

### Tasks
1. <task-id>: <title> (ready)
2. <task-id>: <title> (blocked by #1)

### Next Step
Run `/tk-queue` or `/tk-start <id>` to begin.
```

## Contract

**ALLOWED:** `openspec show`, `tk create`, `tk dep`, `tk query`
**FORBIDDEN:** `tk start`, `tk close`, editing code files
