#!/bin/bash

# Restore Claude Code config files to ~/.claude from this repo

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="$HOME/.claude"

# Create ~/.claude if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy CLAUDE.md
if [ -f "$SOURCE_DIR/CLAUDE.md" ]; then
    cp -f "$SOURCE_DIR/CLAUDE.md" "$DEST_DIR/"
    echo "✓ Restored CLAUDE.md"
else
    echo "✗ CLAUDE.md not found in repo"
fi

# Copy settings.json
if [ -f "$SOURCE_DIR/settings.json" ]; then
    cp -f "$SOURCE_DIR/settings.json" "$DEST_DIR/"
    echo "✓ Restored settings.json"
else
    echo "✗ settings.json not found in repo"
fi

# Copy mcp.json
if [ -f "$SOURCE_DIR/mcp.json" ]; then
    cp -f "$SOURCE_DIR/mcp.json" "$DEST_DIR/"
    echo "✓ Restored mcp.json"
else
    echo "✗ mcp.json not found in repo"
fi

# Copy commands/ directory
if [ -d "$SOURCE_DIR/commands" ]; then
    rm -rf "$DEST_DIR/commands"
    cp -r "$SOURCE_DIR/commands" "$DEST_DIR/"
    echo "✓ Restored commands/"
else
    echo "✗ commands/ not found in repo"
fi

# Copy skills/ directory
if [ -d "$SOURCE_DIR/skills" ]; then
    rm -rf "$DEST_DIR/skills"
    cp -r "$SOURCE_DIR/skills" "$DEST_DIR/"
    echo "✓ Restored skills/"
else
    echo "✗ skills/ not found in repo"
fi

echo ""
echo "Done! Restart Claude Code for changes to take effect."
