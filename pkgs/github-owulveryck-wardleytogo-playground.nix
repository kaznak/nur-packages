{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchurl,
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

  # index.html が cdnjs から読んでいた CodeMirror 5.65.18 の全アセットを
  # ベンダリングして CDN 依存を除去する（供給網方針: 完全ローカル化）。
  # 各アセットは fetchurl で sha256 ピン留めし、site 合成時に
  # vendor/codemirror/5.65.18/<相対パス> へ配置する。相対パスは cdnjs の
  # URL 末尾（ajax/libs/codemirror/5.65.18/ 以降）をそのまま踏襲するので、
  # index.html の書き換えは前置ドメインの一括置換だけで済む。
  codemirrorVersion = "5.65.18";
  codemirrorBase = "https://cdnjs.cloudflare.com/ajax/libs/codemirror/${codemirrorVersion}";
  # { <相対パス> = <sha256>; } の対応表。相対パスは vendor 配置先にもなる。
  codemirrorAssets = {
    "codemirror.min.css" = "sha256-EQdxEqtpVdKf5BCFxiNlx9Si8ApXDHR14q7CqMvIX8Q=";
    "addon/hint/show-hint.min.css" = "sha256-8OouEuq9DQ9BBiMCFRG7+dDlSBw0MeKeOAqh7z6IZZo=";
    "codemirror.min.js" = "sha256-XfTZceJK6kg7+O1bSOAm84BnkkNu8psSSK73x1TRYfk=";
    "addon/mode/simple.min.js" = "sha256-nDHRUACt/yrJnswCXqPfJLq/wASmPe7KnKlGpJHR3U4=";
    "addon/hint/show-hint.min.js" = "sha256-RjgUvfIeSYWJBHPEQk9p6xUOENCBfetufNrUqzef01I=";
    "addon/display/placeholder.min.js" = "sha256-YOAtF4Drijwzf51lrzIpxec5AsB+IezotoI++4OZDvI=";
  };
  # 各アセットの fetchurl derivation。
  codemirrorFetched = lib.mapAttrs (
    relPath: sha256:
    fetchurl {
      url = "${codemirrorBase}/${relPath}";
      inherit sha256;
    }
  ) codemirrorAssets;
  # installPhase 内で vendor/ へ配置する cp 群を生成する。
  codemirrorInstall = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (relPath: drv: ''
      install -Dm644 ${drv} "$out/vendor/codemirror/${codemirrorVersion}/${relPath}"
    '') codemirrorFetched
  );

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

      # ベンダリングした CodeMirror アセットを vendor/ 以下へ配置。
      ${codemirrorInstall}

      # index.html の CDN 参照をローカル相対パスへ書き換える。
      #  1. <link>/<script> の cdnjs URL 前置ドメインを vendor/ へ置換
      #     （相対パス末尾は vendor 配置先と一致しているのでこれだけで解決）。
      #  2. preconnect / dns-prefetch の cdnjs ヒント行を削除（外部参照の残骸）。
      substituteInPlace $out/index.html \
        --replace-fail '${codemirrorBase}/' 'vendor/codemirror/${codemirrorVersion}/'
      sed -i '/rel="preconnect" href="https:\/\/cdnjs.cloudflare.com"/d' $out/index.html
      sed -i '/rel="dns-prefetch" href="https:\/\/cdnjs.cloudflare.com"/d' $out/index.html

      # --- 書き換え漏れ検出（機械化ゲート）---
      # served される全ファイルからロード系の外部 URL を検出したら fail。
      # 対象: <script src=... http>, <link href=... http>, @import http,
      #       url(http...), fetch(...http...), import ... http... 。
      # クォート文字はまとめて任意 1 文字 . で許容する形にする（Nix の
      # 二重シングルクォート文字列内に生の single quote を書けないため）。
      # 非ロード系（コメント・GitHub ドキュメントリンク等）は許容する。
      if grep -rEn \
        -e '<(script|link)[^>]+(src|href)=.?https?://' \
        -e '@import[[:space:]]+.?https?://' \
        -e 'url\(.?https?://' \
        -e 'fetch\(.?https?://' \
        $out/index.html $out/app.js $out/wasm_exec.js; then
        echo "ERROR: load-bearing external URL still present after vendoring" >&2
        exit 1
      fi
      # cdnjs への参照が一切残っていないことも確認（ヒント行の消し漏れ検出）。
      if grep -rn 'cdnjs.cloudflare.com' $out/index.html $out/app.js $out/wasm_exec.js; then
        echo "ERROR: cdnjs reference still present after vendoring" >&2
        exit 1
      fi
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
