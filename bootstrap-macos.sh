#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(pwd)}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
PACKAGES=(zsh starship git ghostty nvim zed tmux lazygit bat gh gh-dash opencode eza macos)

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

require_cmd() {
  if ! has_cmd "$1"; then
    echo "Missing dependency: $1" >&2
    exit 1
  fi
}

require_macos() {
  if [ "$(uname -s)" != "Darwin" ]; then
    echo "bootstrap-macos.sh only supports macOS" >&2
    exit 1
  fi
}

install_brew_package() {
  brew install "$@"
}

install_command() {
  local command_name="$1"
  shift

  if ! has_cmd "$command_name"; then
    echo "Installing $command_name..."
    install_brew_package "$@"
  fi
}

install_curl() {
  install_command curl curl
}

install_git() {
  install_command git git
}

ensure_cargo_path() {
  if ! has_cmd cargo && [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
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

install_bun() {
  if ! has_cmd bun; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
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

install_opencode() {
  if ! has_cmd opencode; then
    echo "Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
  fi
}

install_opencode_config_dependencies() {
  local config_dir="$REPO_DIR/opencode/.config/opencode"

  if [ -f "$config_dir/package.json" ]; then
    echo "Installing opencode config dependencies..."
    (
      cd "$config_dir"
      if [ -f bun.lock ]; then
        bun install --frozen-lockfile
      else
        bun install
      fi
    )
  fi
}

resolve_link_target() {
  local link="$1"
  local target="$2"
  local target_dir
  local target_base

  if [[ "$target" = /* ]]; then
    printf '%s\n' "$target"
    return
  fi

  target_dir="$(dirname "$target")"
  target_base="$(basename "$target")"
  (
    cd "$(dirname "$link")/$target_dir" 2>/dev/null && printf '%s/%s\n' "$PWD" "$target_base"
  )
}

link_entry() {
  local src="$1"
  local dest="$2"
  local existing_target
  local existing_resolved

  if [ -d "$src" ] && [ ! -L "$src" ]; then
    mkdir -p "$dest"
    local child
    shopt -s dotglob nullglob
    for child in "$src"/*; do
      link_entry "$child" "$dest/$(basename "$child")"
    done
    shopt -u dotglob nullglob
    return
  fi

  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    existing_target="$(readlink "$dest")"
    existing_resolved="$(resolve_link_target "$dest" "$existing_target")"
    if [ "$existing_resolved" = "$src" ]; then
      return
    fi
    echo "Refusing to replace existing symlink: $dest -> $existing_target" >&2
    return 1
  fi
  if [ -e "$dest" ]; then
    echo "Refusing to replace existing path: $dest" >&2
    return 1
  fi
  ln -s "$src" "$dest"
}

link_package() {
  local pkg="$1"
  local src="$REPO_DIR/$pkg"
  local child

  if [ ! -d "$src" ]; then
    echo "Skipping missing package: $pkg"
    return
  fi

  shopt -s dotglob nullglob
  for child in "$src"/*; do
    link_entry "$child" "$TARGET_DIR/$(basename "$child")"
  done
  shopt -u dotglob nullglob
}

sync_lazyvim() {
  require_cmd nvim
  require_cmd git

  echo "Restoring LazyVim plugins..."
  nvim --headless "+Lazy! restore" +qa
}

main() {
  require_macos
  require_cmd brew

  cd "$REPO_DIR"
  REPO_DIR="$(pwd)"

  install_curl
  install_git
  install_rust
  install_command nvim neovim
  install_command unzip unzip
  install_command fzf fzf
  install_command rg ripgrep
  install_command fd fd
  install_command lazygit lazygit
  install_command eza eza
  install_command gh gh
  install_opencode
  install_bun_globals
  install_opencode_config_dependencies

  echo "Linking packages to $TARGET_DIR"
  for pkg in "${PACKAGES[@]}"; do
    link_package "$pkg"
  done

  sync_lazyvim

  echo "Done. Edit package list in bootstrap-macos.sh as needed."
}

main "$@"
