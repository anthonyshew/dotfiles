# Dotfiles

This repo is organized into "packages" (directories) that mirror `$HOME`. The bootstrap scripts link package contents into your home directory so the repo remains the source of truth.

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
- `bootstrap-macos.sh` → install/link macOS packages
- `bootstrap-linux.sh` → install/link Linux packages

Add more packages by creating new directories and mirroring the target paths inside them.

## Usage
1. Clone this repo to `~/dotfiles` (or any path).
2. From repo root, run the bootstrap script for the current OS (defaults target to `$HOME`).

Each bootstrap script installs missing core tools, links common packages plus the matching platform package, then restores LazyVim plugins headlessly from the lockfile.

Common commands:
- `./bootstrap-macos.sh` — install and link packages on macOS.
- `./bootstrap-linux.sh` — install and link packages on Linux.
- `TARGET_DIR=/some/dir ./bootstrap-macos.sh` — link into a different target.
