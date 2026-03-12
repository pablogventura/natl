#!/usr/bin/env bash
#
# Install natl: link the script to ~/bin and optionally add shell integration.
#

set -e

NATL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN_DIR="${HOME}/bin"
MARKER_START="# --- natl integration (install.sh)"
MARKER_END="# --- end natl"

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Install natl to ~/bin and optionally configure shell integration.

Options:
  --bash          Add integration only to ~/.bashrc
  --zsh           Add integration only to ~/.zshrc
  --all           Add integration to .bashrc and .zshrc (default)
  --no-shell      Do not modify .bashrc or .zshrc (install binary only)
  -h, --help      Show this help
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
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Default: install to both if nothing specified
if ! $DO_BASH && ! $DO_ZSH; then
    DO_BASH=true
    DO_ZSH=true
fi

mkdir -p "$BIN_DIR"
ln -sf "${NATL_DIR}/natl" "${BIN_DIR}/natl"
echo "Installed: ${BIN_DIR}/natl -> ${NATL_DIR}/natl"

add_to_rc() {
    local rc_file="$1"
    local shell_name="$2"
    local source_file="$3"

    [[ -f "$rc_file" ]] || touch "$rc_file"

    if grep -qF "$MARKER_START" "$rc_file" 2>/dev/null; then
        echo "  $rc_file: already had natl integration, not duplicating."
        return 0
    fi

    cat >> "$rc_file" <<EOF

$MARKER_START
export NATL_BIN="${BIN_DIR}/natl"
source "${NATL_DIR}/shell/${source_file}"
$MARKER_END
EOF
    echo "  Added integration to $rc_file"
}

if ! $DO_BASH && ! $DO_ZSH; then
    echo "To use natl in the prompt (Ctrl+G), add to your ~/.bashrc or ~/.zshrc:"
    echo "  export NATL_BIN=\"${BIN_DIR}/natl\""
    echo "  source \"${NATL_DIR}/shell/bash_integration.sh\"   # or zsh_integration.sh for zsh"
    exit 0
fi

echo "Configuring shell..."
$DO_BASH && add_to_rc "${HOME}/.bashrc" "bash" "bash_integration.sh"
$DO_ZSH  && add_to_rc "${HOME}/.zshrc" "zsh" "zsh_integration.sh"

echo ""
echo "Done. Run 'source ~/.bashrc' or 'source ~/.zshrc' and try:"
echo "  natl list all files"
echo "  or type 'natl list files' in the prompt and press Ctrl+G."
