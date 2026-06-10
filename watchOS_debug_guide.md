# watchOSデバッグガイド

## シミュレーターでのデバッグ

### 1. 環境準備
```bash
# watchOS 26.2ランタイムの確認
xcrun simctl runtime list | grep -i watch

# ペアリングされたデバイスの確認
xcrun simctl list pairs
```

### 2. プロジェクト構成の修正

#### project.ymlの正しい設定
```yaml
targets:
  # iOSアプリ（親アプリ）
  FortunetellingDebugApp:
    type: application
    platform: iOS
    dependencies:
      - target: FortunetellingDebugWatch
        embed: true  # Watch.appを埋め込み
        codeSign: true

  # watchOSアプリ（コンテナのみ）
  FortunetellingDebugWatch:
    type: application
    platform: watchOS
    deploymentTarget: 10.5
    sources: []  # ソースコードなし（コンテナのみ）
    dependencies:
      - target: FortunetellingDebugWatchExtension
        embed: true  # Extensionを埋め込み
        codeSign: true

  # WatchKit Extension（実際のコード）
  FortunetellingDebugWatchExtension:
    type: app-extension
    platform: watchOS
    deploymentTarget: 10.5
    sources:
      - path: watchOS/FortunetellingDebugWatchExtension
```

### 3. Xcodeでの実行手順

1. **プロジェクトクリーン**
   - Product > Clean Build Folder (⇧⌘K)

2. **スキーム選択**
   - FortunetellingDebugApp-iOS を選択

3. **デバイス選択**
   - iPhone 17 + Apple Watch Series 10 のペアを選択

4. **ビルド＆実行**
   - ⌘R で実行

### 4. トラブルシューティング

#### "com.apple.Bridge not found"エラーの場合
```bash
# シミュレーターリセット
xcrun simctl shutdown all
xcrun simctl erase all

# 新しいペアを作成
xcrun simctl create "iPhone 17 New" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-17 \
  com.apple.CoreSimulator.SimRuntime.iOS-26-2

xcrun simctl create "Apple Watch S11" \
  com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-11-46mm \
  com.apple.CoreSimulator.SimRuntime.watchOS-26-2

# ペアリング
xcrun simctl pair [WATCH_ID] [IPHONE_ID]
```

#### "Missing bundle executable"エラーの場合
WatchKit Extensionが正しくビルドされていません。
- Build Settingsで SKIP_INSTALL = NO を確認
- WatchKit Appは実行ファイルを持たない（正常）
- WatchKit Extensionが実行ファイルを持つ

## 実機でのデバッグ

### 1. 準備
- iPhone実機とApple Watchをペアリング
- 両デバイスを開発用に登録（Xcode > Window > Devices）

### 2. プロビジョニング
```bash
# 自動署名を使用
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = TNU5GR62GT
```

### 3. 実行
- スキーム: FortunetellingDebugWatch
- デバイス: DaisukeさんのApple Watch
- ⌘R で実行

## SwiftUI Appベースの新しいwatchOSアプリ作成

### 最新のwatchOSアプリ構造（推奨）

1. **Xcodeで新規プロジェクト作成**
   - File > New > Project
   - watchOS > Watch App を選択
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App

2. **既存コードの移行**
   - WatchConnectivityは同じように使用可能
   - SwiftUI ViewsをそのままApp構造に移行

3. **プロジェクト構造**
```
FortunetellingWatch/
├── FortunetellingWatchApp.swift  # @main App
├── ContentView.swift
├── Models/
│   └── WatchConnectivity.swift
└── Views/
    ├── BriefApprovalView.swift
    └── QuickTestView.swift
```

### メリット
- 実行ファイル問題が解決
- よりシンプルな構造
- 最新のSwiftUI機能を活用可能
- シミュレーターでの動作が安定

## 現在のプロジェクトの修正方法

1. **一時的にwatchOSを無効化**（現在の状態）
```yaml
dependencies: []
# watchOS targets commented out
```

2. **iOSアプリのみでテスト**
- エンゲージメント機能はiOSで利用可能
- APIテストもiOSで実行可能

3. **後でwatchOSアプリを再実装**
- SwiftUI Appベースで作り直し
- または実機のみでテスト