---
description: Run autonomous ticket lifecycle (start → review → done) [ulw]
agent: os-tk-planner
---

# /tk-run [<ticket-id>] [--epic <epic-id>] [--ralph] [--max-cycles N]

Use your **os-tk-workflow** skill section "/tk-run Workflow" for the updated sequence.

---

## Arguments

- `ticket-id`: Single ticket to process (optional, if omitted uses queue)
- `--epic <epic-id>`: Process all tickets under epic until closed
- `--ralph`: Loop until queue is empty (full Ralph mode)
- `--max-cycles N`: Limit number of iterations (default: 10)

---

## EXECUTION CONTRACT

### ALLOWED
- `tk ready`, `tk blocked`, `tk show` - Queue and ticket inspection
- `tk query` - Query ticket state
- Delegated commands: `/tk-start`, `/tk-review`, `/tk-done`

### FORBIDDEN
- Direct code edits (delegate to `/tk-start`)
- Direct ticket closing (delegate to `/tk-done`)
- Skipping review gate in gate policies

---

## Step 1: Determine Mode

**Single ticket mode:**
```
If ticket-id is provided:
  Process just that ticket: start → review → done
  Exit after completion
```

**Epic mode:**
```
If --epic is provided:
  Loop until all tickets under epic are closed
  Each cycle: select ready ticket under epic → start → review → done
  Exit when: epic has no more open tickets
```

**Ralph mode:**
```
If --ralph is provided:
  Loop until queue is empty (tk ready returns nothing)
  Each cycle: select next ready ticket → start → review → done
  Exit when: tk ready is empty or max-cycles reached
```

---

## Step 2: Cycle Logic (NEW: start → review → done)

**IMPORTANT:** The order has changed from start→done→review to **start→review→done**.

### 2.1 Select next ticket

```bash
# Get next ready ticket
if [[ -n "$EPIC_ID" ]]; then
  # Epic mode: get ready tickets under epic
  NEXT_TICKET=$(tk query '.parent == "'$EPIC_ID'" and .status == "open"' | jq -r '.[0].id')
else
  # Ralph mode or queue mode: get next ready ticket
  NEXT_TICKET=$(tk ready | head -1 | awk '{print $1}')
fi

if [[ -z "$NEXT_TICKET" ]]; then
  echo "No more tickets to process"
  exit 0
fi
```

### 2.2 Start ticket

```bash
echo "Starting: $NEXT_TICKET"
/tk-start $NEXT_TICKET

START_RESULT=$?

if [[ $START_RESULT -ne 0 ]]; then
  echo "Failed to start ticket: $NEXT_TICKET"
  echo "Stopping for human intervention"
  exit 1
fi
```

### 2.3 Review ticket (NEW GATE)

```bash
echo "Reviewing: $NEXT_TICKET"
/tk-review $NEXT_TICKET

REVIEW_RESULT=$?

if [[ $REVIEW_RESULT -ne 0 ]]; then
  echo "Review failed for ticket: $NEXT_TICKET"
  echo "Review gate: BLOCKED (ticket remains open)"

  # Load config to check policy
  POLICY=$(jq -r '.reviewer.policy // "gate"' config.json)

  if [[ "$POLICY" == "gate" ]] || [[ "$POLICY" == "gate-with-followups" ]]; then
    echo "Policy: $POLICY (blocks on review FAIL)"
    echo "Stopping for human intervention"
    echo ""
    echo "To fix issues:"
    echo "  1. Review findings in ticket notes"
    echo "  2. Fix blocking issues"
    echo "  3. Re-run: /tk-review $NEXT_TICKET"
    echo "  4. Retry: /tk-done $NEXT_TICKET"
    exit 1
  else
    # followups-only policy: always PASS
    echo "Policy: followups-only (review failures non-blocking)"
    echo "Proceeding to /tk-done (followup tickets may have been created)"
  fi
fi

# Extract review result for reporting
LATEST_REVIEW=$(tk show $NEXT_TICKET | grep -A 30 "## Review Summary")
REVIEW_RESULT_TEXT=$(echo "$LATEST_REVIEW" | grep "Result:" | awk '{print $2}')

echo "Review result: $REVIEW_RESULT_TEXT"
```

