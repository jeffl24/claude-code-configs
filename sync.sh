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
#   ./sync.sh mcps-push           extract user-scope MCPs from ~/.claude.json → mcps.json
#   ./sync.sh mcps-install        register MCPs from mcps.json via `claude mcp add -s user`
#
# All destructive operations first snapshot the target into
# <target>/.backups/<timestamp>/ so you can undo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_JSON="$HOME/.claude.json"
MCPS_FILE="$REPO_DIR/mcps.json"
TS="$(date +%Y%m%d-%H%M%S)"

TRACKED=(
    "CLAUDE.md"
    "settings.json"
    "commands"
    "skills"
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
    mcps_status
}

# --- MCP sync (user-scope MCPs live in ~/.claude.json, not ~/.claude/) ----------

mcps_status() {
    if [ ! -f "$MCPS_FILE" ] && [ ! -f "$CLAUDE_JSON" ]; then
        printf "  %-20s —\n" "mcps.json"
        return 0
    fi
    if [ ! -f "$MCPS_FILE" ]; then
        printf "  %-20s repo only (run mcps-push)\n" "mcps.json"
        return 0
    fi
    if ! command -v jq >/dev/null 2>&1; then
        printf "  %-20s (jq missing)\n" "mcps.json"
        return 0
    fi
    local repo_mcps live_mcps
    repo_mcps=$(jq -S '.' "$MCPS_FILE" 2>/dev/null || echo "{}")
    live_mcps=$(jq -S '.mcpServers // {}' "$CLAUDE_JSON" 2>/dev/null || echo "{}")
    if [ "$repo_mcps" = "$live_mcps" ]; then
        printf "  %-20s in sync\n" "mcps.json"
    else
        printf "  %-20s DIFFERS\n" "mcps.json"
    fi
}

cmd_mcps_push() {
    command -v jq >/dev/null 2>&1 || { echo "jq is required for mcps-push"; exit 1; }
    [ -f "$CLAUDE_JSON" ] || { echo "no $CLAUDE_JSON found"; exit 1; }

    backup_into "$REPO_DIR" "mcps.json"
    jq '.mcpServers // {}' "$CLAUDE_JSON" > "$MCPS_FILE"

    # Warn loudly if any env or header value looks secret-like.
    local hits
    hits=$(jq -r '
        to_entries[]
        | .key as $name
        | (.value.env? // {}) + (.value.headers? // {})
        | to_entries[]
        | select(.value | tostring | test("sk-|api[_-]?key|token|secret|password|bearer"; "i"))
        | "  - \($name): \(.key)"
    ' "$MCPS_FILE" 2>/dev/null || true)
    if [ -n "$hits" ]; then
        echo "⚠️  WARNING: secret-like values detected in mcps.json:"
        echo "$hits"
        echo "  REMOVE these entries before committing — secrets must NOT be tracked."
        echo "  Document them in README.md as MCPs to register manually."
    fi
    echo "✓ wrote $MCPS_FILE"
}

cmd_mcps_install() {
    [ -f "$MCPS_FILE" ] || { echo "no $MCPS_FILE — nothing to install"; return 0; }
    command -v jq >/dev/null 2>&1 || { echo "jq is required for mcps-install"; exit 1; }
    command -v claude >/dev/null 2>&1 || { echo "claude CLI is required for mcps-install"; exit 1; }

    # Names already registered at user scope.
    local existing=""
    if [ -f "$CLAUDE_JSON" ]; then
        existing=$(jq -r '.mcpServers // {} | keys[]?' "$CLAUDE_JSON" 2>/dev/null || true)
    fi

    local names
    names=$(jq -r 'keys[]?' "$MCPS_FILE")

    while IFS= read -r name; do
        [ -z "$name" ] && continue
        if printf '%s\n' "$existing" | grep -qx "$name"; then
            echo "= $name (already at user scope)"
            continue
        fi

        local entry type
        entry=$(jq --arg n "$name" '.[$n]' "$MCPS_FILE")
        type=$(echo "$entry" | jq -r '.type // "stdio"')

        case "$type" in
            stdio)
                local cmd
                cmd=$(echo "$entry" | jq -r '.command')
                local -a args=()
                while IFS= read -r a; do
                    [ -n "$a" ] && args+=("$a")
                done < <(echo "$entry" | jq -r '.args[]?')
                if [ ${#args[@]} -gt 0 ]; then
                    claude mcp add "$name" "$cmd" "${args[@]}" -s user
                else
                    claude mcp add "$name" "$cmd" -s user
                fi
                ;;
            http)
                local url
                url=$(echo "$entry" | jq -r '.url')
                claude mcp add --transport http "$name" "$url" -s user
                ;;
            sse)
                local url
                url=$(echo "$entry" | jq -r '.url')
                claude mcp add --transport sse "$name" "$url" -s user
                ;;
            *)
                echo "✗ $name: unknown type '$type', skipping"
                continue
                ;;
        esac
        echo "✓ installed $name"
    done <<< "$names"
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
    status)        cmd_status ;;
    push)          cmd_push ;;
    pull)          cmd_pull ;;
    add)           shift; cmd_add "$@" ;;
    remove)        shift; cmd_remove "$@" ;;
    mcps-push)     cmd_mcps_push ;;
    mcps-install)  cmd_mcps_install ;;
    *) echo "usage: sync.sh {status|push|pull|add <path>|remove <path>|mcps-push|mcps-install}"; exit 1 ;;
esac
