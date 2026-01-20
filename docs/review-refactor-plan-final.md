# Code Reviewer Refactor - Implementation Plan (Final)

**Status:** Ready to Implement
**Date:** 2026-01-18
**Based on:** `docs/review-refactor-plan.md` + critical reviews + user decisions

---

## Executive Summary

Replace the current 7-scout + 2-aggregator + adaptive routing review system with a simpler 4-role + 1-lead pipeline. Make review a **gate** by default: `/tk-done` cannot close/merge/push unless review passes.

**Key Changes:**
- Remove adaptive routing entirely (no fast/strong variants, no size-based role selection)
- Role reviewers: `bug-footgun`, `spec-audit`, `generalist`, `second-opinion`
- Lead reviewer: merges findings deterministically, decides PASS/FAIL, creates followups (policy-dependent)
- Ticket must be **open** for `/tk-review`
- New workflow: `/tk-start → /tk-review → /tk-done`
- Config v2 with legacy back-compat
- Auto-rerun opt-in with guardrails (default: `false`)

---

## Target Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    /tk-review                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │         4 Role Reviewers (parallel)              │   │
│  │  bug-footgun | spec-audit | generalist | 2nd    │   │
│  └─────────────────────────────────────────────────┘   │
│                         │                               │
│                         ▼                               │
│  ┌─────────────────────────────────────────────────┐   │
│  │              Lead Reviewer                       │   │
│  │  - Merge/dedupe findings (deterministic)        │   │
│  │  - Pass/fail decision (config-driven)           │   │
│  │  - Single consolidated note                     │   │
│  │  - Optional follow-up tickets (policy-driven)   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Workflow: /tk-start → /tk-review → /tk-done (gate before close)
```

---

## 1. Role Mapping Appendix

**Current (7 scouts):**
- `spec-audit`
- `shallow-bugs`
- `history-context`
- `code-comments`
- `intentional-check`
- `fast-sanity`
- `second-opinion`

**Target (4 roles):**

### 1.1 `spec-audit`
- **Preserves:** current `spec-audit`
- **Responsibilities:**
  - OpenSpec proposal/spec delta/tasks/design alignment
  - Requirement/scenario coverage
  - Evidence must cite spec lines + code lines
  - Checks for ADDED/MODIFIED requirements implemented
  - Verifies scenarios have test coverage

### 1.2 `bug-footgun`
- **Absorbs:** `shallow-bugs` + `fast-sanity` + security footguns
- **Responsibilities:**
  - Diff-focused bug scan (null checks, off-by-one, branching errors)
  - Obvious security issues (injection, auth gaps, hardcoded secrets)
  - Broken imports/dependencies
  - Type mismatches
  - Race conditions (missing async/await)
- **Constraint:** Shallow only—read diff, not full files

### 1.3 `generalist`
- **Absorbs:** `history-context` + `intentional-check` + `code-comments`
- **Responsibilities:**
  - Regression risk (did we revert a fix?)
  - Intentionality check (was this change intentional?)
  - TODO/debt introduced
  - Documentation/comments quality
  - Maintainability and error handling
  - Code patterns and DRY violations
- **Constraint:** May read git history and context for these checks

### 1.4 `second-opinion`
- **Preserves:** current `second-opinion`
- **Responsibilities:**
  - Alternative perspective
  - Challenge assumptions
  - Missing edge cases
  - Architecture drift (lightweight)
  - Risk-based sanity check

---

## 2. Review Contract (Deterministic Inputs/Outputs)

### 2.1 Diff Target (Ticket Open)

Default review mode: ticket is open, no merge commit exists.

**Base ref resolution (deterministic):**
```bash
# Prefer origin if available, else local main
baseRef="origin/${mainBranch}"  # if origin exists
baseRef="${mainBranch}"          # fallback (default: "main")
mergeBaseSha=$(git merge-base ${baseRef} HEAD)
```

**Review diff:**
```bash
git diff ${mergeBaseSha}...HEAD
```

**Metadata to record:**
- `baseRef` (resolved)
- `baseSha` (commit SHA at baseRef)
- `headSha` (current HEAD)
- `mergeBaseSha`
- `diffStat` (file count, line count)
- `diffHash` (SHA256 of patch text, for `/tk-done` validation)

### 2.2 Role Reviewer Output Envelope

Each role reviewer MUST output exactly one envelope:

```json
{
  "role": "spec-audit|bug-footgun|generalist|second-opinion",
  "findings": [
    {
      "category": "spec-compliance|tests|security|quality",
      "severity": "error|warning|info",
      "confidence": 85,
      "title": "Short title",
      "evidence": ["file:line", "file:line"],
      "description": "Clear description",
      "suggestedFix": ["Step 1", "Step 2"]
    }
  ]
}
```

**Hard rule:** If a role can't find issues, output `"findings": []`.

### 2.3 Lead Reviewer Merge Rules (Deterministic)

**Dedupe key:** `(category, normalized_title, primary_file)`
- Normalize title: lowercase, trim, collapse whitespace
- Primary file: first evidence file or most relevant

**Resolution:**
```javascript
severity = MAX(findings.map(f => f.severity))  // error > warning > info
confidence = MIN(findings.map(f => f.confidence))  // conservative
sources = findings.map(f => f.role)  // which roles found it
agreement = sources.length  // e.g., "2/3 scouts flagged this"
```

**Evidence guardrail:**
- If `severity === "error"` but `evidence` is missing/weak:
  - Downgrade to `"warning"`
  - Note in description: "Downgraded from error due to weak evidence"

**Pass/fail decision (config-driven, not vibes):**
```javascript
hasBlocker = findings.some(f =>
  config.blockSeverities.includes(f.severity) &&
  f.confidence >= config.blockMinConfidence
)

