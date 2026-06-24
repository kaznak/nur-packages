# Development shell used by `nix develop` (and `flake.nix` wires it in).
# Provides the tools that `Justfile` recipes and ad-hoc nur-packages.json
# inspection assume on PATH.
{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    jq
    just
    nix-update
    nixfmt
  ];
}
