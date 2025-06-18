#!/bin/bash

# vscode_auto_attach.sh - VS Code専用簡易セッション表示

echo "🚀 VS Code Claude-Code-Communication セッション表示"
echo ""

# セッション存在確認
if ! tmux has-session -t team 2>/dev/null || ! tmux has-session -t gm 2>/dev/null; then
    echo "❌ セッションが見つかりません"
    echo "💡 まず 'make auto-start' を実行してください"
    exit 1
fi

echo "📋 次の手順でセッションを表示してください:"
echo ""
echo "1. 新しいターミナルを開く (Ctrl+Shift+`)"
echo "2. 以下を実行: tmux attach-session -t team"
echo ""
echo "3. さらに新しいターミナルを開く"
echo "4. 以下を実行: tmux attach-session -t gm"
echo ""

# バックグラウンドでセッション監視を開始
echo "🔍 セッション状態監視を開始..."
echo ""

while true; do
    echo "📊 現在のセッション状態 ($(date +%H:%M:%S)):"

    if tmux has-session -t team 2>/dev/null; then
        echo "✅ team セッション: 起動中"
        tmux list-panes -t team -F "  ├── ペイン #{pane_index}: #{pane_current_command}"
    else
        echo "❌ team セッション: 停止中"
    fi

    if tmux has-session -t gm 2>/dev/null; then
        echo "✅ gm セッション: 起動中"
        tmux list-panes -t gm -F "  ├── ペイン #{pane_index}: #{pane_current_command}"
    else
        echo "❌ gm セッション: 停止中"
    fi

    echo ""
    echo "💡 Ctrl+C で監視を停止"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    sleep 10
done
