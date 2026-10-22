#!/usr/bin/env bash
# Stop hook. Two deterministic checks on the session transcript; no LLM involved.
#   1. Open tasks: TaskCreate'd items whose last TaskUpdate is not completed/deleted -> keep working.
#      (This is what "continue" prompts were doing by hand: 427 of them in 45 days.)
#   2. Code edited after the last verification command -> nudge once per session.
# Exit 2 = do not stop, stderr goes to Claude. stop_hook_active=true means we already nudged
# this turn: always allow then, so the hook can never loop.
set -u
input="$(cat)"
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0
t="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"
[ -f "$t" ] || exit 0
sid="$(printf '%s' "$input" | jq -r '.session_id // "nosession"')"

# If the last assistant text ends with a question, Claude is asking the user: let it stop,
# unless he is away, where a chat question stalls the run exactly like AskUserQuestion would.
last_text="$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text' "$t" 2>/dev/null | grep -v '^[[:space:]]*$' | tail -1)"
case "$(printf '%s' "$last_text" | sed -E 's/[[:space:]*_`]+$//')" in *\?)
  away="$(bash "$(dirname "$0")/away-minutes.sh" "$t")"
  [ "$away" -lt "${CLAUDE_AWAY_MINUTES:-5}" ] && exit 0
  printf 'Fenil has been away for %s+ min, so ending on a question stalls the run. Take your recommended answer, record it under Decisions, and keep working; list only what needs his hands (credentials, logins) in the report.\n' "$away" >&2
  exit 2 ;;
esac

# ---- 1. open tasks -------------------------------------------------------------
created="$(jq -r 'select(.type=="user") | .message.content[]? | select(.type=="tool_result") | (.content | if type=="string" then . else (.[]?.text // "") end)' "$t" 2>/dev/null \
  | grep -oE '^Task #[0-9]+ created' | grep -oE '[0-9]+' | sort -u)"
if [ -n "$created" ]; then
  closed="$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="TaskUpdate") | "\(.input.taskId) \(.input.status // "")"' "$t" 2>/dev/null \
    | awk '{st[$1]=$2} END{for (k in st) if (st[k]=="completed"||st[k]=="deleted"||st[k]=="cancelled") print k}' | sort -u)"
  open="$(comm -23 <(printf '%s\n' "$created") <(printf '%s\n' "$closed") | grep -c . || true)"
  if [ "${open:-0}" -gt 0 ]; then
    subjects="$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="TaskCreate") | .input.subject' "$t" 2>/dev/null | tail -n +1 | head -20)"
    printf 'Not done: %s task(s) are still open (TaskList to see them). Keep working through them; mark each completed as it lands. Stop only when the list is done and verified, or to ask the user a question.\n' "$open" >&2
    exit 2
  fi
fi

# ---- 2. edited after last verification (once per session) --------------------------
marker="${TMPDIR:-/tmp}/claude-stop-verify-$sid"
[ -f "$marker" ] && exit 0
calls="$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | "\(.name)\t\(.input.command // .input.file_path // "")"' "$t" 2>/dev/null | nl -ba -w1 -s $'\t')"
[ -z "$calls" ] && exit 0
code_re='\.(ts|tsx|js|jsx|mjs|svelte|vue|swift|kt|py|rs|c|cc|cpp|h|hpp|go|sql)$'
# Also counts ad-hoc test scripts (bash foo-tests.sh, ./test.sh, python3 test_x.py) and `claude -p` smoke runs.
verify_re='(bun|npm|pnpm)[[:space:]]+(run[[:space:]]+)?(test|verify|typecheck|check|build|lint|smoke)|turbo|vitest|playwright|pytest|xcodebuild|swift[[:space:]]+(build|test)|make[[:space:]]+(test|build|check)|cmake[[:space:]]+--build|ctest|cargo[[:space:]]+(test|build|check)|curl|simctl[[:space:]]+(launch|install)|tsc|oxlint|uv[[:space:]]+run|(^|[[:space:]/])[A-Za-z0-9_-]*test[A-Za-z0-9_-]*\.(sh|py|js|ts|mjs)([[:space:]]|$)|claude[[:space:]]+-p[[:space:]]'
last_edit="$(printf '%s\n' "$calls" | awk -F'\t' -v re="$code_re" '($2=="Edit"||$2=="Write") && $3 ~ re {n=$1} END{print n+0}')"
last_verify="$(printf '%s\n' "$calls" | awk -F'\t' -v re="$verify_re" '$2=="Bash" && $3 ~ re {n=$1} END{print n+0}')"
last_browser="$(printf '%s\n' "$calls" | awk -F'\t' '$2 ~ /^mcp__claude-in-chrome__/ {n=$1} END{print n+0}')"
[ "$last_browser" -gt "$last_verify" ] && last_verify="$last_browser"
[ "$last_edit" -eq 0 ] && exit 0
[ "$last_verify" -ge "$last_edit" ] && exit 0
touch "$marker"
cat >&2 <<MSG
Not done yet: code files were edited after the last verification command (edit #$last_edit vs verify #$last_verify).
"Done means verified": run the repo's real check (tests / typecheck / build / simulator / curl / browser) and show the command and its output. If this turn was only a plan or a question for the user, say so in one line and stop.
MSG
exit 2
