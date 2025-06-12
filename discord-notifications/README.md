# Discord通知システム

Claude Codeの作業完了をDiscordに通知するシンプルなPythonライブラリ。

## セットアップ

1. **Discord Webhookの作成**
   - Discordサーバーで通知を受け取りたいチャンネルを右クリック
   - 「チャンネルの編集」→「連携サービス」→「Webhooks」
   - 「新しいWebhook」を作成してURLをコピー

2. **環境変数の設定**
   ```bash
   # メインの.envファイルを編集（プロジェクトルートの.env）
   # Claude-Code-Communication/.env
   DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/your_webhook_url
   ```

3. **仮想環境とパッケージのインストール**
   ```bash
   cd discord-notifications
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

## 使用方法

### 🤖 Discord Bot（リモート操作）

Discord BotでClaude-Code-Communicationシステムをリモート操作できます！

#### Bot起動
```bash
cd discord-notifications
./start_bot.sh
```

#### Discord コマンド
```
!cc cchelp        - ヘルプを表示
!cc status        - システム状態確認
!cc setup         - システムセットアップ

!cc gm <メッセージ>    - GMに指示
!cc tl <メッセージ>    - TLに指示
!cc st <メッセージ>    - STs(スタッフ)に指示

!cc start <プロジェクト名>     - プロジェクト開始
!cc project <プロジェクト説明> - 新規プロジェクト作成
```

#### 使用例
```
!cc start "Webアプリケーション開発"
!cc project "ユーザー管理システムを作成してください"
!cc gm "プロジェクトの進捗を確認してください"
!cc tl "コードレビューを実施してください"
```

### 📱 通知システム（従来機能）

#### 基本的な使い方

```python
from discord_notify import notify

# 埋め込みメッセージ（推奨）
notify("✅ デプロイが完了しました！")
notify("⚠️ テストが3つスキップされました")
notify("❌ ビルドが失敗しました")

# プレーンテキスト
notify("シンプルなメッセージ", embed=False)
```

### コマンドライン使用

```bash
# Discord通知システムディレクトリに移動
cd discord-notifications

# 仮想環境を有効化
source venv/bin/activate

# 直接メッセージを送信
python cli.py "テストが完了しました"

# Bashスクリプト経由でタスク実行
./claude_notify.sh "新機能の実装"

# Pythonスクリプト経由でタスク実行
python run_with_notify.py "バグ修正"
```

## ファイル構成

### 🤖 Discord Bot システム
- `discord_bot.py` - Discord Bot メインコード
- `start_bot.sh` - Bot起動スクリプト

### 📱 通知システム
- `discord_notify.py` - メインライブラリ
- `cli.py` - コマンドライン インターフェース
- `claude_notify.sh` - Bashスクリプト統合
- `run_with_notify.py` - Python統合スクリプト
- `requirements.txt` - 必要なパッケージ
- `.env` - 環境変数（要設定）
- `.env.example` - 環境変数テンプレート

## 特徴

### 🤖 Discord Bot
- 🎯 **リモート操作** - DiscordからClaude-Code-Communicationを制御
- 👥 **エージェント管理** - GM/TL/STsへの直接指示
- 🚀 **クイックコマンド** - プロジェクト開始・作成が簡単
- 🔒 **セキュリティ** - 認証ユーザーのみアクセス可能

### 📱 通知システム
- 🎨 **リッチな埋め込みメッセージ** - タイムスタンプと色分けで視認性抜群
- 🚀 **シンプルなAPI** - `notify()`関数一つで簡単操作
- 🔧 **柔軟な統合** - Bash、Python、コマンドラインから利用可能
- ⚡ **高速動作** - 軽量で必要最小限の依存関係

## トラブルシューティング

### よくある問題

1. **「DISCORD_WEBHOOK_URLを.envに設定してください」エラー**
   - `.env`ファイルにWebhook URLが設定されているか確認

2. **通知が届かない**
   - Webhook URLが正しいか確認
   - インターネット接続を確認

3. **仮想環境エラー**
   - `cd discord-notifications`でディレクトリに移動
   - `source venv/bin/activate`で仮想環境を有効化してから実行
