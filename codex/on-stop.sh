#!/bin/bash
# Play Finish sound and send Telegram only if the task took >= 1 minute.

TELEGRAM_BOT_TOKEN="PASTE_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="PASTE_CHAT_ID_HERE"

cat >/dev/null

TS_FILE="/tmp/loudcli-codex-task.ts"
if [ ! -f "$TS_FILE" ]; then
  exit 0
fi

TS=$(cat "$TS_FILE" 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$((NOW - TS))
rm -f "$TS_FILE"

if [ "$ELAPSED" -ge 60 ]; then
  afplay ~/.codex/hooks/sounds/GLaDOS/Finish-2.aiff >/dev/null 2>&1
  HOURS=$((ELAPSED / 3600))
  MINS=$(((ELAPSED % 3600) / 60))
  SECS=$((ELAPSED % 60))
  if [ "$HOURS" -gt 0 ]; then
    DURATION="${HOURS}h ${MINS}m ${SECS}s"
  else
    DURATION="${MINS}m ${SECS}s"
  fi
  TIME=$(date +%H:%M)

  TEXT="LoudCLI: Codex finished a long task.

The task took ${DURATION} and was finished at ${TIME}."
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="${TEXT}" \
    > /dev/null 2>&1
fi
