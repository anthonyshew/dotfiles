# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export MANPATH="$HOMEBREW_PREFIX/share/man:${MANPATH:-}"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"

# OrbStack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

if command -v security >/dev/null 2>&1; then
  export AI_GATEWAY_API_KEY="$(security find-generic-password -a "anthonyshew" -s "AI_GATEWAY_API_KEY" -w 2>/dev/null || :)"
fi
