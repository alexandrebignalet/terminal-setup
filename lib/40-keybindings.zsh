# macOS-native + Ghostty-friendly key bindings.

# Shift+Enter inserts a newline (matches Warp behavior)
shift-enter-newline() { LBUFFER+=$'\n'; }
zle -N shift-enter-newline
bindkey '^[[27;2;13~' shift-enter-newline

# Option+Left/Right — word jump (Ghostty sends these escape sequences)
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[b'     backward-word
bindkey '^[f'     forward-word

# Cmd+Left/Right — line start/end (Ghostty maps Cmd+arrows to Home/End)
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Cmd+Backspace — delete to line start
bindkey '^U' backward-kill-line

# Option+Backspace — delete previous word
bindkey '^[^?' backward-kill-word
