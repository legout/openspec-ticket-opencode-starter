---
description: Start one or more tk tickets and implement them
argument-hint: <ticket-id> [ticket-id ...] [--parallel N]
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# /tk-start $@

Parse arguments:
- All positional args are ticket IDs
- `--parallel N` sets concurrency (default: 3)

## Current Context

Config settings:
!`cat .os-tk/config.json | jq '{useWorktrees, defaultParallel}'`

Ready tickets:
!`tk ready`

## Steps

1. **Validate tickets are ready**
2. **Set up execution context** (worktree if enabled)
3. **Mark as in-progress**: `tk start <id>`
4. **Implement deliverables and acceptance criteria**
5. **Run tests**
6. **Summarize and instruct to run `/tk-done`**

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
- Implementing multiple tickets in one flow

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
