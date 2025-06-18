#!/bin/bash
# VS Code ターミナル自動作成スクリプト

echo "📊 teamセッション表示用ターミナルを作成中..."
echo "実行コマンド: tmux attach-session -t team"
echo ""
echo "別のターミナルで以下を実行してください:"
echo "  tmux attach-session -t gm"
echo ""
echo "セッションアタッチ後、以下でClaude一括起動:"
echo "  make activate-all"
