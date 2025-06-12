#!/usr/bin/env python3
"""Agent送信機能の直接テスト"""

import os
import asyncio
import sys
sys.path.append('/home/mikan/AutonomousClaudeCode/Claude-Code-Communication/discord-notifications')

from dotenv import load_dotenv
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

from discord_bot import ClaudeCommunicationBot

async def test_send():
    print("🧪 Agent送信テスト開始")

    try:
        bot = ClaudeCommunicationBot()
        print("✅ Bot初期化完了")

        # GMにテストメッセージ送信
        result = await bot.send_to_agent('gm', '[TEST] Discord Bot接続テスト')
        print(f"📋 結果: {result}")

    except Exception as e:
        print(f"❌ エラー: {e}")

if __name__ == "__main__":
    asyncio.run(test_send())
