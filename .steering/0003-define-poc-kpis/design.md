# Design (0003 Define PoC KPIs)

## 1. 実装アプローチ
- ドキュメントでKPIとEventLog設計を確定し、実装者が迷わない状態にする
- 端末内保存のみの前提を維持し、イベントはローカルログとして保存する想定
- KPI → EventLog → 算出 → 目標 → 受け入れ条件の鎖が崩れないよう整理する

## 2. 変更する成果物
- `.steering/0003-define-poc-kpis/requirements.md`（KPI/イベント定義）
- `.steering/0003-define-poc-kpis/design.md`（設計）
- `.steering/0003-define-poc-kpis/tasklist.md`（作業タスク）

## 3. 設計方針
### 3.1 集計の一貫性
- `consultation_id` 単位で重複発火を除外する
- `user_id` は端末内生成UUIDとし、PoCでは跨ぎ集計を行わない

### 3.2 漏斗の可視化
- `consultation_started` → `consultation_completed` → `recommendation_viewed` → `recommendation_executed` の順で可視化する
- `recommendation_generated` を挟むことでロジック/表示の切り分けを可能にする

### 3.3 入力タイミングの固定
- 価値KPIは `recommendation_viewed` 直後または `followup_submitted` 時に取得し、比較可能性を担保

## 4. EventLog設計
### 4.1 必須フィールド
- `user_id`, `session_id`, `consultation_id`, `timestamp`, `event_type`

### 4.2 発火タイミング
- `consultation_started`: 問診1問目が表示された時点
- `consultation_completed`: 最終回答が確定した時点
- `recommendation_generated`: ルール判定完了・`recommendation_id` 確定時点
- `recommendation_viewed`: 結果画面の初回表示
- `recommendation_executed`: 実行状況（all/partial/none）の確定送信
- `followup_submitted`: 翌日フォロー結果の確定送信

### 4.3 主要フィールド（例）
- `products_registered`: `count`, `categories_summary`（JSON）
- `recommendation_viewed`: `recommendation_id`, `selected_categories`, `skipped_categories`, `safety_level`
- `recommendation_executed`: `status`, `selected_product_ids`
- `followup_submitted`: `result`, `notes_length`

## 5. KPI算出設計
### 5.1 行動KPI
- 問診完了率 = `consultation_completed / consultation_started`
- 提案到達率 = `recommendation_viewed / consultation_completed`
- 提案実行率 = `recommendation_executed(all) / recommendation_viewed`
  - 補助で `all + partial` を併記

### 5.2 継続KPI
- 2回目利用率（7日以内）:
  - 初回 `recommendation_viewed` から7日以内に `consultation_started` が再度発生した `user_id` の割合

### 5.3 価値KPI
- 不安低減の自己評価: `1〜5平均`
- 紹介意向: `0〜10平均`

### 5.4 母集団
- KPI母集団は `consultation_started` が1回以上の `user_id`
- 2回目利用率は初回 `recommendation_viewed` 到達者を母集団とする

## 6. リスクと回避策
- 二重発火による過大計測 → `consultation_id` 単位で初回のみ採用
- 画面未表示の誤カウント → `recommendation_generated` と `recommendation_viewed` を分離
- ユーザー定義の不一致 → `user_id` の生成/扱いを明文化
