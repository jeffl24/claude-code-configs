# claude-code-configs

Personal Claude Code config tracked in git so it can be replicated across machines.

## Layout

| Path | Tracked? | Notes |
|---|---|---|
| `CLAUDE.md` | yes | Global user instructions |
| `settings.json` | yes | Permissions, status line, etc. |
| `commands/` | yes | User-defined slash commands |
| `skills/` | yes | User-defined skills |
| `agents/` | yes | User-defined subagents (if any) |
| `rules/` | yes | (if any) |
| `statusline.sh` | yes | (if any) |
| `mcps.json` | yes | **Declarative** list of user-scope MCPs (see below) |
| `install.sh` | — | Bootstrap script — symlinks tracked items into `~/.claude/` and registers MCPs |
| `sync.sh` | — | Push/pull/status helper |

`settings.local.json` is intentionally **never** touched — it's machine-specific.

## Bootstrapping a new machine

```bash
git clone <this repo> ~/github-projects/claude-code-configs
cd ~/github-projects/claude-code-configs
./install.sh
```

`install.sh`:
1. Symlinks each tracked item from the repo into `~/.claude/` (backing up anything already there into `~/.claude/.backups/<timestamp>/`).
2. If `mcps.json` exists and the `claude` CLI is available, registers each listed MCP at user scope via `claude mcp add ... -s user`. Idempotent — already-registered MCPs are skipped.
3. After it finishes, also follow the **Manual MCPs** section below for any MCPs that need secrets.

## Day-to-day sync

```bash
./sync.sh status         # show which tracked items differ between repo and ~/.claude
./sync.sh push           # copy ~/.claude → repo (for tracked items)
./sync.sh pull           # copy repo  → ~/.claude (for tracked items)
./sync.sh add <path>     # start tracking a new file/dir from ~/.claude
./sync.sh remove <path>  # stop tracking
```

All destructive operations snapshot the target into `<target>/.backups/<timestamp>/` first.

## MCP sync

User-scope MCPs **do not live in `~/.claude/`** — they live in `~/.claude.json` (a giant file that also contains chat history, sessions, and credentials, and must never be committed). The repo therefore tracks a separate, minimal `mcps.json` containing only the `mcpServers` block.

```bash
./sync.sh mcps-push      # extract user-scope MCPs from ~/.claude.json → mcps.json
./sync.sh mcps-install   # register MCPs from mcps.json via `claude mcp add -s user`
```

`./sync.sh status` reports `mcps.json in sync` / `DIFFERS` against the live `~/.claude.json` so drift is visible.

### Adding a new MCP

```bash
claude mcp add <name> <command> [args...] -s user      # or --transport http <url>
./sync.sh mcps-push                                    # capture into mcps.json
git add mcps.json && git commit -m "add <name> mcp"
```

### Secrets

`mcps.json` is checked into git. **Do not commit MCPs that need API keys, tokens, or other secrets.** `mcps-push` will warn if it detects secret-like values in `env` or `headers`, but the safer rule is: if an MCP needs auth, leave it out of `mcps.json` and document it in the **Manual MCPs** section below.

## Manual MCPs

These MCPs require secrets and must be registered manually on each machine. They are intentionally **not** in `mcps.json`.

_(none currently — add entries here when you install a secret-bearing MCP)_

Template:

```
### <mcp-name>
- What it does: …
- Required secret(s): `FOO_API_KEY` (where to get it: …)
- Install command:
  ```
  claude mcp add <name> <command> args... \
    --env FOO_API_KEY=<value> \
    -s user
  ```
```
