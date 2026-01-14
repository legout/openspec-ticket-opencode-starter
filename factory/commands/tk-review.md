---
description: Review completed ticket for quality issues
argument-hint: <ticket-id>
---

# /tk-review

**Arguments:** $ARGUMENTS

Parse from $ARGUMENTS:
- First word: ticket-id (required)

## Steps

1. **Get ticket and epic info**: `tk show <ticket-id>`
2. **Analyze changes**: `git diff`
3. **Read OpenSpec specs**: `openspec show <change-id>`
4. **Review categories**:
   - **spec-compliance**: Does implementation match requirements?
   - **tests**: Are acceptance criteria covered?
   - **security**: Obvious vulnerabilities?
   - **quality**: Code patterns, DRY, error handling?

5. **Create fix tickets** if needed:
   ```bash
   tk create "Fix: <issue>" --parent <epic-id> --priority 0 --tags review-fix
   tk link <new-id> <ticket-id>
   ```

6. **Add review note**:
   ```bash
   tk add-note <ticket-id> "<review summary>"
   ```

## Output Format

```
## Review (YYYY-MM-DD)

spec-compliance: ✅ passed / ⚠️ warning / ❌ error
tests: ...
security: ...
quality: ...

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
