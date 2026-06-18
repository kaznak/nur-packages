#!/bin/bash
# Refresh a flake package via nix-update.
# Usage:
#   scripts/nix-update.sh              # update every package in NIX_UPDATE_PACKAGES
#   scripts/nix-update.sh <package>    # update the named package only
set -euo pipefail

here="$(dirname -- "$(readlink -f -- "$0")")"
# shellcheck source=lib.sh
. "$here/lib.sh"

update_one() {
  local pkg="$1"
  echo "=== nix-update $pkg ==="
  nix run nixpkgs#nix-update -- --flake "$pkg"
}

if [ "$#" -gt 0 ]; then
  update_one "$1"
else
  failed=()
  for pkg in "${NIX_UPDATE_PACKAGES[@]}"; do
    if ! update_one "$pkg"; then
      failed+=("$pkg")
    fi
  done
  if [ "${#failed[@]}" -gt 0 ]; then
    printf '\nFailed: %s\n' "${failed[*]}" >&2
    exit 1
  fi
fi
