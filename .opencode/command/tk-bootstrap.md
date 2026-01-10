---
description: Create tk epic + 3–8 chunky task tickets for an OpenSpec change [ultrahardwork]
agent: os-tk-agent
permission:
  skill: allow
---

# COMMAND CONTRACT (MUST OBEY)

You are running `/tk-bootstrap`, which is a **VIEW-ONLY** command.

## ALLOWED
- `tk query`, `openspec list`, `openspec show <id>`, `openspec validate <id>`
- Summarize, analyze, and recommend

## FORBIDDEN
- `tk create`, `tk start`, `tk close`, `tk add-note`, `tk dep`, or any other mutating `tk` command
- Edit files or write code
- Any bash commands that modify state

## ENFORCEMENT
If you are about to output `tk create ...` commands:
1. STOP immediately
2. Remove all content after the command contract
3. Only output the exact `tk create ...` commands, nothing else

---

# COMMAND CONTRACT (MUST OBEY)

You are running `/tk-bootstrap`, which is a **VIEW-ONLY** command.

OpenSpec change-id: $1
Epic title: $2

Use your **openspec** skill to understand the change and your **ticket** skill to design the execution graph.

Show the change:
!`openspec show $1`

Create a tk epic and 3–8 task tickets under it.

Requirements:
- Epic must use: `--type epic --external-ref "openspec:$1"`
- Each task must use: `--type task --parent <EPIC_ID>`
- Use `--acceptance` for measurable done criteria (tests, behavior, docs).
- Use `tk dep` only for real blockers.
- Keep it chunky: deliverables (DB/API/UI/tests/docs), not one per checkbox.

Output EXACT commands in order:
1) `tk create ...` epic
2) 3–8x `tk create ...` tasks
3) `tk dep ...` lines (if needed)
4) What should appear in `tk ready` afterward

<!-- ultrahardwork -->
