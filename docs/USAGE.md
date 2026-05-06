# Tool usage guide

Concrete examples for every tool installed by `bootstrap.sh`. Grouped by
what you'd actually do at the terminal.

---

## eza — modern `ls`

Replacement for `ls`. Icons, git status, tree mode, color by file type.

```bash
ls                   # alias → eza --group-directories-first --icons=auto
ll                   # long listing, no hidden
la                   # long, with hidden
l                    # long, with hidden + sizes
lt                   # tree, depth 2

# Useful one-offs (no alias)
eza -l --git                       # show git status per file (M/A/?/!)
eza --tree --level=3 --git-ignore  # tree, skip .gitignored files
eza -l --sort=modified             # newest last
eza -l --total-size                # show dir sizes
```

**Tip**: replace `find . -type d -maxdepth 2` with `eza -D --tree --level=2`.

---

## bat — `cat` with syntax highlighting + paging

```bash
cat file.js          # alias → bat --paging=never --style=plain (no chrome)
bat file.js          # paged, line numbers, syntax highlight
bat -A file.txt      # show non-printable chars (tabs, CRLF, trailing space)
bat -r 50:80 file    # only lines 50–80
bat *.md             # browse multiple files

# Pipe-friendly (auto-detects, but force with --color=always)
curl -s api.example.com/foo | bat -l json
git diff | bat -l diff
```

**Tip**: set as `man` pager: `export MANPAGER="sh -c 'col -bx | bat -l man -p'"`.

---

## fd — modern `find`

```bash
fd README                    # any file containing "README"
fd '\.ts$'                   # regex: TypeScript files
fd -e md                     # extension shorthand
fd -t f -t x                 # files (-t f) that are executable (-t x)
fd -t d node_modules         # directories named node_modules
fd -H -I '.env'              # include hidden + ignored files
fd -E node_modules pattern   # exclude pattern from search
fd pattern --exec wc -l {}   # run command per match
fd -0 pattern | xargs -0 ...  # null-delimited for filenames with spaces
```

vs. `find`: `find . -name '*.ts' -not -path '*/node_modules/*'` → `fd -e ts`.

---

## ripgrep (rg) — modern `grep`

```bash
rg pattern                   # recursive, respects .gitignore, skips binaries
rg -i pattern                # case-insensitive
rg -w word                   # whole word only
rg -F 'literal.string'       # fixed string, no regex
rg -l pattern                # only filenames that match
rg -c pattern                # count matches per file
rg -A 3 -B 1 pattern         # 3 lines after, 1 before
rg -t js pattern             # only .js (built-in type list: rg --type-list)
rg -g '*.{ts,tsx}' pattern   # glob filter
rg pattern -- path/          # restrict to path
rg --hidden --no-ignore foo  # search hidden + .gitignored
rg pattern -r 'replacement'  # preview replacement (no write)
```

vs. `grep -rn`: `rg pattern` (faster, smarter defaults).

---

## fzf — fuzzy finder

Standalone + interactive pickers. Already wired into Ctrl+R history search and Ctrl+T file picker.

```bash
# Built-in keybinds (after installing fzf shell integration)
# Ctrl+R       fuzzy history search
# Ctrl+T       fuzzy file insert into command line
# Alt+C        fuzzy cd

# Pipe anything
ls | fzf
git branch -a | fzf | xargs git checkout

# Common patterns
nvim "$(fd -t f | fzf)"                       # open a file
git checkout "$(git branch | fzf | tr -d ' *')" # pick a branch
kill -9 "$(ps aux | fzf | awk '{print $2}')"  # pick a process

# Preview pane
fzf --preview 'bat --color=always {}'
fd -t f | fzf --preview 'bat --color=always --line-range :100 {}'
```

**fzf-tab** (auto-loaded in zsh): just hit `Tab` after any command — completion items appear in fzf UI.

```
git checkout <Tab>           # fuzzy-search branches
cd <Tab>                     # fuzzy-search subdirs (with eza preview)
kill <Tab>                   # fuzzy-search processes
```

---

## zoxide — smarter `cd`

