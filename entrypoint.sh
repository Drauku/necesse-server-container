#!/bin/bash
set -euo pipefail

echo "Updating Necesse server files..."
steamcmd +login anonymous \
         +force_install_dir "${HOME}/necesse" \
         +app_update 1169370 validate \
         +quit

chmod +x "${HOME}/necesse/StartServer-nogui.sh"

# Ensure config and log dirs exist
CFG_DIR="${HOME}/necesse/cfg"
LOG_DIR="${HOME}/.config/Necesse/logs"
mkdir -p "$CFG_DIR" "$LOG_DIR"

CFG_FILE="${CFG_DIR}/server.cfg"
: > "$CFG_FILE"

write_cfg() {
  local key="$1" value="$2"
  sed -i "/^[[:space:]]*${key}[[:space:]]*=/I d" "$CFG_FILE" 2>/dev/null || true
  printf "%s=%s\n" "$key" "$value" >> "$CFG_FILE"
}

write_cfg "world"               "$WORLD"
write_cfg "slots"               "$SLOTS"
write_cfg "owner"               "$OWNER"
write_cfg "motd"                "$MOTD"
write_cfg "password"            "$PASSWORD"
write_cfg "pause"               "$PAUSE"
write_cfg "giveclientspower"    "$GIVE_CLIENTS_POWER"
write_cfg "logging"             "$LOGGING"
write_cfg "zip"                 "$ZIP"

JAVA_CMD="java"
[[ -n "$JVMARGS" ]] && JAVA_CMD="${JAVA_CMD} ${JVMARGS}"

echo "Starting Necesse server..."
exec ${JAVA_CMD} -jar "${HOME}/necesse/Server.jar" -nogui