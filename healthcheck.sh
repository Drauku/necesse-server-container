#!/bin/bash
set -euo pipefail

# Paths (match the ones used in entrypoint.sh)
SERVER_DIR="${HOME}/necesse"
LOG_DIR="${HOME}/.config/Necesse/logs"
LOG_FILE="${LOG_DIR}/latest.log"

# 1. Is the Java process running?
if ! pgrep -f "java.*Server.jar" > /dev/null; then
    echo "Java process not found"
    exit 1
fi

# 2. Did the server finish booting?
if [[ -f "$LOG_FILE" ]]; then
    if grep -q "Server started" "$LOG_FILE"; then
        echo "Server is up and reports 'Server started'"
        exit 0
    else
        echo "Server process alive but not yet started (no 'Server started' in log)"
        exit 1
    fi
else
    echo "Log file missing – assuming server is still initializing"
    exit 1
fi