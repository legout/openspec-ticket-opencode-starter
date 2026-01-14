---
description: Start one or more tk tickets and implement them
argument-hint: <ticket-id> [ticket-id ...] [--parallel N]
---

# /tk-start

**Arguments:** $ARGUMENTS

Parse from $ARGUMENTS:
- All words are ticket IDs (unless prefixed with --)
- `--parallel N` sets concurrency (default: 3)

## Steps

1. **Load config** from `.os-tk/config.json`
2. **Validate tickets are ready**: Run `tk ready`
3. **Set up execution context** (worktree if enabled)
4. **Mark as in-progress**: `tk start <id>`
5. **Implement deliverables and acceptance criteria**
6. **Run tests**
7. **Summarize and instruct to run `/tk-done`**

## Worktree Setup (if enabled)

```bash
git worktree add -b ticket/<id> .worktrees/<id>
```

## Worker Contract

**ALLOWED:**
- Edit files, write code, refactor
- Run tests
- `tk show`, `tk start`

**FORBIDDEN:**
- `tk close` (use `/tk-done`)
- Archiving OpenSpec
- Merging branches or pushing

## Output Format

```
## Implementation Complete

### Files Modified
- path/to/file1.ts

### Files Created
- path/to/new-file.ts

### Tests
- All tests passing

### Next Step
Run `/tk-done <ticket-id>` to close, commit, and merge.
```
