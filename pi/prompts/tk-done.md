---
description: Close ticket, sync OpenSpec tasks, auto-archive, merge to main, and push
---

# /tk-done <ticket-id> [change-id]

**Arguments:** $ARGUMENTS

Parse:
- `ticket-id`: first argument ($1)
- `change-id`: second argument ($2, optional)

## Step 1: Identify the OpenSpec change AND epic ID

If `change-id` is not provided:
1. Get the ticket: `tk show $1` → extract `parent` field as `epic-id`
2. Find the parent epic: `tk show <epic-id>`
3. Extract `external_ref` (format: `openspec:<change-id>`)
4. Save both `epic-id` and `change-id` for later steps

## Step 2: Load config

Read `.os-tk/config.json` for:
- `useWorktrees` (boolean)
- `mainBranch` (default: "main")
- `autoPush` (boolean)
- `unsafe.commitStrategy` (prompt|all|fail)

## Step 3: Add note and close ticket

```bash
tk add-note $1 "Implementation complete, closing via /tk-done"
tk close $1
```

## Step 4: Sync OpenSpec tasks.md

Find the matching checkbox in `openspec/changes/<change-id>/tasks.md`:
- Match by exact ticket title
- Flip `[ ]` to `[x]`

## Step 5: Check if all tasks are complete

Query tickets under the epic:
```bash
tk query ".parent == \"<epic-id>\" and .status != \"closed\""
```

If result is empty (all tasks closed):
- Archive the OpenSpec change: `openspec archive <change-id> --yes`
- Print: "All tasks complete. OpenSpec change archived."

## Step 6: Commit changes

**If `useWorktrees: true` (safe mode):**
- Operating in worktree: `.worktrees/$1/`
- Rebase onto latest main: `git fetch origin && git rebase origin/<mainBranch>`
- Stage and commit: `git add -A && git commit -m "$1: <ticket-title>"`

**If `useWorktrees: false` (simple mode):**
- Stage and commit: `git add -A && git commit -m "$1: <ticket-title>"`

## Step 7: Merge to main

1. Switch to main branch
2. Merge the ticket branch or current changes
3. FF merge if possible

## Step 8: Push to remote

If `autoPush: true`:
```bash
git push origin <mainBranch>
```

## Step 9: Cleanup (worktree mode only)

If `useWorktrees: true`:
```bash
git worktree remove .worktrees/$1
git branch -d ticket/$1
```

## Output

Summarize results.
