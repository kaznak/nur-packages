# NUR (Nix User Repository) entry point.
#
# 慣例どおり `{ pkgs ? import <nixpkgs> {} }` を受け取り、パッケージの attrset を返す。
# 各パッケージは `pkgs` だけで解決する。
#
# 注意: doorstop は cython 0.29 系の依存により nixpkgs 24.11 / Python 3.12 系 pin が必要で、
# `default.nix` に置くと NUR の eval (`default.nix` 直接 eval) で eval-time fetch
# (`builtins.fetchTarball` で 24.11 系 pkgs/poetry2nix を取得) を引き起こす。NUR の登録要件
# (外部 URL アクセスは `pkgs.fetch*` のみ) と合わないため、doorstop は `flake.nix` 側に
# 隔離してある。結果として:
#   - NUR overlay 経由 (`pkgs.nur.repos.kaznak.doorstop`) では使えない
#   - non-flake (`nix-build -A doorstop`) でも使えない
#   - flake 経由 (`nix build .#doorstop` / `inputs.nur-kaznak.packages.${system}.doorstop`)
#     では従来通り build できる
{
  pkgs ? import <nixpkgs> { },
}:
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
  wardleytogo = pkgs.callPackage ./pkgs/github-owulveryck-wardleytogo.nix { };
  wtg-playground = pkgs.callPackage ./pkgs/github-owulveryck-wardleytogo-playground.nix { };
}
