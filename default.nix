# NUR (Nix User Repository) entry point.
#
# 慣例どおり `{ pkgs ? import <nixpkgs> {} }` を受け取り、パッケージの attrset を返す。
# NUR の評価/ビルド bot はここを評価するので、各パッケージは `pkgs` だけで解決できること。
{
  pkgs ? import <nixpkgs> { },
}:
{
  git-appraise-web = pkgs.callPackage ./pkgs/github-google-gitappraiseweb.nix { };
  mantra = pkgs.callPackage ./pkgs/github-mhatzl-mantra.nix { };
  eye = pkgs.callPackage ./pkgs/github-eyereasoner-eye.nix { };
  goose = pkgs.callPackage ./pkgs/github-aaifgoose-goose.nix { };
  goose-desktop = pkgs.callPackage ./pkgs/github-aaifgoose-goose-desktop.nix { };
  pi-coding-agent = pkgs.callPackage ./pkgs/pi-coding-agent.nix { };

  # doorstop は poetry2nix + nixpkgs 24.11 に依存するため NUR には含めない。
  # home-manager 側で従来どおり pkgs/github-doorstopdev-doorstop.nix を直接 callPackage する。
}
