#!/usr/bin/env bash
# PreToolUse(Bash) guard. Reads the hook JSON on stdin, splits .tool_input.command on the same
# separators Claude Code uses (&&, ||, ;, |, newline) and checks EACH subcommand against the
# global rules. Exit 2 = deny (stderr is shown to Claude). Exit 0 = allow.
# Never exit 1: Claude Code treats 1 as a non-blocking error and runs the command anyway.
#
# Escape hatch for actions allowed only after the user's explicit yes: prefix the command with
# CLAUDE_OK=<merge|deploy|deps|destructive>. The deny message tells the model to add it only
# after AskUserQuestion returned a yes; every allow-by-prefix is written to ~/.claude/hooks-audit.log.
set -u
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
[ -z "$cmd" ] && exit 0

log="${HOME}/.claude/hooks-audit.log"
deny() {
  printf '%s\tDENY\t%s\t%s\n' "$(date -u +%FT%TZ)" "$1" "$cmd" >> "$log" 2>/dev/null
  printf 'BLOCKED by ~/.claude/hooks/guard-bash.sh: %s\n' "$1" >&2
  exit 2
}
ok_for() {
  if printf '%s' "$cmd" | grep -Eq "(^|[[:space:];&|])CLAUDE_OK=$1([[:space:]]|$)"; then
    printf '%s\tOK:%s\t%s\n' "$(date -u +%FT%TZ)" "$1" "$cmd" >> "$log" 2>/dev/null; return 0
  fi; return 1
}
m() { printf '%s' "$seg" | grep -Eq -e "$1"; }     # case-sensitive match on the current subcommand
mi() { printf '%s' "$seg" | grep -Eiq -e "$1"; }   # case-insensitive

# split into subcommands the way the permission system does
segments="$(printf '%s\n' "$cmd" | sed -E 's/\|\||&&|;|\|&|\|/\n/g')"

