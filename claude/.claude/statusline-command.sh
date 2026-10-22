#!/bin/bash
input=$(cat)

IFS=$'\t' read -r model effort cwd pct five week < <(echo "$input" | jq -r '[
  .model.display_name,
  (.effort.level? // "-"),
  (.workspace.current_dir // .cwd // "-"),
  ((.context_window.used_percentage // 0) | floor | tostring),
  (.rate_limits.five_hour.used_percentage | if . == null then "-" else (floor | tostring) end),
  (.rate_limits.seven_day.used_percentage | if . == null then "-" else (floor | tostring) end)
] | @tsv')

if [ "$pct" -ge 80 ]; then c=31; elif [ "$pct" -ge 50 ]; then c=33; else c=32; fi

width=10
filled=$((pct * width / 100))
[ "$filled" -gt "$width" ] && filled=$width
bar=""
for ((i = 0; i < width; i++)); do
  if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
done

limit_color() {
  if [ "$1" -ge 80 ]; then echo 31; elif [ "$1" -ge 50 ]; then echo 33; else echo 32; fi
}

out=$(printf '\033[36m%s\033[0m' "$model")
[ "$effort" != "-" ] && out="$out$(printf ' \033[2m(%s)\033[0m' "$effort")"
out="$out$(printf ' | \033[%sm%s %s%%\033[0m' "$c" "$bar" "$pct")"
out="$out$(printf ' | \033[34m%s\033[0m' "$(basename "$cwd")")"

if [ "$cwd" != "-" ]; then
  branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
  [ -n "$branch" ] && out="$out$(printf ' \033[35m%s\033[0m' "$branch")"
fi

[ "$five" != "-" ] && out="$out$(printf ' | 5h \033[%sm%s%%\033[0m' "$(limit_color "$five")" "$five")"
[ "$week" != "-" ] && out="$out$(printf ' 7d \033[%sm%s%%\033[0m' "$(limit_color "$week")" "$week")"

printf '%s' "$out"
