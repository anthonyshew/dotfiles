# No ZSH shell sessions thing, yuck.
export SHELL_SESSIONS_DISABLE=1

# Command execution time (right-aligned, dimmed)
__cmd_start=0
__ghostty_title_pwd=""

__ghostty_update_title() {
  [[ "$TERM_PROGRAM" == "ghostty" && "$PWD" != "$__ghostty_title_pwd" ]] || return

  local root title
  root="$(git rev-parse --show-toplevel 2>/dev/null)"
  title="${root:-$PWD:t}"
  title="${title:t}"
  printf '\e]0;%s\a' "$title"
  __ghostty_title_pwd="$PWD"
}

preexec() { __cmd_start=$EPOCHREALTIME }
precmd() {
  if (( __cmd_start > 0 )); then
    local elapsed=$(( EPOCHREALTIME - __cmd_start ))
    local ms=$(( elapsed * 1000 ))
    local display
    if (( ms < 1000 )); then
      display="${ms%.*}ms"
    elif (( elapsed < 60 )); then
      printf -v display "%.2fs" $elapsed
    else
      display="$((${elapsed%.*} / 60))m $((${elapsed%.*} % 60))s"
    fi
    printf "\e[90m%*s\e[0m\n" $COLUMNS "[$display]"
    __cmd_start=0
  fi
}

autoload -Uz add-zsh-hook

# Bun
export BUN_INSTALL="$HOME/.bun"

case "$(uname -s)" in
  Darwin) _zsh_platform_config="$HOME/.config/zsh/macos.zsh" ;;
  Linux) _zsh_platform_config="$HOME/.config/zsh/linux.zsh" ;;
esac

if [[ -n "${_zsh_platform_config:-}" && -r "$_zsh_platform_config" ]]; then
  source "$_zsh_platform_config"
fi

: "${PNPM_HOME:=$HOME/.local/share/pnpm}"

# Default editor
export EDITOR="nvim"

# eza config directory
export EZA_CONFIG_DIR="$HOME/.config/eza"
export EZA_COLORS="im=0:README.md=0:package.json=0:Makefile=0:Cargo.toml=0:go.mod=0"

# Consolidated PATH (single assignment is faster than multiple appends)
export PATH="\
$HOME/.local/bin:\
$HOME/.opencode/bin:\
$BUN_INSTALL/bin:\
$HOME/.cargo/bin:\
$PNPM_HOME:\
$HOME/go/bin:\
$HOME/bin:\
${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin:}\
${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin:}\
/usr/local/bin:\
$PATH"
typeset -gU path PATH

# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
# plugins=(git gh)

export FNM_LOGLEVEL="quiet"

# Cache fnm and starship init to avoid subprocess on every shell startup
# Regenerate cache: rm ~/.zsh_cache_*
_zsh_fnm_cache="$HOME/.zsh_cache_fnm"
_zsh_starship_cache="$HOME/.zsh_cache_starship"
_fnm_bin="$(command -v fnm 2>/dev/null || :)"
_starship_bin="$(command -v starship 2>/dev/null || :)"

if [[ -n "$_fnm_bin" ]]; then
  if [[ ! -f "$_zsh_fnm_cache" || "$_fnm_bin" -nt "$_zsh_fnm_cache" ]]; then
    fnm env --use-on-cd > "$_zsh_fnm_cache"
  fi
  source "$_zsh_fnm_cache"
fi

if [[ -n "$_starship_bin" ]]; then
  if [[ ! -f "$_zsh_starship_cache" || "$_starship_bin" -nt "$_zsh_starship_cache" ]]; then
    starship init zsh --print-full-init > "$_zsh_starship_cache"
  fi
  source "$_zsh_starship_cache"
fi


