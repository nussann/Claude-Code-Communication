# 🤖 Claude-Code-Communication システム

Claude Code多エージェント協調フレームワーク - 役割分担による効率的なプロジェクト開発環境

## 🎯 システム概要

GM → TL → STs の階層型役割管理システムで、複数のClaude Codeインスタンスが協調してプロジェクト開発を行います

### 👥 エージェント構成

```
📊 gm セッション (1ペイン)
└── GM: ジェネラルマネージャー（プロジェクト統括責任者）

📊 team セッション (4ペイン)
├── TL: チームリーダー（チーム統括・品質管理）
├── ST: スタッフ（実装担当者A）
├── ST: スタッフ（実装担当者B）
└── ST: スタッフ（実装担当者C）
```

## 🚀 クイックスタート

### 0. リポジトリのクローン

```bash
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication
```

### 1. tmux環境構築

⚠️ **注意**: 既存の `team` と `gm` セッションがある場合は自動的に削除されます。

```bash
./system/setup.sh
```

### 2. セッションアタッチ

```bash
# チーム確認
tmux attach-session -t team

# GM確認（別ターミナルで）
tmux attach-session -t gm
```

### 3. Claude Code起動

**手順1: GM認証**
```bash
# まずGMで認証を実施
tmux send-keys -t gm 'claude' C-m
# Dangerous Skipモードでの実行
tmux send-keys -t gm 'claude --dangerously-skip-permissions' C-m
```
認証プロンプトに従って許可を与えてください。

**手順2: Team一括起動**
```bash
# 認証完了後、teamセッションを一括起動
for i in {0..3}; do tmux send-keys -t team:0.$i 'claude' C-m; done

# Dangerous Skipモードでの実行
for i in {0..3}; do tmux send-keys -t team:0.$i 'claude --dangerously-skip-permissions' C-m; done
```

### 4. システム実行

GMセッションで直接入力：
```
あなたはgmです。指示書に従って
```

## 📜 役割管理システム

### 役割別CLAUDE.md
- **GM**: `GM/CLAUDE.md` - プロジェクト統括責任者
- **TL**: `TL/CLAUDE.md` - チームリーダー・品質管理
- **ST**: `ST/CLAUDE.md` - スタッフ・実装担当

### システム構造
- **シンボリックリンク方式**: プロジェクトファイルを各役割で共有
- **コンテキスト最適化**: 役割固有の最小限指示のみ記載
- **システムファイル分離**: `system/`ディレクトリで管理
- **Git安全性**: `project/`ディレクトリは`.gitignore`で除外済み

**動作フロー:**
- **GM**: プロジェクト方針決定 → TLに指示送信
- **TL**: GM指示受信 → STs全員に作業配分 → 品質管理・完了報告
- **STs**: TL指示受信 → 実装作業 → 品質確認・完了報告

## 🎬 期待される動作フロー

```
1. GM → TL: "あなたはtlです。[プロジェクト名] 開始指示"
2. TL → STs: "あなたはstです。[具体的な作業内容] 実装開始"
3. STs → 実装作業 → 品質確認 → 最後のST → TL: "全員作業完了しました"
4. TL → GM: "品質確認済み完了しました"
```

## 🔧 手動操作

### system/agent-send.shを使った送信

```bash
# 基本送信
./system/agent-send.sh [エージェント名] [メッセージ]

# 例
./system/agent-send.sh gm "プロジェクト開始指示"
./system/agent-send.sh tl "品質確認完了"
./system/agent-send.sh st1 "実装作業完了しました"

# エージェント一覧確認
./system/agent-send.sh --list
```

## 🧪 確認・デバッグ

### ログ確認

```bash
# 送信ログ確認
cat logs/send_log.txt

# 特定エージェントのログ
grep "tl" logs/send_log.txt

# 完了ファイル確認
ls -la ./tmp/st*_done.txt
```

### セッション状態確認

```bash
# セッション一覧
tmux list-sessions

# ペイン一覧
tmux list-panes -t team
tmux list-panes -t gm
```

## 🔄 環境リセット

```bash
# セッション削除
tmux kill-session -t team
tmux kill-session -t gm

# 完了ファイル削除
rm -f ./tmp/st*_done.txt

# 再構築（自動クリア付き）
./system/setup.sh
```

---

## 🔧 役割管理拡張

### 新しいプロジェクトの作成（推奨）
```bash
# 新プロジェクト作成と全役割への自動リンク
./system/setup-role.sh -n web-app-project
./system/setup-role.sh -n my-awesome-project

# スペースを含む場合は引用符を使用
./system/setup-role.sh -n "my project with spaces"

# 作成後のプロジェクトアクセス
cd GM/project/web-app-project    # GMとして作業
cd TL/project/web-app-project    # TLとして作業  
cd ST/project/web-app-project    # STとして作業
```

### 手動での役割管理
```bash
# 新しい役割ディレクトリを作成
./system/setup-role.sh create <役割名> <説明>

# プロジェクトを役割にリンク
./system/setup-role.sh link <役割名> <プロジェクト名>

# 新しいプロジェクトを作成（リンクなし）
./system/setup-role.sh create_project <プロジェクト名>
```

### ディレクトリ構造
```
Claude-Code-Communication/
├── system/              # システムファイル
│   ├── setup.sh        # tmux環境セットアップ
│   ├── agent-send.sh   # エージェント間通信
│   └── setup-role.sh   # 役割管理
├── GM/                 # GM役割コンテキスト
│   ├── CLAUDE.md      # GM専用指示書
│   └── project/       # プロジェクトリンク（git除外対象）
├── TL/                 # TL役割コンテキスト
│   ├── CLAUDE.md      # TL専用指示書
│   └── project/       # プロジェクトリンク（git除外対象）
├── ST/                 # ST役割コンテキスト
│   ├── CLAUDE.md      # ST専用指示書
│   └── project/       # プロジェクトリンク（git除外対象）
├── shared-projects/    # 実際のプロジェクトファイル
│   └── demo-project/  # サンプルプロジェクト
└── instructions/       # 従来の指示書（参考用）
```

## 🔒 Git管理とセキュリティ

### プロジェクトファイルの管理方針
- **共有対象**: `shared-projects/demo-project/` のみgit管理
- **除外対象**: `*/project/` ディレクトリ（個人・テスト用プロジェクト）

### .gitignoreの設定
```gitignore
# プロジェクトディレクトリ（個人・テスト用プロジェクトを除外）
*/project/

# Claude Code設定（ローカル設定のみ）
.claude/settings.local.json
```

### 安全な開発フロー
1. **テスト・開発**: `*/project/` 内で自由に実験
2. **本格運用**: `shared-projects/` に正式プロジェクト作成
3. **Git管理**: 必要なもののみコミット・プッシュ

---

🚀 **高効率マルチエージェント開発を体感してください！** 🤖✨
