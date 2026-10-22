#!/usr/bin/env bash
# PreToolUse(AskUserQuestion). A question asked while Fenil is away stalls the whole run, and
# askUserQuestionTimeout pauses while the terminal is unfocused, so deny it and make the agent decide.
# Threshold: CLAUDE_AWAY_MINUTES (default 5). Exit 2 = deny, stderr goes to Claude.
set -u
input="$(cat)"
t="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"
away="$(bash "$(dirname "$0")/away-minutes.sh" "$t")"
[ "$away" -lt "${CLAUDE_AWAY_MINUTES:-5}" ] && exit 0
cat >&2 <<MSG
Fenil has been away for ${away}+ min; a question now stalls the run until he is back. Take your recommended option for each question, record each as one line under Decisions in the report, and keep working. Anything only he can supply (a credential, a login) goes under "needs my hands" in the report; finish every part of the task that does not depend on it.
MSG
exit 2
