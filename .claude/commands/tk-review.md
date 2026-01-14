---
description: Review completed ticket for quality issues
argument-hint: <ticket-id>
allowed-tools: Bash(git:*), Bash(tk:*), Bash(openspec:*), Read, Grep
---

# /tk-review $1

Parse:
- `$1`: ticket-id (required)

## Current Context

Ticket details:
!`tk show $1`

Recent commits:
!`git log --oneline -5`

## Steps

1. **Get ticket and epic info**
2. **Analyze changes**: `git diff`
3. **Read OpenSpec specs**
4. **Review categories**:
   - **spec-compliance**: Does implementation match requirements?
   - **tests**: Are acceptance criteria covered?
   - **security**: Obvious vulnerabilities?
   - **quality**: Code patterns, DRY, error handling?

5. **Create fix tickets** if needed:
   ```bash
   tk create "Fix: <issue>" --parent <epic-id> --priority 0 --tags review-fix
   tk link <new-id> $1
   ```

6. **Add review note**:
   ```bash
   tk add-note $1 "<review summary>"
   ```

## Output Format

```
## Review (YYYY-MM-DD)

spec-compliance: passed/warning/error
tests: passed/warning/error
security: passed/warning/error
quality: passed/warning/error

### Findings
- <issue with file:line reference>

### Fix Tickets Created
- <ticket-id>: <title>

### Summary
<overall assessment>
```

## Contract

**ALLOWED:** `git diff`, `tk add-note`, `tk create`, `tk link`, reading files
**FORBIDDEN:** Editing code files, implementing fixes
