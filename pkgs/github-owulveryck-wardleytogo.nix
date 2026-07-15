{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "wardleytogo";
  version = "1.15.1";
  meta = with lib; {
    description = "wtg2svg: render Wardley maps written in the WTG2 DSL to SVG";
    homepage = "https://github.com/owulveryck/wardleyToGo";
    license = licenses.mit; # MIT
    mainProgram = "wtg2svg";
  };
  src = fetchFromGitHub {
    owner = "owulveryck";
    repo = "wardleyToGo";
    rev = "v${version}";
    hash = "sha256-821Fzn1cZZUhejbesnX8qLHMNoWmKPVGZqPSARkWUdg=";
  };
  # wardleyToGo は標準ライブラリのみに依存し外部モジュールを vendor しないため null。
  vendorHash = null;
  subPackages = [ "cmd/wtg2svg" ];
}
