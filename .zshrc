
# Rust thing, idk
. "$HOME/.cargo/env"

eval $(/opt/homebrew/bin/brew shellenv)
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/opt/homebrew/opt/go@1.20/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(git gh)

eval "$(fnm env --use-on-cd)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/anthonyshew/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

eval "$(fnm env --use-on-cd)"
eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# My aliases
alias t='tmux'
alias p='pnpm'

# Open sourcery
alias projo="cd ~/projects/open"

# Closed sourcery
alias projc="cd ~/projects/closed"

# Debugging the bugs of myself and others
alias projd="cd ~/projects/debugs"

# Turbooooooo
alias projt="cd ~/projects/open/turbo"
alias devturbo="~/projects/open/turbo/target/debug/turbo"

# Math.rand()
alias prlist="gh pr list --author \"@me\" --json=url --jq '.[].url'"
alias nukemodules='find . -name "node_modules" -type d -prune | xargs rm -rf'
