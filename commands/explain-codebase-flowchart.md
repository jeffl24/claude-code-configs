# Explain Codebase with Flowchart

Analyze a codebase (or a specific module/directory) and produce a detailed technical explanation of its architecture, logic flow, and design patterns, accompanied by a markdown-based process flowchart. Export the result to a file called `explain-codebase.md` in the project root.

## Input

Target: $ARGUMENTS

If no argument is provided, analyze the current working directory as the project root.

## Instructions

### Phase 1: Discovery

1. **Identify the project root and scope:**
   - If a file or directory path is given, scope the analysis to that subtree
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

### Phase 2: Deep Analysis

4. **Read all key source files** (not tests, not generated code):
   - Start from entry points and follow imports/dependencies
   - For each module, understand: inputs, processing logic, outputs, side effects
   - Identify design patterns (DI, lazy evaluation, builder, observer, etc.)
   - Note any LLM/AI agent logic: prompts, chains, tool use, RAG pipelines

5. **Map the data flow end-to-end:**
   - What are the system inputs? (files, API calls, user input, databases)
   - What transformations happen? (parsing, LLM calls, DB queries, computations)
   - What are the outputs? (files, API responses, rendered content, side effects)
   - What external services are called? (LLM APIs, databases, file systems)

6. **Identify architectural layers:**
   - Core domain logic
   - Infrastructure/adapters (DB, APIs, file I/O)
   - User interface (CLI, web, SDK)
   - Configuration and dependency management

### Phase 3: Write the Explanation

Produce a detailed markdown explanation with these sections:

#### Required Sections

1. **System Overview** (2-3 sentences)
   - What problem does this system solve?
   - What is the high-level approach?

2. **Architecture & Data Flow**
   - Major stages/phases of the system
   - For each stage: purpose, inputs, processing logic, outputs
   - How stages connect to each other

3. **Component Deep-Dive**
   - For each significant module/class:
     - What it does and why it exists
     - Key methods/functions and their logic
     - Design patterns used
     - How it interacts with other components
   - Be specific: reference actual file paths, class names, function names

4. **Key Design Patterns & Decisions**
   - Table of patterns used, where, and why
   - Notable architectural decisions and their tradeoffs

5. **External Dependencies & Integrations**
   - Databases, APIs, LLM services, file formats
   - How they're configured and accessed

### Phase 4: Generate the Process Flowchart

Draw the flowchart using **pure markdown** with ASCII/Unicode box-drawing characters. Do NOT use Mermaid or any diagramming DSL.

#### Flowchart Requirements

- **Cover the full pipeline** from inputs to outputs
- **Show decision points** with diamond-style `< >` or `?` notation
- **Show data stores** clearly labeled (e.g., `[(Database)]`)
- **Group related steps** under labeled section headers
- **Use arrows** (`-->`, `|`, `v`) to show flow direction
- **Label branches** on decision points (e.g., Yes/No, match/no match)

#### Markdown Flowchart Style Guide

Use indented, structured ASCII art like:

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
      │ Decision │
      └────┬────┘
      Yes/ │ \No
          v
```

- Use `┌ ┐ └ ┘ ─ │ ┬ ┴ ├ ┤` box-drawing characters
- Align boxes vertically for main flow, branch horizontally for decisions
- Keep box widths consistent within each section
- Label each major pipeline stage with a section header above the diagram
- For complex systems, draw separate diagrams per stage/phase rather than one giant diagram
- Maximum ~15 boxes per diagram section; split into multiple sections if larger

### Phase 5: Output

Write the complete output to a file called `explain-codebase.md` in the project root using the Write tool. Structure the file as:

1. Title and system overview
2. The full markdown explanation (Phases 2-3)
3. The process flowchart(s) in fenced code blocks (Phase 4)
4. Dependencies and integration tables

## Important Rules

- **Read before explaining** — never describe code you haven't read
- **Be specific** — reference actual file paths (`module/file.py:ClassName.method_name`), not vague descriptions
- **Follow the code** — trace actual execution paths, don't guess
- **Preserve complexity** — don't oversimplify; include conditional logic, error handling, and edge cases
- **Separate concerns** — clearly distinguish what the code does from what it could/should do
- **No invention** — only describe what exists in the codebase; flag gaps but don't fill them
- **Scale appropriately** — for large codebases, focus on the most important flows and note what was skipped
- **Use tables** — for pattern summaries, dependency lists, and component comparisons
- **No Mermaid** — all diagrams must be pure markdown/ASCII art, never Mermaid syntax
- **Always export** — the final output MUST be written to `explain-codebase.md` in the project root
