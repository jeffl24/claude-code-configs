# Add Makefile Target

Add a new target to the project Makefile following established conventions.

## Input

Target description: $ARGUMENTS

## Instructions

### Phase 1: Understand

1. Parse the desired target name and behavior from $ARGUMENTS
2. Read the current Makefile to understand:
   - Existing targets and their organization
   - Variable conventions (COMPOSE, SERVICE, etc.)
   - Help text formatting

### Phase 2: Design

Ask the user:
- Target name (lowercase, hyphenated for multi-word: `test-api`)
- What it should do
- Dependencies (other targets it depends on, e.g., `setup`)
- Does it accept arguments? (like `logs` accepts service names)

### Phase 3: Implement

Add the target following these conventions:

1. **Add to `.PHONY` declaration** at the top of the Makefile

2. **Add help text** in the `help` target:
   ```makefile
   @echo "  make {target}       - {description}"
   ```

3. **Add the target** using project conventions:
   ```makefile
   {target}: {dependencies}
   	@echo "{Description}..."
   	@{command}
   	@echo "✅ {Completion message}"
   ```

   Conventions to follow:
   - `@` prefix on every command (suppress echo)
   - `@echo` for user-facing messages
   - Unicode arrows `→` for URLs/paths in output
   - Use `$(COMPOSE)` variable for docker compose commands
   - Use `cd local &&` prefix for compose commands
   - Use `--env-file ../api/.env` for compose commands
   - Shell conditionals with backslash continuations

### Phase 4: Verify

1. Show the user the exact diff
2. Run `make help` to verify help text renders
3. Run `make {target}` to test (with user permission)

## Important Rules

- Maintain alphabetical or logical grouping of targets
- Always add to .PHONY
- Always add help text
- Use `@` prefix on ALL commands
- Use existing variables (COMPOSE, SERVICE) rather than hardcoding
