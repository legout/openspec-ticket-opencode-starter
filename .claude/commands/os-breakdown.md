---
description: Break down a project plan/PRD into comprehensive OpenSpec proposals
agent: planner
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Write", "Edit", "Task"]
---

# /os breakdown <source> [--with-tickets]

**Arguments:**
- `$1`: Source - file path (@file.md), folder (@folder/), URL, or inline text
- `--with-tickets`: Optional flag to auto-bootstrap tickets after creating proposals

---

## PURPOSE

Transform a high-level project plan, PRD, or implementation specification into a comprehensive set of **feature-level OpenSpec proposals**. Each proposal is self-contained and self-documenting.

---

## EXECUTION CONTRACT

### ALLOWED
- Read files, folders, URLs, or inline text
- Use openspec CLI to create/modify proposals
- Create files under `openspec/changes/<id>/`
- Call `/tk bootstrap` for each proposal if `--with-tickets` is present

### FORBIDDEN
- Implement code (only create specs)
- Skip proposal creation and jump directly to tickets
- Create tickets without corresponding proposals
- Modify existing specs outside `openspec/changes/`
- Edit code files (*.py, *.ts, *.js, *.go, etc.)

---

## STEPS

### Step 1: Ingest Source Material

Read and parse the input:
- If `@file` -> Read the file contents
- If `@folder/` -> Read all markdown/text files in the folder
- If URL -> Fetch and parse the content
- If inline text -> Use the provided text directly

### Step 2: Deep Analysis

Analyze the source material:
1. Identify distinct features/components (3-10 proposals typically)
2. Extract requirements and constraints
3. Capture context and rationale
4. Note technical considerations and dependencies

### Step 3: Plan Proposal Structure

Design the set of proposals:
1. Group into feature-level proposals (each implementable independently)
2. Name proposals clearly (kebab-case IDs)
3. Document relationships and dependencies

Output the planned structure before creating files:
```
## Proposed OpenSpec Structure

### Proposals to Create
1. `<id-1>`: <title> - <brief description>
2. `<id-2>`: <title> - <brief description>

### Dependency Order
<id-1> -> <id-2> -> <id-3>
```

### Step 4: Create OpenSpec Proposals

For each identified proposal:

1. Initialize: `! openspec init <proposal-id>`

2. Create `proposal.md` with:
   - Summary, Motivation, Background
   - Scope (in/out), Requirements
   - Design Considerations, Dependencies
   - Risks and Success Criteria

3. Create `tasks.md` with 3-8 chunky tasks:
   - Each task has Goal, Background, Rationale
   - Subtasks, Acceptance Criteria, Considerations

### Step 5: Bootstrap Tickets (if --with-tickets)

If `--with-tickets` flag is present:
```
/tk bootstrap <proposal-id> "<Proposal Title>" --yes
```

### Step 6: Output Summary

```
## Breakdown Complete

### Proposals Created
| ID | Title | Tasks | Status |
|----|-------|-------|--------|
| <id-1> | <title> | N | Created |

### Next Steps
- Run `/tk queue` to see ready tickets
- Run `/tk start <ticket-id>` to begin implementation
```

---

## SELF-CHECK

Confirm you:
- [ ] Created proposal.md with full context
- [ ] Created tasks.md with 3-8 chunky tasks
- [ ] Each task has acceptance criteria
- [ ] Dependencies documented
- [ ] Did NOT implement any code
