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