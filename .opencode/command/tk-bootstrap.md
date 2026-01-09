---
description: Create tk epic + 3–8 chunky task tickets for an OpenSpec change [ultrahardwork]
agent: os-tk-agent
permission:
  skill: allow
---

OpenSpec change-id: $1
Epic title: $2

Use your **openspec** skill to understand the change and your **ticket** skill to design the execution graph.

Show the change:
!`openspec show $1`

Scan existing open tickets to avoid duplication:
!`tk query --status open`

Create a tk epic and 3–8 task tickets under it.

Requirements:
- Epic must use: `--type epic --external-ref "openspec:$1"`
- Each task must use: `--type task --parent <EPIC_ID>`
- Use `--acceptance` for measurable done criteria (tests, behavior, docs).
- Use `tk dep` only for real blockers.
- Keep it chunky: deliverables (DB/API/UI/tests/docs), not one per checkbox.
- **Avoid duplicates:** Before proposing a task, check if an existing open ticket (from the scan above) already covers >90% of the same work. If yes, do NOT create a new task—note that existing ticket should be used instead.

Output EXACT commands in order:
1) `tk create ...` epic
2) 3–8x `tk create ...` tasks
3) `tk dep ...` lines (if needed)
4) What should appear in `tk ready` afterward

<!-- ultrahardwork -->
