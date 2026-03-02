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

# Get current pane index
CURRENT_IDX=$(tmux display-message -p "#{pane_index}")

# Split window to create (COUNT - 1) additional panes
for ((i = 1; i < COUNT; i++)); do
    tmux split-window -h -t "$CURRENT_IDX"
done

# Arrange panes in a nice grid layout
tmux select-layout -t "$CURRENT_IDX" tiled >/dev/null 2>&1

# After layout, get panes in visual order (left-to-right, top-to-bottom)
# Use layout order which is the order panes appear in the grid
PANE_ORDER=$(tmux list-panes -F "#{pane_id}" | tr '\n' ' ')

# Send tail command to each pane using 0-based indexing
# But we need to account for base-index (which is 1 in user's config)
TMPFILE=$(mktemp /tmp/multitail.XXXXXX)
echo "$LOG_LIST" > "$TMPFILE"

i=1
while read -r log_file; do
    # Use 1-based index for send-keys (matches pane-base-index)
    tmux send-keys -t $i "tail -F '$log_file'" C-m
    i=$((i + 1))
done < "$TMPFILE"

rm -f "$TMPFILE"

# Return to first pane
tmux select-pane -t "$CURRENT_IDX"

tmux display-message "Tailing $COUNT log files"