#!/bin/bash
# Bootstrap a machine: symlink tracked config from this repo into ~/.claude.
#
# - Symlinks (not copies) so edits in either place stay in sync.
# - Backs up anything pre-existing to ~/.claude/.backups/<timestamp>/.
# - Preserves local-only files: nothing in ~/.claude is deleted unless it
#   collides with a tracked path.
# - settings.local.json is never touched (machine-specific).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$CLAUDE_DIR/.backups/$TS"

# Tracked top-level items (files and directories).
TRACKED=(
    "CLAUDE.md"
    "settings.json"
    "mcp.json"
    "commands"
    "agents"
    "rules"
    "statusline.sh"
)

mkdir -p "$CLAUDE_DIR"

link_item() {
    local name="$1"
    local src="$REPO_DIR/$name"
    local dst="$CLAUDE_DIR/$name"

    if [ ! -e "$src" ]; then
        return 0  # not tracked in this repo yet, skip silently
    fi

    # If the destination is already the correct symlink, no-op.
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "= $name (already linked)"
        return 0
    fi

    # Back up any existing file/dir/wrong-symlink before replacing.
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        echo "↺ backed up existing $name → $BACKUP_DIR/"
    fi

    ln -s "$src" "$dst"
    echo "✓ linked $name"
}

for item in "${TRACKED[@]}"; do
    link_item "$item"
done

if [ -d "$BACKUP_DIR" ]; then
    echo ""
    echo "Backups saved to: $BACKUP_DIR"
fi
echo "Done. Restart Claude Code for changes to take effect."
