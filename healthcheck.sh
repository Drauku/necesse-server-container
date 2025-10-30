#!/bin/sh

LOG_FILE="/home/necesse/.config/Necesse/logs/healthcheck.log"

if ! pgrep -f "java.*Server.jar" > /dev/null; then
    echo "Java process not running"
    exit 1
fi

if [ -f "$LOG_FILE" ] && grep -q "Server started" "$LOG_FILE"; then
    echo "Server is healthy"
    exit 0
else
    echo "Server not ready"
    exit 1
fi