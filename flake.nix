{
  description = "kaznak's NUR (Nix User Repository) packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";

    # doorstop 専用。cython 0.29 系の依存で nixpkgs 24.11 / Python 3.12 系が必須なため、
    # 24.11 系 nixpkgs と対応する poetry2nix を flake input として固定する。
    # default.nix からは外しているので NUR overlay には乗らないが、flake 経由
    # (`nix build .#doorstop`) では従来通り build できる。
    nixpkgs_24_11.url = "github:nixos/nixpkgs/50ab793786d9de88ee30ec4e4c24fb4236fc2674";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/ce2369db77f45688172384bbeb962bc6c2ea6f94";
      inputs.nixpkgs.follows = "nixpkgs_24_11";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs_24_11,
      poetry2nix,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgs_24_11 = import nixpkgs_24_11 { inherit system; };
        poetry2nixInstance = import poetry2nix { pkgs = pkgs_24_11; };
        nurPkgs = import ./default.nix { inherit pkgs; };
        doorstop = pkgs.callPackage ./pkgs/github-doorstopdev-doorstop.nix {
          poetry2nix = poetry2nixInstance;
        };
      in
      {
        # `nix build .#eye` などで個別ビルドできる。
        # doorstop は default.nix には無いが flake outputs には含めるので、
        # flake 経由のアクセス (`nix build .#doorstop`) は維持される。
        packages = nurPkgs // { inherit doorstop; };

        # `nix flake check` 相当の軽い動作確認用。
        legacyPackages = nurPkgs // { inherit doorstop; };

        # `nix develop` で just / nix-update などの開発ツールを揃える。
        devShells.default = import ./devshell.nix { inherit pkgs; };

        formatter = pkgs.nixfmt;
      }
    )
    // {
      # NUR / overlay 経由で `pkgs.nur.repos.kaznak.<name>` のように使うため。
      # default.nix を見るので doorstop は overlay には載らない（意図通り）。
      overlays.default = final: prev: import ./default.nix { pkgs = final; };
    };
}
