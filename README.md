# OpenSpec + Ticket (os-tk) Workflow

A lightweight, agent-friendly workflow that combines:

- **OpenSpec** for spec-driven changes (proposal -> apply -> archive)
- **ticket (`tk`)** for git-backed task tracking (ready/blocked queues + dependencies)
- **Multi-agent support** for OpenCode, Claude Code, Factory/Droid, and more

This repo is a template. Use `os-tk` to install the workflow into any project, giving *any* coding agent consistent operating rules via `AGENTS.md`, while agent-specific platforms get their own commands and skills.

---

## Quick Start

```bash
# 1. Install os-tk (one-time, global)
curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/v0.5.0/install.sh | bash

# 2. Add ~/.local/bin to PATH (if not already)
export PATH="$HOME/.local/bin:$PATH"

# 3. Initialize the workflow in your project
cd your-project
os-tk init                              # OpenCode only (default)
os-tk init --agent opencode,claude      # OpenCode + Claude Code
os-tk init --agent all                  # All platforms

# 4. Commit the workflow files
git add config.json opencode AGENTS.md .gitignore  # adjust based on selected agents
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
curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/v0.5.0/install.sh | bash
```

Replace `v0.2.0` with the desired version tag.

### Option 2: Manual Install

Download the script directly:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/legout/openspec-ticket-opencode-starter/v0.5.0/os-tk -o ~/.local/bin/os-tk
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
| `os-tk init [options]` | Initialize project (sync + apply + update AGENTS.md) |
| `os-tk sync [--agent <platforms>]` | Download agent files from templateRepo@templateRef |
| `os-tk apply [--agent <platforms>]` | Re-apply config to agents (no network, no AGENTS.md) |
| `os-tk version` | Show os-tk version and project templateRef |

### Agent Platform Options

| Platform | Directory | Description |
|----------|-----------|-------------|
| `opencode` | `.opencode/` | OpenCode format (default) |
| `claude` | `.claude/` | Claude Code format |
| `factory` | `.factory/` | Factory/Droid format |
| `pi` | `.pi/` | Pi coding agent (requires subagent extension) |
| `all` | All above | Install all platforms |

Examples:
```bash
os-tk init --agent opencode,claude    # Multiple platforms
os-tk sync --agent factory             # Sync specific platform
os-tk apply --agent all               # Apply config to all
```

---

## Configuration

After running `os-tk init`, configuration is stored in `config.json`.

