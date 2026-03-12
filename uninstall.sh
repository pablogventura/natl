#!/usr/bin/env bash
#
# Uninstall natl: remove the ~/bin link and shell integration.
#

set -e

NATL_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN_DIR="${HOME}/bin"
MARKER_START="# --- natl integration (install.sh)"
MARKER_END="# --- end natl"

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Uninstall natl: remove ~/bin/natl and integration from .bashrc/.zshrc.

Options:
  --no-shell   Do not touch .bashrc or .zshrc (remove binary only)
  -h, --help   Show this help
EOF
}

REMOVE_SHELL=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-shell) REMOVE_SHELL=false; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Quitar binario
if [[ -L "${BIN_DIR}/natl" ]] || [[ -f "${BIN_DIR}/natl" ]]; then
    rm -f "${BIN_DIR}/natl"
    echo "Removed: ${BIN_DIR}/natl"
else
    echo "Not found: ${BIN_DIR}/natl"
fi

remove_from_rc() {
    local rc_file="$1"
    [[ -f "$rc_file" ]] || return 0

    if ! grep -qF "$MARKER_START" "$rc_file" 2>/dev/null; then
        return 0
    fi

    # Remove the block between markers (fixed string comparison)
    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        index($0, start) > 0 { skip=1; next }
        skip && index($0, end) > 0 { skip=0; next }
        !skip { print }
    ' "$rc_file" > "${rc_file}.tmp" && mv "${rc_file}.tmp" "$rc_file"
    echo "  Removed integration from $rc_file"
}

if $REMOVE_SHELL; then
    echo "Removing shell integration..."
    remove_from_rc "${HOME}/.bashrc"
    remove_from_rc "${HOME}/.zshrc"
fi

echo "Uninstall completed."
