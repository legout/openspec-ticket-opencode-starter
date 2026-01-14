---
description: Close ticket, sync OpenSpec tasks, auto-archive, merge to main, and push [ulw]
agent: os-tk-worker
---

# /tk-done <ticket-id> [change-id]

**Arguments:** $ARGUMENTS

Parse:
- `ticket-id`: first argument (required)
- `change-id`: second argument (optional; will be auto-detected from epic's external_ref)

## Step 1: Identify the OpenSpec change AND epic ID

If `change-id` is not provided:
1. Get the ticket: `tk show <ticket-id>` → extract `parent` field as `epic-id`
2. Find the parent epic: `tk show <epic-id>`
3. Extract `external_ref` (format: `openspec:<change-id>`)
4. Save both `epic-id` and `change-id` for later steps

If no change-id can be found, ask the user to provide it.

## Step 2: Load config

Read `.os-tk/config.json` for:
- `useWorktrees` (boolean)
- `mainBranch` (default: "main")
- `autoPush` (boolean)
- `unsafe.commitStrategy` (prompt|all|fail)

## Step 3: Add note and close ticket

```bash
tk add-note <ticket-id> "Implementation complete, closing via /tk-done"
tk close <ticket-id>
```

## Step 4: Sync OpenSpec tasks.md

Find the matching checkbox in `openspec/changes/<change-id>/tasks.md`:
- Match by exact ticket title (as created by `/tk-bootstrap`)
- Flip `[ ]` to `[x]`

If no exact match is found, warn and continue.

## Step 5: Check if all tasks are complete

Query tickets under the epic:
```bash
tk query '.parent == "<epic-id>" and .status != "closed"'
```

If result is empty (all tasks closed):
- Archive the OpenSpec change: `openspec archive <change-id> --yes`
- Print: "All tasks complete. OpenSpec change archived."

## Step 6: Commit changes

**If `useWorktrees: true` (safe mode):**
- Operating in worktree: `.worktrees/<ticket-id>/`
- Rebase onto latest main: `git fetch origin && git rebase origin/<mainBranch>`
- If conflicts:
  - Attempt auto-resolve for trivial cases (accept theirs for formatting, ours for logic)
  - If not straightforward: STOP and ask user to resolve manually
- Stage and commit: `git add -A && git commit -m "<ticket-id>: <ticket-title>"`

**If `useWorktrees: false` (simple mode):**
- Check `unsafe.commitStrategy`:
  - `prompt`: Ask user how to proceed if working tree has unrelated changes
  - `all`: Stage and commit everything with ticket ID prefix
  - `fail`: Refuse if working tree has changes outside ticket scope
- Stage and commit: `git add -A && git commit -m "<ticket-id>: <ticket-title>"`

## Step 7: Merge to main

**If `useWorktrees: true`:**
1. Switch to main: `git checkout <mainBranch>` (in main worktree or from worktree context)
2. Fast-forward merge: `git merge --ff-only ticket/<ticket-id>`
3. If fast-forward fails (diverged): 
   - `git merge ticket/<ticket-id>` with commit message
   - If conflicts: STOP and ask user

**If `useWorktrees: false`:**
- If already on main: skip merge step
- Otherwise: merge current branch into main

## Step 8: Push to remote

If `autoPush: true` and remote exists:
```bash
git push origin <mainBranch>
```

If push fails (rejected), warn user and suggest `git pull --rebase` first.

## Step 9: Cleanup (worktree mode only)

If `useWorktrees: true`:
```bash
git worktree remove .worktrees/<ticket-id>
git branch -d ticket/<ticket-id>
```

## Output

Summarize:
- Ticket closed: `<ticket-id>`
- OpenSpec tasks.md synced: Yes/No
- OpenSpec archived: Yes/No (if all complete)
- Committed: `<commit-hash>`
- Merged to: `<mainBranch>`
- Pushed: Yes/No

---

## EXECUTION CONTRACT

This command **DOES** mutate state:
- Closes the ticket via `tk close`
- Edits `openspec/changes/<id>/tasks.md`
- May archive OpenSpec
- Creates git commits
- Merges branches
- Pushes to remote

**Stop points:**
- Conflict resolution that isn't trivial
- Missing change-id and cannot auto-detect
- Push rejected by remote
