#!/bin/bash

# Sync CLAUDE.md, mcp.json, and skills/ from ~/.claude to this directory

SOURCE_DIR="$HOME/.claude"
DEST_DIR="$HOME/github-projects/claude-code-configs"

# Copy CLAUDE.md
if [ -f "$SOURCE_DIR/CLAUDE.md" ]; then
    cp -f "$SOURCE_DIR/CLAUDE.md" "$DEST_DIR/"
    echo "✓ Copied CLAUDE.md"
else
    echo "✗ CLAUDE.md not found in $SOURCE_DIR"
fi

# Copy settings.json
if [ -f "$SOURCE_DIR/settings.json" ]; then
    cp -f "$SOURCE_DIR/settings.json" "$DEST_DIR/"
    echo "✓ Copied settings.json"
else
    echo "✗ settings.json not found in $SOURCE_DIR"
fi

# Copy mcp.json
if [ -f "$SOURCE_DIR/mcp.json" ]; then
    cp -f "$SOURCE_DIR/mcp.json" "$DEST_DIR/"
    echo "✓ Copied mcp.json"
else
    echo "✗ mcp.json not found in $SOURCE_DIR"
fi

# Copy skills/ directory
if [ -d "$SOURCE_DIR/skills" ]; then
    rm -rf "$DEST_DIR/skills"
    cp -r "$SOURCE_DIR/skills" "$DEST_DIR/"
    echo "✓ Copied skills/"
else
    echo "✗ skills/ not found in $SOURCE_DIR"
fi

echo "Done!"
