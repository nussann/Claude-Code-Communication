#!/usr/bin/env python3
"""
Discord通知機能のテストスクリプト
"""

import sys
import os
sys.path.append(os.path.dirname(__file__))

from discord_notify import notify

def test_discord_notification():
    """Discord通知のテスト"""
    print("🧪 Discord通知テスト開始")

    # テストメッセージ
    test_message = "**🤖 GM からの応答** `20:50:15`\n```\n✅ テストメッセージです。Discord通知システムが正常に動作しています。\n```"

    # 通知送信
    success = notify(test_message, embed=True)

    if success:
        print("✅ Discord通知送信成功")
    else:
        print("❌ Discord通知送信失敗")

    return success

if __name__ == "__main__":
    test_discord_notification()
