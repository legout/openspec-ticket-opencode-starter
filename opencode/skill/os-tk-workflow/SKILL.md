---
name: os-tk-workflow
description: Orchestrating the OpenSpec + ticket workflow. Decision trees for command selection, phase transitions, anti-patterns to avoid, and autonomous execution guidance.
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

### User Mentions a Bug

```
1. Is it a quick fix (< 1 hour)?
   ├─ YES → Create lightweight proposal or skip?
   │        Recommendation: Create minimal proposal for traceability
   │        /os-proposal fix-<bug-name>
   │        /tk-bootstrap fix-<bug-name> "Fix: <description>" --yes
   │
   └─ NO  → Full proposal workflow
            /os-proposal fix-<bug-name>
            (Include root cause analysis in design.md)
```

### User Has a PRD/Plan Document

```
1. Is it a comprehensive plan with multiple features?
   ├─ YES → /os-breakdown @document.md --with-tickets
   │        This creates multiple proposals + tickets in one pass
   │
   └─ NO  → Single feature? Use standard flow
            /os-proposal <id>
            /tk-bootstrap <id> "<title>"
```

### User Wants to See Progress

```
1. At what level?
   ├─ All changes   → openspec list + tk ready
   ├─ One change    → /os-change <id>
   ├─ Ready tickets → /tk-queue or /tk-queue --all
   └─ Blocked work  → tk blocked
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

## Phase Transitions

### Planning → Execution

**Trigger:** All proposals approved, tickets created
**Action:** `/tk-queue` to see what's ready
**Gate:** Must have at least one "ready" ticket

### Execution → Execution (next ticket)

**Trigger:** `/tk-done <id>` completes successfully
**Action:** Check if more tickets are ready
**Gate:** Previous ticket must be closed and merged

### Execution → Archive

**Trigger:** All tickets under an epic are closed
**Action:** `/tk-done` auto-archives the OpenSpec change
**Gate:** `tk query '.parent == "<epic-id>" and .status != "closed"'` returns empty

### Manual Archive (edge case)

**When:** Implementation complete but tickets not properly linked
**Action:** `openspec archive <change-id> --yes`
**Warning:** Prefer letting `/tk-done` handle this automatically

## Command → Agent Mapping

| Command | Agent | Purpose |
|---------|-------|---------|
| `/os-change` | planner | View OpenSpec changes (read-only) |
| `/os-proposal` | worker | Create proposal files |
| `/os-breakdown` | planner | Analyze PRD, create multiple proposals |
| `/tk-bootstrap` | orchestrator | Design + create tickets |
| `/tk-queue` | orchestrator | Queue management + file-aware deps |
| `/tk-start` | worker | Implement ticket |
| `/tk-done` | worker | Close, sync, merge, push |
| `/tk-review` | reviewer | Post-implementation review |
| `/tk-run` | planner | Autonomous loop (spawns workers) |
| `/tk-refactor` | planner | Clean up backlog |

## Anti-Patterns

### DO NOT: Skip the proposal

**Bad:** Jump straight to coding when user asks for a feature
**Why:** Loses traceability, no spec to review against, harder to onboard others
**Fix:** Always create at least a minimal `/os-proposal`

### DO NOT: Create tickets without proposals

**Bad:** `/tk-bootstrap` without corresponding OpenSpec change
**Why:** Tickets should link to specs via `external_ref`
**Fix:** Create proposal first, then bootstrap

### DO NOT: Bypass /tk-done

**Bad:** Manually close tickets with `tk close`, skip merge/push
**Why:** Breaks sync with OpenSpec tasks.md, may not auto-archive
**Fix:** Always use `/tk-done <id>` to complete work

### DO NOT: Edit code during planning

**Bad:** Start implementing while in `/tk-bootstrap` or `/tk-queue`
**Why:** Violates agent contract, mixes planning with execution
**Fix:** Wait for explicit `/tk-start` command

### DO NOT: Implement multiple tickets in one session

**Bad:** `/tk-start T-001` then also do T-002 work in same context
**Why:** Commits get tangled, harder to review and revert
**Fix:** Complete T-001 with `/tk-done`, then start T-002

### DO NOT: Force push or skip hooks

**Bad:** `git push --force`, `--no-verify`
**Why:** Destroys team history, bypasses quality gates
**Fix:** Use proper rebase workflow, fix hook failures

## Ralph Mode (Autonomous Execution)

### When to Use Ralph Mode

- **Internal (`/tk-run --ralph`):** Small features, bug fixes, subtask isolation
- **External (`./ralph.sh`):** Large greenfield projects, full process isolation

### Safety Valves

1. **Max cycles:** `--max-cycles N` limits iterations
2. **Empty queue:** Exits when no more ready tickets
3. **Critical fix:** Stops if P0 fix ticket is created during review
4. **Human interrupt:** User can Ctrl+C at any time

### Ralph Decision Flow

**NOTE:** Sequence changed from start→done→review to **start→review→done** (gate-first workflow).

```
1. /tk-queue --next
   ├─ Empty → Exit "No more work"
   │
   └─ Has ticket → /tk-start <id>
                   ├─ Success → /tk-review <id>
                   │            ├─ PASS → /tk-done <id>
                   │            │         ├─ Success → Loop to step 1
                   │            │         └─ Failure → Ask human
                   │            ├─ FAIL → Stop (gate policy)
                   │            │         └─ Instruct to fix and re-run /tk-review
                   │            └─ Error → Ask human
                   │
                   └─ Failure → Ask human
