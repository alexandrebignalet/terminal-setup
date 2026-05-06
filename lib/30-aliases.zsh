# Aliases. Most git aliases come from the OMZ git plugin loaded via zinit.

# eza (modern ls)
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first --icons=auto'
  alias l='eza -lah --git --group-directories-first --icons=auto'
  alias ll='eza -lh --git --group-directories-first --icons=auto'
  alias la='eza -lAh --git --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
else
  alias ls='ls -G'
  alias l='ls -lah'
  alias ll='ls -lh'
  alias la='ls -lAh'
fi

# bat (better cat)
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'

# Quick-edit configs
alias zshconfig='${EDITOR} ~/.zshrc'
alias reloadshell='exec zsh'

# Existing custom aliases (preserved from prior setup)
alias p='platform'
alias md='mkdir -p'
alias rd='rmdir'
