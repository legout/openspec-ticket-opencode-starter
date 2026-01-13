---
description: Show tk ready/blocked and suggest next work item(s) (view-only, does NOT start work) [ulw]
agent: os-tk-planner
---

# /tk-queue [FLAGS]

**Flags:**
- `--next` - Recommend ONE ticket to start (default if no flags provided)
- `--all` - List ALL ready tickets
- `--change <id>` - Filter tickets to a specific OpenSpec change

**Examples:**
- `/tk-queue` or `/tk-queue --next` - Show one recommended ticket
- `/tk-queue --all` - List all ready tickets
- `/tk-queue --change my-feature` - Filter tickets for a specific change

## Mode Detection

Parse flags from `$ARGUMENTS`:
- If no flags or `--next` present: Recommend ONE ticket to start
- If `--all` present: List ALL ready tickets
- If `--change <id>` present: Filter to that OpenSpec change
- Flags can be combined: `/tk-queue --all --change my-feature`

## Step 1: Gather queue status

Ready tickets:
!`tk ready`

Blocked tickets:
!`tk blocked`

## Step 2: Check for active worktrees (if enabled)

Read `.os-tk/config.json` for `useWorktrees`.

If `useWorktrees: true`:
- List active worktrees: `ls -d .worktrees/*/ 2>/dev/null`
- Mark those ticket IDs as "in progress (worktree active)"
- Exclude them from "ready to start" recommendations

## Step 3: Filter by change (if --change flag provided)

If `--change <id>` flag is present:
1. Find the epic: `tk query '.external_ref == "openspec:<change-id>"'`
2. List tasks under that epic: `tk query '.parent == "<epic-id>"'`
3. Show only those tickets in ready/blocked output

## Step 4: Output

**For `--next` or no flags:**
Pick ONE ready ticket and show:
- Ticket ID
- Title & brief summary
- Why it's a good choice (e.g., no dependencies, unblocks others)

**For `--all`:**
List ALL ready tickets with:
- Ticket ID
- Title
- Brief status note

**For `--change <id>`:**
Show tickets grouped:
- Ready (can start now)
- In progress (worktree active or `tk status == in_progress`)
- Blocked (and what's blocking them)

**For combined flags (e.g., `--all --change <id>`):**
Apply both filters - show all tickets for the specified change

## Step 5: Suggest next action

**For `--next` or no flags:**
> Would you like me to start this ticket? Run `/tk-start <ticket-id>`

**For `--all`:**
> To start one ticket: `/tk-start <ticket-id>`
> To start multiple in parallel: `/tk-start <id1> <id2> <id3>`

**For `--change <id>`:**
> Ready tickets for this change can be started with `/tk-start <id>`

---

## COMMAND CONTRACT

### ALLOWED
- `tk ready`, `tk blocked`, `tk show <id>`, `tk query <filter>`
- `openspec list`, `openspec show <id>`
- Reading `.os-tk/config.json`
- Listing `.worktrees/` directory contents
- Summarize, analyze, and recommend

### FORBIDDEN
- `tk start`, `tk close`, `tk add-note`, or any mutating `tk` command
- Edit files, write code, run tests
- Create implementation plans or suggest code changes
- Spawn worker subtasks

### SELF-CHECK (before responding)

Confirm you did NOT:
- [ ] Suggest any implementation steps or code
- [ ] Propose running `tk start`, `tk add-note`, or `tk close`
- [ ] Edit or propose edits to any files
- [ ] Create an implementation plan

If you violated any of the above, remove it and remind the user to run `/tk-start`.

---

**STOP here. This command is view-only. Wait for user to run `/tk-start`.**
