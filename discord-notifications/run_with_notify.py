import subprocess
import sys
from discord_notify import notify

def run_claude_code(task: str):
    notify(f"🚀 開始: {task}")

    # 実際のClaude Codeの実行（現在はデモ用のコマンド）
    result = subprocess.run(
        ["echo", f"実行中: {task}"],
        capture_output=True,
        text=True
    )

    if result.returncode == 0:
        notify(f"✅ 完了: {task}")
    else:
        notify(f"❌ 失敗: {task}\nエラー: {result.stderr}")

    return result.returncode

if __name__ == "__main__":
    if len(sys.argv) > 1:
        task = " ".join(sys.argv[1:])
        exit(run_claude_code(task))
    else:
        print("使い方: python run_with_notify.py タスク名")
