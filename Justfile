# Run via `nix develop -c just <recipe>` (or enter the shell with
# `nix develop` first, then call `just`).

# Show available recipes.
default:
    @just --list

# Refresh one package (or all if PKG empty) via nix-update.
update PKG="":
    ./scripts/nix-update.sh {{ PKG }}

# Build one package (or all if PKG empty).
build PKG="":
    ./scripts/build.sh {{ PKG }}

# nix-update + build in sequence, for a single package or all.
refresh PKG="": (update PKG) (build PKG)

# Format every .nix file in the tree.
fmt:
    nix fmt -- $(git ls-files '*.nix')

# Run `nix flake check`.
check:
    nix flake check --print-build-logs
