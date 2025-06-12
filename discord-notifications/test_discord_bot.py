#!/usr/bin/env python3

"""
Discord Bot のバグチェック・テストスクリプト
"""

import sys
import os

# パスを追加
sys.path.insert(0, '/home/mikan/AutonomousClaudeCode/Claude-Code-Communication/discord-notifications')

def test_imports():
    """必要なライブラリのインポートテスト"""
    print("📦 インポートテスト開始...")

    try:
        import discord
        print("✅ discord.py インポート成功")
    except ImportError as e:
        print(f"❌ discord.py インポートエラー: {e}")
        return False

    try:
        from dotenv import load_dotenv
        print("✅ python-dotenv インポート成功")
    except ImportError as e:
        print(f"❌ python-dotenv インポートエラー: {e}")
        return False

    try:
        import discord_bot
        print("✅ discord_bot インポート成功")
    except Exception as e:
        print(f"❌ discord_bot インポートエラー: {e}")
        return False

    return True

def test_bot_initialization():
    """Bot初期化テスト"""
    print("\n🤖 Bot初期化テスト開始...")

    try:
        import discord_bot
        bot_instance = discord_bot.ClaudeCommunicationBot()
        print("✅ Bot初期化成功")
        return True
    except FileNotFoundError as e:
        print(f"⚠️  ファイル未発見（正常）: {e}")
        return True  # これは正常（agent-send.shがない環境では期待される）
    except Exception as e:
        print(f"❌ Bot初期化エラー: {e}")
        return False

def test_user_display_name():
    """ユーザー名取得関数テスト"""
    print("\n👤 ユーザー名取得テスト開始...")

    try:
        import discord_bot

        # モックユーザーを作成
        class MockUser:
            def __init__(self, name, global_name=None):
                self.name = name
                self.global_name = global_name

        # テストケース1: global_nameがない場合
        user1 = MockUser('testuser')
        result1 = discord_bot.get_user_display_name(user1)
        expected1 = 'testuser'
        assert result1 == expected1, f"期待値: {expected1}, 実際: {result1}"
        print(f"✅ テスト1成功: {result1}")

        # テストケース2: global_nameがある場合
        user2 = MockUser('testuser', 'TestGlobalName')
        result2 = discord_bot.get_user_display_name(user2)
        expected2 = 'TestGlobalName'
        assert result2 == expected2, f"期待値: {expected2}, 実際: {result2}"
        print(f"✅ テスト2成功: {result2}")

        return True
    except Exception as e:
        print(f"❌ ユーザー名取得テストエラー: {e}")
        return False

def test_message_sanitization():
    """メッセージサニタイゼーションテスト"""
    print("\n🧹 メッセージサニタイゼーションテスト開始...")

    try:
        import discord_bot
        bot_instance = discord_bot.ClaudeCommunicationBot()

        # 危険な文字列のテスト
        dangerous_message = "test message with\nnewlines\rand`backticks$variables"
        safe_message = bot_instance._sanitize_message(dangerous_message)

        # 改行が除去されているかチェック
        assert '\n' not in safe_message, "改行が除去されていません"
        assert '\r' not in safe_message, "キャリッジリターンが除去されていません"
        print(f"✅ サニタイゼーション成功: {safe_message}")

        # 長いメッセージのテスト
        long_message = "A" * 1000
        truncated = bot_instance._sanitize_message(long_message)
        assert len(truncated) <= 500, "メッセージが切り詰められていません"
        print(f"✅ 長いメッセージの切り詰め成功: {len(truncated)}文字")

        return True
    except Exception as e:
        print(f"❌ メッセージサニタイゼーションエラー: {e}")
        return False

def main():
    """メインテスト実行"""
    print("🔍 Discord Bot バグチェック開始")
    print("=" * 50)

    tests = [
        test_imports,
        test_bot_initialization,
        test_user_display_name,
        test_message_sanitization
    ]

    passed = 0
    failed = 0

    for test in tests:
        try:
            if test():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            print(f"❌ テスト実行エラー: {e}")
            failed += 1

    print("\n" + "=" * 50)
    print(f"📊 テスト結果: ✅ {passed}個成功, ❌ {failed}個失敗")

    if failed == 0:
        print("🎉 全テスト成功！Botは正常に動作する可能性が高いです。")
    else:
        print("⚠️  一部テストが失敗しました。修正が必要です。")

if __name__ == "__main__":
    main()
