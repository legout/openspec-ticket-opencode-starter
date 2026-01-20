# Template Workflow

This document explains the template-based architecture used by os-tk to generate platform-specific assets from shared source-of-truth templates.

## Overview

The os-tk workflow uses a **template-based generation system** where:

- **Opencode is the source of truth** for shared workflow semantics
- **Templates define conditional logic** for platform-specific behavior
- **Platform outputs are generated**, not manually maintained
- **Sync/apply commands regenerate** outputs from templates

This ensures consistency across platforms while allowing platform-specific customization through overlays.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Source of Truth                         │
│                  (opencode content)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              templates/shared/*.template                     │
│  - Agent definitions with platform conditionals              │
│  - Command definitions with platform conditionals            │
│  - Skill definitions with platform conditionals              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│           templates/platform/overlays.md                     │
│  - Platform directory mappings                              │
│  - Frontmatter conventions                                  │
│  - Platform-specific execution checks                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Render Engine (os-tk)                     │
│  - Applies handlebars conditionals                          │
│  - Merges overlays                                          │
│  - Validates outputs                                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Generated Platform Outputs                      │
│  .opencode/  .claude/  .factory/  .pi/                      │
└─────────────────────────────────────────────────────────────┘
```

## Template Structure

### Shared Templates

Located in `templates/shared/`:

```
templates/shared/
├── agent/
│   ├── os-tk-planner.md.template       # Planning agent
│   ├── os-tk-worker.md.template        # Implementation agent
│   ├── os-tk-orchestrator.md.template  # Orchestration agent
│   ├── os-tk-agent-spec.md.template    # Spec advisor
│   ├── os-tk-agent-design.md.template  # Design advisor
│   ├── os-tk-agent-safety.md.template  # Safety advisor
│   ├── os-tk-agent-scout.md.template   # Scout/research advisor
│   ├── os-tk-agent-quality.md.template # Quality/testing advisor
│   ├── os-tk-agent-simplify.md.template # Simplification advisor
│   ├── os-tk-reviewer-lead.md.template # Review lead agent
│   ├── os-tk-reviewer-role-bug-footgun.md.template
│   ├── os-tk-reviewer-role-spec-audit.md.template
│   ├── os-tk-reviewer-role-generalist.md.template
│   └── os-tk-reviewer-role-second-opinion.md.template
├── command/
│   ├── os-change.md.template
│   ├── os-proposal.md.template
│   ├── tk-bootstrap.md.template
│   ├── tk-queue.md.template
│   ├── tk-start.md.template
│   ├── tk-done.md.template
│   ├── tk-review.md.template
│   ├── tk-run.md.template
│   └── tk-refactor.md.template
└── skill/
    ├── openspec/SKILL.md.template
    ├── ticket/SKILL.md.template
    ├── os-tk-workflow/SKILL.md.template
    └── tk-frontmatter/SKILL.md.template
```

### Platform Overlays

Located in `templates/platform/overlays.md`:

- **Directory mappings**: Maps template categories to platform-specific directory names
- **Frontmatter conventions**: Platform-specific YAML frontmatter fields
- **Agent-specific deltas**: Temperature, permissions, tool access
- **Command-specific deltas**: Logic variations (e.g., review gate enforcement)
- **Pre-execution checks**: Platform requirements (e.g., Pi subagent extension)

## Conditional Syntax

Templates use handlebars-style conditionals:

```markdown
{{#opencode}}
# OpenCode-specific content

This content only appears in opencode outputs.
{{/opencode}}

{{#pi}}
## Pre-execution Check

Verify the `subagent` extension is available:
```bash
pi ext list | grep subagent
```
{{/pi}}

{{#claude}}
## Claude-specific instructions

This content only appears in Claude Code outputs.
{{/claude}}

{{#factory}}
## Factory-specific instructions

This content only appears in Factory/Droid outputs.
{{/factory}}
```

### Nested Conditionals

Conditionals can be nested for complex logic:

```markdown
{{#opencode}}
{{#tk-done}}
OpenCode-specific tk-done logic with review gate enforcement.
{{/tk-done}}
{{/opencode}}
```

## Platform Directory Mapping

Each platform has different directory conventions:

| Platform | Agent Dir | Command Dir | Skill Dir |
|----------|-----------|-------------|-----------|
| opencode | `agent/`  | `command/`  | `skill/`  |
| claude   | `agents/` | `commands/` | `skills/` |
| factory  | `droids/` | `commands/` | `skills/` |
| pi       | `agents/` | `prompts/`  | `skills/` |

The render engine automatically applies these mappings when generating outputs.

## Render Commands

### `os-tk init`

Initializes a project with the workflow:

1. Downloads templates from `templateRepo@templateRef`
2. Renders templates for specified platforms (default: opencode)
3. Generates `config.json` with project settings
4. Updates `AGENTS.md` with workflow rules

```bash
os-tk init                              # OpenCode only
os-tk init --agent opencode,claude      # OpenCode + Claude Code
os-tk init --agent all                  # All platforms
```

### `os-tk sync`

Updates template sources and regenerates outputs:

1. Fetches latest templates from `templateRepo@templateRef`
2. Renders all platform outputs from templates
3. Applies platform-specific overlays
4. Validates generated files

```bash
os-tk sync                              # Sync all configured platforms
os-tk sync --agent claude               # Sync specific platform
```

### `os-tk apply`

Re-renders outputs from existing templates (no network):

1. Reads templates from local `templates/` directory
2. Applies config.json settings to frontmatter
3. Regenerates platform outputs
4. Validates generated files

```bash
os-tk apply                             # Apply to all platforms
os-tk apply --agent factory             # Apply to specific platform
```

## Source of Truth Model

### Opencode is Canonical

- **Shared semantics**: Opencode content defines the shared workflow logic
- **Template derivation**: Shared templates are derived from opencode content
- **Platform deltas**: Other platforms add overlays, not competing implementations

### Edit Hierarchy

1. **Source of truth**: Edit `templates/shared/*.template` for shared logic
2. **Platform customization**: Edit `templates/platform/overlays.md` for platform deltas
3. **Generated outputs**: Do NOT edit `.opencode/`, `.claude/`, etc. (overwritten on sync)

### Sync Behavior

- **Upstream updates**: Change `templateRef` and run `os-tk sync` to pull updates
- **Local customization**: Edit templates and run `os-tk apply` to regenerate
- **Conflict resolution**: Local template edits take precedence over upstream

## Validation Rules

The render engine enforces these validation rules:

1. **Valid YAML frontmatter**: All rendered files must have parseable YAML
2. **Directory structure**: Output directories must match platform conventions
3. **Shared content integrity**: Shared content must be identical across platforms (except overlays)
4. **No platform leakage**: Platform-specific content must not appear in other platforms
5. **Conditional coverage**: All conditionals must have valid platform targets

## Example: Platform-Specific Delta

### Template (tk-start.md.template)

```markdown
{{#opencode}}
## Parallel Execution

With `useWorktrees: true`, each ticket gets an isolated git worktree...

## Worktree Safety

Ticket branches follow the naming convention `ticket/<id>`...
{{/opencode}}

{{#pi}}
## Pre-execution Check

Verify you have the subagent extension installed:
```bash
pi ext list | grep subagent
```

## Simple Execution

Pi uses the main working tree for all operations...
{{/pi}}

## Shared Implementation

Both platforms implement the same core ticket workflow:
1. Read ticket details from `tk show <id>`
2. Implement acceptance criteria
3. Run tests
4. Mark complete for `/tk-done`
```

### Overlay (templates/platform/overlays.md)

```yaml
### tk-start
- **opencode**: Full parallelism logic + worktree details
- **pi**: Adds subagent pre-execution check
```

### Rendered Output (opencode/command/tk-start.md)

```markdown
## Parallel Execution

With `useWorktrees: true`, each ticket gets an isolated git worktree...

## Worktree Safety

Ticket branches follow the naming convention `ticket/<id>`...

## Shared Implementation

Both platforms implement the same core ticket workflow:
1. Read ticket details from `tk show <id>`
2. Implement acceptance criteria
3. Run tests
4. Mark complete for `/tk-done`
```

### Rendered Output (pi/prompts/tk-start.md)

```markdown
## Pre-execution Check

Verify you have the subagent extension installed:
```bash
pi ext list | grep subagent
```

## Simple Execution

Pi uses the main working tree for all operations...

## Shared Implementation

Both platforms implement the same core ticket workflow:
1. Read ticket details from `tk show <id>`
2. Implement acceptance criteria
3. Run tests
4. Mark complete for `/tk-done`
```

## Migration Path

### From Manual to Template-Based

If you have an existing os-tk installation with manually maintained platform files:

1. **Backup**: Commit your current state
2. **Initialize**: Run `os-tk init` to create template structure
3. **Diff**: Compare generated outputs with your manual files
4. **Customize**: Add any custom logic to templates as conditionals
5. **Switch**: Delete manual files, use template-generated outputs
6. **Commit**: Save template customizations to `templates/`

### Upstream Updates

To receive updates from the template repository:

1. **Check version**: Run `os-tk version` to see current `templateRef`
2. **Review changes**: Check GitHub releases for the new version
3. **Update ref**: Edit `config.json` to set new `templateRef`
4. **Sync**: Run `os-tk sync` to fetch and render updates
5. **Customize**: Re-apply any local template customizations if needed
6. **Test**: Verify generated outputs work correctly
7. **Commit**: Save the updated templates and config

## Troubleshooting

### Template Not Found

**Error**: `Template not found: templates/shared/agent/os-tk-planner.md.template`

**Solution**: Run `os-tk sync` to download template sources from `templateRepo@templateRef`.

### Render Validation Failed

**Error**: `Render validation failed: Invalid YAML frontmatter in .opencode/agent/os-tk-planner.md`

**Solution**:
1. Check template syntax in `templates/shared/agent/os-tk-planner.md.template`
2. Verify YAML frontmatter is properly formatted
3. Ensure conditionals are properly closed
4. Run `os-tk apply` to re-render

### Platform Directory Mismatch

**Error**: `Platform directory mismatch: expected 'agents/' but found 'agent/' for platform 'claude'`

**Solution**: Check `templates/platform/overlays.md` for correct directory mappings.

### Content Drift Across Platforms

**Issue**: Shared content differs between platforms

**Solution**:
1. Verify templates in `templates/shared/` are platform-agnostic
2. Check that platform-specific content is wrapped in conditionals
3. Run `os-tk apply` to re-render all platforms
4. Compare outputs to ensure shared content matches

## Best Practices

1. **Edit templates, not outputs**: Always edit `templates/shared/*.template`, never generated files
2. **Use conditionals**: Wrap platform-specific content in appropriate conditionals
3. **Document overlays**: Add platform deltas to `templates/platform/overlays.md`
4. **Test sync**: Run `os-tk apply` after template edits to validate
5. **Commit templates**: Save customizations to `templates/` directory
6. **Version pin**: Pin `templateRef` to specific tags for reproducibility
7. **Review updates**: Check changelog before updating `templateRef`

## Related Documentation

- [Platform Template Inventory](platform-template-inventory.md) — Classification of shared vs platform-specific assets
- [Configuration Reference](configuration.md) — Config options for template rendering
- [Multi-Agent Support](multi-agent-support.md) — Platform comparison and setup
