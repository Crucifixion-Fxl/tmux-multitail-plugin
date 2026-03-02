# tmux-multitail-plugin

A tmux plugin that automatically splits your current window into panes and tails all `.log` files in the current directory.

## Features

- Automatically detects all `.log` files in the current working directory
- Smart layout calculation - arranges panes in an optimal grid
- One-key activation - press `prefix + m` to tail all logs
- Works with any number of log files

## Installation

### Option 1: Using TPM (Recommended)

1. Install [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) if you haven't already

2. Add this plugin to your `.tmux.conf`:
   ```bash
   set -g @plugin 'fengxiaolong/tmux-multitail-plugin'
   ```

3. Press `prefix + I` to install the plugin

### Option 2: Manual Installation

1. Clone or download this repository to your tmux plugins directory:
   ```bash
   git clone https://github.com/fengxiaolong/tmux-multitail-plugin.git ~/.tmux/plugins/tmux-multitail-plugin
   ```

2. Add this line to your `.tmux.conf`:
   ```bash
   run-shell "#{plugin_root}/tmux-multitail-plugin/plugin.tmux"
   ```

3. Reload tmux configuration:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

## Usage

1. Navigate to a directory containing `.log` files
2. Press `prefix + m`
3. The plugin will:
   - Scan the current directory for `*.log` files
   - Split the current window into the appropriate number of panes
   - Start `tail -F` on each log file in its own pane

## Examples

### Single log file
```
app.log
```
Press `prefix + m` → tails `app.log` in current pane

### Multiple log files
```
error.log
access.log
debug.log
```
Press `prefix + m` → splits into 3 panes, each tailing a different log

## Layout Algorithm

The plugin uses a smart layout algorithm:
- 1-2 files: 2 columns
- 3-4 files: 2x2 grid
- 5-6 files: 3x2 or 2x3 grid
- 7-9 files: 3x3 grid
- And so on...

## Customization

### Change the key binding

Add this to your `.tmux.conf` before loading the plugin:
```bash
# Change 'm' to your preferred key
unbind m
bind-key M run-shell "bash #{plugin_root}/tmux-multitail-plugin/scripts/multitail.sh"
```

Then reload tmux: `tmux source-file ~/.tmux.conf`

## Requirements

- tmux 1.9 or higher
- bash 4.0 or higher

## License

MIT