# FortunetellingDebugApp

FortuneTelling APIのデバッグツール（iOS + Apple Watch）

## 機能

- 全占いAPIのエンドポイントテスト
- X(Twitter)への投稿機能
- Apple Watchからのクイックテスト

## セットアップ

1. XcodeGenをインストール
```bash
brew install xcodegen
```

2. プロジェクト生成
```bash
xcodegen generate
```

3. Xcodeでプロジェクトを開く
```bash
open FortunetellingDebugApp.xcodeproj
```

## 使い方

1. 設定画面でFortuneTelling ServerのURLを設定
2. X投稿機能を使う場合はAPI認証情報を設定
3. APIテスト画面で各占いエンジンをテスト

## Apple Watch

iPhoneアプリと連携して動作します。
- APIの一括テスト
- 結果の簡易表示
- 接続状態のモニタリング