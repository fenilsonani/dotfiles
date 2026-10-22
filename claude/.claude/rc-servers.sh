#!/usr/bin/env bash
# Usage: rc-servers.sh <repo under ~/Developer>... : one always-on Remote Control server per repo (launchd).
# Stop one: launchctl bootout gui/$(id -u)/com.fenil.claude-rc.<repo> && rm ~/Library/LaunchAgents/com.fenil.claude-rc.<repo>.plist
set -eu
P="$PATH"
for r in "$@"; do
  label="com.fenil.claude-rc.$r"; f="$HOME/Library/LaunchAgents/$label.plist"
  cat > "$f" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>WorkingDirectory</key><string>$HOME/Developer/$r</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/caffeinate</string><string>-s</string>
    <string>$HOME/.local/bin/claude</string><string>remote-control</string>
    <string>--spawn</string><string>worktree</string>
    <string>--permission-mode</string><string>bypassPermissions</string>
    <string>--remote-control-session-name-prefix</string><string>$r</string>
  </array>
  <key>EnvironmentVariables</key><dict><key>PATH</key><string>$P</string><key>HOME</key><string>$HOME</string></dict>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>ThrottleInterval</key><integer>30</integer>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/claude-rc-$r.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/claude-rc-$r.log</string>
</dict>
</plist>
PL
  plutil -lint "$f"
  launchctl bootout gui/$(id -u)/$label 2>/dev/null || true
  launchctl bootstrap gui/$(id -u) "$f"
done
