# OpenSpec + Ticket + OpenCode Starter Kit

A lightweight, agent-friendly workflow that combines:

- **OpenSpec** for spec-driven changes (proposal → apply → archive)
- **ticket (`tk`)** for git-backed task tracking (ready/blocked queues + dependencies)
- **OpenCode** custom **agents** + **slash commands** to make the workflow frictionless

This repo is meant to be copied into an existing project (or used as a template) so *any* coding agent can follow the same operating rules via `AGENTS.md`, while OpenCode users get a fast UX with `/commands`.

---

## What you get

- `AGENTS.md` — tool-agnostic rules any agent can follow
- `.opencode/agent/flow.md` — a “workflow orchestrator” subagent (planning + tracking only)
- `.opencode/command/*` — slash commands to:
  - list/show OpenSpec changes
  - display `tk ready/blocked`
  - bootstrap a **3–8 chunky ticket** execution plan for a change
  - close + sync progress back to OpenSpec tasks

---

## Why “3–8 chunky tickets” (recommended default)

Instead of creating one ticket per checkbox, this workflow uses **3–8 deliverable-sized tickets per OpenSpec change**.

Benefits:
- Keeps `tk ready` meaningful (no ticket spam)
- Low admin overhead for humans and agents
- More resilient when implementation details change mid-flight

Fine-grained checklists still live in **OpenSpec** (and optionally inside each ticket body).

---

## Prerequisites

### 1) Install OpenSpec
If you install via npm:

```bash
npm install -g @fission-ai/openspec@latest
```

Then initialize in your project and select **OpenCode** integration when prompted:

```bash
openspec init
```

### 2) Install ticket (`tk`)
If you use Homebrew:

```bash
brew tap wedow/tools
brew install ticket
```

(Or install via your preferred method. Ensure `tk` is on PATH.)

Optional (for `tk query`):
- `jq` installed

---

## Quick start (in your project)

1) Copy these files into your repo:
- `AGENTS.md`
- `.opencode/agent/flow.md`
- `.opencode/command/*.md`

2) Commit them:

```bash
git add AGENTS.md .opencode
git commit -m "Add OpenSpec + ticket + OpenCode workflow"
```

3) In OpenCode, start using the commands below.

---

## Daily workflow

### Step A — Define the change in OpenSpec

In OpenCode:

- `/openspec-proposal <change-id>`

Refine the proposal + acceptance criteria, then (optionally):

- `openspec validate <change-id>`
- `openspec show <change-id>`

When ready to implement:

- `/openspec-apply <change-id>`

### Step B — Create a ticket epic + chunky tasks

Create a tk epic and 3–8 deliverable-sized tasks (DB/API/UI/tests/docs, etc).

In OpenCode, run:

- `/tk-bootstrap <change-id> "<epic title>"`

This command prints the exact `tk create ...` commands to run (and any `tk dep` links).

### Step C — Execute from `tk ready`

Loop:

```bash
tk ready
tk show <id>
tk start <id>
# implement + test
tk add-note <id> "what changed, files, tests"
tk close <id>
```

Then sync OpenSpec checkboxes:

- `/tk-close-and-sync <ticket-id> <change-id>`

### Step D — Archive the change

When the epic is done:

```bash
openspec archive <change-id> --yes
```

---

## OpenCode commands included

### `/os-status`
Shows active OpenSpec changes and recommends next action.

### `/os-show <change-id>`
Shows a change and suggests 3–8 deliverable chunks for ticketing.

### `/tk-queue`
Shows `tk ready` and `tk blocked`, then suggests the single best next task.

### `/tk-bootstrap <change-id> "<epic title>"`
Bootstraps the execution graph: epic + 3–8 tasks + dependencies (commands printed in order).

### `/tk-close-and-sync <ticket-id> <change-id>`
Prompts for a good `tk add-note`, suggests closing the ticket, and tells you which OpenSpec checkboxes to tick.

---

## Using this workflow without OpenCode (any agent)

Even without OpenCode, agents can follow `AGENTS.md`:

1) Use OpenSpec as the “source of truth” for the change
2) Create a tk epic with `--external-ref "openspec:<change-id>"`
3) Create 3–8 chunky tasks under that epic
4) Pick work from `tk ready`
5) Keep OpenSpec tasks checked off and archive at the end

---

## Recommended conventions

- **External reference:** every epic uses `--external-ref "openspec:<change-id>"`
- **Commit messages:** include ticket IDs when relevant, e.g. `ab-1234: add endpoint`
- **Dependencies:** only model real blockers with `tk dep`
- **Notes:** use `tk add-note` to capture “what changed + how to verify”

---

## Troubleshooting

### `tk query` doesn’t work
Install `jq` and ensure it’s on PATH.

### OpenCode commands can’t run shell commands
Some OpenCode setups require explicit permission for `bash`.  
The included `flow` subagent is configured to allow `openspec *` and `tk *`, but may still prompt depending on your OpenCode security settings.

### Nothing shows in `tk ready`
Check:
- Are tasks closed?
- Are tasks blocked by dependencies?
- Run `tk blocked` to see what’s waiting.

---

## License

MIT. See `LICENSE`.

---

## Credits

This starter kit is an integration pattern for:
- OpenSpec
- ticket (`tk`)
- OpenCode

Upstream projects are owned by their respective authors.
