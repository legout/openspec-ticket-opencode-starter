<!-- OPENSPEC-TK-START -->
# Agent Workflow: OpenSpec + Ticket (tk)

This repo uses:
- OpenSpec for spec-driven changes (proposal → setup → archive)
- ticket (tk) for task execution tracking (dependencies, ready/blocked)

# Ticket Instructions

This project uses a CLI ticket system for task management. Run `tk help` when you need to use it.
For every OpenSpec change, create a ticket epic with --external-ref openspec:<change-id> and work from tk ready.

## Core rules (must follow)

1) Specs before code
- If there is no active OpenSpec change for the request, create one (proposal) before implementing.
- Use:
  - `openspec list`
  - `openspec show <change>`
  - `openspec validate <change>` before coding when feasible.

2) No "blind" implementation
- Do NOT use commands like `/os-apply` or equivalent "auto-implement" tools.
- All implementation must be driven by `tk` tickets.

3) One OpenSpec change = one ticket epic
- Create a tk epic with `--external-ref "openspec:<change-id>"`.

4) Use 3–8 chunky tickets per change (default)
- Create 3–8 task tickets under the epic (deliverables like DB/API/UI/tests/docs).
- Propose these tickets based on the OpenSpec `tasks.md` and `proposal.md`.

5) Drive work via tk queues
- Always pick the next task using `tk ready`.
- Mark progress with `tk start <id>`, notes with `tk add-note <id>`, and completion with `tk close <id>`.

5a) Parallel execution (when safe)
- Use `/tk-start-multi <id1> <id2> ...` to start multiple ready tickets in parallel.
- Optional: append `--parallel N` to control concurrency (default: 3).
- Only tickets in `tk ready` will be started; non-ready tickets are skipped.
- Always wait for all workers to complete and summarize results.

5b) Backlog hygiene (avoid duplicates)
- Before creating new tickets with `/tk-bootstrap`, agent must check existing open tickets via `tk query`.
- If a task required for a proposal already exists (>90% overlap), use existing ticket instead of creating a duplicate.
- Use `/tk-refactor` to clean up backlog after bootstrapping large proposals or when duplicate work is suspected.
- When merging duplicates: consolidate into one shared ticket, mark losers as done with notes, and reroute all dependencies.

6) Keep OpenSpec tasks in sync
- When a tk task is completed, check off the corresponding items in `openspec/changes/<change>/tasks.md`.
- When all tickets under the epic are complete, archive the change:
  - `openspec archive <change> --yes`

7) Dependencies
- Encode real blockers using `tk dep <id> <dep-id>`.
- Use `tk blocked` when nothing is ready.

8) Git hygiene
- Include the ticket ID in commits when relevant (e.g., "ab-1234: implement API endpoint").

## Working loop (summary)

Identify/create OpenSpec proposal → review/validate → bootstrap tk epic + 3–8 task tickets → loop: `tk ready` → `tk start` (or `/tk-start-multi <ids...>` for parallel) → implement → `tk close` → update OpenSpec tasks → all tickets done? → `openspec archive --yes`.
## oh-my-opencode Integration (Sisyphus)

If you have `oh-my-opencode` installed, the **Sisyphus** engineering manager will orchestrate this workflow automatically.

1. **Automatic Persistence:** Sisyphus will monitor the `tk` queue and OpenSpec status.
2. **Delegation:** It will automatically delegate chunky implementation tasks to the `os-tk-agent`.
3. **Parallelism:** Sisyphus will attempt to run multiple ready tickets in parallel where possible. Use `/tk-start-multi <ids...> [--parallel N]` to explicitly start multiple tickets in parallel with configurable concurrency.

Commands in this workflow are marked with `[ultrahardwork]`, signaling to the orchestrator that they are part of the managed engineering flow.
<!-- OPENSPEC-TK-END -->
