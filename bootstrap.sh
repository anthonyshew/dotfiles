#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(pwd)}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
PACKAGES=(zsh starship git ghostty nvim zed tmux lazygit bat gh gh-dash opencode)

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

install_npm_globals() {
  if command -v npm >/dev/null 2>&1; then
    echo "Installing global npm packages..."
    bun install -g critique 2>/dev/null
  else
    echo "bun not found, skipping global package installation"
  fi
}

main() {
  cd "$REPO_DIR"
  require_cmd stow

  install_npm_globals

  echo "Linking packages to $TARGET_DIR"
  for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
      stow --target "$TARGET_DIR" "$pkg"
    else
      echo "Skipping missing package: $pkg"
    fi
  done

  echo "Done. Edit package list in bootstrap.sh as needed."
}

main "$@"
