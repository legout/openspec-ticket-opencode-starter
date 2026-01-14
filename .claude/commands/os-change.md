---
description: Show OpenSpec changes or display details for a specific change [VIEW-ONLY]
agent: planner
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# COMMAND CONTRACT (MUST OBEY)

You are running `/os change`, which is a **VIEW-ONLY** command.

## ALLOWED
- `openspec list`, `openspec show <id>`, `openspec validate <id>`
- `tk ready`, `tk blocked`, `tk show <id>`, `tk query <filter>`
- Summarize, analyze, and recommend

## FORBIDDEN
- `tk start`, `tk close`, `tk add-note`, or any mutating `tk` command
- Edit files, write code, run tests, or implement plans
- Any bash commands that modify state

## ENFORCEMENT
If you are about to describe code changes or an implementation plan:
1. STOP immediately
2. Remove any implementation content from your response
3. Tell the user to run `/tk start <ticket-id>` instead

---

# /os change [change-id]

**Arguments:**
- `$1`: Optional change ID to view details

## No arguments

When invoked without arguments:

1. Show active OpenSpec changes: `! openspec list`
2. For each change, show summary:
   - Change ID
   - Proposal file exists?
   - Tasks file exists?
   - Last modified
3. Suggest next actions (e.g., `/os change <id>` or `/tk bootstrap <id>`).
4. End with: "Run `/os change <id>` to view details or `/tk queue` to see ready tickets."

## With change-id argument

When invoked with a change-id:

1. Show the change details: `! openspec show $1`
2. Show the task list: `! cat openspec/changes/$1/tasks.md`
3. Highlight any missing acceptance criteria or unclear requirements.
4. Identify 3-8 deliverable chunks that should become tk tasks.
5. Suggest next steps (e.g., `/tk bootstrap <id> "<epic title>"` or `/tk queue`).

## Output Format

For a change view, present:
- Change metadata (ID, proposal exists, tasks exist, last modified)
- Proposal summary (if file exists)
- Tasks checklist (if file exists)
- Gaps (missing acceptance criteria, unclear requirements)
- Suggested ticket chunks (3-8 items)
- Next command recommendation

**STOP. Do not create tickets or begin implementation.**
