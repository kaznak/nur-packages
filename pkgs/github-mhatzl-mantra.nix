{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "mantra";
  version = "0.7.8";
  meta = with lib; {
    description = "Manuels ANforderungs-TRAcing (Managed Tracing)";
    homepage = "https://github.com/mhatzl/mantra";
    license = licenses.mit; # MIT
  };
  src = fetchFromGitHub {
    owner = "mhatzl";
    repo = "mantra";
    rev = "v${version}";
    hash = "sha256-WSUiLVcMBQxi7OdBgu7SRojDz4VnV4VGJxyoGIBMjyQ=";
  };
  # mantra は cargo.lock をリポジトリに含んでいないので cargoHash を指定する
  cargoHash = "sha256-5cMPSgN+Ijn0wLv2vsJ5TnGcp+VXbH9f216KEPbXiY4=";
}
