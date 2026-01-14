---
description: Run full ticket lifecycle (start → done → review) with fresh context per step
---

# /tk-run [<ticket-id>] [--epic <epic-id>] [--ralph] [--max-cycles N]

**Arguments:** $ARGUMENTS

## Pre-execution Check
Check if the `subagent` extension is installed by checking for the `subagent` tool. If not available, instruct the user to install it globally at `~/.pi/agent/extensions/subagent`.

## Mode Selection

| Mode | Behavior |
|------|----------|
| Default (single ticket) | Run one ticket through start → done → review |
| `--epic` | Loop until all tickets in epic are closed |
| `--ralph` | Loop until `tk ready` returns empty |

---

## Step 1: Load config and determine mode

Read `.os-tk/config.json` for:
- `reviewer.autoTrigger` (boolean)

## Step 2: Main execution loop

Use the `subagent` tool to orchestrate the lifecycle:
1. Select next ticket based on mode.
2. Run `/tk-start` for the ticket.
3. Run `/tk-done` for the ticket.
4. Run `/tk-review` for the ticket (if enabled).
5. Loop until exit condition or `max-cycles` reached.

---

## EXECUTION CONTRACT

This command is an **orchestrator** that delegates to other commands via the Pi `subagent` extension.
