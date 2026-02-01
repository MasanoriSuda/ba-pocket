# Repository Structure

## 1. 目的
本リポジトリのフォルダ・ファイル構成と配置ルールを定義する。

## 2. ディレクトリ構成（案）
```
.
├─ docs/                     # 設計・仕様ドキュメント
├─ .steering/                # 作業単位のドキュメント
├─ lib/                      # Flutterアプリ本体
│  ├─ app/                   # アプリ起点（App/Route/Theme）
│  ├─ features/              # 画面/機能単位
│  ├─ domain/                # ドメインロジック
│  ├─ data/                  # 永続化/リポジトリ
│  └─ shared/                # 共通UI/ユーティリティ
├─ assets/                   # 画像・フォント等
├─ test/                     # 単体テスト
├─ android/                  # Androidビルド設定
├─ ios/                      # iOSビルド設定
├─ pubspec.yaml
└─ README.md
```

## 3. ディレクトリの役割
- `docs/`：永続的ドキュメント
- `.steering/`：作業単位のドキュメント
- `lib/`：Flutterアプリの実装

## 4. ファイル配置ルール
- 画面/機能は `lib/features/` 配下にまとめる
- ルールベースの判断ロジックは `lib/domain/` に配置
- 永続化は `lib/data/` に配置
- 共通UI/ユーティリティは `lib/shared/`
- 画像・フォントは `assets/` に置き、`pubspec.yaml` で管理する

## 5. 命名規則（概要）
- UpperCamelCase（Dartの型）
- lowerCamelCase（関数/変数）
- lower_snake_case（ファイル/ディレクトリ名）

## 6. 追加ルール
- `docs/` と `.steering/` の運用は `AGENTS.md` に従う
