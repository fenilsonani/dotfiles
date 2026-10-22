#!/usr/bin/env bash
# PostToolUse(Edit|Write) + PreToolUse(Bash) for git commit / gh pr / gh issue.
# Exit 2 (stderr shown to Claude) when emoji land in code, docs, commit messages, or PR/issue text.
# Range covers pictographs, dingbats/misc symbols (2600-27BF: checkmarks, warning signs, etc.),
# regional indicators, and the VS16 selector. Text arrows (2190-21FF) and box drawing stay allowed.
set -u
input="$(cat)"
event="$(printf '%s' "$input" | jq -r '.hook_event_name // empty')"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

case "$tool" in
  Bash)
    cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
    printf '%s' "$cmd" | grep -Eq '\bgit\b.*\bcommit\b|\bgh\b[[:space:]]+(pr|issue|release)[[:space:]]+(create|edit|comment|review)' || exit 0
    text="$cmd" ;;
  Edit|Write)
    f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
    case "$f" in *.lock|*.lockb|*/node_modules/*|*.svg|*.snap|*/fixtures/*) exit 0;; esac
    text="$(printf '%s' "$input" | jq -r '[.tool_input.content?, .tool_input.new_string?, (.tool_input.edits[]?.new_string?)] | map(select(. != null)) | join("\n")')" ;;
  *) exit 0 ;;
esac
[ -z "$text" ] && exit 0

hit="$(printf '%s' "$text" | perl -CSD -ne 'while (/([\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{1F1E6}-\x{1F1FF}\x{FE0F}\x{2B50}\x{2B55}\x{231A}-\x{23FF}])/g){ printf "U+%04X %s\n", ord($1), $1; }' | sort -u | head -5)"
[ -z "$hit" ] && exit 0

if [ "$tool" = "Bash" ]; then
  printf 'BLOCKED: emoji in commit/PR/issue text is not allowed (global rule). Found:\n%s\nRewrite in plain English.\n' "$hit" >&2
else
  printf 'Emoji written to %s; the global rule is no emoji in code, docs, or UI (use lucide/SVG icons or plain text). Found:\n%s\nReplace them now.\n' "$f" "$hit" >&2
fi
exit 2
