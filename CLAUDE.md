# Agent Communication System

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **boss1** (multiagent:0.0): チームリーダー
- **worker1,2,3** (multiagent:0.1-3): 実行担当

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
PRESIDENT → boss1 → workers → boss1 → PRESIDENT

# コーディング方針

## 基本原則
- **モジュール性重視**: 機能ごとにファイル分割、責務を明確に分離
- **メインファイルは制御のみ**: ロジックはモジュール側に実装
- **エラーハンドリング必須**: try-except使用、loggingでログ出力
- **設定の外部化**: .envファイル使用、ハードコーディング禁止

## ディレクトリ構造
```
project_root/
├── src/          # メインコード（models/, services/, utils/, config/）
├── tests/        # テストコード
├── docs/         # 要件定義書・設計書を参照すること
├── scripts/      # ユーティリティスクリプト
└── CHANGELOG.md  # 変更は必ず記録
```
※Referencesディレクトリには新規ファイルを作成しない

## 開発ルール
- **仮想環境必須**: `uv`を使用（`uv venv`でセットアップ）
- **依存関係**: uvで管理（`uv pip install`、`uv pip compile`）
- **命名規則**: 関数=snake_case、クラス=PascalCase、定数=UPPER_CASE
- **型ヒント使用**: 引数と戻り値に型を明記
- **docstring必須**: 関数・クラスの説明を記載
- **インラインコマンド禁止**: セキュリティのため
- **出力確認**: バックグラウンドターミナルで確認

## 重要
- docs/の要件定義書とシステム設計書を必ず確認
- 新機能は既存モジュールへの統合を優先検討
- Don't hold back. Give it your all!
