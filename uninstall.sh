#!/usr/bin/env bash
#
# Desinstala natl: quita el enlace de ~/bin y elimina la integración del shell.
#

set -e

NATL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN_DIR="${HOME}/bin"
MARKER_START="# --- natl integration (install.sh)"
MARKER_END="# --- end natl"

usage() {
    cat <<EOF
Uso: $0 [OPCIONES]

Desinstala natl: elimina ~/bin/natl y quita la integración de .bashrc/.zshrc.

Opciones:
  --no-shell   No tocar .bashrc ni .zshrc (solo quitar el binario)
  -h, --help   Mostrar esta ayuda
EOF
}

REMOVE_SHELL=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-shell) REMOVE_SHELL=false; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Opción desconocida: $1" >&2; exit 1 ;;
    esac
done

# Quitar binario
if [[ -L "${BIN_DIR}/natl" ]] || [[ -f "${BIN_DIR}/natl" ]]; then
    rm -f "${BIN_DIR}/natl"
    echo "Eliminado: ${BIN_DIR}/natl"
else
    echo "No se encontró ${BIN_DIR}/natl"
fi

remove_from_rc() {
    local rc_file="$1"
    [[ -f "$rc_file" ]] || return 0

    if ! grep -qF "$MARKER_START" "$rc_file" 2>/dev/null; then
        return 0
    fi

    # Eliminar el bloque entre los marcadores (comparación por cadena fija)
    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        index($0, start) > 0 { skip=1; next }
        skip && index($0, end) > 0 { skip=0; next }
        !skip { print }
    ' "$rc_file" > "${rc_file}.tmp" && mv "${rc_file}.tmp" "$rc_file"
    echo "  Eliminada integración de $rc_file"
}

if $REMOVE_SHELL; then
    echo "Quitando integración del shell..."
    remove_from_rc "${HOME}/.bashrc"
    remove_from_rc "${HOME}/.zshrc"
fi

echo "Desinstalación completada."
