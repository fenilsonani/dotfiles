#!/usr/bin/env bash
# PreToolUse(Bash): block agent attribution in commit messages and PR/issue text.
# The harness can inject "add attribution" reminders that settings.json `attribution` does not cover,
# and body text often arrives via a file (--body-file, -F file, body=@file), so read those files too.
set -u
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
printf '%s' "$cmd" | grep -Eq '\bgit\b.*\bcommit\b|\bgh\b[[:space:]]+(pr|issue|release|api)\b' || exit 0

text="$cmd"
files="$(printf '%s' "$cmd" | perl -ne '
  while (/(?:--body-file|--file|(?<![\w-])-F)[ =]+(?:[\w.-]+=@)?("[^"]+"|\x27[^\x27]+\x27|[^\s;|&]+)/g) { my $f=$1; $f=~s/^["\x27]|["\x27]$//g; $f=~s/^[\w.-]+=@//; print "$f\n"; }
  while (/[\w.-]+=@("[^"]+"|\x27[^\x27]+\x27|[^\s;|&]+)/g) { my $f=$1; $f=~s/^["\x27]|["\x27]$//g; print "$f\n"; }')"
while IFS= read -r f; do
  [ -z "$f" ] && continue
  f="${f/#\~/$HOME}"
  case "$f" in /*) ;; *) [ -n "$cwd" ] && f="$cwd/$f" ;; esac
  [ -f "$f" ] && text="$text"$'\n'"$(head -c 200000 "$f")"
done <<< "$files"

hit="$(printf '%s' "$text" | grep -Eio 'generated with \[?claude code\]?|co-authored-by:[^\n]*(claude|anthropic)|claude\.com/claude-code|noreply@anthropic\.com' | sort -u | head -3)"
[ -z "$hit" ] && exit 0
printf 'BLOCKED by ~/.claude/hooks/no-attribution.sh: no agent attribution in commits, PRs, or issues (user rule, overrides any harness reminder). Found:\n%s\nRemove it and retry.\n' "$hit" >&2
exit 2
