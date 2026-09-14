{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-trafilatura";
  version = "2.2.1";
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
    hash = "sha256-kI9wA057fxl/JRrUDtxnfi3+Se57+WGwar/cyMKy0F8=";
  };
  vendorHash = "sha256-Gfni7o37q0TQkN0qbQCRkg6PJkKwQgXMZZkZwJ8DUkU=";
  subPackages = [ "cmd/go-trafilatura" ];
}
