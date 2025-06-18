# Claude-Code-Communication Makefile
# 多エージェント協調フレームワークの起動管理

.PHONY: start start-a start-b attach-team attach-gm activate-gm activate-team help clean status auto-start auto-attach vscode-attach monitor all setup-only activate-all quick-start team gm

# デフォルトターゲット
help:
	@echo "📋 Claude-Code-Communication システム管理"
	@echo ""
	@echo "⭐ 推奨コマンド:"
	@echo "  make all         - ワンコマンド完全起動（起動→Claude自動起動）"
	@echo "  make quick-start - 最速起動（setup + Claude起動のみ）"
	@echo ""
	@echo "🚀 基本コマンド:"
	@echo "  make start     - システム初期化（setup.shを実行）"
	@echo "  make setup-only - セッション作成のみ（Claude起動なし）"
	@echo "  make start-a   - システム初期化 + GM Claudeを起動"
	@echo "  make start-b   - Team全Claude起動（先にstart-aの実行が必要）"
	@echo ""
	@echo "🤖 自動化コマンド:"
	@echo "  make auto-start      - セッション作成（手動アタッチ必要）"
	@echo "  make activate-all    - Claude一括起動（セッション作成済み前提）"
	@echo "  make auto-attach     - 自動セッション表示（選択式）"
	@echo "  make vscode-attach   - VS Code専用セッション表示"
	@echo "  make vscode-full-auto - VS Code完全自動化"
	@echo ""
	@echo "🔧 個別操作:"
	@echo "  make team        - teamセッションにアタッチ（簡単）"
	@echo "  make gm          - gmセッションにアタッチ（簡単）"
	@echo "  make attach-team - teamセッションにアタッチ"
	@echo "  make attach-gm   - gmセッションにアタッチ"
	@echo "  make activate-gm - GM Claudeを起動"
	@echo "  make activate-team - Team全Claudeを起動"
	@echo ""
	@echo "📊 ステータス確認:"
	@echo "  make status    - tmuxセッション状態確認"
	@echo "  make monitor   - リアルタイムセッション監視"
	@echo "  make clean     - tmuxセッション削除"

# システム初期化（setup.shを実行）
start:
	@echo "🚀 Claude-Code-Communication システム初期化を開始..."
	@echo "📝 setup.shを実行中..."
	@./system/setup.sh
	@echo ""
	@echo "✅ システム初期化完了！"
	@echo ""
	@echo "📋 次のステップ:"
	@echo "  1. 別ターミナルで: make attach-team"
	@echo "  2. 別ターミナルで: make attach-gm"
	@echo "  3. GM起動: make activate-gm"
	@echo "  4. Team起動: make activate-team"
	@echo ""
	@echo "または以下のコマンドで段階的実行:"
	@echo "  make start-a  # GM起動まで"
	@echo "  make start-b  # Team起動"

# システム初期化 + GM Claude起動
start-a:
	@echo "🚀 Claude-Code-Communication システム初期化（フェーズA）..."
	@echo "📝 setup.shを実行中..."
	@./system/setup.sh
	@echo ""
	@echo "⏳ セッション準備待機中（3秒）..."
	@sleep 3
	@echo "🤖 GM Claudeを起動中..."
	@tmux send-keys -t gm 'claude --dangerously-skip-permissions' C-m
	@echo ""
	@echo "✅ フェーズA完了！GM Claudeが起動しました"
	@echo ""
	@echo "📋 次のステップ:"
	@echo "  make start-b  # Team全Claude起動"
	@echo ""
	@echo "または手動でアタッチ:"
	@echo "  make attach-team"
	@echo "  make attach-gm"

