---
description: Close a tk ticket and sync progress back to OpenSpec tasks
agent: flow
subtask: true
---

Ticket: $1
OpenSpec change: $2

Show ticket:
!`tk show $1`

Show OpenSpec:
!`openspec show $2`

Now:
1) Propose the exact `tk add-note $1` text summarizing what changed (files, tests run, behavior).
2) Propose `tk close $1`.
3) Tell me which OpenSpec checkboxes in tasks.md should be checked off (by section/line reference).
4) Recommend the next `tk ready` ticket.
