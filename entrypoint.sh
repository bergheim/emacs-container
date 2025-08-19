#!/bin/sh
# entrypoint.sh: Start D-Bus and launch Emacs GUI

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
  echo "Neither DISPLAY nor WAYLAND_DISPLAY is set"
  exit 1
fi

# Export GPG_TTY for gpg-agent/pinentry communication
export GPG_TTY=$(tty)

# Start session bus for Emacs GUI (needed for DBus features)
dbus-daemon --session --fork --address=unix:path=$XDG_RUNTIME_DIR/bus

# Restart gpg-agent so it picks up updated config (~/.gnupg/gpg-agent.conf)
gpgconf --kill gpg-agent || true
gpgconf --launch gpg-agent

# Start session bus for Emacs
dbus-daemon --session --fork --address=unix:path=$XDG_RUNTIME_DIR/bus

# Run Emacs GUI
exec emacs
