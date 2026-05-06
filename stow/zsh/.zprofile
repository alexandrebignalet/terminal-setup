# ~/.zprofile — login-shell init. Symlinked via `stow zsh`.

# Homebrew shellenv early so login shells (incl. tmux/ssh) see PATH.
if [[ -x "$HOME/brew/bin/brew" ]]; then
  eval "$("$HOME/brew/bin/brew" shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# JetBrains Toolbox scripts on PATH for login shells
TOOLBOX_SCRIPTS="$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
[[ -d "$TOOLBOX_SCRIPTS" ]] && export PATH="$PATH:$TOOLBOX_SCRIPTS"
