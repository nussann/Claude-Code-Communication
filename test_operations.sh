#!/bin/bash
# プロジェクトルートからの操作テストスクリプト

echo "🧪 Claude Code Communication - 操作テスト"
echo "=========================================="
echo ""

# プロジェクトルートにいることを確認
if [ ! -f "SETUP_README.md" ] || [ ! -d "system" ]; then
    echo "❌ エラー: プロジェクトルートで実行してください"
    exit 1
fi

echo "📍 現在位置: $(pwd)"
echo ""

# 1. Discord Bot状態確認
echo "🔍 1. Discord Bot状態確認"
./system/discord_bot_manager.sh status
echo ""

# 2. ヘルプ表示テスト
echo "📖 2. ヘルプ表示テスト"
echo "使用方法: ./system/discord_bot_manager.sh {setup|start|stop|status|restart}"
echo ""

# 3. システム構造確認
echo "📁 3. システム構造確認"
echo "✅ system/setup.sh: $([ -f system/setup.sh ] && echo "存在" || echo "なし")"
echo "✅ system/discord_bot_manager.sh: $([ -f system/discord_bot_manager.sh ] && echo "存在" || echo "なし")"
echo "✅ system/agent-send.sh: $([ -f system/agent-send.sh ] && echo "存在" || echo "なし")"
echo "✅ discord-notifications/: $([ -d discord-notifications ] && echo "存在" || echo "なし")"
echo "✅ .env.example: $([ -f .env.example ] && echo "存在" || echo "なし")"
echo ""

# 4. 実行権限確認
echo "🔑 4. 実行権限確認"
echo "system/setup.sh: $(ls -l system/setup.sh | cut -d' ' -f1)"
echo "system/discord_bot_manager.sh: $(ls -l system/discord_bot_manager.sh | cut -d' ' -f1)"
echo "system/agent-send.sh: $(ls -l system/agent-send.sh | cut -d' ' -f1)"
echo ""

# 5. 推奨操作コマンド
echo "🚀 5. 推奨操作コマンド（プロジェクトルートから）"
echo ""
echo "【初回セットアップ】"
echo "  cp .env.example .env"
echo "  # .envを編集してAPI Keyを設定"
echo "  ./system/setup.sh"
echo ""
echo "【Discord Bot管理】"
echo "  ./system/discord_bot_manager.sh status    # 状態確認"
echo "  ./system/discord_bot_manager.sh start     # 起動"
echo "  ./system/discord_bot_manager.sh stop      # 停止"
echo "  ./system/discord_bot_manager.sh restart   # 再起動"
echo "  ./system/discord_bot_manager.sh setup     # 環境構築"
echo ""
echo "【エージェント操作】"
echo "  ./system/agent-send.sh gm \"メッセージ\"    # GMに送信"
echo "  ./system/agent-send.sh tl \"メッセージ\"    # TLに送信"
echo ""

echo "✅ テスト完了！"
