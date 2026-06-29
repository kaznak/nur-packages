# NUR (Nix User Repository) entry point.
#
# 慣例どおり `{ pkgs ? import <nixpkgs> {} }` を受け取り、パッケージの attrset を返す。
# 各パッケージは原則 `pkgs` だけで解決する。例外は doorstop（下記）。
{
  pkgs ? import <nixpkgs> { },

  # 以下 2 つは doorstop 専用の pin（依存の都合で nixpkgs 24.11 系 / Python 3.12 が
  # 必須）。名前のとおり 24.11 でのみ使い、他パッケージは通常の `pkgs` で建てる。
  nixpkgs_24_11 ? builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/50ab793786d9de88ee30ec4e4c24fb4236fc2674.tar.gz";
    sha256 = "1s2gr5rcyqvpr58vxdcb095mdhblij9bfzaximrva2243aal3dgx";
  },
  poetry2nix_24_11 ? builtins.fetchTarball {
    url = "https://github.com/nix-community/poetry2nix/archive/ce2369db77f45688172384bbeb962bc6c2ea6f94.tar.gz";
    sha256 = "0xq52gq2920xnv7n8rchy3myxbijfpap8z0sd572ifla9dnpqzvi";
  },
}:
let
  # doorstop のビルドに使う 24.11 系の pkgs と poetry2nix インスタンス。
  pkgs_24_11 = import nixpkgs_24_11 { inherit (pkgs.stdenv.hostPlatform) system; };
  poetry2nixInstance_24_11 = import poetry2nix_24_11 { pkgs = pkgs_24_11; };
in
{
  defuddle = pkgs.callPackage ./pkgs/github-kaznak-defuddle.nix { };
  git-appraise-web = pkgs.callPackage ./pkgs/github-google-gitappraiseweb.nix { };
  go-trafilatura = pkgs.callPackage ./pkgs/github-markusmobius-gotrafilatura.nix { };
  mantra = pkgs.callPackage ./pkgs/github-mhatzl-mantra.nix { };
  eye = pkgs.callPackage ./pkgs/github-eyereasoner-eye.nix { };
  goose = pkgs.callPackage ./pkgs/github-aaifgoose-goose.nix { };
  goose-desktop = pkgs.callPackage ./pkgs/github-aaifgoose-goose-desktop.nix { };
  pi-coding-agent = pkgs.callPackage ./pkgs/pi-coding-agent.nix { };
  pdf-to-md = pkgs.callPackage ./pkgs/pdf-to-md.nix { };

  doorstop = pkgs.callPackage ./pkgs/github-doorstopdev-doorstop.nix {
    poetry2nix = poetry2nixInstance_24_11;
  };
}
