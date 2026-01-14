---
description: Show tk ready/blocked and suggest next work item(s) (view-only, does NOT start work) [ulw]
agent: os-tk-planner
---

# /tk-queue [next|all|<change-id>]

**Arguments:** $ARGUMENTS

## Mode Detection

- If `$ARGUMENTS` is empty or `next`: Recommend ONE ticket to start
- If `$ARGUMENTS` is `all`: List ALL ready tickets
- If `$ARGUMENTS` matches a change-id pattern: Filter to that OpenSpec change

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

## Step 3: Filter by change (if specified)

If `$ARGUMENTS` looks like a change-id:
1. Find the epic: `tk query '.external_ref == "openspec:<change-id>"'`
2. List tasks under that epic: `tk query '.parent == "<epic-id>"'`
3. Show only those tickets in ready/blocked output

## Step 4: Output

**For `next` or empty:**
Pick ONE ready ticket and show:
- Ticket ID
- Title & brief summary
- Why it's a good choice (e.g., no dependencies, unblocks others)

**For `all`:**
List ALL ready tickets with:
- Ticket ID
- Title
- Brief status note

**For `<change-id>`:**
Show tickets grouped:
- Ready (can start now)
- In progress (worktree active or `tk status == in_progress`)
- Blocked (and what's blocking them)

## Step 5: Suggest next action

**For `next` or empty:**
> Would you like me to start this ticket? Run `/tk-start <ticket-id>`

**For `all`:**
> To start one ticket: `/tk-start <ticket-id>`
> To start multiple in parallel: `/tk-start <id1> <id2> <id3>`

**For `<change-id>`:**
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
