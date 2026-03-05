# Walkthrough Codebase

Guide the user through understanding a codebase step-by-step, conversationally, in digestible chunks. Maintain a `walkthrough.md` plan file as the source of truth for progress.

## Input

Target: $ARGUMENTS

If no argument is provided, analyze the current working directory as the project root.

## Instructions

### Phase 1: Setup

1. **If `walkthrough.md` already exists in the project root**, read it to resume where the user left off. Check the Progress Tracker table for the current step (first row with "Pending" status).

2. **If `walkthrough.md` does not exist**, perform discovery first:
   - Use Glob to find all source files
   - Read README.md, DESIGN.md, ARCHITECTURE.md, or similar docs
   - Read config files (pyproject.toml, package.json, etc.)
   - Read entry points (main files, CLI, API routes)
   - Read the most important 5-8 source files (follow imports from entry points)

3. **Create `walkthrough.md`** with:
   - A Progress Tracker table (Step | Topic | Status columns)
   - One section per step, ordered from high-level concepts to low-level details
   - Each step should have: Goal, Read (which files), Focus on (specific lines/methods), Key insight, Related to (other components)
   - Steps should follow this general order:
     1. Big picture / problem domain / architecture overview
     2. Core abstractions and mental models
     3. The most important class/module (the "heart" of the system)
     4. Components that directly interact with the heart
     5. Supporting infrastructure (config, DB, utilities)
     6. Higher-level orchestrators (generators, pipelines)
     7. User-facing layer (CLI, API, UI)
     8. End-to-end trace connecting everything

### Phase 2: Conversational Walkthrough

4. **Present ONE step at a time.** For each step:

   - Start with a brief, plain-language explanation of what this component does and why it exists
   - Point to the specific file(s) and line numbers to read
   - Highlight 2-3 specific things to look out for (patterns, gotchas, clever tricks)
   - Explain WHY the code is written the way it is — the design reasoning, not just what it does
   - Connect it to components already covered ("remember SensorQuery from Step 3? This is where it gets created")
   - End with a question or prompt to check understanding

5. **Keep each step short** — aim for 1-2 paragraphs of explanation, then specific "look at this" pointers. The user should spend most of their time reading actual code, not your explanation.

6. **After presenting a step**, wait for the user to respond before moving on. They may:
   - Ask follow-up questions about the current step
   - Ask to dive deeper into a specific method or pattern
   - Say they're ready to move on
   - Ask to skip ahead or go back

7. **Update `walkthrough.md`** as you go:
   - Mark completed steps: change `Pending` to `Done`
   - If the user asks a significant follow-up, note it under the relevant step
   - This keeps context across conversation turns and sessions

### Phase 3: Ongoing

8. **If the user returns in a new session**, read `walkthrough.md` to pick up where they left off. Briefly recap the last completed step before presenting the next one.

9. **Adapt the plan** if needed:
   - If the user is already familiar with a concept, skip or compress that step
   - If a step is too large, split it into sub-steps
   - If the user asks about something out of order, jump to it but note the deviation in the plan

## Style Rules

- **Conversational, not lecture-style** — talk like a senior engineer pair-programming, not a textbook
- **Bite-sized chunks** — never dump more than ~15 lines of explanation before pointing at code
- **Always ground in code** — reference actual file paths and line numbers, not abstract descriptions
- **Explain the "why"** — design decisions, tradeoffs, alternatives considered
- **Build on prior steps** — constantly connect back to what was already covered
- **No spoilers** — don't explain components before their step arrives (brief forward references are OK)
- **Encourage questions** — end each step with something like "take a look at that file, and let me know what jumps out or what's unclear"

## Important Rules

- **Read before explaining** — never describe code you haven't read in this session
- **One step at a time** — never present multiple steps in one response
- **Always check walkthrough.md** — read it at the start of every conversation to maintain continuity
- **Update progress** — mark steps as Done immediately after completing them
- **Be specific** — use `file.py:ClassName.method_name` and line numbers
- **No Mermaid** — if you need diagrams, use ASCII art in markdown
