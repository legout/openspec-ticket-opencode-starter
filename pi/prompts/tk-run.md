---
description: Run full ticket lifecycle (skill-driven)
---

# /tk-run [<ticket-id>] [--epic <epic-id>] [--ralph] [--max-cycles N]

Use the **os-tk-workflow** skill section “/tk-run Workflow” for the full process.

## Pre-execution Check
Ensure the `subagent` extension is installed.

## Contract (brief)
Read queue/ticket state and delegate to `/tk-start`, `/tk-done`, `/tk-review`.
