# Model Selection Rationale

This document explains the default model choices in `.os-tk/config.json` and the reasoning behind using different models for the **planner**, **orchestrator**, and **worker** roles.

---

## The Three-Agent Architecture

The os-tk workflow uses three specialized agents with distinct responsibilities:

| Agent | Role | Key Trait |
|-------|------|-----------|
| **Planner** (`os-tk-planner`) | View-only analysis, queue inspection | View-only, high reasoning |
| **Orchestrator** (`os-tk-orchestrator`) | Ticket design and creation | Strong reasoning, can run `tk create/dep` |
| **Worker** (`os-tk-worker`) | Code implementation | Edit/write, execution speed |

This separation matters because:
- **Planning** tasks are strictly view-only (no mutations)
- **Orchestrating** requires strong reasoning to design good tickets, plus the ability to run `tk create`/`tk dep`
- **Implementation** benefits from speed and cost efficiency (writing code, running tests, iterating quickly)

---

## Planner: Strong Reasoning Model

**Default:** `openai/gpt-5.2` with `reasoningEffort: high`

### Why strong reasoning for planning?

The planner handles:
- Analyzing OpenSpec proposals and identifying gaps
- Decomposing work into 3-8 "chunky" tickets
- Setting up dependencies correctly
- Reviewing implementation scope before work starts

These tasks require:
1. **Holistic understanding** — seeing the full picture before breaking it down
2. **Edge case awareness** — catching missing acceptance criteria
3. **Dependency reasoning** — understanding what blocks what
4. **Conservative judgment** — the planner should never "hallucinate" work that doesn't exist in the spec

A strong reasoning model prevents:
- Over-decomposition (too many tiny tickets)
- Under-decomposition (monolithic tickets that are hard to review)
- Missed dependencies (blocked work appearing as "ready")
- Scope creep (tickets that exceed the spec)

### Cost justification

Planning and bootstrapping happen infrequently (once per feature/change), while implementation happens repeatedly (once per ticket). Spending more on planning/bootstrapping pays off in cleaner execution.

---

## Orchestrator: Strong Reasoning + Ticket Creation

**Default:** Same model as planner (`openai/gpt-5.2` with `reasoningEffort: high`)

### Why a separate orchestrator agent?

The orchestrator handles:
- Analyzing OpenSpec proposals deeply
- Decomposing work into 3-8 "chunky" tickets
- Setting up dependencies correctly
- Running `tk create` and `tk dep` commands

This requires:
1. **Strong reasoning** — same as planner, to design good ticket structures
2. **Execution permission** — must be able to run `tk create`/`tk dep` (unlike planner which is view-only)
3. **Limited file access** — can update `AGENTS.md` markers, but not code files

### Why not just use the planner?

The planner is intentionally **view-only** for safety. It should never mutate state. But ticket creation requires running `tk create` commands.

### Why not just use the worker?

The worker uses a fast OSS model optimized for code generation. Ticket design benefits from the same deep reasoning as planning — understanding scope, identifying edge cases, and structuring work well.

### The solution: a third agent

The orchestrator combines:
- **Planner's model** (strong reasoning)
- **Worker's bash permission** (can run `tk` commands)
- **Restricted file access** (can only update `AGENTS.md` markers, not code)

---

## Worker: Fast, Capable OSS Model

**Default:** `zai-coding-plan/glm-4.7` with `reasoningEffort: none` (omitted from agent file)

**Fallback:** `minimax/MiniMax-M2.1`

### Why a fast OSS model for implementation?

The worker handles:
- Reading ticket acceptance criteria
- Writing code to satisfy the criteria
- Running tests
- Iterating on failures

These tasks require:
1. **Speed** — fast iteration loops
2. **Code quality** — correct, idiomatic code
3. **Context efficiency** — handling large codebases without excessive cost
4. **Tool use** — reliable file editing, test running, etc.

Modern OSS models like GLM-4 and MiniMax-M2 excel at code generation while being significantly cheaper and faster than frontier models.

### Why not use the strongest model for everything?

1. **Cost** — Implementation involves many more tokens (reading files, writing code, test output). Using a frontier model for every edit is expensive.
2. **Latency** — Fast feedback loops matter during implementation. Waiting 30s for each edit kills flow.
3. **Diminishing returns** — For straightforward coding tasks guided by clear acceptance criteria, a capable OSS model performs nearly as well as frontier models.

### Fallback models

The `fallbackModels` array provides resilience:
- If the primary model is unavailable or rate-limited, the worker can fall back to alternatives
- MiniMax-M2.1 is a solid backup with similar capabilities

---

## Temperature Settings

| Agent | Temperature | Rationale |
|-------|-------------|-----------|
| Planner | `0` | Deterministic, consistent analysis |
| Worker | `0.2` | Slight creativity for problem-solving |

**Planner at 0:** Planning should be reproducible. Given the same spec, the planner should produce the same ticket structure. Temperature=0 ensures consistency.

**Worker at 0.2:** Implementation sometimes benefits from minor variation (e.g., choosing between equivalent approaches). A small temperature allows this without introducing randomness into the core logic.

---

## Reasoning Effort

The `reasoningEffort` field (when supported by the model) controls how much "thinking" the model does before responding:

| Level | Use Case |
|-------|----------|
| `high` | Complex analysis, planning, architecture |
| `medium` | Implementation, straightforward tasks |
| `low` | Simple queries, status checks |
| `none` | Model doesn't support reasoning effort (omits field from agent file) |

The planner uses `high` because planning benefits from deliberate analysis.

The worker uses `none` by default because the default worker models (GLM-4.7, MiniMax-M2.1) do not support the `reasoningEffort` parameter. Setting it to `"none"` tells `os-tk apply` to omit the field entirely from the generated agent YAML.

### When to use `"none"`

Use `"none"` when:
- The model doesn't support reasoning effort parameters (most OSS models)
- You want to use the model's default behavior without explicit reasoning control
- You're using fallback models that may not all support the same parameters

When `reasoningEffort` is set to `"none"` (case-insensitive), `os-tk apply` will generate agent files **without** a `reasoningEffort:` line in the YAML frontmatter.

---

## Customizing Models

Edit `.os-tk/config.json` to use different models:

```json
{
  "planner": {
    "model": "anthropic/claude-sonnet-4-20250514",
    "reasoningEffort": "high",
    "temperature": 0
  },
  "worker": {
    "model": "deepseek/deepseek-coder",
    "fallbackModels": ["openai/gpt-4o-mini"],
    "reasoningEffort": "none",
    "temperature": 0.2
  }
}
```

After editing, run:
```bash
os-tk apply
```

This regenerates the agent files with your new model settings.

---

## Recommended Model Pairings

| Use Case | Planner | Worker |
|----------|---------|--------|
| **Default (balanced)** | `openai/gpt-5.2` | `zai-coding-plan/glm-4.7` |
| **Cost-optimized** | `openai/gpt-4o` | `deepseek/deepseek-coder` |
| **Quality-first** | `anthropic/claude-sonnet-4-20250514` | `anthropic/claude-sonnet-4-20250514` |
| **OSS-only** | `meta/llama-3.1-405b` | `zai-coding-plan/glm-4.7` |

---

## Summary

- **Planner:** Strong reasoning model, temperature=0, high effort. Invest in good planning.
- **Worker:** Fast OSS model, temperature=0.2, medium effort. Optimize for iteration speed.
- **Fallbacks:** Provide resilience without manual intervention.

This split optimizes for both quality (plans) and efficiency (execution), which is the core philosophy of the os-tk workflow.
