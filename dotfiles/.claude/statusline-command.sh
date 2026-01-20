#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract Claude Code info
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
output_style=$(echo "$input" | jq -r '.output_style.name // ""')
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Terminal-style elements
user=$(whoami)
host=$(hostname -s)

# Simplify directory path - replace home with ~
if [[ "$cwd" == "$HOME"* ]]; then
  display_dir="~${cwd#$HOME}"
else
  display_dir="$cwd"
fi

# Get git info (skip locks for performance)
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null || echo "detached")

  # Check for uncommitted changes
  if ! git -C "$cwd" --no-optional-locks diff-index --quiet HEAD -- 2>/dev/null; then
    git_status="*"
  else
    git_status=""
  fi

  git_info=" $(printf '\033[35m')($branch$git_status)$(printf '\033[0m')"
fi

# Build context info
context_info=""
if [ -n "$context_remaining" ]; then
  # Color code based on remaining percentage
  if (( $(echo "$context_remaining < 20" | bc -l) )); then
    context_color='\033[31m'  # Red
  elif (( $(echo "$context_remaining < 50" | bc -l) )); then
    context_color='\033[33m'  # Yellow
  else
    context_color='\033[32m'  # Green
  fi
  context_info=" $(printf "${context_color}")${context_remaining}%$(printf '\033[0m')"
fi

# Build output style info
style_info=""
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
  style_info=" $(printf '\033[36m')[${output_style}]$(printf '\033[0m')"
fi

# Build the status line with colors
printf '\033[32m'  # Green for user@host
echo -n "${user}@${host}"
printf '\033[0m'   # Reset
echo -n " "
printf '\033[34m'  # Blue for directory
echo -n "${display_dir}"
printf '\033[0m'   # Reset
echo -n "${git_info}"
echo -n " "
printf '\033[33m'  # Yellow for model
echo -n "[${model}]"
printf '\033[0m'   # Reset
echo -n "${context_info}"
echo -n "${style_info}"
