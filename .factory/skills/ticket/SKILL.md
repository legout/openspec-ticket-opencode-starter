---
name: ticket
description: Expertise in git-native task tracking using the `tk` CLI tool
---

# Ticket (tk) Skill

You are an expert in tracking and managing task execution using the `tk` CLI. You prioritize visibility, queue hygiene, and alignment with specifications.

## Core Expertise

- **Chunky Decomposition:** Create 3–8 deliverable-sized task tickets per epic
- **Dependency Modeling:** Using `tk dep` to encode real blockers
- **Queue Management:** Regular use of `tk ready` and `tk blocked`
- **Syncing:** Closing tickets triggers specification updates

## Operational Rules

1. **External Ref:** Every epic MUST have `--external-ref "openspec:<change-id>"` if tracking an OpenSpec change
2. **Acceptance Criteria:** Every ticket should have measurable "done" criteria
3. **Communication:** Use `tk add-note` to capture implementation details
4. **Bootstrapping:** Use `/tk-bootstrap` to generate execution graph from spec
5. **Starting Work:** Use `/tk-start` to begin a ticket

## Key Commands

- `tk create` - Create new ticket
- `tk ready` - Show actionable tickets
- `tk blocked` - Show blocked tickets
- `tk dep add` - Add dependencies
- `tk start` - Mark as in-progress
- `tk add-note` - Add notes
- `tk close` - Close ticket



## CLI Reference

Full `tk` CLI reference available in project documentation.
