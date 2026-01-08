# OpenSpec + Ticket + OpenCode Starter Kit

A lightweight, agent-friendly workflow that combines:

- **OpenSpec** for spec-driven changes (proposal → apply → archive)
- **ticket (`tk`)** for git-backed task tracking (ready/blocked queues + dependencies)
- **OpenCode** custom **agents** + **slash commands** to make the workflow frictionless

This repo is meant to be copied into an existing project (or used as a template) so *any* coding agent can follow the same operating rules via `AGENTS.md`, while OpenCode users get a fast UX with `/commands`.

---

## What you get

- `AGENTS.md` — tool-agnostic rules any agent can follow.
- `.opencode/agent/flow.md` — a “workflow orchestrator” subagent.
- `.opencode/skill/` — **modular expert knowledge** (OpenSpec & ticket) for better agent performance.
- `.opencode/command/*` — specialized slash commands to:
  - list/show OpenSpec changes
  - display `tk ready/blocked`
  - bootstrap a **3–8 chunky ticket** execution plan
  - close + sync progress back to OpenSpec tasks

---

## Installation

### 1) Prerequisites
The workflow requires these CLI tools:

- **OpenSpec** (spec-driven changes):
  ```bash
  npm install -g @fission-ai/openspec@latest
  openspec init  # run in your project
  ```
- **ticket (`tk`)** (git-backed task tracking):
  ```bash
  brew tap wedow/tools
  brew install ticket
  ```
- **jq** (optional, for `tk query`):
  ```bash
  brew install jq
  ```

### 2) Install Workflow Files
Run this one-liner in your project root:

```bash
curl -sSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/main/install.sh | bash
```

This will:
- Create `.opencode/agent/` and `.opencode/command/` directories.
- **Append** to your existing `AGENTS.md` (or create a new one).

### 3) Commit changes
```bash
git add AGENTS.md .opencode
git commit -m "Add OpenSpec + ticket + OpenCode workflow"
```

---

## Daily Workflow

### Phase 1: Spec Planning (OpenSpec)
1. **Propose:** `/openspec-proposal <id>` (Define requirements and design).
2. **Review:** Ensure the proposal in `openspec/changes/<id>/` is complete.

### Phase 2: Setup Execution (ticket)
1. **Bootstrap:** `/tk-bootstrap <id> "<epic title>"` (Converts the OpenSpec proposal into actionable `tk` tickets).
2. **Execute:** Loop through `tk ready`:
   - `tk start <id>`
   - Work + Test
   - `/tk-close-and-sync <tk-id> <os-id>` (Closes ticket and checks off OpenSpec task boxes).

### Phase 3: Archive
1. **Archive:** Once all tickets are closed, `openspec archive <id> --yes`.

---

## Workflow Example: "Add Search"

Here is how you would implement a new search feature using this kit:

1. **Define the Specs:**
   - In OpenCode: `/openspec-proposal search-feature`
   - Agent writes the PRD and Acceptance Criteria in `openspec/changes/search-feature/`.
   - You review the docs.

2. **Bootstrap the Tasks:**
   - In OpenCode: `/tk-bootstrap search-feature "Implement site-wide search"`
   - OpenCode reads the OpenSpec files and proposes a set of chunky tickets (e.g., `DB Schema`, `API Endpoint`, `UI Component`).
   - Run the generated `tk create` commands.

3. **Fly through the Queue:**
   - You (or the agent) run `/tk-queue` to see what's next.
   - Run `tk start 123` (the API ticket).
   - Once finished, run `/tk-close-and-sync 123 search-feature`. OpenCode prompts you to check off "Implement API" in the OpenSpec file.

4. **Archive:**
   - All tickets closed? Run `openspec archive search-feature --yes`.

---

## Why “3–8 chunky tickets”?

This workflow favors **3–8 deliverable-sized tickets** over fine-grained checkboxes.
- **Better for Context:** Agents focus on one "chunk" (e.g., "Implement Auth API") rather than 10 tiny tasks.
- **Cleaner Backlog:** `tk ready` stays readable for humans.
- **Flexibility:** Implementation details can evolve within a chunky ticket without needing constant re-ticketing.

---

## OpenCode Commands

| Command | Description |
| :--- | :--- |
| `/os-status` | Show active OpenSpec changes and next steps. |
| `/os-show <id>` | Show change details and suggest ticket chunks. |
| `/tk-queue` | Show `tk ready/blocked` and the best next task. |
| `/tk-bootstrap <id> "<title>"` | Generate `tk create` commands for an epic + tasks. |
| `/tk-close-and-sync <tk-id> <os-id>` | Add notes, close ticket, and sync OpenSpec progress. |

---

## Using with any Agent (Non-OpenCode)

Even without OpenCode, any agent can follow `AGENTS.md` by:
1. Using OpenSpec for high-level requirements.
2. Creating a `tk` epic with `--external-ref "openspec:<id>"`.
3. Executing tasks from `tk ready`.

---

## Recommended conventions

- **External reference:** every epic uses `--external-ref "openspec:<change-id>"`
- **Commit messages:** include ticket IDs when relevant, e.g. `ab-1234: add endpoint`
- **Dependencies:** only model real blockers with `tk dep`
- **Notes:** use `tk add-note` to capture “what changed + how to verify”

---

## Troubleshooting

- **`tk query` fails:** Ensure `jq` is installed.
- **Permissions:** Some setups require explicit `bash` permission for OpenCode commands.
- **Empty Queue:** Check `tk blocked` to see if dependencies are holding up work.

---

## License & Credits

MIT. Integration pattern for [OpenSpec](https://github.com/fission-ai/openspec), [ticket](https://github.com/wedow/ticket), and [OpenCode](https://opencode.dev).
