# Reviewer Migration Guide (v2: 4 Roles + Lead, Gate-First)

**Status:** Reference for migrating from review pipeline v1 (scouts/aggregators) to v2 (roles/lead).

---

## Overview of Changes

The code review pipeline has been significantly refactored to be simpler and deterministic:

| Aspect | v1 (Old) | v2 (New) |
|--------|--------------|--------------|
| **Pipeline** | 7 scouts + 2 aggregators + adaptive routing | 4 role reviewers + 1 lead reviewer (deterministic) |
| **Review Timing** | Post-close (after `/tk-done`) | Pre-close (before `/tk-done`) |
| **Gate** | Review was optional | Review is a gate by default (`/tk-done` blocks without PASS) |
| **Flags** | `--fast`, `--ultimate`, `--scouts` | `--roles`, `--policy`, `--base` (old flags deprecated) |
| **Config Schema** | `reviewer.scouts[]` + `reviewer.adaptive` + `reviewer.aggregator*` | `reviewer.roles{}` + `reviewer.policy` + thresholds |
| **Auto-rerun** | Not available | `autoRerunOnDone` with guardrails (optional, default false) |

---

## New Roles Overview

### Role Reviewers (Read-Only)

Each role reviewer specializes in a specific area:

| Role | Responsibility | Key Checks |
|-------|---------------|-------------|
| `bug-footgun` | Diff-focused bug/security scan | Null checks, off-by-one, injection, auth gaps, hardcoded secrets, broken imports, type mismatches, race conditions |
| `spec-audit` | OpenSpec/spec compliance | ADDED/MODIFIED requirements implemented, scenarios have test coverage, matches design.md |
| `generalist` | Regression + code quality | Reverted fixes, intentionality, TODO/debt, error handling, maintainability, DRY violations |
| `second-opinion` | Alternative perspective | Edge cases, challenge assumptions, architecture drift, risk assessment |

### Lead Reviewer (Writer)

The lead reviewer:
1. Orchestrates role reviewers in parallel
2. Collects and merges their findings deterministically
3. Decides PASS/FAIL based on config thresholds
4. Creates followup tickets (if policy allows and thresholds met)
5. Writes single consolidated review note to ticket

**Only the lead reviewer** can create tickets or add notes.

---

## Config Schema v2

### New Schema Structure

```json
{
  "reviewer": {
    "autoTrigger": false,
    "autoRerunOnDone": false,
    "policy": "gate",
    "blockSeverities": ["error"],
    "blockMinConfidence": 80,
    "followupSeverities": ["warning"],
    "followupMinConfidence": 60,
    "skipTags": ["no-review", "wip"],
    "roles": {
      "bug-footgun": {
        "enabled": true,
        "model": "openai/gpt-5.2-codex",
        "reasoningEffort": "high",
        "temperature": 0
      },
      "spec-audit": {
        "enabled": true,
        "model": "openai/gpt-5.2-codex",
        "reasoningEffort": "high",
        "temperature": 0
      },
      "generalist": {
        "enabled": true,
        "model": "openai/gpt-5.2",
        "reasoningEffort": "medium",
        "temperature": 0
      },
      "second-opinion": {
        "enabled": true,
        "model": "anthropic/opus-4.5",
        "reasoningEffort": "max",
        "temperature": 0
      }
    }
  }
}
```

### Policy Modes

| Policy | Behavior |
|--------|----------|
| `gate` (default) | Review FAIL blocks `/tk-done`. No followups created (even for warnings). |
| `gate-with-followups` | Review FAIL blocks. Followups created only when overall review is PASS (no blockers). |
| `followups-only` | Review FAIL does NOT block. Followups created for all findings meeting thresholds. |

### Thresholds

- `blockSeverities`: Array of severities that block the gate (default: `["error"]`)
- `blockMinConfidence`: Minimum confidence (0-100) for blocking (default: `80`)
- `followupSeverities`: Array of severities that create followups (default: `["warning"]`)
- `followupMinConfidence`: Minimum confidence for followups (default: `60`)

---

## Legacy Migration

### What's Removed

