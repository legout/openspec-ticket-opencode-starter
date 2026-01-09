---
description: Start multiple tickets in parallel (includes full implementation workflow) [ultrahardwork]
agent: os-tk-agent
background: true
---

**Ticket IDs:** $ARGUMENTS

For EACH ticket ID provided in `$ARGUMENTS`, you MUST execute the full implementation workflow below. 

> [!IMPORTANT]
> You are responsible for the actual implementation, not just marking them as started. If your execution environment allow, handle these tickets in parallel.

### Workflow for each Ticket <id>:
1. **Initialize:** Run `tk start <id>` to mark it as in-progress.
2. **Context:** Show the ticket details: !`tk show <id>`
3. **Analysis:** Summarize the acceptance criteria and key deliverables for this ticket.
4. **Implementation:** Create and execute a detailed implementation plan (write code, refactor, etc.).
5. **Verification:** Run all relevant tests and validate the implementation.
6. **Completion:** Notify the user when the ticket is fully implemented.

Confirm to the user which tickets you are starting and provide updates as you progress through the implementation phases for each.

<!-- ultrahardwork -->
