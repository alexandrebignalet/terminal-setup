# terminal-setup

Reproducible terminal environment for macOS. Inspired by [Gordon Beeming's
migration post](https://gordonbeeming.com/blog/2026-03-06/i-let-claude-migrate-my-entire-terminal-setup).

| Component        | Tool                                |
|------------------|-------------------------------------|
| Terminal         | [Ghostty](https://ghostty.org)      |
| Shell            | zsh + [zinit](https://github.com/zdharma-continuum/zinit) (cherry-picked OMZ libs) |
| Prompt           | [Starship](https://starship.rs)     |
| Node manager     | [fnm](https://github.com/Schniz/fnm) |
| Ruby manager     | [RVM](https://rvm.io) (authoritative) |
| Python manager   | [pyenv](https://github.com/pyenv/pyenv) |
| JVM manager      | [SDKMAN](https://sdkman.io)         |
| History          | [Atuin](https://atuin.sh) (local-only) |
| Smart cd         | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| ls replacement   | [eza](https://github.com/eza-community/eza) |
| Fuzzy completion | [fzf-tab](https://github.com/Aloxaf/fzf-tab) |
| Dotfiles         | [GNU Stow](https://www.gnu.org/software/stow/) symlinks |

**See [`docs/USAGE.md`](docs/USAGE.md) for tool-by-tool usage with concrete examples.**

## Quick start (new Mac)

```bash
# 1. Xcode CLT
xcode-select --install

# 2. Clone
git clone <this-repo-url> ~/Documents/code/terminal-setup
cd ~/Documents/code/terminal-setup

# 3. Run
./bootstrap.sh
```

The bootstrap script:

1. Detects (or installs) Homebrew. Per-user prefix at `~/brew` is supported (see *Multi-user note*).
2. Runs `brew bundle` to install Ghostty, Starship, fnm, Atuin, zoxide, eza, fzf, bat, fd, ripgrep, stow, git-delta, JetBrains Mono Nerd Font.
3. Backs up live dotfiles to `backups/<timestamp>/dotfiles/`.
4. Renames any conflicting plain dotfiles in `$HOME` to `*.pre-stow.<timestamp>` so `stow` can symlink without clobbering.
5. Stows `zsh`, `starship`, `ghostty`, `git` modules into `$HOME`.
6. Installs every Node version from `~/.nvm/versions/node/*` into fnm (additive — nvm dir untouched). Sets default = matches `~/.nvm/alias/default`.
7. Imports zsh history into Atuin (local-only).

Re-runnable. Each run creates a fresh timestamped backup.

## Manual steps (one-time)

These can't be automated:

- **1Password SSH agent**: open 1Password → Settings → Developer → enable *Use the SSH agent*. The `lib/20-tools.zsh` fragment auto-detects the socket once enabled.
- **Ghostty permissions**: first launch will prompt for Accessibility / Full Disk Access if used.
- **Atuin sync**: this setup is local-only by design. To enable cloud sync later: `atuin register`.

## Repository layout

```
terminal-setup/
├── README.md
├── Brewfile                # tools installed via `brew bundle`
├── bootstrap.sh            # idempotent installer
├── stow/                   # GNU Stow modules (symlinked into $HOME)
│   ├── zsh/.zshrc          # → ~/.zshrc
│   ├── zsh/.zprofile       # → ~/.zprofile
│   ├── starship/.config/starship.toml
│   ├── ghostty/.config/ghostty/config
│   ├── git/.gitconfig
│   └── git/.gitignore_global
├── lib/                    # zshrc-sourced fragments
│   ├── 10-path.zsh         # PATH (dynamic brew prefix)
│   ├── 20-tools.zsh        # fnm, pyenv, atuin, zoxide, fzf, 1Password
│   ├── 30-aliases.zsh      # eza/bat aliases
│   ├── 40-keybindings.zsh  # Shift+Enter, word/line nav
│   └── 99-local.zsh        # gitignored, machine-specific overrides
└── backups/<ts>/           # gitignored — auto-snapshots before changes
```

`lib/99-local.zsh` is gitignored. Use it for machine-specific env vars
that shouldn't be committed (work API keys, paths, etc.). Template at
`lib/99-local.zsh.example`.

## Multi-user Homebrew note

This repo's primary host has two user accounts. `/opt/homebrew` is owned
by user `alexandrebignalet`; user `alex` cannot write to it. Solution:
**per-user prefix at `~/brew`**. The shell config detects whichever
brew exists and runs its `shellenv`, so the same `.zshrc` works on:

- per-user prefix at `~/brew`
- standard `/opt/homebrew` (Apple Silicon)
- legacy `/usr/local` (Intel)

When bootstrapping on a fresh Mac where you own the machine, just let
brew install to its default prefix. To force a per-user install:

```bash
mkdir -p ~/brew
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/brew
~/brew/bin/brew shellenv >> ~/.zprofile
```

## What is preserved from the prior setup

- All shell PATH entries (`~/.platformsh/bin`, `~/.fly/bin`, JetBrains Toolbox, php@8.1).
- pyenv (Python 2.7.18 default), RVM (Ruby 3.2.3 default), SDKMAN.
- All 11 nvm Node versions, migrated to fnm.
- All 200+ git aliases (loaded via OMZ `git` plugin through zinit).
- 1Password SSH agent (auto-detected via socket).
- `.gitconfig` user, autocrlf, init.defaultBranch, LFS filters, `[safe]` directory.

`~/.nvm` and `~/.oh-my-zsh` are **not removed** — kept for rollback. See cleanup below.

## Rollback

Each `bootstrap.sh` run creates a backup at `backups/<timestamp>/`:

```bash
TS=20260506-100330                              # the run you want to undo
cd ~

# Remove the symlinks
rm .zshrc .zprofile .gitconfig .gitignore_global
rm -rf .config/ghostty .config/starship.toml

# Restore originals from the pre-stow rename
mv .zshrc.pre-stow.$TS    .zshrc
mv .zprofile.pre-stow.$TS .zprofile
mv .gitconfig.pre-stow.$TS .gitconfig

# Or, restore from repo backup snapshot
cp ~/Documents/code/terminal-setup/backups/$TS/dotfiles/.zshrc ~/.zshrc
# ...etc
```

To uninstall the tools: `brew bundle cleanup --file=Brewfile --force`.

## Cleanup (after you trust the new setup, ≥1 day)

Optional — removes the legacy stack to free disk + simplify environment:

```bash
# Remove nvm (fnm replaces it)
rm -rf ~/.nvm

# Remove oh-my-zsh (zinit cherry-picks what we need)
rm -rf ~/.oh-my-zsh

# Drop nvm from any old shell-init files (already gone from new .zshrc)
```

## Customizing

- Add a tool: edit `Brewfile` → run `brew bundle`.
- Add an alias: edit `lib/30-aliases.zsh`.
- Change prompt: edit `stow/starship/.config/starship.toml`.
- Change Ghostty: edit `stow/ghostty/.config/ghostty/config`.
- Machine-specific stuff: copy `lib/99-local.zsh.example` → `lib/99-local.zsh`.

After editing, no re-stow needed (symlinks point at the repo). Just
`exec zsh` to reload.

## Performance

Cold shell startup ≈700ms; warm ≈460ms (Apple Silicon, M-series, includes
zinit, OMZ git plugin, fnm, pyenv, RVM, SDKMAN). Stripping pyenv or RVM
brings it under 250ms — both are kept because the prior environment uses
them.

## Verification commands

```bash
node -v && which node          # via fnm shim
ruby -v                        # via RVM
python --version && pyenv version
git --version && alias gst     # OMZ git plugin loaded
starship --version
which fnm zoxide eza fzf bat ripgrep fd delta atuin stow
echo $SSH_AUTH_SOCK            # 1Password agent (if enabled)
```
