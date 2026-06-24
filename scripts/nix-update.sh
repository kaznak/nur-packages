#!/bin/bash
# Refresh a flake package via nix-update.
# Usage:
#   scripts/nix-update.sh              # update every package with nixUpdate=true
#   scripts/nix-update.sh <package>    # update the named package only
#
# Per-package configuration (including extra nix-update args) lives in
# nur-packages.json at the repo root. This script intentionally has no
# per-package knowledge.
set -euo pipefail

here="$(dirname -- "$(readlink -f -- "$0")")"
config="$here/../nur-packages.json"

update_one() {
  local pkg="$1"
  local extra_args=()
  while IFS= read -r arg; do
    extra_args+=("$arg")
  done < <(jq -r --arg p "$pkg" '.[$p].nixUpdateExtraArgs // [] | .[]' "$config")
  echo "=== nix-update $pkg ${extra_args[*]} ==="
  nix run nixpkgs#nix-update -- --flake "$pkg" "${extra_args[@]}"
}

if [ "$#" -gt 0 ]; then
  update_one "$1"
  exit
fi

failed=()
while IFS= read -r pkg; do
  if ! update_one "$pkg"; then
    failed+=("$pkg")
  fi
done < <(jq -r 'to_entries[] | select(.value.nixUpdate) | .key' "$config")

if [ "${#failed[@]}" -gt 0 ]; then
  printf '\nFailed: %s\n' "${failed[*]}" >&2
  exit 1
fi
