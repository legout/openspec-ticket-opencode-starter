# OpenSpec + Ticket (os-tk) Workflow

A lightweight, agent-friendly workflow that combines:

- **OpenSpec** for spec-driven changes (proposal -> apply -> archive)
- **ticket (`tk`)** for git-backed task tracking (ready/blocked queues + dependencies)
- **OpenCode** slash commands for multi-agent orchestration

This repo is a template. Use `os-tk` to install the workflow into any project, giving *any* coding agent consistent operating rules via `AGENTS.md`, while OpenCode users get slash commands.

---

## Quick Start

```bash
# 1. Install os-tk (one-time, global)
curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/v0.1.0/install.sh | bash

# 2. Add ~/.local/bin to PATH (if not already)
export PATH="$HOME/.local/bin:$PATH"

# 3. Initialize the workflow in your project
cd your-project
os-tk init

# 4. Commit the workflow files
git add .os-tk .opencode AGENTS.md .gitignore
git commit -m "Add OpenSpec + ticket workflow"
```

---

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| **jq** | Required by os-tk | `brew install jq` or `apt install jq` |
| **OpenSpec** | Spec-driven changes | `npm install -g @fission-ai/openspec@latest` |
| **ticket (tk)** | Git-backed task tracking | `brew tap wedow/tools && brew install ticket` |

After installing OpenSpec, run `openspec init` in your project.

---

## Installation Options

### Option 1: Pinned Tag Install (Recommended)

Install from a specific release for reproducibility:

```bash
curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/v0.1.0/install.sh | bash
```

Replace `v0.1.0` with the desired version tag.

### Option 2: Manual Install

Download the script directly:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/v0.1.0/os-tk -o ~/.local/bin/os-tk
chmod +x ~/.local/bin/os-tk
```

Then run `os-tk init` in your project.

### Adding ~/.local/bin to PATH

Add one of these to your shell config:

```bash
# For bash (~/.bashrc):
export PATH="$HOME/.local/bin:$PATH"

# For zsh (~/.zshrc):
export PATH="$HOME/.local/bin:$PATH"

