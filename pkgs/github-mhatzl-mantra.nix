{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mantra";
  version = "0.2.14";
  meta = with lib; {
    description = "Manuels ANforderungs-TRAcing (Managed Tracing)";
    homepage = "https://github.com/mhatzl/mantra";
    license = licenses.mit; # MIT
  };
  src = fetchFromGitHub {
    owner = "mhatzl";
    repo = "mantra";
    rev = "v${version}";
    hash = "sha256-RLUdvpqBA++Gij7OvTtNw+miGP2BSD2CsnjcuYUNR4E=";
  };
  # mantra は cargo.lock をリポジトリに含んでいないので cargoHash を指定する
  cargoHash = "sha256-evPaXtpzc2k2TPeBwS4uH0E2o2/tGfrG9y5/KmWcqo8=";
}
