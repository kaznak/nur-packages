{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mantra";
  version = "0.9.0";
  meta = with lib; {
    description = "Manuels ANforderungs-TRAcing (Managed Tracing)";
    homepage = "https://github.com/mhatzl/mantra";
    license = licenses.mit; # MIT
  };
  src = fetchFromGitHub {
    owner = "mhatzl";
    repo = "mantra";
    rev = "v${version}";
    hash = "sha256-iRs3ffCSKUI+Yh7pmckR7rvFcAZPedmAJQ3Rk2METhs=";
  };
  # mantra は cargo.lock をリポジトリに含んでいないので cargoHash を指定する
  cargoHash = "sha256-olUNu3hY/vOtLuYYVStLC6GCGH6pw4JmcgEOxBYSIw0=";
  # buildRustPackage は既定で release ビルド (buildType = "release") のため、
  # release では debug_assertions が無効になり debug_assert! 系が展開されない。
  # mantra 0.8.1 の usage テストは debug_assert 系の panic を期待するので、
  # テスト (checkPhase) だけ debug プロファイルで実行して debug_assertions を有効化する。
  checkType = "debug";
}
