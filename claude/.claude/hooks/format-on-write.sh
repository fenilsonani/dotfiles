#!/usr/bin/env bash
# PostToolUse(Edit|Write): run the repo's OWN formatter on the file just written.
# Only formats when the repo has that formatter configured (obey the repo config exactly,
# never impose one). Always exits 0: formatting is convenience, not policy.
set -u
input="$(cat)"
f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')"
[ -n "$f" ] && [ -f "$f" ] || exit 0
case "$f" in */node_modules/*|*/.git/*|*/dist/*|*/build/*|*/.open-next/*|*.lock|*.lockb) exit 0;; esac

dir="$(dirname "$f")"
root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")"
# nearest package dir (monorepo apps/* have their own node_modules/.bin sometimes)
bin() { for d in "$dir" "$root"; do [ -x "$d/node_modules/.bin/$1" ] && { echo "$d/node_modules/.bin/$1"; return; }; done; command -v "$1" 2>/dev/null; }

case "$f" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.jsonc|*.css|*.md|*.svelte|*.vue|*.yml|*.yaml)
    if ls "$root"/.oxfmtrc* >/dev/null 2>&1 || grep -q '"oxfmt"' "$root/package.json" 2>/dev/null; then
      x="$(bin oxfmt)"; [ -n "$x" ] && "$x" "$f" >/dev/null 2>&1
    elif ls "$root"/.prettierrc* "$root"/prettier.config.* >/dev/null 2>&1; then
      x="$(bin prettier)"; [ -n "$x" ] && "$x" --write --log-level=silent "$f" >/dev/null 2>&1
    fi ;;
  *.swift)
    if [ -f "$root/.swiftformat" ] && command -v swiftformat >/dev/null; then
      swiftformat --quiet "$f" >/dev/null 2>&1
    fi ;;
  *.c|*.cc|*.cpp|*.cxx|*.h|*.hh|*.hpp|*.m|*.mm)
    if [ -f "$root/.clang-format" ] && command -v clang-format >/dev/null; then
      clang-format -i "$f" >/dev/null 2>&1
    fi ;;
  *.py)
    if grep -qE '^\[tool\.(black|ruff)' "$root/pyproject.toml" 2>/dev/null; then
      if grep -q '^\[tool.ruff' "$root/pyproject.toml"; then (cd "$root" && uv run --quiet ruff format "$f") >/dev/null 2>&1
      else (cd "$root" && uv run --quiet black -q "$f") >/dev/null 2>&1; fi
    fi ;;
  *.rs)
    [ -f "$root/Cargo.toml" ] && command -v rustfmt >/dev/null && rustfmt --edition 2021 "$f" >/dev/null 2>&1 ;;
esac
exit 0
