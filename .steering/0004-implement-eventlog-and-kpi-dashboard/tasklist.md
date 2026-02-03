# Task List (0004 Implement EventLog and KPI Dashboard)

## 1. データ層
- [ ] EventLogモデル（Hive）を追加
- [ ] EventLogRepository（保存/取得）を実装
- [ ] `user_id`/`session_id`/`consultation_id` の生成・付与を統一

## 2. イベント記録
- [ ] 0003定義のイベントを各画面/処理で発火
- [ ] 主要フィールドの記録（JSON）
- [ ] 重複イベントの除外ルールを実装

## 3. KPI集計
- [ ] 直近14日フィルタを実装
- [ ] KPI算出（分子/分母）を実装
- [ ] 価値KPIの入力タイミングを実装

## 4. UI
- [ ] KPI一覧画面を作成
- [ ] Home or 設定からの導線を追加
- [ ] 率KPIは値（%）＋分子/分母を表示
- [ ] 任意: データリセット（確認ダイアログ）

## 5. 受け入れ確認
- [ ] EventLogが端末内に保存される
- [ ] KPI一覧が端末内で表示される
- [ ] KPI算出式が0003定義と一致する
