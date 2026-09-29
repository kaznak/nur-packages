{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  makeWrapper,
}:

# TOPDON TC001 (および InfiRay P2 Pro 等の同系統 UVC サーモカメラ) の
# 熱画像を表示するビューア。上流は単一の Python スクリプトで、CLI 名は付いていない。
#
# Usage:
#   pythermalcamera --device 0   # デバイス番号は v4l2-ctl --list-devices で調べる
#   スナップショット (p) と録画 (r/t) はカレントディレクトリに書き出される。
#
# 上流は 2023-07 で更新が止まっていてタグも無いので、コミットに固定している。

let
  # 既定の opencv4 は GUI 無しでビルドされていて (getBuildInformation の GUI: NONE)
  # cv2.imshow が動かない。GTK3 付きでキャッシュにあるのは opencv4Full だけなので
  # それを使う (enableGtk3 だけの override はキャッシュに無くソースビルドになる)。
  pythonEnv = python3.withPackages (ps: [
    ps.opencv4Full
    ps.numpy
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "pythermalcamera";
  version = "0-unstable-2023-07-11";

  src = fetchFromGitHub {
    owner = "leswright1977";
    repo = "PyThermalCamera";
    rev = "b19821a1a25e081594c666022a3d64e2b9cf41cc";
    hash = "sha256-G1kYpCayxqqzOnnMh0BHYvWIBXGXnBUIai63rcz1dZE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # OpenCV 4.13 の cap.set() は bool を受け付けない
  # (TypeError: Argument 'value' must be double, not bool)。
  # Raspberry Pi 側の分岐と同じ 0.0 に揃える。
  postPatch = ''
    substituteInPlace src/tc001v4.2.py \
      --replace-fail 'cap.set(cv2.CAP_PROP_CONVERT_RGB, False)' 'cap.set(cv2.CAP_PROP_CONVERT_RGB, 0.0)'

    # NumPy 2 (NEP 50) では uint8 のスカラーに Python の int を掛けても広がらず、
    # lo*256 が OverflowError になる。温度計算に入る uint8 の値を int にしておく。
    substituteInPlace src/tc001v4.2.py \
      --replace-fail 'hi = thdata[96][128][0]' 'hi = int(thdata[96][128][0])' \
      --replace-fail 'lo = thdata[96][128][1]' 'lo = int(thdata[96][128][1])' \
      --replace-fail 'lomax = thdata[...,1].max()' 'lomax = int(thdata[...,1].max())' \
      --replace-fail 'himax = thdata[mcol][mrow][0]' 'himax = int(thdata[mcol][mrow][0])' \
      --replace-fail 'lomin = thdata[...,1].min()' 'lomin = int(thdata[...,1].min())' \
      --replace-fail 'himin = thdata[lcol][lrow][0]' 'himin = int(thdata[lcol][lrow][0])'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 src/tc001v4.2.py $out/share/pythermalcamera/tc001v4.2.py
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/pythermalcamera \
      --add-flags $out/share/pythermalcamera/tc001v4.2.py
    runHook postInstall
  '';

  meta = with lib; {
    description = "Thermal image viewer for the TOPDON TC001 (and InfiRay P2 Pro class) UVC thermal cameras";
    homepage = "https://github.com/leswright1977/PyThermalCamera";
    license = licenses.asl20;
    mainProgram = "pythermalcamera";
    platforms = platforms.linux;
  };
}
