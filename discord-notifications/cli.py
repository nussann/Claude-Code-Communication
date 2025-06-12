import sys
from discord_notify import notify

if __name__ == "__main__":
    if len(sys.argv) > 1:
        message = " ".join(sys.argv[1:])
        if notify(message):
            print("✅ 送信完了")
        else:
            sys.exit(1)
    else:
        print("使い方: python cli.py メッセージ")
