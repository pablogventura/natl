#!/usr/bin/env bash
#
# Instala natl: enlaza el script en ~/bin y opcionalmente añade la integración al shell.
#

set -e

NATL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN_DIR="${HOME}/bin"
MARKER_START="# --- natl integration (install.sh)"
MARKER_END="# --- end natl"

usage() {
    cat <<EOF
Uso: $0 [OPCIONES]

Instala natl en ~/bin y opcionalmente configura la integración en tu shell.

Opciones:
  --bash          Añadir integración solo a ~/.bashrc
  --zsh           Añadir integración solo a ~/.zshrc
  --all           Añadir integración a .bashrc y .zshrc (por defecto)
  --no-shell      No modificar .bashrc ni .zshrc (solo instalar el binario)
  -h, --help      Mostrar esta ayuda
EOF
}

DO_BASH=false
DO_ZSH=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --bash)   DO_BASH=true; shift ;;
        --zsh)    DO_ZSH=true; shift ;;
        --all)    DO_BASH=true; DO_ZSH=true; shift ;;
        --no-shell) shift; break ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Opción desconocida: $1" >&2; exit 1 ;;
    esac
done

# Por defecto instalar en ambos si no se dijo nada
if ! $DO_BASH && ! $DO_ZSH; then
    DO_BASH=true
    DO_ZSH=true
fi

mkdir -p "$BIN_DIR"
ln -sf "${NATL_DIR}/natl" "${BIN_DIR}/natl"
echo "Instalado: ${BIN_DIR}/natl -> ${NATL_DIR}/natl"

add_to_rc() {
    local rc_file="$1"
    local shell_name="$2"
    local source_file="$3"

    [[ -f "$rc_file" ]] || touch "$rc_file"

    if grep -qF "$MARKER_START" "$rc_file" 2>/dev/null; then
        echo "  $rc_file: ya contenía la integración de natl, no se duplica."
        return 0
    fi

    cat >> "$rc_file" <<EOF

$MARKER_START
export NATL_BIN="${BIN_DIR}/natl"
source "${NATL_DIR}/shell/${source_file}"
$MARKER_END
EOF
    echo "  Añadida integración a $rc_file"
}

if ! $DO_BASH && ! $DO_ZSH; then
    echo "Para usar natl en el prompt (Ctrl+G), añade a tu ~/.bashrc o ~/.zshrc:"
    echo "  export NATL_BIN=\"${BIN_DIR}/natl\""
    echo "  source \"${NATL_DIR}/shell/bash_integration.sh\"   # o zsh_integration.sh para zsh"
    exit 0
fi

echo "Configurando shell..."
$DO_BASH && add_to_rc "${HOME}/.bashrc" "bash" "bash_integration.sh"
$DO_ZSH  && add_to_rc "${HOME}/.zshrc" "zsh" "zsh_integration.sh"

echo ""
echo "Listo. Ejecuta 'source ~/.bashrc' o 'source ~/.zshrc' y prueba con:"
echo "  natl listar todos los archivos"
echo "  o escribe 'natl listar archivos' en el prompt y pulsa Ctrl+G."
