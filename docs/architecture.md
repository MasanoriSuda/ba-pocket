# Architecture (PoC)

## 1. 概要
本PoCはFlutterでiOS/Androidの共通アプリとして、端末内のみで完結する構成とする。外部APIは使用せず、匿名データを端末内に保存する。

## 2. テクノロジースタック（案）
- UI: Flutter
- 言語: Dart
- 状態管理: 最小構成（StatefulWidget/ChangeNotifier等）
- データ保存: Hive（EventLog含む端末内保存）
- 依存管理: pub (Flutter/Dart)
- テスト: flutter_test（可能な範囲）

※PoCのため、採用は最短で動く選択を優先する。

## 3. システム構成
```mermaid
flowchart LR
  App[Flutter App (iOS/Android)] --> Storage[Local Storage]
```

## 4. アーキテクチャ方針
- 画面/UIとロジックを分離（MVVM相当）
- ルールベースの判断ロジックを小さく保つ
- 将来のAPI連携に備え、データアクセスはRepository層で抽象化

## 5. データ保存方針
- 端末内保存のみ
- 個人情報は保存しない
- 削除はユーザー操作で行える
- EventLogはHiveに保存し、KPIは端末内で集計する

## 6. 技術的制約と要件
- ネットワーク通信を前提としない
- iOS 16以降 / Android 8以降を想定（仮）

## 7. パフォーマンス要件
- 画面遷移は1秒以内
- 問診から結果表示まで3秒以内

## 8. セキュリティ要件
- PIIを取得しない
- 端末内のみで完結
- 受診誘導の注意書きを必ず表示

## 9. 開発ツールと手法
- Flutter SDK
- Android Studio / VS Code（いずれか）
- Xcode（iOSビルド用）
- GitHub（またはGit運用）
- 簡易な手動テストを優先