```json
// OLD (no longer supported)
{
  "reviewer": {
    "scouts": [...],              // REMOVED
    "adaptive": {...},            // REMOVED
    "aggregatorFast": {...},     // REMOVED
    "aggregatorStrong": {...}   // REMOVED
  }
}
```

### Migration Path

If you have a v1 config with `reviewer.scouts` or `reviewer.adaptive`:

1. **Migration is automatic** - When you run `os-tk apply`, it will:
   - Detect legacy config
   - Print a warning: `"⚠️  Legacy review config detected..."`
   - Auto-migrate to v2 schema in-memory
   - Note: Your `config.json` is not modified automatically

2. **Manual update (recommended)** - Edit `config.json` and replace legacy blocks:
   ```diff
   {
     "reviewer": {
   -    "scouts": [...],            // REMOVE
   -    "adaptive": {...},          // REMOVE
   -    "aggregatorFast": {...},   // REMOVE
   -    "aggregatorStrong": {...} // REMOVE
   +    "roles": {                 // ADD
   +      "bug-footgun": { "enabled": true, ... },
   +      "spec-audit": { "enabled": true, ... },
   +      "generalist": { "enabled": true, ... },
   +      "second-opinion": { "enabled": true, ... }
   +    },
   +    "policy": "gate",          // ADD
   +    "blockSeverities": ["error"], // ADD
   +    "blockMinConfidence": 80,       // ADD
   +    "followupSeverities": ["warning"], // ADD
   +    "followupMinConfidence": 60      // ADD
   +    "autoRerunOnDone": false         // ADD (optional)
   +  }
   }
   ```

### Legacy Flag Deprecation

| Old Flag | New Equivalent | Deprecation Window |
|-----------|-----------------|--------------------|
| `--spec-audit` | `--roles spec-audit` | 1 release |
| `--shallow-bugs` | `--roles bug-footgun` | 1 release |
| `--second-opinion` / `--seco` | `--roles second-opinion` | 1 release |
| `--ultimate` | `--roles bug-footgun,spec-audit,generalist,second-opinion` | 1 release |
| `--fast` | N/A (removed) | 1 release |

---

## Workflow Changes

### New Sequence: Start → Review → Done

```
/tk-start <id>
  ↓
/tk-review <id>  ← NOW REQUIRED (gate)
  ↓
/tk-done <id>  ← ENFORCES PASS REVIEW
```

**Key change:** `/tk-review` now runs **before** `/tk-done`, not after.

### Ticket Open Requirement

- `/tk-review` requires ticket to be **open**.
- If ticket is closed, `/tk-review` refuses with message: `"Ticket is closed. Reopen with: tk reopen <id>"`

### Deterministic Review Contract

- **Base ref:** Prefer `origin/main` if available, else `main`
- **Diff source:** `git diff $(git merge-base <baseRef> HEAD)`
- **Metadata recorded:** baseRef, baseSha, headSha, mergeBaseSha, diffStat, diffHash

### Review Note Format

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

---

## Auto-Rerun on /tk-done (Optional)

### What It Does

If `reviewer.autoRerunOnDone` is enabled (`true`), `/tk-done` will automatically run `/tk-review` when the review is missing or stale for the current HEAD.

### Guardrails (All Must Pass)

1. **Working tree clean:**
   ```bash
   git status --porcelain  # Must be empty
   ```

2. **Deterministic base ref:**
   - Must resolve to a specific commit (not a branch name)

3. **No secrets in diff:**
   - No PEM blocks: `-----BEGIN ...`
   - No common tokens: `sk-`, `ghp_`, `xoxb-`, `AIza...`

### Guardrail Failure Behavior

If any guardrail fails:
- `/tk-done` refuses with message
- Manual `/tk-review <id>` is required

---

## Platform-Specific Notes

### OpenCode

- Full support for 4 roles + lead
- Uses `subagent` calls for parallel role execution
- Model and reasoningEffort settings from `reviewer.roles.<role-name>`

### Claude Code

- Full support for 4 roles + lead
- Uses `subagent` calls
- Model mapping: Claude models may not support `reasoningEffort`
- Ignore `reasoningEffort` if not supported