Tracks dirs you visit. Jump by partial name.

```bash
cd ~/Documents/code/terminal-setup    # first time, do it normally
# ... later:
z terminal           # jumps to ~/Documents/code/terminal-setup
z ter set            # multiple keywords, scored
z -                  # last directory
zi                   # interactive picker via fzf
```

Database lives at `~/.local/share/zoxide/db.zo`. Inspect: `zoxide query --list --score`.

---

## atuin — shell history with full-text search

Replaces Ctrl+R. Local-only in this setup (no cloud sync).

```bash
# Ctrl+R                                fuzzy fullscreen search (default)
atuin search docker                  # CLI search
atuin search --cwd .                 # only commands run in current dir
atuin search --exit 0 build          # only successful runs
atuin search --before '1 hour ago' deploy
atuin stats                          # top commands, total runs
atuin status                         # session info

# Filters in interactive UI:
#   Tab cycles filter mode (Global / Host / Session / Directory)
#   Ctrl+R cycles search mode (Fuzzy / Prefix / Exact)
```

History DB: `~/.local/share/atuin/history.db`. Migration from zsh history was done at bootstrap.

---

## fnm — fast Node version manager

Replaces nvm. Reads `.nvmrc` / `.node-version` automatically (with `--use-on-cd`, already enabled).

```bash
fnm list                         # installed versions
fnm list-remote                  # all available
fnm install 22.20.0              # install
fnm install --lts                # latest LTS
fnm use 20.11.0                  # switch in current shell
fnm default 22.20.0              # set default version
fnm current                      # active version

# Auto-switch on cd: just have a .nvmrc file
echo "20.11.0" > .nvmrc
cd .                             # fnm auto-switches
```

`.nvmrc` files from old projects work as-is.

---

## starship — prompt

Already loaded. Config at `~/.config/starship.toml` (symlink to repo).

```bash
starship preset --list           # list named presets
starship preset gruvbox-rainbow > ~/.config/starship.toml  # try a preset
starship explain                 # why each module is showing
starship timings                 # find slow modules
starship config <key> <val>      # set without editing TOML
```

To hide a module: add `[<module>]\ndisabled = true` to the toml.

---

## delta — git diff viewer

Already wired in via `~/.gitconfig` (`core.pager = delta`).

```bash
git diff                  # uses delta automatically
git log -p                # paged with delta
git show HEAD             # delta-styled

# CLI use (file-vs-file)
delta a.txt b.txt
diff -u a.txt b.txt | delta

# Toggle side-by-side from gitconfig:
#   git config --global delta.side-by-side false
```

Already configured: `side-by-side = true`, `navigate = true` (use `n`/`N` to jump between files in pager).

---

## stow — manage dotfiles

This repo uses it. Day-to-day:

```bash
cd ~/Documents/code/terminal-setup/stow

# (Re)apply a module — symlinks into $HOME
stow --target=$HOME zsh

# Update after adding files (idempotent re-link)
stow --restow --target=$HOME zsh

# Remove symlinks (preserve files in repo)
stow --delete --target=$HOME zsh

# All modules at once
stow --restow --target=$HOME zsh starship ghostty git

# Dry-run
stow -n -v --target=$HOME zsh
```

Conflicts: stow refuses if a real (non-symlink) file exists at the target. `bootstrap.sh` handles this by renaming to `*.pre-stow.<ts>`.

---

## zinit — zsh plugin manager

Loaded inside `.zshrc`. To add a plugin:

```bash
# In stow/zsh/.zshrc:
zinit light user/repo                  # github plugin (oh-my-zsh-style load)
zinit snippet OMZP::docker             # OMZ plugin (lazy snippet)
zinit snippet OMZL::git.zsh            # OMZ library
zinit ice wait lucid; zinit light foo/bar  # lazy-load (after prompt)

# CLI ops
zinit update                # update all
zinit times                 # plugin load times (debug slow startup)
zinit unload user/repo      # remove without restart
zinit self-update           # update zinit itself
```

---

## ghostty — terminal emulator

Config: `~/.config/ghostty/config` (symlinked from repo).

