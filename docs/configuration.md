# Configuration Reference

The os-tk workflow is configured via `config.json`. This document explains each field in detail.

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

GitHub repository to sync `opencode/` files from.

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

---

## After Changing Config

After editing `config.json`, run:

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
