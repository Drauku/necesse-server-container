#!/bin/sh
set -euo pipefail

echo "Updating Necesse server..."

# ONE steamcmd call with all commands
        #  +force_install_dir "${GAME_DIR}/server" \
steamcmd +login anonymous \
         +app_update 1169370 force_install_dir "${GAME_DIR}/server" validate \
         +quit

chmod +x "${GAME_DIR}/server/StartServer-nogui.sh"

# Necesse reads/writes config in server/cfg, NOT cfg/
CFG_DIR="${GAME_DIR}/cfg"
LOG_DIR="${GAME_DIR}/logs"
mkdir -p "$CFG_DIR" "$LOG_DIR"
# echo -e "DEBUG: CFG_DIR: $CFG_DIR"
echo -e "DEBUG: LOG_DIR: $LOG_DIR"

CFG_FILE="$CFG_DIR/server.cfg"
echo -e "DEBUG: CFG_FILE: $CFG_FILE"

# Create default server.cfg if missing
if [ ! -f "$CFG_FILE" ]; then
    cat > "$CFG_FILE" <<'EOF'
SERVER = {
    port = 14159,
    slots = 10,
    password = ,
    maxClientLatencySeconds = 30,
    pauseWhenEmpty = true,
    strictServerAuthority = false,
    logging = true,
    language = en,
    unloadLevelsCooldown = 30,
    droppedItemsLifeMinutes = 0,
    unloadSettlements = false,
    maxSettlementsPerPlayer = -1,
    maxSettlersPerSettlement = -1,
    zipSaves = true,
    MOTD =
}
EOF
fi

write_cfg() {
  key="$1" value="$2"
  # Remove old line
  sed -i "/^[[:space:]]*${key}[[:space:]]*=/d" "$CFG_FILE" 2>/dev/null || true
  # Append
  printf "%s=%s\n" "$key" "$value" >> "$CFG_FILE"
}

# Apply ENV vars (non-empty world required!)
write_cfg "world"               "${WORLD:-necesseworld}"
write_cfg "slots"               "${SLOTS:-10}"
write_cfg "owner"               "${OWNER:-}"
write_cfg "password"            "${PASSWORD:-}"
write_cfg "motd"                "${MOTD:-This server made possible by Docker!}"
write_cfg "pause"               "${PAUSE:-0}"
write_cfg "giveclientspower"    "${GIVE_CLIENTS_POWER:-1}"
write_cfg "logging"             "${LOGGING:-1}"
write_cfg "zip"                 "${ZIP:-1}"

ENV WORLD="necesseworld"
ENV SLOTS="10"
ENV OWNER=""
ENV PASSWORD=""
ENV MOTD="This server made possible by Docker!"
ENV PAUSE="0"
ENV GIVE_CLIENTS_POWER="1"
ENV LOGGING="1"
ENV ZIP="1"

JAVA_CMD="java"
[ -n "${JVMARGS:-}" ] && JAVA_CMD="${JAVA_CMD} ${JVMARGS}"

echo "Starting Necesse server..."
exec $JAVA_CMD -jar "${GAME_DIR}/server/Server.jar" -nogui
# exec $JAVA_CMD ${JVMARGS} \
#   -jar Server.jar \
#   -nogui -localdir \
#   -world "${WORLD}" \
#   -slots "${SLOTS}" \
#   -owner "${OWNER}" \
#   -motd "${MOTD}" \
#   -password "${PASSWORD}" \
#   -pausewhenempty "${PAUSE}" \
#   -giveclientspower "${GIVE_CLIENTS_POWER}" \
#   -logging "${LOGGING}" \
#   -zipsaves "${ZIP}"
