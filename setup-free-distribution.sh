#!/bin/bash

# FreeSlotExporter - Free Distribution Setup
# GitHub Releasesを使った無料配布のセットアップ

set -e

echo "🎉 Setting up free distribution for FreeSlotExporter"
echo "📍 Using GitHub Releases for distribution"
echo ""

# バージョン情報
VERSION="1.0.0"
APP_NAME="FreeSlotExporter"

# 配布用ディレクトリを作成
DIST_DIR="distribution"
rm -rf "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

echo "📦 Step 1: Building release app bundle..."
./build-app.sh

echo "💾 Step 2: Creating DMG..."
./create-dmg.sh

echo "📋 Step 3: Creating distribution package..."

# DMGをdistributionフォルダにコピー
cp ".build/release/${APP_NAME}-${VERSION}.dmg" "${DIST_DIR}/"

# 簡単セットアップ用のスクリプトを作成
cat > "${DIST_DIR}/easy-setup.sh" << 'EOF'
#!/bin/bash

# FreeSlotExporter 簡単セットアップスクリプト
echo "🚀 FreeSlotExporter セットアップを開始します..."

# Google認証情報の入力
echo ""
echo "📝 Google Cloud Consoleから取得した認証情報を入力してください:"
echo "   https://console.cloud.google.com/"
echo ""

read -p "Client ID を入力: " CLIENT_ID
read -p "Client Secret を入力: " CLIENT_SECRET

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
    echo "❌ 認証情報が入力されていません。セットアップを中止します。"
    exit 1
fi

# アプリ内のConfig.plistを作成
APP_PATH="/Applications/FreeSlotExporter.app"
CONFIG_PATH="${APP_PATH}/Contents/Resources/Config.plist"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ FreeSlotExporter.app が /Applications に見つかりません。"
    echo "   先にアプリをApplicationsフォルダにインストールしてください。"
    exit 1
fi

# Config.plistを作成
cat > "$CONFIG_PATH" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ClientID</key>
    <string>$CLIENT_ID</string>
    <key>ClientSecret</key>
    <string>$CLIENT_SECRET</string>
</dict>
</plist>
PLIST_EOF

echo "✅ 設定完了！FreeSlotExporter を起動できます。"
echo "📱 Launchpad または Applications フォルダから起動してください。"
EOF

chmod +x "${DIST_DIR}/easy-setup.sh"

# ユーザー向けインストールガイドを作成
cat > "${DIST_DIR}/INSTALL.md" << 'EOF'
# FreeSlotExporter インストールガイド

## 📥 インストール手順（3ステップ）

### 1. アプリをインストール
1. `FreeSlotExporter-1.0.0.dmg` をダブルクリック
2. `FreeSlotExporter.app` を `Applications` フォルダにドラッグ&ドロップ

### 2. Google認証情報を取得
1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 新しいプロジェクトを作成
3. Google Calendar API を有効化
4. OAuth 2.0 認証情報を作成：
   - アプリケーションタイプ: **デスクトップアプリケーション**
   - 名前: `FreeSlotExporter`
5. Client ID と Client Secret をメモ

### 3. 簡単セットアップ実行
```bash
./easy-setup.sh
```

## 🎉 完了！

アプリを起動してGoogleアカウントでログインしてください。

## ❓ トラブルシューティング

### 「開発元が未確認」の警告が出る場合
1. システム設定 > プライバシーとセキュリティ
2. 「このまま開く」をクリック

### 認証エラーが出る場合
- Google Cloud Console の設定を確認
- Client ID と Client Secret が正しいか確認

### その他の問題
GitHub Issues でサポートします：
https://github.com/dcm-kimura/free-slot-exporter/issues
EOF

# GitHub Release用の説明文を作成
cat > "${DIST_DIR}/release-notes.md" << EOF
# FreeSlotExporter v${VERSION} 🎉

> **2025 Vibe Coding Day** で開発されたプロジェクトです！

Google Calendarと連携して空き時間を抽出・エクスポートするmacOSアプリケーションです。

## 📥 ダウンロード

\`FreeSlotExporter-${VERSION}.dmg\` をダウンロードしてください。

## 🚀 インストール方法

1. **DMGをダウンロード** して開く
2. **アプリをApplicationsフォルダ**にドラッグ&ドロップ  
3. **Google認証情報を取得**（[詳細手順](https://github.com/dcm-kimura/free-slot-exporter#readme)）
4. **簡単セットアップを実行**: \`./easy-setup.sh\`

## ✨ 機能

- 🗓️ Google Calendarから自動で空き時間を検出
- ⏰ 営業時間（9:00-18:00）内の30分以上の空き時間を表示
- 📅 平日のみ対象（週末は除外）
- ✅ 複数の空き時間を選択可能
- 📋 日本語形式でクリップボードにエクスポート
- 🎨 ネイティブmacOSアプリ（SwiftUI）

## 🔧 必要環境

- macOS 13.0以降
- Google Calendarアカウント

## 🆘 サポート

質問や問題は [GitHub Issues](https://github.com/dcm-kimura/free-slot-exporter/issues) でお気軽にどうぞ！

---

**無料配布中** - ぜひお試しください！ ⭐️
EOF

echo "📄 Step 4: Creating release assets..."

# READMEを更新してダウンロードリンクを追加
cat > "${DIST_DIR}/README-update.md" << EOF

## 📥 ダウンロード

### 最新版: v${VERSION}

**即座に使える配布版:**
- [FreeSlotExporter-${VERSION}.dmg](https://github.com/dcm-kimura/free-slot-exporter/releases/latest/download/FreeSlotExporter-${VERSION}.dmg) - アプリ本体
- [簡単セットアップスクリプト](https://github.com/dcm-kimura/free-slot-exporter/releases/latest/download/easy-setup.sh) - 認証情報の設定

### インストール手順
1. DMGをダウンロード
2. アプリをApplicationsフォルダにドラッグ&ドロップ
3. [Google Cloud Console](https://console.cloud.google.com/)で認証情報を取得
4. \`easy-setup.sh\`を実行して認証情報を設定
5. アプリを起動！

詳細な手順は [INSTALL.md](INSTALL.md) をご覧ください。
EOF

echo ""
echo "✅ 無料配布の準備が完了しました！"
echo ""
echo "📁 配布ファイル:"
echo "   - ${DIST_DIR}/${APP_NAME}-${VERSION}.dmg"
echo "   - ${DIST_DIR}/easy-setup.sh"
echo "   - ${DIST_DIR}/INSTALL.md"
echo "   - ${DIST_DIR}/release-notes.md"
echo ""
echo "🚀 次のステップ:"
echo "   1. GitHub Releases でバージョンタグを作成"
echo "   2. 配布ファイルをアップロード"  
echo "   3. READMEにダウンロードリンクを追加"
echo ""
echo "💡 GitHub Release作成コマンド:"
echo "   gh release create v${VERSION} ${DIST_DIR}/* --title \"FreeSlotExporter v${VERSION}\" --notes-file ${DIST_DIR}/release-notes.md"
echo ""
echo "🎉 これで誰でも無料でダウンロード・インストールできます！"
EOF