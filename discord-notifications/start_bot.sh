#!/bin/bash

# Discord Bot 起動スクリプト

echo "🤖 Claude-Code-Communication Discord Bot を起動します..."

# スクリプトのディレクトリに移動
cd "$(dirname "$0")"

# 仮想環境をアクティベート
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✅ 仮想環境をアクティベートしました"
else
    echo "❌ 仮想環境が見つかりません。requirements.txtからインストールしてください。"
    exit 1
fi

# 環境変数をチェック
if [ -z "$DISCORD_BOT_TOKEN" ]; then
    echo "⚠️  DISCORD_BOT_TOKENが設定されていません。"
    echo "メインの.envファイルを確認してください。"
fi

# Botを起動
echo "🚀 Discord Bot を起動中..."
python discord_bot.py
