{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "git-appraise-web";
  version = "0.0.0-unstable-2021-04-02";
  meta = with lib; {
    description = "Web UI for git-appraise";
    homepage = "https://github.com/google/git-appraise-web";
    license = licenses.asl20; # Apache-2.0
  };
  src = fetchFromGitHub {
    owner = "google";
    repo = "git-appraise-web";
    # the commit hash of the master branch in 2021-04-02.
    # this hash is still the latest in 2026-01-23
    rev = "5cf242be17d4ea89bb17ea5b3e6a20e4d34d8435";
    hash = "sha256-qtOSTuvW0lBOQlwl/v6v8w8+Ia3w7pdMR+yHHWabDZk=";
  };
  vendorHash = "sha256-7JhHFaBaessek2XA6/6beFCtQ5LexhGeVLax7xS5DFE=";
}
