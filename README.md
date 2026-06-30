# GLaDOS - AI CLI Sound Hooks + Telegram Notifications

## What This Does

Plays GLaDOS-themed audio cues during AI CLI sessions (supports **Claude Code** and **Gemini CLI**) and sends Portal-themed Telegram notifications for long tasks:

| Event | Sound File | Trigger | Telegram |
|---|---|---|---|
| Session start | `Hello-2.aiff` | CLI launches | No |
| Session end | `Bye-2.aiff` | CLI exits | No |
| Task start | `Start-2.aiff` | User sends a prompt AND AI is still working 10 seconds later | No |
| Task finish | `Finish-2.aiff` | AI finishes a response AND the task took >= 1 minute | Yes |

The Start/Finish sounds have timing thresholds to avoid playing on quick exchanges. Telegram notifications are sent only for long tasks (>= 1 minute) and include the last assistant message from the session transcript (Claude only).

## Setup Instructions

### Step 1: Choose Your CLI & Copy Files

This repository contains dedicated scripts for different CLIs because their hook engines operate differently.

**For Claude Code (`~/.claude`):**
```bash
AGENT_HOME=~/.claude
SCRIPT_DIR="claude code"
```

**For Gemini CLI (`~/.gemini`):**
```bash
AGENT_HOME=~/.gemini
SCRIPT_DIR="gemini"
```

Create the hooks directory and copy everything:
```bash
mkdir -p ${AGENT_HOME}/hooks/sounds
cp -r sounds/GLaDOS sounds/JARVIS ${AGENT_HOME}/hooks/sounds/
cp "${SCRIPT_DIR}/"* ${AGENT_HOME}/hooks/
chmod +x ${AGENT_HOME}/hooks/*.sh
```

### Step 2: Update paths inside the shell scripts

The scripts reference `~/.claude/hooks/sounds/GLaDOS/` (for Claude) or `~/.gemini/hooks/sounds/GLaDOS/` (for Gemini). Ensure the scripts inside your `hooks/` directory point to the correct path based on your installation.

To use JARVIS sounds instead, change `GLaDOS` to `JARVIS` and remove the `-2` suffix from filenames in the scripts and `settings.json`.

If installing on Linux, replace `afplay` with the appropriate audio player (e.g., `paplay`, `aplay`, or `mpv --no-video`).

### Step 3: Set up Telegram bot

This step enables Telegram notifications for long tasks. If you don't want Telegram notifications, skip this step — the sounds will still work, and the curl command will silently fail with the placeholder values.

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow the prompts to create a bot
3. Copy the bot token (looks like `123456:ABC-DEF...`)
4. Send any message to your new bot on Telegram
5. Get your chat ID by running:
   ```bash
   curl -s "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates" | python3 -m json.tool
   ```
   Look for `"chat": { "id": 123456789 }` in the response.

6. Edit `${AGENT_HOME}/hooks/on-stop.sh` and replace the placeholder on line 6:
   ```bash
   TELEGRAM_BOT_TOKEN="PASTE_BOT_TOKEN_HERE"   # ← replace with your bot token
   ```
   The chat ID on line 7 also needs to be replaced with your own.

7. Test by sending a message manually:
   ```bash
   curl -s -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/sendMessage" \
     -d chat_id="<YOUR_CHAT_ID>" \
     -d text="Test notification from AI CLI."
   ```

### Step 4: Merge hooks into settings.json

The hooks configuration must be added to your CLI settings file (e.g., `~/.claude/settings.json` or `~/.gemini/settings.json`).

The provided `hooks.json` file contains two configuration objects: `"claude-code"` and `"gemini-cli"`. 

**Important differences:**
- **Claude Code** uses hooks like `UserPromptSubmit` and `Stop`.
- **Gemini CLI** uses `BeforeAgent`, `AfterAgent`, and requires an idempotent `on-exit.sh` script for `SessionEnd` to prevent multiple audio triggers during shutdown.

**To install:**
1. Open your CLI's `settings.json`.
2. Locate the appropriate JSON payload for your CLI from the `hooks.json` file.
3. Merge the `"hooks"` object into your `settings.json` file. If `"hooks"` already exists, append the new arrays without overwriting your other configurations.

### Step 5: Verify

Restart your CLI. You should hear `Hello-2.aiff` on launch. To test Telegram, run a task that takes over 1 minute — you should receive a Portal-themed notification on Telegram when it finishes.

## File Inventory

| File | Purpose |
|---|---|
| `sounds/GLaDOS/Hello-2.aiff` | Played on session start |
| `sounds/GLaDOS/Bye-2.aiff` | Played on session end |
| `sounds/GLaDOS/Start-2.aiff` | Played when a task exceeds 10 seconds |
| `sounds/GLaDOS/Finish-2.aiff` | Played when a task exceeds 1 minute |
| `sounds/JARVIS/` | Alternative JARVIS voice pack |
| `claude code/on-prompt.sh` | Claude version: schedules Start sound |
| `claude code/on-stop.sh` | Claude version: handles Finish sound & Telegram |
| `gemini/on-prompt.sh` | Gemini version: schedules Start sound, outputs JSON |
| `gemini/on-stop.sh` | Gemini version: handles Finish sound, outputs JSON |
| `gemini/on-exit.sh` | Gemini version: ensures idempotent Bye sound on exit |
| `hooks.json` | Contains the hook configurations for both CLIs |
| `README.md` | This file |

## Platform Requirements

- **macOS**: Works out of the box (`afplay` and `curl` are built-in)
- **Linux**: Replace `afplay` with `paplay` (PulseAudio), `aplay` (ALSA), or `mpv --no-video` in all locations.
- **Windows (WSL)**: Use `powershell.exe -c "(New-Object Media.SoundPlayer 'path/to/file.wav').PlaySync()"` or install `sox` (`play` command). Audio files may need conversion to `.wav`.
