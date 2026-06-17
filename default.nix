# NUR (Nix User Repository) entry point.
#
# 慣例どおり `{ pkgs ? import <nixpkgs> {} }` を受け取り、パッケージの attrset を返す。
# 各パッケージは原則 `pkgs` だけで解決する。例外は doorstop（下記）。
{
  pkgs ? import <nixpkgs> { },

  # doorstop 専用: 依存の都合で nixpkgs 24.11 系 (Python 3.12) が必須なので
  # 24.11 と poetry2nix を pin して自己完結させる（呼び出し側で上書きも可能）。
  nixpkgs_24_11 ? builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/50ab793786d9de88ee30ec4e4c24fb4236fc2674.tar.gz";
    sha256 = "1s2gr5rcyqvpr58vxdcb095mdhblij9bfzaximrva2243aal3dgx";
  },
  poetry2nix ? builtins.fetchTarball {
    url = "https://github.com/nix-community/poetry2nix/archive/ce2369db77f45688172384bbeb962bc6c2ea6f94.tar.gz";
    sha256 = "0xq52gq2920xnv7n8rchy3myxbijfpap8z0sd572ifla9dnpqzvi";
  },
}:
let
  # doorstop のビルドに使う 24.11 系の poetry2nix インスタンス。
  pkgs_24_11 = import nixpkgs_24_11 { inherit (pkgs.stdenv.hostPlatform) system; };
  poetry2nixInstance = import poetry2nix { pkgs = pkgs_24_11; };
in
{
  git-appraise-web = pkgs.callPackage ./pkgs/github-google-gitappraiseweb.nix { };
  mantra = pkgs.callPackage ./pkgs/github-mhatzl-mantra.nix { };
  eye = pkgs.callPackage ./pkgs/github-eyereasoner-eye.nix { };
  goose = pkgs.callPackage ./pkgs/github-aaifgoose-goose.nix { };
  goose-desktop = pkgs.callPackage ./pkgs/github-aaifgoose-goose-desktop.nix { };
  pi-coding-agent = pkgs.callPackage ./pkgs/pi-coding-agent.nix { };

  doorstop = pkgs.callPackage ./pkgs/github-doorstopdev-doorstop.nix {
    poetry2nix = poetry2nixInstance;
  };
}
