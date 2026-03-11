# Integración de natl con Bash
# Añade a ~/.bashrc:
#   source /ruta/a/natl/shell/bash_integration.sh
#
# Uso:
#   - Escribir "natl listar archivos" y pulsar Ctrl+G → la línea se sustituye por el comando.
#   - Escribir "listar archivos" y pulsar Ctrl+G → igual.
#   - Desde otra terminal: natl listar archivos  (imprime el comando para copiar/pegar).

NATL_BIN="${NATL_BIN:-$HOME/bin/natl}"

# Función: natl <texto> → reemplaza la línea actual por el comando (cuando se invoca desde el widget)
# Si se ejecuta como comando normal, imprime el comando en stdout.
natl() {
    local cmd
    cmd=$("$NATL_BIN" "$*") || return $?
    [[ -z "$cmd" ]] && return 1
    if [[ -n "${READLINE_LINE+set}" ]]; then
        READLINE_LINE="$cmd"
        READLINE_POINT=${#READLINE_LINE}
    else
        echo "$cmd"
    fi
}

# Widget: convertir línea actual en comando (Ctrl+G)
# Si la línea empieza por "natl ", se pasa solo el resto al LLM.
_natl_widget() {
    local input cmd
    input="$READLINE_LINE"
    [[ -z "$input" ]] && return 0
    if [[ "$input" == natl\ * ]]; then
        input="${input#natl }"
    fi
    cmd=$("$NATL_BIN" "$input") || return $?
    [[ -z "$cmd" ]] && return 1
    READLINE_LINE="$cmd"
    READLINE_POINT=${#READLINE_LINE}
}

bind -x '"\C-g":_natl_widget'
