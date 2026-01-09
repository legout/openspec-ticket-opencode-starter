---
description: Close a tk ticket and sync progress back to OpenSpec tasks [ulw]
agent: os-tk-agent
---

Ticket: $1
OpenSpec ID: $2

Now:
1) Add a summary note to the ticket: `tk add-note $1 "Implemented: <summary>"`
2) Close the ticket: `tk close $1`
3) Update `openspec/changes/$2/tasks.md` and check off the completed work.
4) If all tickets are done, suggest: `openspec archive $2`

STOP here. Do NOT automatically archive. Wait for user confirmation.
