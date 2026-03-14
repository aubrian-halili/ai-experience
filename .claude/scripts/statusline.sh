#!/usr/bin/env bash
# Claude Code status line — context window dashboard
set -euo pipefail

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  bar_width=10
  filled=$(( used_int * bar_width / 100 ))
  empty=$(( bar_width - filled ))
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}#"; done
  for i in $(seq 1 $empty); do bar="${bar}-"; done
  printf "\033[36m%s\033[0m  [%s] %d%%" "$model" "$bar" "$used_int"
else
  printf "\033[36m%s\033[0m  [----------] --%%" "$model"
fi
