---
description: Review a completed ticket using multi-model adaptive aggregation
---

# /tk-review <ticket-id> [options]

**Arguments:** $ARGUMENTS

## Pre-execution Check
Check if the `subagent` extension is installed by checking for the `subagent` tool. If not available, instruct the user to install it globally at `~/.pi/agent/extensions/subagent`.

## Step 1: Validation and Context

Read `.os-tk/config.json` and check `skipTags`.
Ensure ticket is closed: `tk show $1`.

## Step 2: Adaptive Complexity Scoring

1. Find the merge commit: `git log --oneline --grep=\"$1\" -1`.
2. Get diff stats:
   - `files_changed`: `git show --name-only <sha> | wc -l`
   - `lines_changed`: `git diff --shortstat <sha>^..<sha>`
3. Identify **risk signals**:
   - Check if diff touches: `auth`, `security`, `crypto`, `migrations`, `lockfile`, `config`.

## Step 3: Routing Logic

Based on `reviewer.adaptive` config:

- **SMALL**: (files <= 4 AND lines <= 200) AND NOT risky
  - Use **FAST** aggregator.
  - Default scouts: `mini`. (Add more scouts if needed)
- **MEDIUM**: (files <= 12 AND lines <= 800) AND NOT risky
  - Use **FAST** aggregator.
- **LARGE / RISKY**: (else)
  - Use **STRONG** aggregator.

## Step 4: Delegate

Use `subagent` tool to run the review pipeline:
1. Spawn scouts in parallel using `subagent.parallel`.
2. Spawn aggregator using `subagent.single` to merge results.

---

## EXECUTION CONTRACT

This command acts as an **orchestrator and router**. It computes complexity and delegates the actual review to the multi-model aggregator subtask via the Pi `subagent` extension.
