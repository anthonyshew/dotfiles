#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(pwd)}"
TARGET_DIR="${TARGET_DIR:-$HOME}"
PACKAGES=(zsh starship git ghostty nvim zed tmux lazygit bat gh gh-dash opencode eza linux)
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

require_linux() {
  if [ "$(uname -s)" != "Linux" ]; then
    echo "bootstrap-linux.sh only supports Linux" >&2
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

detect_package_manager() {
  if has_cmd apt-get; then
    PACKAGE_MANAGER="apt"
  elif has_cmd dnf; then
    PACKAGE_MANAGER="dnf"
  elif has_cmd pacman; then
    PACKAGE_MANAGER="pacman"
  else
    echo "No supported Linux package manager found. Install apt, dnf, or pacman." >&2
    exit 1
  fi
}

install_system_package() {
  case "$PACKAGE_MANAGER" in
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

install_curl() {
  install_command curl curl
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

install_fzf_from_release() {
  local arch
  local version
  local url
  local tmpdir

  install_curl
  install_command tar tar
  install_command gzip gzip

  case "$(uname -m)" in
    x86_64 | amd64) arch="amd64" ;;
    arm64 | aarch64) arch="arm64" ;;
    armv6l | armv7l) arch="armv7" ;;
    *)
      echo "Unsupported architecture for fzf: $(uname -m)" >&2
      exit 1
      ;;
  esac

  version="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/junegunn/fzf/releases/latest | perl -ne 'print "$1" if m{/tag/v([^/]+)$}')"
  if [ -z "$version" ]; then
    echo "Could not determine latest fzf version" >&2
    exit 1
  fi

  url="https://github.com/junegunn/fzf/releases/latest/download/fzf-${version}-linux_${arch}.tar.gz"
  tmpdir="$(mktemp -d)"
  (
    trap 'rm -rf "$tmpdir"' EXIT
    cd "$tmpdir"
    curl -fsSL -o fzf.tar.gz "$url"
    tar -xzf fzf.tar.gz fzf
    mkdir -p "$HOME/.local/bin"
    cp fzf "$HOME/.local/bin/fzf"
    chmod +x "$HOME/.local/bin/fzf"
  )

  export PATH="$HOME/.local/bin:$PATH"
}

install_fzf() {
  if has_cmd fzf; then
    return
  fi

  echo "Installing fzf..."
  if install_system_package fzf; then
    return
  fi

  echo "System package for fzf unavailable; installing fzf from release..."
  install_fzf_from_release
  require_cmd fzf
}

install_rg() {
  if has_cmd rg; then
    return
  fi

  echo "Installing rg..."
  if install_system_package ripgrep; then
    return
  fi

  echo "System package for rg unavailable; installing ripgrep with cargo..."
  ensure_cargo_path
  require_cmd cargo
  cargo install ripgrep
  export PATH="$HOME/.cargo/bin:$PATH"
  require_cmd rg
}

install_fd() {
  if has_cmd fd; then
    return
  fi

  echo "Installing fd..."
  case "$PACKAGE_MANAGER" in
    apt)
      if install_system_package fd-find; then
        if ! has_cmd fd && has_cmd fdfind; then
          mkdir -p "$HOME/.local/bin"
          ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
          export PATH="$HOME/.local/bin:$PATH"
        fi
      else
        echo "System package for fd unavailable; installing fd-find with cargo..."
        ensure_cargo_path
        require_cmd cargo
        cargo install fd-find
        export PATH="$HOME/.cargo/bin:$PATH"
      fi
      ;;
    dnf)
      if install_system_package fd-find; then
        return
      fi
      echo "System package for fd unavailable; installing fd-find with cargo..."
      ensure_cargo_path
      require_cmd cargo
      cargo install fd-find
      export PATH="$HOME/.cargo/bin:$PATH"
      ;;
    *)
      if install_system_package fd; then
        return
      fi
      echo "System package for fd unavailable; installing fd-find with cargo..."
      ensure_cargo_path
      require_cmd cargo
      cargo install fd-find
      export PATH="$HOME/.cargo/bin:$PATH"
      ;;
  esac

  require_cmd fd
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