### 2.4 Close ticket

```bash
echo "Closing: $NEXT_TICKET"
/tk-done $NEXT_TICKET

DONE_RESULT=$?

if [[ $DONE_RESULT -ne 0 ]]; then
  echo "Failed to close ticket: $NEXT_TICKET"
  echo "Stopping for human intervention"
  exit 1
fi
```

---

## Step 3: Exit Conditions

### Max cycles limit

```bash
CYCLE=$((CYCLE + 1))

if [[ $CYCLE -ge $MAX_CYCLES ]]; then
  echo "Max cycles reached ($MAX_CYCLES)"
  echo "Stopping"
  exit 0
fi
```

### Critical (P0) fix ticket created

```bash
# Check if P0 fix ticket was created during review
P0_FIXES=$(tk query '.priority == 0 and .status == "open"' | jq -r '.[].id')

if [[ -n "$P0_FIXES" ]]; then
  echo "Critical (P0) fix ticket(s) created: $P0_FIXES"
  echo "Stopping for human review"
  exit 1
fi
```

### Empty queue (Ralph/epic mode)

```bash
if [[ -n "$EPIC_ID" ]]; then
  # Epic mode: check if more tickets open under epic
  REMAINING=$(tk query '.parent == "'$EPIC_ID'" and .status != "closed"' | jq 'length')
  if [[ $REMAINING -eq 0 ]]; then
    echo "All tickets under epic $EPIC_ID are closed"
    exit 0
  fi
else
  # Ralph mode: check if queue is empty
  if ! tk ready | grep -q .; then
    echo "Queue is empty"
    exit 0
  fi
fi
```

---

## Step 4: Loop (Repeat from Step 2)

```
# Decrement max-cycles counter
# Go back to Step 2
```

---

## Examples

### Single ticket:
```
/tk-run otos-0159
Starting: otos-0159
Reviewing: otos-0159
  Review result: PASS
Closing: otos-0159
✓ Complete
```

### Epic mode:
```
/tk-run --epic otos-70e5 --max-cycles 5
Cycle 1/5
  Starting: otos-0159
  Reviewing: otos-0159 (PASS)
  Closing: otos-0159 ✓
Cycle 2/5
  Starting: otos-833b
  Reviewing: otos-833b (PASS)
  Closing: otos-833b ✓
...
```

### Ralph mode:
```
/tk-run --ralph --max-cycles 10
Starting: otos-0159
  Review result: PASS
  Closing: otos-0159 ✓
Starting: otos-054e
  Review result: PASS
  Closing: otos-054e ✓
Queue is empty
✓ All done
```

### Review fails (gate policy):
```
/tk-run --ralph
Starting: otos-0159
  Review result: FAIL
  Review gate: BLOCKED (ticket remains open)
  Policy: gate (blocks on review FAIL)
  Stopping for human intervention

To fix issues:
  1. Review findings in ticket notes
  2. Fix blocking issues
  3. Re-run: /tk-review otos-0159
  4. Retry: /tk-done otos-0159
```

### P0 fix ticket created:
```
/tk-run --ralph
Starting: otos-0159
  Review result: PASS (with followups)
  Critical (P0) fix ticket(s) created: otos-a1b2
  Stopping for human review
```

---

## Config Options

```json
{
  "reviewer": {
    "policy": "gate",
    "autoTrigger": false
  }
}
```

- `reviewer.policy`: Controls gate behavior
  - `gate`: Stops on review FAIL (default)
  - `gate-with-followups`: Stops on review FAIL
  - `followups-only`: Does not stop on FAIL

---

## Notes

- **Sequence changed:** Now uses start→review→done (review BEFORE close)
- **Gate enforcement:** `/tk-done` validates PASS review for current HEAD/diffHash
- **Auto-rerun:** Optional safety feature in `/tk-done` with guardrails
- **P0 stops:** Critical fix tickets always stop the loop for human review