pass = !hasBlocker
```

### 2.4 Consolidated Note Format (Required)

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

**SKIPPED format (if ticket has skip tag):**
```markdown
## Review Summary (YYYY-MM-DD)
**Result:** SKIPPED
**Reason:** Ticket has tag "no-review"
**Policy:** ${policy}
**Head:** ${headSha}
```

---

## 3. Policy Semantics (Final)

### 3.1 `gate` (Default)
- `/tk-review` produces PASS/FAIL based on blockers only
- **Never creates followups** (even for warnings)
- If FAIL: ticket stays open, fix blockers, rerun `/tk-review`
- `/tk-done` must refuse unless latest review is PASS for current HEAD

### 3.2 `gate-with-followups`
- If FAIL due to blockers: ticket stays open, no followups created
- If PASS (no blockers, possibly warnings):
  - Create followups for warnings that meet thresholds
  - Ticket may proceed to `/tk-done`
- **Followups created only when overall review is PASS** (prevents duplicates on repeated FAILs)

### 3.3 `followups-only` (Not Recommended)
- Always PASS (ignores blockers for gate purposes)
- Create followups for all findings that meet thresholds (`error+warning`)
- Ticket may close even with errors

### 3.4 Thresholds

```json
{
  "reviewer": {
    "policy": "gate",
    "blockSeverities": ["error"],
    "blockMinConfidence": 80,
    "followupSeverities": ["warning"],
    "followupMinConfidence": 60
  }
}
```

**Threshold application:**
```javascript
isBlocker = severity in blockSeverities && confidence >= blockMinConfidence
shouldCreateFollowup = severity in followupSeverities && confidence >= followupMinConfidence
```

### 3.5 Skip Tags

- Keep `reviewer.skipTags` (default: `["no-review", "wip"]`)
- If ticket has any skip tag: `/tk-review` writes SKIPPED note with metadata
- `/tk-done` in gate mode treats SKIPPED as explicit bypass (allows close)

---

## 4. CLI Flags & UX

### 4.1 New Flags

- `--roles <comma-list>`: Override which roles run
  - Example: `--roles bug-footgun,spec-audit`
- `--policy <gate|gate-with-followups|followups-only>`: Override policy
- `--base <ref>`: Override base ref (advanced)
- Remove: `--fast`, `--ultimate`, `--shallow-bugs`, etc. (see deprecation below)

### 4.2 Flag Deprecation Bridge (One Release Window)

**Old flag → New mapping:**
- `--spec-audit` → `--roles spec-audit`
- `--shallow-bugs` → `--roles bug-footgun`
- `--second-opinion` / `--seco` → `--roles second-opinion`
- `--ultimate` → `--roles bug-footgun,spec-audit,generalist,second-opinion`
- `--fast` → Warning: "adaptive routing removed; use --roles to select roles"

**Behavior:**
- Accept old flags for one release
- Print deprecation warning with new syntax
- Internally map to `--roles`

### 4.3 Working Tree Flag

- Remove `--working-tree` as a separate concept
- Default behavior is now working-tree mode (ticket open, no merge commit)
- Document this as the primary mode in all help text

---

## 5. Workflow Changes (Gate-First)

### 5.1 `/tk-review` Requirements

**Preconditions:**
- Ticket must be **open**
- If closed: refuse with message "Ticket is closed. Reopen with: `tk reopen <id>`"

**Steps:**
1. Load config (v2 or legacy with warning)
2. Resolve base ref + merge base deterministically
3. Spawn enabled role reviewers in parallel
4. Collect envelopes
5. Invoke lead reviewer to merge/dedupe/decide
6. Write consolidated note
7. Create followups (if policy allows and thresholds met)
8. Return PASS/FAIL status

**Agent:** `os-tk-reviewer-lead` (orchestrator + merger)

### 5.2 `/tk-run` Sequence Change

**Old:** `/tk-start → /tk-done → /tk-review` (post-close)
**New:** `/tk-start → /tk-review → /tk-done` (gate-before-close)

**Ralph mode loop:**
```
1. /tk-queue --next
   ├─ Empty → Exit
   └─ Has ticket → /tk-start <id>
                   ├─ Success → /tk-review <id>
                   │            ├─ FAIL → Stop (ticket open)
                   │            └─ PASS → /tk-done <id>
                   └─ Failure → Ask human
