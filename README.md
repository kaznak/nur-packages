# nur-packages

[NUR (Nix User Repository)](https://github.com/nix-community/NUR) として公開する
kaznak のパッケージ集。nixpkgs に存在しない / 自前ビルドしているツールをまとめる。

## 収録パッケージ

定義は `pkgs/` 配下、エントリは `default.nix` / `flake.nix`。

| attribute | 説明 | 方式 |
|---|---|---|
| `git-appraise-web` | git-appraise の Web UI | buildGoModule |
| `mantra` | 要求トレーシングツール (Managed Tracing) | buildRustPackage |
| `eye` | EYE reasoner (RDF/N3/RDFS/OWL の推論エンジン) | mkDerivation (swi-prolog) |
| `goose` | block/goose AI エージェント CLI | fetchurl バイナリ |
| `goose-desktop` | goose のデスクトップアプリ | .deb 展開 |
| `pi-coding-agent` | pi - 最小構成のターミナルコーディングエージェント | buildNpmPackage |
| `doorstop` | バージョン管理による要求管理 | poetry2nix (pin: nixpkgs 24.11) |

## 使い方

### flake から (public / NUR 登録後)

```nix
{
  inputs.nur-kaznak.url = "github:kaznak/nur-packages";

  # 例: home-manager の packages で
  # home.packages = [ inputs.nur-kaznak.packages.${system}.eye ];
}
```

### flake から (private repo / SSH)

private リポジトリのまま使う場合は `git+ssh://` で参照する:

```nix
inputs.nur-kaznak = {
  url = "git+ssh://git@github.com/kaznak/nur-packages";
  inputs.nixpkgs.follows = "nixpkgs";
};
# extraSpecialArgs.nurPkgs = nur-kaznak.packages.${system};
# home.packages = [ nurPkgs.eye ];
```

### NUR 経由 (登録後)

```nix
# overlay として
nixpkgs.overlays = [ nur.overlays.default ];
# -> pkgs.nur.repos.kaznak.eye などで参照
```

### 個別ビルド

```sh
nix build .#eye
nix-build -A eye        # non-flake
```

## CI / NUR 登録

`ci.nix` がビルド対象を列挙する。NUR への登録は
[nix-community/NUR](https://github.com/nix-community/NUR) の `repos.json` に
1 エントリ追加する PR を出す。
