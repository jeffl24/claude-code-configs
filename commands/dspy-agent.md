# Scaffold a New DSPy Agent

Create a new DSPy agent by analyzing the project's existing agents and matching the appropriate complexity to the task.

## Input

Agent description: $ARGUMENTS

## Instructions

### Phase 1: Discovery

1. **Read the base class contract:**
   - Read `api/src/agents/agent_base/agent.py` to understand required interfaces:
     - `data_map` property
     - `lm` property
     - `aforward()` async method
     - `AgentPrediction` return type
     - `self.callbacks` for MLflow tracing

2. **Analyze existing agents to build a complexity spectrum:**
   - Read `api/src/agents/planner/sub_agents.py` — simple single-predictor agents
   - Read `api/src/agents/sql_agent/sql_agent.py` — complex multi-stage agent with tools
   - Read any other agents under `api/src/agents/` that exist
   - For each, note: number of DSPy signatures, tools used, workflow stages, error handling depth

3. **Read the registration system:**
   - Read `api/agent-config.json` to understand how agents are registered
   - Read `api/src/agents/planner/agent_registry.py` to understand dynamic loading

### Phase 2: Propose

Based on the user's description in $ARGUMENTS, determine the closest existing agent in terms of complexity and present a proposal:

**Ask the user:**
- "Based on your description, this most closely resembles [ExistingAgent] because [reason]. I'll use it as a reference pattern."
- Agent name and module name
- Any tools or external resources it needs
- Which LLM config to use (show what existing agents use as options)

**Present the proposed architecture:**
- How many DSPy signatures/predictors are needed
- Whether it needs tools (and what kind)
- Single-pass vs multi-stage workflow
- What the `data_map` should return

Wait for user confirmation before generating code.

### Phase 3: Generate

1. **Create agent directory:** `api/src/agents/{module_name}/`
2. **Create agent module** modeled after the closest existing agent — DO NOT use a rigid template. Adapt the structure from the reference agent:
   - Use the same import style
   - Match the error handling pattern
   - Use `dspy.context(lm=self.lm, track_usage=True, callbacks=self.callbacks)` for all LLM calls
   - Return `AgentPrediction` via `.create_success()` / `.create_error()` factory methods
3. **Create `__init__.py`** with the agent's import
4. **Register in `api/agent-config.json`** under `planner.subAgents`

### Phase 4: Verify

1. Show the generated code and explain design decisions
2. Verify the import works: `cd api && python -c "from src.agents.{module_name} import {AgentName}; print('OK')"`
3. Offer to scaffold tests via `/unit-test-create`

## Important Rules

- ALWAYS read existing agents first — never generate from memory alone
- Match the complexity to the task — don't over-scaffold a simple agent
- Use `dspy.context()` block for ALL LLM operations (required for MLflow tracing)
- Always return `AgentPrediction` (never raw dspy.Prediction)
- Use async pattern (`aforward` + `acall`) — never blocking calls
- If the reference agent has patterns the new agent doesn't need, leave them out
