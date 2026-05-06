#!/usr/bin/env bash
# bootstrap.sh — idempotent installer for terminal-setup.
# Safe to re-run. Backs up live dotfiles before stowing.
#
# Usage:  ./bootstrap.sh [--skip-brew] [--skip-node] [--skip-stow]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$REPO_DIR/backups/$TS"

SKIP_BREW=0; SKIP_NODE=0; SKIP_STOW=0
for arg in "$@"; do
  case "$arg" in
    --skip-brew) SKIP_BREW=1 ;;
    --skip-node) SKIP_NODE=1 ;;
    --skip-stow) SKIP_STOW=1 ;;
    *) echo "Unknown arg: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mXX \033[0m %s\n' "$*" >&2; exit 1; }

# --- 0. Pre-flight ---
[[ "$(uname -s)" == "Darwin" ]] || die "macOS only"
xcode-select -p >/dev/null 2>&1 || die "Install Xcode CLT first: xcode-select --install"

# --- 1. Brew detect ---
detect_brew() {
  if [[ -x "$HOME/brew/bin/brew" ]]; then echo "$HOME/brew/bin/brew"
  elif [[ -x /opt/homebrew/bin/brew ]];   then echo /opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]];      then echo /usr/local/bin/brew
  else return 1; fi
}

if BREW=$(detect_brew); then
  log "Using brew at: $BREW"
else
  warn "No brew found."
  read -r -p "Install per-user brew at ~/brew? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    mkdir -p "$HOME/brew"
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$HOME/brew"
    BREW="$HOME/brew/bin/brew"
  else
    die "Brew required."
  fi
fi
eval "$("$BREW" shellenv)"

# --- 2. Brewfile ---
if [[ "$SKIP_BREW" -eq 0 ]]; then
  log "brew bundle (Brewfile)"
  "$BREW" bundle --file="$REPO_DIR/Brewfile"
else
  log "Skipping brew bundle"
fi

# --- 3. Backup live dotfiles before stow ---
log "Backing up live dotfiles → $BACKUP_DIR"
mkdir -p "$BACKUP_DIR/dotfiles"
for f in .zshrc .zprofile .bash_profile .bashrc .gitconfig .gitignore_global; do
  if [[ -f "$HOME/$f" && ! -L "$HOME/$f" ]]; then
    cp -p "$HOME/$f" "$BACKUP_DIR/dotfiles/$f"
  fi
done
[[ -f "$HOME/.config/starship.toml" && ! -L "$HOME/.config/starship.toml" ]] \
  && { mkdir -p "$BACKUP_DIR/dotfiles/.config"; cp -p "$HOME/.config/starship.toml" "$BACKUP_DIR/dotfiles/.config/"; }
[[ -d "$HOME/.config/ghostty"    && ! -L "$HOME/.config/ghostty"    ]] \
  && { mkdir -p "$BACKUP_DIR/dotfiles/.config"; cp -Rp "$HOME/.config/ghostty" "$BACKUP_DIR/dotfiles/.config/"; }

# --- 4. Move conflicting plain files aside (stow refuses to overwrite) ---
log "Moving conflicting plain files aside (renamed .pre-stow.$TS)"
move_aside() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.pre-stow.$TS"
    warn "Moved $target → $target.pre-stow.$TS"
  fi
}
move_aside "$HOME/.zshrc"
move_aside "$HOME/.zprofile"
move_aside "$HOME/.gitconfig"
move_aside "$HOME/.gitignore_global"
move_aside "$HOME/.config/starship.toml"
move_aside "$HOME/.config/ghostty/config"

# --- 5. Stow ---
if [[ "$SKIP_STOW" -eq 0 ]]; then
  command -v stow >/dev/null || die "stow not installed (brew bundle should have done it)"
  mkdir -p "$HOME/.config"
  log "stow zsh starship ghostty git"
  cd "$REPO_DIR/stow"
  stow --restow --target="$HOME" zsh starship ghostty git
  cd - >/dev/null
fi

# --- 6. Migrate Node versions from nvm to fnm (additive) ---
if [[ "$SKIP_NODE" -eq 0 ]] && command -v fnm >/dev/null; then
  if [[ -d "$HOME/.nvm/versions/node" ]]; then
    log "Migrating Node versions from nvm to fnm"
    eval "$(fnm env --shell bash)"
    for v in "$HOME/.nvm/versions/node"/*; do
      ver="${v##*/}"
      ver_num="${ver#v}"
      if fnm list 2>/dev/null | grep -q "$ver"; then
        log "  fnm already has $ver"
      else
        log "  fnm install $ver_num"
        fnm install "$ver_num" || warn "  failed: $ver_num"
      fi
    done
    if [[ -f "$HOME/.nvm/alias/default" ]]; then
      DEFAULT_VER=$(cat "$HOME/.nvm/alias/default")
      log "Setting fnm default → $DEFAULT_VER"
      fnm default "$DEFAULT_VER" || warn "fnm default failed"
    fi
  fi
fi

# --- 7. Atuin import (local-only) ---
if command -v atuin >/dev/null; then
  if [[ ! -d "$HOME/.local/share/atuin" ]]; then
    log "Initializing atuin (local-only)"
    atuin import zsh || warn "atuin import failed (non-fatal)"
  fi
fi

# --- 8. Done ---
log "Done. Backup at: $BACKUP_DIR"
log "Open a new Ghostty window (or run: exec zsh) to use the new setup."
log "Old config files preserved as *.pre-stow.$TS in \$HOME"
