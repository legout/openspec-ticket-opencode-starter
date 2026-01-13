---
description: Design and create tk epic + 3–8 chunky task tickets for an OpenSpec change [ulw]
agent: os-tk-orchestrator
permission:
  skill: allow
  bash: allow
  edit: allow
  write: allow
---

# /tk-bootstrap <change-id> "<epic-title>" [--yes]

**Arguments:** $ARGUMENTS

Parse:
- `change-id`: first argument (required)
- `epic-title`: second argument (required, quoted string)
- `--yes`: optional flag to execute (without it, preview only)

---

## EXECUTION MODES

### Preview Mode (default, no `--yes`)
- Analyze the OpenSpec change
- Design the ticket structure (3-8 chunky tickets)
- Output the **exact** `tk create` and `tk dep` commands that would run
- **DO NOT EXECUTE** any `tk create` or `tk dep` commands
- End with: "Re-run with `--yes` to execute these commands."

### Execute Mode (`--yes` flag present)
- Analyze the OpenSpec change
- Design the ticket structure
- **EXECUTE** all `tk create` and `tk dep` commands
- Update `AGENTS.md` OS-TK block if missing
- Show final state with `tk ready`

---

## EXECUTION CONTRACT

### ALLOWED
- `openspec list`, `openspec show <id>`, `openspec validate <id>`
- `tk create`, `tk dep`, `tk query`, `tk show` (only in `--yes` mode for create/dep)
- Summarize and recommend next steps
- Update `AGENTS.md` **only within `<!-- OS-TK-START -->` / `<!-- OS-TK-END -->` markers**

### FORBIDDEN
- `tk start`, `tk close`, `tk add-note` (those are `/tk-start` and `/tk-done`)
- Edit code files (*.py, *.ts, *.js, *.go, etc.)
- Edit config files (*.json, *.yaml, etc.) except AGENTS.md markers
- Archive OpenSpec
- Begin implementation

---

## Step 1: Detect Mode

Check if `--yes` is present in `$ARGUMENTS`:
- If `--yes` is present: **Execute Mode**
- If `--yes` is NOT present: **Preview Mode**

---

## Step 2: Analyze the OpenSpec change

Show the change details:
!`openspec show $1`

Use your **openspec** skill to understand:
- The proposal goals and scope
- The tasks.md deliverables (if exists)
- Acceptance criteria

---

## Step 3: Design the ticket structure

Plan 3–8 chunky tickets that cover:
- Database/model changes
- API/backend logic
- UI/frontend components
- Tests
- Documentation

Each ticket should be a meaningful deliverable, not a single checkbox.

Design the dependencies:
- Identify which tickets block others
- Only add dependencies for real blockers

---

## Step 4: Generate Commands

Create the exact commands that will be run:

**Epic creation:**
```bash
tk create --type epic --external-ref "openspec:<change-id>" --title "<epic-title>"
```

**Task creation (for each task):**
```bash
tk create --type task --parent <epic-id> --title "<task title>" --acceptance "<measurable done criteria>"
```

**Dependencies (if any):**
```bash
tk dep <blocked-id> <blocker-id>
```

---

## Step 5: Preview or Execute

### If Preview Mode (no `--yes`):

Output a summary:
```
## Proposed Ticket Structure

### Epic
- Title: "<epic-title>"
- External ref: openspec:<change-id>

### Tasks (N total)
1. <task-1-title>
   Acceptance: <criteria>
2. <task-2-title>
   Acceptance: <criteria>
...

### Dependencies
- <task-X> blocked by <task-Y>
...

## Commands to Execute

```bash
tk create --type epic --external-ref "openspec:<change-id>" --title "<epic-title>"
# Assume epic ID is <epic-id>

tk create --type task --parent <epic-id> --title "<task-1>" --acceptance "<criteria>"
tk create --type task --parent <epic-id> --title "<task-2>" --acceptance "<criteria>"
...

tk dep <blocked-id> <blocker-id>
...
```

---

**This is a preview. No tickets have been created.**

To execute, re-run with `--yes`:
> `/tk-bootstrap <change-id> "<epic-title>" --yes`
```

**STOP here. Do not execute any tk commands.**

---

### If Execute Mode (`--yes` present):

1. Run the epic creation command and capture the epic ID
2. Run each task creation command with the actual epic ID
3. Run each dependency command with actual task IDs
4. Check if `AGENTS.md` has the OS-TK block; if missing, add it
5. Show final state:
   !`tk ready`

Output a summary:
```
## Tickets Created

- Epic: `<epic-id>` — "<epic-title>"
- Tasks created: N
- Dependencies added: M
- Ready to start: <list of ready ticket IDs>

Next step:
> Run `/tk-queue` to see the full queue, or `/tk-start <ticket-id>` to begin implementation.
```

**STOP here. Do not begin implementation. The user will run `/tk-start` to begin work.**
