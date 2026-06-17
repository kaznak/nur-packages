# CI でビルドする対象を列挙する。broken / unfree を正しくマークしておくと
# キャッシュ可能なものだけがビルドされる。NUR テンプレート準拠。
{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = lib.isDerivation;
  isBuildable = p: !(p.meta.broken or false) && (p.meta.license.free or true);
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: lib.isAttrs p && (p.recurseForDerivations or false);

  flattenPkgs =
    s:
    let
      f =
        _name: value:
        if shouldRecurseForDerivations value then
          flattenPkgs value
        else if isDerivation value then
          [ value ]
        else
          [ ];
    in
    lib.concatLists (lib.mapAttrsToList f s);

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs = flattenPkgs (lib.filterAttrs (n: v: !isReserved n && isDerivation v) nurAttrs);
in
{
  buildPkgs = lib.filter (p: isBuildable p && isCacheable p) nurPkgs;
}
