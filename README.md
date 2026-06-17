# nur-packages

[NUR (Nix User Repository)](https://github.com/nix-community/NUR) として公開する
kaznak のパッケージ集。nixpkgs に存在しない / 自前ビルドしているツールをまとめる。

## 収録パッケージ

| attribute | 説明 |
|---|---|
| `git-appraise-web` | git-appraise の Web UI |
| `mantra` | 要求トレーシングツール (Managed Tracing) |
| `eye` | EYE reasoner (RDF/N3/RDFS/OWL の推論エンジン) |
| `goose` | block/goose AI エージェント CLI |
| `goose-desktop` | goose のデスクトップアプリ |
| `pi-coding-agent` | pi - 最小構成のターミナルコーディングエージェント |

## 使い方

### flake から

```nix
{
  inputs.nur-kaznak.url = "github:kaznak/nur-packages";

  # 例: home-manager の packages で
  # home.packages = [ inputs.nur-kaznak.packages.${system}.eye ];
}
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
