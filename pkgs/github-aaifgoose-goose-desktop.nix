{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
}:

# 旧 block/goose は aaif-goose/goose へリダイレクトされる（org 名変更で同一リポジトリ）。
# リダイレクトが将来切れても良いよう、URL は正準名 aaif-goose/goose を使う。
let
  version = "1.29.1";

  src = fetchurl {
    url = "https://github.com/aaif-goose/goose/releases/download/v${version}/goose_${version}_amd64.deb";
    sha256 = "1fwkcqhhqcd655x3bggbj4kl99i971c1spavikavp65gn61q7x29";
  };

  runtimeLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
  ];
in

stdenv.mkDerivation {
  pname = "goose-desktop";
  inherit version;
  inherit src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = runtimeLibs;

  dontWrapGApps = true;

  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar x --no-same-permissions --no-same-owner
  '';

  installPhase = ''
    mkdir -p $out/lib/goose
    cp -r usr/lib/goose/* $out/lib/goose/

    mkdir -p $out/bin
    makeWrapper $out/lib/goose/Goose $out/bin/goose-desktop \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --add-flags "--no-sandbox"

    mkdir -p $out/share/applications
    substitute usr/share/applications/goose.desktop $out/share/applications/goose-desktop.desktop \
      --replace-fail "/usr/lib/goose/Goose" "$out/bin/goose-desktop" \
      --replace-fail "Name=Goose" "Name=Goose Desktop"

    mkdir -p $out/share/pixmaps
    cp usr/share/pixmaps/goose.png $out/share/pixmaps/goose-desktop.png
  '';

  meta = with lib; {
    description = "Goose AI agent desktop application";
    homepage = "https://github.com/aaif-goose/goose";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "goose-desktop";
  };
}
