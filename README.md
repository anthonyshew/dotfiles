# Dotfiles managed with GNU Stow

This repo is organized into "packages" (directories) that mirror `$HOME`. Symlinks are created via GNU Stow so your home directory stays clean.

## Layout
- `zsh/` → `~/.zshrc`
- `bash/` → `~/.bash_profile`, `~/.bashrc`
- `starship/` → `~/.config/starship.toml`
- `git/` → `~/.gitconfig`
- `ghostty/` → `~/.config/ghostty/config`
- `nvim/` → `~/.config/nvim/` (full LazyVim setup)
- `zed/` → `~/.config/zed/settings.json`, `keymap.json`
- `tmux/` → `~/.config/tmux/tmux.conf`
- `lazygit/` → `~/.config/lazygit/config.yml`
- `bat/` → `~/.config/bat/config`
- `bootstrap.sh` → helper to stow all packages

Add more packages by creating new directories and mirroring the target paths inside them.

## Usage
1) Install GNU Stow (e.g., `brew install stow` on macOS).
2) Clone this repo to `~/dotfiles` (or any path).
3) From repo root, run `./bootstrap.sh` (defaults target to `$HOME`).

Common commands:
- `stow zsh bash starship git ghostty nvim zed tmux lazygit bat` — link all packages.
- `stow -D nvim` — remove links for a package.
- `stow --target /some/dir pkg` — link into a different target.

## Tips
- Put machine- or work-specific configs in separate packages and choose per host.
- Keep secrets outside the repo or inject via a secret manager (e.g., `pass`, `gopass`, `sops`).
- For local overrides, use patterns like `~/.zshrc.local` so they remain untracked.
