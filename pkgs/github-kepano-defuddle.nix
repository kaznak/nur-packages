{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "defuddle";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "kepano";
    repo = "defuddle";
    rev = version;
    hash = "sha256-DtGfAu+Yv9AZVPXdf/UA0Fk2252v+WhznPyYNVCE3sQ=";
  };

  npmDepsHash = "sha256-3YxwAyrQrxU0ADjyuQmOpxGRtJ9HgTDubvhH8Tr4aCA=";

  meta = with lib; {
    description = "Extract article content and metadata from web pages (CLI/library)";
    homepage = "https://github.com/kepano/defuddle";
    license = licenses.mit;
    mainProgram = "defuddle";
  };
}
