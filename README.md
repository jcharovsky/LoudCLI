# LoudCLI

LoudCLI adds personalized sound cues and Telegram alerts to coding agent CLIs.

It is built for the common case where you leave an agent working on a task and do
not want to stay next to the terminal. LoudCLI can play a sound when work has
been running for a while, alert you when a long task finishes, and optionally
send a Telegram notification so you can step away from the computer.

The default sound packs are GLaDOS and JARVIS, but the project is intended to be
personal. Replace the sounds with anything you want. Sites like
[Myinstants](https://www.myinstants.com/) are a good source for short audio clips.

## Features

- Delayed "task started" sound for prompts that keep running past 10 seconds.
- "Task finished" sound for runs that take at least 1 minute.
- Optional Telegram notification when a long task finishes.
- Session start and session end sounds where the agent exposes those hooks.
- Hook examples for Claude Code, Google Antigravity, and Codex.
- GLaDOS and JARVIS sound packs.

## Supported Agents

LoudCLI currently includes hook scripts for:

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [Google Antigravity](https://antigravity.google/docs/hooks)
- [Codex](https://developers.openai.com/codex/hooks)

The project is just shell scripts, audio files, and hook configuration, so it can
be adapted to other agent CLIs that support lifecycle hooks.

## Hook Coverage

| Agent | Session start | Session end | Task start | Task finish |
| --- | --- | --- | --- | --- |
| Claude Code | Yes | Yes | Yes | Yes |
| Antigravity | No documented hook | No documented hook | Yes | Yes |
| Codex | Yes | No documented hook | Yes | Yes |

Task start plays after 10 seconds so quick prompts stay quiet. Task finish plays
only for runs that take at least 1 minute.

## Installation

Clone the repository:

```bash
git clone <repo-url> LoudCLI
cd LoudCLI
```

Then copy the scripts and sounds for the agent you use.

### Claude Code

```bash
AGENT_HOME="$HOME/.claude"
mkdir -p "$AGENT_HOME/hooks/sounds"
cp -r sounds/GLaDOS sounds/JARVIS "$AGENT_HOME/hooks/sounds/"
cp "claude code"/* "$AGENT_HOME/hooks/"
chmod +x "$AGENT_HOME"/hooks/*.sh
```

Merge the `claude-code.hooks` object from `hooks.json` into
`~/.claude/settings.json`.

### Antigravity

Antigravity loads hooks from a `hooks.json` file in a customization directory,
such as `~/.gemini/config/` or a workspace `.agents/` directory.

For a global install:

```bash
AGENT_HOME="$HOME/.gemini/config"
mkdir -p "$AGENT_HOME/hooks/sounds"
cp -r sounds/GLaDOS sounds/JARVIS "$AGENT_HOME/hooks/sounds/"
cp antigravity/*.sh "$AGENT_HOME/hooks/"
cp antigravity/hooks.json "$AGENT_HOME/hooks.json"
chmod +x "$AGENT_HOME"/hooks/*.sh
```

If you already have Antigravity hooks, merge the top-level entries from
`antigravity/hooks.json` into your existing `hooks.json`.

### Codex

Codex loads hooks from `~/.codex/hooks.json`, `~/.codex/config.toml`, or a
trusted project `.codex/` configuration layer.

For a global install:

```bash
AGENT_HOME="$HOME/.codex"
mkdir -p "$AGENT_HOME/hooks/sounds"
cp -r sounds/GLaDOS sounds/JARVIS "$AGENT_HOME/hooks/sounds/"
cp codex/*.sh "$AGENT_HOME/hooks/"
cp codex/hooks.json "$AGENT_HOME/hooks.json"
chmod +x "$AGENT_HOME"/hooks/*.sh
```

Codex requires command hooks to be reviewed and trusted before they run. Open
`/hooks` in Codex after installing or changing the hook definitions.

## Configure Paths

The included scripts use the GLaDOS sound pack by default. If you install the
files somewhere else, update the paths in the shell scripts and hook config.

Default sound locations:

| Agent | Default path |
| --- | --- |
| Claude Code | `~/.claude/hooks/sounds/GLaDOS/` |
| Antigravity | `~/.gemini/config/hooks/sounds/GLaDOS/` |
| Codex | `~/.codex/hooks/sounds/GLaDOS/` |

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
2. Add your audio files.
3. Copy the folder into your agent hooks sound directory.
4. Update the hook scripts and hook config to point at the new files.

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
| `antigravity/` | Google Antigravity hook scripts and config |
| `codex/` | Codex hook scripts and config |
| `hooks.json` | High-level hook example catalog |
| `sounds/GLaDOS/` | Default GLaDOS sound pack |
| `sounds/JARVIS/` | Alternative JARVIS sound pack |
| `README.md` | Project documentation |

## License

No license has been added yet.
