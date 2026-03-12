# natl integration for Bash
# Add to ~/.bashrc:
#   source /path/to/natl/shell/bash_integration.sh
#
# Usage:
#   - Type "natl list files" and press Ctrl+G → the line is replaced by the command.
#   - Type "list files" and press Ctrl+G → same.
#   - From another terminal: natl list files  (prints the command to copy/paste).

NATL_BIN="${NATL_BIN:-$HOME/bin/natl}"

# Function: natl <text> → replace current line with the command (when invoked from the widget)
# If run as a normal command, prints the command to stdout.
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

# Widget: convert current line to command (Ctrl+G)
# If the line starts with "natl ", only the rest is passed to the LLM.
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
