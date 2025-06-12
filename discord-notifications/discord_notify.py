import os
import requests
from datetime import datetime
from typing import Optional, Dict
from dotenv import load_dotenv

# メインの.envファイルを読み込み（親ディレクトリの.env）
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

class DiscordNotifier:
    def __init__(self):
        self.webhook_url = os.getenv('DISCORD_WEBHOOK_URL')
        if not self.webhook_url:
            raise ValueError("DISCORD_WEBHOOK_URLを.envに設定してください")

    def send(self, message: str, embed: bool = True) -> bool:
        """
        メッセージを送信
        embed=Trueだと見た目がリッチになる
        """
        if embed:
            data = {
                "embeds": [{
                    "description": message,
                    "color": 5814783,  # 緑色
                    "timestamp": datetime.now().isoformat(),
                    "footer": {"text": "Claude Code"}
                }]
            }
        else:
            data = {"content": message}

        try:
            response = requests.post(self.webhook_url, json=data, timeout=10)
            return response.status_code == 204
        except Exception as e:
            print(f"❌ エラー: {e}")
            return False

# 便利関数
def notify(message: str, embed: bool = True):
    """使いやすいようにワンライナーで"""
    try:
        notifier = DiscordNotifier()
        return notifier.send(message, embed)
    except ValueError as e:
        print(e)
        return False
