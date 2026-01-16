---
description: Review a completed ticket using multi-model adaptive aggregation [ulw]
agent: os-tk-reviewer
---

# /tk-review <ticket-id> [options]

**Arguments:** $ARGUMENTS

## Step 1: Validation and Context

Read `.os-tk/config.json` and check `skipTags`.
Ensure ticket is closed: \`tk show <ticket-id>\`.

## Step 2: Adaptive Complexity Scoring

1. Find the merge commit: \`git log --oneline --grep="<ticket-id>" -1\`.
2. Get diff stats:
   - \`files_changed\`: \`git show --name-only <sha> | wc -l\`
   - \`lines_changed\`: \`git diff --shortstat <sha>^..<sha>\`
3. Identify **risk signals**:
   - Check if diff touches: \`auth\`, \`security\`, \`crypto\`, \`migrations\`, \`lockfile\`, \`config\`.

## Step 3: Routing Logic

Based on \`reviewer.adaptive\` config:

- **SMALL**: (files <= 4 AND lines <= 200) AND NOT risky
  - Use **FAST** aggregator.
  - Default scouts: \`shallow-bugs\`, \`spec-audit\`.
- **MEDIUM**: (files <= 12 AND lines <= 800) AND NOT risky
  - Use **FAST** aggregator.
  - Default scouts: \`shallow-bugs\`, \`spec-audit\`, \`history-context\`.
- **LARGE / RISKY**: (else)
  - Use **STRONG** aggregator.
  - Default scouts: All 7 roles (shallow-bugs, spec-audit, history-context, code-comments, intentional-check, fast-sanity, second-opinion).

### Manual Overrides

- `--all-scouts`: Run all configured scouts.
- `--scouts ROLE,ROLE`: Run specific subset by role (highest precedence).
- `--no-adaptive`: Skip heuristic, use LARGE/STRONG defaults.
- `--force-strong` / `--force-fast`: Override aggregator choice.

### Global-Style Reviewer Flags (7-Scout System)

These flags select reviewers by **role** (from `reviewer.scouts[]` config):

**Specialized reviewer flags:**
- `--spec-audit`: Run spec-audit role only (OpenSpec compliance)
- `--shallow-bugs`: Run shallow-bugs role only (obvious bugs, alias: `--fast`)
- `--history-context`: Run history-context role only (git blame/comments, alias: `--deep`)
- `--code-comments`: Run code-comments role only (TODO/FIXME compliance)
- `--intentional-check`: Run intentional-check role only (intentional vs bug)

**Flexible provider flags (multi-provider support):**
- `--fast-sanity`: Run fast-sanity role only (quick checks, any provider)
- `--second-opinion`: Run second-opinion role only (alt perspective, alias: `--seco`)

**Meta flags:**
- `--ultimate`: Run all 7 role-based scouts + **STRONG aggregator**
- `--standard`: Run default set (shallow-bugs, spec-audit)

**Precedence rules (highest to lowest):**
1. `--scouts ROLE,ROLE` (manual role selection, bypasses all flags)
2. Specialized reviewer flags (`--spec-audit`, `--shallow-bugs`, etc.)
3. Flexible provider flags (`--fast-sanity`, `--second-opinion`)
4. `--ultimate` → all 7 scouts + STRONG aggregator
5. Adaptive complexity-based selection (default when no flags)

**Aliases:**
- `--fast` → alias for `--shallow-bugs` (backwards compatible)
- `--seco` → alias for `--second-opinion` (backwards compatible)

**Role mapping:**
- Flags select scouts by **role** from `config.json` / `.os-tk/config.json` → `reviewer.scouts[]`.
- `role` is the unique identifier (no separate `id` field needed)
- One reviewer per role enforced by `os-tk apply` validation.

**Adaptive defaults (when no flags):**
- Small (≤4 files, ≤200 lines): `shallow-bugs`, `spec-audit`
- Medium (≤12 files, ≤800 lines): `shallow-bugs`, `spec-audit`, `history-context`
- Large / risky: All 7 scouts

**Ultimate mode behavior:**
- `--ultimate` ⇒ always uses STRONG aggregator (regardless of diff size/risk).
- `--ultimate` + `--force-fast` ⇒ conflict error (mutually exclusive).

## Step 4: Delegate

Call the appropriate internal command with selected scouts:

\`\`\`bash
/tk-review-<fast|strong> <ticket-id> --scouts <list> [options]
\`\`\`

---

## EXECUTION CONTRACT

This command acts as an **orchestrator and router**. It computes complexity and delegates the actual review to the multi-model aggregator subtask.
