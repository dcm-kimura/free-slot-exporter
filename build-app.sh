#!/bin/bash

# FreeSlotExporter App Bundle Builder
# このスクリプトは通常のmacOSアプリケーション(.app)を作成します

set -e

echo "🚀 Building FreeSlotExporter.app..."

# ビルド設定
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

# Info.plistを作成
echo "📄 Creating Info.plist..."
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
    <string>1.0</string>
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
                <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
            </array>
        </dict>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# アイコンを作成（オプション）
# icnsファイルがある場合は追加
if [ -f "icon.icns" ]; then
    echo "🎨 Adding app icon..."
    cp "icon.icns" "${RESOURCES_DIR}/"
    echo "    <key>CFBundleIconFile</key>" >> "${CONTENTS_DIR}/Info.plist.tmp"
    echo "    <string>icon</string>" >> "${CONTENTS_DIR}/Info.plist.tmp"
fi

# 実行権限を設定
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "✅ App bundle created: ${APP_BUNDLE}"
echo ""
echo "📋 Next steps:"
echo "1. Update Info.plist with your actual Google Client ID"
echo "2. Create Config.plist in the app bundle"
echo "3. Test the app: open ${APP_BUNDLE}"
echo "4. For distribution: codesign and notarize the app"
echo ""
echo "🔧 To create a distributable DMG:"
echo "   ./create-dmg.sh"