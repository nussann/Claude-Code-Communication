# Claude-Code-Communication Makefile追加履歴

## 📅 2025-06-18: Makefile自動起動システム追加・修正版

### � 重要な修正
**問題**: tmuxセッション作成後、セッションアタッチせずにClaudeコマンドを送信していたため正常に動作しない
**解決**: セッション作成とClaude起動を分離し、適切な手順で実行するよう修正

### �🚀 追加機能

#### ⭐ 推奨コマンド
- `make all`: ワンコマンド完全起動（セッション作成→表示→手動Claude起動）

#### 基本コマンド
- `make start`: システム初期化（setup.sh実行）
- `make setup-only`: セッション作成のみ（Claude起動なし）
- `make start-a`: システム初期化 + GM Claude起動
- `make start-b`: Team全Claude起動（start-a実行後）

#### 🤖 自動化コマンド
- `make auto-start`: セッション作成（手動アタッチ必要）
- `make activate-all`: Claude一括起動（セッション作成済み前提）
- `make auto-attach`: 自動セッション表示（選択式・Claude自動起動オプション付き）
- `make vscode-attach`: VS Code専用セッション表示

#### 個別操作
- `make attach-team`: teamセッションアタッチ
- `make attach-gm`: gmセッションアタッチ
- `make activate-gm`: GM Claude起動
- `make activate-team`: Team全Claude起動

#### 📊 管理機能
- `make status`: tmuxセッション状態確認
- `make monitor`: リアルタイムセッション監視
- `make clean`: tmuxセッション削除
- `make help`: 使用可能コマンド表示

### 🎯 使用方法

#### 🌟 最も簡単な方法
```bash
make all        # セッション作成→表示→手動Claude起動指示
```

#### 🔧 段階的実行（推奨）
```bash
make setup-only    # 1. セッション作成のみ
make auto-attach   # 2. セッション表示（Claude自動起動オプション付き）
```

#### 完全手動制御
```bash
make setup-only      # 1. セッション作成
make attach-team     # 2. teamセッションアタッチ（別ターミナル）
make attach-gm       # 3. gmセッションアタッチ（別ターミナル）
make activate-all    # 4. Claude一括起動
```

### 📝 更新ファイル
- `Makefile`: 新規作成（拡張版）
- `scripts/auto_attach.sh`: 自動セッション表示スクリプト
- `scripts/vscode_auto_attach.sh`: VS Code専用表示スクリプト
- `CLAUDE.md`: Makefile起動管理説明追加
- `README.md`: クイックスタート部分をMakefile対応に更新

### 🔧 技術的詳細
- tmuxセッション自動化
- 複数ターミナルエミュレータ対応
- VS Code統合ターミナル対応
- リアルタイムセッション監視
- エラーハンドリング付きコマンド実行
- 分離可能な起動フェーズ
- 安全なセッション管理

### ⚠️ 注意事項
- tmuxが必要（setup.shで自動構築）
- Claude Codeが事前にインストールされている必要あり
- 既存のteam/gmセッションは自動削除される
- VS Code環境で最適化されているが、他のターミナルでも動作
