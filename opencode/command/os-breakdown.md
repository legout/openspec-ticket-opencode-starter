---
description: Break down a project plan/PRD into comprehensive OpenSpec proposals [ulw]
agent: os-tk-planner
permission:
  skill: allow
  bash: allow
  edit: allow
  write: allow
---

# /os-breakdown <source> [--with-tickets]

**Arguments:** $ARGUMENTS

Parse:
- `source`: Required. One of:
  - `@file.md` — A file reference (PRD, project plan, implementation spec)
  - `@folder/` — A folder containing multiple plan documents
  - `https://...` — A URL to fetch and parse
  - Inline text — A brief description to expand
- `--with-tickets`: Optional flag to auto-bootstrap tickets after creating proposals

---

## PURPOSE

Transform a high-level project plan, PRD, or implementation specification into a comprehensive set of **feature-level OpenSpec proposals**. Each proposal is self-contained and self-documenting, including:

- Detailed background and context
- Reasoning and justifications for decisions
- Considerations and trade-offs
- How it serves the overarching project goals
- Complete task breakdowns with acceptance criteria

---

## EXECUTION CONTRACT

### ALLOWED
- Read files, folders, URLs, or inline text
- Use `openspec` skill and CLI to create/modify proposals
- Create files under `openspec/changes/<id>/`
- Call `/tk-bootstrap` for each proposal if `--with-tickets` is present
- Use extended reasoning (ultrathink) for deep analysis

### FORBIDDEN
- Implement code (only create specs)
- Skip proposal creation and jump directly to tickets
- Create tickets without corresponding proposals
- Modify existing specs outside `openspec/changes/`
- Edit code files (*.py, *.ts, *.js, *.go, etc.)

---

## Step 1: Ingest Source Material

Read and parse the input:

- If `@file` → Read the file contents
- If `@folder/` → Read all markdown/text files in the folder
- If URL → Fetch and parse the content
- If inline text → Use the provided text directly

Combine all sources into a unified understanding of the project requirements.

---

## Step 2: Deep Analysis (Ultrathink)

Use extended reasoning to deeply analyze the source material:

### 2.1 Identify Distinct Features/Components
- What are the major features or functional areas?
- How do they relate to each other?
- What is the logical grouping for implementation?

### 2.2 Extract Requirements and Constraints
- What are the explicit requirements?
- What constraints are implied (technical, business, timeline)?
- What dependencies exist between features?

### 2.3 Capture Context and Rationale
- What is the motivation behind each feature?
- What problem does it solve?
- What are the trade-offs and alternatives considered?
- What background information is essential for understanding?

### 2.4 Note Technical Considerations
- What architectural decisions are implied?
- What technologies or patterns are relevant?
- What risks or challenges exist?

---

## Step 3: Plan Proposal Structure

Design the set of proposals:

### 3.1 Group Into Feature-Level Proposals
- Each proposal should represent one cohesive feature
- Target 3-10 proposals for a typical project plan
- Each should be implementable independently (with dependencies noted)

### 3.2 Name Proposals Clearly
- Use kebab-case IDs (e.g., `user-authentication`, `data-export`, `notification-system`)
- Names should be descriptive and self-explanatory

### 3.3 Document Relationships
- Note which proposals depend on others
- These dependencies will be formalized at the ticket level during bootstrap

### 3.4 Output Proposal Plan
Before creating files, output the planned structure:

```
## Proposed OpenSpec Structure

### Proposals to Create
1. `<id-1>`: <title> — <brief description>
2. `<id-2>`: <title> — <brief description>
...

### Dependency Order (for implementation)
<id-1> → <id-2> → <id-3>
<id-4> (independent)
...

Proceeding to create proposals...
```

---

## Step 4: Create OpenSpec Proposals

For each identified proposal, use the `openspec` skill to create the change:

### 4.1 Initialize the Change
```bash
openspec init <proposal-id>
```

### 4.2 Create proposal.md

Write a comprehensive `proposal.md` with the following structure:

