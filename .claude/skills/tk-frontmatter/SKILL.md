---
name: tk-frontmatter
description: Edit tk ticket YAML frontmatter in .tickets/*.md to update files-modify/files-create safely
---

# tk-frontmatter Skill

Use this when you must add or update `files-modify` and `files-create` in a ticket.

## Steps

1. Find the ticket file in `.tickets/` by matching the ID prefix
2. Edit only the YAML frontmatter between `---` markers
3. Add or update `files-modify` / `files-create` as YAML arrays
4. Preserve existing fields and formatting
5. Leave the ticket body unchanged

## Example

```yaml
---
id: ab-123
status: open
files-modify:
  - src/api.ts
files-create: []
---
```
