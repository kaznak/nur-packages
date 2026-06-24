#!/bin/bash
# Build flake packages on the current system.
# Usage:
#   scripts/build.sh              # build every package in nur-packages.json
#   scripts/build.sh <package>    # build the named package only
set -euo pipefail

here="$(dirname -- "$(readlink -f -- "$0")")"
config="$here/../nur-packages.json"

if [ "$#" -gt 0 ]; then
  exec nix build --print-build-logs ".#$1"
fi

args=()
while IFS= read -r pkg; do
  args+=(".#$pkg")
done < <(jq -r 'keys[]' "$config")
exec nix build --print-build-logs "${args[@]}"