```markdown
# <Proposal Title>

## Summary
<1-2 paragraph executive summary of what this change accomplishes>

## Motivation
<Why is this needed? What problem does it solve?>
<How does it serve the overarching project goals?>

## Background
<Relevant context, history, or existing system state>
<What does a "future self" need to know to understand this?>

## Scope

### In Scope
- <Feature 1>
- <Feature 2>
...

### Out of Scope
- <Explicitly excluded items>

## Requirements

### Functional Requirements
- REQ-1: <Requirement description>
- REQ-2: <Requirement description>
...

### Non-Functional Requirements
- NFR-1: <Performance, security, scalability, etc.>
...

## Design Considerations
<Technical decisions, trade-offs, alternatives considered>
<Reasoning and justification for chosen approach>

## Dependencies
<Other proposals or external dependencies>
<Implementation order considerations>

## Risks and Mitigations
<Known risks and how to address them>

## Success Criteria
<How will we know this is successfully implemented?>
```

### 4.3 Create tasks.md

Write a detailed `tasks.md` with 3-8 chunky tasks:

```markdown
# Tasks: <Proposal Title>

## Overview
<Brief summary of implementation approach>

---

## 1. <Task Title>

**Goal:** <What this task accomplishes>

**Background:** <Context needed to implement this correctly>

**Rationale:** <Why this task exists and why in this order>

### Subtasks
- [ ] 1.1 <Subtask description>
- [ ] 1.2 <Subtask description>
...

### Acceptance Criteria
- <Measurable criterion 1>
- <Measurable criterion 2>

### Considerations
<Technical notes, edge cases, things to watch out for>

---

## 2. <Next Task Title>
...
```

Each task should:
- Be a meaningful deliverable (not a single checkbox)
- Include enough context to stand alone
- Have clear acceptance criteria
- Document the reasoning behind it

### 4.4 Create design.md (if needed)

For complex proposals, create a `design.md` with:
- Architecture diagrams or descriptions
- API specifications
- Database schema changes
- Technical implementation details

---

## Step 5: Bootstrap Tickets (if --with-tickets)

If `--with-tickets` flag is present:

For each created proposal, invoke the bootstrap command:

```
/tk-bootstrap <proposal-id> "<Proposal Title>" --yes
```

This creates:
- One epic per proposal
- 3-8 task tickets per epic
- Dependencies between tickets

---

## Step 6: Output Summary

Provide a comprehensive summary:

```
## Breakdown Complete

### Proposals Created
| ID | Title | Tasks | Status |
|----|-------|-------|--------|
| <id-1> | <title> | N | Created |
| <id-2> | <title> | M | Created |
...

### File Structure
openspec/changes/
├── <id-1>/
│   ├── proposal.md
│   └── tasks.md
├── <id-2>/
│   ├── proposal.md
│   ├── tasks.md
│   └── design.md
...

### Implementation Order (Recommended)
1. <id-X> — <rationale>
2. <id-Y> — <rationale>
...

### Next Steps
<If --with-tickets was used>
- Run `/tk-queue` to see ready tickets
- Run `/tk-start <ticket-id>` to begin implementation

<If --with-tickets was NOT used>
- Review the proposals in `openspec/changes/`
- Run `/tk-bootstrap <id> "<title>" --yes` for each proposal to create tickets
- Or run `/os-breakdown <source> --with-tickets` to auto-bootstrap all
```

---

## SELF-CHECK (Before Responding)

Confirm you:
- [ ] Created a proposal.md with full context (motivation, background, rationale)
- [ ] Created tasks.md with 3-8 chunky, self-documenting tasks
- [ ] Each task has acceptance criteria and reasoning
- [ ] Dependencies between proposals are documented
- [ ] If `--with-tickets`: bootstrapped all proposals
- [ ] Did NOT implement any code
- [ ] Did NOT skip proposals and create only tickets

---

## EXAMPLES

### Example 1: Single PRD File
```
/os-breakdown @docs/product-requirements.md
```

Creates proposals for each major feature in the PRD.

### Example 2: Folder of Specs
```
/os-breakdown @project-planning/ --with-tickets
```

Reads all files in the folder, creates proposals, and bootstraps tickets.

### Example 3: URL
```
/os-breakdown https://example.com/api-spec.md
```

Fetches the spec and creates proposals.

### Example 4: Inline Description
```
/os-breakdown Build a task management app with user auth, projects, tasks, and team collaboration
```

Expands the brief description into comprehensive proposals.
