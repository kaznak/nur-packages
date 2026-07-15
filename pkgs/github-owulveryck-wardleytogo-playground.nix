{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  go,
  python3,
  writeShellApplication,
}:

let
  pname = "wtg-playground";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "owulveryck";
    repo = "wardleyToGo";
    rev = "v${version}";
    hash = "sha256-821Fzn1cZZUhejbesnX8qLHMNoWmKPVGZqPSARkWUdg=";
  };

  # WTG2 playground の WebAssembly バイナリを GOOS=js GOARCH=wasm でビルドする。
  # wardleyToGo は標準ライブラリのみ依存なので vendorHash = null。
  wasm = buildGoModule {
    pname = "wtg-playground-wasm";
    inherit version src;
    vendorHash = null;
    # exp/ui/wasm は js/wasm build tag 付きなので GOOS/GOARCH を固定する。
    # buildGoModule は env.GOOS/GOARCH を go 由来の値で上書きするため
    # (build-support/go/module.nix: `env = args.env // { inherit (go) GOOS GOARCH; }`)、
    # env 経由では効かない。buildPhase の go build が読む環境変数を preBuild で export する。
    preBuild = ''
      export GOOS=js
      export GOARCH=wasm
    '';
    subPackages = [ "exp/ui/wasm" ];
    # GOOS=js GOARCH=wasm の成果物は $out/bin/js_wasm/wasm に置かれる
    # (stdenv 的には非クロスなので module.nix の js_wasm 正規化が走らない)。
    # これを main.wasm として据え、bin/ は畳む。
    postInstall = ''
      mkdir -p $out/share
      mv $out/bin/js_wasm/wasm $out/share/main.wasm
      rm -rf $out/bin
    '';
    # クロスコンパイル成果物なので実行不可・strip 無効・test 無効。
    doCheck = false;
    dontStrip = true;
    dontFixup = true;
    meta = {
      description = "WTG2 playground WebAssembly artifact";
      homepage = "https://github.com/owulveryck/wardleyToGo";
      license = lib.licenses.mit;
    };
  };

  # exp/ui の静的アセット (index.html, app.js, favicon) + main.wasm +
  # Go 配布物の wasm_exec.js を合成した静的サイト。静的配信のみで動作する。
  site = stdenv.mkDerivation {
    pname = "wtg-playground-site";
    inherit version src;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp exp/ui/index.html exp/ui/app.js $out/
      cp exp/ui/favicon.ico exp/ui/favicon-16.png exp/ui/favicon-32.png $out/
      cp ${wasm}/share/main.wasm $out/main.wasm
      cp ${go}/share/go/lib/wasm/wasm_exec.js $out/wasm_exec.js
      runHook postInstall
    '';
    meta = {
      description = "WTG2 playground static site (index.html + main.wasm + wasm_exec.js)";
      homepage = "https://github.com/owulveryck/wardleyToGo";
      license = lib.licenses.mit;
    };
  };

  # 一発起動ラッパ。静的サイトを配信し URL を表示、xdg-open があればブラウザを開く。
  app = writeShellApplication {
    name = pname;
    runtimeInputs = [ python3 ];
    text = ''
            port=18080
            while [ $# -gt 0 ]; do
              case "$1" in
                --port)
                  port="$2"
                  shift 2
                  ;;
                --port=*)
                  port="''${1#*=}"
                  shift
                  ;;
                -h | --help)
                  echo "Usage: ${pname} [--port PORT]"
                  echo "Serve the WTG2 Wardley Map playground (default port 18080)."
                  exit 0
                  ;;
                *)
                  # 位置引数としても port を受け付ける。
                  port="$1"
                  shift
                  ;;
              esac
            done

            url="http://localhost:''${port}/"
            echo "WTG2 playground: ''${url}"
            echo "Press Ctrl-C to stop."
            if command -v xdg-open >/dev/null 2>&1; then
              ( sleep 1 && xdg-open "''${url}" >/dev/null 2>&1 || true ) &
            fi
            # main.wasm を application/wasm で返せるよう mime を明示する。
            exec python3 -c '
      import http.server, sys
      port = int(sys.argv[1])
      directory = sys.argv[2]
      handler = http.server.SimpleHTTPRequestHandler
      handler.extensions_map[".wasm"] = "application/wasm"
      class H(handler):
          def __init__(self, *a, **k):
              super().__init__(*a, directory=directory, **k)
      http.server.ThreadingHTTPServer(("", port), H).serve_forever()
      ' "''${port}" "${site}"
    '';
    meta = {
      description = "Launch the WTG2 Wardley Map playground (static site + WebAssembly)";
      homepage = "https://github.com/owulveryck/wardleyToGo";
      license = lib.licenses.mit;
      mainProgram = pname;
    };
  };
in
app
// {
  # 中間成果物を passthru しておくと個別に nix build .#wtg-playground.site 等で検査できる。
  inherit wasm site;
}
