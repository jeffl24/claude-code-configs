# Codebase Teach Walkthrough — File-by-File Guided Explanation for Learners

Produce a comprehensive, beginner-friendly walkthrough of a codebase that explains every source file, class, and function as if teaching someone who knows the language basics but is not yet comfortable with classes, design patterns, or architecture. The document should read like a patient mentor sitting next to you, walking through each file and saying "here's what this does and why." Export to `teach-walkthrough.md` in the project root.

## Input

Target: $ARGUMENTS

If no argument is provided, analyze the current working directory as the project root.

## Prompt This Skill Covers

> Explain to me step by step, walking through each source file and the individual class or function definitions inside, what each of them means. Explain as if I have some knowledge of the language but am not familiar with classes, and walk me through how to build this from scratch.

## Instructions

### Phase 1: Discovery

1. **Scope the analysis:**
   - If a file or directory path is given, scope to that subtree
   - If a description is given (e.g., "the auth module"), search for matching files
   - If no argument, use the current working directory

2. **Map the project structure:**
   - Use Glob to find all source files
   - Read config files (`pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, etc.)
   - Read `README.md`, `DESIGN.md`, or similar docs if they exist
   - Identify the language/framework stack

3. **Read EVERY source file** (not tests, not generated code, not vendored dependencies):
   - Start from entry points and follow imports
   - You MUST read each file before explaining it — no guessing
   - Note every class, function, and important constant/variable

4. **Determine the reader's language:**
   - Default assumption: knows basic syntax (variables, functions, loops, if/else, imports) but is NOT comfortable with classes, decorators, protocols, dunder methods, dataclasses, context managers, or design patterns
   - If $ARGUMENTS includes a skill level indicator (e.g., "beginner", "intermediate"), adjust accordingly

### Phase 1.5: Interactive Starting Point

After completing discovery (reading all source files and any specifically quoted scripts), **STOP and ask the user** before proceeding to the walkthrough. Present two options:

1. **"Learn how to build this from scratch"** — You'll walk through the project as if reconstructing it step by step, explaining each file, class, and function along the way (the full walkthrough flow starting from Phase 2 below).
2. **"I have specific questions"** — The user can ask targeted questions about specific files, classes, patterns, or architectural decisions. Answer those questions interactively, using the same teaching style (plain language, analogies, motivate-don't-describe). Continue the Q&A until the user is satisfied or chooses to switch to the full walkthrough.

Use AskUserQuestion for this. Example prompt:

> I've finished scanning the codebase. Here's a quick summary of what I found:
> - [brief bullet list: number of source files, key modules/packages, main entry point, language/framework stack]
>
> How would you like to proceed?
> 1. **Walk me through building this from scratch** — I'll explain the full codebase file-by-file, as if we were reconstructing it together
> 2. **I have specific questions** — Ask me anything about specific files, classes, patterns, or how things connect
>
> Pick one, or just fire away with a question!

If the user picks option 1, continue to Phase 2. If the user picks option 2 or asks a question, answer it and keep the conversation going — they can always switch to the full walkthrough later.

### Phase 2: Concepts Primer

Before diving into files, write a short section that teaches ONLY the language concepts actually used in this codebase. Do not teach concepts that don't appear in the code.

For each concept used, provide:
- A plain-language explanation (1-3 sentences, no jargon)
- A minimal standalone example (5-10 lines max) that is NOT from the codebase
- Why it's useful (one sentence connecting it to what the reader is about to see)

Common concepts to check for and explain if present:
- Classes and `__init__` / `self`
- Dataclasses (`@dataclass`)
- Dunder/magic methods (`__str__`, `__float__`, `__add__`, `__enter__`/`__exit__`)
- Protocols / Abstract classes / Interfaces
- Decorators (`@property`, `@classmethod`, `@staticmethod`, custom decorators)
- Context managers (`with` statement)
- Type hints and `Optional`
- Generators and `yield`
- `*args` and `**kwargs`
- Dependency injection (the concept, not a framework)
- Any framework-specific patterns (e.g., Click decorators for CLI, FastAPI routes, Django models)

Only include concepts that actually appear in the codebase. Skip the rest.

### Phase 3: File-by-File Walkthrough

This is the core of the document. Walk through EVERY source file, organized by architectural layer (bottom-up: foundational files first, then files that build on them).

#### Ordering Rules

1. **Group files by module/directory** — process one module completely before moving to the next
2. **Within each module, order by dependency** — if file A imports from file B, explain B first
3. **Start with the foundational layer** (data models, config, utilities) and work up to the orchestration layer (CLI, API routes, main entry points)
4. **End with the entry point / CLI** so the reader sees how everything connects

#### For Each File, Write:

**File header:**
```
### `path/to/file.py` — [One-sentence purpose]
```

**Purpose paragraph:** 2-3 sentences explaining what this file is for and why it exists. Use an analogy if it helps. Connect it to files already explained: "Remember the Config class from earlier? This file uses it to..."

**For each class in the file:**

1. **What it is** — one sentence explaining the class's role. Use a real-world analogy if the concept is abstract.
2. **`__init__` / constructor walkthrough** — explain every parameter and what gets stored on `self`. Explain WHY each piece of state is needed.
3. **Method-by-method breakdown** — for each method:
   - What it does (1-2 sentences)
   - What it takes as input and what it returns
   - Key logic explained in plain language (not just restating the code)
   - If it uses a language feature from the Concepts Primer, reference it: "This is the `__str__` magic method we talked about earlier"
4. **How it connects** — which other classes/functions use this class, and how

**For each standalone function in the file:**
1. What it does and why it's a function (not a method on a class)
2. Parameters and return value explained
3. Key logic in plain language

**For each important constant/variable:**
1. What it holds and where it's used

**"If you were building this" aside (per file):**
A short paragraph (2-4 sentences) explaining the motivation: "If you were building this from scratch, you'd start by... Then you'd realize... So you'd create this class to..."

### Phase 4: How to Build This From Scratch

After the file-by-file walkthrough, write a dedicated section that tells the story of constructing this system incrementally. This is NOT a repeat of the walkthrough — it's a narrative that answers: "If I had to build this from zero, what order would I do things and why?"

Structure it as numbered steps:

```
**Step 1 — [Get the simplest version working]**
What you'd build first, what it would look like, what problem it solves.
Which files from the real codebase correspond to this step.

**Step 2 — [What limitation you'd hit next]**
What breaks or becomes painful, motivating the next abstraction.
Which files from the real codebase correspond to this step.

...continue until the full system is reconstructed...
```

Rules for this section:
- Each step should introduce 1-3 files worth of concepts
- Each step should be motivated by a concrete problem ("you'd get tired of...", "this breaks when...", "you'd realize you need...")
- Reference the actual files that implement each step
- End with a step that wires everything together (the CLI/entry point)

### Phase 5: Summary Tables

End with reference tables:

1. **File Index** — every file with a one-line description

| File | Purpose |
|------|---------|
| `path/to/file.py` | ... |

2. **Class & Function Index** — every class and public function with file location

| Name | Type | File | One-line description |
|------|------|------|---------------------|
| `Config` | class | `core/config.py` | ... |
| `get_connection` | function | `core/database.py` | ... |

3. **Design Patterns Used** — patterns with plain-language explanations

| Pattern | Where | Plain-language explanation |
|---------|-------|--------------------------|
| Lazy Evaluation | `SensorQuery` | The query doesn't run until you actually need the answer |

### Phase 6: Output

Write the complete output to `teach-walkthrough.md` in the project root. Structure:

1. Title and one-paragraph project summary
2. Concepts Primer (Phase 2)
3. File-by-File Walkthrough (Phase 3)
4. How to Build This From Scratch (Phase 4)
5. Summary Tables (Phase 5)

## Important Rules

- **Read before explaining** — never describe code you haven't read. Read every source file.
- **Every file, every class, every function** — do not skip files or summarize classes as "has several helper methods." Be exhaustive.
- **Plain language first** — explain what the code does in everyday language before referencing syntax or patterns. Prefer "this saves the name so other methods can use it later" over "this assigns the parameter to an instance attribute."
- **Teach concepts in context** — when a language feature appears for the first time in the walkthrough, briefly remind the reader: "This is the dataclass decorator we covered in the Concepts Primer — it auto-generates the `__init__` for us."
- **Use analogies** — especially for abstract concepts (classes, protocols, lazy evaluation, dependency injection). Good analogies are concrete and everyday.
- **Connect everything** — every file explanation should reference files explained before it. The reader should always know where they are in the bigger picture.
- **No jargon without explanation** — if you must use a technical term, define it inline on first use.
- **Motivate, don't just describe** — for each class/pattern, explain WHY it exists, not just WHAT it does. "This exists because without it, you'd have to..."
- **Be specific** — reference actual file paths, class names, function names, and line numbers
- **No Mermaid** — if you include any diagrams, use pure ASCII/Unicode box-drawing characters
- **Always export** — the final output MUST be written to `teach-walkthrough.md` in the project root
- **Scale for large codebases** — if the codebase has 50+ source files, group minor utility files into summary tables and give full treatment to the core 15-25 files. Note what was summarized vs fully explained.
