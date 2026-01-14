# Multi-Agent Platform Support

The os-tk workflow supports multiple AI coding agent platforms, allowing teams to use the same spec-driven workflow regardless of their preferred tooling.

---

## Supported Platforms

| Platform | Directory | Description |
|----------|-----------|-------------|
| **OpenCode** | `.opencode/` | Canonical format. Slash commands, agents, skills. |
| **Claude Code** | `.claude/` | Anthropic's coding agent. Commands, agents, skills. |
| **Factory/Droid** | `.factory/` | Factory AI droids with reasoning effort config. |
| **Universal** | `.agent/` | Platform-agnostic format for other agents. |

---

## Installation

### Single Platform (Default)

By default, os-tk installs only the OpenCode format:

```bash
os-tk init
```

This creates `.opencode/` with agents, commands, and skills.

### Multiple Platforms

Use the `--agent` flag to install for multiple platforms:

```bash
# OpenCode + Claude Code
os-tk init --agent opencode,claude

# All platforms
os-tk init --agent all
```

### Updating an Existing Project

To add platforms to an existing project:

```bash
# Add Claude Code support
os-tk sync --agent claude

# Add all missing platforms
os-tk sync --agent all
```

---

## Platform Comparison

### Directory Structure

```
# OpenCode (.opencode/)
.opencode/
  agent/
    os-tk-planner.md
    os-tk-worker.md
    os-tk-reviewer.md
  command/
    tk-start.md
    tk-done.md
    ...
  skill/
    openspec/SKILL.md
    ticket/SKILL.md
    os-tk-workflow/SKILL.md

# Claude Code (.claude/)
.claude/
  agents/
    planner.md
    worker.md
    reviewer.md
  commands/
    openspec/
      proposal.md
      ...
    tk/
      start.md
      done.md
      ...
  skills/
    openspec/SKILL.md
    ticket/SKILL.md
    os-tk-workflow/SKILL.md

# Factory/Droid (.factory/)
.factory/
  droids/
    planner.md
    worker.md
    reviewer.md
  commands/
    tk-start.md
    tk-done.md
    ...
  skills/
    openspec/SKILL.md
    ticket/SKILL.md
    os-tk-workflow/SKILL.md

# Universal (.agent/)
.agent/
  agents/
    planner.md
    worker.md
    reviewer.md
  commands/
    tk-start.md
    tk-done.md
    ...
  skills/
    openspec.md
    ticket.md
    os-tk-workflow.md
```

### Feature Comparison

| Feature | OpenCode | Claude Code | Factory/Droid | Universal |
|---------|----------|-------------|---------------|-----------|
| **Slash commands** | `/tk-start` | `/tk start` | `/tk-start` | Varies |
| **Agent routing** | Via frontmatter | Via tools array | Via reasoningEffort | Manual |
| **Model config** | In agent file | In settings.json | In droid frontmatter | Manual |
| **Skills** | Directory-based | Directory-based | Directory-based | File-based |
| **Subtasks** | Native | Native | Native | Manual |

### Command Syntax Differences

| Action | OpenCode | Claude Code |
|--------|----------|-------------|
| Start ticket | `/tk-start T-001` | `/tk start T-001` |
| Close ticket | `/tk-done T-001` | `/tk done T-001` |
| View queue | `/tk-queue` | `/tk queue` |
| Create proposal | `/os-proposal foo` | `/openspec proposal foo` |

---

## Configuration

### Stored Agent Selection

When you run `os-tk init --agent opencode,claude`, the selection is saved in `.os-tk/config.json`:

```json
{
  "agents": "opencode,claude",
  "templateRepo": "legout/openspec-ticket-opencode-starter",
  "templateRef": "v0.1.0",
  ...
}
```

Subsequent `os-tk sync` and `os-tk apply` commands will use this stored value unless overridden with `--agent`.

### Model & Review Configuration

Model and multi-model review settings in `config.json` apply to **OpenCode only**:

```json
{
  "planner": {
    "model": "openai/gpt-5.2",
    "reasoningEffort": "high"
  },
  "reviewer": {
    "scouts": [...],
    "adaptive": { "enabled": true }
  }
}
```

For other platforms:
- **Claude Code**: Configure models via Claude Code settings; review is single-agent.
- **Factory/Droid**: Edit droid frontmatter directly; review is single-agent.
- **Universal**: Platform-specific configuration; review is single-agent.

---

## Platform-Specific Notes

### OpenCode

The canonical source. All other formats are derived from OpenCode.

- Full model configuration via `os-tk apply`
- Supports subagent spawning for parallel execution
- Skills loaded via `skill` frontmatter field

### Claude Code

Uses Claude Code's native format with nested command directories.

- Commands use `$1`, `$2` positional arguments
- Tools specified in `tools` array in frontmatter
- Supports `!` for inline bash in command files
- Configure models via Claude Code's settings UI

### Factory/Droid

Uses Factory's droid format with `reasoningEffort` in frontmatter.

- Commands use `$ARGUMENTS` for all args
- Droids have `reasoningEffort` field (low/medium/high)
- Tool categories: `read-only`, `edit`, `bash`

### Universal

A platform-agnostic format for agents that don't have dedicated support.

- Simpler structure (skills as single files)
- No platform-specific frontmatter
- Designed to be adapted to any agent system

---

## Workflow Files

All platforms share the same `AGENTS.md` file, which provides agent-agnostic workflow rules. This ensures consistent behavior regardless of which agent platform interprets the instructions.

```markdown
<!-- In AGENTS.md -->
## Core Rules

1. **Specs before code** - Create an OpenSpec proposal before implementing.
2. **One change = one epic** - Create a tk epic with `--external-ref "openspec:<change-id>"`.
3. **3-8 chunky tickets** - Break work into deliverables (DB/API/UI/tests/docs).
4. **Queue-driven execution** - Pick work via `tk ready`, never blind implementation.
5. **`/tk-done` is mandatory** - Always use `/tk-done` to close work.
```

---

## Adding Support for New Platforms

To add support for a new agent platform:

1. **Create directory structure** under the platform's config directory
2. **Port agents** from `.agent/agents/` adapting to platform format
3. **Port commands** from `.agent/commands/` adapting syntax
4. **Port skills** from `.agent/skills/` adapting format
5. **Update `os-tk` script** with new file arrays and sync logic

Contributions welcome! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Commands not recognized | Check platform-specific command syntax (e.g., `/tk start` vs `/tk-start`) |
| Models not applying | Only OpenCode supports automatic model config; others need manual setup |
| Skills not loading | Verify skill directory structure matches platform expectations |
| Sync fails for platform | Check that templateRef contains files for that platform |

---

## See Also

- [Configuration Reference](configuration.md)
- [Model Selection Rationale](models.md)
- [Versioning and Releases](versioning.md)