while IFS= read -r seg; do
  seg="$(printf '%s' "$seg" | sed -E 's/^[[:space:]]+//; s/^(CLAUDE_OK=[a-z]+[[:space:]]+)//')"
  [ -z "$seg" ] && continue

  # --- 1. never bypass git hooks ---------------------------------------------
  if m '^(command[[:space:]]+)?git[[:space:]]'; then
    m '[[:space:]]commit([[:space:]]|$)' && m '[[:space:]](--no-verify|-n)([[:space:]]|$)' && deny "git commit --no-verify is banned; fix the hook failure in scope"
    m '[[:space:]]push([[:space:]]|$)' && m '[[:space:]]--no-verify([[:space:]]|$)' && deny "git push --no-verify is banned"
    m 'core\.hooksPath=/dev/null' && deny "disabling git hooks is banned"
    m '[[:space:]]commit([[:space:]]|$)' && m '[[:space:]]--allow-empty' && deny "empty commits exist only to poke CI; not allowed"
  fi
  m '(^|[[:space:]])(HUSKY|LEFTHOOK)=0([[:space:]]|$)' && deny "disabling git hooks is banned"

  # --- 2. never trigger CI on your own ----------------------------------------
  m '^gh[[:space:]]+workflow[[:space:]]+run|^gh[[:space:]]+run[[:space:]]+(rerun|watch)|^gh[[:space:]]+api[[:space:]].*/dispatches' \
    && deny "CI minutes cost money: never trigger, re-run, or babysit CI; run typecheck/lint/test locally"
  if m '^git[[:space:]]+push([[:space:]]|$)'; then
    # refspec = first non-option arg after the remote; if absent, the current branch is pushed
    args="$(printf '%s' "$seg" | sed -E 's/^git[[:space:]]+push//' | tr ' ' '\n' | grep -vE '^(-|$)' )"
    remote="$(printf '%s\n' "$args" | sed -n 1p)"; ref="$(printf '%s\n' "$args" | sed -n 2p)"
    [ -z "$ref" ] && ref="$(git -C "${cwd:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    case "${ref#*:}" in
      main|master|HEAD:main|HEAD:master)
        ok_for merge || deny "pushing '$ref' to ${remote:-origin} is a deploy (Workers Builds) and a CI run. Work on a branch and open a PR; merging needs the user's explicit yes, then CLAUDE_OK=merge" ;;
    esac
  fi
  if m '^gh[[:space:]]+pr[[:space:]]+merge([[:space:]]|$)'; then
    ok_for merge || deny "merging waits for the user's explicit yes (AskUserQuestion). After a yes, re-run as: CLAUDE_OK=merge gh pr merge ..."
  fi

  # --- 3. destructive / irreversible: explicit yes first ------------------------
  if ! ok_for destructive; then
    m '^git[[:space:]]+push([[:space:]]|$)' && m '[[:space:]](-f|--force|--force-with-lease(=[^[:space:]]*)?)([[:space:]]|$)' \
      && deny "force push needs the action + impact stated and an explicit yes (CLAUDE_OK=destructive after the yes)"
    m '^git[[:space:]]+reset([[:space:]]|$)' && m '[[:space:]]--hard([[:space:]]|$)' && deny "git reset --hard needs an explicit yes (CLAUDE_OK=destructive after the yes)"
    m '^git[[:space:]]+clean([[:space:]]|$)' && m '[[:space:]]-[a-zA-Z]*[fd]' && deny "git clean -f/-d deletes untracked work; explicit yes needed"
    m '^git[[:space:]]+branch([[:space:]]|$)' && m '[[:space:]]-D([[:space:]]|$)' && deny "force-deleting a branch needs an explicit yes"
    m '^git[[:space:]]+worktree[[:space:]]+remove' && m '[[:space:]]--force' && deny "force-removing a worktree needs an explicit yes"
    # only when the segment can execute SQL (not grep/cat/echo of a migration file)
    if ! m '^(grep|rg|cat|less|head|tail|sed|awk|echo|printf|git|ls|find|diff|bat)([[:space:]]|$)'; then
      mi '(^|[^a-z_])(drop[[:space:]]+(table|column|database|schema|index)|truncate[[:space:]]+(table[[:space:]]+)?[a-z_"`]+)' && deny "DROP/TRUNCATE is banned; migrations are additive"
    fi
    m '(^|[[:space:]])drizzle-kit[[:space:]]+(push|drop)([[:space:]]|$)' && deny "drizzle-kit push/drop against a database needs an explicit yes; gmh uses migrations-manual/ (prod-db-push skill)"
    m '(^|[[:space:]])wrangler[[:space:]]' && m '[[:space:]](delete|secret[[:space:]]+(put|delete|bulk)|d1[[:space:]]+(delete|execute)|r2[[:space:]]+bucket[[:space:]]+delete|kv[[:space:]]+(namespace|key)[[:space:]]+delete)([[:space:]]|$)' \
      && deny "wrangler delete/secret/d1 execute touches env or data; explicit yes needed"
    m '^sudo([[:space:]]|$)' && deny "sudo needs an explicit yes"
    m '^rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\$HOME|\.git)([[:space:]/]*$)' && deny "rm -rf on /, ~, or .git is banned"
  fi

  # --- 4. deploys --------------------------------------------------------------
  if m '(^|[[:space:]])wrangler[[:space:]]+deploy([[:space:]]|$)' && ! printf '%s' "$cmd" | grep -q watchdog; then
    deny "bare 'wrangler deploy' skips NODE_ENV=production, populateCache and --env=\"\" (gmh deploy skill). Use 'bun run deploy' in the app dir, after the user's yes"
  fi
  if m '^(bun|npm|pnpm)[[:space:]]+run[[:space:]]+deploy([[:space:]:]|$)|(^|[[:space:]])wrangler[[:space:]]+deploy([[:space:]]|$)|^vercel[[:space:]]+(deploy|--prod)|^fly[[:space:]]+deploy|^railway[[:space:]]+up'; then
    ok_for deploy || deny "deploys wait for the user's explicit yes. After a yes, re-run as: CLAUDE_OK=deploy <same command>"
  fi

  # --- 5. dependency changes need a yes; package-manager rules -------------------
  m '^yarn([[:space:]]|$)' && deny "yarn is never used; bun (or the repo's lockfile manager)"
  if ! ok_for deps; then
    m '^bun[[:space:]]+(add|remove|rm|update|upgrade|pm[[:space:]]+trust)([[:space:]]|$)' && deny "adding/removing/upgrading a dependency needs the user's explicit yes (any manifest or lockfile change). After a yes: CLAUDE_OK=deps <cmd>. Pin exact versions (bun add -E)"
    m '^bun[[:space:]]+(install|i)[[:space:]]+[^-[:space:]]' && deny "bun install <pkg> adds a dependency; explicit yes needed (CLAUDE_OK=deps)"
    m '^(command[[:space:]]+)?npm[[:space:]]+(install|i|add|uninstall|remove|rm|update|up)[[:space:]]+[^-[:space:]]' && deny "npm install <pkg> changes the lockfile; explicit yes needed (CLAUDE_OK=deps)"
    m '^(command[[:space:]]+)?npm[[:space:]]+(install|i)[[:space:]]+(-[gD]|--(global|save))' && deny "npm install -g/-D changes deps; explicit yes needed (CLAUDE_OK=deps)"
    m '^pnpm[[:space:]]+(add|remove|rm|update|up)([[:space:]]|$)' && deny "pnpm add/remove needs the user's explicit yes (CLAUDE_OK=deps)"
    m '^uv[[:space:]]+(add|remove|lock[[:space:]]+--upgrade)([[:space:]]|$)|^pip3?[[:space:]]+install([[:space:]]|$)|^poetry[[:space:]]+add' && deny "python dependency change needs the user's explicit yes (CLAUDE_OK=deps); use uv"
    m '^cargo[[:space:]]+(add|remove)([[:space:]]|$)|^brew[[:space:]]+(install|uninstall)([[:space:]]|$)|^gem[[:space:]]+install' && deny "installing packages needs the user's explicit yes (CLAUDE_OK=deps)"
    m '^(bunx|npx|pnpm[[:space:]]+dlx)[[:space:]]+(eslint|biome|prettier)[[:space:]]+(--init|init)|^(bun|npm|pnpm)[[:space:]]+(add|install|i)[[:space:]].*(^|[[:space:]@])(eslint|biome)' && deny "never add eslint or biome; lint with oxlint, format with oxfmt/prettier"
  fi

  # --- 6. simulators: reuse, never spawn -------------------------------------------
  m '^xcrun[[:space:]]+simctl[[:space:]]+(create|clone)([[:space:]]|$)' && deny "never create simulators (disk cost). Reuse the existing iPhone 17 Pro: xcrun simctl list devices | grep 'iPhone 17 Pro '"
  if m '^xcrun[[:space:]]+simctl[[:space:]]+boot([[:space:]]|$)'; then
    booted="$(xcrun simctl list devices booted 2>/dev/null | grep -c Booted || true)"
    [ "${booted:-0}" -ge 2 ] && deny "2 simulators are already booted; reuse one (xcrun simctl list devices booted) instead of booting more"
  fi
  if m '^xcodebuild([[:space:]]|$)'; then
    m '[[:space:]]-quiet([[:space:]]|$)' && deny "never pass -quiet to xcodebuild: it swallows the failure reason"
    m '-destination[[:space:]]+["'"'"']?[^"'"'"']*name=' && deny "pin -destination by id=<udid>, never name= (ambiguous when Pro and Pro Max both exist)"
  fi

  # --- 7. never re-record baselines -------------------------------------------------
  m '(^|[[:space:]])(vitest|jest|(bun|npm|pnpm)[[:space:]]+(run[[:space:]]+)?test)([[:space:]].*)?[[:space:]](-u|--update)([[:space:]]|$)|--update-snapshots|UPDATE_SNAPSHOTS=1' && deny "never re-record a snapshot or baseline to make a diff go away"
done <<EOF
$segments
EOF
exit 0