**Note:** The example below shows the full OpenCode config. If you initialize without OpenCode, the `reviewer` section will be smaller and omit multi-model scouting fields.

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
  },
  "reviewer": {
    "autoTrigger": false,
    "categories": ["spec-compliance", "tests", "security", "quality"],
    "createTicketsFor": ["error"],
    "skipTags": ["no-review", "wip"],
    "scouts": [
      { "id": "opus45", "model": "google/antigravity-claude-opus-4-5-thinking", "reasoningEffort": "max" },
      { "id": "gpt52",  "model": "openai/gpt-5.2-codex", "reasoningEffort": "high" },
      { "id": "mini",   "model": "openai/gpt-5.1-codex-mini", "reasoningEffort": "high" },
      { "id": "grok",   "model": "opencode/grok-fast" }
    ],
    "adaptive": { "enabled": true },
    "aggregatorStrong": { "model": "openai/gpt-5.2", "reasoningEffort": "medium" }
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
| `reviewer.scouts` | List of models for parallel review scouting (OpenCode only) |
| `reviewer.adaptive` | Enable adaptive (complexity-based) review (OpenCode only) |
| `reviewer.autoTrigger` | `false` (manual /tk-review) or `true` (auto after /tk-done) |

See [docs/configuration.md](docs/configuration.md) for complete reference.

### Updating the Workflow

To update to a newer version:

1. Edit `config.json` and change `templateRef` to the new tag (or `latest`)
2. Run `os-tk sync` to download updated files
3. Commit the changes

---

## What Gets Installed

Running `os-tk init` creates/updates these files in your project:

```
config.json              # Project config (commit this)

# OpenCode (--agent opencode, default)
.opencode/
  agent/
    os-tk-planner.md       # Planning + orchestration agent
    os-tk-worker.md        # Implementation agent
    os-tk-reviewer.md      # Code review agent
  command/
    os-change.md           # View OpenSpec changes
    os-proposal.md         # Create proposals
    tk-bootstrap.md        # Design + create epic + tasks
    tk-queue.md            # View ready/blocked
    tk-start.md            # Start implementation
    tk-done.md             # Close + sync + merge
    tk-review.md           # Code review after completion
    tk-run.md              # Autonomous execution loop
    tk-refactor.md         # Clean up backlog
  skill/
    openspec/SKILL.md      # OpenSpec expertise
    ticket/SKILL.md        # tk expertise
    os-tk-workflow/SKILL.md # Workflow decision trees

# Claude Code (--agent claude)
.claude/
  agents/os-tk-planner.md, os-tk-worker.md, os-tk-reviewer.md
  commands/os-breakdown.md, os-change.md, os-proposal.md, tk-bootstrap.md, ...
  skills/openspec/, ticket/, os-tk-workflow/

# Factory/Droid (--agent factory)
.factory/
  droids/os-tk-planner.md, os-tk-worker.md, os-tk-reviewer.md
  commands/os-breakdown.md, os-change.md, os-proposal.md, tk-bootstrap.md, ...
  skills/openspec/, ticket/, os-tk-workflow/

AGENTS.md                  # Agent-agnostic workflow rules (all platforms)
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
| `/tk-review <id>` | Review completed ticket, create fix tickets if needed |
| `/tk-run [--all] [--max-cycles N]` | Autonomous loop: start → done → review → repeat |
| `/tk-refactor` | Merge duplicates, clean up backlog |

---

## Why "3-8 Chunky Tickets"?

This workflow favors **3-8 deliverable-sized tickets** over fine-grained checkboxes:

- **Better for Context:** Agents focus on one "chunk" (e.g., "Implement Auth API") rather than 10 tiny tasks.
- **Cleaner Backlog:** `tk ready` stays readable.
- **Flexibility:** Implementation details can evolve within a chunky ticket.

## File-Aware Dependency Management

Tickets can optionally include file predictions in their frontmatter to enable safer parallel execution:

```yaml
---
id: ab-123
status: open
files-modify:
  - src/api.ts
  - src/utils.ts
files-create:
  - src/types/User.ts
---
```

### How It Works

1. **Prediction:** When creating tickets via `/tk-bootstrap`, the agent predicts which files will be modified/created.
2. **Overlap Detection:** `/tk-queue --all` detects when multiple tickets would modify the same files.
3. **Auto-Dependencies:** Overlapping tickets automatically get `tk dep` relationships added to serialize work.
4. **Conflict Prevention:** `/tk-queue --next` skips tickets that would conflict with in-progress work.

### Benefits

- **Merge Safety:** Reduces merge conflicts when working in parallel
- **Visibility:** See which files a ticket will touch before starting
- **Automatic Serialization:** No need to manually track file-based dependencies

### Querying File Predictions

Use `tk query` to see file predictions:

```bash
# Show all file predictions for ready tickets
tk ready | jq -r '.[] | select(.status == "open") | "\(.id): \(.files_modify // [])"'

# Find tickets that modify a specific file
tk query | jq -r '.[] | select(.files_modify[]? == "src/api.ts") | .id'
```

---

## Review Automation

After completing a ticket, `/tk-review` analyzes the implementation against OpenSpec specs. On OpenCode, this triggers a multi-model adaptive review pipeline. On other platforms, it runs a single-agent review.

```bash
# Review a completed ticket
/tk-review ab-101
```

Review checks:
- **spec-compliance**: Does implementation match requirements?
- **tests**: Are acceptance criteria covered?
- **security**: Obvious vulnerabilities?
- **quality**: Code patterns, DRY, error handling?

If issues are found, fix tickets are automatically created and linked to the original.

### Autonomous Mode (Ralph Mode)

Two options depending on your use case:

**Internal (small features, bug fixes):**
```bash
# Process one ticket through full lifecycle
/tk-run T-123

# Process entire epic
/tk-run --epic otos-653a

# Internal ralph mode (subtask isolation)
/tk-run --ralph --max-cycles 10
```

**External (large greenfield projects):**
```bash
# Full process isolation per ticket
./ralph.sh

# Process only one epic
./ralph.sh --epic otos-653a

# Dry run to see what would execute
./ralph.sh --dry-run
```

| Mode | Context Isolation | Use Case |
|------|-------------------|----------|
| `/tk-run --ralph` | Subtasks (partial) | Quick iterations, small changes |
| `./ralph.sh` | Full process (complete) | Greenfield, multi-hour autonomous runs |

Safety valves:
- `--max-cycles N`: Stop after N iterations
- Exits on empty queue
- Stops if a critical (P0) fix ticket is created

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

- [**Multi-Agent Support**](docs/multi-agent-support.md) — Platform comparison, installation, and configuration
- [**Configuration Reference**](docs/configuration.md) — Complete guide to all config options
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
