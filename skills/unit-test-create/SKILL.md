# Unit Test Creator

Analyze source code and interactively create unit tests with the user.

## Input

Target file or module to test (optional): $ARGUMENTS

## Instructions

### Phase 1: Discovery

1. **Determine scope:**
   - If the user provided a file/module via `$ARGUMENTS`, focus on that
   - If no argument, check `git diff --name-only` for recently changed files and offer those as candidates
   - If no recent changes either, ask the user what they want to test

2. **Detect project conventions:**
   - Identify language and test framework by scanning for config files:
     - Python: `pytest.ini`, `pyproject.toml` (look for `[tool.pytest]`), `conftest.py`
     - JavaScript/TypeScript: `vitest.config.*`, `jest.config.*`, `package.json` (look for test scripts)
     - Other: scan for test runner configs
   - Find existing test files to learn naming conventions (`test_*.py`, `*.test.tsx`, etc.)
   - Find existing test directories to know where tests should go
   - Read 1-2 existing test files to understand patterns: imports, fixtures, mocking style, assertion style

3. **Analyze the target code:**
   - Read the source file(s) to test
   - Identify all public functions, methods, and classes
   - Map dependencies and imports that will need mocking
   - Note edge cases: error handling paths, boundary conditions, optional parameters, async code

### Phase 2: Scenario Proposal (Interactive)

4. **Present test scenarios to the user:**

   Organize by function/method and show a structured proposal:

   ```
   ## Test Scenarios for <file>

   ### <function_name>
   1. [Happy path] <description>
   2. [Edge case] <description>
   3. [Error case] <description>

   ### <class.method_name>
   4. [Happy path] <description>
   5. [Edge case] <description>
   ...
   ```

   Then ask the user:
   - Which scenarios to include (all, or pick by number)
   - Any additional scenarios they want to add
   - Whether to mock external dependencies or test with real calls

5. **Wait for user input before proceeding.** Do not generate test code until the user confirms which scenarios to implement.

### Phase 3: Test Generation

6. **Write the test file:**
   - Match the project's existing test conventions exactly (naming, location, imports, style)
   - Group tests logically by function/class being tested
   - Use descriptive test names that read as behavior specifications
   - Include docstrings or comments only where the test intent is non-obvious
   - Mock external dependencies (DB, APIs, file I/O) — never make real external calls
   - Use fixtures for shared setup when 3+ tests need the same arrangement
   - Keep each test focused on one behavior (single assertion per test when practical)

7. **Show the user the generated tests** and ask if they want to:
   - Add or remove any test cases
   - Adjust mocking strategy
   - Modify test structure

8. **Run the tests** if the user approves:
   - Execute the test file using the project's test runner
   - Report results: passes, failures, errors
   - If tests fail due to implementation issues in the test itself, fix and re-run
   - If tests fail because they found actual bugs, report the findings to the user

## Important Rules

- **Never skip Phase 2** — always get user confirmation on scenarios before writing code
- **Match existing conventions** — if the project uses `pytest` with fixtures, don't use `unittest.TestCase`; if it uses Vitest, don't use Jest APIs
- **Prefer unit over integration** — mock boundaries, test logic in isolation
- **No over-mocking** — don't mock the thing you're testing, only its dependencies
- **Test behavior, not implementation** — assert on outputs and side effects, not internal state
