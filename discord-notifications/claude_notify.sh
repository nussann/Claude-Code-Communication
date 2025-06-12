#!/bin/bash
# claude_notify.sh

TASK="$*"

if [ -z "$TASK" ]; then
    echo "使い方: $0 タスク名"
    exit 1
fi

# 開始通知
python3 -c "from discord_notify import notify; notify('🚀 開始: $TASK')"

# Claude Code実行（ここは実際のClaude Codeの実行コマンドに置き換える）
# claude-code "$TASK"
echo "📝 実行中: $TASK"
sleep 2  # デモ用の待機時間

# 結果通知
if [ $? -eq 0 ]; then
    python3 -c "from discord_notify import notify; notify('✅ 完了: $TASK')"
else
    python3 -c "from discord_notify import notify; notify('❌ 失敗: $TASK')"
fi
