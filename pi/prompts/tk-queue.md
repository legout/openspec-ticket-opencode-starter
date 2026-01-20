---
description: View the queue of ready and blocked tickets
---

# /tk-queue [--next|--all|--change <change-id>]

**Arguments:** $ARGUMENTS

1) Parse flags (`--next`, `--all`, `--change <id>`) with positional fallback `next|all|<change-id>`.
2) Gather queue: `tk ready`, `tk blocked`.
3) If change filter: `tk query ".parent == \"$1\" or .external_ref == \"openspec:$1\""`
4) Generate missing `files-modify` / `files-create` predictions and update ticket frontmatter (edit `.tickets/<id>.md`).
   - Use the **tk-frontmatter** skill for edits.
5) Detect overlaps and add dependencies with `tk dep` to serialize conflicts.
6) Summarize the queue and identify blockers.
