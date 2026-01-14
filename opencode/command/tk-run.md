---
description: Run full ticket lifecycle (start → done → review) with fresh context per step
agent: os-tk-planner
---

# /tk-run [<ticket-id>] [--epic <epic-id>] [--ralph] [--max-cycles N]

**Arguments:** $ARGUMENTS

Parse arguments:
- `ticket-id`: Single ticket to process (default mode)
- `--epic <epic-id>`: Process all tickets in the epic until complete
- `--ralph`: Process all ready tickets until queue empty (autonomous mode)
- `--max-cycles N`: Safety limit (default: 50 for ralph, 20 for epic, 1 for single)

## Mode Selection

| Mode | Behavior |
|------|----------|
| Default (single ticket) | Run one ticket through start → done → review |
| `--epic` | Loop until all tickets in epic are closed |
| `--ralph` | Loop until `tk ready` returns empty |

---

## Step 1: Load config and determine mode

Read `.os-tk/config.json` for:
- `reviewer.autoTrigger` (boolean: false = manual, true = auto after done)

Determine mode:
- If `--ralph`: ralph mode, max_cycles defaults to 50
- If `--epic <id>`: epic mode, max_cycles defaults to 20
- If `ticket-id`: single mode, max_cycles = 1
- If nothing: show usage and EXIT

## Step 2: Validate inputs

**Single ticket mode:**
```bash
tk show <ticket-id>
```
Verify ticket exists and is ready.

**Epic mode:**
```bash
tk show <epic-id>
```
Verify epic exists. Get list of child tickets.

**Ralph mode:**
```bash
tk ready
```
Verify queue is not empty.

---

## Step 3: Main execution loop

```
cycles = 0

WHILE cycles < max_cycles:
    
    # 3a. Select next ticket
    IF single mode:
        ticket = provided ticket-id
    ELIF epic mode:
        tickets = tk query '.parent == "<epic-id>" and .status != "closed"'
        ready_tickets = filter by tk ready
        IF ready_tickets is empty:
            PRINT "Epic complete. All tickets closed."
            EXIT
        ticket = first ready ticket
    ELIF ralph mode:
        ready = tk ready
        IF ready is empty:
            PRINT "Queue empty. Exiting."
            EXIT
        ticket = first ready ticket
    
    # 3b. Execute with FRESH CONTEXT per step
    # Each step runs as a subagent with its own context
    
    PRINT "=== Cycle $cycles: Processing $ticket ==="
    
    # STEP 1: Start (fresh subagent)
    SPAWN SUBAGENT:
        Read: AGENTS.md, openspec/project.md
        Read: tk show <ticket-id> (get epic, external_ref)
        Read: OpenSpec change files (proposal.md, tasks.md, specs/)
        Execute: /tk-start <ticket-id>
    
    # STEP 2: Done (fresh subagent)  
    SPAWN SUBAGENT:
        Read: AGENTS.md, openspec/project.md
        Read: tk show <ticket-id>
        Execute: /tk-done <ticket-id>
    
    # STEP 3: Review (fresh subagent, if enabled)
    IF reviewer.autoTrigger:
        SPAWN SUBAGENT:
            Read: AGENTS.md, openspec/project.md
            Read: tk show <ticket-id>
            Read: OpenSpec specs
            Execute: /tk-review <ticket-id>
            
            # Check for critical issues
            IF P0 fix ticket created:
                PRINT "Critical issue found. Stopping for human review."
                EXIT
    
    cycles++
    
    # Exit conditions
    IF single mode:
        PRINT "Ticket $ticket complete."
        EXIT
```

---

## Fresh Context Pattern

**Why fresh context matters:**
- Prevents hallucinations from stale information
- Each step reads current state from disk/git
- Long conversations don't pollute decision-making
- Matches how human developers work (check status before acting)

**What each subagent reads:**
1. `AGENTS.md` — Workflow rules
2. `openspec/project.md` — Project conventions
3. `tk show <ticket-id>` — Current ticket state
4. Epic's `external_ref` → OpenSpec change files
5. Relevant code files (determined by ticket)

**OpenCode implementation:**
```yaml
# Each step uses subtask: true to get fresh context
agent: os-tk-worker
subtask: true
```

---

## Output Summary

After each cycle:
```
=== Cycle 0: Processing T-123 ===
  ✓ /tk-start T-123 (implemented)
  ✓ /tk-done T-123 (committed, merged, pushed)
  ✓ /tk-review T-123 (passed, no issues)

=== Cycle 1: Processing T-456 ===
  ...
```

Final summary:
```
/tk-run complete:
  Mode: epic (otos-653a)
  Cycles: 5
  Tickets processed: T-123, T-456, T-789, T-012, T-345
  Exit reason: Epic complete
```

---

## EXECUTION CONTRACT

This command is an **orchestrator** that:
- Reads queue/ticket state
- Spawns subagents for actual work
- Tracks cycle count
- Handles exit conditions

**This command DOES NOT directly:**
- Edit code files
- Close tickets
- Merge branches

**Delegates to (as fresh subagents):**
- `/tk-start` — Implementation (os-tk-worker)
- `/tk-done` — Commit, sync, merge, push (os-tk-worker)
- `/tk-review` — Code review (os-tk-reviewer)

---

## Examples

```bash
# Process one ticket (default)
/tk-run T-123

# Process entire epic
/tk-run --epic otos-653a

# Ralph mode (internal): uses subtasks, shared process
/tk-run --ralph

# Ralph mode with lower cycle limit
/tk-run --ralph --max-cycles 10
```

---

## Internal vs External Ralph Mode

| Mode | Command | Context Isolation | Use Case |
|------|---------|-------------------|----------|
| Internal | `/tk-run --ralph` | Subtasks (partial) | Small features, bug fixes |
| External | `./ralph.sh` | Full process isolation | Large greenfield projects |

**Internal (`/tk-run --ralph`):**
- Uses OpenCode subtasks for each step
- Faster (no process spawn overhead)
- Context mostly fresh but shares parent process
- Good for: quick iterations, small changes

**External (`./ralph.sh`):**
- Spawns fresh `opencode` process per ticket
- Complete context isolation guaranteed
- Slower but more reliable for long runs
- Good for: greenfield, multi-hour autonomous runs

See `ralph.sh` in project root for external implementation.
