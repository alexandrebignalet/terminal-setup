# PATH setup. Order matters — earliest entries win.
# Resolves brew prefix dynamically (works for ~/brew, /opt/homebrew, /usr/local).

# Personal bin
[[ -d "$HOME/bin"       ]] && path=("$HOME/bin" $path)
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

# Homebrew (auto-detect — supports per-user prefix on shared Mac)
if [[ -x "$HOME/brew/bin/brew" ]]; then
  eval "$("$HOME/brew/bin/brew" shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Cloud + service CLIs
[[ -d "$HOME/.platformsh/bin" ]] && path=("$HOME/.platformsh/bin" $path)
[[ -d "$HOME/.fly/bin"        ]] && path=("$HOME/.fly/bin" $path)

# JetBrains Toolbox scripts
TOOLBOX_SCRIPTS="$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
[[ -d "$TOOLBOX_SCRIPTS" ]] && path=($path "$TOOLBOX_SCRIPTS")

# php@8.1 (legacy — kept for compatibility)
if [[ -d "$(brew --prefix 2>/dev/null)/opt/php@8.1/bin" ]]; then
  path=("$(brew --prefix)/opt/php@8.1/bin" $path)
fi

# Dedupe
typeset -U path PATH
export PATH
