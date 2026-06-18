# Development shell used by `nix develop` (and `flake.nix` wires it in).
# Hands the repo's helper scripts (scripts/) the tools they assume on PATH.
{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    just
    nix-update
    nixfmt
    shellcheck
  ];
}
