#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Read hook stdin to get session_id
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r ".session_id // empty")

if [ -z "$SESSION_ID" ]; then
  SESSION_ID="unknown"
fi

LOCK_FILE="/tmp/gemini-exit-${SESSION_ID}.lock"

if [ ! -f "$LOCK_FILE" ]; then
  touch "$LOCK_FILE"
  afplay ~/.claude/hooks/sounds/GLaDOS/Bye-2.aiff > /dev/null 2>&1
fi

echo '{}'
exit 0
