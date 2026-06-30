#!/bin/bash
# Play Finish sound and send Telegram only after a fully idle long run.

TELEGRAM_BOT_TOKEN="PASTE_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="PASTE_CHAT_ID_HERE"

INPUT=$(cat)
CONVERSATION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('conversationId','default'))" 2>/dev/null)
FULLY_IDLE=$(echo "$INPUT" | python3 -c "import sys,json; print(str(json.load(sys.stdin).get('fullyIdle', True)).lower())" 2>/dev/null)
TRANSCRIPT_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('transcriptPath',''))" 2>/dev/null)

if [ -z "$CONVERSATION_ID" ]; then
  CONVERSATION_ID="default"
fi

if [ "$FULLY_IDLE" = "false" ]; then
  echo '{"decision":""}'
  exit 0
fi

TS_FILE="/tmp/loudcli-antigravity-${CONVERSATION_ID}.ts"
if [ ! -f "$TS_FILE" ]; then
  echo '{"decision":""}'
  exit 0
fi

TS=$(cat "$TS_FILE" 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$((NOW - TS))
rm -f "$TS_FILE"

if [ "$ELAPSED" -ge 60 ]; then
  afplay ~/.gemini/config/hooks/sounds/GLaDOS/Finish-2.aiff >/dev/null 2>&1
  HOURS=$((ELAPSED / 3600))
  MINS=$(((ELAPSED % 3600) / 60))
  SECS=$((ELAPSED % 60))
  if [ "$HOURS" -gt 0 ]; then
    DURATION="${HOURS}h ${MINS}m ${SECS}s"
  else
    DURATION="${MINS}m ${SECS}s"
  fi
  TIME=$(date +%H:%M)

  MESSAGE=""
  if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    MESSAGE=$(tail -200 "$TRANSCRIPT_PATH" | python3 -c "
import json, sys
last = ''
for line in sys.stdin:
    try:
        obj = json.loads(line)
    except Exception:
        continue
    role = obj.get('role') or obj.get('type') or obj.get('author')
    if role not in ('assistant', 'model', 'agent'):
        continue
    content = obj.get('content') or obj.get('message') or obj.get('text') or ''
    if isinstance(content, dict):
        content = content.get('text') or content.get('content') or ''
    if isinstance(content, list):
        chunks = []
        for item in content:
            if isinstance(item, dict):
                chunks.append(str(item.get('text') or item.get('content') or ''))
            else:
                chunks.append(str(item))
        content = '\\n'.join(chunk for chunk in chunks if chunk)
    if content:
        last = str(content)
print(last)
" 2>/dev/null)
  fi

  TEXT="LoudCLI: Antigravity finished a long task."
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

echo '{"decision":""}'
