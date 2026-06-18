{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc-unwrapped,
  libgcc,
}:

# 旧 block/goose は aaif-goose/goose へリダイレクトされる（org 名変更で同一リポジトリ）。
# リダイレクトが将来切れても良いよう、URL は正準名 aaif-goose/goose を使う。
let
  version = "1.38.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/aaif-goose/goose/releases/download/v${version}/goose-x86_64-unknown-linux-gnu.tar.bz2";
      sha256 = "sha256-Mp0RlV9hQ9htu4VQxieNkhgZiD8sqhmAIEuCfFBa0og=";
    };
    aarch64-linux = {
      url = "https://github.com/aaif-goose/goose/releases/download/v${version}/goose-aarch64-unknown-linux-gnu.tar.bz2";
      sha256 = "0gjy08n3k05vbs04mn9w3h1az81s5ilx25fms0wnxnq9q5175jq9";
    };
  };

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation {
  pname = "goose";
  inherit version;

  src = fetchurl {
    inherit (src) url sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gcc-unwrapped # libgomp.so.1, libstdc++.so.6
    libgcc # libgcc_s.so.1
  ];

  unpackPhase = ''
    tar xjf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp goose $out/bin/goose
    chmod +x $out/bin/goose
  '';

  meta = with lib; {
    description = "An open-source AI agent that supercharges your software development";
    homepage = "https://github.com/aaif-goose/goose";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "goose";
  };
}
