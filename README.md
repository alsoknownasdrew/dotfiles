# Dotfiles

My macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/)

## Set up

Install and init chezmoi

```sh
sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply alsoknownasdrew
```

Check the changes before applying them

```sh
chezmoi diff
```

Apply the changes

```sh
chezmoi apply
```