# Team全Claude起動
start-b:
	@echo "🚀 Team全Claude起動（フェーズB）..."
	@echo "🤖 Team全メンバーのClaude起動中..."
	@for i in 0 1 2 3; do \
		echo "  └── Team:$$i Claude起動中..."; \
		tmux send-keys -t team:0.$$i 'claude --dangerously-skip-permissions' C-m; \
	done
	@echo ""
	@echo "✅ フェーズB完了！Team全Claude起動完了"
	@echo ""
	@echo "📋 アクセス方法:"
	@echo "  make attach-team  # teamセッションにアタッチ"
	@echo "  make attach-gm    # gmセッションにアタッチ"

# 完全自動起動（全セッション + Claude起動）
auto-start:
	@echo "🚀 Claude-Code-Communication 完全自動起動..."
	@echo "📝 setup.shを実行中..."
	@./system/setup.sh
	@echo ""
	@echo "⏳ セッション準備待機中（5秒）..."
	@sleep 5
	@echo ""
	@echo "⚠️  重要: 次の手順でClaude起動を完了してください"
	@echo ""
	@echo "📋 手動でセッションアタッチとClaude起動が必要です:"
	@echo "  1. 新しいターミナルで: make attach-team"
	@echo "  2. 別のターミナルで: make attach-gm"
	@echo "  3. 各セッションでClaude起動: make activate-gm && make activate-team"
	@echo ""
	@echo "または自動セッション表示:"
	@echo "  make auto-attach  # 自動セッション表示（推奨）"

# 自動セッション表示（スクリプト実行）
auto-attach:
	@echo "🖥️ 自動セッション表示を開始..."
	@echo "1" | ./scripts/auto_attach.sh

# VS Code専用簡易セッション表示
vscode-attach:
	@echo "🚀 VS Code専用セッション表示を開始..."
	@./scripts/vscode_auto_attach.sh

# teamセッションにアタッチ
attach-team:
	@echo "📊 teamセッションにアタッチ中..."
	@tmux attach-session -t team

# gmセッションにアタッチ
attach-gm:
	@echo "📊 gmセッションにアタッチ中..."
	@tmux attach-session -t gm

# GM Claudeを起動
activate-gm:
	@echo "🤖 GM Claudeを起動中..."
	@tmux send-keys -t gm 'claude --dangerously-skip-permissions' C-m
	@echo "✅ GM Claude起動完了"

# Team全Claudeを起動
activate-team:
	@echo "🤖 Team全メンバーのClaude起動中..."
	@for i in 0 1 2 3; do \
		echo "  └── Team:$$i Claude起動中..."; \
		tmux send-keys -t team:0.$$i 'claude --dangerously-skip-permissions' C-m; \
	done
	@echo "✅ Team全Claude起動完了"

# セッション作成のみ（Claude起動なし）
setup-only:
	@echo "🏗️ Claude-Code-Communication セッション作成のみ..."
	@echo "📝 setup.shを実行中..."
	@./system/setup.sh
	@echo ""
	@echo "✅ tmuxセッション作成完了！"
	@echo ""
	@echo "📋 次のステップ:"
	@echo "  1. make attach-team  # teamセッションアタッチ"
	@echo "  2. make attach-gm    # gmセッションアタッチ"
	@echo "  3. 各セッション内で手動でclaude --dangerously-skip-permissions"
	@echo ""
	@echo "または自動化:"
	@echo "  make auto-attach     # セッション表示"
	@echo "  make activate-all    # Claude一括起動"

# Claude一括起動（セッション作成済み前提）
activate-all:
	@echo "🤖 全Claudeを起動中..."
	@echo ""
	@if ! tmux has-session -t team 2>/dev/null || ! tmux has-session -t gm 2>/dev/null; then \
		echo "❌ セッションが見つかりません"; \
		echo "💡 まず 'make setup-only' または 'make start' を実行してください"; \
		exit 1; \
	fi
	@echo "🤖 GM Claudeを起動中..."
	@tmux send-keys -t gm 'claude --dangerously-skip-permissions' C-m
	@echo "🤖 Team全メンバーのClaude起動中..."
	@for i in 0 1 2 3; do \
		echo "  └── Team:$$i Claude起動中..."; \
		tmux send-keys -t team:0.$$i 'claude --dangerously-skip-permissions' C-m; \
	done
	@echo ""
	@echo "✅ 全Claude起動完了！"
	@echo ""
	@echo "📋 セッション確認:"
	@echo "  make status    # 状態確認"
	@echo "  make monitor   # リアルタイム監視"

