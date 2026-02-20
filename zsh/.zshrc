# No ZSH shell sessions thing, yuck.
export SHELL_SESSIONS_DISABLE=1

# Command execution time (right-aligned, dimmed)
__cmd_start=0
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

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export MANPATH="/opt/homebrew/share/man:${MANPATH:-}"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"

# Bun
export BUN_INSTALL="$HOME/.bun"

# OrbStack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

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
$PNPM_HOME:\
/usr/local/go/bin:\
$HOME/go/bin:\
/opt/homebrew/opt/go@1.20/bin:\
$HOME/bin:\
/opt/homebrew/bin:\
/opt/homebrew/sbin:\
/usr/local/bin:\
$PATH"

# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"
# plugins=(git gh)

export FNM_LOGLEVEL="quiet"

# Cache fnm and starship init to avoid subprocess on every shell startup
# Regenerate cache: rm ~/.zsh_cache_*
_zsh_fnm_cache="$HOME/.zsh_cache_fnm"
_zsh_starship_cache="$HOME/.zsh_cache_starship"
_fnm_bin="/opt/homebrew/bin/fnm"
_starship_bin="/usr/local/bin/starship"

if [[ ! -f "$_zsh_fnm_cache" || "$_fnm_bin" -nt "$_zsh_fnm_cache" ]]; then
  fnm env --use-on-cd > "$_zsh_fnm_cache"
fi
source "$_zsh_fnm_cache"

if [[ ! -f "$_zsh_starship_cache" || "$_starship_bin" -nt "$_zsh_starship_cache" ]]; then
  starship init zsh --print-full-init > "$_zsh_starship_cache"
fi
source "$_zsh_starship_cache"


# My aliases
alias ls='eza --icons'
alias t='tmux'
alias p='pnpm'
alias n='nvim'
alias c='clear'
alias e='exit'
alias oc="OPENCODE_EXPERIMENTAL_MARKDOWN=true opencode"

# Git
alias gcm="git checkout main && git pull"
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
alias wip="source ~/.zshrc; git add -A && git commit -m 'WIP $(head -c 16 /dev/urandom | md5 | cut -c 1-5)' && git push"
alias newbranch="source ~/.zshrc; git checkout -b shew/$(head -c 16 /dev/urandom | md5 | cut -c 1-5)"
# Changed from alias to function - alias with $() runs git at shell startup!
cdgr() { cd "$(git rev-parse --show-toplevel)"; }

# Copy pwd without a newline, so annoying
cpwd() { printf '%s' "$PWD" | pbcopy; }

# Projects
alias projo="cd ~/projects/open"
alias projc="cd ~/projects/closed"
alias projd="cd ~/projects/debugs"
alias projt="cd ~/projects/open/turbo"

# Dev binaries and executables
alias devturbo="~/projects/open/turbo/target/debug/turbo"
alias devturboprod="~/projects/open/turbo/target/release/turbo"
dt() {
  local dir="$PWD"
  local turbo_bin=""
  
  # Walk up looking for target/debug/turbo
  while [[ "$dir" != "/" ]]; do
    if [[ -x "$dir/target/debug/turbo" ]]; then
      turbo_bin="$dir/target/debug/turbo"
      break
    fi
    dir="$(dirname "$dir")"
  done
  
  # Fallback to main repo
  if [[ -z "$turbo_bin" ]]; then
    turbo_bin=~/projects/open/turbo/target/debug/turbo
  fi
  
  "$turbo_bin" "$@" --skip-infer
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

# ENVIRONMENT VARIABLES
# DO NOT WRITE ENVIRONMENT VARIABLES HERE DIRECTLY
# USE THE `security` FUNCTIONALITY FROM MACOS
export AI_GATEWAY_API_KEY=$(security find-generic-password -a "anthonyshew" -s "AI_GATEWAY_API_KEY" -w)
