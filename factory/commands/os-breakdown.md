---
description: Break down a PRD/plan into OpenSpec proposals (skill-driven)
argument-hint: <source> [--with-tickets]
---

# /os-breakdown

Use the **openspec** skill section “/os-breakdown Workflow” for the full process.

**Arguments:** $ARGUMENTS  
Parse `source` (file/folder/URL/inline) and optional `--with-tickets`.

## Contract (brief)
**ALLOWED:** Read sources, create OpenSpec change files, call `/tk-bootstrap` if `--with-tickets`.  
**FORBIDDEN:** Implement code or modify specs outside `openspec/changes/`.

## Steps (thin wrapper)
1. Ingest the source.
2. Follow the **openspec** skill workflow to draft proposals + tasks.
3. Validate with `openspec validate <id> --strict`.
4. If `--with-tickets`, run `/tk-bootstrap <id> "<title>" --yes`.

STOP after proposal creation. Await user approval before implementation.
