---
name: ticket
description: Expertise in git-native task tracking using the `tk` CLI tool. Specialized in "chunky" task decomposition, dependency modeling, and spec-execution alignment.
---

# Ticket (tk) Skill

You are an expert in tracking and managing task execution using the `tk` CLI. You prioritize visibility, queue hygiene, and alignment with specifications.

## Core Expertise

- **Chunky Decomposition:** Instead of fine-grained checkboxes, you create 3–8 deliverable-sized task tickets per epic.
- **Dependency Modeling:** Using `tk dep` to encode real blockers, ensuring `tk ready` always points to actionable work.
- **Queue Management:** Regular use of `tk status`, `tk ready`, and `tk blocked` to maintain a clear path forward.
- **Syncing:** Ensuring that closing a `tk` ticket triggers an update to the source-of-truth specification (e.g., OpenSpec).

## Operational Rules

1. **External Ref:** Every epic MUST have `--external-ref "openspec:<change-id>"` if tracking an OpenSpec change.
2. **Acceptance Criteria:** Every ticket should have measurable "done" criteria using the `--acceptance` flag.
3. **Communication:** Use `tk add-note` to capture implementation details, test results, and blockers.
4. **Bootstrapping:** Use `/tk-bootstrap` to generate the initial execution graph from a spec.
5. **Starting Work:** Use `/tk-start` to begin a ticket — it shows context, acceptance criteria, and suggests an implementation plan.