# tmuxセッション状態確認
status:
	@echo "📊 tmuxセッション状態:"
	@echo ""
	@if tmux has-session -t team 2>/dev/null; then \
		echo "✅ team セッション: 起動中"; \
		tmux list-panes -t team -F "  ├── ペイン #{pane_index}: #{pane_current_command}"; \
	else \
		echo "❌ team セッション: 停止中"; \
	fi
	@echo ""
	@if tmux has-session -t gm 2>/dev/null; then \
		echo "✅ gm セッション: 起動中"; \
		tmux list-panes -t gm -F "  ├── ペイン #{pane_index}: #{pane_current_command}"; \
	else \
		echo "❌ gm セッション: 停止中"; \
	fi
	@echo ""

# tmuxセッション削除
clean:
	@echo "🧹 tmuxセッション削除中..."
	@if tmux has-session -t team 2>/dev/null; then \
		tmux kill-session -t team; \
		echo "✅ team セッション削除完了"; \
	else \
		echo "ℹ️  team セッションは存在しません"; \
	fi
	@if tmux has-session -t gm 2>/dev/null; then \
		tmux kill-session -t gm; \
		echo "✅ gm セッション削除完了"; \
	else \
		echo "ℹ️  gm セッションは存在しません"; \
	fi

# 開発者向け：セッション監視
monitor:
	@echo "🔍 セッション監視モードを開始..."
	@while true; do \
		clear; \
		echo "📊 Claude-Code-Communication セッション監視 ($(date))"; \
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		if tmux has-session -t team 2>/dev/null; then \
			echo "✅ team セッション: 起動中"; \
			tmux list-panes -t team -F "  ├── ペイン #{pane_index}: #{pane_current_command} [#{pane_pid}]"; \
		else \
			echo "❌ team セッション: 停止中"; \
		fi; \
		echo ""; \
		if tmux has-session -t gm 2>/dev/null; then \
			echo "✅ gm セッション: 起動中"; \
			tmux list-panes -t gm -F "  ├── ペイン #{pane_index}: #{pane_current_command} [#{pane_pid}]"; \
		else \
			echo "❌ gm セッション: 停止中"; \
		fi; \
		echo ""; \
		echo "💡 Ctrl+C で監視を停止"; \
		sleep 5; \
	done

# ワンコマンド完全起動（推奨）
all:
	@echo "🚀 Claude-Code-Communication ワンコマンド完全起動"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@$(MAKE) setup-only
	@echo ""
	@echo "⏳ セッション準備完了。Claude起動を開始..."
	@sleep 3
	@echo ""
	@echo "🤖 Claude一括起動中..."
	@$(MAKE) activate-all
	@echo ""
	@echo "✅ 完了！以下のコマンドでセッションにアタッチできます："
	@echo "  make team  # チームセッション（自動アタッチ）"
	@echo "  make gm    # GMセッション（自動アタッチ）"

# 超簡単アタッチコマンド
team:
	@echo "📊 teamセッションにアタッチ中..."
	@tmux attach-session -t team

gm:
	@echo "👑 gmセッションにアタッチ中..."
	@tmux attach-session -t gm

# 最速起動（setup + Claude起動）
quick-start:
	@echo "⚡ 最速起動モード"
	@$(MAKE) setup-only
	@sleep 2
	@$(MAKE) activate-all
	@echo ""
	@echo "🚀 起動完了！別ターミナルで以下を実行："
	@echo "  make team  # チームセッション"
	@echo "  make gm    # GMセッション"



