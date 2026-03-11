#!/usr/bin/env bash
# Build the .deb package. Run from the project root (or from this script's directory).
# Requires: build-essential, debhelper (apt install build-essential debhelper)

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

if ! command -v dpkg-buildpackage &>/dev/null; then
  echo "dpkg-buildpackage not found. Install build dependencies:" >&2
  echo "  sudo apt install build-essential debhelper" >&2
  exit 1
fi

echo "Building .deb ..."
dpkg-buildpackage -us -uc -b

DEB=$(ls -t ../natl_*_all.deb 2>/dev/null | head -1)
if [[ -n "$DEB" ]]; then
  echo ""
  echo "Built: $DEB"
  echo "Install: sudo dpkg -i $DEB"
fi
