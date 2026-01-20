---
description: Run full ticket lifecycle (skill-driven)
argument-hint: [<ticket-id>] [--epic <epic-id>] [--ralph] [--max-cycles N]
allowed-tools: Bash(tk:*), Read
---

# /tk-run $@

Use the **os-tk-workflow** skill section “/tk-run Workflow” for the full process.

## Contract (brief)
Read queue/ticket state and delegate to `/tk-start`, `/tk-done`, `/tk-review`.
