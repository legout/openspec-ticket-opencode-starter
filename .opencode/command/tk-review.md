---
description: Review a completed ticket's implementation for quality issues [ulw]
agent: os-tk-reviewer
---

# /tk-review <ticket-id>

**Arguments:** $ARGUMENTS

Parse:
- `ticket-id`: first argument (required)

## Step 1: Load config and validate

Read `.os-tk/config.json` for:
- `reviewer.categories` (which checks to run)
- `reviewer.createTicketsFor` (severity threshold for fix tickets)
- `reviewer.skipTags` (tickets with these tags skip review)

## Step 2: Get ticket details

```bash
tk show <ticket-id>
```

Extract:
- `status`: Must be "closed" (review happens after implementation)
- `title`: For context
- `parent`: Epic ID for linking fix tickets
- `tags`: Check against `skipTags`

If status is not "closed":
- Print: "Ticket <id> is not closed. Run /tk-done first."
- EXIT

If ticket has any tag in `skipTags`:
- Print: "Skipped: ticket has <tag> tag"
- EXIT

## Step 3: Find the merge commit

Find the commit associated with this ticket:
```bash
git log --oneline --grep="<ticket-id>:" -1
```

If no commit found, try:
```bash
git log --oneline --grep="<ticket-id>" -1
```

Extract the commit SHA.

If still no commit found:
- Print: "No commit found for ticket <id>. Cannot review."
- EXIT

## Step 4: Get the diff

```bash
git show <commit-sha> --stat
git diff <commit-sha>^..<commit-sha>
```

## Step 5: Load OpenSpec context

Get the epic's external_ref to find the OpenSpec change:
```bash
tk show <parent-epic-id>
```

Extract `external_ref` (format: `openspec:<change-id>`).

If change-id found, read:
- `openspec/changes/<change-id>/proposal.md`
- `openspec/changes/<change-id>/specs/**/*.md` (delta specs)

Also read relevant current specs:
- `openspec/specs/**/*.md` (for context)

## Step 6: Analyze the implementation

For each category in `reviewer.categories`:

### spec-compliance
- Compare the diff against OpenSpec requirements
- Check that scenarios are implemented as specified
- Flag any deviations from spec

### tests
- Check if acceptance criteria have corresponding tests
- Look for test files modified/created in the diff
- Flag missing test coverage

### security
- Look for obvious vulnerabilities:
  - SQL injection (string concatenation in queries)
  - XSS (unescaped user input)
  - Hardcoded secrets
  - Unsafe deserialization
- Flag any findings

### quality
- Check for code patterns and DRY violations
- Look for proper error handling
- Check for TODOs or commented-out code left behind
- Flag concerns

## Step 7: Classify findings

For each finding, assign severity:
- `error`: Must be fixed (blocks quality)
- `warning`: Should be fixed (improves quality)
- `info`: Nice to have (optional improvement)

## Step 8: Add review note to original ticket

```bash
tk add-note <ticket-id> "<review-summary>"
```

Format:
```markdown
## Review (YYYY-MM-DD)
✅ spec-compliance: passed
⚠️ tests: Missing edge case test for null input
❌ security: SQL injection risk in query builder

Created: T-XXX, T-YYY (linked)
```

Use:
- ✅ for passed categories
- ⚠️ for warnings
- ❌ for errors

## Step 9: Create fix tickets (if needed)

For each finding with severity in `createTicketsFor`:

```bash
tk create "Fix: <issue summary>" \
  --parent <parent-epic-id> \
  --priority <0 for error, 1 for warning> \
  --description "<detailed description of the issue and how to fix it>" \
  --tags review-fix
```

Then link to original:
```bash
tk link <new-ticket-id> <ticket-id>
```

## Step 10: Output summary

Print:
- Review completed for: `<ticket-id>`
- Categories checked: `<list>`
- Findings: `<count by severity>`
- Fix tickets created: `<list of IDs>` or "None"

If no issues found:
- Print: "Review passed, no issues found"

---

## REVIEW CONTRACT

This command **DOES**:
- Read git history and diffs
- Read OpenSpec specs and ticket data
- Add notes to tickets via `tk add-note`
- Create fix tickets via `tk create`
- Link tickets via `tk link`

This command **DOES NOT**:
- Edit code files
- Close or start tickets
- Merge branches or push
- Archive OpenSpec

**If issues are found**: Fix tickets are created and linked. The original ticket remains closed.
