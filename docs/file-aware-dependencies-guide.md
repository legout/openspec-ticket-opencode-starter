# File-Aware Dependencies: User Guide

This guide explains how to use the file-aware dependency management feature in the os-tk workflow.

## Overview

File-aware dependency management prevents merge conflicts when working on multiple tickets in parallel. It does this by:

1. **Predicting file changes**: Tickets declare which files they'll modify or create
2. **Detecting overlaps**: The system finds when multiple tickets touch the same files
3. **Auto-generating dependencies**: Hard dependencies are added to serialize conflicting work
4. **Conflict-safe recommendations**: Only non-conflicting tickets are recommended for parallel work

## How It Works

### 1. File Predictions in Tickets

When creating tickets (via `/tk-bootstrap`), each ticket gets file predictions in its YAML frontmatter:

```yaml
---
id: ab-123
status: open
files-modify:
  - src/api/auth.ts
  - src/middleware/auth.ts
files-create:
  - src/types/UserCredentials.ts
  - src/types/Session.ts
---
```

- **files-modify**: Files that will be changed by this ticket
- **files-create**: New files that will be created by this ticket
- **Empty arrays are valid**: Use `files-modify: []` if a ticket doesn't change existing files

### 2. Overlap Detection

When you run `/tk-queue --all`, the system:

- Queries all tickets for their file predictions
- Checks for overlapping files in `files-modify` and `files-create`
- Creates dependencies using `tk dep` to serialize work on overlapping files

Example output:
```
Ready tickets (4):
- ab-123: Add authentication API [P2][open]
  files-modify: src/api/auth.ts, src/middleware/auth.ts
  files-create: src/types/UserCredentials.ts

- ab-456: Add authorization middleware [P2][open]
  files-modify: src/api/auth.ts, src/middleware/auth.ts
  ⚠️ Overlap detected: both modify src/api/auth.ts

File overlap resolution:
- Created dependency: ab-456 blocked by ab-123
- Total dependencies created: 1
```

### 3. Conflict-Safe Recommendations

When you run `/tk-queue --next`, the system:

- Checks recommended ticket's files against in-progress tickets
- Skips tickets that would conflict with active work
- Recommends a safe ticket instead

Example output:
```
⚠️ Skipping ab-456: modifies src/api/auth.ts (already modified by in-progress ab-123)

Recommended ticket:
- ab-789: Add user profile UI [P2][open]
  files-modify: src/ui/Profile.tsx
  ✅ No file conflicts with in-progress work

Would you like me to start this ticket? Run `/tk-start ab-789`
```

## Usage Workflow

### Step 1: Bootstrap Tickets

When starting a new feature, use `/tk-bootstrap` to create tickets:

```bash
/tk-bootstrap add-user-auth "Add user authentication system" --yes
```

The orchestrator will:
1. Analyze the OpenSpec change
2. Design 3-8 chunky tickets
3. Predict file changes for each ticket
4. Add `files-modify` and `files-create` to ticket frontmatter

### Step 2: Check Queue with Overlap Detection

See all ready tickets with overlap detection:

```bash
/tk-queue --all
```

Output shows:
- All ready tickets
- File predictions for each ticket
- Overlap warnings
- Dependencies created to prevent conflicts
- Tickets missing file predictions

### Step 3: Get Safe Recommendation

Get a ticket that won't conflict with in-progress work:

```bash
/tk-queue --next
```

The system:
- Skips conflicting tickets
- Recommends a safe alternative
- Explains any conflicts clearly

### Step 4: Start Implementation

Start the recommended ticket:

```bash
/tk-start ab-789
```

If using worktrees:
- Creates isolated worktree at `.worktrees/ab-789/`
- Creates branch `ticket/ab-789`
- Implementation happens in isolation

### Step 5: Close and Sync

Complete the ticket:

```bash
/tk-done ab-789 add-user-auth
```

This:
- Closes the ticket
- Syncs OpenSpec tasks.md
- Archives the change
- Merges the branch
- Pushes to remote

## Best Practices

### 1. Accurate File Predictions

When bootstrapping tickets, be specific about file changes:

**Good:**
```yaml
files-modify:
  - src/api/auth.ts
  - src/middleware/auth.ts
```

**Bad:**
```yaml
files-modify:
  - auth files
  - backend code
```

### 2. Over-Predict When Uncertain

If you're not sure which files will be touched, include them:

**Uncertain but safe:**
```yaml
files-modify:
  - src/api/auth.ts
  - src/middleware/auth.ts
  - src/config.ts  # might need changes
```

This may create unnecessary dependencies (false positives), but prevents merge conflicts. You can manually remove dependencies if they're not needed.

### 3. Regular Queue Checks

Run `/tk-queue` frequently to:
- See new overlap detections
- Check which tickets are ready
- Understand what's blocking progress

