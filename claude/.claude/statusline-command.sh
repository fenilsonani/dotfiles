#!/bin/bash
input=$(cat)

# Split on the unit separator: tab is IFS whitespace, so an empty field between tabs collapses and shifts every field after it.
IFS=$'\x1f' read -r model effort cwd pct five week < <(echo "$input" | jq -r '
  def pct: if type == "number" then floor | tostring else "-" end;
  [
    (.model.display_name // "-"),
    (.effort.level? // "-"),
    (.workspace.current_dir // .cwd // "-"),
    (.context_window.used_percentage | pct),
    (.rate_limits.five_hour.used_percentage | pct),
    (.rate_limits.seven_day.used_percentage | pct)
  ] | join("\u001f")')

level_color() {
  if [ "$1" = "-" ]; then echo 2; elif [ "$1" -ge 80 ]; then echo 31; elif [ "$1" -ge 50 ]; then echo 33; else echo 32; fi
}

shown() { if [ "$1" = "-" ]; then printf -- '-'; else printf '%s%%' "$1"; fi; }

width=10
filled=0
[ "$pct" != "-" ] && filled=$((pct * width / 100))
[ "$filled" -gt "$width" ] && filled=$width
bar=""
for ((i = 0; i < width; i++)); do
  if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
done

# Every segment is always drawn, with "-" while Claude Code has not sent its value, so the line keeps one shape.
out=$(printf '\033[36m%s\033[0m \033[2m(%s)\033[0m' "$model" "$effort")
out="$out$(printf ' | \033[%sm%s %s\033[0m' "$(level_color "$pct")" "$bar" "$(shown "$pct")")"
out="$out$(printf ' | \033[34m%s\033[0m' "$(basename "$cwd")")"

if [ "$cwd" != "-" ]; then
  branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
  [ -n "$branch" ] && out="$out$(printf ' \033[35m%s\033[0m' "$branch")"
fi

out="$out$(printf ' | 5h \033[%sm%s\033[0m' "$(level_color "$five")" "$(shown "$five")")"
out="$out$(printf ' 7d \033[%sm%s\033[0m' "$(level_color "$week")" "$(shown "$week")")"

printf '%s' "$out"
