---
description: Start one or more tk tickets and implement them (unified single/multi-ID) [ulw]
agent: os-tk-worker
subtask: true
background: true
---

# /tk-start <ticket-id> [ticket-id ...] [--parallel N]

**Arguments:** $ARGUMENTS

Parse arguments:
- All positional args are ticket IDs
- `--parallel N` sets concurrency (default: 3 from config)

## Step 1: Load config

Read `.os-tk/config.json` for:
- `useWorktrees` (boolean)
- `worktreeDir` (default: ".worktrees")
- `defaultParallel` (default: 3)
- `unsafe.allowParallel` (boolean)

## Step 2: Validate tickets are ready

Run: `tk ready`

Filter requested ticket IDs to only those that appear in the ready list.
- If a requested ID is not ready, print warning: `<id> is not ready (skipped)`
- If no IDs are ready, STOP with message: "No tickets are ready to start."

## Step 3: Check for active worktrees (if enabled)

If `useWorktrees: true`:
- Check for existing worktrees: `ls -d .worktrees/*/ 2>/dev/null`
- Exclude any ticket IDs that already have an active worktree
- Print warning for excluded IDs: `<id> already has active worktree (skipped)`

## Step 4: Handle parallel execution policy

**Single ticket:** Proceed directly.

**Multiple tickets with `useWorktrees: true`:**
- Safe parallel execution is allowed
- Each ticket gets its own worktree + branch

**Multiple tickets with `useWorktrees: false`:**
- Check `unsafe.allowParallel`:
  - If `false`: STOP with message:
    ```
    Parallel execution in a single working tree is disabled.
    Enable it in .os-tk/config.json: unsafe.allowParallel = true
    Or enable worktrees: useWorktrees = true
    ```
  - If `true`: Print warning and proceed:
    ```
    WARNING: Running multiple tickets in one working tree is risky.
    Changes may conflict. Commits may bundle unrelated work.
    Proceeding because unsafe.allowParallel is enabled.
    ```

## Step 5: Set up execution context

**If `useWorktrees: true`:**
For each ticket ID:
1. Create worktree with new branch: `git worktree add -b ticket/<ticket-id> .worktrees/<ticket-id>`
2. Worker operates in: `.worktrees/<ticket-id>/`

**If `useWorktrees: false`:**
- Worker operates in current directory
- No branch creation

## Step 6: Execute implementation

For each eligible ticket:
1. Run `tk start <ticket-id>` to mark as in-progress
2. Show ticket details: `tk show <ticket-id>`
3. Summarize acceptance criteria and key deliverables
4. Create and execute implementation plan
5. Run tests and validate

**Worker contract:**
- Implement ticket deliverables and acceptance criteria
- Run relevant tests
- Do NOT close tickets (that's `/tk-done`'s job)
- Do NOT archive OpenSpec
- Do NOT merge branches or push

## Step 7: Completion

When implementation is complete:
- Summarize what was implemented
- List files created/modified
- Instruct user to run: `/tk-done <ticket-id> [change-id]`

---

## EXECUTION CONTRACT

This command **DOES** mutate state:
- Marks tickets as in-progress via `tk start`
- Creates worktrees and branches (if enabled)
- Edits/creates files during implementation
- Runs tests

**This command does NOT:**
- Close tickets
- Archive OpenSpec
- Merge to main or push

**After implementation, user must run `/tk-done` to complete the workflow.**

---

**Note:** This command runs in the background. You can run `/tk-queue` again to check status or start additional tickets.
