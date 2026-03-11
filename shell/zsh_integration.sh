# Integración de natl con Zsh
# Añade a ~/.zshrc:
#   source /ruta/a/natl/shell/zsh_integration.sh
#
# Uso: igual que en Bash; Ctrl+G convierte la línea (con o sin prefijo "natl ").

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
