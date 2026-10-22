#!/usr/bin/env bash
# WorktreeRemove hook: Xcode keys DerivedData by workspace path, so every mobile worktree
# leaves a multi-GB DerivedData tree behind. Delete the one that belonged to this worktree.
set -u
wt="$(jq -r '.worktree_path // .worktreePath // empty' 2>/dev/null)"
[ -n "$wt" ] || exit 0
for d in "$HOME"/Library/Developer/Xcode/DerivedData/*/; do
  p="$(/usr/libexec/PlistBuddy -c 'Print WorkspacePath' "$d/info.plist" 2>/dev/null || true)"
  [ -n "$p" ] && [ "${p#"$wt"}" != "$p" ] && rm -rf "$d" && echo "removed DerivedData $(basename "$d") for $wt"
done
exit 0