```

**Exit conditions:**
- Empty queue
- Max cycles reached (`--max-cycles`)
- Review FAIL (in gate policies)
- P0 fix ticket created (regardless of policy)

### 5.3 `/tk-done` Gate Enforcer

**New ordering (worktree mode):**
1. Verify PASS review exists for current HEAD (see validation below)
2. If missing/outdated and `autoRerunOnDone=true`: attempt safe auto rerun
3. If still missing/outdated: **refuse** with clear instruction
4. Commit changes: `git commit -m "<ticket-id>: <title>"`
5. Merge to main: `git merge --ff-only ticket/<ticket-id>`
6. Push: `git push origin <mainBranch>` (if `autoPush`)
7. Close ticket: `tk close <id>`
8. Sync OpenSpec `tasks.md`
9. Archive OpenSpec if epic complete
10. Cleanup worktree/branch

**Validation logic:**
```bash
# Find latest review note for this ticket
latest_review=$(tk log <id> | grep -A 20 "## Review Summary")

# Extract headSha and diffHash
review_head=$(echo "$latest_review" | grep "Head:" | awk '{print $2}')
review_hash=$(echo "$latest_review" | grep "Hash:" | awk '{print $2}')
review_result=$(echo "$latest_review" | grep "Result:" | awk '{print $2}')

# Current state
current_head=$(git rev-parse HEAD)
current_hash=$(git diff ${mergeBase}...HEAD | sha256sum)

# Validate
if [[ "$review_result" != "PASS" ]]; then
  echo "Review failed. Fix issues and rerun /tk-review"
  exit 1
fi

if [[ "$review_head" != "$current_head" || "$review_hash" != "$current_hash" ]]; then
  echo "Review outdated for current HEAD"
  exit 1
fi
```

---

## 6. Auto Re-run Security Model (Opt-in, Guarded)

### 6.1 Config

```json
{
  "reviewer": {
    "autoRerunOnDone": false  // default: false (opt-in)
  }
}
```

### 6.2 Safety Conditions (ALL Must Pass)

Auto-rerun only attempted if:
1. `reviewer.autoRerunOnDone === true`
2. Working tree is clean: `git status --porcelain` → empty
3. Base ref resolution is deterministic (see section 2.1)
4. No obvious secrets detected in diff:
   - PEM blocks (`-----BEGIN`)
   - Common token patterns (`sk-`, `ghp_`, `xoxb-`)
   - If detected: refuse auto-rerun, require explicit `/tk-review`

### 6.3 Idempotency for Followups

**Problem:** Repeated reviews could create duplicate followup tickets

**Solution:** Stable key deduplication
```javascript
followupKey = sha256(
  finding.category +
  finding.title +
  finding.evidence[0] +  // primary evidence
  reviewedTicket.id
)

# Check if followup already exists
existing = tk query | grep -F "$followupKey"
if [[ -z "$existing" ]]; then
  tk create "Fix: $title" --key "$followupKey"
  tk link <new-id> <reviewed-ticket-id>
