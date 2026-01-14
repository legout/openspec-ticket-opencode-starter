---
description: Close ticket, sync OpenSpec, merge to main, push
argument-hint: <ticket-id> [change-id]
---

# /tk-done

**Arguments:** $ARGUMENTS

Parse from $ARGUMENTS:
- First word: ticket-id (required)
- Second word: change-id (optional, auto-detected from epic)

## Steps

1. **Identify OpenSpec change**:
   - Get parent epic from ticket
   - Extract `external_ref` (format: `openspec:<change-id>`)

2. **Add note and close**:
   ```bash
   tk add-note <ticket-id> "Closing via /tk-done"
   tk close <ticket-id>
   ```

3. **Sync OpenSpec tasks.md**:
   - Find matching checkbox
   - Flip `[ ]` to `[x]`

4. **Check if all tasks complete**:
   - If yes: `openspec archive <change-id> --yes`

5. **Commit changes**:
   ```bash
   git add -A
   git commit -m "<ticket-id>: <ticket-title>"
   ```

6. **Merge to main**:
   ```bash
   git checkout main
   git merge --ff-only ticket/<ticket-id>
   ```

7. **Push** (if autoPush: true)

8. **Cleanup** (worktree mode)

## Output Format

```
## Ticket Closed

- Ticket: <ticket-id>
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
