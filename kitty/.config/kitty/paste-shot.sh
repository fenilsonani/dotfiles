#!/bin/zsh
# Paste a screenshot into the focused kitty window as a file path (cmd+shift+v).
# Image comes from the clipboard, else the newest Desktop screenshot.
# If the window is running ssh, the image is copied to that host first.
export PATH="/opt/homebrew/bin:$HOME/.local/bin:/usr/bin:/bin:$PATH"
notify() { osascript -e "display notification \"$1\" with title \"Screenshot paste\""; }

mkdir -p ~/screenshots
f=~/screenshots/shot-$(date +%Y%m%d-%H%M%S).png
if ! pngpaste "$f" >/dev/null 2>&1; then
  latest=$(ls -t ~/Desktop/Screenshot*.png 2>/dev/null | head -1)
  [[ -n $latest ]] || { notify "No image in clipboard or on Desktop"; exit 1; }
  cp "$latest" "$f"
fi

# Focused window id + ssh host (empty when local)
read -r win host < <(kitten @ ls --match state:focused | python3 -c '
import json, os, sys
VAL = set("BbcDEeFIiJLlmOoPpQRSWw")  # ssh flags that take a value
for o in json.load(sys.stdin):
  for t in o["tabs"]:
    for w in t["windows"]:
      host = ""
      for p in w["foreground_processes"]:
        a = p["cmdline"]
        if a and os.path.basename(a[0]) == "ssh":
          i = 1
          while i < len(a):
            x = a[i]
            if x.startswith("-") and len(x) > 1:
              i += 2 if (len(x) == 2 and x[1] in VAL) else 1
              continue
            host = x; break
      print(w["id"], host); sys.exit()
')
[[ -n $win ]] || { notify "No focused kitty window"; exit 1; }

if [[ -n $host ]]; then
  dest=$(ssh "$host" "mkdir -p ~/screenshots && cat > ~/screenshots/${f:t} && echo \$HOME/screenshots/${f:t}" <"$f") \
    || { notify "Upload to $host failed"; exit 1; }
else
  dest=$f
fi
kitten @ send-text --match id:$win --bracketed-paste enable -- "$dest "
