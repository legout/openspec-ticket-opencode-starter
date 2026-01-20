---
name: os-tk-workflow
description: Orchestrating the OpenSpec + ticket workflow
---

# OpenSpec + Ticket Workflow Orchestration

This skill teaches you how to orchestrate the full os-tk workflow, from user intent to completed work.

## Workflow Overview

```
User Intent → Planning → Execution → Archive
     │            │           │          │
     │       /os-proposal  /tk-start   /tk-done
     │       /tk-bootstrap     │     (auto-archives)
     │            │            │
     └────────────┴────────────┴──────────────────┘
                         tk ready
```





## Workflow Order

Standard pipeline with review gate.

See opencode documentation for full details.


## Decision Trees

### User Wants a New Feature

```
1. Does an OpenSpec proposal exist?
   ├─ NO  → /os-proposal <id>
   │        Then: /tk-bootstrap <id> "<title>"
   │        Then: /tk-queue to see ready work
   │
   └─ YES → Are there tickets?
            ├─ NO  → /tk-bootstrap <id> "<title>"
            └─ YES → /tk-queue or /tk-start <id>
```

### User Wants to Start Work

```
1. Is there a ready ticket?
   ├─ NO  → /tk-queue to find one, or /tk-bootstrap if none exist
   │
   └─ YES → Single or multiple?
            ├─ Single → /tk-start <id>
            └─ Multiple → /tk-start <id1> <id2> --parallel 2
```

## Command → Agent Mapping

| Command | Agent | Purpose |
|---------|-------|---------|
| `/os-change` | planner | View OpenSpec changes |
| `/os-proposal` | worker | Create proposal files |
| `/os-breakdown` | planner | Analyze PRD |
| `/tk-bootstrap` | orchestrator | Design + create tickets |
| `/tk-queue` | orchestrator | Queue management |
| `/tk-start` | worker | Implement ticket |
| `/tk-done` | worker | Close, sync, merge |
| `/tk-review` | reviewer | Post-implementation review |

## Anti-Patterns

### DO NOT: Skip the proposal
**Bad:** Jump straight to coding
**Fix:** Always create at least a minimal `/os-proposal`

### DO NOT: Bypass /tk-done
**Bad:** Manually close tickets with `tk close`
**Fix:** Always use `/tk-done <id>` to complete work

### DO NOT: Implement multiple tickets in one session
**Bad:** Do T-001 and T-002 work in same context
**Fix:** Complete T-001 with `/tk-done`, then start T-002`


## Troubleshooting

### "No tickets are ready"
1. Run `tk blocked` to see what's waiting
2. Check if dependencies are satisfied
3. Verify epic exists

### "Worktree already exists"
1. Previous work not cleaned up
2. Check: `git worktree list`
3. Remove: `git worktree remove .worktrees/<id>`
