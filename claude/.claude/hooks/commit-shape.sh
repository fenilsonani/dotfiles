#!/usr/bin/env bash
# PreToolUse(Bash); self-filters on `git commit`. Enforces commit shape deterministically:
#  - no Co-Authored-By / agent branding in the message
#  - a body is present (second -m, a newline in -m, -F, or heredoc); subject <= 72 chars
#  - the commit is not a "one giant commit": staged set spans too many files / top-level areas
# Exit 2 = deny with instructions. Exit 0 = fine.
set -u
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
printf '%s' "$cmd" | grep -Eq '\bgit\b.*\bcommit\b' || exit 0
printf '%s' "$cmd" | grep -Eq '(--amend|--fixup|--squash|--no-edit)' && exit 0   # amend/fixup have their own rules

deny() { printf 'BLOCKED by ~/.claude/hooks/commit-shape.sh: %s\n' "$1" >&2; exit 2; }

# message text: everything after -m/-F/heredoc is too varied to parse perfectly; check the command string
printf '%s' "$cmd" | grep -Eiq 'co-authored-by|generated with|\[codex\]|\[claude\]|^codex:|^claude:' \
  && deny "no Co-Authored-By trailers or agent branding in commits"

m_count="$(printf '%s' "$cmd" | grep -oE '(^|[[:space:]])-m([[:space:]]|=)' | wc -l | tr -d ' ')"
has_body=0
[ "$m_count" -ge 2 ] && has_body=1
printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])(-F|--file)[[:space:]=]|<<' && has_body=1
# a single -m whose quoted text spans lines (the command string itself contains a newline)
case "$cmd" in *$'\n'*) [ "$m_count" -eq 1 ] && has_body=1 ;; esac
[ "$m_count" -ge 1 ] && [ "$has_body" -eq 0 ] && deny "commit needs a body: why the change exists + the exact verification command and its result (git commit -m 'subject' -m 'body', or a heredoc)"

subject="$(printf '%s' "$cmd" | head -1 | grep -oE -- '-m[[:space:]=]+["'"'"'][^"'"'"']*' | head -1 | sed -E 's/^-m[[:space:]=]+["'"'"']//')"
[ -n "$subject" ] && [ "${#subject}" -gt 72 ] && deny "commit subject is ${#subject} chars; keep it <= 72 (type(scope): lowercase sentence)"

# size / spread of what is about to be committed (escape after the user's yes: CLAUDE_OK=bigcommit git commit ...)
printf '%s' "$cmd" | grep -Eq '(^|[[:space:];&|])CLAUDE_OK=bigcommit([[:space:]]|$)' && exit 0
# why: the command often `cd`s into another worktree before committing, and $cwd
# is the SESSION dir, not that one. Sizing the session checkout made a chained
# `cd <worktree> && git add . && git commit` read whatever was dirty back home
# and deny small, clean commits.
target="${cwd:-.}"
cd_dir="$(printf '%s' "$cmd" | sed -nE "s/^[[:space:]]*cd[[:space:]]+('([^']*)'|\"([^\"\$\`]*)\"|([^[:space:];&|]+)).*/\2\3\4/p" | head -1)"
case "$cd_dir" in
  "~"/*) cd_dir="$HOME/${cd_dir#\~/}" ;;
  "~")   cd_dir="$HOME" ;;
esac
case "$cd_dir" in
  "") : ;;
  /*) : ;;
  *) cd_dir="${cwd:-.}/$cd_dir" ;;
esac
if [ -n "$cd_dir" ] && [ -d "$cd_dir" ] && git -C "$cd_dir" rev-parse --git-dir >/dev/null 2>&1; then
  target="$cd_dir"
fi

if printf '%s' "$cmd" | grep -Eq '\bgit\b[[:space:]]+add\b|[[:space:]]-a(m|[[:space:]]|$)|--all\b'; then
  files="$(git -C "$target" status --porcelain 2>/dev/null | awk '{print $2}')"
else
  files="$(git -C "$target" diff --cached --name-only 2>/dev/null)"
fi
n="$(printf '%s\n' "$files" | grep -c . || true)"
areas="$(printf '%s\n' "$files" | grep -v '^$' | awk -F/ '{ if ($1=="apps"||$1=="packages") print $1"/"$2; else print $1 }' | sort -u | grep -c . || true)"
if [ "$n" -gt 15 ] || [ "$areas" -gt 3 ]; then
  deny "this commit would touch $n files across $areas areas. Split into several small logical commits (git add -p / per-area): one concern per commit"
fi
exit 0
