---
description: Autonomous execution loop - start, done, review, repeat
argument-hint: [--all] [--max-cycles N] [--ralph]
allowed-tools: Bash(tk:*), Read
---

# /tk-run $@

Parse flags:
- `--all`: Process all ready tickets (default: one cycle)
- `--max-cycles N`: Limit iterations (default: 10)
- `--epic <id>`: Only process tickets from this epic
- `--ralph`: Full autonomous mode with review

## Current Context

Ready tickets:
!`tk ready`

## Execution Loop

```
1. /tk-queue --next
   ├─ Empty → Exit "No more work"
   │
   └─ Has ticket → Spawn: /tk-start <id>
                   ├─ Success → /tk-done <id>
                   │            ├─ Success → /tk-review (if ralph)
                   │            │            ├─ Passed → Loop
                   │            │            └─ Failed → Create fix
                   │            └─ Failure → Ask human
                   │
                   └─ Failure → Ask human
```

## Safety Valves

1. **Max cycles**: Stop after N iterations
2. **Empty queue**: Exit when no more ready tickets
3. **Critical fix**: Stop if P0 fix ticket created
4. **Human interrupt**: User can interrupt

## Output Format

```
## Autonomous Run Complete

### Completed
- <ticket-id>: <title>

### Created (fixes)
- <ticket-id>: <title>

### Remaining
- X tickets still ready
- Y tickets blocked

### Exit Reason
<empty queue | max cycles | critical fix>
```

## Contract

**ALLOWED:** Spawning worker subtasks, `tk ready`, `tk query`
**FORBIDDEN:** Direct code editing (delegate to workers)
