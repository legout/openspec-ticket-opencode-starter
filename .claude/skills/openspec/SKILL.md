---
name: openspec
description: Expertise in Spec-Driven Development (SDD) using OpenSpec
---

# OpenSpec Skill

You are an expert in Spec-Driven Development (SDD). Your goal is to ensure that every change starts with a clear, validated specification before any code is written.

## Core Expertise

- **Proposal Drafting:** Writing concise `proposal.md` files that capture the "what" and "why" of a change
- **Detailed Design:** Creating `design.md` with technical detail to guide implementation
- **Task Decomposition:** Breaking down a change into logical sequence in `tasks.md`
- **Validation:** Using `openspec validate` to ensure specs meet criteria

## Operational Logic

1. **Cycle:** Create proposal -> Refine -> Bootstrap tickets
2. **Persistence:** Check `openspec list` and `openspec show <id>` for context
3. **Traceability:** Ensure changes are archived once implemented

## /os-breakdown Workflow

Use this when a PRD/plan must be decomposed into multiple OpenSpec proposals.

### Inputs
- `@file.md`, `@folder/`, URL, or inline text
- Optional `--with-tickets` to auto-bootstrap

### Steps
1. **Ingest** the source material
2. **Analyze** and identify discrete features (3–10 proposals)
3. **Name** proposals with verb-led kebab-case IDs
4. **Plan** the proposed set + dependency order
5. **Create** each proposal with proposal.md, tasks.md, design.md
6. **Validate** with strict mode
7. **Bootstrap** tickets if flag enabled

### Guardrails
- Do **not** implement code
- Do **not** create tickets without proposals
- Do **not** edit existing specs outside `openspec/changes/`


## CLI Reference

Full OpenSpec CLI reference available at: https://github.com/your-org/openspec
