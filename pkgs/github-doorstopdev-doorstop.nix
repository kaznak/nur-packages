/*
  doorstop は依存ライブラリ (cython 0.29 系) の都合で新しい Python では建たず、
  nixpkgs 24.11 系 (Python 3.12) でビルドする必要がある。
  呼び出し側は 24.11 で構成した poetry2nix インスタンスを渡すこと:
  `poetry2nix = import <poetry2nix> { pkgs = <nixpkgs 24.11>; };`
  （本リポジトリでは default.nix が pin 済みの 24.11 / poetry2nix を注入する）
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
    rev = "v3.1";
    hash = "sha256-qHY3a/o25e4WONPnF4YoQQW+zAQ/4FShlP99S+zJbys=";
  };
  preferWheels = true; # It was too difficult to build >_<.
  overrides = poetry2nix.defaultPoetryOverrides.extend (
    self: super: {
      macfsevents = if stdenv.isLinux then null else super.macfsevents;
      pync = if stdenv.isLinux then null else super.pync;
    }
  );
}
