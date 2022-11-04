#!/bin/bash

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing Homebrew packages..."
brew bundle --no-lock --file=/dev/stdin <<EOF
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"
brew "chezmoi"
brew "docker"
brew "cmake"
brew "git"
brew "git-lfs"
brew "helm"
brew "kind"
brew "kubectl"
brew "neofetch"
brew "node"
cask "alfred"
cask "amethyst"
cask "discord"
cask "firefox"
cask "google-chrome"
cask "google-drive"
cask "iterm2"
cask "keepassxc"
cask "lens"
cask "libreoffice"
cask "mongodb-compass"
cask "obsidian"
cask "postman"
cask "slack"
cask "spotify"
cask "stats"
cask "telegram"
cask "toggl-track"
cask "visual-studio-code"
cask "vlc"
cask "zoom"
EOF

printf "TODO:\n\
install: \n\
Logi Options (https://www.logitech.com/en-us/product/options) \n\
Logi Capture (https://www.logitech.com/en-us/product/capture) \n\
\n\
Log in everywhere!\n\
"
