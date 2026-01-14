---
description: Design and create tk epic + 3-8 chunky task tickets
argument-hint: <change-id> "<epic-title>" [--yes]
---

# /tk-bootstrap

**Arguments:** $ARGUMENTS

Parse from $ARGUMENTS:
- `change-id`: first word (required)
- `epic-title`: quoted string (required)
- `--yes`: execute (without it, preview only)

## Steps

1. **Show change details**: Run `openspec show <change-id>`
2. **Design 3-8 chunky tickets** covering:
   - Database/model changes
   - API/backend logic
   - UI/frontend components
   - Tests
   - Documentation
3. **Preview or Execute** based on `--yes` flag

## Ticket Creation Pattern

```bash
# Create epic
tk create --type epic --external-ref "openspec:<change-id>" --title "<epic-title>"

# Create tasks
tk create --type task --parent <epic-id> --title "<task>" --acceptance "<criteria>"

# Add dependencies
tk dep <blocked-id> <blocker-id>
```

## Output Format

```
## Tickets Created

### Epic
- ID: <epic-id>
- Title: <epic-title>
- External ref: openspec:<change-id>

### Tasks
1. <task-id>: <title> (ready)
2. <task-id>: <title> (blocked by #1)

### Next Step
Run `/tk-queue` or `/tk-start <id>` to begin.
```

## Contract

**ALLOWED:** `openspec show`, `tk create`, `tk dep`, `tk query`
**FORBIDDEN:** `tk start`, `tk close`, editing code files
