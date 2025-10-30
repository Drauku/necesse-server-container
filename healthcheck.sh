#!/bin/sh

LOG_DIR="/home/necesse/.config/Necesse/logs"
LATEST_LOG="$LOG_DIR/latest.log"

if [ -d "$LOG_DIR" ]; then
    ACTUAL_LOG=$(find "$LOG_DIR" -name "*.txt" -type f -exec stat -c '%Y %n' {} + 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
else
    ACTUAL_LOG=""
fi

if ! pgrep -f "java.*Server.jar" > /dev/null; then
    echo "Java process not running"
    exit 1
fi

if [ -n "$ACTUAL_LOG" ] && grep -q "Server started" "$ACTUAL_LOG" 2>/dev/null; then
    ln -sf "$(basename "$ACTUAL_LOG")" "$LATEST_LOG" 2>/dev/null || true
    echo "Server is healthy"
    exit 0
else
    echo "Server not ready (no 'Server started' in logs)"
    exit 1
fi
