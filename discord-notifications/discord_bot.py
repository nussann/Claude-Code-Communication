import os
import asyncio
import discord
from discord.ext import commands
import subprocess
import json
import shlex
from datetime import datetime
from dotenv import load_dotenv

# メインの.envファイルを読み込み
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))

# Botの設定
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!cc ', intents=intents)

# 許可されたユーザーID（セキュリティのため）
AUTHORIZED_USERS = []  # 空の場合は全ユーザーが利用可能

# 自動転送設定
AUTO_FORWARD_ENABLED = True  # 全メッセージを自動転送
DEFAULT_AGENT = 'gm'  # デフォルトの転送先エージェント
RESPONSE_MONITORING = True  # Claude Codeからの応答監視

# Discord メッセージ長制限
DISCORD_MAX_LENGTH = 1900  # 安全マージンを含む

# 応答監視用グローバル変数
monitoring_tasks = {}
last_response_positions = {'gm': 0, 'tl': 0}
response_monitor_process = None  # 応答監視プロセス

class ClaudeCommunicationBot:
    def __init__(self):
        self.system_path = os.path.join(os.path.dirname(__file__), '..', 'system')
        self.agent_send_script = os.path.join(self.system_path, 'agent-send.sh')

        # スクリプトの存在確認
        if not os.path.exists(self.agent_send_script):
            raise FileNotFoundError(f"agent-send.sh not found: {self.agent_send_script}")

    def _sanitize_message(self, message: str) -> str:
        """メッセージの安全性を確保"""
        # 危険な文字を除去/エスケープ
        message = message.replace('\n', ' ').replace('\r', ' ')
        message = message.replace('`', "'").replace('$', '\\$')
        # 長さ制限
        if len(message) > 500:
            message = message[:497] + "..."
        return message

    def _truncate_output(self, text: str, max_length: int = DISCORD_MAX_LENGTH) -> str:
        """出力を安全な長さに切り詰め"""
        if len(text) <= max_length:
            return text

        truncated = text[:max_length - 50]
        return f"{truncated}\n... (出力が長すぎるため切り詰められました)"

    async def send_to_agent(self, agent: str, message: str):
        """エージェントにメッセージを送信（非同期）"""
        print(f"🔧 send_to_agent 開始: agent='{agent}', message='{message[:50]}...'")
        try:
            # メッセージの安全性確保
            safe_message = self._sanitize_message(message)
            print(f"🔒 安全化後のメッセージ: '{safe_message[:50]}...'")

            # スクリプトパスの確認
            print(f"📂 スクリプトパス: {self.agent_send_script}")
            print(f"📁 作業ディレクトリ: {self.system_path}")

            # 非同期でsubprocessを実行
            print(f"⚡ subprocess実行開始...")
            process = await asyncio.create_subprocess_exec(
                self.agent_send_script, agent, safe_message,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=self.system_path
            )

            # タイムアウト付きで実行
            try:
                print(f"⏳ プロセス実行中（最大30秒）...")
                stdout, stderr = await asyncio.wait_for(process.communicate(), timeout=30.0)
                stdout = stdout.decode('utf-8')
                stderr = stderr.decode('utf-8')
                print(f"📤 stdout: '{stdout}'")
                print(f"📤 stderr: '{stderr}'")
                print(f"📤 returncode: {process.returncode}")
            except asyncio.TimeoutError:
                print("⏰ タイムアウト発生 - プロセスを強制終了")
                process.kill()
                return "❌ タイムアウト: コマンドの実行に時間がかかりすぎました"

            if process.returncode == 0:
                print(f"✅ 送信成功")
                return f"✅ {agent}にメッセージを送信しました"
            else:
                error_msg = self._truncate_output(stderr) if stderr else "不明なエラー"
                print(f"❌ 送信失敗: {error_msg}")
                return f"❌ エラー: {error_msg}"

        except FileNotFoundError as e:
            print(f"❌ ファイルが見つかりません: {e}")
            return "❌ エラー: agent-send.shスクリプトが見つかりません"
        except Exception as e:
            print(f"❌ 予期しないエラー: {e}")
            return f"❌ 送信エラー: {str(e)}"

    async def get_system_status(self):
        """システムの状態を確認（非同期）"""
        try:
            # tmuxの存在確認
            tmux_check = await asyncio.create_subprocess_exec(
                'which', 'tmux',
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            await tmux_check.communicate()

            if tmux_check.returncode != 0:
                return "❌ tmuxがインストールされていません"

            # tmuxセッションの確認
            process = await asyncio.create_subprocess_exec(
                'tmux', 'list-sessions',
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )

            try:
                stdout, stderr = await asyncio.wait_for(process.communicate(), timeout=10.0)
                stdout = stdout.decode('utf-8')
            except asyncio.TimeoutError:
                return "❌ タイムアウト: tmuxの確認に時間がかかりすぎました"

            if process.returncode == 0:
                # 出力を安全な長さに制限
                safe_output = self._truncate_output(stdout)
                return f"🟢 システム稼働中\n```\n{safe_output}\n```"
            else:
                return "🔴 システム停止中（tmuxセッションが見つかりません）"

        except Exception as e:
            return f"❌ ステータス確認エラー: {str(e)}"

# Bot インスタンス
cc_bot = ClaudeCommunicationBot()

@bot.event
async def on_ready():
    print(f'{bot.user} が Discord に接続しました！')
    print('使用可能なコマンド:')
    print('!cc cchelp - ヘルプを表示')
    print('!cc status - システム状態を確認')
    print('!cc gm <メッセージ> - GMにメッセージを送信')
    print('!cc tl <メッセージ> - TLにメッセージを送信')
    print('!cc autoforward on/off - 自動転送切り替え')
    print('-' * 50)
    auto_status = "有効" if AUTO_FORWARD_ENABLED else "無効"
    print(f'🔄 自動転送機能: {auto_status}')
    print('📝 !ccプレフィックスなしでもメッセージを自動転送します')
    print('Discord接続完了 - コマンド待機中...')

@bot.event
async def on_message(message):
    """全メッセージを監視・自動転送"""
    # Botのメッセージは無視
    if message.author == bot.user:
        return

    # チャンネル情報
    channel_info = f"#{message.channel.name}" if hasattr(message.channel, 'name') else "DM"

    # メッセージの内容をログ出力
    print(f"\n📨 Discord メッセージ受信:")
    print(f"   チャンネル: {channel_info}")
    print(f"   ユーザー: {get_user_display_name(message.author)}")
    print(f"   内容: {message.content}")
    print(f"   時刻: {message.created_at.strftime('%Y-%m-%d %H:%M:%S')}")
    print("-" * 50)

    # 権限チェック
    if not is_authorized_user(message.author):
        print(f"⚠️ 非認証ユーザーからのメッセージ: {get_user_display_name(message.author)}")
        return

    # コマンド処理を先にチェック
    if message.content.startswith('!cc '):
        await bot.process_commands(message)
        return

    # 自動転送が有効で、通常のメッセージの場合
    if AUTO_FORWARD_ENABLED and message.content.strip():
        user_name = get_user_display_name(message.author)
        discord_info = f"[Discord: {user_name}]"

        # 送信先エージェントを決定（メッセージに基づいて）
        target_agent = determine_target_agent(message.content)

        full_message = f"{discord_info} {message.content}"

        print(f"🔄 自動転送開始: {target_agent} <- '{message.content[:50]}...'")

        # エージェントに自動転送
        result = await cc_bot.send_to_agent(target_agent, full_message)

        # 結果をDiscordに送信（簡潔版）
        if result.startswith("✅"):
            await message.add_reaction("✅")  # 成功時はリアクション
            print(f"✅ 自動転送完了: {target_agent}")
        else:
            await message.reply(f"転送結果: {result}")
            print(f"❌ 自動転送失敗: {result}")

    # コマンドとして処理もする（!ccプレフィックス用）
    await bot.process_commands(message)

def is_authorized(ctx):
    """ユーザーの認証チェック（コマンド用）"""
    if not AUTHORIZED_USERS:  # 空の場合は全ユーザーOK
        return True
    return ctx.author.id in AUTHORIZED_USERS

def is_authorized_user(user):
    """ユーザーの認証チェック（メッセージ用）"""
    if not AUTHORIZED_USERS:  # 空の場合は全ユーザーOK
        return True
    return user.id in AUTHORIZED_USERS

def determine_target_agent(message_content: str) -> str:
    """メッセージ内容に基づいて送信先エージェントを決定"""
    content_lower = message_content.lower()

    # キーワードベースの判定
    if any(keyword in content_lower for keyword in ['プロジェクト', 'project', '全体', '管理', 'マネジメント', '計画']):
        return 'gm'
    elif any(keyword in content_lower for keyword in ['タスク', 'task', 'チーム', 'team', 'リーダー', 'tl']):
        return 'tl'
    elif any(keyword in content_lower for keyword in ['実装', 'コード', 'code', 'バグ', 'bug', 'st', 'staff']):
        return 'tl'  # STは基本的にTL経由
    else:
        return DEFAULT_AGENT  # デフォルトはGM

@bot.command(name='cchelp')
async def help_command(ctx):
    """ヘルプコマンド"""
    print(f"🤖 コマンド実行: cchelp by {get_user_display_name(ctx.author)}")

    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    embed = discord.Embed(
        title="🤖 Claude-Code-Communication Bot",
        description="Discordから Claude Code システムをリモート操作",
        color=0x00ff00
    )

    embed.add_field(
        name="📊 システム管理",
        value="```\n!cc status - システム状態確認\n!cc setup - システムセットアップ\n```",
        inline=False
    )

    embed.add_field(
        name="👥 エージェント操作",
        value="```\n!cc gm <メッセージ> - GMに指示\n!cc tl <メッセージ> - TLに指示\n!cc st <メッセージ> - STsに指示\n!cc agent <エージェント> <メッセージ> - 直接指定\n```",
        inline=False
    )

    embed.add_field(
        name="🔄 自動転送機能",
        value="```\n!cc autoforward on/off - 自動転送切り替え\n（!ccなしでも全メッセージを自動転送）\n```",
        inline=False
    )

    embed.add_field(
        name="👁️ 応答監視機能",
        value="```\n!cc monitor start/stop - Claude応答監視\n（エージェントからの応答を自動転送）\n```",
        inline=False
    )

    embed.add_field(
        name="🚀 クイックコマンド",
        value="```\n!cc start <プロジェクト名> - プロジェクト開始\n!cc project <説明> - 新規プロジェクト作成\n```",
        inline=False
    )

    await ctx.send(embed=embed)
    print("✅ ヘルプ送信完了")

@bot.command(name='status')
async def status_command(ctx):
    """システム状態確認"""
    print(f"📊 コマンド実行: status by {get_user_display_name(ctx.author)}")

    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    status = await cc_bot.get_system_status()
    await ctx.send(status)
    print(f"✅ ステータス送信完了: {status[:50]}...")

def get_user_display_name(user):
    """ユーザーの表示名を取得（discriminator廃止対応）"""
    if hasattr(user, 'global_name') and user.global_name:
        return user.global_name
    return user.name

@bot.command(name='gm')
async def gm_command(ctx, *, message):
    """GMにメッセージ送信"""
    print(f"🚀 GMコマンド実行開始: {get_user_display_name(ctx.author)} -> '{message}'")

    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    # Discord情報を付加（discriminator廃止対応）
    user_name = get_user_display_name(ctx.author)
    discord_info = f"[Discord: {user_name}]"
    full_message = f"{discord_info} {message}"

    print(f"📤 GMに送信予定のメッセージ: '{full_message}'")
    result = await cc_bot.send_to_agent('gm', full_message)
    print(f"📥 GMからの応答: '{result}'")
    await ctx.send(result)
    print("✅ GMコマンド実行完了")

@bot.command(name='tl')
async def tl_command(ctx, *, message):
    """TLにメッセージ送信"""
    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    user_name = get_user_display_name(ctx.author)
    discord_info = f"[Discord: {user_name}]"
    full_message = f"{discord_info} {message}"

    result = await cc_bot.send_to_agent('tl', full_message)
    await ctx.send(result)

@bot.command(name='st')
async def st_command(ctx, *, message):
    """STsにメッセージ送信（TL経由）"""
    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    # STsには直接送らず、TL経由で送信
    user_name = get_user_display_name(ctx.author)
    discord_info = f"[Discord: {user_name}]"
    tl_message = f"{discord_info} STsに以下を指示してください: {message}"

    result = await cc_bot.send_to_agent('tl', tl_message)
    await ctx.send(result)

@bot.command(name='start')
async def start_command(ctx, *, project_name):
    """プロジェクト開始のクイックコマンド"""
    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    user_name = get_user_display_name(ctx.author)
    discord_info = f"[Discord: {user_name}]"
    gm_message = f"""{discord_info} あなたはGMです。

【プロジェクト開始指示】
プロジェクト名: {project_name}

このプロジェクトの開発を開始してください。
TLに適切な指示を出し、チーム全体でプロジェクトを進行させてください。"""

    result = await cc_bot.send_to_agent('gm', gm_message)
    await ctx.send(f"🚀 プロジェクト '{project_name}' を開始しました！\n{result}")

@bot.command(name='project')
async def project_command(ctx, *, description):
    """新規プロジェクト作成"""
    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    user_name = get_user_display_name(ctx.author)
    discord_info = f"[Discord: {user_name}]"
    gm_message = f"""{discord_info} あなたはGMです。

【新規プロジェクト作成】
プロジェクト説明: {description}

このプロジェクトの詳細を検討し、適切な実装計画を立てて開発を開始してください。
TLに具体的な作業指示を出し、チーム全体で効率的に進行させてください。"""

    result = await cc_bot.send_to_agent('gm', gm_message)
    await ctx.send(f"📁 新規プロジェクトを作成しました！\n{result}")

@bot.command(name='autoforward')
async def autoforward_command(ctx, action='status'):
    """自動転送設定の切り替え"""
    global AUTO_FORWARD_ENABLED

    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    if action.lower() == 'on':
        AUTO_FORWARD_ENABLED = True
        await ctx.send("🔄 自動転送を有効にしました。全てのメッセージが自動的にClaude Codeシステムに転送されます。")
    elif action.lower() == 'off':
        AUTO_FORWARD_ENABLED = False
        await ctx.send("⏸️ 自動転送を無効にしました。!ccコマンドのみ有効です。")
    else:
        status = "有効" if AUTO_FORWARD_ENABLED else "無効"
        await ctx.send(f"📊 自動転送状態: {status}\n使用方法: `!cc autoforward on/off`")

@bot.command(name='agent')
async def agent_command(ctx, agent_name=None, *, message=None):
    """指定エージェントに直接送信"""
    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    if not agent_name or not message:
        await ctx.send("❌ 使用方法: `!cc agent <gm|tl|st> <メッセージ>`")
        return

    valid_agents = ['gm', 'tl', 'st']
    if agent_name.lower() not in valid_agents:
        await ctx.send(f"❌ 無効なエージェント名: {agent_name}\n利用可能: {', '.join(valid_agents)}")
        return

    user_name = get_user_display_name(ctx.author)
    discord_info = f"[Discord: {user_name}]"
    full_message = f"{discord_info} {message}"

    result = await cc_bot.send_to_agent(agent_name.lower(), full_message)
    await ctx.send(result)

@bot.command(name='monitor')
async def monitor_command(ctx, action='status'):
    """応答監視機能の制御"""
    global response_monitor_process

    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    if action.lower() == 'start':
        if response_monitor_process is not None:
            await ctx.send("⚠️ 応答監視は既に実行中です。")
            return

        try:
            # 応答監視スクリプトを実行
            monitor_script = os.path.join(os.path.dirname(__file__), 'response_monitor.py')

            response_monitor_process = await asyncio.create_subprocess_exec(
                'python3', monitor_script,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=os.path.dirname(__file__)
            )

            await ctx.send("🔍 Claude Code応答監視を開始しました！\nエージェントからの応答が自動的にDiscordに送信されます。")
            print("✅ 応答監視プロセス開始")

        except Exception as e:
            await ctx.send(f"❌ 応答監視開始エラー: {str(e)}")
            response_monitor_process = None

    elif action.lower() == 'stop':
        if response_monitor_process is None:
            await ctx.send("⚠️ 応答監視は実行されていません。")
            return

        try:
            response_monitor_process.terminate()
            await response_monitor_process.wait()
            response_monitor_process = None
            await ctx.send("🛑 Claude Code応答監視を停止しました。")
            print("✅ 応答監視プロセス停止")

        except Exception as e:
            await ctx.send(f"❌ 応答監視停止エラー: {str(e)}")

    else:
        # ステータス確認
        if response_monitor_process is None:
            status = "停止中"
            status_emoji = "🔴"
        else:
            # プロセスがまだ生きているかチェック
            if response_monitor_process.returncode is None:
                status = "監視中"
                status_emoji = "🟢"
            else:
                status = "異常終了"
                status_emoji = "🔴"
                response_monitor_process = None

        await ctx.send(f"📊 応答監視状態: {status_emoji} {status}\n使用方法: `!cc monitor start/stop`")

@bot.command(name='setup')
async def setup_command(ctx):
    """システムセットアップ"""
    if not is_authorized(ctx):
        await ctx.send("❌ このBotを使用する権限がありません。")
        return

    await ctx.send("🔧 システムセットアップを開始します...")

    try:
        setup_script = os.path.join(cc_bot.system_path, 'setup.sh')

        # 非同期でsetup.shを実行
        process = await asyncio.create_subprocess_exec(
            setup_script,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=cc_bot.system_path
        )

        # タイムアウト付きで実行（セットアップは時間がかかる可能性がある）
        try:
            stdout, stderr = await asyncio.wait_for(process.communicate(), timeout=120.0)
            stdout = stdout.decode('utf-8')
            stderr = stderr.decode('utf-8')
        except asyncio.TimeoutError:
            process.kill()
            await ctx.send("❌ セットアップタイムアウト: 120秒以内に完了しませんでした")
            return

        if process.returncode == 0:
            await ctx.send("✅ システムセットアップが完了しました！")
        else:
            error_msg = cc_bot._truncate_output(stderr) if stderr else "不明なエラー"
            await ctx.send(f"❌ セットアップエラー: {error_msg}")

    except Exception as e:
        await ctx.send(f"❌ セットアップエラー: {str(e)}")

@bot.event
async def on_command_error(ctx, error):
    """エラーハンドリング"""
    if isinstance(error, commands.MissingRequiredArgument):
        await ctx.send("❌ 必要な引数が不足しています。`!cc cchelp` でヘルプを確認してください。")
    elif isinstance(error, commands.CommandNotFound):
        # コマンドが見つからない場合は無視（スパム防止）
        pass
    elif isinstance(error, commands.CommandInvokeError):
        # コマンド実行中のエラー
        await ctx.send(f"❌ コマンド実行エラーが発生しました。管理者に報告してください。")
        print(f"Command error: {error}")  # ログに記録
    else:
        await ctx.send(f"❌ 不明なエラーが発生しました。")
        print(f"Unexpected error: {error}")  # ログに記録

def main():
    """Botを起動"""
    token = os.getenv('DISCORD_BOT_TOKEN')
    if not token:
        print("❌ DISCORD_BOT_TOKENが設定されていません。")
        print("メインの.envファイルにDISCORD_BOT_TOKENを設定してください。")
        return

    try:
        print("🤖 Claude-Code-Communication Bot を起動中...")
        # Botインスタンスの初期化テスト
        global cc_bot
        cc_bot = ClaudeCommunicationBot()
        print("✅ Bot設定の初期化完了")

        bot.run(token)
    except FileNotFoundError as e:
        print(f"❌ 必要ファイルが見つかりません: {e}")
    except Exception as e:
        print(f"❌ Bot起動エラー: {e}")

if __name__ == "__main__":
    main()