```bash
# Keybinds (already configured)
Cmd+T          new tab
Cmd+N          new window
Cmd+D          split right
Cmd+Shift+D    split down
Cmd+W          close pane/tab
Cmd+[ / Cmd+]  switch panes
Cmd+Left/Right  beginning/end of line (zsh-aware)
Option+Left/Right  word jump
Shift+Enter    newline (don't submit)
Cmd+K          clear scrollback

# Reload config without restart
Cmd+Shift+,    open config in editor
Cmd+Shift+R    reload config
```

CLI: `ghostty +list-themes`, `ghostty +show-config`.

---

## RVM — Ruby version manager (kept authoritative)

```bash
rvm list                       # installed
rvm install 3.3.0
rvm use 3.2.3 --default        # set default (already set)
rvm gemset list
rvm gemset create myproj
rvm use 3.2.3@myproj --create  # ruby + isolated gemset
echo "3.2.3" > .ruby-version   # auto-switch on cd
```

Loaded last in `.zshrc`. Don't mix with rbenv (this repo uses RVM only).

---

## pyenv — Python version manager

```bash
pyenv versions                 # installed
pyenv install 3.12.0
pyenv global 3.12.0            # default
pyenv local 3.11.0             # writes .python-version
pyenv shell 3.12.0             # one shell only
pyenv which python             # resolve current
```

For per-project deps: pair with `python -m venv .venv && source .venv/bin/activate`.

---

## SDKMAN — JDK / Maven / Gradle / etc.

Loaded last in `.zshrc` per its requirement.

```bash
sdk list java                  # candidates
sdk install java 21.0.2-tem    # Temurin
sdk use java 21.0.2-tem        # this shell
sdk default java 21.0.2-tem    # default
sdk current java
sdk env init                   # write .sdkmanrc — auto-switch on cd
```

---

## platform.sh / fly CLI

```bash
platform login
platform project:list
platform environment:push
p ssh                          # alias

fly auth login
fly apps list
fly deploy
```

---

## gh — GitHub CLI

```bash
gh auth login
gh repo clone alexandrebignalet/terminal-setup
gh pr create --fill
gh pr view --web
gh pr checkout 42              # check out PR #42 locally
gh issue list --assignee @me
gh run watch                   # follow CI run
gh api /repos/:owner/:repo     # raw API
```

---

## git aliases (loaded via OMZ git plugin)

201 aliases active. Most-used:

```bash
gst                git status
gss                git status -s
gco <branch>       git checkout
gcb <branch>       git checkout -b
gcm                git checkout main/master (auto-detected)
gcmsg "msg"        git commit -m
gcam "msg"         git commit -am
gca!               git commit --amend
gcan!              git commit --amend --no-edit
gp                 git push
gpf!               git push --force (with leases — careful)
gl                 git pull
gup                git pull --rebase
gloga              git log --oneline --decorate --graph --all
gd                 git diff
gds                git diff --staged
ga                 git add
gaa                git add --all
gb                 git branch
gbd                git branch -d
gba                git branch --all
gsta               git stash push
gstp               git stash pop
grb                git rebase
grbi               git rebase -i
grbm               git rebase main
gm                 git merge
gf                 git fetch
gfa                git fetch --all --prune
gcl                git clone
g                  git
```

Full list: `alias | rg '^g[a-z]'` (or `alias | grep '^g[a-z]'`).

---

## Combos (this is where it pays off)

```bash
# Open fuzzy-picked file in vim, with bat preview
vim "$(fd -t f | fzf --preview 'bat --color=always {}')"

# Fuzzy-checkout git branch
git checkout "$(git branch -a | fzf | tr -d ' *' | sed 's|remotes/origin/||')"

# rg → fzf → bat
rg --line-number . | fzf --delimiter=: --preview 'bat --color=always --highlight-line {2} {1}'

# Kill a process by name
kill -9 "$(ps -A -o pid,command | fzf | awk '{print $1}')"

# Jump to a recent dir + open editor
z terminal && code .

# Fuzzy-select a Node version
fnm use "$(fnm list | fzf | tr -d ' *')"
```
