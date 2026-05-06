# ~/.zshrc — managed by terminal-setup (https://github.com/alexandrebignalet/terminal-setup)
# Symlinked via `stow zsh`. Edit the source in repo, not this file.

# Path to the dotfiles repo (used to source lib/ fragments)
export TERMINAL_SETUP_DIR="${TERMINAL_SETUP_DIR:-$HOME/Documents/code/terminal-setup}"

# --- 1. Zinit (plugin manager) ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  command mkdir -p "$(dirname "$ZINIT_HOME")"
  command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# --- 2. Cherry-picked Oh My Zsh libs (replaces full OMZ) ---
zinit snippet OMZL::git.zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::history.zsh
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::theme-and-appearance.zsh

# --- 3. Plugins ---
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git           # 200+ git aliases (gst, gco, gcm, etc.)
zinit snippet OMZP::sudo          # ESC ESC to prepend sudo

# Load completions
# Per-user completions dir (populated by bootstrap.sh from foreign-owned
# brew symlinks — see step 2.5). Must be on fpath BEFORE compinit so its
# entries take precedence; -i silently skips the still-flagged brew links.
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)
autoload -Uz compinit && compinit -i
zinit cdreplay -q

# --- 4. fzf-tab styling ---
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --- 5. Repo lib fragments (PATH, tools, aliases, keys) ---
for f in "$TERMINAL_SETUP_DIR"/lib/[0-9]*.zsh; do
  [[ -r "$f" ]] && source "$f"
done

# --- 6. Starship prompt ---
command -v starship >/dev/null && eval "$(starship init zsh)"

# --- 7. RVM (must be late — modifies PATH) ---
[[ -d "$HOME/.rvm/bin" ]] && export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# --- 8. Local overrides (gitignored) ---
[[ -r "$TERMINAL_SETUP_DIR/lib/99-local.zsh" ]] && source "$TERMINAL_SETUP_DIR/lib/99-local.zsh"

# --- 9. SDKMAN — MUST be the very last entry per SDKMAN's own warning ---
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
