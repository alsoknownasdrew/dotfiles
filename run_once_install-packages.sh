#!/bin/bash

set -e

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

echo "Installing Homebrew packages..."
brew bundle --no-lock --file=/dev/stdin <<EOF
# Formulae
brew "chezmoi"
brew "fastfetch"
brew "gh"
brew "git"
brew "git-lfs"
brew "helm"
brew "k6"
brew "kubectl"
brew "libpq"
brew "neovim"
brew "nvm"
brew "pnpm"
brew "python@3.12"

# Casks
cask "adobe-creative-cloud"
cask "amethyst"
cask "calibre"
cask "claude-code"
cask "firefox"
cask "ghostty"
cask "libreoffice"
cask "notion"
cask "obsidian"
cask "raycast"
cask "slack"
cask "spotify"
cask "stats"
cask "steam"
cask "visual-studio-code"
cask "vlc"
cask "zoom"
EOF

# Setup NVM directory
mkdir -p "$HOME/.nvm"

# Setup git-lfs
git lfs install

echo "Homebrew packages installed."
