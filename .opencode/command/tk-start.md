---
description: Start a tk ticket and implement it (runs in background for parallel work) [ultrahardwork]
agent: os-tk-agent
background: true
sisyphus: true
---

Ticket: $ARGUMENTS

Show the ticket details:
!`tk show $ARGUMENTS`

Now:
1) Run `tk start $ARGUMENTS` to mark it as in-progress.
2) Summarize the acceptance criteria and key deliverables.
3) Create and execute an implementation plan.
4) Run tests and validate the implementation.
5) When complete, notify the user and suggest `/tk-close-and-sync <ticket-id> <change-id>`.

**Note:** This command runs in the background. You can run `/tk-queue` again to start additional tickets in parallel.

<!-- ultrahardwork -->
