#!/bin/bash
# Show Claude Code state in the terminal tab title.
# kitty (local or over ssh): write an OSC 2 title to Claude's tty. iTerm2: hand off to cc-status.
input=$(cat)
if [[ $TERM == xterm-kitty ]]; then
  event=$(sed -n 's/.*"hook_event_name" *: *"\([A-Za-z]*\)".*/\1/p' <<<"$input" | head -1)
  case "$event" in
    SessionStart)                            title="claude" ;;
    UserPromptSubmit|PreToolUse|PostToolUse) title="● claude" ;;
    Notification|PermissionRequest)          title="? claude needs you" ;;
    Stop)                                    title="✓ claude done" ;;
    StopFailure)                             title="✗ claude error" ;;
    SessionEnd)                              title="" ;;  # shell prompt restores its own title
    *) exit 0 ;;
  esac
  # Hooks have no controlling tty: find the nearest ancestor (claude) that has one.
  pid=$PPID
  while (( pid > 1 )); do
    tty=$(ps -o tty= -p "$pid" | tr -d ' ')
    [[ -n $tty && $tty != "??" ]] && break
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  done
  [[ -w /dev/$tty ]] && printf '\e]2;%s\a' "$title" >"/dev/$tty"
  exit 0
fi
cc=/Users/fenilsonani/.config/iterm2/cc-status
[[ -x $cc ]] && exec "$cc" <<<"$input"
exit 0
