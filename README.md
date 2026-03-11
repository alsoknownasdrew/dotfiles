# dotfiles

My macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## What's included

- **Shell**: Zsh with Oh My Zsh, zsh-autosuggestions, robbyrussell theme
- **Git**: Global config with git-lfs, global gitignore
- **Homebrew**: Formulae + casks for dev tools, productivity apps, creative apps
- **macOS**: Dark mode, dock auto-hide, Finder path bar, fast key repeat
- **VS Code**: Dracula theme, Python tooling, Docker, Claude Code, extensions

## Setup on a new Mac

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alsoknownasdrew
```

Or if chezmoi is already installed:

```bash
chezmoi init --apply alsoknownasdrew
```

## Updating

```bash
chezmoi update
```

## Editing

```bash
chezmoi edit ~/.zshrc
chezmoi apply
```

## File overview

| File | Purpose |
|---|---|
| `dot_zshrc` | Zsh configuration |
| `dot_gitconfig.tmpl` | Git config (templated for name/email) |
| `dot_gitignore_global` | Global gitignore patterns |
| `.chezmoiexternal.toml` | Oh My Zsh + zsh-autosuggestions auto-install |
| `.chezmoi.toml.tmpl` | Chezmoi data prompts (name, email) |
| `run_once_01-install-packages.sh` | Homebrew formulae + casks |
| `run_once_02-macos-defaults.sh` | macOS system preferences |
| `run_once_03-install-vscode-extensions.sh` | VS Code extensions |
| `private_Library/.../settings.json` | VS Code settings |
