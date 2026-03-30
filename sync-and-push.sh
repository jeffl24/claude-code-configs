#!/bin/bash

# Sync claude config files, commit changes, and push to remote
# Intended to be run via cron

REPO_DIR="$HOME/github-projects/claude-code-configs"

cd "$REPO_DIR" || exit 1

# Run the sync script
bash "$REPO_DIR/sync-claude-config.sh"

# Check if there are any changes
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "No changes to commit."
    exit 0
fi

# Stage all changes
git add -A

# Commit with timestamp
git commit -m "auto-sync claude config $(date '+%Y-%m-%d %H:%M')"

# Push to remote
git push
