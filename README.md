# Dotfiles managed with GNU Stow

This repo is organized into "packages" (directories) that mirror `$HOME`. Symlinks are created via GNU Stow so your home directory stays clean.

The shared config is intended to work on macOS and Linux. Platform-specific pieces live in `macos/` and `linux/`.

> [!NOTE]
> I haven't had the chance to use every Linux distro from scratch. Package names may vary outside Homebrew, apt, dnf, and pacman.
> But, at the least, these are my configurations.

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
- `macos/` → macOS-only shell and Git config
- `linux/` → Linux-only shell and Git config
- `bootstrap.sh` → helper to stow all packages

Add more packages by creating new directories and mirroring the target paths inside them.

## Usage
1. Clone this repo to `~/dotfiles` (or any path).
2. From repo root, run `./bootstrap.sh` (defaults target to `$HOME`).

`bootstrap.sh` detects macOS or Linux, installs missing core tools with Homebrew, apt, dnf, or pacman, then stows common packages plus the current platform package.

Common commands:
- `stow zsh starship git ghostty nvim zed tmux lazygit bat gh gh-dash opencode eza macos` — link packages manually on macOS.
- `stow zsh starship git ghostty nvim zed tmux lazygit bat gh gh-dash opencode eza linux` — link packages manually on Linux.
- `stow -D nvim` — remove links for a package.
- `stow --target /some/dir pkg` — link into a different target.
