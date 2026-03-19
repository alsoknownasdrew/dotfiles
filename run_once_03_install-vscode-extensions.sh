#!/bin/bash

set -e

echo "Installing VS Code extensions..."

extensions=(
    anthropic.claude-code
    astro-build.astro-vscode
    dracula-theme.theme-dracula
    github.copilot-chat
    github.vscode-github-actions
    ms-azuretools.vscode-containers
    ms-azuretools.vscode-docker
    ms-python.debugpy
    ms-python.python
    ms-python.vscode-pylance
    ms-python.vscode-python-envs
    zoellner.openapi-preview
)

if command -v code &>/dev/null; then
    for ext in "${extensions[@]}"; do
        code --install-extension "$ext" --force 2>/dev/null || echo "Failed to install $ext"
    done
    echo "VS Code extensions installed."
else
    echo "VS Code CLI not found, skipping extensions."
fi
