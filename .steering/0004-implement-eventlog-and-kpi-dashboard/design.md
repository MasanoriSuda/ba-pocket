# Design (0004 Implement EventLog and KPI Dashboard)

## 1. 実装アプローチ
- EventLogはHiveに保存する
- KPI一覧は端末内で集計し、最小構成の一覧表示にする
- 0003で定義したKPI算出ルールとEventLog仕様に準拠する

## 2. 変更するコンポーネント
### 2.1 Data
- EventLogモデル（Hive）
- EventLogRepository（保存/取得）
- KPI集計サービス（ローカル集計）

### 2.2 UI
- KPI一覧画面
- KPI一覧への導線（Homeまたは設定）
- 任意: データリセット（端末内削除）ボタン

## 3. データ構造（EventLog）
### 3.1 必須フィールド
- user_id
- session_id
- consultation_id
- timestamp
- event_type

### 3.2 主要フィールド（例）
- consultation_abandoned: step_index, elapsed_ms
- products_registered: count, categories_summary
- recommendation_generated: recommendation_id
- recommendation_viewed: recommendation_id, selected_categories, skipped_categories, safety_level
- recommendation_executed: status (all/partial/none), selected_product_ids
- followup_submitted: result (improved/same/worse), notes_length

## 4. KPI算出設計
### 4.1 対象期間
- 直近14日（rolling 14 days）をデフォルト
- 全期間は任意で切替可能（PoCでは最小）

### 4.2 集計ルール
- 同一 consultation_id の重複イベントは初回のみ採用
- KPIの母集団は consultation_started を1回以上発生させた user_id
- 2回目利用率は初回 recommendation_viewed 到達者を母集団とする

### 4.3 表示形式
- 率KPIは「値（%）＋分子/分母」を併記
- 数値KPI（平均値）は小数1桁で表示

## 5. 画面仕様（最小）
- KPIカード一覧
  - KPI名
  - 値（% or 平均値）
  - 分子/分母（率KPIのみ）
  - 対象期間（直近14日）
- 任意: データリセットボタン（確認ダイアログ付き）

## 6. リスクと回避策
- 集計のブレ → 0003の集計ルールを固定で実装
- イベント欠落 → recommendationGenerated/viewed を分離して切り分け可能にする
- 端末内のみで確認しづらい → KPI一覧に分子/分母を表示
