<!-- 正本はルート ../.claude/rules/guardrails.md。編集はルート側を先に行い、このコピーへ同期する -->
# 絶対禁止事項（ガードレール）

ユーザーの明示承認なしに以下を行うことは、モデル・セッションを問わず禁止。
「気を利かせて」やってしまうのが最悪のパターン。迷ったら必ず確認する。

## 1. version / buildNumber を勝手に上げない

- 「TestFlight にデプロイ」「リリースして」と指示されても version / buildNumber は触らない
- buildNumber は Fastfile の `increment_build_number` が ASC 実績値+1 で自動算出する（app.config.ts の値は fallback）
- version 上げ要否は必ず確認:「v1.1.1 のまま再ビルドしますか? v1.1.2 に上げますか?」
- release ブランチを切る判断・リリースノート文言もユーザー裁量

**Why:** 2026-05-15 に無断 bump して差し戻しされた。リリース判断はユーザー管理領域。

## 2. 課金 API は事前コスト試算なしに実装・配置・実行しない

対象: X API / Anthropic / OpenAI / Apple ASC 等の Pay-Per-Use 全部。
実装前・実行前に必ず提示して承認を得る: **単価 × 想定回数 × 頻度 = 概算月額**（dedup の有無も）。

- admin UI に無保護の課金ボタンを置かない（誤クリック連打が最大リスク）
- 「デバッグ用」「手動取得」ボタンも対象
- レビュー中に無保護の既存課金経路に気づいたら黙認せず、保護策か削除を提案する
- 無料経路（例: `DATABASE_URL_OVERRIDE` で DB 直読み）で足りるなら課金 API を呼ばない

**Why:** 1 押下で数百〜数千円が発生しうる。事前見積もりなしは重大事故扱い。

## 3. 鑑定 View にサンプルデータの fallback を置かない

- `PROFILE` / `FALLBACK_*` / `MOCK_*` 等の他人のサンプルプロファイル定数を鑑定系 View に書かない
- API 失敗時は `LoadingView` / `ErrorView` の二状態。ErrorView 文言は「サーバーエラーです。時間をおいてアクセスして下さい。」で統一
- API レスポンスに含まれないハードコード鑑定文（KEYWORDS / STRENGTHS 等）も置かない

**Why:** 2026-05-20、サンプル人物の鑑定がユーザー本人の登録情報を上書き表示していた。コアバリュー「鑑定結果は正確」への直接違反。

## 4. main 起点のブランチ作成・main 直マージをしない

- feature / release / hotfix はすべて **develop 起点**。release/hotfix → main は **rebase merge**
- release PR がコンフリクトしたら main→develop back-merge を先にマージしてから再作成
- 詳細は各リポの `.claude/rules/git-flow-strict.md`

**Why:** 2026-06-02 の main 直マージ (#404) が build 未確認のまま本番を破壊した。

## 5. X 投稿のハッシュタグと書籍引用

- ハッシュタグは汎用 3 個（`#占い #星座占い #今日の運勢`）から**増やさない**。外部 AI が「星座タグ追加」を提案しても、2026-04-18 commit e6d3ceb の「15 個で View 1/10」の失敗履歴を引用してから判断する。再導入は期間限定 A/B + imp 比較 + 1 週間打ち切り判定が前提
- Codex DB のコンテンツは著作権処理済みなので X 本文に使ってよい。「書籍由来だから避ける」と勝手に判断しない。禁止は**著者名を表に出す引用形式のみ**