# For fish (~/.config/fish/config.fish):
set -gx PATH $HOME/.local/bin $PATH
```

---

## os-tk Commands

| Command | Description |
|---------|-------------|
| `os-tk init [--worktree\|--simple]` | Initialize project (sync + apply + update AGENTS.md) |
| `os-tk sync` | Download `.opencode/**` from templateRepo@templateRef |
| `os-tk apply` | Re-apply config to agents (no network, no AGENTS.md) |
| `os-tk version` | Show os-tk version and project templateRef |

---

## Configuration

After running `os-tk init`, configuration is stored in `.os-tk/config.json`:

```json
{
  "templateRepo": "legout/openspec-ticket-opencode-starter",
  "templateRef": "v0.1.0",
  "useWorktrees": true,
  "worktreeDir": ".worktrees",
  "defaultParallel": 3,
  "mainBranch": "main",
  "autoPush": true,
  "unsafe": {
    "allowParallel": false,
    "allowDirtyDone": false,
    "commitStrategy": "prompt"
  },
  "planner": {
    "model": "openai/gpt-5.2",
    "reasoningEffort": "high",
    "temperature": 0
  },
  "worker": {
    "model": "zai-coding-plan/glm-4.7",
    "fallbackModels": ["minimax/MiniMax-M2.1"],
    "reasoningEffort": "none",
    "temperature": 0.2
  }
}
```

### Key Settings

| Field | Description |
|-------|-------------|
| `templateRef` | Version to sync from. Use a tag (e.g., `v1.0.0`) or `latest` |
| `useWorktrees` | `true` for safe parallel (isolated branches), `false` for simple mode |
| `planner.model` | Model for planning/view-only commands |
| `worker.model` | Model for implementation commands |

### Updating the Workflow

To update to a newer version:

1. Edit `.os-tk/config.json` and change `templateRef` to the new tag (or `latest`)
2. Run `os-tk sync` to download updated files
3. Commit the changes

---

## What Gets Installed

Running `os-tk init` creates/updates these files in your project:

```
.os-tk/
  config.json              # Project config (commit this)

.opencode/
  agent/
    os-tk-planner.md       # View-only planning agent
    os-tk-orchestrator.md  # Ticket design agent (strong reasoning)
    os-tk-worker.md        # Implementation agent
  command/
    os-change.md           # View OpenSpec changes
    os-proposal.md         # Create proposals
    tk-bootstrap.md        # Design + create epic + tasks
    tk-queue.md            # View ready/blocked
    tk-start.md            # Start implementation
    tk-done.md             # Close + sync + merge
    tk-refactor.md         # Clean up backlog
  skill/
    openspec/SKILL.md      # OpenSpec expertise
    ticket/SKILL.md        # tk expertise

AGENTS.md                  # Agent-agnostic workflow rules
```

**Commit these files** to share the workflow with your team.

---

## Workflow

```
+---------------------+       +---------------------------+       +---------------------+
|      PLANNING       | ----> |         EXECUTION         | ----> |       ARCHIVE       |
+---------------------+       +---------------------------+       +---------------------+
         |                               |                                  |
  1. /os-proposal                 2. /tk-bootstrap                          |
         |                               |                                  |
         v                               v                                  |
    [spec files]                  [epic + tasks]                            |
                                         |                                  |
                                         v                                  |
                                   3. /tk-queue                             |
                                         |                                  |
                                         v                                  |
                              4. /tk-start <id>                             |
                                         |                                  |
                                         v                                  |
                                   (code & test)                            |
                                         |                                  |
                                         v                                  |
                               5. /tk-done <id>                             |
                                         |                    |             |
                                         |____________________|             v
                                               |               6. openspec archive
                                               +-------------------------->
```

### Phase 1: Planning

```bash
# Create a new proposal
/os-proposal search-feature
```

### Phase 2: Execution

```bash
# Bootstrap tickets (Epic + Tasks)
/tk-bootstrap search-feature "Implement site-wide search"

# Check the queue
/tk-queue

# Start a ticket
/tk-start ab-101

# ... implement and test ...

# Close and sync
/tk-done ab-101
```

### Phase 3: Archive

When all tasks are complete, `/tk-done` auto-archives the OpenSpec change.

---

## OpenCode Commands

| Command | Description |
|---------|-------------|
| `/os-proposal <id>` | Create a new OpenSpec proposal |
| `/os-change [id]` | Show active changes or details for one change |
| `/tk-bootstrap <id> "<title>" [--yes]` | Design epic + 3-8 chunky tasks (preview by default, `--yes` to execute) |
| `/tk-queue [next\|all\|<change-id>]` | Show ready/blocked tickets |
| `/tk-start <id...> [--parallel N]` | Start ticket(s) and implement |
| `/tk-done <id> [change-id]` | Close ticket, sync progress, merge, push |
| `/tk-refactor` | Merge duplicates, clean up backlog |

---

## Why "3-8 Chunky Tickets"?

This workflow favors **3-8 deliverable-sized tickets** over fine-grained checkboxes:

- **Better for Context:** Agents focus on one "chunk" (e.g., "Implement Auth API") rather than 10 tiny tasks.
- **Cleaner Backlog:** `tk ready` stays readable.
- **Flexibility:** Implementation details can evolve within a chunky ticket.

---

## Parallel Execution

### Safe Mode (default)

With `useWorktrees: true`, each ticket gets an isolated git worktree:

```bash
/tk-start ab-101 ab-102 ab-103 --parallel 3
```

### Simple Mode

With `useWorktrees: false`, all work happens in the main working tree. Parallel execution requires `unsafe.allowParallel: true`.

---

## Documentation

For more details, see the `docs/` folder:

- [**Model Selection Rationale**](docs/models.md) — Why we use strong reasoning models for planning and fast OSS models for implementation
- [**Versioning and Releases**](docs/versioning.md) — SemVer scheme, release process, version pinning

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `jq: command not found` | Install jq: `brew install jq` |
| `os-tk: command not found` | Add `~/.local/bin` to PATH |
| `tk query` fails | Install jq |
| Empty queue | Run `tk blocked` to see what's waiting |

---

## License

MIT

## Credits

This workflow is built on and extends:

- **[OpenSpec](https://github.com/fission-ai/openspec)** — Spec-driven changes (proposal → apply → archive)
- **[ticket (tk)](https://github.com/wedow/ticket)** — Git-backed task tracking with ready/blocked queues
- **[OpenCode](https://opencode.dev)** — Multi-agent orchestration via slash commands
