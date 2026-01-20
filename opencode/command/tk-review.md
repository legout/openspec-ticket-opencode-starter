---
description: Review a ticket using 4-role + lead reviewer pipeline [ulw]
agent: os-tk-reviewer-lead
---

# /tk-review <ticket-id> [options]

Use your **openspec** skill to validate and review a completed or in-progress ticket.

## Arguments

- `ticket-id`: The ticket to review (required)
- `--roles <comma-list>`: Override which roles run (e.g., `--roles bug-footgun,spec-audit`)
- `--policy <gate|gate-with-followups|followups-only>`: Override review policy
- `--base <ref>`: Override base ref for diff (advanced)

## EXECUTION CONTRACT

### ALLOWED
- `openspec show <change-id>` - Read OpenSpec proposal/specs
- `tk show <ticket-id>` - Read ticket details and notes
- `tk query` - Check for existing followup tickets
- `git *` - Compute diff, resolve merge-base
- Read files for context

### FORBIDDEN
- `tk start`, `tk close` - These are separate commands
- Edit code files - This is review-only
- `tk add-note`, `tk create`, `tk link` - Delegated to lead reviewer

---

## Step 1: Validate Ticket is Open

**Precondition:** Ticket must be **open**.

```
# Get ticket status
STATUS=$(tk show $TICKET_ID | grep -E "^status:" | awk '{print $2}')

if [[ "$STATUS" != "open" ]]; then
  echo "Error: Ticket is closed (status: $STATUS)"
  echo "Review requires open ticket. Reopen with: tk reopen $TICKET_ID"
  exit 1
fi
```

**Reason:** Review should happen **before** closing, not after merge.

---

## Step 2: Resolve Base Ref (Deterministic)

Prefer `origin/main` if available, otherwise use `main`:

```
# Check if origin exists
if git remote | grep -q "origin"; then
  BASE_REF="origin/${MAIN_BRANCH:-main}"
else
  BASE_REF="${MAIN_BRANCH:-main}"
fi

# Get merge-base commit
MERGE_BASE_SHA=$(git merge-base ${BASE_REF} HEAD)
BASE_SHA=$(git rev-parse ${BASE_REF})
HEAD_SHA=$(git rev-parse HEAD)

# Compute diff stat
DIFF_STAT=$(git diff --stat ${MERGE_BASE_SHA}...HEAD)
DIFF_HASH=$(git diff ${MERGE_BASE_SHA}...HEAD | sha256sum | awk '{print $1}')
```

---

## Step 3: Prepare Inputs for Lead Reviewer

Gather and pass to `os-tk-reviewer-lead`:

```
Inputs for lead reviewer:
- ticket-id: $TICKET_ID
- --roles: $ROLES (from flag, or all enabled from config)
- --policy: $POLICY (from flag, or from config)
- --base: $BASE_REF (from flag, or computed)
- Metadata:
  - baseRef: $BASE_REF
  - baseSha: $BASE_SHA
  - headSha: $HEAD_SHA
  - mergeBaseSha: $MERGE_BASE_SHA
  - diffStat: $DIFF_STAT
  - diffHash: $DIFF_HASH
```

**Delegate to lead reviewer:**
```
Invoke os-tk-reviewer-lead subagent with:
- All parsed flags
- Diff metadata
- Ticket context
```

The lead reviewer will:
1. Spawn role reviewers in parallel
2. Collect and merge their findings
3. Decide PASS/FAIL based on config thresholds
4. Create followups (if policy allows)
5. Write consolidated review note via `tk add-note`

---

## Step 4: Report Result

After lead reviewer completes, show:

```
## Review Complete

Ticket: $TICKET_ID
Result: PASS | FAIL | SKIPPED
Policy: $POLICY
Diff: $DIFF_STAT
Hash: $DIFF_HASH

Next steps:
- If PASS: /tk-done $TICKET_ID to close and merge
- If FAIL: Fix issues, then re-run /tk-review $TICKET_ID
- If SKIPPED: Check skipTags in config or remove ticket tags
```

---

## Legacy Flag Deprecation (One Release Window)

Map old flags to new `--roles`:

| Old flag | New mapping | Warning |
|----------|-------------|----------|
| `--spec-audit` | `--roles spec-audit` | "Deprecated: use --roles instead" |
| `--shallow-bugs` | `--roles bug-footgun` | "Deprecated: use --roles instead" |
| `--second-opinion` / `--seco` | `--roles second-opinion` | "Deprecated: use --roles instead" |
| `--ultimate` | `--roles bug-footgun,spec-audit,generalist,second-opinion` | "Deprecated: use --roles instead" |
| `--fast` | N/A | "Removed: Adaptive routing removed. Use --roles to select roles." |

**Behavior:**
- Accept old flags for one release
- Print deprecation warning with new syntax
- Internally map to `--roles`

**Removed flags (no longer supported):**
- `--ultimate` (use `--roles` for all roles)
- `--fast` / `--shallow-bugs` (use `--roles bug-footgun`)
- `--strong` (removed: single lead reviewer)
- `--working-tree` (now default behavior)

---

## Skip Tags

If ticket has a tag listed in `reviewer.skipTags` (default: `["no-review", "wip"]`):
- Lead reviewer will write a SKIPPED note with metadata
- `/tk-done` in gate mode treats SKIPPED as explicit bypass (allows close)

Check ticket tags:
```
TAGS=$(tk show $TICKET_ID | grep -E "^tags:" | sed 's/tags: //')
SKIP_TAGS=$(jq -r '.reviewer.skipTags[]' config.json 2>/dev/null || echo "no-review,wip")

for skip_tag in $SKIP_TAGS; do
  if echo "$TAGS" | grep -q "$skip_tag"; then
    echo "Ticket has skip tag: $skip_tag"
    echo "Lead reviewer will write SKIPPED note."
  fi
done
```

---

## Configuration

Review behavior is controlled in `config.json`:

```json
{
  "reviewer": {
    "policy": "gate",
    "blockSeverities": ["error"],
    "blockMinConfidence": 80,
    "followupSeverities": ["warning"],
    "followupMinConfidence": 60,
    "skipTags": ["no-review", "wip"],
    "roles": {
      "bug-footgun": { "enabled": true, "model": "..." },
      "spec-audit": { "enabled": true, "model": "..." },
      "generalist": { "enabled": true, "model": "..." },
      "second-opinion": { "enabled": true, "model": "..." }
    }
  }
}
```

---

## Examples

### Basic review (all enabled roles):
```
/tk-review otos-0159
```

### Review specific roles:
```
/tk-review otos-0159 --roles bug-footgun,spec-audit
```

### Review with policy override:
```
/tk-review otos-0159 --policy gate-with-followups
```

### Review with custom base:
```
/tk-review otos-0159 --base origin/main
```

### Legacy flag (deprecation warning):
```
/tk-review otos-0159 --ultimate
⚠️  Deprecated: --ultimate removed. Use --roles bug-footgun,spec-audit,generalist,second-opinion
```

---

## Exit Conditions

**Success:**
- Lead reviewer completes and writes note
- Result reported to user

**Error:**
- Ticket is closed → Instruct to reopen
- Config invalid → Fix config and retry
- Diff resolution fails → Check git state

**Note:** Role reviewer failures are handled by lead reviewer (partial results still merge, missing roles noted in note).
