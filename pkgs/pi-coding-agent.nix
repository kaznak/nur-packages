{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  pixman,
  cairo,
  pango,
  giflib,
  libjpeg,
  python3,
  makeWrapper,
  nodejs,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.80.2";

  src = fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-mono";
    rev = "v${version}";
    hash = "sha256-aKtgPc3rwHEp856jP3N7nImph0CSG+gsWq9OVci3hmE=";
  };

  npmDepsHash = "sha256-oJB85gvo7ihlAbNPRAAv2EIhH2Wa/1PufDSOqoV+rXQ=";
  npmDepsFetcherVersion = 2;
  npmWorkspace = "packages/coding-agent";
  makeCacheWritable = true;

  nativeBuildInputs = [
    pkg-config
    python3
    makeWrapper
  ];
  buildInputs = [
    pixman
    cairo
    pango
    giflib
    libjpeg
  ];

  postPatch = ''
    substituteInPlace packages/ai/package.json \
      --replace-fail '"build": "npm run generate-models && npm run generate-image-models && tsgo -p tsconfig.build.json"' \
                     '"build": "tsgo -p tsconfig.build.json"'
  '';

  buildPhase = ''
    runHook preBuild
    npm run --workspace=packages/tui build
    npm run --workspace=packages/ai build
    npm run --workspace=packages/agent build
    npm run --workspace=packages/coding-agent build
    runHook postBuild
  '';

  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    local packageOut="$out/lib/node_modules/@mariozechner/pi-coding-agent"
    mkdir -p "$packageOut"

    cp -r packages/coding-agent/{dist,docs,examples,README.md,CHANGELOG.md} "$packageOut/"
    cp packages/coding-agent/package.json "$packageOut/"

    npm prune --omit=dev 2>/dev/null || true

    # Replace workspace symlinks with actual built content
    for ws in pi-agent-core:agent pi-ai:ai pi-tui:tui; do
      local pkg="''${ws%%:*}"
      local dir="''${ws##*:}"
      rm -rf "node_modules/@mariozechner/$pkg"
      mkdir -p "node_modules/@mariozechner/$pkg"
      cp -r "packages/$dir/dist" "node_modules/@mariozechner/$pkg/"
      cp "packages/$dir/package.json" "node_modules/@mariozechner/$pkg/"
    done

    cp -r node_modules "$packageOut/"

    # Remove broken symlinks (workspace packages pointing to packages/ that wasn't copied)
    find "$packageOut/node_modules" -type l ! -exec test -e {} \; -delete
    find "$packageOut/node_modules" -type d -empty -delete

    mkdir -p "$out/bin"
    makeWrapper ${nodejs}/bin/node "$out/bin/pi" \
      --add-flags "$packageOut/dist/cli.js" \
      --set PI_SKIP_VERSION_CHECK 1

    runHook postInstall
  '';

  meta = with lib; {
    description = "Pi - a minimal terminal coding agent";
    homepage = "https://pi.dev";
    license = licenses.mit;
    mainProgram = "pi";
  };
}
