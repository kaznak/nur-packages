{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

# Temporary fork of kepano/defuddle with the `develop` branch applied
# (= `feat/cli-url-flag` + `feat/cli-extractor-arg` merged), while
# https://github.com/kepano/defuddle reviews the upstream PRs. Switch back
# to the upstream package once both feature PRs are merged.
buildNpmPackage rec {
  pname = "defuddle";
  version = "0.19.0-unstable-2026-06-25";

  src = fetchFromGitHub {
    owner = "kaznak";
    repo = "defuddle";
    rev = "0c378ef68247c507b9b54871b458fb8d4c744523";
    hash = "sha256-BksKb9Oz8Lz/guLZU8WLnw1DH+jZTEcV9gXmcsABx1k=";
  };

  npmDepsHash = "sha256-3YxwAyrQrxU0ADjyuQmOpxGRtJ9HgTDubvhH8Tr4aCA=";

  meta = with lib; {
    description = "Extract article content and metadata from web pages (CLI/library)";
    homepage = "https://github.com/kaznak/defuddle/tree/develop";
    license = licenses.mit;
    mainProgram = "defuddle";
  };
}
