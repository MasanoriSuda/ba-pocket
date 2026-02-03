# Requirements (0003 Define PoC KPIs)

## 1. 目的
PoCの成功指標を明確化し、端末内イベントログ（EventLog）として計測できる状態にする。計測方法と目標値の叩きを記載する。

## 2. 変更・追加する成果物
- PoC検証KPIの定義（行動/継続/価値）
- KPIに対応する計測イベント一覧（EventLog）
- 計測方法（算出式/観測期間/粒度）
- 目標値（叩き）と仮説

## 3. KPI設計方針
- 2週間のPoCで観測可能な指標に限定する
- ルールベース/端末内のみの前提を崩さない
- ユーザー自己申告に依存する指標は明示する

## 4. KPI定義（案）
### 4.1 行動KPI
- 問診完了率: `consultation_completed / consultation_started`
  - カウントは `consultation_id` 単位（同一相談の重複発火は無視）
- 提案到達率（追加推奨）: `recommendation_viewed / consultation_completed`
  - 結果画面の表示到達を計測（漏斗の把握）
- 提案実行率（自己申告）: `recommendation_executed / recommendation_viewed`
  - `recommendation_executed` は `status ∈ {all, partial, none}`
  - KPIは `all` を主、補助で `all + partial` も併記

### 4.2 継続KPI
- 2回目利用率（7日以内再訪）:
  - 初回 `recommendation_viewed` から7日以内に `consultation_started` が再度発生した `user_id` の割合
  - `app_opened` は誤タップ等のノイズがあるため再訪定義に使わない

### 4.3 価値KPI
- 不安低減の自己評価: `1〜5評価の平均`
  - `recommendation_viewed` 直後 or `followup_submitted` 時に質問
- 紹介意向: `0〜10評価の平均`
  - `followup_submitted` 時に質問（体験後が妥当）

## 5. EventLog（案）
- `app_opened`（起動）
- `consultation_started`
- `consultation_completed`
- `consultation_abandoned`（問診途中離脱）
- `products_registered`（件数）
- `recommendation_generated`（ルール計算完了）
- `recommendation_viewed`
- `recommendation_executed`（自己申告）
- `followup_opened`
- `followup_submitted`（結果）
- `safety_notice_viewed`
- `medical_prompt_shown`

### 5.1 EventLog 必須フィールド
- `user_id`
- `session_id`
- `consultation_id`
- `timestamp`
- `event_type`

`user_id` は端末内生成の匿名UUIDとし、再インストール時はリセットされる想定（PoCでは跨ぎ集計しない）。

### 5.2 EventLog 主要フィールド（最低限）
- `consultation_abandoned`: `step_index`, `elapsed_ms`
- `products_registered`: `count`, `categories_summary`
- `recommendation_generated`: `recommendation_id`
- `recommendation_viewed`: `recommendation_id`, `selected_categories`, `skipped_categories`, `safety_level`
- `recommendation_executed`: `status (all/partial/none)`, `selected_product_ids`（optional）
- `followup_submitted`: `result (improved/same/worse)`, `notes_length`（optional）

`categories_summary` はカテゴリ別件数のJSON（例: `{"cleanser":2,"toner":1,"moisturizer":1,"serum_active":1}`）。

### 5.3 EventLog 発火タイミング（最小定義）
- `consultation_started`: 問診1問目が表示された時点
- `consultation_completed`: 結果生成に必要な最終回答が確定した時点
- `recommendation_generated`: ルール判定が完了し `recommendation_id` が確定した時点
- `recommendation_viewed`: 結果画面が初回表示された時点
- `recommendation_executed`: 実行状況（all/partial/none）を確定して送信した時点
- `followup_submitted`: 翌日フォローの結果を確定した時点

## 6. 計測方法（案）
- 期間: 2週間
- 粒度: ユーザー単位 + セッション単位
- 端末内集計が前提。外部送信は行わない

### 6.1 集計ルール
- 同一 `consultation_id` の `*_started` / `*_completed` は最初の1回のみ採用
- KPIは「ユーザー単位」と「相談単位」を分けて算出
  - 例: 問診完了率＝相談単位、2回目利用率＝ユーザー単位

### 6.2 KPI母集団
- KPIの母集団は `consultation_started` を1回以上発生させた `user_id` とする
- 2回目利用率の母集団は初回 `recommendation_viewed` 到達者とする

## 7. 目標値（叩き）
- 問診完了率: 60%以上
- 提案到達率: 80%以上
- 提案実行率（自己申告）: 50%以上
- 2回目利用率: 30%以上
- 不安低減の自己評価: 平均4.0/5以上
- 紹介意向: 平均7.0/10以上

## 8. 受け入れ条件
- KPIの定義と算出方法が明文化されている
- EventLogの一覧が明文化されている
- 目標値（叩き）が記載されている
- EventLogの各イベントに必須フィールドが定義されている

## 9. 制約事項 / 非対象
- 外部分析基盤への送信はしない
- 個人情報は収集しない
