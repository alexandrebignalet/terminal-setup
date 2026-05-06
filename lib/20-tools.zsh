# Runtime managers + tool integrations.

# --- fnm (node — replaces nvm at runtime; nvm dir kept for rollback) ---
if command -v fnm >/dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# --- pyenv ---
if command -v pyenv >/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d "$PYENV_ROOT/bin" ]] && path=("$PYENV_ROOT/bin" $path)
  eval "$(pyenv init - zsh)"
fi

# --- platform.sh CLI ---
if [[ -f "$HOME/.platformsh/shell-config.rc" ]]; then
  source "$HOME/.platformsh/shell-config.rc"
fi

# --- zoxide (smart cd: `z <partial>`) ---
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# --- atuin (history — local-only) ---
if command -v atuin >/dev/null; then
  export ATUIN_NOSTATS=true
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# --- fzf ---
if command -v fzf >/dev/null; then
  source <(fzf --zsh) 2>/dev/null
fi

# --- 1Password SSH agent (if app installed) ---
if [[ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
  export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# --- editor ---
export EDITOR=vim
export VISUAL=vim

# Less / locale
export LANG=${LANG:-en_US.UTF-8}
export LESS='-R --use-color'
