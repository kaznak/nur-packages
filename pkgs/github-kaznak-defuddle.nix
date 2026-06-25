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
    rev = "cba0806b247f49f759bfaf0a33d9924c5edfeca9";
    hash = "sha256-YWyU3XC7EKfXS1FTFxMwGz2CZIXRa8GfGl0U7T8ZAgU=";
  };

  npmDepsHash = "sha256-3YxwAyrQrxU0ADjyuQmOpxGRtJ9HgTDubvhH8Tr4aCA=";

  meta = with lib; {
    description = "Extract article content and metadata from web pages (CLI/library)";
    homepage = "https://github.com/kaznak/defuddle/tree/develop";
    license = licenses.mit;
    mainProgram = "defuddle";
  };
}
