# Git Commit Organizer

Analyze all staged and unstaged changes in the current git repository, then generate well-structured, copy-paste-ready git commands for committing changes logically.

**IMPORTANT: This skill only outputs commands. Do NOT execute git add or git commit — the user will copy-paste and run them manually. Do NOT append "Co-Authored-By" lines.**

## Instructions

1. **Analyze the current state:**
   - Run `git status` to see all modified, added, and deleted files
   - Run `git diff` (staged and unstaged) to understand the actual changes
   - Run `git log --oneline -5` to match the repo's existing commit style
   - Group related changes together based on their purpose

2. **Categorize changes by type:**
   - `feat`: New features or functionality
   - `fix`: Bug fixes
   - `refactor`: Code restructuring without behavior change
   - `chore`: Build scripts, configs, dependencies
   - `docs`: Documentation only changes
   - `style`: Formatting, whitespace (no code change)
   - `test`: Adding or updating tests
   - `perf`: Performance improvements

3. **Group files into logical commits:**
   - Files that serve the same purpose should be in the same commit
   - Keep commits atomic and focused on a single concern
   - Consider dependencies between changes
   - Exclude unrelated files (e.g., .DS_Store) unless explicitly requested

4. **Generate git commands:**
   - For each logical group, output ready-to-copy commands
   - Use imperative mood ("add" not "added")
   - Subject line: under 72 characters, concise
   - For simple changes, single-line `-m` is fine
   - For changes that need a body (multi-file, non-obvious "why"), use HEREDOC format:
   ```bash
   git add <file1> <file2>
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <short subject>

   <body explaining why, not what>
   EOF
   )"
   ```

5. **Output format:**
   - First, show a summary table of proposed commits
   - Then, provide the exact commands to copy-paste in order
   - Each commit in its own code block for easy individual copying

## Example Output

### Proposed Commits

| # | Type | Scope | Files | Description |
|---|------|-------|-------|-------------|
| 1 | fix | api | models.py, service.py | fix null handling in metric queries |
| 2 | docs | readme | README.md, Makefile | rewrite quickstart to match Docker workflow |

### Commands

**Commit 1:**
```bash
git add api/src/models.py api/src/service.py
git commit -m "fix(api): fix null handling in metric queries"
```

**Commit 2:**
```bash
git add README.md Makefile
git commit -m "$(cat <<'EOF'
docs(readme): rewrite quickstart to match Docker workflow

Previous instructions listed uv/venv as a prerequisite. Docker is the
only requirement — deps are installed inside containers automatically.
EOF
)"
```

---

Now analyze the current repository and generate the commit commands.
