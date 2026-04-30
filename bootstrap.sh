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

ensure_cargo_path() {
  if ! has_cmd cargo && [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
  fi
}

install_eza() {
  if has_cmd eza; then
    return
  fi

  echo "Installing eza..."
  if install_system_package eza; then
    return
  fi

  echo "System package for eza unavailable; installing eza with cargo..."
  ensure_cargo_path
  require_cmd cargo
  cargo install eza
}

install_gh_from_release() {
  local arch
  local url
  local tmpdir
  local gh_dir

  install_curl
  install_command tar tar
  install_command gzip gzip

  case "$(uname -m)" in
    x86_64 | amd64) arch="amd64" ;;
    arm64 | aarch64) arch="arm64" ;;
    armv6l | armv7l) arch="armv6" ;;
    *)
      echo "Unsupported architecture for GitHub CLI: $(uname -m)" >&2
      exit 1
      ;;
  esac

  url="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | perl -ne 'print "$1\n" if /"browser_download_url": "([^"]*linux_'"$arch"'\.tar\.gz)"/' | head -n 1)"
  if [ -z "$url" ]; then
    echo "Could not find GitHub CLI Linux release for $arch" >&2
    exit 1
  fi

  tmpdir="$(mktemp -d)"
  (
    trap 'rm -rf "$tmpdir"' EXIT
    cd "$tmpdir"
    curl -fsSL -o gh.tar.gz "$url"
    tar -xzf gh.tar.gz
    gh_dir="$(printf '%s\n' gh_*_linux_* | head -n 1)"
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/man/man1"
    cp "$gh_dir/bin/gh" "$HOME/.local/bin/gh"
    cp "$gh_dir/share/man/man1/gh.1" "$HOME/.local/share/man/man1/gh.1"
  )

  export PATH="$HOME/.local/bin:$PATH"
}

install_gh() {
  if has_cmd gh; then
    return
  fi

  echo "Installing gh..."
  if install_system_package gh; then
    return
  fi

  if [ "$PLATFORM" = "linux" ]; then
    echo "System package for gh unavailable; installing GitHub CLI from release..."
    install_gh_from_release
    require_cmd gh
    return
  fi

  require_cmd gh
}

install_curl() {
  install_command curl curl
}

install_stow_from_source() {
  local version="2.4.1"
  local tmpdir

  install_curl
  install_command perl perl
  install_command make make
  install_command tar tar
  install_command gzip gzip

  tmpdir="$(mktemp -d)"
  (
    trap 'rm -rf "$tmpdir"' EXIT
    cd "$tmpdir"
    curl -fsSLO "https://ftp.gnu.org/gnu/stow/stow-$version.tar.gz"
    tar -xzf "stow-$version.tar.gz"
    cd "stow-$version"
    ./configure --prefix="$HOME/.local"
    make install
  )

  export PATH="$HOME/.local/bin:$PATH"
}

install_stow() {
  if has_cmd stow; then
    return
  fi

  echo "Installing stow..."
  if install_system_package stow; then
    return
  fi

  echo "System package for stow unavailable; installing GNU Stow from source..."
  install_stow_from_source
  require_cmd stow
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
  ensure_cargo_path
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

  install_curl
  install_stow
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
