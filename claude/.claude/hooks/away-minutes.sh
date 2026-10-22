#!/usr/bin/env bash
# Prints whole minutes since Fenil's last real message in transcript $1 (tool results and
# background-task notifications are not him). Prints 9999 when none is found.
set -u
t="${1:-}"
[ -f "$t" ] || { echo 9999; exit 0; }
last="$(jq -r '
  select(.type=="user" and (.isMeta // false | not))
  | select(
      (.message.content | type) == "string"
      or ([.message.content[]? | .type] | index("text"))
    )
  | (.message.content | if type=="string" then . else ([.[] | select(.type=="text") | .text] | join(" ")) end) as $txt
  | select(($txt | startswith("<task-notification>") or startswith("[SYSTEM NOTIFICATION")) | not)
  | .timestamp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601
' "$t" 2>/dev/null | tail -1)"
[ -z "$last" ] && { echo 9999; exit 0; }
echo $(( ( $(date +%s) - ${last%.*} ) / 60 ))
