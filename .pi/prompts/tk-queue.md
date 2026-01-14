---
description: View the queue of ready and blocked tickets
---

# /tk-queue [next|all|<change-id>]

**Arguments:** $ARGUMENTS

1) If `next`: `tk ready --limit 1`
2) If `all`: `tk status`
3) If ID provided: `tk query ".parent == \"$1\" or .external_ref == \"openspec:$1\""`
4) Otherwise: `tk ready`
5) Summarize the queue and identify blockers.
