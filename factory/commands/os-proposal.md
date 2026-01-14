---
description: Create a new OpenSpec proposal
argument-hint: <change-id>
---

# /os-proposal

**Arguments:** $ARGUMENTS

Parse from $ARGUMENTS:
- First word: change-id (required, kebab-case)

## Steps

1. **Review context**:
   - `openspec/project.md` for conventions
   - `openspec list` for existing changes

2. **Initialize change**:
   ```bash
   openspec init <change-id>
   ```

3. **Create proposal.md** with:
   - Summary
   - Motivation
   - Scope (in/out)
   - Requirements
   - Success criteria

4. **Create tasks.md** with 3-8 chunky tasks

5. **Validate**:
   ```bash
   openspec validate <change-id> --strict
   ```

## Output Format

```
## Proposal Created

- Change ID: <change-id>
- Files created:
  - openspec/changes/<change-id>/proposal.md
  - openspec/changes/<change-id>/tasks.md

### Next Step
Run `/tk-bootstrap <change-id> "<title>"` to create tickets.
```

## Contract

**ALLOWED:** `openspec init`, creating spec files, `openspec validate`
**FORBIDDEN:** Implementing code, creating tickets directly
