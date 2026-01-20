# Platform Template Inventory

This document captures the classification of platform-specific assets into **shared templates** vs **platform-specific overlays**, as part of the refactor to a **template-based generation system**.

## Source of Truth

**Opencode is the canonical source** for shared workflow semantics. Platform-specific assets are generated from templates derived from opencode content, with platform-specific overlays applied for frontmatter, directory naming, and execution checks.

See [template-workflow.md](template-workflow.md) for details on the template rendering system.

## Asset Categories

### Agents (os-tk-*.md)
| File | Shared? | Platform Deltas |
|-------|----------|------------------|
| os-tk-planner.md | ✅ Yes | opencode: view-only, edit/write deny; others: allow bootstrapping, temp 0.5 |
| os-tk-worker.md | ✅ Yes | opencode: temp 0.2; others: temp 0.75 |
| os-tk-orchestrator.md | ✅ Yes | identical across platforms |
| os-tk-agent-*.md (advisors) | ✅ Yes | identical across platforms |
| os-tk-reviewer-lead.md | ✅ Yes | identical across platforms |
| os-tk-reviewer-role-*.md | ✅ Yes | identical across platforms |

### Commands/Prompts (tk-*.md)
| File | Shared? | Platform Deltas |
|-------|----------|------------------|
| tk-done.md | ✅ Yes | opencode: review gate + auto-rerun; others: simplified |
| tk-run.md | ✅ Yes | opencode: explicit cycle logic; others: skill stubs |
| tk-start.md | ✅ Yes | pi: subagent pre-check; opencode: parallelism details |
| tk-review.md | ✅ Yes | body aligned; frontmatter varies |
| tk-bootstrap.md | ✅ Yes | identical across platforms |
| tk-queue.md | ✅ Yes | identical across platforms |
| tk-refactor.md | ✅ Yes | identical across platforms |

### Skills
| File | Shared? | Platform Deltas |
|-------|----------|------------------|
| os-tk-workflow/SKILL.md | ✅ Yes | opencode: gate-first (start→review→done); pi: old order |
| openspec/SKILL.md | ✅ Yes | opencode/pi: shorter; claude/factory: CLI reference |
| ticket/SKILL.md | ✅ Yes | opencode/pi: shorter; claude/factory: CLI reference |
| tk-frontmatter/SKILL.md | ✅ Yes | identical everywhere |

## Directory Layout Differences

| Platform | Agent Dir | Command/Prompt Dir | Skill Dir |
|----------|-------------|-------------------|-----------|
| opencode | agent/ | command/ | skill/ |
| claude | agents/ | commands/ | skills/ |
| factory | droids/ | commands/ | skills/ |
| pi | agents/ | prompts/ | skills/ |

## Frontmatter Convention Differences

| Platform | Fields Used |
|----------|---------------|
| opencode | agent:, [ulw], subtask, background |
| claude/factory | argument-hint, allowed-tools |
| pi | minimal; adds "Pre-execution Check" |

## Key Findings

1. **High reuse potential**: ~70% of content is identical across platforms
2. **Frontmatter is platform-specific**: Should be isolated in overlays
3. **Workflow semantics drift**: opencode has gate-first pipeline; others reference older order
4. **Opencode is canonical**: Use as source-of-truth for shared content
5. **Sync strategy needed**: Render templates from opencode + apply platform overlays

---

*This inventory supports the design doc analysis in `openspec/changes/refactor-platform-templates/design.md`.*
