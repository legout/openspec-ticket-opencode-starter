---
name: os-tk-workflow
description: |
  Orchestrating the OpenSpec + ticket workflow. 
  Decision trees for command selection, phase transitions, anti-patterns to avoid, and autonomous execution guidance.
  Keywords: workflow, orchestration, ralph, parallel, planning
---

# OpenSpec + Ticket Workflow Orchestration

This skill teaches you how to orchestrate the full os-tk workflow, from user intent to completed work.

## Workflow Overview

```
User Intent → Planning → Execution → Archive
     │            │           │          │
     │       /os-proposal  /tk-start   /tk-done
     │       /tk-bootstrap     │     (auto-archives)
```

## Decision Trees

### User Wants a New Feature

```
1. Does an OpenSpec proposal exist?
   ├─ NO  → /os-proposal <id>
   │        Then: /tk-bootstrap <id> "<title>"
   │
   └─ YES → Are there tickets?
            ├─ NO  → /tk-bootstrap <id> "<title>"
            └─ YES → /tk-queue or /tk-start <id>
```

### User Has a PRD/Plan Document

```
1. Is it a comprehensive plan with multiple features?
   ├─ YES → /os-breakdown @document.md --with-tickets
   └─ NO  → /os-proposal <id>
```

## Command → Agent Mapping

| Command | Agent | Purpose |
|---------|-------|---------|
| `/os-change` | planner | View OpenSpec changes |
| `/os-proposal` | worker | Create proposal files |
| `/os-breakdown` | planner | Analyze PRD, create proposals |
| `/tk-bootstrap` | planner | Design + create tickets |
| `/tk-queue` | planner | View ready/blocked |
| `/tk-start` | worker | Implement ticket |
| `/tk-done` | worker | Close, sync, merge, push |
| `/tk-review` | reviewer | Post-implementation review |
| `/tk-run` | planner | Autonomous loop |
| `/tk-refactor` | planner | Clean up backlog |

## Anti-Patterns

### DO NOT: Skip the proposal
Always create at least a minimal `/os-proposal` for traceability.

### DO NOT: Bypass /tk-done
Always use `/tk-done <id>` to complete work (syncs OpenSpec).

### DO NOT: Edit code during planning
Wait for explicit `/tk-start` command.

## Ralph Mode (Autonomous Execution)

Safety valves:
- `--max-cycles N` limits iterations
- Exits when queue is empty
- Stops on P0 fix ticket creation

## Parallel Execution

### Safe Mode (useWorktrees: true)
Each ticket gets an isolated worktree + branch.

### Simple Mode (useWorktrees: false)
All work in main working tree. Only parallel if `unsafe.allowParallel: true`.
