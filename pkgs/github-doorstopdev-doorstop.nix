/*
  doorstop は依存ライブラリ (cython 0.29 系) の都合で新しい Python では建たず、
  nixpkgs 24.11 系 (Python 3.12) でビルドする必要がある。
  呼び出し側は 24.11 で構成した poetry2nix インスタンスを渡すこと:
  `poetry2nix = import <poetry2nix> { pkgs = <nixpkgs 24.11>; };`
  （本リポジトリでは default.nix が pin 済みの 24.11 / poetry2nix を注入する）

  nix-update の特殊事情:
  (1) poetry2nix の mkPoetryApplication は pyproject.toml を src から readFile する
      ため、nix-update の eval が source derivation の realize を要求する (IFD)。
      fresh CI runner では未 realize で eval が落ちるので、事前に `nix build` で
      source を store に入れる必要がある。
  (2) mkPoetryApplication の meta.position が poetry2nix 内 default.nix を指すため、
      nix-update の sanitizePositions で「flake 内に無い」と弾かれる。
      --override-filename で更新先を明示する必要がある。
  これらの設定は nur-packages.json (repo root) の doorstop エントリに集約され
  (`nixUpdatePreBuild`, `nixUpdateExtraArgs`)、.github/workflows/update.yml の
  matrix 経由で workflow 側が解釈する。
*/

{
  lib,
  poetry2nix,
  fetchFromGitHub,
  stdenv,
}:

poetry2nix.mkPoetryApplication {
  pname = "doorstop-bin";
  meta = with lib; {
    description = "Requirements management using version control";
    homepage = "https://github.com/doorstop-dev/doorstop";
    license = licenses.lgpl3Only; # LGPL3.0
  };
  projectDir = fetchFromGitHub {
    owner = "doorstop-dev";
    repo = "doorstop";
    rev = "v3.2";
    hash = "sha256-Ph2K5qKGn/AfmI3Hmy2PRQz7E3rL0Y6FEabRWVaIKxA=";
  };
  preferWheels = true; # It was too difficult to build >_<.
  overrides = poetry2nix.defaultPoetryOverrides.extend (
    self: super: {
      macfsevents = if stdenv.isLinux then null else super.macfsevents;
      pync = if stdenv.isLinux then null else super.pync;
    }
  );
}
