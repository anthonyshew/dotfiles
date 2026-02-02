#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(pwd)}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
PACKAGES=(zsh starship git ghostty nvim zed tmux lazygit bat gh gh-dash opencode eza)

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

install_bun() {
  if ! command -v bun >/dev/null 2>&1; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
  fi
}

install_eza() {
  if ! command -v eza >/dev/null 2>&1; then
    echo "Installing eza..."
    brew install eza
  fi
}

install_rust() {
  if ! command -v rustc >/dev/null 2>&1; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

install_bun_globals() {
  install_bun
  if command -v bun >/dev/null 2>&1; then
    echo "Installing global bun packages..."
    bun install -g critique 2>/dev/null
    bun install -g agent-browser 2>/dev/null && agent-browser install
    bun install -g ai-cli 2>/dev/null
  else
    echo "bun installation failed, skipping global package installation"
  fi
}

main() {
  cd "$REPO_DIR"
  require_cmd stow

  install_rust
  install_eza
  install_bun_globals

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
