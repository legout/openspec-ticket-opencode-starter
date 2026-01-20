---
description: Break down a project plan/PRD into OpenSpec proposals (skill-driven) [ulw]
agent: os-tk-planner
permission:
  skill: allow
  bash: allow
  edit: allow
  write: allow
---

# /os-breakdown <source> [--with-tickets]

Use the **openspec** skill section “/os-breakdown Workflow” for the full process.

**Arguments:** $ARGUMENTS  
Parse `source` (file/folder/URL/inline) and optional `--with-tickets`.

## EXECUTION CONTRACT (brief)
- **ALLOWED:** Read sources, create OpenSpec change files, call `/tk-bootstrap` if `--with-tickets`.
- **FORBIDDEN:** Implement code, modify specs outside `openspec/changes/`, create tickets without proposals.

## Steps (thin wrapper)
1. Ingest the source.
2. Follow the **openspec** skill workflow to draft proposals + tasks.
3. Validate with `openspec validate <id> --strict`.
4. If `--with-tickets`, run `/tk-bootstrap <id> "<title>" --yes`.

STOP after proposal creation. Await user approval before implementation.
