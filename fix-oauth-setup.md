# Google OAuth設定の修正手順

## 🚨 エラーの原因

「アクセスをブロック: このアプリのリクエストは無効です」エラーは、Google Cloud ConsoleでのリダイレクトURI設定が正しくないことが原因です。

## ✅ 修正手順

### 1. Google Cloud Consoleにアクセス
https://console.cloud.google.com/

### 2. 認証情報を開く
1. 左メニュー > **APIとサービス** > **認証情報**
2. Client ID `478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0` をクリック

### 3. リダイレクトURIを追加/修正

**承認済みのリダイレクトURI** セクションに以下を追加：

```
com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect
```

**重要**: 
- `http://` や `https://` は不要
- 正確に上記の文字列をコピー&ペースト

### 4. 保存
**保存** ボタンをクリック

## 🔧 追加の設定確認

### OAuth同意画面の設定
1. **APIとサービス** > **OAuth同意画面**
2. **テストユーザー** に自分のGoogleアカウントを追加
3. **公開ステータス** を「本番環境」に変更（または「テスト」のままでテストユーザーを追加）

### スコープの確認
以下のスコープが必要：
- `openid`
- `profile` 
- `email`
- `https://www.googleapis.com/auth/calendar.readonly`

## 🧪 テスト手順

1. 上記設定を完了
2. アプリを再起動
3. 「Sign in with Google」をクリック
4. 正常にGoogleログイン画面が表示されることを確認

## ❓ まだエラーが出る場合

### 確認項目：
- [ ] リダイレクトURIが正確に入力されている
- [ ] OAuth同意画面でテストユーザーが追加されている
- [ ] Calendar APIが有効になっている
- [ ] アプリタイプが「デスクトップアプリケーション」になっている

### デバッグ方法：
1. ブラウザのデベロッパーツールでエラー詳細を確認
2. Google Cloud Consoleの「使用状況」で認証試行を確認
3. 新しいClient IDを作成してテスト