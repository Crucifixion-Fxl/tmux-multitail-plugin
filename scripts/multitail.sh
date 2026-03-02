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
mapfile -t LOG_FILES < <(ls -1 "$CURRENT_PATH"/*.log 2>/dev/null)

# Check if any log files were found
if [ ${#LOG_FILES[@]} -eq 0 ]; then
    tmux display-message "No .log files found in $(basename "$CURRENT_PATH")"
    exit 0
fi

COUNT=${#LOG_FILES[@]}

# Calculate optimal layout
# Returns: rows cols
calculate_layout() {
    local count=$1
    local cols rows

    if [ "$count" -eq 1 ]; then
        echo "1 1"
        return
    fi

    # Find best columns (prefer wider layouts for log viewing)
    cols=1
    for ((i = 2; i <= count; i++)); do
        if [ $((count % i)) -eq 0 ]; then
            cols=$i
            rows=$((count / i))
            # Prefer layouts where cols >= rows
            if [ "$cols" -ge "$rows" ]; then
                echo "$rows $cols"
                return
            fi
        fi
    done

    # If no ideal divisor found, use approximate
    cols=$(( (count + 1) / 2 ))
    rows=$(( (count + cols - 1) / cols ))
    echo "$rows $cols"
}

# Calculate rows and columns
read -r ROWS COLS <<< "$(calculate_layout "$COUNT")"

# If only 1 log file, just tail it in the current pane
if [ "$COUNT" -eq 1 ]; then
    tmux send-keys "tail -F '${LOG_FILES[0]}'" C-m
    tmux display-message "Tailing: $(basename "${LOG_FILES[0]}")"
    exit 0
fi

# Split window to create (COUNT - 1) additional panes
# Using -h (horizontal split) repeatedly creates a row of panes
# Then we'll use select-layout to arrange them
for ((i = 1; i < COUNT; i++)); do
    tmux split-window -h -t 0
done

# Arrange panes in a nice grid layout
tmux select-layout -t 0 tiled >/dev/null 2>&1

# Send tail command to each pane
for ((i = 0; i < COUNT; i++)); do
    tmux send-keys -t $i "tail -F '${LOG_FILES[$i]}'" C-m
done

# Return to first pane
tmux select-pane -t 0

tmux display-message "Tailing $COUNT log files"