# shellcheck shell=bash
# Shared definitions for scripts/. Source this from other helpers.

# All packages produced by the flake.
PACKAGES=(
  defuddle
  git-appraise-web
  go-trafilatura
  mantra
  eye
  goose
  goose-desktop
  pi-coding-agent
  doorstop
)

# Subset refreshable by nix-update. git-appraise-web is pinned to a commit
# (no upstream tags) so it stays out of automated updates.
NIX_UPDATE_PACKAGES=(
  defuddle
  go-trafilatura
  mantra
  eye
  pi-coding-agent
  goose
  goose-desktop
  doorstop
)
