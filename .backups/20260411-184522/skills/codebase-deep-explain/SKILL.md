# Codebase Deep Explain — Painstaking Codebase Explanation with ASCII Flowcharts

Produce an exhaustive, layered technical explanation of a codebase with inline ASCII flowcharts at every layer. The document reads like a guided architectural tour — each section builds on the previous one, with a flowchart showing exactly how that layer works before moving deeper. Export to `deep-explain.md` in the project root.

## Input

Target: $ARGUMENTS

If no argument is provided, analyze the current working directory as the project root.

## Instructions

### Phase 1: Discovery

1. **Scope the analysis:**
   - If a file or directory path is given, scope to that subtree
   - If a description is given (e.g., "the auth module"), search for matching files
   - If no argument, use the current working directory

2. **Map the project structure:**
   - Use Glob to find all source files (`**/*.py`, `**/*.ts`, `**/*.js`, `**/*.go`, `**/*.rs`, `**/*.java`, etc.)
   - Read `README.md`, `DESIGN.md`, `ARCHITECTURE.md`, or similar docs if they exist
   - Read config files (`pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, etc.)
   - Identify the language/framework stack

3. **Identify entry points:**
   - CLI commands, main functions, API routes, event handlers
   - Read these files first to understand the top-level flow

4. **Read all key source files** (not tests, not generated code):
   - Start from entry points and follow imports/dependencies
   - For each module, understand: inputs, processing logic, outputs, side effects
   - Identify design patterns (DI, lazy evaluation, builder, observer, etc.)
   - Note any LLM/AI agent logic: prompts, chains, tool use, RAG pipelines

### Phase 2: Layered Explanation with Inline Flowcharts

Structure the document as **progressive layers**, from highest abstraction to lowest detail. Each layer MUST include:
- A plain-language explanation of what this layer does and why
- An ASCII flowchart showing the flow/structure at this layer
- A table of key components with file paths, responsibilities, and patterns
- Connections to the layers above and below

#### Layer 1: Bird's Eye View
- What problem does this system solve? (2-3 sentences)
- What is the high-level approach / architecture style?
- Who are the actors? (users, external systems, cron jobs, etc.)
- **Flowchart:** System context diagram — show the system as a single box with all external actors/systems around it, arrows showing what flows in and out

#### Layer 2: Major Pipeline Stages
- Break the system into 3-7 major stages/phases (e.g., Ingest → Process → Store → Serve)
- For each stage: one-sentence purpose, primary input, primary output
- How stages connect — sync vs async, queues, direct calls, file hand-offs
- **Flowchart:** End-to-end pipeline diagram showing all stages as boxes connected by arrows, with data types labeled on each arrow

#### Layer 3: Component Architecture
- For each major stage, decompose into its constituent modules/classes
- Show the dependency graph — what depends on what
- Identify the "heart" of the system (the most important module everything revolves around)
- **Flowchart:** Component diagram per stage — show classes/modules as boxes, with arrows for dependencies, inheritance, and data flow. Group related components with labeled borders.

#### Layer 4: Core Logic Deep-Dive
- For the most important 3-5 modules/classes:
  - What it does and why it exists (not just what — WHY this abstraction)
  - Key methods/functions: signature, logic summary, edge cases handled
  - State management: what state does it hold, how does it change
  - Error handling: what can go wrong, how is it handled
- **Flowchart:** Per-module logic flow — show the internal processing steps of each core module, including decision points, loops, and error paths

#### Layer 5: Data Model & State
- All significant data structures, schemas, models
- How data transforms as it moves through the pipeline (show the shape at each stage)
- Database schemas, file formats, API contracts
- **Flowchart:** Data transformation diagram — show data shape at each stage with arrows showing transformations

#### Layer 6: Configuration, Infrastructure & Glue
- How the system is configured (env vars, config files, CLI args)
- Dependency injection / wiring — how components find each other
- External service integrations (APIs, databases, file systems, LLM providers)
- **Flowchart:** Infrastructure wiring diagram — show config sources flowing into components, external services connected to adapters

#### Layer 7: End-to-End Trace
- Pick the most representative use case and trace it from input to output
- Show EVERY function call, data transformation, and side effect in order
- Include timing/sequencing where relevant (what happens first, what waits for what)
- **Flowchart:** Sequence-style diagram showing the full trace — each component as a column, arrows showing calls between them in order

### Phase 3: Cross-Cutting Analysis

After the layered explanation, include:

1. **Design Patterns & Decisions Table**

| Pattern | Where Used | Why | Tradeoff |
|---------|-----------|-----|----------|
| ... | `file.py:ClassName` | ... | ... |

2. **Dependency Map**

| Component | Depends On | Depended On By |
|-----------|-----------|----------------|
| ... | ... | ... |

3. **External Dependencies & Integrations**

| Service/Library | Purpose | Config Location | Access Pattern |
|----------------|---------|-----------------|----------------|
| ... | ... | ... | ... |

4. **Gaps & Questions**
   - Anything that seems incomplete, inconsistent, or unclear in the codebase
   - Missing error handling, undocumented behavior, dead code
   - Do NOT invent answers — just flag the questions

### Phase 4: ASCII Flowchart Style Guide

All flowcharts MUST use pure ASCII/Unicode box-drawing characters. No Mermaid. No diagramming DSL.

```
┌─────────────────────┐
│   Input / Step       │
└──────────┬──────────┘
           │
           v
    ┌──────┴──────┐
    │  Process     │
    └──────┬──────┘
           │
      ┌────┴────┐
      │ Decision?│
      └──┬───┬──┘
     Yes │   │ No
         v   v
```

Rules:
- Use `┌ ┐ └ ┘ ─ │ ┬ ┴ ├ ┤` box-drawing characters
- Align boxes vertically for main flow, branch horizontally for decisions
- Keep box widths consistent within each diagram
- Label each diagram with a section header
- Maximum ~15 boxes per diagram; split into multiple diagrams if larger
- Show decision points with `?` in the box
- Show data stores with `[(Name)]` notation
- Label arrows with data types or conditions where helpful
- Use `···` or `...` to indicate parts omitted for clarity

### Phase 5: Output

Write the complete output to `deep-explain.md` in the project root. Structure:

1. Title + System Overview (Layer 1)
2. Pipeline Overview (Layer 2)
3. Component Architecture (Layer 3)
4. Core Logic Deep-Dive (Layer 4)
5. Data Model & State (Layer 5)
6. Configuration & Infrastructure (Layer 6)
7. End-to-End Trace (Layer 7)
8. Cross-Cutting Analysis (tables)
9. Gaps & Questions

## Important Rules

- **Read before explaining** — never describe code you haven't read
- **Be specific** — reference actual file paths (`module/file.py:ClassName.method_name`) and line numbers
- **Follow the code** — trace actual execution paths, don't guess
- **Preserve complexity** — don't oversimplify; include conditional logic, error handling, edge cases
- **No invention** — only describe what exists in the codebase; flag gaps but don't fill them
- **Every layer gets a flowchart** — this is non-negotiable; if a layer has no meaningful flow, explain why
- **Progressive depth** — each layer must build on the previous; no forward references without noting them
- **Use tables** — for pattern summaries, dependency lists, component comparisons
- **No Mermaid** — all diagrams must be pure ASCII/Unicode art
- **Always export** — the final output MUST be written to `deep-explain.md` in the project root
- **Scale appropriately** — for large codebases, focus on the most important flows and note what was skipped
