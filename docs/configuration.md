# Configuration Reference

The os-tk workflow is configured via `.os-tk/config.json`. This document explains each field in detail.

## Full Example

```json
{
  "templateRepo": "legout/openspec-ticket-opencode-starter",
  "templateRef": "v0.1.0",
  "useWorktrees": true,
  "worktreeDir": ".worktrees",
  "defaultParallel": 3,
  "mainBranch": "main",
  "autoPush": true,
  "unsafe": {
    "allowParallel": false,
    "allowDirtyDone": false,
    "commitStrategy": "prompt"
  },
  "planner": {
    "model": "openai/gpt-5.2",
    "reasoningEffort": "high",
    "temperature": 0
  },
  "worker": {
    "model": "zai-coding-plan/glm-4.7",
    "fallbackModels": ["minimax/MiniMax-M2.1"],
    "reasoningEffort": "none",
    "temperature": 0.2
  },
  "reviewer": {
    "autoTrigger": false,
    "categories": ["spec-compliance", "tests", "security", "quality"],
    "createTicketsFor": ["error"],
    "skipTags": ["no-review", "wip"],
    "scouts": [
      { "id": "opus45", "model": "google/antigravity-claude-opus-4-5-thinking", "reasoningEffort": "max" },
      { "id": "gpt52",  "model": "openai/gpt-5.2-codex", "reasoningEffort": "high" },
      { "id": "mini",   "model": "openai/gpt-5.1-codex-mini", "reasoningEffort": "high" },
      { "id": "grok",   "model": "opencode/grok-fast" }
    ],
    "adaptive": {
      "enabled": true,
      "maxParallelScouts": 3,
      "thresholds": {
        "small":  { "maxFiles": 4,  "maxChangedLines": 200 },
        "medium": { "maxFiles": 12, "maxChangedLines": 800 }
      },
      "defaults": {
        "small":  ["grok", "mini"],
        "medium": ["grok", "gpt52"],
        "large":  ["grok", "gpt52", "opus45"]
      }
    },
    "aggregatorStrong": {
      "model": "openai/gpt-5.2",
      "reasoningEffort": "medium"
    }
  }
}
```

---

## Template Settings

### `templateRepo`
**Type:** `string`  
**Default:** `"legout/openspec-ticket-opencode-starter"`

GitHub repository to sync `.opencode/` files from.

### `templateRef`
**Type:** `string`  
**Default:** `"v0.1.0"`  
**Valid values:** Any git tag (e.g., `"v1.0.0"`), branch name (e.g., `"main"`), or `"latest"`

Version to sync when running `os-tk sync`. Use `"latest"` to always get the newest release.

---

## Git & Parallel Execution

### `useWorktrees`
**Type:** `boolean`  
**Default:** `true`

Controls how parallel ticket execution works:

| Value | Behavior |
|-------|----------|
| `true` | Each ticket gets an isolated git worktree in `worktreeDir`. Safe for parallel work. Branches named `ticket/<id>`. |
| `false` | All work happens in the main working tree. Simpler but riskier for parallel execution. |

**Recommendation:** Use `true` unless you have a specific reason not to.

### `worktreeDir`
**Type:** `string`  
**Default:** `".worktrees"`

Directory where git worktrees are created (when `useWorktrees: true`). Automatically added to `.gitignore`.

### `defaultParallel`
**Type:** `number`  
**Default:** `3`

How many tickets to process in parallel when using `/tk-start <id1> <id2> ... --parallel`.

### `mainBranch`
**Type:** `string`  
**Default:** `"main"`

The primary branch to merge completed tickets into.

### `autoPush`
**Type:** `boolean`  
**Default:** `true`

Whether `/tk-done` should automatically push to the remote after merging.

---

## Unsafe Settings

These settings relax safety guarantees. Use with caution.

### `unsafe.allowParallel`
**Type:** `boolean`  
**Default:** `false`

When `useWorktrees: false`, this allows multiple tickets to run in parallel in the same working tree.

**Warning:** This can cause merge conflicts and mixed commits. Only enable if you understand the risks.

