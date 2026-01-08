# Agent Workflow: OpenSpec + Ticket (tk)

This repo uses:
- OpenSpec for spec-driven changes (proposal → apply → archive)
- ticket (tk) for task execution tracking (dependencies, ready/blocked)

## Core rules (must follow)

1) Specs before code
- If there is no active OpenSpec change for the request, create one (proposal) before implementing.
- Use:
  - `openspec list`
  - `openspec show <change>`
  - `openspec validate <change>` before coding when feasible.

2) One OpenSpec change = one ticket epic
- Create a tk epic with `--external-ref "openspec:<change-id>"`.

3) Use 3–8 chunky tickets per change (default)
- Create 3–8 task tickets under the epic (deliverables like DB/API/UI/tests/docs).
- Do NOT create one ticket per OpenSpec checkbox unless explicitly requested.

4) Drive work via tk queues
- Always pick the next task using `tk ready`.
- Mark progress with `tk start <id>`, notes with `tk add-note <id>`, and completion with `tk close <id>`.

5) Keep OpenSpec tasks in sync
- When a tk task is completed, check off the corresponding items in `openspec/changes/<change>/tasks.md`.
- When all tasks are complete, archive the change:
  - `openspec archive <change> --yes`

6) Dependencies
- Encode real blockers using `tk dep <id> <dep-id>`.
- Use `tk blocked` when nothing is ready.

7) Git hygiene
- Include the ticket ID in commits when relevant (e.g., "ab-1234: implement API endpoint").
- Prefer small, reviewable commits per task.

## Working loop (summary)

Identify or create OpenSpec change → validate → create epic + 3–8 task tickets → execute: `tk ready` → implement → `tk close` → update OpenSpec tasks → when done: `openspec archive --yes`.
