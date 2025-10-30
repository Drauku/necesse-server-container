#!/bin/sh

LOG_FILE="$HOME/.config/Necesse/logs/latest.log"

# 1. Java process?
if ! pgrep -f "java.*Server.jar" > /dev/null; then
    echo "Java process not running"
    exit 1
fi

# 2. Server started?
if [ -f "$LOG_FILE" ] && grep -q "Server started" "$LOG_FILE"; then
    echo "Server is healthy"
    exit 0
else
    echo "Server not ready (no 'Server started' in log)"
    exit 1
fi