### `unsafe.allowDirtyDone`
**Type:** `boolean`  
**Default:** `false`

Allow `/tk-done` to proceed even if the working tree has uncommitted changes unrelated to the current ticket.

### `unsafe.commitStrategy`
**Type:** `string`  
**Default:** `"prompt"`  
**Valid values:** `"prompt"`, `"all"`, `"fail"`

What to do when the working tree has changes that might not belong to the current ticket:

| Value | Behavior |
|-------|----------|
| `"prompt"` | Ask the user how to proceed |
| `"all"` | Commit everything with the ticket ID prefix |
| `"fail"` | Refuse to commit; recommend enabling worktrees |

---

## Agent Models

These settings control which AI models are used for different workflow phases.

### `planner.model`
**Type:** `string`  
**Default:** `"openai/gpt-5.2"`

Model for planning and view-only commands (`/os-change`, `/tk-queue`, `/tk-bootstrap`). Should be a strong reasoning model.

**Examples:**
- `"openai/gpt-5.2"` — OpenAI GPT-5.2
- `"anthropic/claude-opus-4-5-20250514"` — Claude Opus 4.5
- `"google/gemini-2.5-pro"` — Gemini 2.5 Pro

### `planner.reasoningEffort`
**Type:** `string`  
**Default:** `"high"`  
**Valid values:** `"none"`, `"low"`, `"medium"`, `"high"`

How much reasoning/thinking the model should do. Higher = more thorough but slower.

### `planner.temperature`
**Type:** `number`  
**Default:** `0`  
**Range:** `0` to `1`

Randomness in model output. `0` = deterministic, `1` = creative. For planning, low values are recommended.

---

### `worker.model`
**Type:** `string`  
**Default:** `"zai-coding-plan/glm-4.7"`

Model for implementation (`/tk-start`). Can be a faster, cheaper model since it's doing the "grunt work" of coding.

**Examples:**
- `"zai-coding-plan/glm-4.7"` — GLM 4.7 (fast, good for code)
- `"minimax/MiniMax-M2.1"` — MiniMax M2.1
- `"anthropic/claude-sonnet-4-20250514"` — Claude Sonnet 4

### `worker.fallbackModels`
**Type:** `string[]`  
**Default:** `["minimax/MiniMax-M2.1"]`

Models to try if the primary worker model fails or is unavailable.

### `worker.reasoningEffort`
**Type:** `string`  
**Default:** `"none"`

For fast worker models, `"none"` is typically fine since they're executing a defined plan.

### `worker.temperature`
**Type:** `number`  
**Default:** `0.2`

Slightly higher than planner to allow some creativity in implementation.

---

## Reviewer Settings

Controls the `/tk-review` code review automation.

### `reviewer.autoTrigger`
**Type:** `boolean`  
**Default:** `false`

Whether to automatically run `/tk-review` after `/tk-done` completes.

| Value | Behavior |
|-------|----------|
| `false` | Manual only — you must explicitly call `/tk-review <id>` |
| `true` | Automatic — `/tk-done` triggers review, `/tk-run` includes review step |

**Recommendation:** Start with `false` to understand the workflow, then enable `true` for autonomous operation.

### `reviewer.categories`
**Type:** `string[]`  
**Default:** `["spec-compliance", "tests", "security", "quality"]`

Which review checks to run:

| Category | What it checks |
|----------|----------------|
| `"spec-compliance"` | Does implementation match OpenSpec requirements and scenarios? |
| `"tests"` | Are acceptance criteria covered by tests? Any missing test coverage? |
| `"security"` | SQL injection, XSS, hardcoded secrets, auth issues, unsafe patterns |
| `"quality"` | Code patterns, DRY violations, error handling, TODOs left behind |

Remove categories to skip those checks. For example, `["spec-compliance", "security"]` skips test and quality checks.

### `reviewer.createTicketsFor`
**Type:** `string[]`  
**Default:** `["error"]`  
**Valid values:** `"error"`, `"warning"`, `"info"`

Severity threshold for creating fix tickets:

