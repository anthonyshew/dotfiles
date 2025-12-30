#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(pwd)}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
PACKAGES=(zsh bash starship git ghostty nvim zed tmux lazygit bat)

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

main() {
  cd "$REPO_DIR"
  require_cmd stow

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
