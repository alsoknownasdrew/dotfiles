---
title: "feat: Split Homebrew packages between personal and work machines"
type: feat
status: completed
date: 2026-03-17
---

# Split Homebrew Packages Between Personal and Work Machines

Add a `personal` boolean flag to chezmoi config, prompted during `chezmoi init`, that controls whether personal-only Homebrew casks are installed.

## Acceptance Criteria

- [x] `chezmoi init` prompts "Is this a personal machine?" with default `false`
- [x] Work machines install only shared packages (14 formulae + 10 casks)
- [x] Personal machines install everything (14 formulae + 17 casks)
- [x] Existing machines prompt for `personal` on next `chezmoi apply` (expected)
- [x] `brew bundle` is idempotent — re-running is harmless

## Implementation

### 1. Update `.chezmoi.toml.tmpl`

Add `personal` boolean using `promptBool` (NOT `promptString` — strings are always truthy in Go templates):

```toml
{{- $personal := false -}}
{{- if (hasKey . "personal") -}}
{{-   $personal = .personal -}}
{{- else -}}
{{-   $personal = promptBool "Is this a personal machine" -}}
{{- end }}

[data]
    name = {{ $name | quote }}
    email = {{ $email | quote }}
    personal = {{ $personal }}
```

### 2. Rename and template the install script

```bash
git mv run_once_install-packages.sh run_once_install-packages.sh.tmpl
```

Wrap personal-only casks in a conditional block:

```bash
# Casks
cask "amethyst"
cask "claude-code"
cask "firefox"
cask "ghostty"
cask "notion"
cask "raycast"
cask "slack"
cask "stats"
cask "visual-studio-code"
cask "zoom"

{{ if .personal -}}
# Personal casks
cask "adobe-creative-cloud"
cask "calibre"
cask "libreoffice"
cask "obsidian"
cask "spotify"
cask "steam"
cask "vlc"
{{ end -}}
```

### 3. Verify before applying

```bash
chezmoi execute-template < .chezmoi.toml.tmpl
chezmoi cat run_once_install-packages.sh
chezmoi diff
```

## Key Files

| File | Action |
|---|---|
| `.chezmoi.toml.tmpl` | Add `personal` boolean with `hasKey`/`promptBool` |
| `run_once_install-packages.sh` | `git mv` to `.sh.tmpl`, add conditional block |

## Assumptions

- **Switching personal→work is not supported.** Leftover personal casks stay installed — `brew bundle` installs only, it does not remove.
- The rename will change the content hash, causing chezmoi to re-run the script on next apply. This is harmless since `brew bundle` is idempotent.

## References

- Brainstorm: `docs/brainstorms/2026-03-17-brew-personal-work-split-brainstorm.md`
