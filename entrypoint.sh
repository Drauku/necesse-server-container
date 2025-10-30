#!/bin/sh
set -euo pipefail

echo "Updating Necesse server..."
steamcmd +login anonymous
steamcmd +force_install_dir "${GAME_DIR}/.config/Necesse/server"
steamcmd +app_update 1169370 validate
steamcmd +quit
chmod +x "${GAME_DIR}/server/StartServer-nogui.sh"

# Necesse expects config in ~/.config/Necesse/cfg
CFG_DIR="${GAME_DIR}/cfg"
LOG_DIR="${GAME_DIR}/logs"
mkdir -p "$CFG_DIR" "$LOG_DIR"

CFG_FILE="$CFG_DIR/server.cfg"
: > "$CFG_FILE"

write_cfg() {
  key="$1" value="$2"
  grep -v "^[[:space:]]*${key}[[:space:]]*=" "$CFG_FILE" > "${CFG_FILE}.tmp" || true
  mv "${CFG_FILE}.tmp" "$CFG_FILE"
  printf "%s=%s\n" "$key" "$value" >> "$CFG_FILE"
}

# Apply ENV vars
write_cfg "world"               "${WORLD:-necessworld}"
write_cfg "slots"               "${SLOTS:-10}"
write_cfg "owner"               "${OWNER:-}"
write_cfg "password"            "${PASSWORD:-}"
write_cfg "motd"                "${MOTD:-This server made possible by Docker!}"
write_cfg "pause"               "${PAUSE:-0}"
write_cfg "giveclientspower"    "${GIVE_CLIENTS_POWER:-1}"
write_cfg "logging"             "${LOGGING:-1}"
write_cfg "zip"                 "${ZIP:-1}"

JAVA_CMD="java"
[ -n "${JVMARGS:-}" ] && JAVA_CMD="${JAVA_CMD} ${JVMARGS}"

echo "Starting Necesse server..."
exec $JAVA_CMD -jar "${GAME_DIR}/server/Server.jar" -nogui