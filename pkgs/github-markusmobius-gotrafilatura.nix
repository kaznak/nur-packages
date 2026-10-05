{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-trafilatura";
  version = "2.2.6";
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
    hash = "sha256-fJ7oRk3rHQTSt2kGOsRHwZ97y0E6mrStsNwnm+HfeKo=";
  };
  vendorHash = "sha256-V02V9vxtFVwj/KKc0166bS4OWVg5RiSj9j13Gm0iLcA=";
  subPackages = [ "cmd/go-trafilatura" ];
}
