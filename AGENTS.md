
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
| `/os-breakdown <source> [--with-tickets]` | Break down PRD/plan into OpenSpec proposals |
| `/os-proposal <id>` | Create/update OpenSpec change files |
| `/os-change [id]` | View change status (view-only) |
| `/tk-bootstrap <change-id> "<title>"` | Create tk epic + tasks from OpenSpec change |
| `/tk-queue [next\\|all\\|<change-id>]` | Show ready/blocked tickets (view-only) |
| `/tk-start <id...> [--parallel N]` | Start ticket(s) and implement |
| `/tk-done <id> [change-id]` | Close + sync + archive + merge + push |
| `/tk-review <id>` | Review completed ticket, create fix tickets if needed |
| `/tk-run [--all] [--max-cycles N]` | Autonomous loop: start → done → review → repeat |
| `/tk-refactor` | Merge duplicates, clean up backlog (optional) |

## Specialized Advisors (Advise-only)

Call these agents manually to get expert guidance at any stage. They can research via the web but cannot edit files.

| Agent | Expertise |
|-------|-----------|
| `@agent-spec` | Requirements, acceptance criteria, and edge cases |
| `@agent-design` | Architecture, dependencies, and rollout risk |
| `@agent-safety` | Security, privacy, and performance hotspots |
| `@agent-scout` | Tech research, API usage, and reference patterns |
| `@agent-quality` | Test strategy and verification checklists |
| `@agent-simplify` | Complexity reduction and refactoring advice |

## Review Automation

- `/tk-review` analyzes merge commits against OpenSpec specs
- Creates linked fix tickets (non-blocking) for issues found
- Configure via `reviewer` section in `config.json`
- `/tk-run` enables fully autonomous operation (Ralph mode)

## Parallel Execution

- **Safe mode** (`useWorktrees: true`): Parallel via git worktrees, isolated branches.
- **Simple mode** (`useWorktrees: false`): Single working tree; parallel only if `unsafe.allowParallel: true`.

Configure via `config.json`. Initialize with `os-tk init`.
<!-- OS-TK-END -->
