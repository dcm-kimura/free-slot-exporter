# FreeSlotExporter 配布ガイド

通常のmacOSアプリとして配布するための手順です。

## 配布方法の選択肢

### 1. App Store配布（推奨）
- **メリット**: 自動更新、セキュリティ、簡単インストール
- **デメリット**: Apple Developer Account必要（年額$99）、審査必要
- **ユーザー**: App Storeからワンクリックでインストール

### 2. 独自配布（現実的）
- **メリット**: 無料、迅速な配布
- **デメリット**: 手動インストール、設定が必要
- **ユーザー**: DMGをダウンロードしてインストール

## 独自配布用アプリの作成手順

### Step 1: アプリバンドルを作成
```bash
chmod +x build-app.sh
./build-app.sh
```

### Step 2: DMGファイルを作成
```bash
chmod +x create-dmg.sh
./create-dmg.sh
```

### Step 3: 配布用設定

作成されたアプリには以下の設定が必要です：

#### A. Google認証情報の設定方法をユーザーに説明
```
1. Google Cloud Consoleで認証情報を取得
2. Config.plistファイルを作成
3. アプリ内のResourcesフォルダに配置
```

#### B. セキュリティ設定
macOS Catalinaからの要件：
- コード署名（Code Signing）
- 公証（Notarization）

## より良い配布方法

### Option A: 設定済みアプリの提供

各ユーザー向けに事前設定済みアプリを作成：

```bash
# ユーザー専用の設定済みアプリを作成
./build-configured-app.sh [USER_CLIENT_ID] [USER_CLIENT_SECRET]
```

### Option B: 設定アシスタント付きアプリ

アプリ内に設定ウィザードを追加：
1. 初回起動時に設定画面を表示
2. Google認証情報を入力
3. 自動的にConfig.plistを生成

### Option C: ウェブベース配布システム

1. ユーザーがWebでGoogle認証情報を入力
2. 自動的に設定済みアプリをダウンロード
3. すぐに使用可能

## 推奨配布フロー

### 個人/小規模チーム向け
1. GitHubのReleasesページでDMGを配布
2. READMEで詳細な設定手順を提供
3. サポート用のIssuesを活用

### 企業/大規模向け
1. Apple Developer Programに登録
2. App Store経由で配布
3. または企業向け配布（Enterprise Program）

## 現在の制限事項

- ユーザーが個別にGoogle認証情報を設定する必要がある
- 初回設定がやや複雑
- コード署名なしだとmacOSが警告を表示

## 改善案

1. **設定アシスタントの実装**: 初回起動時の設定を簡素化
2. **コード署名の実装**: セキュリティ警告を回避
3. **自動更新機能**: Sparkleフレームワークを使用
4. **設定済み配布システム**: Webベースの配布システム

## 実際の配布手順

現在の状態で配布する場合：

1. `./build-app.sh` でアプリを作成
2. `./create-dmg.sh` でDMGを作成
3. GitHub Releasesで配布
4. ユーザーには詳細な設定手順を提供

配布可能なファイル：
- `FreeSlotExporter-1.0.dmg`
- 設定手順書（README）
- Config.plistテンプレート