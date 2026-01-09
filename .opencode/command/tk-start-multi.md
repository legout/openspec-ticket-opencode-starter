---
description: Start multiple tk tickets in parallel (wait and summarize) [ultrahardwork]
agent: os-tk-agent
---

Ticket IDs: $ARGUMENTS

**Parsing:**
- Extract ticket IDs from `$ARGUMENTS`.
- If `$ARGUMENTS` ends with `--parallel N`, set concurrency limit to N (otherwise default to 3).

**Readiness check:**
- Run !`tk ready` to get the list of ready tickets.
- Keep only ticket IDs that appear in the ready list. Skip any IDs not in ready and report them skipped.

**Launch parallel workers:**
You MUST use the `task` tool to spawn one independent `os-tk-agent` subtask per ticket ID. Do NOT execute the workflow yourself; delegate to parallel subtasks.

For each ready ticket ID, create a task with:
- `subagent_type`: os-tk-agent
- `description`: Implement ticket <id>
- `prompt`: Execute the full workflow for ticket <id>:

```
Ticket: <id>

Execute the full implementation workflow for this ticket:
1. **Initialize:** Run `tk start <id>` to mark it as in-progress.
2. **Context:** Show the ticket details: !`tk show <id>`
3. **Analysis:** Summarize the acceptance criteria and key deliverables for this ticket.
4. **Implementation:** Create and execute a detailed implementation plan (write code, refactor, etc.).
5. **Verification:** Run all relevant tests and validate the implementation.
6. **Completion:** Confirm the ticket is fully implemented.

When complete, report a brief summary including the ticket ID and outcome (success/failure).
```

Launch tasks in batches of at most the concurrency limit (default: 3). Launch the next batch only after the current batch completes.

**Wait and summarize:**
- Wait for all tasks to complete.
- Report a concise summary:
  - Number of tickets started/implemented/failed
  - Per-ticket outcome (ID: success/failure + brief note)
- For each successfully implemented ticket, suggest: `/tk-close-and-sync <id> <change-id>`.

<!-- ultrahardwork -->
