# FreeSlotExporter

![screen](https://github.com/user-attachments/assets/e26357dd-271d-44a7-a37b-6566edb31863)

> **2025 Vibe Coding Day** で開発されたプロジェクトです 🚀

Google Calendarと連携して空き時間を抽出・エクスポートするmacOSアプリケーションです。

## 📥 ダウンロード

### 🚀 推奨: Ready to Use Edition (v1.0.4) 

**設定不要で即座に使える！OAuth認証エラー修正済み！**
- [📦 FreeSlotExporter-Ready-1.0.4.dmg](https://github.com/dcm-kimura/free-slot-exporter/releases/download/v1.0.4-ready/FreeSlotExporter-Ready-1.0.4.dmg) - 事前設定済みアプリ

### 🎯 超簡単インストール（3ステップ）
1. **DMGをダウンロード**して開く
2. **アプリをApplicationsフォルダ**にドラッグ&ドロップ
3. **アプリを起動**してGoogleでログイン → **完了！**

> **Google Cloud設定は不要** - 全て事前設定済みです！

---

## 機能

- **Googleアカウント認証**: OAuth 2.0による安全な認証
- **カレンダー同期**: Google Calendarから次の7日間の予定を自動取得
- **空き時間の可視化**: 営業時間（9:00-18:00）内の30分以上の空き時間を自動検出
- **週末除外**: 土日を除いた平日のみの空き時間を表示
- **エクスポート機能**: 選択した空き時間を日本語形式でクリップボードにコピー
- **ネイティブmacOS対応**: SwiftUIで構築された洗練されたインターフェース
- **プロフィール画像表示**: Googleアカウントのプロフィール画像を表示

## 必要環境

- macOS 13.0以降
- Swift 5.9以降
- Google Calendarアカウント


## 使い方

1. アプリケーションを起動
2. 「Sign in with Google」をクリックしてGoogleアカウントでログイン
3. カレンダーへのアクセスを許可
4. 左側のサイドバーに予定と空き時間が日付ごとに表示されます
   - 緑色のバー: 空き時間（選択可能）
   - 赤色のバー: 予定がある時間（選択不可）
5. エクスポートしたい空き時間をクリックして選択（複数選択可）
6. 右側のプレビューで選択内容を確認
7. 「クリップボードにコピー」をクリックしてエクスポート

## エクスポート形式

空き時間は以下の形式でエクスポートされます：

```
12月25日（月） 10:00〜12:00（2時間）
12月26日（火） 14:00〜15:30（1時間30分）
```

## プライバシーとセキュリティ

- 認証情報はmacOSのKeychainに安全に保存されます
- Google Calendarへは読み取り専用でアクセスします
- 個人情報はローカルにのみ保存され、外部に送信されることはありません

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 貢献

バグ報告や機能要望は、GitHubのIssuesにお願いします。プルリクエストも歓迎します！

## 仕様詳細

### 空き時間の検出ロジック

- 営業時間: 9:00-18:00
- 最小空き時間: 30分
- 対象日数: 今日から7日間（平日のみ）
- 全日イベントは除外

### UI仕様

- NavigationSplitView による2ペインレイアウト
- 左側: イベントと空き時間のリスト（日付ヘッダー付き）
- 右側: 選択した空き時間のプレビューとエクスポート機能
- アカウント情報は左下に固定表示

## 開発者向け情報

### アーキテクチャ

- **SwiftUI**: ユーザーインターフェース
- **AppAuth-iOS**: OAuth 2.0認証
- **Google Calendar API v3**: カレンダーデータの取得

### 主要コンポーネント

- `FreeSlotExporter.swift`: アプリケーションのエントリーポイント
- `GoogleAuthManager.swift`: 認証とAPI通信の管理
- `ContentView.swift`: メインUIの実装
- `CalendarEvent.swift`: イベントデータモデル
- `AvailableTimeSlot.swift`: 空き時間データモデル

### ディレクトリ構造

```
schedule-app/
├── GoogleCalendarApp/
│   ├── Package.swift
│   ├── GoogleCalendarApp/
│   │   ├── FreeSlotExporter.swift
│   │   ├── Info.plist
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Views/
│   └── README.md
├── CLAUDE.md
└── .gitignore
```
