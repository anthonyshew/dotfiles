# No ZSH shell sessions thing, yuck.
SHELL_SESSIONS_DISABLE=1

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export MANPATH="/opt/homebrew/share/man:${MANPATH:-}"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# pnpm
export PNPM_HOME="/Users/anthonyshew/Library/pnpm"

# Bun
export BUN_INSTALL="$HOME/.bun"

# Consolidated PATH (single assignment is faster than multiple appends)
export PATH="\
$HOME/.local/bin:\
$HOME/.opencode/bin:\
$BUN_INSTALL/bin:\
$PNPM_HOME:\
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
alias t='tmux'
alias p='pnpm'
alias n='nvim'
alias c='clear'
alias e='exit'
alias rec="alacritty --config-file $HOME/.config/alacritty/recording.toml"
alias oc="opencode"

# Git
alias gcm="git checkout main && git pull"
alias gc="git commit -m"
alias wip="source ~/.zshrc; git add -A && git commit -m 'WIP $(head -c 16 /dev/urandom | md5 | cut -c 1-5)' && git push"
alias newbranch="source ~/.zshrc; git checkout -b shew/$(head -c 16 /dev/urandom | md5 | cut -c 1-5)"
# Changed from alias to function - alias with $() runs git at shell startup!
cdgr() { cd "$(git rev-parse --show-toplevel)"; }

# Git worktrees (usage: wt add [name], wt rm <branch>, wt list, wt rm --force <branch>)
wt() {
  case "$1" in
    add)
      local suffix="${2:-$(head -c 16 /dev/urandom | md5 | cut -c 1-5)}"
      local name="shew/$suffix"
      local worktree_path="../$(basename $(pwd))-worktree-$suffix"
      git worktree add "$worktree_path" -b "$name"
      echo "Created worktree on branch: $name"
      cd "$worktree_path"
      ;;
    rm)
      if [[ "$2" == "--force" || "$2" == "-f" ]]; then
        local branch="$3"
        local short="${branch##*/}"
        local main_repo="../$(basename $(pwd) | sed 's/-worktree-.*//')"
        cd "$main_repo"
        git worktree remove --force "$(pwd)-worktree-$short"
        git branch -D "$branch"
      else
        local branch="$2"
        local short="${branch##*/}"
        local main_repo="../$(basename $(pwd) | sed 's/-worktree-.*//')"
        cd "$main_repo"
        git worktree remove "$(pwd)-worktree-$short" && git branch -d "$branch"
      fi
      ;;
    list|ls)
      git worktree list
      ;;
    *)
      echo "Usage: wt <command>"
      echo "Commands:"
      echo "  add [name]       Create worktree (random name if omitted)"
      echo "  rm <branch>      Remove worktree and delete branch"
      echo "  rm -f <branch>   Force remove worktree and branch"
      echo "  list, ls         List all worktrees"
      ;;
  esac
}

# Projects
alias projo="cd ~/projects/open"
alias projc="cd ~/projects/closed"
alias projd="cd ~/projects/debugs"
alias projt="cd ~/projects/open/turbo"

# Dev binaries and executables
alias devturbo="~/projects/open/turbo/target/debug/turbo"
alias devturboprod="~/projects/open/turbo/target/release/turbo"
dt() { ~/projects/open/turbo/target/debug/turbo "$@" --skip-infer; }
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

# AI AF
alias claude="/Users/anthonyshew/.claude/local/claude"

# # Rename Ghostty tabs to git root or PWD
# precmd() {
#     local git_root=$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null)
#     if [ -n "$git_root" ]; then
#         printf "\e]9;9;%s\a" "$(basename "$git_root")"
#     else
#         printf "\e]9;9;%s\a" "$(basename "$PWD")"
#     fi
# }

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
if [[ -s "/Users/anthonyshew/.bun/_bun" ]]; then
  __load_bun_completions() {
    source "/Users/anthonyshew/.bun/_bun"
    unfunction __load_bun_completions
  }
  compdef __load_bun_completions bun
fi
