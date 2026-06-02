# FortunetellingDebugApp

FortuneTelling APIのデバッグとXポスト機能を統合したiOS/watchOSアプリ

## プロジェクト情報

- Bundle ID: `jp.dsgarage.fortunetellingdebugapp`
- Team ID: `TNU5GR62GT`
- 最小iOS: 17.0
- 最小watchOS: 10.0

## 主要機能

### iOS App
1. **APIテスト**: 全占いエンジンのエンドポイント動作確認
   - 四柱推命
   - 西洋占星術
   - 数秘術
   - タロット
   - 九星気学
   - 血液型占い
   - 六星占術

2. **Xポスト**: OAuth 1.0a認証でX(Twitter)へ投稿
   - テンプレート機能
   - 文字数カウント
   - 投稿履歴

3. **設定**: APIエンドポイントと認証情報の管理

### watchOS App
1. **APIクイックテスト**: iPhone経由で全APIを一括テスト
2. **結果表示**: 最新の鑑定結果を表示
3. **接続状態モニタリング**: iPhoneとの接続状態を表示

## ビルド手順

```bash
# プロジェクト生成
xcodegen generate

# ビルド
xcodebuild -scheme FortunetellingDebugApp -configuration Debug build
```

## APIエンドポイント

デフォルト: `http://localhost:3000`

## X API認証

設定画面で以下を入力:
- API Key
- API Secret  
- Access Token
- Access Token Secret