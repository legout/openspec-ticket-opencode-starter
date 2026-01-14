---
description: Create a new OpenSpec proposal for a feature or bugfix
agent: worker
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Write", "Edit"]
---

# /os proposal <change-id>

**Arguments:**
- `$1`: Change ID for the new proposal (kebab-case, e.g., "user-authentication")

---

## PURPOSE

Create a new OpenSpec proposal for a feature or bugfix. This initializes the change directory and drafts the proposal document.

---

## EXECUTION

Use your **openspec** skill to:

1. Initialize the change:
   ```bash
   ! openspec init $1
   ```

2. Draft a high-quality `proposal.md` in `openspec/changes/$1/` with:
   - Summary
   - Motivation
   - Background
   - Scope (in/out)
   - Requirements
   - Design Considerations

3. Identify initial goals and constraints.

4. Summarize the proposal to the user and suggest next steps:
   - Refine the design
   - Create tasks.md
   - Run `/tk bootstrap <id> "<title>"` to create tickets

---

## OUTPUT

After creating the proposal:

```
## Proposal Created: $1

**Location:** openspec/changes/$1/proposal.md

### Summary
<Brief summary of the proposal>

### Next Steps
1. Review and refine the proposal
2. Add tasks.md with implementation breakdown
3. Run `/tk bootstrap $1 "<title>"` to create tickets
```

**STOP here.** Wait for user to review and approve the proposal before proceeding.
