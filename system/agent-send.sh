#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "gm") echo "gm" ;;
        "tl") echo "team:0.0" ;;
        "st1") echo "team:0.1" ;;
        "st2") echo "team:0.2" ;;
        "st3") echo "team:0.3" ;;
        "st") echo "team:0.1" ;;  # デフォルトでst1ペインに送信
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  gm  - ジェネラルマネージャー
  tl  - チームリーダー  
  st  - スタッフ（デフォルト：ペイン1）
  st1 - スタッフ（ペイン1）
  st2 - スタッフ（ペイン2）
  st3 - スタッフ（ペイン3）

使用例:
  $0 gm "指示書に従って"
  $0 tl "Hello World プロジェクト開始指示"
  $0 st "作業完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    echo "  gm  → gm:0        (ジェネラルマネージャー)"
    echo "  tl  → team:0.0    (チームリーダー)"
    echo "  st  → team:0.1    (スタッフ・デフォルト)"
    echo "  st1 → team:0.1    (スタッフ・ペイン1)"
    echo "  st2 → team:0.2    (スタッフ・ペイン2)" 
    echo "  st3 → team:0.3    (スタッフ・ペイン3)"
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 