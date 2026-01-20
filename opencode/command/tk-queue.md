---
description: Show tk ready/blocked and suggest next work item(s) (queue management, does NOT start work) [ulw]
agent: os-tk-orchestrator
---

# /tk-queue [--next|--all|--change <change-id>]

**Arguments:** $ARGUMENTS

## Mode Detection

- Flags take precedence:
  - `--next` (or no args): Recommend ONE ticket to start
  - `--all`: List ALL ready tickets
  - `--change <id>`: Filter to that OpenSpec change
- Backward-compatibility:
  - `next|all|<change-id>` positional values still work

## Step 1: Gather queue status

Ready tickets:
!`tk ready`

Blocked tickets:
!`tk blocked`

## Step 2: Check for active worktrees (if enabled)

Read `.os-tk/config.json` (fallback `config.json`) for `useWorktrees`.

If `useWorktrees: true`:
- List active worktrees: `ls -d .worktrees/*/ 2>/dev/null`
- Mark those ticket IDs as "in progress (worktree active)"
- Exclude them from "ready to start" recommendations

## Step 3: Filter by change (if specified)

If `--change <id>` is provided (or positional change-id is used):
1. Find the epic: `tk query '.external_ref == "openspec:<change-id>"'`
2. List tasks under that epic: `tk query '.parent == "<epic-id>"'`
3. Show only those tickets in ready/blocked output

## Step 4: File-Aware Dependency Management

Ensure each ready ticket has file predictions:
- If a ticket is missing `files-modify` and `files-create`, generate predictions and update the ticket frontmatter.
- Use conservative predictions: list likely touched files or folders if uncertain.
- To update frontmatter, locate the ticket file in `.tickets/` (match by ID) and edit the YAML header.
- Use the **tk-frontmatter** skill when editing `.tickets/*.md`.

Detect overlaps among ready tickets:
- If two ready tickets overlap on any predicted file:
  - Create a hard dependency with `tk dep <blocked> <blocker>`
  - Prefer earlier ID or higher priority as the blocker
  - Recompute the ready list after adding dependencies

Also exclude tickets that conflict with **in-progress** worktrees when recommending `--next`.

## Step 5: Output

**For `--next` or empty:**
Pick ONE ready ticket and show:
- Ticket ID
- Title & brief summary
- Why it's a good choice (e.g., no dependencies, unblocks others)

**For `--all`:**
List ALL ready tickets with:
- Ticket ID
- Title
- Brief status note

**For `<change-id>`:**
Show tickets grouped:
- Ready (can start now)
- In progress (worktree active or `tk status == in_progress`)
- Blocked (and what's blocking them)

## Step 6: Suggest next action

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
- `tk ready`, `tk blocked`, `tk show <id>`, `tk query <filter>`, `tk dep`
- `openspec list`, `openspec show <id>`
- Reading `.os-tk/config.json` (fallback to `config.json`)
- Listing `.worktrees/` directory contents
- Summarize, analyze, and recommend
- Edit ticket frontmatter to add `files-modify` / `files-create`

### FORBIDDEN
- `tk start`, `tk close`, `tk add-note`
- Edit code files, write code, run tests
- Create implementation plans or suggest code changes
- Spawn worker subtasks

### SELF-CHECK (before responding)

Confirm you did NOT:
- [ ] Suggest any implementation steps or code
- [ ] Propose running `tk start`, `tk add-note`, or `tk close`
- [ ] Edit or propose edits to code files
- [ ] Create an implementation plan

If you violated any of the above, remove it and remind the user to run `/tk-start`.

---

**STOP here. This command does not start work. Wait for user to run `/tk-start`.**
