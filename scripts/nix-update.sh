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
  local extra_args=()
  # doorstop は poetry2nix 経由で build され、その評価が pyproject.toml を src から
  # readFile する (IFD)。加えて mkPoetryApplication の meta.position が poetry2nix の
  # default.nix を指すため、nix-update が「flake 内に無い」と sanitizePositions で
  # 弾く。--src-only で重い eval を skip し、--override-filename で正しい更新先を
  # 明示する (doorstop は cargoDeps 等の追加成果物を持たないため src 更新だけで十分)。
  case "$pkg" in
    doorstop)
      extra_args+=(--src-only --override-filename pkgs/github-doorstopdev-doorstop.nix)
      ;;
  esac
  echo "=== nix-update $pkg ${extra_args[*]} ==="
  nix run nixpkgs#nix-update -- --flake "$pkg" "${extra_args[@]}"
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
