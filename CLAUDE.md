# Claude-Code-Communication システム

## エージェント構成
- **GM** (gmセッション): ジェネラルマネージャー・統括責任者
- **TL** (team:0.0): チームリーダー・品質管理
- **ST** (team:0.1-3): スタッフ・実装担当

## あなたの役割
- **GM**: @GM/CLAUDE.md
- **TL**: @TL/CLAUDE.md
- **ST**: @ST/CLAUDE.md

## メッセージ送信
```bash
./system/agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
GM → TL → STs → TL → GM

## システム構造

### ディレクトリ構成
```
Claude-Code-Communication/
├── system/              # システムファイル
│   ├── setup.sh        # tmux環境セットアップ
│   ├── agent-send.sh   # エージェント間通信
│   └── setup-role.sh   # 役割管理
├── GM/                 # GM役割コンテキスト
├── TL/                 # TL役割コンテキスト
├── ST/                 # ST役割コンテキスト
└── shared-projects/    # 実際のプロジェクトファイル
```

### セッション管理
- **gmセッション**: 1ペイン (GM専用)
- **teamセッション**: 4ペイン (TL + ST x3)

### 役割分担
- **GM**: 全体統括・品質最終確認・方針決定
- **TL**: チーム管理・タスク配分・進捗管理・品質管理
- **ST**: 実装作業・単体テスト・品質確認

## 通信プロトコル

### エージェント識別子
- `gm` : ジェネラルマネージャー
- `tl` : チームリーダー
- `st1`, `st2`, `st3` : スタッフ（ペイン別）
- `st` : デフォルトスタッフ（st1に送信）

### メッセージ形式
```bash
# 基本送信
./system/agent-send.sh <target> "<message>"

# 使用例
./system/agent-send.sh gm "プロジェクト完了報告"
./system/agent-send.sh tl "品質確認完了"
./system/agent-send.sh st1 "実装作業完了"
```

## プロジェクト管理

### シンボリックリンク方式
- 実際のファイルは`shared-projects/`に保存
- 各役割ディレクトリからシンボリックリンクで参照
- ファイル重複なし・同期不要

### 役割管理自動化
```bash
# 新しい役割作成
./system/setup-role.sh create <役割名> <説明>

# プロジェクトリンク
./system/setup-role.sh link <役割名> <プロジェクト名>

# プロジェクト作成
./system/setup-role.sh create_project <プロジェクト名>
```

## 重要な注意事項

## システム起動管理（Makefile）

### 基本的な起動フロー
```bash
# 1. システム初期化
make start

# 2. 別ターミナルでアタッチ
make attach-team  # teamセッション
make attach-gm    # gmセッション

# 3. Claude起動
make activate-gm   # GM Claude起動
make activate-team # Team全Claude起動
```

### 自動化オプション
```bash
# GM起動まで自動実行
make start-a

# Team全Claude起動（start-a実行後）
make start-b
```

### 管理コマンド
```bash
make status    # セッション状態確認
make clean     # セッション削除
make help      # ヘルプ表示
```

### ログ管理
