# FreeSlotExporter トラブルシューティングガイド

## 🚨 よくあるエラーと解決方法

### 1. 「アクセスをブロック: このアプリのリクエストは無効です」

**原因**: Google Cloud ConsoleでのリダイレクトURI設定が正しくない

**解決方法**:

#### Step 1: Google Cloud Consoleにアクセス
https://console.cloud.google.com/

#### Step 2: 認証情報を修正
1. **APIとサービス** > **認証情報**
2. Client ID `478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0` をクリック
3. **承認済みのリダイレクトURI** に以下を追加:
   ```
   com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect
   ```
4. **保存**をクリック

#### Step 3: OAuth同意画面の設定
1. **APIとサービス** > **OAuth同意画面**
2. **テストユーザー**に使用するGoogleアカウントを追加
3. または**公開ステータス**を「本番環境」に変更

---

### 2. 「開発元が未確認のため開けません」

**原因**: macOSのセキュリティ機能

**解決方法**:
1. **システム設定** > **プライバシーとセキュリティ**
2. **セキュリティ**セクションで「このまま開く」をクリック
3. または、ターミナルで以下を実行:
   ```bash
   sudo spctl --master-disable
   ```

---

### 3. Config.plistエラー

**エラーメッセージ**: "Config.plist not found or missing required keys"

**解決方法**:
Ready to Use Editionを使用している場合、このエラーは発生しないはずです。発生した場合:

1. 最新版をダウンロード: 
   https://github.com/dcm-kimura/free-slot-exporter/releases/latest
2. 古いアプリを削除してから再インストール

---

### 4. カレンダーデータが表示されない

**原因**: Calendar APIアクセス権限またはデータ不足

**解決方法**:

#### A. APIアクセス権限の確認
1. ログイン時にカレンダーアクセス許可を与えたか確認
2. Google Calendarに予定があることを確認

#### B. デバッグ情報の確認
アプリ起動時にコンソールログを確認:
```
🔧 OAuth Configuration:
   Client ID: 478117704045-...
   Redirect URI: com.googleusercontent.apps...
```

---

### 5. ネットワークエラー

**症状**: ログインはできるが、データが取得できない

**解決方法**:
1. インターネット接続を確認
2. ファイアウォール設定を確認
3. プロキシ環境の場合、管理者に相談

---

## 🔧 デバッグ方法

### コンソールログの確認
1. **アプリケーション** > **ユーティリティ** > **コンソール**
2. FreeSlotExporterを検索
3. エラーメッセージを確認

### 詳細なエラー情報
アプリ内でエラーが発生すると、詳細なダイアログが表示されます:
- エラー内容
- 考えられる原因
- 解決方法の提案

---

## 📞 サポート

### GitHub Issues
https://github.com/dcm-kimura/free-slot-exporter/issues

### 報告時に含める情報:
- [ ] macOSバージョン
- [ ] アプリバージョン
- [ ] エラーメッセージの全文
- [ ] 実行した操作の詳細
- [ ] コンソールログ（該当部分）

### よくある質問の確認
GitHub Issuesで他のユーザーの質問と回答を確認してください。

---

## 🛠 高度なトラブルシューティング

### アプリの完全リセット
```bash
# 認証情報をクリア
rm -rf ~/Library/Keychains/FreeSlotExporter*

# アプリを再インストール
rm -rf /Applications/FreeSlotExporter.app
# 新しいDMGからインストール
```

### 代替認証方法
1. ブラウザでGoogle Calendarにアクセス可能か確認
2. 他のGoogleサービス（Gmail等）が正常に動作するか確認
3. 別のGoogleアカウントでテスト

---

## ✅ 正常動作の確認

正常に動作している場合:
1. ✅ Googleアカウントでログイン成功
2. ✅ プロフィール画像が表示される
3. ✅ カレンダーイベントが左側に表示される
4. ✅ 空き時間（緑色）が表示される
5. ✅ 空き時間を選択してエクスポート可能

すべて確認できれば、FreeSlotExporterは正常に動作しています！