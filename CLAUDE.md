- always format your response in markdown file format
- Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

## Python Environment

- **Always** activate and use the local `.venv` virtual environment in the current working directory before running any Python commands.
- Run `source .venv/bin/activate` (or `.venv/bin/python` / `.venv/bin/pip` directly) instead of using the system `python3` or `pip3`.
- **Never** use macOS's default system Python (`/usr/bin/python3`). Always prefer `.venv/bin/python`.
- If a `.venv` directory does not exist in the working directory, ask the user before creating one.
- **Prefer `uv`** for all Python environment and package management (e.g., `uv sync`, `uv run`, `uv pip install`).
- Always check for `pyproject.toml` and/or `uv.lock` in the working directory for the correct project configuration before running anything.
- If neither `pyproject.toml` nor `uv.lock` exists, **stop and ask the user** what to do before proceeding.

## Plan Execution Workflow

When working from a plan file (e.g., `PLAN.md`):
1. Read ONLY the tasks you are assigned — do not read the entire file
2. Implement tasks sequentially, in the order specified
3. After completing each task, mark it in the plan: change `⬜` to `✅`
4. Commit after each task with message: "Phase X Task Y.Z: <description>"
5. Do NOT skip ahead or work on tasks outside your assigned range
6. If a task is blocked, stop and report — do not attempt the next task