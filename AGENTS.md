<!-- OS-TK-START -->
# Agent Workflow: OpenSpec + Ticket (tk)

This repo uses OpenSpec for spec-driven changes and tk for task execution tracking.

## Core Rules

1. **Specs before code** - Create an OpenSpec proposal before implementing.
2. **One change = one epic** - Create a tk epic with `--external-ref "openspec:<change-id>"`.
3. **3-8 chunky tickets** - Break work into deliverables (DB/API/UI/tests/docs).
4. **Queue-driven execution** - Pick work via `tk ready`, never blind implementation.
5. **`/tk-done` is mandatory** - Always use `/tk-done` to close work (syncs tasks + archives + merges + pushes).

## Commands

| Command | Purpose |
|---------|---------|
| `/os-proposal <id>` | Create/update OpenSpec change files |
| `/os-change [id]` | View change status (view-only) |
| `/tk-bootstrap <change-id> "<title>"` | Create tk epic + tasks from OpenSpec change |
| `/tk-queue [--next|--all|--change <id>]` | Show ready/blocked tickets (view-only) |
| `/tk-start <id...> [--parallel N]` | Start ticket(s) and implement |
| `/tk-done <id> [change-id]` | Close + sync + archive + merge + push |
| `/tk-refactor` | Merge duplicates, clean up backlog (optional) |

## Parallel Execution

- **Safe mode** (`useWorktrees: true`): Parallel via git worktrees, isolated branches.
- **Simple mode** (`useWorktrees: false`): Single working tree; parallel only if `unsafe.allowParallel: true`.

Configure via `.os-tk/config.json`. Initialize with `os-tk init`.
<!-- OS-TK-END -->
