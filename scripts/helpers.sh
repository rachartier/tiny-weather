#!/usr/bin/env bash

set_tmux_option() {
  local option="$1"
  local value="$2"
  tmux set-option -gq "$option" "$value"
}

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(tmux show-option -gqv "$option")"
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

# get files age in seconds
get_file_age() { # $1 - cache file
  local file_path="${1:-}"
  local now=$(date +%s)
  if [ -f "$file_path" ]; then
    local file_modification_timestamp=$(stat -c "%Y" "$file_path" 2>/dev/null || echo 0)
    echo $((now - file_modification_timestamp))
  else
    echo "-1" # Return -1 for missing files
  fi
}
