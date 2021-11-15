# Dotfiles

Managed by [chezmoi](https://www.chezmoi.io/)

## Set up

Install and init chezmoi

```sh
sh -c "$(curl -fsLS git.io/chezmoi)"
chezmoi init https://github.com/alsoknownasdrew/dotfiles.git
```

Check the changes before applying them

```sh
chezmoi diff
```

Apply the changes

```sh
chezmoi apply
```
