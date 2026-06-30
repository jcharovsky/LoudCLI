#!/bin/bash
# Schedule the Start sound after 10s for the first model invocation in a run.

INPUT=$(cat)
CONVERSATION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('conversationId','default'))" 2>/dev/null)
INVOCATION_NUM=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('invocationNum',0))" 2>/dev/null)

if [ -z "$CONVERSATION_ID" ]; then
  CONVERSATION_ID="default"
fi

if [ "$INVOCATION_NUM" = "0" ]; then
  TS=$(date +%s)
  TS_FILE="/tmp/loudcli-antigravity-${CONVERSATION_ID}.ts"
  echo "$TS" > "$TS_FILE"
  (sleep 10 && [ -f "$TS_FILE" ] && [ "$(cat "$TS_FILE")" = "$TS" ] && afplay ~/.gemini/config/hooks/sounds/GLaDOS/Start-2.aiff) >/dev/null 2>&1 &
fi

echo '{}'