### Factory/Droid

- Full support for 4 roles + lead
- Uses `subagent` calls
- Model mapping: Use `low|medium|high` for `reasoningEffort`

### Pi

- Full support for 4 roles + lead
- Requires Pi `subagent` extension for parallel execution
- Use `subagent` calls (if available)
- Model mapping: Same as OpenCode if extension supports it

---

## Testing Your Migration

### Step 1: Update Config (Manual)

Update your `config.json` to remove legacy `reviewer` blocks and add v2 schema.

### Step 2: Run os-tk apply

```bash
os-tk apply
```

This will:
- Regenerate all agent files based on your v2 config
- Print warnings if legacy config was detected
- Note: Config file itself is not modified automatically

### Step 3: Run Test Review

```bash
# Create a test ticket or use an existing one
/tk-review <ticket-id>
```

Expected behavior:
- Uses 4 role reviewers in parallel
- Lead reviewer merges findings
- Single consolidated note is added to ticket

### Step 4: Test Gate Enforcement

```bash
/tk-done <ticket-id>  # Should fail if no PASS review
```

Expected behavior:
- Refuses if no PASS review or review is stale
- Or auto-reruns if `autoRerunOnDone` is enabled and guardrails pass

### Step 5: Test Legacy Flags (If Applicable)

```bash
/tk-review <id> --ultimate  # Should deprecation warning
```

Expected behavior:
- Deprecation warning printed
- Internally mapped to `--roles bug-footgun,spec-audit,generalist,second-opinion`
- Review still proceeds

---

## Troubleshooting

### "Legacy review config detected"

**Cause:** Your `config.json` has `reviewer.scouts` or `reviewer.adaptive`.

**Fix:** Edit `config.json` and use the v2 schema shown above. After updating, run `os-tk apply` to regenerate agents.

### "/tk-review failed: Ticket is closed"

**Cause:** Trying to review a ticket that has already been closed.

**Fix:** Reopen the ticket first:
```bash
tk reopen <id>
/tk-review <id>
```

### "/tk-done refused: Review is stale"

**Cause:** Changes were made after the last review.

**Fix:** Re-run `/tk-review <id>` to get a fresh review for current state.

### "/tk-done refused: Auto-rerun blocked"

**Cause:** One of the guardrails failed:
- Working tree is dirty
- Base ref cannot be resolved
- Secrets detected in diff

**Fix:** Either fix the issue or run `/tk-review <id>` manually:
```bash
git status  # Check for uncommitted changes
/tk-review <id>  # Run manual review
```

### "No role reviewers generated"

**Cause:** `os-tk apply` did not generate role reviewer files.

**Fix:** Check that your config has `reviewer.roles` defined with enabled roles:
```bash
cat config.json | jq '.reviewer.roles'
```

---

## Rollback (If Needed)

If you need to revert to v1 after upgrading:

1. Set feature flag in config (not yet implemented in os-tk, but documented in plan):
   ```json
   {
     "reviewer": {
       "pipelineVersion": "legacy"  // Would enable rollback in future
     }
   }
   ```

2. Restore old config schema manually:
   - Add back `reviewer.scouts`, `reviewer.adaptive`, `reviewer.aggregator*`
   - Remove `reviewer.roles`, `reviewer.policy`, thresholds

3. Run `os-tk sync` from the v1 tag:
   ```bash
   # If you remember the v1 template tag
   os-tk sync --templateRef v0.x.x
   ```

---

## Next Steps

1. **Review this guide** - Understand the v2 changes
2. **Update your config** - Manual migration to v2 schema
3. **Run `os-tk apply`** - Regenerate agents with new config
4. **Test on a sample ticket** - Verify `/tk-review` and `/tk-done` work as expected
5. **Update your team** - Share this guide with developers using the new workflow

---

## Additional Resources

- **Full refactor plan:** `docs/review-refactor-plan-final.md`
- **OpenSpec change:** `openspec/changes/review-refactor-v2/`
- **AGENTS.md:** Updated OS-TK block with v2 workflow
