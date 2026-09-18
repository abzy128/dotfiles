# Keep terminal word movement from being interpreted as Escape in vi insert mode.
bindkey -M viins $'\e[1;5D' backward-word
bindkey -M viins $'\e[1;5C' forward-word
bindkey -M viins $'\e[5D' backward-word
bindkey -M viins $'\e[5C' forward-word

zsh_clipboard_copy() {
    (( $+commands[wl-copy] )) && printf %s "$CUTBUFFER" | wl-copy
}

zsh-yank-clipboard() {
    zle vi-yank
    zsh_clipboard_copy
}
zle -N zsh-yank-clipboard

zsh-yank-line-clipboard() {
    zle vi-yank-whole-line
    zsh_clipboard_copy
}
zle -N zsh-yank-line-clipboard

zsh-paste-after-clipboard() {
    (( $+commands[wl-paste] )) && CUTBUFFER=$(wl-paste --no-newline 2>/dev/null)
    zle vi-put-after
}
zle -N zsh-paste-after-clipboard

zsh-paste-before-clipboard() {
    (( $+commands[wl-paste] )) && CUTBUFFER=$(wl-paste --no-newline 2>/dev/null)
    zle vi-put-before
}
zle -N zsh-paste-before-clipboard

bindkey -M vicmd y zsh-yank-clipboard
bindkey -M vicmd Y zsh-yank-line-clipboard
bindkey -M vicmd p zsh-paste-after-clipboard
bindkey -M vicmd P zsh-paste-before-clipboard
bindkey -M visual y zsh-yank-clipboard
