---
description: Start multiple tickets in parallel as background tasks [ultrahardwork]
---

**Ticket IDs:** $ARGUMENTS

For EACH ticket ID provided in `$ARGUMENTS`:
- **CRITICAL:** Use your **slashcommand** tool to invoke `/tk-start <id>`. 
- Do NOT run `tk start` in bash; you MUST use the `/tk-start` slash command so the background implementation logic is triggered.

**Important:** Each `/tk-start` call will automatically spawn a background task handled by the `os-tk-agent`.

After initiating all tasks using the tool, confirm to the user:
> "Started <N> tickets in parallel: <id1>, <id2>, ... Each is running as a background task via `os-tk-agent`."

<!-- ultrahardwork -->
