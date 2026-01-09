---
description: Start multiple tk tickets in parallel (wait and summarize) [ultrahardwork]
agent: os-tk-agent
subtask: true
background: true
---

Ticket IDs: $ARGUMENTS

You MUST process these tickets in parallel as independent workers.

**Parsing:**
- Extract ticket IDs from `$ARGUMENTS`.
- If `$ARGUMENTS` ends with `--parallel N`, set concurrency limit to N (otherwise default to 3).

**Readiness check:**
- Run !`tk ready` to get the list of ready tickets.
- Keep only ticket IDs that appear in the ready list. Skip any IDs not in ready and report them skipped.

**Parallel execution:**
- For each ready ticket, launch ONE independent worker (parallel subtask).
- Process workers in batches of at most the concurrency limit (3 by default).
- Each worker must perform the following workflow for its ticket <id>:

### Worker Workflow for Ticket <id>:
1. **Initialize:** Run `tk start <id>` to mark it as in-progress.
2. **Context:** Show the ticket details: !`tk show <id>`
3. **Analysis:** Summarize the acceptance criteria and key deliverables for this ticket.
4. **Implementation:** Create and execute a detailed implementation plan (write code, refactor, etc.).
5. **Verification:** Run all relevant tests and validate the implementation.
6. **Completion:** Confirm the ticket is fully implemented.

**Wait and summarize:**
- Wait for all workers to complete.
- Report a concise summary:
  - Number of tickets started/implemented/failed
  - Per-ticket outcome (ID: success/failure + brief note)
- For each successfully implemented ticket, suggest: `/tk-close-and-sync <id> <change-id>`.

<!-- ultrahardwork -->
