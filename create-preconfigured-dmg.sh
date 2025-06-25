#!/bin/bash

# Create ready-to-use DMG with pre-configured credentials
# ユーザーが即座に使えるDMGを作成します

set -e

APP_NAME="FreeSlotExporter"
VERSION="1.0.3"
BUILD_DIR=".build/release"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-Ready-${VERSION}"
DMG_DIR="${BUILD_DIR}/dmg-ready"

echo "📦 Creating ready-to-use DMG..."

# DMGディレクトリを準備
rm -rf "${DMG_DIR}"
mkdir -p "${DMG_DIR}"

# アプリをDMGディレクトリにコピー
cp -R "${APP_BUNDLE}" "${DMG_DIR}/"

# Applicationsフォルダへのシンボリックリンクを作成
ln -s /Applications "${DMG_DIR}/Applications"

# 簡潔なREADMEファイルを追加
cat > "${DMG_DIR}/README.txt" << EOF
FreeSlotExporter v${VERSION} - Ready to Use!

🎉 Google認証情報は既に設定済みです！

インストール方法:
1. FreeSlotExporter.app を Applications フォルダにドラッグ&ドロップ
2. アプリを起動
3. Googleアカウントでログイン
4. すぐに使用開始！

⚠️ 初回起動時に「開発元が未確認」の警告が出た場合:
   システム設定 > プライバシーとセキュリティ > 「このまま開く」

詳細情報: https://github.com/dcm-kimura/free-slot-exporter

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2025 Vibe Coding Day で開発されました 🚀
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# DMGを作成
echo "💾 Creating DMG file..."
hdiutil create -volname "${APP_NAME} Ready" \
    -srcfolder "${DMG_DIR}" \
    -ov -format UDZO \
    "${BUILD_DIR}/${DMG_NAME}.dmg"

echo "✅ Ready-to-use DMG created: ${BUILD_DIR}/${DMG_NAME}.dmg"
echo ""
echo "🎯 この DMG の特徴:"
echo "  ✅ Google認証情報が事前設定済み"
echo "  ✅ ユーザーの設定作業は不要"
echo "  ✅ インストール後すぐに使用可能"
echo "  ✅ ダウンロード → インストール → 起動 → 完了！"
echo ""
echo "📤 配布準備完了！"