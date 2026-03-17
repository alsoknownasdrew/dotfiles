#!/bin/bash
# Install Claude Code plugins and marketplaces

if ! command -v claude &>/dev/null; then
  echo "Claude Code not installed, skipping plugin setup"
  exit 0
fi

# Add the Every marketplace (for compound-engineering plugin)
claude plugins marketplace add https://github.com/EveryInc/every-marketplace.git 2>/dev/null || true

# Install plugins
plugins=(
  "github@claude-plugins-official"
  "compound-engineering@every-marketplace"
  "frontend-design@claude-plugins-official"
  "superpowers@claude-plugins-official"
  "code-review@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
  "claude-code-setup@claude-plugins-official"
  "skill-creator@claude-plugins-official"
)

for plugin in "${plugins[@]}"; do
  echo "Installing $plugin..."
  claude plugins install "$plugin" 2>/dev/null || true
done

echo "Claude Code plugins installed."
