# Brewfile — terminal-setup
# Run: brew bundle --file=Brewfile
#
# Note: this Mac uses a per-user Homebrew prefix (~/brew for user `alex`)
# because /opt/homebrew is owned by another user (`alexandrebignalet`).
# All installs target whichever brew is first on PATH at bootstrap time.

# --- shell prompt + framework ---
brew "starship"          # prompt (replaces oh-my-zsh theme)
brew "zsh-completions"   # extra completions

# --- runtime managers (additive — nvm/pyenv/rvm stay) ---
brew "fnm"               # fast node manager (replaces nvm at runtime)

# --- modern CLI ---
brew "atuin"             # shell history (local-only mode)
brew "zoxide"            # smart cd
brew "eza"               # ls replacement
brew "fzf"               # fuzzy finder
brew "bat"               # cat with syntax highlighting
brew "fd"                # find replacement
brew "ripgrep"           # grep replacement

# --- dotfiles management ---
brew "stow"              # symlink dotfiles

# --- utilities ---
brew "git-delta"         # better git diff

# --- terminal emulator ---
cask "ghostty"

# --- font (Nerd Font for prompt icons) ---
cask "font-jetbrains-mono-nerd-font"
