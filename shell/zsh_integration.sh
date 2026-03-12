# natl integration for Zsh
# Add to ~/.zshrc:
#   source /path/to/natl/shell/zsh_integration.sh
#
# Usage: same as Bash; Ctrl+G converts the line (with or without "natl " prefix).

NATL_BIN="${NATL_BIN:-$HOME/bin/natl}"

natl() {
    local cmd
    cmd=$("$NATL_BIN" "$*") || return $?
    [[ -z "$cmd" ]] && return 1
    echo "$cmd"
}

_natl_widget() {
    local input cmd
    input="$BUFFER"
    [[ -z "$input" ]] && return 0
    if [[ "$input" == natl\ * ]]; then
        input="${input#natl }"
    fi
    cmd=$("$NATL_BIN" "$input") || return $?
    [[ -z "$cmd" ]] && return 1
    BUFFER="$cmd"
    CURSOR=${#BUFFER}
}

zle -N _natl_widget
bindkey '^g' _natl_widget
