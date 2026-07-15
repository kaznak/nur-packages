{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mantra";
  version = "0.8.1";
  meta = with lib; {
    description = "Manuels ANforderungs-TRAcing (Managed Tracing)";
    homepage = "https://github.com/mhatzl/mantra";
    license = licenses.mit; # MIT
  };
  src = fetchFromGitHub {
    owner = "mhatzl";
    repo = "mantra";
    rev = "v${version}";
    hash = "sha256-xdQ8hVZqYCJWk9aZbcZinodFvsFv+i3zBeIYeQYQvxM=";
  };
  # mantra は cargo.lock をリポジトリに含んでいないので cargoHash を指定する
  cargoHash = "sha256-iwt+hIh6b3ypYIUZ7ZlM6JWN3dRnhr/HYp143nrZmeE=";
  # buildRustPackage は既定で release ビルド (buildType = "release") のため、
  # release では debug_assertions が無効になり debug_assert! 系が展開されない。
  # mantra 0.8.1 の usage テストは debug_assert 系の panic を期待するので、
  # テスト (checkPhase) だけ debug プロファイルで実行して debug_assertions を有効化する。
  checkType = "debug";
}
