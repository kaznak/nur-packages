# Run via `nix develop -c just <recipe>` (or enter the shell with
# `nix develop` first, then call `just`).
#
# Per-package update args are listed in nur-packages.json; for special
# packages pass them as extra args, e.g.:
#   just update doorstop --src-only --override-filename pkgs/github-doorstopdev-doorstop.nix
# Automated updates (cron / workflow_dispatch) read nur-packages.json and
# pass these args via the matrix in .github/workflows/update.yml.

# Show available recipes.
default:
    @just --list

# Refresh a single package via nix-update.
update PKG *ARGS:
    nix run nixpkgs#nix-update -- --flake {{ PKG }} {{ ARGS }}

# Build a single package.
build PKG:
    nix build --print-build-logs .#{{ PKG }}

# Format every .nix file in the tree.
fmt:
    nix fmt -- $(git ls-files '*.nix')

# Run `nix flake check` (builds every flake output for the current system).
check:
    nix flake check --print-build-logs
