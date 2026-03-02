#!/usr/bin/env bash

# tmux-multitail-plugin
# A tmux plugin to tail multiple log files in panes
#
# Installation:
#   Add to ~/.tmux.conf:
#     set -g @plugin 'Crucifixion-Fxl/tmux-multitail-plugin'
#   Then press prefix + I to install
#
# Usage:
#   Press prefix + m to tail all .log files in the current directory

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${CURRENT_DIR}/scripts"

main() {
    # Bind the key to run the multitail script
    tmux bind-key m run-shell "bash ${SCRIPTS_DIR}/multitail.sh"
}

main