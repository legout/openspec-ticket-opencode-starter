---
name: ticket
description: |
  Expertise in git-native task tracking using the `tk` CLI tool. 
  Specialized in "chunky" task decomposition, dependency modeling, and spec-execution alignment.
  Keywords: tk, ticket, task, queue, ready, blocked
---

# Ticket (tk) Skill

You are an expert in tracking and managing task execution using the `tk` CLI. You prioritize visibility, queue hygiene, and alignment with specifications.

## Core Expertise

- **Chunky Decomposition:** Instead of fine-grained checkboxes, create 3–8 deliverable-sized task tickets per epic.
- **Dependency Modeling:** Using `tk dep` to encode real blockers, ensuring `tk ready` always points to actionable work.
- **Queue Management:** Regular use of `tk status`, `tk ready`, and `tk blocked` to maintain a clear path forward.
- **Syncing:** Ensuring that closing a `tk` ticket triggers an update to the source-of-truth specification (e.g., OpenSpec).

## tk CLI Reference

| Command | Purpose |
|---------|---------|
| `tk create` | Create a new ticket |
| `tk show <id>` | Show ticket details |
| `tk ready` | List tickets ready to start |
| `tk blocked` | List blocked tickets |
| `tk start <id>` | Mark ticket as in-progress |
| `tk close <id>` | Close a completed ticket |
| `tk dep <blocked> <blocker>` | Add dependency |
| `tk add-note <id> "<note>"` | Add note to ticket |
| `tk query '<filter>'` | Query tickets with jq filter |
| `tk link <id1> <id2>` | Link related tickets |

## Ticket Creation Flags

```bash
tk create \
  --type epic|task \
  --title "<title>" \
  --parent <epic-id> \
  --external-ref "openspec:<change-id>" \
  --acceptance "<done criteria>" \
  --priority 0|1|2 \
  --tags tag1,tag2
```

## Chunky Ticket Design

### Why 3-8 Tickets?
- **Better context:** Agents focus on one "chunk" (e.g., "Implement Auth API")
- **Cleaner backlog:** `tk ready` stays readable
- **Flexibility:** Implementation details evolve within a ticket

### Good Chunk Examples
| Good (Chunky) | Bad (Too Fine) |
|---------------|----------------|
| "Implement User API" | "Create user.ts file" |
| "Add Authentication" | "Write login function" |
| "Database Schema" | "Add id column" |

## Operational Rules

1. **External Ref:** Every epic MUST have `--external-ref "openspec:<change-id>"`
2. **Acceptance Criteria:** Every ticket should have measurable "done" criteria
3. **Communication:** Use `tk add-note` to capture implementation details
4. **Queue Hygiene:** Regularly check `tk ready` and `tk blocked`
