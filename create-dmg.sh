#!/bin/bash

# Create distributable DMG for FreeSlotExporter
# このスクリプトは配布用のDMGファイルを作成します

set -e

APP_NAME="FreeSlotExporter"
VERSION="1.0"
BUILD_DIR=".build/release"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}"
DMG_DIR="${BUILD_DIR}/dmg"

echo "📦 Creating DMG for distribution..."

# DMGディレクトリを準備
rm -rf "${DMG_DIR}"
mkdir -p "${DMG_DIR}"

# アプリをDMGディレクトリにコピー
cp -R "${APP_BUNDLE}" "${DMG_DIR}/"

# Applicationsフォルダへのシンボリックリンクを作成
ln -s /Applications "${DMG_DIR}/Applications"

# READMEファイルを追加
cat > "${DMG_DIR}/README.txt" << EOF
FreeSlotExporter v${VERSION}

Google Calendarと連携して空き時間を抽出・エクスポートするmacOSアプリケーションです。

インストール方法:
1. FreeSlotExporter.appをApplicationsフォルダにドラッグ&ドロップ
2. Launchpadまたは /Applications/FreeSlotExporter.app から起動
3. 初回起動時にGoogle認証を行ってください

詳細な設定方法:
https://github.com/dcm-kimura/free-slot-exporter

⚠️ 重要: 初回起動前にConfig.plistの設定が必要です
詳細はGitHubのREADMEをご確認ください
EOF

# DMGを作成
echo "💾 Creating DMG file..."
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov -format UDZO \
    "${BUILD_DIR}/${DMG_NAME}.dmg"

echo "✅ DMG created: ${BUILD_DIR}/${DMG_NAME}.dmg"
echo ""
echo "📋 Distribution checklist:"
echo "  ✅ App bundle created"
echo "  ✅ DMG created"
echo "  ⚠️  Code signing (recommended for distribution)"
echo "  ⚠️  Notarization (required for Gatekeeper)"
echo "  ⚠️  User needs to configure Config.plist"
echo ""
echo "🚀 Ready for distribution!"