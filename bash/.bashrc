# Claude Code runs its Bash tool through this file (CLAUDE_CODE_SHELL); PATH order matches fish/config.fish
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
eval "$(/opt/homebrew/bin/brew shellenv bash)"
export ANDROID_HOME="$HOME/Library/Android/sdk"
# node@22 and openjdk@17 sit behind Homebrew so `node` and `java` stay the latest versions
export PATH="$PATH:/opt/homebrew/opt/node@22/bin:/opt/homebrew/opt/openjdk@17/bin:$HOME/.docker/bin:$HOME/.local/bin:/Library/TeX/texbin:$HOME/.lmstudio/bin"
# iTerm.app/Contents/Resources/utilities ships its own it2 that shadows the uv-installed one Claude Code agent teams expect
export PATH="$HOME/.local/priority-bin:$PATH"
# keg-only libpq (psql, pg_isready) and Android platform-tools (adb) are off PATH by default
export PATH="/opt/homebrew/opt/libpq/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/.resend/bin:/opt/homebrew/opt/openjdk/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.codeium/windsurf/bin:$HOME/.antigravity/antigravity/bin:$HOME/.cap/bin:$HOME/.grok/bin:$PATH"

export LANG=en_US.UTF-8
export BUN_INSTALL="$HOME/.bun"

# Agents call these bare; resolve through the repo's own node_modules via bunx
for _c in tsc vitest tsx playwright turbo wrangler; do
  eval "$_c() { bunx $_c \"\$@\"; }"
done; unset _c

# Spotlight: keep node_modules/.git out of the index. NO leading underscore on the
# function name: Claude Code's shell snapshot drops _-prefixed functions.
spotlight_block() {
  [ -d node_modules ] && touch node_modules/.metadata_never_index
  [ -d .git ] && touch .git/.metadata_never_index
  return 0
}
npm()   { command npm "$@";          local rc=$?; spotlight_block; return $rc; }
npx()   { command npx "$@";          local rc=$?; spotlight_block; return $rc; }
buni()  { command bun install "$@";  local rc=$?; spotlight_block; return $rc; }
pnpmi() { command pnpm install "$@"; local rc=$?; spotlight_block; return $rc; }

# Unsets the invalid GITHUB_TOKEN that IDE extensions export
gp() { (unset GITHUB_TOKEN; git push "$@"); }
# Talks to the daemon on /var/run/tailscaled.socket, which serves both the GUI extension and a homebrew LaunchDaemon
tailscale() { /opt/homebrew/bin/tailscale --socket=/var/run/tailscaled.socket "$@"; }

# Hook-based tools init only outside Claude Code (its snapshot drops _-prefixed functions); agents get mise shims instead
if [[ -n $CLAUDECODE ]]; then
  command -v mise >/dev/null && eval "$(mise activate bash --shims)"
elif [[ $- == *i* ]]; then
  command -v mise >/dev/null && eval "$(mise activate bash)"
  [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
  command -v atuin >/dev/null && eval "$(atuin init bash)"
fi
