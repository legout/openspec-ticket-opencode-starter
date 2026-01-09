---
description: Start multiple tk tickets in parallel (each runs as background task)
agent: os-tk-agent
subtask: false
---

**Ticket IDs:** $ARGUMENTS

For EACH ticket ID provided in `$ARGUMENTS`:
1. Run `tk start <id>` to mark it as in-progress.
2. Spawn a background implementation task that:
   - Shows ticket details via `tk show <id>`
   - Creates and executes an implementation plan
   - Runs tests and validates
   - Notifies the user when complete

**Important:** Each ticket implementation should run as a separate background task so they can proceed in parallel.

After spawning all tasks, confirm to the user:
> "Started <N> tickets in parallel: <id1>, <id2>, ... You'll be notified as each completes."
