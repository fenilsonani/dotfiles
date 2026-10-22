#!/usr/bin/env bash
# UserPromptSubmit: when the prompt reads like "still broken / again / not working", inject the
# re-diagnose rule as context at the exact moment it matters. stdout is added to Claude's context.
# Exit 0 always (never blocks the prompt).
set -u
p="$(cat | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')"
[ -z "$p" ] && exit 0
# why: background-task notifications arrive as prompts and say "still running".
case "$p" in *"<task-notification>"*|*"[system notification"*) exit 0;; esac
# "(^|[^/[:alnum:]])" so that "/still" (the skill name) and words like "against" do not trigger it.
if printf '%s' "$p" | grep -Eq '(^|[^/[:alnum:]])(still|again|not working|doesn.?t work|same (error|issue|problem)|why the fuck|broken again)\b'; then
  cat <<'EOF'
[hook] The user reports the previous fix did not work. Do NOT retry the same fix. Before editing anything: reproduce with the real thing (the failing command, logs, a screenshot, curl, the simulator, the browser), quote the exact error string, and state the new root-cause hypothesis in one line. Then fix and show red-before / green-after with the same command.
EOF
fi
if printf '%s' "$p" | grep -Eq '^(continue|contineu|continuie|continu|go on|keep going|next)\W*$'; then
  cat <<'EOF'
[hook] "continue" = resume the current todo list from the first unchecked item, no re-planning, no summary of what was done before. End the turn only when the list is done and verified, or when a decision needs the user.
EOF
fi
exit 0
