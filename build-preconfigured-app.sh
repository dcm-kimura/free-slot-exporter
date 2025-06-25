#!/bin/bash

# FreeSlotExporter - Pre-configured App Builder
# あなたのGoogle Cloud認証情報を事前設定したアプリを作成します

set -e

echo "🔧 Building pre-configured FreeSlotExporter with your Google credentials..."

# 既存の認証情報を使用
if [ ! -f "GoogleCalendarApp/GoogleCalendarApp/Config.plist" ]; then
    echo "❌ Config.plist が見つかりません。先に認証情報を設定してください。"
    exit 1
fi

# バージョン情報
VERSION="1.0.2"
APP_NAME="FreeSlotExporter"
BUILD_DIR=".build/release"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# クリーンアップ
rm -rf "${APP_BUNDLE}"

# リリースビルド
echo "📦 Building release version..."
cd GoogleCalendarApp
swift build -c release
cd ..

# アプリバンドルディレクトリ作成
echo "📁 Creating app bundle structure..."
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 実行ファイルをコピー
echo "📋 Copying executable..."
cp "GoogleCalendarApp/.build/release/${APP_NAME}" "${MACOS_DIR}/"

# 事前設定済みConfig.plistをコピー
echo "🔐 Adding pre-configured credentials..."
cp "GoogleCalendarApp/GoogleCalendarApp/Config.plist" "${RESOURCES_DIR}/"

# アイコンを追加
echo "🎨 Adding app icon..."
cp "AppIcon.icns" "${RESOURCES_DIR}/"

# Info.plistを作成（あなたの認証情報を使用）
echo "📄 Creating Info.plist..."

# Config.plistからClient IDを読み取り
CLIENT_ID=$(grep -A1 "ClientID" "GoogleCalendarApp/GoogleCalendarApp/Config.plist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

cat > "${CONTENTS_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>FreeSlotExporter</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.FreeSlotExporter</string>
    <key>CFBundleName</key>
    <string>FreeSlotExporter</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.$(echo $CLIENT_ID | cut -d'-' -f1)</string>
            </array>
        </dict>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# 実行権限を設定
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "✅ Pre-configured app bundle created: ${APP_BUNDLE}"
echo "🔐 Google credentials are embedded - no user setup required!"
echo ""
echo "📋 Next steps:"
echo "1. Test the app: open ${APP_BUNDLE}"
echo "2. Create DMG: ./create-preconfigured-dmg.sh"
echo "3. Distribute to users"
echo ""
echo "🎉 Users can now install and run immediately!"