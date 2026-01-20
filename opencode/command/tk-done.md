---
description: Close ticket with review gate enforcement, sync OpenSpec tasks, auto-archive, merge to main, and push [ulw]
agent: os-tk-worker
---

# /tk-done <ticket-id> [change-id]

**Arguments:** $ARGUMENTS

Parse:
- `ticket-id`: first argument (required)
- `change-id`: second argument (optional; will be auto-detected from epic's external_ref)

---

## Step 1: Enforce Review Gate (NEW)

**Precondition:** Review must be PASS for current HEAD and diff hash (unless ticket has skip tag).

### 1.1 Find latest review note for ticket

```bash
# Find latest review note
LATEST_REVIEW=$(tk show $TICKET_ID | grep -A 30 "## Review Summary")

# Extract metadata
REVIEW_RESULT=$(echo "$LATEST_REVIEW" | grep "Result:" | awk '{print $2}')
REVIEW_HEAD=$(echo "$LATEST_REVIEW" | grep "Head:" | awk '{print $2}')
REVIEW_HASH=$(echo "$LATEST_REVIEW" | grep "Hash:" | awk '{print $2}')
```

### 1.2 Check for skip tags

```bash
# Get ticket tags
TICKET_TAGS=$(tk show $TICKET_ID | grep -E "^tags:" | sed 's/tags: //')

# Get skipTags from config
SKIP_TAGS=$(jq -r '.reviewer.skipTags[]' config.json 2>/dev/null || echo "no-review,wip")

# Check if ticket has any skip tag
HAS_SKIP=false
for skip_tag in $SKIP_TAGS; do
  if echo "$TICKET_TAGS" | grep -q "$skip_tag"; then
    HAS_SKIP=true
  fi
done
```

**If HAS_SKIP=true:** Skip review validation (explicit bypass allowed in gate mode).

### 1.3 Validate review status and freshness

```bash
# If no skip tag, enforce review
if [[ "$HAS_SKIP" == "false" ]]; then
  # Check if review exists
  if [[ -z "$LATEST_REVIEW" ]]; then
    echo "Error: No review found for ticket $TICKET_ID"
    echo "Required: Review must be PASS before closing"
    echo "Run: /tk-review $TICKET_ID"
    exit 1
  fi

  # Check if review is PASS
  if [[ "$REVIEW_RESULT" != "PASS" ]]; then
    echo "Error: Review failed (Result: $REVIEW_RESULT)"
    echo "Required: Review must be PASS before closing"
    echo "Run: /tk-review $TICKET_ID to re-run review"
    exit 1
  fi

  # Get current state
  CURRENT_HEAD=$(git rev-parse HEAD)
  CURRENT_HASH=$(git diff ${MERGE_BASE}...HEAD | sha256sum | awk '{print $1}')

  # Check if review is fresh (matches current HEAD/diff)
  if [[ "$REVIEW_HEAD" != "$CURRENT_HEAD" ]] || [[ "$REVIEW_HASH" != "$CURRENT_HASH" ]]; then
    echo "Error: Review is stale for current HEAD"
    echo "Review HEAD: $REVIEW_HEAD"
    echo "Current HEAD: $CURRENT_HEAD"
    echo "Review hash: $REVIEW_HASH"
    echo "Current hash: $CURRENT_HASH"
    echo ""
    echo "Required: Fresh review for current state"

    # Check if auto-rerun is enabled
    AUTO_RERUN=$(jq -r '.reviewer.autoRerunOnDone // false' config.json 2>/dev/null || echo "false")

    if [[ "$AUTO_RERUN" == "true" ]]; then
      echo "Attempting auto-rerun (reviewer.autoRerunOnDone = true)..."
      # Step 1.4 handles auto-rerun with guardrails
    else
      echo "Run: /tk-review $TICKET_ID to get fresh review"
      exit 1
    fi
  fi
fi
```

### 1.4 Auto-Rerun with Guardrails (if enabled)

**Only attempted if:**
- `reviewer.autoRerunOnDone === true`
- Review is missing or stale
- No skip tag on ticket

```bash
if [[ "$AUTO_RERUN" == "true" ]] && [[ "$HAS_SKIP" == "false" ]]; then

  # Guardrail 1: Working tree must be clean
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Error: Auto-rerun blocked: Working tree is dirty"
    echo "Commit or stash changes first"
    echo "Run: /tk-review $TICKET_ID"
    exit 1
  fi

  # Guardrail 2: Base ref resolution must be deterministic
  if git remote | grep -q "origin"; then
    BASE_REF="origin/${MAIN_BRANCH:-main}"
  else
    BASE_REF="${MAIN_BRANCH:-main}"
  fi

  if ! git rev-parse ${BASE_REF} >/dev/null 2>&1; then
    echo "Error: Auto-rerun blocked: Cannot resolve base ref '${BASE_REF}'"
    echo "Run: /tk-review $TICKET_ID"
    exit 1
  fi

  # Guardrail 3: No obvious secrets in diff
  DIFF_CONTENT=$(git diff ${MERGE_BASE}...HEAD)
  if echo "$DIFF_CONTENT" | grep -q "-----BEGIN.*PRIVATE KEY\|-----BEGIN.*RSA\|-----BEGIN.*EC"; then
    echo "Error: Auto-rerun blocked: Detected private key in diff"
    echo "Run: /tk-review $TICKET_ID"
    exit 1
  fi

  if echo "$DIFF_CONTENT" | grep -qE "sk-[a-zA-Z0-9]{20,}\|ghp_[a-zA-Z0-9]{36}\|xoxb-[0-9]{13}-[0-9]{18}\|AIza[0-9A-Za-z_-]{35}"; then
    echo "Error: Auto-rerun blocked: Detected potential token/secret in diff"
    echo "Run: /tk-review $TICKET_ID"
    exit 1
  fi

  # All guardrails passed - attempt auto-rerun
  echo "All guardrails passed. Running: /tk-review $TICKET_ID"
  /tk-review $TICKET_ID

  # Re-check result
  LATEST_REVIEW=$(tk show $TICKET_ID | grep -A 30 "## Review Summary")
  REVIEW_RESULT=$(echo "$LATEST_REVIEW" | grep "Result:" | awk '{print $2}')

  if [[ "$REVIEW_RESULT" != "PASS" ]]; then
    echo "Error: Auto-rerun review failed (Result: $REVIEW_RESULT)"
    echo "Fix issues manually, then run: /tk-review $TICKET_ID"
    exit 1
  fi

  echo "Auto-rerun review passed. Proceeding with closure."
fi
```

---

## Step 2: Identify OpenSpec change AND epic ID

If `change-id` is not provided:
1. Get ticket: `tk show <ticket-id>` → extract `parent` field as `epic-id`
2. Find parent epic: `tk show <epic-id>`
3. Extract `external_ref` (format: `openspec:<change-id>`)
4. Save both `epic-id` and `change-id` for later steps

If no change-id can be found, ask user to provide it.

---

## Step 3: Load config

Read `.os-tk/config.json` (fallback `config.json`) for:
- `useWorktrees` (boolean)
- `mainBranch` (default: "main")
- `autoPush` (boolean)
- `unsafe.commitStrategy` (prompt|all|fail)
- `reviewer.autoRerunOnDone` (boolean) - for gate enforcement

---

## Step 4: Add note and close ticket

```bash
tk add-note <ticket-id> "Implementation complete, closing via /tk-done"
tk close <ticket-id>
```

---

## Step 5: Sync OpenSpec tasks.md

Find matching checkbox in `openspec/changes/<change-id>/tasks.md`:
- Match by exact ticket title (as created by `/tk-bootstrap`)
- Flip `[ ]` to `[x]`

If no exact match is found, warn and continue.

---

## Step 6: Check if all tasks are complete

Query tickets under epic:
```bash
tk query '.parent == "<epic-id>" and .status != "closed"'
```

If result is empty (all tasks closed):
- Archive OpenSpec change: `openspec archive <change-id> --yes`
- Print: "All tasks complete. OpenSpec change archived."

---

## Step 7: Commit changes

**If `useWorktrees: true` (safe mode):**
- Operating in worktree: `.worktrees/<ticket-id>/`
- Rebase onto latest main: `git fetch origin && git rebase origin/<mainBranch>`
- If conflicts:
  - Attempt auto-resolve for trivial cases (accept theirs for formatting, ours for logic)
  - If not straightforward: STOP and ask user to resolve manually
- Stage and commit: `git add -A && git commit -m "<ticket-id>: <ticket-title>"`

**If `useWorktrees: false` (simple mode):**
- Check `unsafe.commitStrategy`:
  - `prompt`: Ask user how to proceed if working tree has unrelated changes
  - `all`: Stage and commit everything with ticket ID prefix
  - `fail`: Refuse if working tree has changes outside ticket scope
- Stage and commit: `git add -A && git commit -m "<ticket-id>: <ticket-title>"`

---

## Step 8: Merge to main

**If `useWorktrees: true`:**
1. Switch to main: `git checkout <mainBranch>` (in main worktree or from worktree context)
2. Fast-forward merge: `git merge --ff-only ticket/<ticket-id>`
3. If fast-forward fails (diverged):
   - `git merge ticket/<ticket-id>` with commit message
   - If conflicts: STOP and ask user

**If `useWorktrees: false`:**
- If already on main: skip merge step
- Otherwise: merge current branch into main

---

## Step 9: Push to remote

If `autoPush: true` and remote exists:
```bash
git push origin <mainBranch>
```

If push fails (rejected), warn user and suggest `git pull --rebase` first.

---

## Step 10: Cleanup (worktree mode only)

If `useWorktrees: true`:
```bash
git worktree remove .worktrees/<ticket-id>
git branch -d ticket/<ticket-id>
```

---

## Output

Summarize:
- Review gate: Passed | Skipped | Auto-rerun
- Ticket closed: `<ticket-id>`
- OpenSpec tasks.md synced: Yes/No
- OpenSpec archived: Yes/No (if all complete)
- Committed: `<commit-hash>`
- Merged to: `<mainBranch>`
- Pushed: Yes/No

---

## EXECUTION CONTRACT

This command **DOES** mutate state:
- Closes ticket via `tk close`
- Edits `openspec/changes/<id>/tasks.md`
- May archive OpenSpec
- Creates git commits
- Merges branches
- Pushes to remote

**Stop points:**
- Review gate fails (no PASS review for current HEAD/diffHash)
- Auto-rerun guardrails fail (dirty tree, secrets, etc.)
- Conflict resolution that isn't trivial
- Missing change-id and cannot auto-detect
- Push rejected by remote

---

## Config Options

### Review Gate Settings

```json
{
  "reviewer": {
    "autoRerunOnDone": false,
    "skipTags": ["no-review", "wip"],
    "policy": "gate",
    "blockSeverities": ["error"],
    "blockMinConfidence": 80
  }
}
```

- `autoRerunOnDone`: If true, attempt automatic review rerun when stale (with guardrails)
- `skipTags`: Tickets with these tags bypass the review gate
- `policy`: `gate` (default), `gate-with-followups`, or `followups-only`

---

## Examples

### Basic closure (with valid PASS review):
```
/tk-done otos-0159
✓ Review gate: Passed (PASS for HEAD abc123..., hash 7a8b9c...)
```

### Closure with skip tag (bypasses review):
```
/tk-done otos-0159
⚠ Review gate: Skipped (ticket has tag "no-review")
```

### Closure fails (stale review):
```
/tk-done otos-0159
✗ Error: Review is stale for current HEAD
  Review HEAD: abc123...
  Current HEAD: def456...
  Run: /tk-review otos-0159
```

### Closure with auto-rerun (enabled):
```
/tk-done otos-0159
⚠ Review is stale. Attempting auto-rerun...
  Guardrail check: Working tree clean ✓
  Guardrail check: Base ref deterministic ✓
  Guardrail check: No secrets detected ✓
  Running: /tk-review otos-0159
✓ Auto-rerun review passed. Proceeding with closure.
```

### Closure blocked by auto-rerun guardrail:
```
/tk-done otos-0159
✗ Error: Auto-rerun blocked: Working tree is dirty
  Commit or stash changes first
  Run: /tk-review otos-0159
```
