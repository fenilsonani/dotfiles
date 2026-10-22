#!/bin/zsh
# Pick an SSH host with fzf and connect with kitten ssh (bound to cmd+shift+s)
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
host=$(awk 'tolower($1)=="host"{for(i=2;i<=NF;i++) if($i!~/[*?]/) print $i}' ~/.ssh/config | sort -u |
  fzf --prompt="ssh › " --height=40% --reverse --border=rounded) || exit 0
kitten @ set-tab-title "$host"
exec kitten ssh "$host"