fi
```

### 6.4 Guardrail Failure Behavior

If any safety condition fails:
- `/tk-done` refuses with message:
  ```
  Review required but auto-rerun blocked: <reason>
  Run manually: /tk-review <id>
  ```

---

## 7. Config Schema v2 (No Adaptive, Legacy Back-compat)

### 7.1 New Schema

```json
{
  "reviewer": {
    "autoTrigger": true,
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

### 7.2 Legacy Config Fallback

**Trigger:** `reviewer.roles` missing but `reviewer.scouts` exists

**Mapping:**
```javascript
legacyScoutToRole = {
  "spec-audit": "spec-audit",
  "shallow-bugs": "bug-footgun",
  "fast-sanity": "bug-footgun",
  "history-context": "generalist",
  "intentional-check": "generalist",
  "code-comments": "generalist",
  "second-opinion": "second-opinion"
}

// In-memory conversion
legacyConfig.reviewer.scouts.forEach(scout => {
  role = legacyScoutToRole[scout.role]
  v2Roles[role].model = scout.model
  v2Roles[role].enabled = true
})
```

**Warning message:**
```
⚠️  Legacy review config detected (reviewer.scouts).
   Auto-migrated to reviewer.roles. Please update config.json.
   See: docs/reviewer-migration.md
```

### 7.3 What's Removed

- `reviewer.adaptive` (entire block, including thresholds and defaults)
- `reviewer.scouts` (after migration period)
- `reviewer.aggregatorStrong` (replaced by lead reviewer)
- `reviewer.hybridFiltering` (replaced by policy + thresholds)
- `reviewer.requireSeverity` → `reviewer.blockSeverities`
- `reviewer.requireConfidence` → `reviewer.blockMinConfidence`

---

## 8. Template Changes (Agents/Commands)

### 8.1 Remove (All Platforms)

**OpenCode:**
- `opencode/agent/os-tk-reviewer-agg-fast.md`
- `opencode/agent/os-tk-reviewer-agg-strong.md`
- `opencode/agent/os-tk-reviewer-scout-*.md` (all 7 scouts)
- `opencode/command/tk-review-fast.md`
- `opencode/command/tk-review-strong.md`

**Claude/Factory/Pi:**
- Equivalent files in `agents/` or `droids/` dirs

### 8.2 Add (All Platforms)

**Role reviewers:**
- `os-tk-reviewer-role-bug-footgun.md`
- `os-tk-reviewer-role-spec-audit.md`
- `os-tk-reviewer-role-generalist.md`
- `os-tk-reviewer-role-second-opinion.md`

**Lead reviewer:**
- `os-tk-reviewer-lead.md`

**Platforms:**
- OpenCode: `.opencode/agent/`
- Claude: `.claude/agents/`
- Factory: `.factory/droids/`
- Pi: `.pi/agents/`

### 8.3 Update Commands

**`/tk-review` entrypoint:**
- Remove references to `/tk-review-fast` and `/tk-review-strong`
- Update to spawn role reviewers → lead reviewer
- Document new flags (`--roles`, `--policy`)
- Add ticket-open requirement

**Platforms:**
- `opencode/command/tk-review.md`
- `claude/commands/tk-review.md`
- `factory/commands/tk-review.md`
- `pi/prompts/tk-review.md`

---

## 9. Generator Changes (`os-tk apply/sync`)

### 9.1 Update File Lists

**Add to sync lists:**
```bash
OPENCODE_AGENT_FILES+=(
  "agent/os-tk-reviewer-lead.md"
  "agent/os-tk-reviewer-role-bug-footgun.md"
  "agent/os-tk-reviewer-role-spec-audit.md"
  "agent/os-tk-reviewer-role-generalist.md"
  "agent/os-tk-reviewer-role-second-opinion.md"
)
```

**Remove from sync lists:**
```bash
# Remove scouts and aggregators
```

### 9.2 Config Generation

**`default_config()` function:**
- Remove adaptive block
- Emit v2 roles schema (no scouts)

### 9.3 Validation

**`cmd_apply()` checks:**
- Valid role names only (`bug-footgun|spec-audit|generalist|second-opinion`)
- If legacy scouts detected: warn + migrate in-memory
- Policy values valid
- Thresholds are sensible (0-100)

### 9.4 Agent Generation

**New function:** `rebuild_role_reviewer_from_template()`
**New function:** `rebuild_lead_reviewer_from_template()`
**Remove:** `rebuild_scout_from_template()`, `rebuild_aggregator_from_template()`

### 9.5 AGENTS.md Block Update

**Embedded `AGENTS_BLOCK` in `os-tk`:**
- Update review automation section
- Document new flags
- Remove adaptive/fast/strong references
- Add note about gate-first workflow

---

## 10. Skills + Docs Updates

### 10.1 `os-tk-workflow` Skill

**File:** `opencode/skill/os-tk-workflow/SKILL.md`

**Changes:**
- Remove adaptive routing logic
- Update `/tk-review Workflow` section:
  - Remove "ticket must be closed" → "ticket must be open"
  - Add base ref resolution algorithm
  - Remove flag precedence table (simplified to `--roles`)
- Update `/tk-run Workflow` section:
  - Change sequence to `/tk-start → /tk-review → /tk-done`
  - Document FAIL behavior (stop loop)
- Add `/tk-done` gate enforcement steps
- Remove all mentions of fast/strong variants

### 10.2 `docs/configuration.md`

**Add sections:**
- "Review Configuration (v2)" with full schema
- "Policy Modes" (gate, gate-with-followups, followups-only)
- "Thresholds" (blockMinConfidence, followupMinConfidence)
- "Auto Re-run" (autoRerunOnDone + safety conditions)
- "Migration Guide" (legacy → v2)

**Remove sections:**
- "Adaptive Review" (entire section)
- Legacy hybrid filtering docs

### 10.3 `docs/multi-agent-support.md`

**Update:**
- Reviewer platform mapping table
- Model-specific notes (Claude ignores `reasoningEffort`, etc.)

### 10.4 `README.md`

**Update:**
- Workflow diagram (show `/tk-review` before `/tk-done`)
- Review automation section
- Remove adaptive references
- Document new flags
- Add note about gate behavior

### 10.5 `AGENTS.md`

**Update:**
- Review automation section
- Remove scout/aggregator references
- Add role reviewer descriptions
- Document policy modes
- Update flags section

---

## 11. Test Plan

### 11.1 Add Shell Test Suite

**File:** `tests/test-review-refactor.sh`

**Assertions:**
```bash
# Old files removed
[ ! -f "opencode/agent/os-tk-reviewer-agg-fast.md" ]
[ ! -f "opencode/agent/os-tk-reviewer-agg-strong.md" ]
[ ! -f "opencode/agent/os-tk-reviewer-scout-spec-audit.md" ]
# ... (all scouts)

# New files exist (all platforms)
[ -f "opencode/agent/os-tk-reviewer-lead.md" ]
[ -f "opencode/agent/os-tk-reviewer-role-bug-footgun.md" ]
[ -f "opencode/agent/os-tk-reviewer-role-spec-audit.md" ]
[ -f "opencode/agent/os-tk-reviewer-role-generalist.md" ]
[ -f "opencode/agent/os-tk-reviewer-role-second-opinion.md" ]

# Command references
grep -q "os-tk-reviewer-lead" "opencode/command/tk-review.md"
! grep -q "tk-review-fast\|tk-review-strong" "opencode/command/tk-review.md"

# Workflow skills
grep -q "ticket must be open" "opencode/skill/os-tk-workflow/SKILL.md"
! grep -q "adaptive\|fast.*strong" "opencode/skill/os-tk-workflow/SKILL.md"

# /tk-done gate enforcement
grep -q "Verify PASS review" "opencode/command/tk-done.md"
grep -q "autoRerunOnDone" "opencode/command/tk-done.md"
```

### 11.2 Integration Test Scenarios

**Test 1: Gate mode blocks on error**
- Create ticket with buggy code
- Run `/tk-review` → FAIL
- Run `/tk-done` → refused
- Fix bug, rerun `/tk-review` → PASS
- Run `/tk-done` → succeeds

**Test 2: Gate-with-followups creates followups on PASS**
- Create ticket with warnings only
- Run `/tk-review` → PASS with followups created
- Verify followup tickets exist and are linked

**Test 3: Legacy config migrates**
- Use old `reviewer.scouts` config
- Run `os-tk apply`
- Verify agents generated + warning emitted

---

## 12. Migration Guide

### 12.1 For Users

**Before upgrading:**
1. Backup `config.json`
2. Run `os-tk sync` to get new templates

**After upgrading:**
1. Run `os-tk apply`
2. If you see legacy warning:
   - Update `config.json` to use `reviewer.roles`
   - Or continue using legacy (deprecated) until next release
3. Update any scripts using old flags (`--ultimate`, etc.)
4. Test with `/tk-review` on a small ticket first

### 12.2 For Platform Maintainers

**Claude Code:**
- Map `model` to `opus|sonnet|haiku|inherit`
- Ignore `reasoningEffort`
- Keep temperature if supported

**Factory/Droid:**
- Honor `model` + `reasoningEffort`
- Use `low|medium|high` for reasoning effort

**Pi:**
- Map as OpenCode if subagent extension supports it
- Fallback to platform defaults

---

## 13. Rollback Procedure

### 13.1 Feature Flag (Optional)

Add `reviewer.pipelineVersion`:
```json
{
  "reviewer": {
    "pipelineVersion": "v2"  // or "legacy"
  }
}
```

**Behavior:**
- If `"v2"` or unset: use new pipeline
- If `"legacy"`: use old scouts/aggregators (if files still exist)

### 13.2 Emergency Rollback

If new pipeline has critical issues:
1. Set `reviewer.pipelineVersion: "legacy"`
2. Run `os-tk sync` to restore old templates (if still in repo)
3. Run `os-tk apply` to regenerate old agents
4. Report issue with reproduction details

---

## 14. Execution Breakdown (3-8 Chunky Tickets)

### Ticket 1: Review Contract + Role Mapping
- [ ] Add role mapping appendix to plan
- [ ] Define deterministic diff target algorithm
- [ ] Define role output envelope schema
- [ ] Define lead merge rules (dedupe, severity, confidence)
- [ ] Define consolidated note format
- [ ] Define policy semantics (gate, gate-with-followups, followups-only)
- [ ] Define skipTags behavior
- [ ] Document threshold application logic

### Ticket 2: OpenCode Review Pipeline
- [ ] Create `os-tk-reviewer-lead.md` agent
- [ ] Create 4 role reviewer agents (bug-footgun, spec-audit, generalist, second-opinion)
- [ ] Update `opencode/command/tk-review.md` (remove fast/strong, add roles/policy flags)
- [ ] Implement ticket-open requirement
- [ ] Remove old scout/agg agents
- [ ] Remove old tk-review-fast/strong commands
- [ ] Test manual `/tk-review` on sample ticket

### Ticket 3: Gate-First Workflow
- [ ] Update `opencode/skill/os-tk-workflow/SKILL.md` (new /tk-review workflow)
- [ ] Update `/tk-run` sequence (review before done)
- [ ] Update `opencode/command/tk-done.md` (gate enforcement, new ordering)
- [ ] Implement review validation logic (headSha, diffHash)
- [ ] Add autoRerunOnDone support with guardrails
- [ ] Update `/tk-run` FAIL handling
- [ ] Test full lifecycle: start → review → done

### Ticket 4: Generator + Config v2
- [ ] Update `os-tk` sync lists (add roles, remove scouts)
- [ ] Implement `rebuild_role_reviewer_from_template()`
- [ ] Implement `rebuild_lead_reviewer_from_template()`
- [ ] Remove scout/agg generation functions
- [ ] Update `default_config()` for v2 schema
- [ ] Implement legacy config migration + warnings
- [ ] Add validation for roles, policy, thresholds
- [ ] Update `AGENTS_BLOCK` in os-tk
- [ ] Test `os-tk apply` with fresh and legacy configs

### Ticket 5: Platform Ports + Docs
- [ ] Port role reviewers to Claude (agents/)
- [ ] Port role reviewers to Factory (droids/)
- [ ] Port role reviewers to Pi (agents/)
- [ ] Update command entrypoints for all platforms
- [ ] Update `docs/configuration.md` (v2 schema, migration guide)
- [ ] Update `docs/multi-agent-support.md` (platform mapping)
- [ ] Update `README.md` (workflow, flags, gate behavior)
- [ ] Update `AGENTS.md` (review automation, flags)
- [ ] Create `docs/reviewer-migration.md` (user guide)

### Ticket 6: Tests + Validation
- [ ] Create `tests/test-review-refactor.sh`
- [ ] Add assertions for old files removed
- [ ] Add assertions for new files exist
- [ ] Add assertions for command references updated
- [ ] Add integration test scenarios
- [ ] Test legacy config migration
- [ ] Test gate mode blocks on error
- [ ] Test gate-with-followups creates followups on PASS
- [ ] Test autoRerunOnDone guardrails
- [ ] Run full test suite and fix failures

### Optional Ticket: Deprecation Messaging
- [ ] Add deprecation warnings for old flags
- [ ] Add legacy config warnings
- [ ] Create migration blog post / announcement
- [ ] Update version changelog

---

## 15. Success Criteria

- [ ] Review pipeline is consistent across OpenCode/Claude/Factory/Pi
- [ ] All 4 role reviewers exist and are distinct
- [ ] Lead reviewer produces single consolidated note
- [ ] Tickets are not closed if review fails (default policy)
- [ ] No legacy scout/aggregator files remain in template dirs
- [ ] `os-tk apply` generates new agents correctly
- [ ] Legacy configs auto-migrate with warning
- [ ] Test suite passes all assertions
- [ ] Docs updated (config, migration, platform support)
- [ ] `/tk-run` uses review-before-done sequence
- [ ] `/tk-done` enforces gate with validation
- [ ] Auto-rerun is opt-in with working guardrails

---

## 16. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| **Role coverage gaps** | Explicit mapping table preserves functionality |
| **Config breaking change** | Legacy fallback + deprecation period |
| **Increased latency (4 reviewers)** | Roles exit fast on small diffs; parallel execution |
| **False positives** | Confidence thresholds + evidence guardrail |
| **Duplicate followups** | Stable key deduplication |
| **Workflow confusion** | Clear docs + migration guide + deprecation warnings |
| **Gate blocks legitimate work** | SkipTags + policy flexibility |
| **Platform limitations** | Model mapping + ignored fields documented |

---

## 17. Open Questions (Resolved)

✅ No adaptive routing (removed entirely)
✅ Warnings don't block in gate mode
✅ `autoRerunOnDone` defaults to `false`
✅ `followups-only` creates followups for `error+warning`
✅ Ticket must be open for `/tk-review`
✅ Followups created only when overall review is PASS (in gate-with-followups)

---

## 18. Appendix: Example Review Outputs

### A.1 PASS Example (Gate Mode)

```markdown
## Review Summary (2026-01-18)
**Result:** PASS
**Policy:** gate
**Base:** origin/main (abc123...)
**Head:** def456...
**Merge Base:** abc123...
**Diff:** 3 files, +45 -12
**Hash:** 7a8b9c...

### Blocking Findings
None. ✅

### Non-Blocking Findings
| Category | Severity | Confidence | Finding | Evidence |
|----------|----------|------------|---------|----------|
| quality | warning | 70 | TODO not addressed | src/user.ts:45 |

### Follow-ups Created
None (gate mode does not create followups)
```

### A.2 FAIL Example (Gate Mode)

```markdown
## Review Summary (2026-01-18)
**Result:** FAIL
**Policy:** gate
**Base:** origin/main (abc123...)
**Head:** def456...
**Merge Base:** abc123...
**Diff:** 5 files, +120 -30
**Hash:** 1d2e3f...

### Blocking Findings (must fix)
| Category | Severity | Confidence | Finding | Evidence | Sources |
|----------|----------|------------|---------|----------|---------|
| security | error | 90 | Missing auth check | src/api.ts:23 | spec-audit, bug-footgun |
| tests | error | 85 | Missing edge case test | tests/user.test.ts | spec-audit |

### Non-Blocking Findings
| Category | Severity | Confidence | Finding | Evidence |
|----------|----------|------------|---------|----------|
| quality | warning | 60 | Long function | src/utils.ts:100 |

### Follow-ups Created
None (fix blockers first, then rerun review)
```

### A.3 PASS with Followups (Gate-with-Followups)

```markdown
## Review Summary (2026-01-18)
**Result:** PASS
**Policy:** gate-with-followups
**Base:** origin/main (abc123...)
**Head:** def456...
**Merge Base:** abc123...
**Diff:** 4 files, +80 -25
**Hash:** 4e5f6a...

### Blocking Findings
None. ✅

### Non-Blocking Findings
| Category | Severity | Confidence | Finding | Evidence |
|----------|----------|------------|---------|----------|
| quality | warning | 75 | TODO not addressed | src/user.ts:45 |
| tests | warning | 70 | Missing assertion | tests/api.test.ts:12 |

### Follow-ups Created
- T-201: Address TODO in user service (linked)
- T-202: Add missing assertion in API tests (linked)
```

---

**End of Implementation Plan**
