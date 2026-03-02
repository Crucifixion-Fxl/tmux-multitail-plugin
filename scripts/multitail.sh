#!/usr/bin/env bash
# tmux-multitail-plugin
# Automatically split current tmux window and tail all .log files

# Get current pane's working directory
CURRENT_PATH="$(tmux display-message -p "#{pane_current_path}")"

if [ -z "$CURRENT_PATH" ]; then
    tmux display-message "Error: Could not get current path"
    exit 1
fi

# Find all .log files in the current directory (non-recursive)
LOG_LIST=$(ls -1 "$CURRENT_PATH"/*.log 2>/dev/null)
COUNT=$(echo "$LOG_LIST" | grep -c . || echo 0)

# Check if any log files were found
if [ "$COUNT" -eq 0 ] || [ -z "$LOG_LIST" ]; then
    tmux display-message "No .log files found in $(basename "$CURRENT_PATH")"
    exit 0
fi

# If only 1 log file, just tail it in the current pane
if [ "$COUNT" -eq 1 ]; then
    LOG_FILE=$(echo "$LOG_LIST" | head -1)
    tmux send-keys "tail -F '$LOG_FILE'" C-m
    tmux display-message "Tailing: $(basename "$LOG_FILE")"
    exit 0
fi

# Split window to create (COUNT - 1) additional panes
for ((i = 1; i < COUNT; i++)); do
    tmux split-window -h -t 0
done

# Arrange panes in a nice grid layout
tmux select-layout -t 0 tiled >/dev/null 2>&1

# Send tail command to each pane
# Save log files to temp file for bash 3 compatibility
TMPFILE=$(mktemp /tmp/multitail.XXXXXX)
echo "$LOG_LIST" > "$TMPFILE"

i=0
while read -r log_file; do
    tmux send-keys -t $i "tail -F '$log_file'" C-m
    i=$((i + 1))
done < "$TMPFILE"

rm -f "$TMPFILE"

# Return to first pane
tmux select-pane -t 0

tmux display-message "Tailing $COUNT log files"