### 4. Monitor In-Progress Work

When using worktrees, check active work:

```bash
ls -d .worktrees/*/ 2>/dev/null
```

Output:
```
.worktrees/ab-123/
.worktrees/ab-456/
```

Two tickets are in progress. The queue will skip any tickets that conflict with these.

## Configuration

File-aware deps behavior is configured in `.os-tk/config.json`:

```json
{
  "useWorktrees": true,
  "worktreeDir": ".worktrees",
  "defaultParallel": 3,
  "fileAwareDeps": {
    "enabled": true,
    "overlapStrategy": "dependency",
    "allowOverwrite": false
  }
}
```

### Configuration Options

- **useWorktrees**: Enable isolated worktrees for parallel execution
- **worktreeDir**: Directory where worktrees are created
- **defaultParallel**: Default number of parallel workers
- **fileAwareDeps.enabled**: Enable file-aware dependency management
- **fileAwareDeps.overlapStrategy**: How to handle overlaps ("dependency" or "warning")
- **fileAwareDeps.allowOverwrite**: Allow manual overrides (if false, always hard-block)

## Advanced Scenarios

### Scenario 1: Manual Override

If the system creates a dependency you don't need:

```bash
tk dep remove ab-456 ab-123
```

This removes the dependency, allowing both tickets to run in parallel. Use with caution - only do this if you're sure the files won't actually conflict.

### Scenario 2: Adding Predictions to Existing Tickets

If you have old tickets without file predictions:

```bash
tk show ab-123
```

Edit the ticket file to add:
```yaml
---
id: ab-123
... (other fields)
files-modify:
  - src/api.ts
files-create: []
---
```

### Scenario 3: Legacy Migration

For repositories with existing tickets:

1. Run `/tk-queue --all` on your backlog
2. The system will flag tickets without predictions
3. Add predictions to high-priority tickets first
4. Over time, add predictions to all tickets

## Troubleshooting

### Problem: Too Many Dependencies Created

**Cause**: Over-prediction or overly conservative overlap detection

**Solution**:
- Review file predictions for accuracy
- Remove unnecessary dependencies: `tk dep remove <blocked> <blocker>`
- Adjust overlap strategy in config to "warning" mode (advisory only)

### Problem: Queue Always Shows "No Tickets Available"

**Cause**: All ready tickets conflict with in-progress work

**Solution**:
- Wait for current work to complete
- Review file predictions - are they too broad?
- Check if conflicts are real or theoretical

### Problem: File Predictions Are Wrong

**Cause**: Predictions made during bootstrap didn't match actual implementation

**Solution**:
- Update predictions as you learn more: edit ticket frontmatter
- Run `/tk-queue --all` again to re-detect overlaps
- No penalty for being wrong - the system uses best-effort predictions

### Problem: Merge Conflict Despite File-Aware Deps

**Cause**: File predictions were incomplete or missing

**Solution**:
1. Resolve the merge conflict manually
2. Update file predictions for both tickets to include the conflicting file
3. Run `/tk-queue --all` to create dependency for future runs

## FAQ

**Q: Do I have to add file predictions?**

A: No, they're optional. But without them, the system can't detect overlaps, and you may encounter merge conflicts when working in parallel.

**Q: What if I don't know which files I'll modify?**

A: Make a best guess based on the ticket description. Over-predicting is safer than under-predicting. You can always update predictions later.

**Q: Can I work on tickets in parallel without file predictions?**

A: Yes, but you lose the safety net. The system won't detect conflicts, and you may encounter merge conflicts at merge time.

**Q: How accurate do predictions need to be?**

A: Aim for 80% accuracy. Some false positives (unnecessary dependencies) are fine. False negatives (missing predictions that cause conflicts) are problematic.

**Q: Does this work with branches without worktrees?**

A: Yes, file-aware deps works regardless of `useWorktrees` setting. However, worktrees provide stronger isolation for parallel execution.

**Q: Can I disable this feature?**

A: Yes, set `fileAwareDeps.enabled: false` in `.os-tk/config.json`. The system will then behave like before, with no file overlap detection.

## Related Commands

- **`/tk-bootstrap`**: Create tickets with file predictions
- **`/tk-queue --all`**: See all ready tickets with overlap detection
- **`/tk-queue --next`**: Get conflict-safe recommendation
- **`/tk-start`**: Begin implementation (creates worktree if enabled)
- **`/tk-done`**: Complete ticket and sync OpenSpec

## See Also

- [Test Plan](./tests/file-aware-dependencies.md) - Comprehensive test scenarios
- [Design Doc](../openspec/changes/add-file-aware-deps/design.md) - Technical design decisions
- [Agent Contract](../opencode/agent/os-tk-orchestrator.md) - Orchestrator behavior
