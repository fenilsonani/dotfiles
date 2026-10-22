#!/usr/bin/env bash
# SessionStart: print a 6-line situational header. stdout becomes context Claude can see.
# Cheap (git + df + simctl), no network. Exit 0 always.
set -u
input="$(cat 2>/dev/null || true)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"; cwd="${cwd:-$PWD}"
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  root="$(git -C "$cwd" rev-parse --show-toplevel)"
  br="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  dirty="$(git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  ab="$(git -C "$cwd" rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null | awk '{print "behind "$1", ahead "$2}')"
  wt="$(git -C "$cwd" worktree list 2>/dev/null | wc -l | tr -d ' ')"
  last="$(git -C "$cwd" log -1 --format='%h %s (%cr)' 2>/dev/null)"
  pm="bun"; [ -f "$root/pnpm-lock.yaml" ] && pm="pnpm"; [ -f "$root/package-lock.json" ] && pm="command npm"
  hooks="none"; [ -f "$root/lefthook.yml" ] && hooks="lefthook"; [ -d "$root/.githooks" ] && hooks=".githooks (core.hooksPath)"
  echo "repo: $root | branch: $br | dirty: $dirty | ${ab:-no upstream} | worktrees: $wt"
  echo "last: $last"
  echo "package manager: $pm | git hooks: $hooks | commitlint: $([ -f "$root/commitlint.config.js" ] && echo yes || echo no)"
fi
free="$(df -h / 2>/dev/null | awk 'NR==2{print $4" free of "$2}')"
booted="$(xcrun simctl list devices booted 2>/dev/null | grep -c Booted || echo 0)"
load="$(sysctl -n vm.loadavg 2>/dev/null | tr -d '{}')"
echo "mac: disk $free | simulators booted: $booted | load:$load ($(sysctl -n hw.ncpu) cores)"
exit 0