```

**Gate policy behavior:**
- In `gate` or `gate-with-followups` modes: review FAIL stops the loop
- Ticket remains open; user must fix issues and re-run `/tk-review`
- After re-review passes, continue with `/tk-done`
- `followups-only` mode does not stop on FAIL (review failures non-blocking)

## Parallel Execution

### Safe Mode (useWorktrees: true)

Each ticket gets an isolated worktree + branch:
```bash
/tk-start T-001 T-002 T-003 --parallel 3
# Creates: .worktrees/T-001/, .worktrees/T-002/, .worktrees/T-003/
```

Benefits:
- No merge conflicts during work
- Each ticket has clean state
- Easy to abandon one without affecting others

### Simple Mode (useWorktrees: false)

All work in main working tree:
- Only parallel if `unsafe.allowParallel: true`
- Higher conflict risk
- Commits may bundle unrelated work

### File-Aware Dependencies

Tickets can include file predictions:
```yaml
files-modify: [src/api.ts]
files-create: [src/types/User.ts]
```

`/tk-queue --all` auto-creates dependencies to prevent overlapping file modifications.

## /tk-review Workflow

Use this to execute reviews using the 4-role + lead pipeline.

**Precondition:** Ticket must be **open**. Review happens **before** closing, not after merge.

### 1. Validate ticket is open

```
# Check ticket status
STATUS=$(tk show <ticket-id> | grep -E "^status:" | awk '{print $2}')

if [[ "$STATUS" != "open" ]]; then
  Error: Ticket is closed (status: $STATUS)
  Review requires open ticket. Reopen with: tk reopen <ticket-id>
fi
```

### 2. Resolve base ref (deterministic)

```
# Prefer origin if available, else use local main
if git remote | grep -q "origin"; then
  BASE_REF="origin/${MAIN_BRANCH:-main}"
else
  BASE_REF="${MAIN_BRANCH:-main}"
fi

# Get merge-base commit
MERGE_BASE_SHA=$(git merge-base ${BASE_REF} HEAD)
BASE_SHA=$(git rev-parse ${BASE_REF})
HEAD_SHA=$(git rev-parse HEAD)

# Compute diff stat and hash
DIFF_STAT=$(git diff --stat ${MERGE_BASE_SHA}...HEAD)
DIFF_HASH=$(git diff ${MERGE_BASE_SHA}...HEAD | sha256sum | awk '{print $1}')
```

### 3. Check for skip tags

```
# Get ticket tags
TICKET_TAGS=$(tk show <ticket-id> | grep -E "^tags:" | sed 's/tags: //')

# Get skipTags from config
SKIP_TAGS=$(jq -r '.reviewer.skipTags[]' config.json 2>/dev/null || echo "no-review,wip")

# Check if ticket has any skip tag
for skip_tag in $SKIP_TAGS; do
  if echo "$TICKET_TAGS" | grep -q "$skip_tag"; then
    Write SKIPPED note with metadata (base/head/merge-base/diffHash)
    Exit early (no role reviewers run)
  fi
done
```

### 4. Orchestrate role reviewers

Spawn enabled role reviewers in parallel (via subagent calls):

**Role reviewers:**
- `bug-footgun` - diff-focused bug/security scan
- `spec-audit` - OpenSpec/spec compliance
- `generalist` - regression, intentionality, code quality
- `second-opinion` - alternative perspective, edge cases

Use `--roles` flag if provided, otherwise use all enabled roles from config.

Each role outputs a structured envelope:
```json
{
  "role": "role-name",
  "findings": [...]
}
```

### 5. Lead reviewer merges findings

**Dedupe key:** `(category, normalized_title, primary_file)`

**Resolution:**
```javascript
severity = MAX(findings.map(f => f.severity))  // error > warning > info
confidence = MIN(findings.map(f => f.confidence))  // conservative
sources = findings.map(f => f.role)  // which roles found it
agreement = sources.length  // e.g., "2/4 roles flagged this"
```

**Evidence guardrail:**
- If `severity === "error"` but `evidence` is missing/weak:
  - Downgrade to `"warning"`
  - Note in description: "Downgraded from error due to weak evidence"

### 6. Decide PASS/FAIL (config-driven)

Load config (`reviewer.policy`, `blockSeverities`, `blockMinConfidence`):

```javascript
hasBlocker = findings.some(f =>
  config.blockSeverities.includes(f.severity) &&
  f.confidence >= config.blockMinConfidence
)

