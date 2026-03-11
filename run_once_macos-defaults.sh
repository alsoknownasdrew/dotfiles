#!/bin/bash

set -e

echo "Configuring macOS defaults..."

# Close System Preferences to prevent overriding changes
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

###############################################################################
# General UI                                                                  #
###############################################################################

# Set dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Show all file extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

###############################################################################
# Dock                                                                        #
###############################################################################

# Set dock icon size
defaults write com.apple.dock tilesize -int 47

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

###############################################################################
# Finder                                                                      #
###############################################################################

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

###############################################################################
# Keyboard                                                                    #
###############################################################################

# Set fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Screenshots                                                                 #
###############################################################################

# Save screenshots to ~/Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

###############################################################################
# Apply changes                                                               #
###############################################################################

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "macOS defaults configured. Some changes may require a logout/restart."
