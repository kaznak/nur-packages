{
  lib,
  stdenv,
  fetchFromGitHub,
  swi-prolog,
  makeWrapper,
}:

# EYE (Euler Yet another proof Engine) は nixpkgs に存在しないため自前でビルドする。
# 上流の install.sh と同じく、swipl で saved state (eye.pvm) を生成し、
# `swipl -x eye.pvm -- "$@"` で起動するラッパーを作成する。
stdenv.mkDerivation rec {
  pname = "eye";
  version = "11.24.4";

  src = fetchFromGitHub {
    owner = "eyereasoner";
    repo = "eye";
    rev = "v${version}";
    hash = "sha256-DKpKu1ELN68Wfd6MoAE3nWU414MoukEZRInUQB96sWU=";
  };

  nativeBuildInputs = [
    swi-prolog
    makeWrapper
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    swipl -q -f eye.pl -g main -- --quiet --image eye.pvm
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib" "$out/bin" "$out/share/eye"
    cp eye.pvm "$out/lib/eye.pvm"
    # saved state はビルドに使った swipl と同一バージョンが実行時に必要なので
    # store path で固定する。
    makeWrapper ${swi-prolog}/bin/swipl "$out/bin/eye" \
      --add-flags "-x $out/lib/eye.pvm --"

    # `reasoning/` は upstream の de facto standard rule library（rpo/, rdfs/,
    # owl/, blogic/ 等の topic 別 N3 rule files。owl:sameAs の symmetric/
    # transitive axiom も `reasoning/rpo/owl-sameAs.n3` に canonical に定義
    # されている）。上流の意図としては eye 本体と一緒に配布して命令行 load する
    # 想定なので、$out/share/eye/reasoning に同梱する（downstream から
    # ''${eye}/share/eye/reasoning/<topic>/<rule>.n3 で参照可能）。
    cp -r reasoning "$out/share/eye/reasoning"
    runHook postInstall
  '';

  meta = with lib; {
    description = "EYE: a reasoning engine supporting RDF, N3, RDFS and OWL (Euler Yet another proof Engine)";
    homepage = "https://github.com/eyereasoner/eye";
    license = licenses.mit;
    mainProgram = "eye";
    platforms = platforms.unix;
  };
}
