# Brainstorm: Split Homebrew Packages Between Personal and Work Machines

**Date:** 2026-03-17
**Status:** Ready for planning

## What We're Building

A chezmoi template-based mechanism to conditionally install Homebrew packages depending on whether the machine is a personal or work laptop. A `personal` boolean flag in chezmoi's data config controls which packages get installed.

## Why This Approach

- **Chezmoi-native**: Uses built-in templating and data prompts — no extra tooling
- **Single file**: Keeps all packages in one install script (`.tmpl`), easy to scan and maintain
- **Simple flag**: One boolean prompted during `chezmoi init` — no tags, no separate files
- **Extensible**: Easy to add more conditional sections later (e.g., work-only packages)

## Key Decisions

1. **Two-tier model**: Shared packages (always installed) + personal-only packages (skipped on work machines). No work-only packages needed currently.
2. **Template with data flag**: Add `personal = true/false` to `.chezmoi.toml.tmpl`, prompted during init. The install script becomes a `.tmpl` with conditional blocks.
3. **Package categorization**:
   - **Shared formulae**: awscli, chezmoi, fastfetch, gh, git, git-lfs, helm, k6, kubectl, libpq, neovim, nvm, pnpm, python@3.12
   - **Shared casks**: amethyst, claude-code, firefox, ghostty, notion, raycast, slack, stats, visual-studio-code, zoom
   - **Personal-only casks**: adobe-creative-cloud, calibre, libreoffice, obsidian, spotify, steam, vlc

## Scope

### In scope
- Add `personal` boolean to `.chezmoi.toml.tmpl` with interactive prompt
- Convert `run_once_install-packages.sh` to `.tmpl` with conditional personal block
- Update existing chezmoi config on current machine

### Out of scope
- Work-only packages (not needed)
- Other run_once scripts (VS Code extensions, Claude plugins, macOS defaults)
- Separate Brewfile management
