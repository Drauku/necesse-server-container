#!/bin/sh
set -euo pipefail

echo "Updating Necesse server..."
steamcmd +login anonymous \
         +force_install_dir "${HOME}/necesse" \
         +app_update 1169370 validate \
         +quit

chmod +x "${HOME}/necesse/StartServer-nogui.sh"

CFG_DIR="${HOME}/necesse/cfg"
LOG_DIR="${HOME}/.config/Necesse/logs"
mkdir -p "${CFG_DIR}" "${LOG_DIR}"

CFG_FILE="${CFG_DIR}/server.cfg"
: > "${CFG_FILE}"

write_cfg() {
  key="$1"
  value="$2"
  grep -v "^[[:space:]]*${key}[[:space:]]*=" "$CFG_FILE" > "${CFG_FILE}.tmp" || true
  mv "${CFG_FILE}.tmp" "$CFG_FILE"
  printf "%s=%s\n" "$key" "$value" >> "$CFG_FILE"
}

write_cfg "world"               "${WORLD:-}"
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
exec ${JAVA_CMD} -jar "${HOME}/necesse/Server.jar" -nogui