install_git() {
  install_command git git
}

install_nvim_from_release() {
  local arch
  local url
  local tmpdir
  local nvim_dir

  install_curl
  install_command tar tar
  install_command gzip gzip

  case "$(uname -m)" in
    x86_64 | amd64) arch="x86_64" ;;
    arm64 | aarch64) arch="arm64" ;;
    *)
      echo "Unsupported architecture for Neovim: $(uname -m)" >&2
      exit 1
      ;;
  esac

  url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz"
  tmpdir="$(mktemp -d)"
  (
    trap 'rm -rf "$tmpdir"' EXIT
    cd "$tmpdir"
    curl -fsSL -o nvim.tar.gz "$url"
    tar -xzf nvim.tar.gz
    nvim_dir="$(printf '%s\n' nvim-linux-* | head -n 1)"
    rm -rf "$HOME/.local/nvim"
    mkdir -p "$HOME/.local/bin"
    cp -R "$nvim_dir" "$HOME/.local/nvim"
    ln -sfn "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  )

  export PATH="$HOME/.local/bin:$PATH"
}

install_nvim() {
  if has_cmd nvim; then
    return
  fi

  echo "Installing nvim..."
  if install_system_package neovim; then
    return
  fi

  echo "System package for nvim unavailable; installing Neovim from release..."
  install_nvim_from_release
  require_cmd nvim
}

install_gh_from_release() {
  local arch
  local version
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

  version="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/cli/cli/releases/latest | perl -ne 'print "$1" if m{/tag/v([^/]+)$}')"
  if [ -z "$version" ]; then
    echo "Could not determine latest GitHub CLI version" >&2
    exit 1
  fi
  url="https://github.com/cli/cli/releases/latest/download/gh_${version}_linux_${arch}.tar.gz"

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

  echo "System package for gh unavailable; installing GitHub CLI from release..."
  install_gh_from_release
  require_cmd gh
}

install_lazygit_from_release() {
  local arch
  local version
  local url
  local tmpdir

  install_curl
  install_command tar tar
  install_command gzip gzip

  case "$(uname -m)" in
    x86_64 | amd64) arch="x86_64" ;;
    arm64 | aarch64) arch="arm64" ;;
    armv6l | armv7l) arch="armv6" ;;
    *)
      echo "Unsupported architecture for lazygit: $(uname -m)" >&2
      exit 1
      ;;
  esac

  version="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/jesseduffield/lazygit/releases/latest | perl -ne 'print "$1" if m{/tag/v([^/]+)$}')"
  if [ -z "$version" ]; then
    echo "Could not determine latest lazygit version" >&2
    exit 1
  fi

  url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_${arch}.tar.gz"
  tmpdir="$(mktemp -d)"
  (
    trap 'rm -rf "$tmpdir"' EXIT
    cd "$tmpdir"
    curl -fsSL -o lazygit.tar.gz "$url"
    tar -xzf lazygit.tar.gz lazygit
    mkdir -p "$HOME/.local/bin"
    cp lazygit "$HOME/.local/bin/lazygit"
    chmod +x "$HOME/.local/bin/lazygit"
  )

  export PATH="$HOME/.local/bin:$PATH"
}

install_lazygit() {
  if has_cmd lazygit; then
    return
  fi

  echo "Installing lazygit..."
  if install_system_package lazygit; then
    return
  fi

  echo "System package for lazygit unavailable; installing lazygit from release..."
  install_lazygit_from_release
  require_cmd lazygit
}

install_opencode() {
  if ! has_cmd opencode; then
    echo "Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
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
  require_linux
  detect_package_manager

  cd "$REPO_DIR"
  REPO_DIR="$(pwd)"

  install_curl
  install_git
  install_rust
  install_nvim
  install_command unzip unzip
  install_fzf
  install_rg
  install_fd
  install_lazygit
  install_eza
  install_gh
  install_opencode
  install_bun_globals

  echo "Linking packages to $TARGET_DIR"
  for pkg in "${PACKAGES[@]}"; do
    link_package "$pkg"
  done

  sync_lazyvim

  echo "Done. Edit package list in bootstrap-linux.sh as needed."
}

main "$@"