pass = !hasBlocker
```

### 7. Create followups (policy-dependent)

```javascript
shouldCreateFollowup = severity in followupSeverities && confidence >= followupMinConfidence
```

**Policy semantics:**
- **gate**: Never create followups (even for warnings)
- **gate-with-followups**: Create followups only when PASS (no blockers)
- **followups-only**: Always create followups (warnings + errors)

**Idempotency:** Use stable key deduplication to avoid duplicate followups.

### 8. Write consolidated note

```markdown
## Review Summary (YYYY-MM-DD)
**Result:** PASS | FAIL
**Policy:** gate | gate-with-followups | followups-only
**Base:** ${baseRef} (${baseSha})
**Head:** ${headSha}
**Merge Base:** ${mergeBaseSha}
**Diff:** ${diffStat}
**Hash:** ${diffHash}

### Blocking Findings (must fix)
| Category | Severity | Confidence | Finding | Evidence | Sources |
|----------|----------|------------|---------|----------|---------|
| security | error | 90 | Missing auth check | src/api.ts:23 | spec-audit, bug-footgun |

### Non-Blocking Findings
| Category | Severity | Confidence | Finding | Evidence |
|----------|----------|------------|---------|----------|
| quality | warning | 70 | TODO not addressed | src/user.ts:45 |

### Follow-ups Created
- T-XXX: Fix missing auth check (linked)
- T-YYY: Address TODO in user service (linked)
```

**SKIPPED format (if skip tag present):**
```markdown
## Review Summary (YYYY-MM-DD)
**Result:** SKIPPED
**Reason:** Ticket has tag "no-review"
**Policy:** ${policy}
**Head:** ${headSha}
```

### Flags

- `--roles <comma-list>`: Override which roles run
- `--policy <gate|gate-with-followups|followups-only>`: Override policy
- `--base <ref>`: Override base ref (advanced)

**Deprecation:**
- Old flags (`--ultimate`, `--fast`, `--shallow-bugs`, etc.) mapped to `--roles` with warnings
- `--working-tree` removed (now default behavior)

Lead reviewer is the only writer (`tk add-note`, `tk create`, `tk link`).

## /tk-run Workflow

Use this for autonomous execution loops.

**NOTE:** Sequence changed from start→done→review to **start→review→done** (gate-first workflow).

1. **Mode**:
   - Single ticket: run once.
   - `--epic`: loop until all tickets under epic closed.
   - `--ralph`: loop until `tk ready` is empty.

2. **Cycle (start → review → done)**:
   - Select next ready ticket.
   - `/tk-start <id>` → `/tk-review <id>` → `/tk-done <id>`
   - If `/tk-review` returns FAIL and policy is `gate` or `gate-with-followups`:
     - Stop the loop (ticket remains open)
     - Instruct user to fix issues and re-run `/tk-review`
   - If `/tk-review` returns PASS:
     - Proceed to `/tk-done` (which validates review is fresh)

3. **Exit**:
   - Stop at `--max-cycles`.
   - Stop when queue/epic has no more ready tickets.
   - Stop on P0 fix ticket creation (critical issue requires human review).
   - Stop when `/tk-review` FAILs (in `gate` or `gate-with-followups` modes).

**Policy impact on /tk-run:**
- `gate` (default): Review FAIL stops loop; user must fix and re-run manually
- `gate-with-followups`: Review FAIL stops loop; warnings only create followups on PASS
- `followups-only`: Review FAIL does NOT stop loop; all failures create followups

## Troubleshooting

### "No tickets are ready"

1. Run `tk blocked` to see what's waiting
2. Check if dependencies are satisfied
3. Verify epic exists with `tk query '.type == "epic"'`

### "Change not found"

1. Run `openspec list` to see active changes
2. Check spelling of change ID
3. May be archived: check `openspec/changes/archive/`

### "Ticket not linked to epic"

1. Ticket needs `parent` field set
2. Epic needs `external_ref` pointing to OpenSpec change
3. Fix: `tk create --parent <epic-id> ...`

### "Tasks.md not synced"

1. `/tk-done` syncs by matching ticket title to task checkbox
2. If titles don't match, manual sync needed
3. Verify with `cat openspec/changes/<id>/tasks.md`

### "Worktree already exists"

1. Previous work not cleaned up
2. Check: `git worktree list`
3. Remove: `git worktree remove .worktrees/<id>`
4. Then retry `/tk-start`
