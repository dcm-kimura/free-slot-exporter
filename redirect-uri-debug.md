# 🔍 redirect_uri_mismatch エラー詳細診断

## 現在の設定情報
- **Client ID**: `478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0.apps.googleusercontent.com`
- **公開ステータス**: 本番環境 ✅
- **アプリが使用するリダイレクトURI**: `com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect`

## 🚨 重要: 正確なリダイレクトURI

アプリは以下の**完全一致**するURIを期待しています：
```
com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect
```

## 📋 Google Cloud Console での確認手順

### 1. 認証情報画面にアクセス
https://console.cloud.google.com/apis/credentials

### 2. OAuth 2.0 クライアント ID を編集
1. `478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0.apps.googleusercontent.com` の行で **鉛筆アイコン（編集）** をクリック
2. または行全体をクリックして詳細画面を開く

### 3. 設定画面で確認すること

#### A. アプリケーションの種類
```
☑️ デスクトップアプリケーション
```
（これが重要：「ウェブアプリケーション」や「iOS」ではダメです）

#### B. 承認済みのリダイレクトURI
**この欄に以下が設定されているか確認：**
```
com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect
```

## 🔧 修正手順（詳細版）

### Step 1: 既存URIを確認
現在設定されているリダイレクトURIを確認してください。
以下のような間違いがないかチェック：

❌ **よくある間違い：**
- `http://com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect`
- `https://com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect`
- `com.googleusercontent.apps.478117704045:/oauthredirect` (短すぎる)
- `com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0/oauthredirect` (コロンなし)
- スペースや改行が混入

### Step 2: 正しいURIを設定
1. **既存のURIを削除**（間違っている場合）
2. **+ URI を追加** をクリック
3. 以下を**正確にコピー&ペースト**：
   ```
   com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect
   ```
4. **保存** をクリック

### Step 3: 設定反映を待つ
- 設定変更後、**5-15分**待つ
- この間はキャッシュのため古い設定が残る可能性があります

## 🧪 テスト手順

### 1. アプリのデバッグ情報確認
アプリを起動すると以下が表示されます：
```
🔧 OAuth Configuration:
   Client ID: 478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0.apps.googleusercontent.com
   Redirect URI: com.googleusercontent.apps.478117704045-6b1tisa38ceqkpkl758mh2c9dl301ma0:/oauthredirect
```

### 2. 認証テスト
1. アプリを**完全に終了**
2. **再起動**
3. 「Sign in with Google」をクリック
4. ブラウザでの認証画面を確認

## 🔍 詳細な確認ポイント

### Google Cloud Console画面で確認すべき項目：

```
OAuth 2.0 クライアント ID の編集
┌─────────────────────────────────────────────────────────┐
│ アプリケーションの種類                                      │
│ ● デスクトップアプリケーション                              │
│                                                         │
│ 名前                                                    │
│ [あなたのアプリ名]                                       │
│                                                         │
│ 承認済みのリダイレクト URI                               │
│ ┌─────────────────────────────────────────────────────┐   │
│ │com.googleusercontent.apps.478117704045-6b1tisa38ce...│   │
│ │qkpkl758mh2c9dl301ma0:/oauthredirect                 │   │
│ └─────────────────────────────────────────────────────┘   │
│ [+ URI を追加]                                          │
│                                                         │
│ [保存] [キャンセル]                                      │
└─────────────────────────────────────────────────────────┘
```

## 📞 確認していただきたいこと

現在のGoogle Cloud Consoleの設定で、以下を教えてください：

1. **アプリケーションの種類**は何になっていますか？
   - [ ] デスクトップアプリケーション
   - [ ] ウェブアプリケーション  
   - [ ] その他

2. **承認済みのリダイレクトURI**欄には何が設定されていますか？
   - 設定されているURIを正確にコピー&ペーストしてください

3. **Calendar API**は有効になっていますか？
   - [ ] はい
   - [ ] いいえ

この情報があれば、exact matchでない原因を特定できます！