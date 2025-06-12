#!/bin/bash
# Discord Bot管理スクリプト

# スクリプトの場所を基準に相対パス設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DISCORD_DIR="$PROJECT_ROOT/discord-notifications"
PID_FILE="$DISCORD_DIR/discord_bot.pid"

# ログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# 仮想環境セットアップ関数
setup_venv() {
    log_info "🔧 Discord Bot仮想環境セットアップ中..."

    cd "$DISCORD_DIR"

    # Python3の存在確認
    if ! command -v python3 &> /dev/null; then
        log_error "Python3がインストールされていません"
        return 1
    fi

    # 仮想環境作成
    if [ ! -d "venv" ]; then
        log_info "仮想環境作成中..."
        python3 -m venv venv
        if [ $? -ne 0 ]; then
            log_error "仮想環境の作成に失敗しました"
            return 1
        fi
        log_success "仮想環境作成完了"
    fi

    # 依存関係インストール
    if [ -f "requirements.txt" ]; then
        log_info "依存関係インストール中..."
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
        if [ $? -eq 0 ]; then
            log_success "依存関係インストール完了"
        else
            log_error "依存関係のインストールに失敗しました"
            return 1
        fi
    else
        log_error "requirements.txtが見つかりません"
        return 1
    fi

    return 0
}

case "$1" in
    "setup")
        echo "🔧 Discord Bot環境セットアップ"
        if [ ! -d "$DISCORD_DIR" ]; then
            log_error "Discord notificationsディレクトリが見つかりません: $DISCORD_DIR"
            exit 1
        fi
        setup_venv
        ;;

    "start")
        echo "🤖 Discord Bot 起動中..."

        # ディレクトリ存在確認
        if [ ! -d "$DISCORD_DIR" ]; then
            log_error "Discord notificationsディレクトリが見つかりません: $DISCORD_DIR"
            exit 1
        fi

        cd "$DISCORD_DIR"

        # 仮想環境確認・セットアップ
        if [ ! -d "venv" ] || [ ! -f "venv/bin/activate" ]; then
            log_info "仮想環境が見つかりません。セットアップします..."
            setup_venv
            if [ $? -ne 0 ]; then
                log_error "仮想環境のセットアップに失敗しました"
                exit 1
            fi
        fi

        # 既存プロセス確認
        if [ -f "$PID_FILE" ]; then
            OLD_PID=$(cat "$PID_FILE")
            if kill -0 "$OLD_PID" 2>/dev/null; then
                echo "⚠️ Discord Bot は既に動作中です (PID: $OLD_PID)"
                exit 1
            else
                rm -f "$PID_FILE"
            fi
        fi

        # 起動
        source venv/bin/activate
        python discord_bot.py &
        echo $! > "$PID_FILE"

        sleep 2
        if kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            log_success "Discord Bot 起動完了 (PID: $(cat "$PID_FILE"))"
        else
            log_error "Discord Bot 起動失敗"
            rm -f "$PID_FILE"
            exit 1
        fi
        ;;

    "stop")
        echo "🛑 Discord Bot 停止中..."
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                kill "$PID"
                rm -f "$PID_FILE"
                log_success "Discord Bot 停止完了"
            else
                echo "⚠️ プロセスが見つかりません"
                rm -f "$PID_FILE"
            fi
        else
            echo "⚠️ PIDファイルが見つかりません"
            # 念のため名前でkill
            pkill -f discord_bot.py && log_success "Discord Bot プロセスを停止しました"
        fi
        ;;

    "status")
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                echo "🟢 Discord Bot 動作中 (PID: $PID)"
            else
                echo "🔴 Discord Bot 停止中 (PIDファイルが古い)"
                rm -f "$PID_FILE"
            fi
        else
            if pgrep -f discord_bot.py > /dev/null; then
                echo "🟡 Discord Bot 動作中 (PIDファイルなし)"
            else
                echo "🔴 Discord Bot 停止中"
            fi
        fi
        ;;

    "restart")
        $0 stop
        sleep 2
        $0 start
        ;;

    *)
        echo "使用方法: $0 {setup|start|stop|status|restart}"
        echo ""
        echo "コマンド説明:"
        echo "  setup   - 仮想環境と依存関係をセットアップ"
        echo "  start   - Discord Bot起動（必要に応じて自動セットアップ）"
        echo "  stop    - Discord Bot停止"
        echo "  status  - Discord Bot状態確認"
        echo "  restart - Discord Bot再起動"
        exit 1
        ;;
esac
