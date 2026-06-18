#!/bin/bash
# Build flake packages on the current system.
# Usage:
#   scripts/build.sh              # build every package in PACKAGES
#   scripts/build.sh <package>    # build the named package only
set -euo pipefail

here="$(dirname -- "$(readlink -f -- "$0")")"
# shellcheck source=lib.sh
. "$here/lib.sh"

if [ "$#" -gt 0 ]; then
  exec nix build --print-build-logs ".#$1"
fi

args=()
for pkg in "${PACKAGES[@]}"; do
  args+=(".#$pkg")
done
exec nix build --print-build-logs "${args[@]}"
