# tmux-multitail-plugin
# A tmux plugin to tail multiple log files in panes
#
# Installation (Option 1 - via TPM):
#   Add to ~/.tmux.conf:
#     set -g @plugin 'fengxiaolong/tmux-multitail-plugin'
#   Then press prefix + I to install
#
# Installation (Option 2 - manual):
#   Add to ~/.tmux.conf:
#     run-shell "#{plugin_root}/tmux-multitail-plugin/plugin.tmux"
#   Then restart tmux or press prefix + I to reload
#
# Usage:
#   Press prefix + m to tail all .log files in the current directory

# Bind the key to run the multitail script
bind-key m run-shell "bash #{plugin_root}/tmux-multitail-plugin/scripts/multitail.sh"