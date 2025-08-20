#!/bin/sh
# entrypoint.sh: Start D-Bus and launch Emacs GUI
set -e

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "Neither DISPLAY nor WAYLAND_DISPLAY is set"
    exit 1
fi

# Set up XDG directories
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME"

# debug things
# echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
# echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
# ls -la "$XDG_RUNTIME_DIR/" 2>/dev/null || echo "XDG_RUNTIME_DIR contents not accessible"

# Export GPG_TTY for gpg-agent/pinentry communication
export GPG_TTY=$(tty 2>/dev/null || echo "/dev/console")

# Start session bus for Emacs GUI (needed for DBus features)
# if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
#     dbus-daemon --session --fork --address="unix:path=$XDG_RUNTIME_DIR/bus" || true
#     export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
# fi

export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# Restart gpg-agent so it picks up updated config (~/.gnupg/gpg-agent.conf)
gpgconf --kill gpg-agent || true
gpgconf --launch gpg-agent

export NO_AT_BRIDGE=1

# these errors are annoying:
# Gdk-Message: 13:58:28.552: Unable to load sb_v_double_arrow from the cursor theme
# export G_MESSAGES_DEBUG=""
# export XCURSOR_PATH=${XCURSOR_PATH}:~/.local/share/icons
# export XCURSOR_THEME=cursor_theme_name
# Run Emacs GUI
exec emacs
