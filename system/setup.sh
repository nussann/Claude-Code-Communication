#!/bin/bash

# 🚀 Multi-Agent Communication Demo 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo 環境構築"
echo "==========================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t team 2>/dev/null && log_info "teamセッション削除完了" || log_info "teamセッションは存在しませんでした"
tmux kill-session -t gm 2>/dev/null && log_info "gmセッション削除完了" || log_info "gmセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/st*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: teamセッション作成（4ペイン：boss1 + worker1,2,3）
log_info "📺 teamセッション作成開始 (4ペイン)..."

# 最初のペイン作成
tmux new-session -d -s team -n "agents"

# 2x2グリッド作成（合計4ペイン）
tmux split-window -h -t "team:0"      # 水平分割（左右）
tmux select-pane -t "team:0.0"
tmux split-window -v                        # 左側を垂直分割
tmux select-pane -t "team:0.2"
tmux split-window -v                        # 右側を垂直分割

# ペインタイトル設定
log_info "ペインタイトル設定中..."
PANE_TITLES=("TL" "ST" "ST" "ST")

for i in {0..3}; do
    tmux select-pane -t "team:0.$i" -T "${PANE_TITLES[$i]}"

    # 作業ディレクトリ設定
    tmux send-keys -t "team:0.$i" "cd $(pwd)" C-m

    # カラープロンプト設定
    if [ $i -eq 0 ]; then
        # TL: 赤色
        tmux send-keys -t "team:0.$i" "export PS1='(\[\033[1;31m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    else
        # STs: 青色
        tmux send-keys -t "team:0.$i" "export PS1='(\[\033[1;34m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    fi

    # ウェルカムメッセージ
    tmux send-keys -t "team:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント ==='" C-m
done

log_success "✅ teamセッション作成完了"
echo ""

# STEP 3: gmセッション作成（1ペイン）
log_info "👑 gmセッション作成開始..."

tmux new-session -d -s gm
tmux send-keys -t gm "cd $(pwd)" C-m
tmux send-keys -t gm "export PS1='(\[\033[1;35m\]GM\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t gm "echo '=== GM セッション ==='" C-m
tmux send-keys -t gm "echo 'ジェネラルマネージャー'" C-m
tmux send-keys -t gm "echo '========================'" C-m

log_success "✅ gmセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
echo "  teamセッション（4ペイン）:"
echo "    Pane 0: TL      (チームリーダー)"
echo "    Pane 1: ST      (スタッフ)"
echo "    Pane 2: ST      (スタッフ)"
echo "    Pane 3: ST      (スタッフ)"
echo ""
echo "  gmセッション（1ペイン）:"
echo "    Pane 0: GM (ジェネラルマネージャー)"

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t team   # マルチエージェント確認"
echo "     tmux attach-session -t gm    # プレジデント確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # 手順1: President認証"
echo "     tmux send-keys -t gm 'claude' C-m"
echo "     # 手順2: 認証後、team一括起動"
echo "     for i in {0..3}; do tmux send-keys -t team:0.\$i 'claude' C-m; done"
echo ""
echo "  3. 📜 指示書確認:"
echo "     GM: instructions/gm.md"
echo "     boss1: instructions/boss.md"
echo "     worker1,2,3: instructions/worker.md"
echo "     システム構造: CLAUDE.md"
echo ""
echo "  4. 🎯 デモ実行: GMに「あなたはgmです。指示書に従って」と入力"
echo ""
echo "  5. 🤖 Discord Bot:"
echo "     自動起動済み - Discord経由でリモート操作可能"

# STEP 5: Discord Bot自動起動
log_info "🤖 Discord Bot自動起動中..."

# Discord Bot管理スクリプトを使用（相対パス）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCORD_MANAGER="$SCRIPT_DIR/discord_bot_manager.sh"

if [ -f "$DISCORD_MANAGER" ]; then
    # まず仮想環境セットアップを実行
    log_info "Discord Bot環境確認中..."
    "$DISCORD_MANAGER" setup

    if [ $? -eq 0 ]; then
        # セットアップ成功後、起動
        "$DISCORD_MANAGER" start
        if [ $? -eq 0 ]; then
            log_success "✅ Discord Bot起動完了"
            echo "    📱 Discordからの操作が可能です"
            echo "    💬 自動転送機能: 有効"
            echo "    🔧 コマンド: !cc cchelp でヘルプ表示"
        else
            log_info "⚠️ Discord Bot起動に失敗しました"
        fi
    else
        log_info "⚠️ Discord Bot環境セットアップに失敗しました"
    fi
else
    log_info "⚠️ Discord Bot管理スクリプトが見つかりません ($DISCORD_MANAGER)"
fi

echo ""
log_success "🎉 完全統合セットアップ完了！"
echo ""
echo "📱 Discord統合機能:"
echo "  ✅ 自動転送: Discordメッセージ → Claude Code"
echo "  🔄 応答監視: Claude Code → Discord (要: !cc monitor start)"
echo "  🎮 リモート操作: Discord経由でシステム制御"
echo ""
echo "🔧 Discord Bot管理:"
echo "  起動: ./system/discord_bot_manager.sh start"
echo "  停止: ./system/discord_bot_manager.sh stop"
echo "  状態: ./system/discord_bot_manager.sh status"
