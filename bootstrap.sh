#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(pwd)}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
COMMON_PACKAGES=(zsh starship git ghostty nvim zed tmux lazygit bat gh gh-dash opencode eza)
PLATFORM=""
PACKAGE_MANAGER=""
APT_UPDATED=0

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

require_cmd() {
  if ! has_cmd "$1"; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

run_as_root() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    "$@"
  else
    require_cmd sudo
    sudo "$@"
  fi
}

detect_platform() {
  case "$(uname -s)" in
    Darwin) PLATFORM="macos" ;;
    Linux) PLATFORM="linux" ;;
    *)
      echo "Unsupported platform: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

detect_package_manager() {
  if has_cmd brew; then
    PACKAGE_MANAGER="brew"
  elif has_cmd apt-get; then
    PACKAGE_MANAGER="apt"
  elif has_cmd dnf; then
    PACKAGE_MANAGER="dnf"
  elif has_cmd pacman; then
    PACKAGE_MANAGER="pacman"
  else
    echo "No supported package manager found. Install Homebrew, apt, dnf, or pacman." >&2
    exit 1
  fi
}

install_system_package() {
  case "$PACKAGE_MANAGER" in
    brew)
      brew install "$@"
      ;;
    apt)
      if [ "$APT_UPDATED" -eq 0 ]; then
        run_as_root apt-get update
        APT_UPDATED=1
      fi
      run_as_root apt-get install -y "$@"
      ;;
    dnf)
      run_as_root dnf install -y "$@"
      ;;
    pacman)
      run_as_root pacman -Sy --needed --noconfirm "$@"
      ;;
    *)
      echo "Unsupported package manager: $PACKAGE_MANAGER" >&2
      exit 1
      ;;
  esac
}

install_command() {
  local command_name="$1"
  shift

  if ! has_cmd "$command_name"; then
    echo "Installing $command_name..."
    install_system_package "$@"
  fi
}

install_bun() {
  if ! has_cmd bun; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
  fi
}

install_eza() {
  install_command eza eza
}

install_gh() {
  install_command gh gh
}

install_stow() {
  install_command stow stow
}

install_curl() {
  install_command curl curl
}

install_opencode() {
  if ! has_cmd opencode; then
    echo "Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
  fi
}

install_rust() {
  if ! has_cmd rustc; then
    echo "Installing rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

install_bun_globals() {
  install_bun
  if has_cmd bun; then
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

  detect_platform
  detect_package_manager

  install_stow
  install_curl
  install_rust
  install_eza
  install_gh
  install_opencode
  install_bun_globals

  echo "Linking packages to $TARGET_DIR"
  for pkg in "${COMMON_PACKAGES[@]}" "$PLATFORM"; do
    if [ -d "$pkg" ]; then
      stow --target "$TARGET_DIR" "$pkg"
    else
      echo "Skipping missing package: $pkg"
    fi
  done

  echo "Done. Edit package list in bootstrap.sh as needed."
}

main "$@"
