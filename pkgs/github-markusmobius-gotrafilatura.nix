{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-trafilatura";
  version = "2.0.0";
  meta = with lib; {
    description = "Go port of trafilatura: web text extraction CLI/library";
    homepage = "https://github.com/markusmobius/go-trafilatura";
    license = licenses.asl20; # Apache-2.0
    mainProgram = "go-trafilatura";
  };
  src = fetchFromGitHub {
    owner = "markusmobius";
    repo = "go-trafilatura";
    rev = "v${version}";
    hash = "sha256-EC4A+shwTCz8fZceB2GIqXmAAgnUph6sQYIlF6al/lQ=";
  };
  vendorHash = "sha256-qqiC1k4PNM4oZpGIeapT9qrCQcXJDO15KHuw6J6B70k=";
  subPackages = [ "cmd/go-trafilatura" ];
}
