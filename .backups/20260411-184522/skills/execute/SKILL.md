# Execute Plan

Execute tasks from a plan file following a structured workflow.

## Usage

```
/execute <plan_file_path> <task_range>
```

**Examples:**
- `/execute /Users/jeff.lim/.claude/plans/my-plan.md Phase 0 (tasks 0.1-0.3)`
- `/execute ./PLAN.md Phase 2, Task 2.1`
- `/execute /Users/jeff.lim/.claude/plans/pdf-to-html-report-plan.md continue from where it left off`

## Arguments

- `$ARGUMENTS` — The plan file path and which tasks/phase to execute. If "continue" or "resume" is specified, find the first unchecked task and start from there.

## Instructions

1. **Read the plan file** specified in the first argument. Parse the task list and identify which tasks to execute based on the second argument.

2. **If resuming**, scan for the first `⬜` (unchecked) task and start from there. Report which tasks are already `✅` completed.

3. **For each task, follow this workflow:**

   a. **Read ONLY the current task** — do not read ahead or work on future tasks
   b. **Mark as in-progress** — update the plan file checkbox if applicable
   c. **Implement the task** — write code, create files, run tests as needed
   d. **Mark as complete** — change `⬜` to `✅` in the plan file
   e. **Commit** — create a git commit with message: `"Phase X Task Y.Z: <description>"`
   f. **Move to the next task** in the assigned range

4. **Rules:**
   - Implement tasks **sequentially, in order** — do NOT skip ahead
   - Do NOT work on tasks outside the assigned range
   - If a task is **blocked** (dependency missing, unclear requirement, error), **stop and report** — do not attempt the next task
   - If the plan file references external files (schemas, configs, CSVs), read them as needed for context

5. **After completing all assigned tasks**, report:
   - Summary of what was implemented
   - Any issues encountered
   - What the next unfinished tasks are
