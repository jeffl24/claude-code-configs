#!/bin/bash
# Granular sync between ~/.claude and this repo.
#
# Usage:
#   ./sync.sh status              show which tracked items differ
#   ./sync.sh push                copy ~/.claude → repo (for tracked items)
#   ./sync.sh pull                copy repo → ~/.claude (for tracked items)
#   ./sync.sh add <path>          start tracking a file/dir from ~/.claude
#                                 (copies into repo; use install.sh to relink)
#   ./sync.sh remove <path>       stop tracking (removes from repo, keeps local)
#
# All destructive operations first snapshot the target into
# <target>/.backups/<timestamp>/ so you can undo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TS="$(date +%Y%m%d-%H%M%S)"

TRACKED=(
    "CLAUDE.md"
    "settings.json"
    "mcp.json"
    "commands"
    "agents"
    "rules"
    "statusline.sh"
)

backup_into() {
    local base="$1" item="$2"
    local dir="$base/.backups/$TS"
    if [ -e "$base/$item" ] || [ -L "$base/$item" ]; then
        mkdir -p "$dir"
        cp -a "$base/$item" "$dir/"
    fi
}

copy_item() {
    local src="$1" dst="$2" name="$3"
    if [ ! -e "$src/$name" ]; then
        return 0
    fi
    backup_into "$dst" "$name"
    rm -rf "$dst/$name"
    cp -a "$src/$name" "$dst/$name"
    echo "✓ $name"
}

cmd_push() {
    echo "Pushing ~/.claude → repo (backups in $REPO_DIR/.backups/$TS)"
    for item in "${TRACKED[@]}"; do
        copy_item "$CLAUDE_DIR" "$REPO_DIR" "$item"
    done
}

cmd_pull() {
    echo "Pulling repo → ~/.claude (backups in $CLAUDE_DIR/.backups/$TS)"
    for item in "${TRACKED[@]}"; do
        copy_item "$REPO_DIR" "$CLAUDE_DIR" "$item"
    done
    echo "Restart Claude Code for changes to take effect."
}

cmd_status() {
    for item in "${TRACKED[@]}"; do
        local r="$REPO_DIR/$item" l="$CLAUDE_DIR/$item"
        if [ ! -e "$r" ] && [ ! -e "$l" ]; then
            printf "  %-20s —\n" "$item"
        elif [ ! -e "$r" ]; then
            printf "  %-20s local only\n" "$item"
        elif [ ! -e "$l" ]; then
            printf "  %-20s repo only\n" "$item"
        elif diff -rq "$r" "$l" >/dev/null 2>&1; then
            printf "  %-20s in sync\n" "$item"
        else
            printf "  %-20s DIFFERS\n" "$item"
        fi
    done
}

cmd_add() {
    local name="${1:-}"
    [ -n "$name" ] || { echo "usage: sync.sh add <path>"; exit 1; }
    [ -e "$CLAUDE_DIR/$name" ] || { echo "not found: $CLAUDE_DIR/$name"; exit 1; }
    backup_into "$REPO_DIR" "$name"
    rm -rf "$REPO_DIR/$name"
    cp -a "$CLAUDE_DIR/$name" "$REPO_DIR/$name"
    echo "✓ added $name to repo. Add it to the TRACKED list in install.sh/sync.sh to persist."
}

cmd_remove() {
    local name="${1:-}"
    [ -n "$name" ] || { echo "usage: sync.sh remove <path>"; exit 1; }
    [ -e "$REPO_DIR/$name" ] || { echo "not tracked: $name"; exit 1; }
    backup_into "$REPO_DIR" "$name"
    rm -rf "$REPO_DIR/$name"
    echo "✓ removed $name from repo (local copy in ~/.claude untouched)."
    echo "  If ~/.claude/$name is a symlink to the repo, re-run install.sh or replace it."
}

case "${1:-status}" in
    status) cmd_status ;;
    push)   cmd_push ;;
    pull)   cmd_pull ;;
    add)    shift; cmd_add "$@" ;;
    remove) shift; cmd_remove "$@" ;;
    *) echo "usage: sync.sh {status|push|pull|add <path>|remove <path>}"; exit 1 ;;
esac
