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

# Bind the key to run the multitail script
# This will work when the plugin is loaded by TPM
run 'tmux bind-key m run-shell "bash #{plugin_root}/tmux-multitail-plugin/scripts/multitail.sh"'