| Severity | Meaning | Creates ticket if in array |
|----------|---------|---------------------------|
| `"error"` | Must fix — blocks quality | Yes by default |
| `"warning"` | Should fix — improves quality | No by default |
| `"info"` | Nice to have — optional improvement | No by default |

**Examples:**
- `["error"]` — Only create tickets for critical issues (default, less noise)
- `["error", "warning"]` — Create tickets for errors and warnings (more thorough)
- `[]` — Never create fix tickets (review is informational only)

### `reviewer.skipTags`
**Type:** `string[]`  
**Default:** `["no-review", "wip"]`

Tickets with any of these tags will skip review entirely.

**Use cases:**
- `"no-review"` — Explicitly skip review for this ticket
- `"wip"` — Work in progress, don't review yet
- `"prototype"` — Throwaway code, no need to review
- `"docs-only"` — Documentation changes, skip code review

---

### `reviewer.scouts`
**Type:** `object[]`  
**Default:** (List of 4 models including Opus 4.5, GPT-5.2, Mini, Grok)

**OpenCode only.** List of models used for parallel review "scouting". Each scout is read-only and emits findings for aggregation.

| Field | Description |
|-------|-------------|
| `id` | Short identifier (e.g., `"opus45"`) |
| `model` | AI model string |
| `reasoningEffort` | `"none"`, `"low"`, `"medium"`, `"high"` |

### `reviewer.adaptive`
**Type:** `object`

**OpenCode only.** Configures the adaptive review pipeline which chooses scouts and aggregators based on change complexity.

| Field | Description |
|-------|-------------|
| `enabled` | `true` to use complexity heuristics |
| `maxParallelScouts` | Maximum concurrent scout subtasks |
| `thresholds` | Limits for "small" and "medium" buckets |
| `defaults` | Which scout IDs to run per bucket |

### `reviewer.aggregatorStrong`
**Type:** `object`

**OpenCode only.** Configures the high-quality aggregator used for large or risky reviews.

| Field | Description |
|-------|-------------|
| `model` | AI model string (default: `"openai/gpt-5.2"`) |
| `reasoningEffort` | Default: `"medium"` |

---

## After Changing Config

After editing `.os-tk/config.json`, run:

```bash
os-tk apply
```

This regenerates the agent files (`.opencode/agent/*.md`) with the updated model settings.

---

## Config Recipes

### Minimal (Fastest)
```json
{
  "useWorktrees": false,
  "planner": { "model": "openai/gpt-4.1-mini", "temperature": 0 },
  "worker": { "model": "openai/gpt-4.1-mini", "temperature": 0.2 },
  "reviewer": { "autoTrigger": false }
}
```

### Maximum Quality (Multi-Model, OpenCode only)
```json
{
  "useWorktrees": true,
  "planner": { "model": "openai/gpt-5.2", "reasoningEffort": "high" },
  "worker": { "model": "zai-coding-plan/glm-4.7" },
  "reviewer": {
    "autoTrigger": true,
    "scouts": [
      { "id": "opus", "model": "google/antigravity-claude-opus-4-5-thinking", "reasoningEffort": "high" },
      { "id": "gpt52", "model": "openai/gpt-5.2-codex", "reasoningEffort": "high" }
    ],
    "aggregatorStrong": { "model": "openai/gpt-5.2", "reasoningEffort": "medium" }
  }
}
```

### Cost-Optimized (Adaptive, OpenCode only)
```json
{
  "planner": { "model": "openai/gpt-5.2", "reasoningEffort": "high" },
  "worker": { "model": "zai-coding-plan/glm-4.7" },
  "reviewer": { 
    "autoTrigger": true,
    "adaptive": { "enabled": true },
    "scouts": [
      { "id": "grok", "model": "opencode/grok-fast" },
      { "id": "mini", "model": "openai/gpt-5.1-codex-mini" }
    ]
  }
}
```

### Autonomous Ralph Mode
```json
{
  "useWorktrees": true,
  "autoPush": true,
  "reviewer": {
    "autoTrigger": true,
    "categories": ["spec-compliance", "tests", "security"],
    "createTicketsFor": ["error"]
  }
}
```
