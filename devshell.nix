# Development shell used by `nix develop` (and `flake.nix` wires it in).
# Hands the repo's helper scripts (scripts/) the tools they assume on PATH.
{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    jq
    just
    nix-update
    nixfmt
    shellcheck
  ];
}
