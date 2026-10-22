#!/usr/bin/env bash
# PostToolUse(Write) with if: "Write(*.swift)". When a NEW .swift file lands inside an
# XcodeGen project, regenerate the .xcodeproj so the file is in the build.
# Exit 2 with the xcodegen error if generation fails (Claude sees it); 0 otherwise.
set -u
input="$(cat)"
f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
[ -n "$f" ] && [ -f "$f" ] || exit 0
case "$f" in *.swift) ;; *) exit 0 ;; esac
dir="$(dirname "$f")"
# only for files git does not know yet (new file); edits to tracked files don't need a regen
git -C "$dir" ls-files --error-unmatch "$f" >/dev/null 2>&1 && exit 0
# walk up to the nearest project.yml (stop at git root or /)
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo /)"
d="$dir"
while [ "$d" != "/" ]; do
  if [ -f "$d/project.yml" ]; then
    command -v xcodegen >/dev/null || { echo "xcodegen not installed (brew install xcodegen)" >&2; exit 2; }
    out="$(cd "$d" && xcodegen generate --quiet 2>&1)" || { printf 'xcodegen generate failed in %s:\n%s\n' "$d" "$out" >&2; exit 2; }
    echo "xcodegen regenerated $(basename "$d") after new file $(basename "$f")"
    exit 0
  fi
  [ "$d" = "$root" ] && break
  d="$(dirname "$d")"
done
exit 0
