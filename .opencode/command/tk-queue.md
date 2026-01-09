---
description: Show tk ready/blocked and suggest next work item(s) (does NOT start work) [ultrahardwork]
agent: os-tk-agent
subtask: false
---

Ready:
!`tk ready`

Blocked:
!`tk blocked`

**Arguments:** $ARGUMENTS

**Mode:**
- If `$ARGUMENTS` is empty or `next`: Pick ONE ready ticket to do next (or the smallest unblock step if none are ready).
- If `$ARGUMENTS` is `all`: List ALL ready tickets that can be worked on in parallel.

**Output (for each ticket):**
- ticket id
- title & brief summary
- why it's a good choice

**Important:** Do NOT start implementation. Do NOT provide an implementation plan.

**End your response by asking:**
- For `next` or empty: *"Would you like me to run `/tk-start <ticket-id>` to begin work on this ticket?"*
- For `all`: *"Would you like me to start all of these tickets in parallel? Run `/tk-start-multi <id1> <id2> ...` to begin."*

<!-- ultrahardwork -->
