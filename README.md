# nur-packages

[NUR (Nix User Repository)](https://github.com/nix-community/NUR) として公開する
kaznak のパッケージ集。nixpkgs に存在しない / 自前ビルドしているツールをまとめる。

## 収録パッケージ

定義は `pkgs/` 配下、エントリは `default.nix` / `flake.nix`。

| attribute | 説明 | 方式 |
|---|---|---|
| `defuddle` | Web 本文抽出ツール (TypeScript, CLI 同梱) | buildNpmPackage |
| `git-appraise-web` | git-appraise の Web UI | buildGoModule |
| `go-trafilatura` | Web 本文抽出ツール (trafilatura の Go 移植) | buildGoModule |
| `mantra` | 要求トレーシングツール (Managed Tracing) | buildRustPackage |
| `eye` | EYE reasoner (RDF/N3/RDFS/OWL の推論エンジン) | mkDerivation (swi-prolog) |
| `goose` | block/goose AI エージェント CLI | fetchurl バイナリ |
| `goose-desktop` | goose のデスクトップアプリ | .deb 展開 |
| `pi-coding-agent` | pi - 最小構成のターミナルコーディングエージェント | buildNpmPackage |
| `doorstop` | バージョン管理による要求管理 | poetry2nix (pin: nixpkgs 24.11) |
| `wardleytogo` | wtg2svg - WTG2 DSL で書いた Wardley Map を SVG に変換する CLI | buildGoModule |
| `wtg-playground` | WTG2 playground (WebAssembly) を静的配信して開くラッパ (`wtg-playground [--port PORT]`)。CodeMirror を fetchurl でベンダリングし CDN 依存ゼロ | writeShellApplication + buildGoModule (GOOS=js GOARCH=wasm) + fetchurl |

## 使い方

### flake から (HTTPS, 推奨)

```nix
{
  inputs.nur-kaznak.url = "github:kaznak/nur-packages";

  # 例: home-manager の packages で
  # home.packages = [ inputs.nur-kaznak.packages.${system}.eye ];
}
```

### flake から (SSH 経由)

push 権限ホルダー向け、もしくは HTTPS が通らない環境向けの fallback:

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

## 開発 / メンテナンス

### レイヤ構成

| レイヤ | 役割 |
|---|---|
| `nur-packages.json` | 設定の単一情報源。パッケージ一覧と nix-update 用 per-package 設定 (`nixUpdate`, `nixUpdateExtraArgs`, `note`) |
| `.github/workflows/` | 自動化レイヤ。JSON を直接読んで matrix を組み、 `nix-update` / `nix build` を呼ぶ |
| `Justfile` | ローカル用の薄いショートカット。設定は読まず、コマンドを並べるだけ |
| `pkgs/` `default.nix` `flake.nix` `ci.nix` `devshell.nix` | nix 本体 |

ヘルパースクリプトは置かない（workflow と Justfile から直接 `nix-update` / `nix build` を呼ぶ）。

### ローカル運用

開発ツール (`just`, `nix-update`, `nixfmt`, `jq`) は `devshell.nix` にまとまっており、
`nix develop` で PATH に揃う。direnv (`nix-direnv` 推奨) を使っていればリポジトリに `cd`
した時点で `.envrc` (`use flake`) から自動で読み込まれる。

```sh
nix develop                                      # devshell に入る
just                                             # レシピ一覧
just update mantra                               # 単体パッケージを nix-update
just update doorstop --src-only \
  --override-filename pkgs/github-doorstopdev-doorstop.nix
                                                 # 特殊引数が要るパッケージは後ろに渡す
                                                 # (引数は nur-packages.json 参照)
just build mantra                                # 単体パッケージビルド
just fmt                                         # 全 .nix を nixfmt
just check                                       # nix flake check (= 全パッケージビルド)
```

### 全パッケージの自動更新

`.github/workflows/update.yml` が毎週月曜に `nur-packages.json` から `nixUpdate=true` な
パッケージを matrix 化し、各 entry の `nixUpdateExtraArgs` も matrix の値として流して
`nix-update` を呼ぶ。手動実行は `gh workflow run update.yml`（単体は `-f package=<name>`）。

## CI / NUR 登録

`ci.nix` がビルド対象を列挙する。`.github/workflows/ci.yml` は `nix flake check` 1 本で
flake outputs（全パッケージ）をビルドし、`update.yml` が自動更新 PR を出す（毎週月曜）。
NUR への登録は [nix-community/NUR](https://github.com/nix-community/NUR) の `repos.json`
に 1 エントリ追加する PR を出す。
