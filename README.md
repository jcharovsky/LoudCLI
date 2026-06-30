# LoudCLI

LoudCLI adds personalized sound cues and Telegram alerts to coding agent CLIs.

It is built for the common case where you leave an agent working on a task and do
not want to stay next to the terminal. LoudCLI can play a sound when a session
starts, when a task has been running for a while, and when a long task finishes.
For longer runs, it can also send a Telegram notification so you know the agent is
done even if you left the room or stepped away completely.

The default sound packs are GLaDOS and JARVIS, but the project is intended to be
personal. Replace the sounds with anything you want. Sites like
[Myinstants](https://www.myinstants.com/) are a good source for short audio clips.

## Features

- Sound cue when an agent session starts.
- Sound cue when an agent session ends.
- Delayed "task started" sound for prompts that keep running past 10 seconds.
- "Task finished" sound for runs that take at least 1 minute.
- Optional Telegram notification when a long task finishes.
- Includes hook examples for Claude Code and Gemini CLI.
- Ships with GLaDOS and JARVIS sound packs.

## Supported Agents

LoudCLI currently includes hook scripts for:

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [Gemini CLI](https://github.com/google-gemini/gemini-cli)

The project is just shell scripts, audio files, and hook configuration, so it can
be adapted to other agent CLIs that support lifecycle hooks.

## How It Works

LoudCLI connects to your agent's hook system:

| Event | Default behavior |
| --- | --- |
| Session start | Plays `Hello` sound |
| Session end | Plays `Bye` sound |
| Task start | Plays `Start` sound if the task is still running after 10 seconds |
| Task finish | Plays `Finish` sound and sends Telegram if the task took at least 1 minute |

The delay thresholds avoid noisy alerts for quick prompts.

## Installation

Clone the repository:

```bash
git clone <repo-url> LoudCLI
cd LoudCLI
```

Choose the agent you want to configure.

For Claude Code:

```bash
AGENT_HOME="$HOME/.claude"
SCRIPT_DIR="claude code"
```

For Gemini CLI:

```bash
AGENT_HOME="$HOME/.gemini"
SCRIPT_DIR="gemini"
```

Copy the hooks and sounds:

```bash
mkdir -p "$AGENT_HOME/hooks/sounds"
cp -r sounds/GLaDOS sounds/JARVIS "$AGENT_HOME/hooks/sounds/"
cp "$SCRIPT_DIR"/* "$AGENT_HOME/hooks/"
chmod +x "$AGENT_HOME"/hooks/*.sh
```

## Configure Hooks

Open `hooks.json` and copy the matching configuration into your agent settings
file:

- Claude Code: `~/.claude/settings.json`
- Gemini CLI: `~/.gemini/settings.json`

If your settings file already has a `hooks` object, merge the LoudCLI entries
into it instead of replacing the whole file.

Restart the agent after changing the settings.

## Configure Paths

The included scripts use the GLaDOS sound pack by default. If you install the
files somewhere else, update the paths in the shell scripts and `hooks.json`.

For example, Claude Code defaults to:

```bash
~/.claude/hooks/sounds/GLaDOS/Hello-2.aiff
~/.claude/hooks/sounds/GLaDOS/Start-2.aiff
~/.claude/hooks/sounds/GLaDOS/Finish-2.aiff
~/.claude/hooks/sounds/GLaDOS/Bye-2.aiff
```

Gemini CLI installs under `~/.gemini`, so make sure any copied scripts point to
`~/.gemini/hooks/...` when using Gemini.

## Customize Sounds

Each sound pack uses four files:

| File | Used for |
| --- | --- |
| `Hello` | Agent session started |
| `Start` | Agent task is taking longer than 10 seconds |
| `Finish` | Agent task finished after at least 1 minute |
| `Bye` | Agent session ended |

To create a custom pack:

1. Create a new folder under `sounds/`.
2. Add your four audio files.
3. Copy the folder into your agent hooks sound directory.
4. Update the hook scripts and `hooks.json` to point at the new files.

On macOS, `.aiff`, `.wav`, and many other formats can be played with `afplay`.

## Telegram Alerts

Telegram notifications are optional. Sounds work without them.

To enable Telegram:

1. Open Telegram and message [@BotFather](https://t.me/BotFather).
2. Create a bot with `/newbot`.
3. Copy the bot token.
4. Send any message to your new bot.
5. Get your chat ID:

```bash
curl -s "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates" | python3 -m json.tool
```

Look for the `chat.id` value in the response.

Then edit your copied `on-stop.sh` file:

```bash
TELEGRAM_BOT_TOKEN="PASTE_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="PASTE_CHAT_ID_HERE"
```

Test the bot manually:

```bash
curl -s -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/sendMessage" \
  -d chat_id="<YOUR_CHAT_ID>" \
  -d text="LoudCLI test notification."
```

## Platform Notes

LoudCLI is written for macOS by default and uses `afplay`.

For Linux, replace `afplay` in the scripts and hook config with an available
player such as:

```bash
paplay
aplay
mpv --no-video
```

For Windows or WSL, use a Windows-compatible audio command or convert the sound
files to a format supported by your player.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `claude code/` | Claude Code hook scripts |
| `gemini/` | Gemini CLI hook scripts |
| `hooks.json` | Hook configuration examples |
| `sounds/GLaDOS/` | Default GLaDOS sound pack |
| `sounds/JARVIS/` | Alternative JARVIS sound pack |
| `README.md` | Project documentation |

## License

No license has been added yet.
