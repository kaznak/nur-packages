{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

# Temporary fork of kepano/defuddle with the `develop` branch applied
# (= `feat/cli-url-flag` + `feat/cli-extractor-arg` + `feat/cli-debug-output`
# + `feat/cli-remove-toggles` merged, on top of upstream main), while
# https://github.com/kepano/defuddle reviews the upstream PRs. Switch back
# to the upstream package once the feature PRs are merged.
buildNpmPackage rec {
  pname = "defuddle";
  version = "0.19.1-unstable-2026-06-26";

  src = fetchFromGitHub {
    owner = "kaznak";
    repo = "defuddle";
    rev = "5f4f879c2bf41691612c6f1e2e60da8ee0647e3c";
    hash = "sha256-d+uBKNzzrk3Fgqf6yRvhZodE7p/81UQggqMbOxnn9HU=";
  };

  npmDepsHash = "sha256-quqWhbcaSNj4Bk++4N4LYq3Y8U5nQqnwc+MqU0LLgso=";

  meta = with lib; {
    description = "Extract article content and metadata from web pages (CLI/library)";
    homepage = "https://github.com/kaznak/defuddle/tree/develop";
    license = licenses.mit;
    mainProgram = "defuddle";
  };
}
