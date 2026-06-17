{
  description = "kaznak's NUR (Nix User Repository) packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        nurPkgs = import ./default.nix { inherit pkgs; };
      in
      {
        # `nix build .#eye` などで個別ビルドできる。
        packages = nurPkgs;

        # `nix flake check` 相当の軽い動作確認用。
        legacyPackages = nurPkgs;

        formatter = pkgs.nixfmt;
      }
    )
    // {
      # NUR / overlay 経由で `pkgs.nur.repos.kaznak.<name>` のように使うため。
      overlays.default = final: prev: import ./default.nix { pkgs = final; };
    };
}