# My aliases
ls() {
  if (( $# == 0 )) || [[ "$*" == -* ]]; then
    command eza --icons "$@" .
  else
    command eza --icons "$@"
  fi
}
alias t='tmux'
alias p='pnpm'
alias n='nvim'
alias c='clear'
alias e='exit'
alias oc="OPENCODE_EXPERIMENTAL_MARKDOWN=true opencode"

# Git
alias gcm="git checkout main && git pull"
random_suffix() {
  if command -v sha256sum >/dev/null 2>&1; then
    head -c 16 /dev/urandom | sha256sum | cut -c 1-5
  elif command -v shasum >/dev/null 2>&1; then
    head -c 16 /dev/urandom | shasum | cut -c 1-5
  else
    head -c 16 /dev/urandom | cksum | cut -c 1-5
  fi
}

gwt() {
  echo -n "What are you building? "
  read desc
  if [[ -z "$desc" ]]; then
    echo "No description provided, aborting."
    return 1
  fi
  local name=$(ai -m openai/gpt-4o-mini "Generate a short git branch name (2-4 words, kebab-case, no prefix) for: $desc. Output ONLY the branch name, nothing else.")
  echo "Syncing main..."
  git fetch origin main -q && git checkout main -q && git pull origin main -q && git worktree add -B "shew/$name" "../$name" main && cd "../$name"
}
gdw() {
  local force=""
  [[ "$1" == "--force" || "$1" == "-f" ]] && force="--force"
  local wt=$(git rev-parse --show-toplevel)
  local main=$(git worktree list | grep '\[main\]' | awk '{print $1}')
  git worktree remove $force "$wt" && cd "$main" && git branch -D "shew/$(basename $wt)"
}
alias gc="git commit -m"
wip() {
  source ~/.zshrc
  git add -A && git commit -m "WIP $(random_suffix)" && git push
}
newbranch() {
  source ~/.zshrc
  git checkout -b "shew/$(random_suffix)"
}
cdgr() { cd "$(git rev-parse --show-toplevel)"; }

if command -v pbcopy >/dev/null 2>&1; then
  clipcopy() { pbcopy; }
elif command -v wl-copy >/dev/null 2>&1; then
  clipcopy() { wl-copy; }
elif command -v xclip >/dev/null 2>&1; then
  clipcopy() { xclip -selection clipboard; }
else
  clipcopy() {
    cat >/dev/null
    echo "No clipboard tool found" >&2
    return 1
  }
fi

# Copy pwd without a newline, so annoying
cpwd() { printf '%s' "$PWD" | clipcopy; }

# Projects
alias projo="cd ~/projects/open"
alias projc="cd ~/projects/closed"
alias projd="cd ~/projects/debugs"
alias projt="cd ~/projects/open/turbo"

# Dev binaries and executables
alias devturbo="~/projects/open/turbo/target/debug/turbo"
alias devturboprod="~/projects/open/turbo/target/release/turbo"
dt() {
  ~/projects/open/turbo/target/debug/turbo "$@" --skip-infer
}
tbp() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -x "$dir/target/debug/turbo" ]]; then
      echo -n "$dir/target/debug/turbo" | clipcopy
      echo "Copied: $dir/target/debug/turbo"
      return
    fi
    dir="$(dirname "$dir")"
  done
  echo "No target/debug/turbo found above $PWD"
  return 1
}
tbpr() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -x "$dir/target/release/turbo" ]]; then
      echo -n "$dir/target/release/turbo" | clipcopy
      echo "Copied: $dir/target/release/turbo"
      return
    fi
    dir="$(dirname "$dir")"
  done
  echo "No target/release/turbo found above $PWD"
  return 1
}
alias devcreateturbo="~/projects/open/turbo/packages/create-turbo/dist/cli.js"
alias devvc="~/projects/open/vercel/packages/cli/dist/vc.js"
# For making videos, comment out usually!
# alias turbo="devturboprod"

# Math.rand()
alias t="turbo"
alias pi="pnpm i --frozen-lockfile"
alias prlist="gh pr list --author \"@me\" --json=url --jq '.[].url'"
alias nukemodules='find . -name "node_modules" -type d -prune | xargs rm -rf'
alias killport='kill_port() { lsof -i tcp:$1 | awk "NR!=1 {print \$2}" | xargs kill -9; }; kill_port'
alias shew="~/projects/open/my-repo/apps/cli-app/target/release/shew-cli"

# Performance stuff below this line

# Initialize completion system (required for compdef)
autoload -Uz compinit
# Only regenerate .zcompdump once per day for speed
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # Skip security check, use cached
fi

# bun completions - lazy load to speed up shell startup
# Completions are loaded on first <tab> after typing 'bun'
if [[ -s "$HOME/.bun/_bun" ]]; then
  __load_bun_completions() {
    source "$HOME/.bun/_bun"
    unfunction __load_bun_completions
  }
  compdef __load_bun_completions bun
fi

# Register title hook last so it runs after Ghostty's shell-integration hooks.
add-zsh-hook chpwd __ghostty_update_title
add-zsh-hook precmd __ghostty_update_title
