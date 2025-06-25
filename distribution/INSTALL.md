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