---
description: Close ticket, sync OpenSpec, merge to main, push
argument-hint: <ticket-id> [change-id]
allowed-tools: Bash, Read, Edit
---

# /tk-done $1 $2

Parse:
- `$1`: ticket-id (required)
- `$2`: change-id (optional, auto-detected from epic)

## Current Context

Ticket details:
!`tk show $1`

## Steps

1. **Identify OpenSpec change**:
   - Get parent epic from ticket
   - Extract `external_ref` (format: `openspec:<change-id>`)

2. **Add note and close**:
   ```bash
   tk add-note $1 "Closing via /tk-done"
   tk close $1
   ```

3. **Sync OpenSpec tasks.md**:
   - Find matching checkbox
   - Flip `[ ]` to `[x]`

4. **Check if all tasks complete**:
   - If yes: `openspec archive <change-id> --yes`

5. **Commit changes**:
   ```bash
   git add -A
   git commit -m "$1: <ticket-title>"
   ```

6. **Merge to main**:
   ```bash
   git checkout main
   git merge --ff-only ticket/$1
   ```

7. **Push** (if autoPush: true):
   ```bash
   git push origin main
   ```

8. **Cleanup** (worktree mode):
   ```bash
   git worktree remove .worktrees/$1
   git branch -d ticket/$1
   ```

## Output Format

```
## Ticket Closed

- Ticket: $1
- OpenSpec synced: Yes/No
- OpenSpec archived: Yes/No
- Committed: <hash>
- Merged to: main
- Pushed: Yes/No
```

## Contract

**DOES mutate state:**
- Closes ticket, edits tasks.md
- Creates commits, merges, pushes

**Stop points:**
- Conflict resolution needed
- Push rejected
