{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

# Temporary fork of kepano/defuddle with the `feat/cli-url-flag` branch applied,
# while https://github.com/kepano/defuddle reviews the upstream PR. Switch back
# to the upstream package once merged.
buildNpmPackage rec {
  pname = "defuddle";
  version = "0.19.0-unstable-2026-06-18";

  src = fetchFromGitHub {
    owner = "kaznak";
    repo = "defuddle";
    rev = "958dd733e66b8c88bbab07022fc01c8f7e693bba";
    hash = "sha256-3t9Zw/PbGWrXXiks8x845P3vUX+DRYtaxVhyz2RJNsM=";
  };

  npmDepsHash = "sha256-3YxwAyrQrxU0ADjyuQmOpxGRtJ9HgTDubvhH8Tr4aCA=";

  meta = with lib; {
    description = "Extract article content and metadata from web pages (CLI/library)";
    homepage = "https://github.com/kaznak/defuddle/tree/feat/cli-url-flag";
    license = licenses.mit;
    mainProgram = "defuddle";
  };
}
