# Template Manifest

This manifest defines the template assets for platform-specific rendering.

## Template Structure

```
templates/
├── shared/
│   ├── agent/
│   │   ├── os-tk-planner.md.template
│   │   ├── os-tk-worker.md.template
│   │   ├── os-tk-orchestrator.md.template
│   │   ├── os-tk-agent-*.md.template
│   │   ├── os-tk-reviewer-lead.md.template
│   │   └── os-tk-reviewer-role-*.md.template
│   ├── command/
│   │   └── tk-*.md.template
│   └── skill/
│       └── */
│           └── SKILL.md.template
└── platform/
    └── overlays.md
```

## Files

- templates/platform/overlays.md
- templates/shared/agent/os-tk-planner.md.template
- templates/shared/agent/os-tk-worker.md.template
- templates/shared/agent/os-tk-orchestrator.md.template
- templates/shared/agent/os-tk-agent-spec.md.template
- templates/shared/agent/os-tk-agent-design.md.template
- templates/shared/agent/os-tk-agent-safety.md.template
- templates/shared/agent/os-tk-agent-scout.md.template
- templates/shared/agent/os-tk-agent-quality.md.template
- templates/shared/agent/os-tk-agent-simplify.md.template
- templates/shared/agent/os-tk-reviewer-lead.md.template
- templates/shared/agent/os-tk-reviewer-role-spec-audit.md.template
- templates/shared/agent/os-tk-reviewer-role-bug-footgun.md.template
- templates/shared/agent/os-tk-reviewer-role-second-opinion.md.template
- templates/shared/agent/os-tk-reviewer-role-generalist.md.template
- templates/shared/command/tk-start.md.template
- templates/shared/skill/openspec/SKILL.md.template
- templates/shared/skill/ticket/SKILL.md.template
- templates/shared/skill/tk-frontmatter/SKILL.md.template
- templates/shared/skill/os-tk-workflow/SKILL.md.template

## Render Targets

For each template, render outputs to:

| Platform | Agent Output | Command Output | Skill Output |
|----------|--------------|----------------|--------------|
| opencode | `opencode/agent/*.md` | `opencode/command/*.md` | `opencode/skill/*/SKILL.md` |
| claude   | `claude/agents/*.md` | `claude/commands/*.md` | `claude/skills/*/SKILL.md` |
| factory | `factory/droids/*.md` | `factory/commands/*.md` | `factory/skills/*/SKILL.md` |
| pi       | `pi/agents/*.md` | `pi/prompts/*.md` | `pi/skills/*/SKILL.md` |

## Conditional Rendering

Templates use handlebars-style conditionals:

- `{{#opencode}}...{{/opencode}}` - opencode-only content
- `{{#pi}}...{{/pi}}` - pi-only content
- `{{#claude}}...{{/claude}}` - claude-only content
- `{{#factory}}...{{/factory}}` - factory-only content

## Rendering Process

1. Read template from `templates/shared/`
2. Apply platform-specific conditionals
3. Write rendered output to platform directory
4. Verify directory mapping matches platform conventions

## Validation Rules

- All rendered files must have valid YAML frontmatter
- Directory structure must match platform conventions
- Shared content must be identical across platforms (except overlays)
- Platform-specific fields must not leak to other platforms
