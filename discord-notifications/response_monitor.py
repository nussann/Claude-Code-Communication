#!/usr/bin/env python3
"""
Claude Code エージェント応答監視・Discord通知システム
tmuxセッションの出力を監視し、新しい応答をDiscordに送信
"""

import os
import sys
import asyncio
import re
import time
from datetime import datetime
from pathlib import Path

# discord_notify.pyをインポート
sys.path.append(os.path.dirname(__file__))
from discord_notify import notify

class AgentResponseMonitor:
    def __init__(self):
        self.monitored_agents = {
            'gm': {'session': 'gm', 'pane': '0'},
            'tl': {'session': 'team', 'pane': '0'},
            'st1': {'session': 'team', 'pane': '1'},
            'st2': {'session': 'team', 'pane': '2'},
            'st3': {'session': 'team', 'pane': '3'}
        }
        self.last_check_time = time.time()
        self.response_patterns = [
            r'👋.*',  # 挨拶
            r'✅.*',  # 完了メッセージ
            r'📋.*',  # 報告
            r'🔧.*',  # 作業中
            r'❌.*',  # エラー
            r'💡.*',  # 提案
            r'📊.*',  # 状況報告
            r'🚀.*',  # 開始
            r'⚠️.*',  # 警告
        ]

    async def get_tmux_pane_content(self, session: str, pane: str) -> str:
        """tmuxペインの内容を取得"""
        try:
            target = f"{session}:{pane}"

            # tmux capture-paneでペインの内容を取得
            process = await asyncio.create_subprocess_exec(
                'tmux', 'capture-pane', '-t', target, '-p',
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            stdout, stderr = await process.communicate()

            if process.returncode == 0:
                return stdout.decode('utf-8')
            else:
                print(f"⚠️ tmuxペイン取得エラー {target}: {stderr.decode('utf-8')}")
                return ""

        except Exception as e:
            print(f"❌ ペイン内容取得エラー: {e}")
            return ""

    def extract_new_responses(self, content: str, agent_name: str) -> list:
        """新しい応答を抽出"""
        lines = content.split('\n')
        new_responses = []

        for line in lines:
            line = line.strip()
            if not line:
                continue

            # パターンマッチング
            for pattern in self.response_patterns:
                if re.match(pattern, line):
                    # タイムスタンプを含むかチェック
                    if any(char.isdigit() for char in line):
                        new_responses.append({
                            'agent': agent_name,
                            'message': line,
                            'timestamp': datetime.now().strftime('%H:%M:%S')
                        })
                        break

        return new_responses

    async def send_response_to_discord(self, response: dict):
        """応答をDiscordに送信"""
        agent_name = response['agent'].upper()
        message = response['message']
        timestamp = response['timestamp']

        # Discordメッセージを整形
        discord_message = f"**🤖 {agent_name} からの応答** `{timestamp}`\n```\n{message}\n```"

        # Discord通知送信
        success = notify(discord_message, embed=True)

        if success:
            print(f"✅ Discord通知送信完了: {agent_name}")
        else:
            print(f"❌ Discord通知送信失敗: {agent_name}")

        return success

    async def monitor_agent(self, agent_name: str, config: dict):
        """特定エージェントを監視"""
        session = config['session']
        pane = config['pane']

        print(f"🔍 監視開始: {agent_name} ({session}:{pane})")

        previous_content = ""

        while True:
            try:
                # 現在のペイン内容を取得
                current_content = await self.get_tmux_pane_content(session, pane)

                # 前回との差分をチェック
                if current_content != previous_content:
                    # 新しい行を特定
                    new_lines = current_content.replace(previous_content, "").strip()

                    if new_lines:
                        # 新しい応答を抽出
                        responses = self.extract_new_responses(new_lines, agent_name)

                        # Discordに送信
                        for response in responses:
                            await self.send_response_to_discord(response)

                    previous_content = current_content

                # 3秒待機
                await asyncio.sleep(3)

            except Exception as e:
                print(f"❌ 監視エラー {agent_name}: {e}")
                await asyncio.sleep(5)

    async def start_monitoring(self):
        """全エージェントの監視を開始"""
        print("🚀 Claude Code 応答監視システム開始")
        print(f"監視対象: {', '.join(self.monitored_agents.keys())}")

        # 各エージェントを並行監視
        tasks = []
        for agent_name, config in self.monitored_agents.items():
            task = asyncio.create_task(
                self.monitor_agent(agent_name, config)
            )
            tasks.append(task)

        # 全タスクを並行実行
        try:
            await asyncio.gather(*tasks)
        except KeyboardInterrupt:
            print("\n🛑 監視を停止しています...")
            for task in tasks:
                task.cancel()

def main():
    """メイン関数"""
    monitor = AgentResponseMonitor()

    try:
        asyncio.run(monitor.start_monitoring())
    except KeyboardInterrupt:
        print("\n✅ 監視システムを終了しました")

if __name__ == "__main__":
    main()
