# Claude Code Communication - Discord Integration

Discord経由でClaude Code Multi-Agent Systemをリモート操作できる統合システムです。

## 🚀 クイックスタート

### 1. 環境設定

```bash
# プロジェクトをクローン
git clone <repository-url>
cd Claude-Code-Communication

# 環境変数設定
cp .env.example .env
# .envファイルを編集してDiscord Bot TokenやWebhook URLを設定
```

### 2. 一括セットアップ

```bash
# システム全体を一括セットアップ（推奨）
./system/setup.sh
```

このコマンドで以下が自動実行されます：
- tmuxセッション作成（GM + Team）
- Discord Bot仮想環境構築
- 依存関係インストール
- Discord Bot自動起動

### 3. 手動セットアップ（必要に応じて）

```bash
# Discord Bot環境のみセットアップ
./system/discord_bot_manager.sh setup

# Discord Bot起動
./system/discord_bot_manager.sh start
```

## 📱 Discord機能

### 基本コマンド
- `!cc cchelp` - ヘルプ表示
- `!cc status` - システム状態確認
- `!cc gm <メッセージ>` - GMに指示送信
- `!cc tl <メッセージ>` - TLに指示送信

### 自動転送機能
プレフィックスなしでメッセージを送信すると自動的にClaude Codeシステムに転送されます。

```
こんにちは、システムの状態を教えてください
→ 自動的にGMに転送
```

### 応答監視機能
```bash
# Discord内で実行
!cc monitor start   # Claude Codeからの応答をDiscordに自動転送
!cc monitor stop    # 応答監視停止
```

## 🛠️ 管理コマンド

### Discord Bot管理
```bash
# 起動
./system/discord_bot_manager.sh start

# 停止
./system/discord_bot_manager.sh stop

# 状態確認
./system/discord_bot_manager.sh status

# 再起動
./system/discord_bot_manager.sh restart

# 環境再構築
./system/discord_bot_manager.sh setup
```

### システム全体管理
```bash
# 完全セットアップ（初回またはリセット時）
./system/setup.sh

# tmuxセッション確認
tmux list-sessions

# セッションにアタッチ
tmux attach-session -t gm    # GM
tmux attach-session -t team  # Team (TL + ST1-3)
```

## 📁 プロジェクト構造

```
Claude-Code-Communication/
├── system/                      # システム管理スクリプト
│   ├── setup.sh                # 一括セットアップ
│   ├── discord_bot_manager.sh  # Discord Bot管理
│   └── agent-send.sh           # エージェント間通信
├── discord-notifications/      # Discord統合機能
│   ├── discord_bot.py          # メインBot
│   ├── discord_notify.py       # 通知システム
│   ├── response_monitor.py     # 応答監視
│   └── requirements.txt        # Python依存関係
├── GM/                         # ジェネラルマネージャー
├── TL/                         # チームリーダー
├── ST/                         # スタッフ
└── .env                        # 環境変数設定
```

## ⚙️ 環境変数設定

`.env`ファイルに以下を設定：

```env
# Discord Bot Token（必須）
DISCORD_BOT_TOKEN=your_bot_token_here

# Discord Webhook URL（通知用）
DISCORD_WEBHOOK_URL=your_webhook_url_here

# その他のAPI Key（必要に応じて）
GEMINI_API_KEY=your_gemini_key
GOOGLE_API_KEY=your_google_key
```

## 🔧 トラブルシューティング

### よくある問題

1. **Discord Botが起動しない**
   ```bash
   # 環境再構築
   ./system/discord_bot_manager.sh setup
   ```

2. **tmuxセッションが見つからない**
   ```bash
   # セットアップ再実行
   ./system/setup.sh
   ```

3. **Python依存関係エラー**
   ```bash
   # 手動で依存関係インストール
   cd discord-notifications
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

### ログ確認
```bash
# Discord Bot状態確認
./system/discord_bot_manager.sh status

# tmuxセッション一覧
tmux list-sessions

# プロセス確認
ps aux | grep discord_bot
```

## 🚀 使用例

1. **プロジェクト開始**
   ```
   Discord: プロジェクト開始してください
   → GM: [Discord: ユーザー名] プロジェクト開始してください
   ```

2. **タスク管理**
   ```
   Discord: !cc tl 今日のタスクリストを確認してください
   → TL: [Discord: ユーザー名] 今日のタスクリストを確認してください
   ```

3. **システム状態確認**
   ```
   Discord: !cc status
   → システム状態レポートをDiscordに返信
   ```

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。
