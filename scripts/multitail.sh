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
# Use nullglob to handle no matches (works in both bash and zsh)
case "$SHELL" in
    */zsh)
        setopt NULL_GLOB
        LOG_FILES=("$CURRENT_PATH"/*.log)
        unsetopt NULL_GLOB
        ;;
    *)
        shopt -s nullglob
        LOG_FILES=("$CURRENT_PATH"/*.log)
        shopt -u nullglob
        ;;
esac
COUNT=${#LOG_FILES[@]}

# Check if any log files were found
if [ "$COUNT" -eq 0 ]; then
    tmux display-message "No .log files found in $(basename "$CURRENT_PATH")"
    exit 0
fi

# If only 1 log file, just tail it in the current pane
if [ "$COUNT" -eq 1 ]; then
    tmux send-keys "tail -F '${LOG_FILES[0]}'" C-m
    tmux display-message "Tailing: $(basename "${LOG_FILES[0]}")"
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

# Send tail command to each pane using 1-based index
for ((i = 0; i < COUNT; i++)); do
    tmux send-keys -t $((i + 1)) "tail -F '${LOG_FILES[i]}'" C-m
done

# Return to first pane
tmux select-pane -t "$CURRENT_IDX"

tmux display-message "Tailing $COUNT log files"