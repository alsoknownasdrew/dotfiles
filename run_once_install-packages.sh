#!/bin/bash

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Installing Homebrew packages..."
brew bundle --no-lock --file=/dev/stdin <<EOF
tap "adoptopenjdk/openjdk"
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"
brew "chezmoi"
brew "docker"
brew "git"
brew "git-lfs"
brew "gradle"
brew "helm"
brew "kind"
brew "kotlin"
brew "neofetch"
brew "node"
cask "adobe-creative-cloud"
cask "adoptopenjdk16"
cask "alfred"
cask "amethyst"
cask "bitwarden"
cask "discord"
cask "figma"
cask "firefox"
cask "google-chrome"
cask "intellij-idea"
cask "iterm2"
cask "lens"
cask "libreoffice"
cask "mongodb-compass"
cask "notion"
cask "obsidian"
cask "postman"
cask "slack"
cask "spotify"
cask "stats"
cask "telegram"
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
