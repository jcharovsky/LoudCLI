#!/bin/bash
# Play Finish sound only if the task took >= 1 minute.
# Also removes the timestamp file to cancel any pending Start sound.
# Sends a Telegram notification for long tasks.

TELEGRAM_BOT_TOKEN="PASTE_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="PASTE_CHAT_ID_HERE"

# Read hook stdin to get session_id
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null)

TS=$(cat /tmp/claude-sound-ts 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$((NOW - TS))
rm -f /tmp/claude-sound-ts

if [ "$ELAPSED" -ge 60 ]; then
  afplay ~/.claude/hooks/sounds/GLaDOS/Finish-2.aiff
  HOURS=$((ELAPSED / 3600))
  MINS=$(((ELAPSED % 3600) / 60))
  SECS=$((ELAPSED % 60))
  if [ "$HOURS" -gt 0 ]; then
    DURATION="${HOURS}h ${MINS}m ${SECS}s"
  else
    DURATION="${MINS}m ${SECS}s"
  fi
  TIME=$(date +%H:%M)

  # Extract last assistant text message from session transcript
  MESSAGE=""
  if [ -n "$SESSION_ID" ]; then
    JSONL=$(find ~/.claude/projects -name "${SESSION_ID}.jsonl" 2>/dev/null | head -1)
    if [ -n "$JSONL" ]; then
      MESSAGE=$(tail -200 "$JSONL" | python3 -c "
import sys, json
last_text = ''
for line in sys.stdin:
    try:
        obj = json.loads(line.strip())
        if obj.get('type') == 'assistant':
            texts = []
            for block in obj.get('message', {}).get('content', []):
                if isinstance(block, dict) and block.get('type') == 'text':
                    texts.append(block['text'])
            if texts:
                last_text = '\n'.join(texts)
    except:
        pass
print(last_text)
" 2>/dev/null)
    fi
  fi

  TEXT="This was a triumph!
I'm making a note here:
HUGE SUCCESS!"
  if [ -n "$MESSAGE" ]; then
    TEXT="${TEXT}

${MESSAGE}"
  fi
  TEXT="${TEXT}

The task took ${DURATION} and was finished at ${TIME}."
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${TEXT}" \
    > /dev/null 2>&1
fi
echo '{}'
