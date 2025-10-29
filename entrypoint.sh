#!/bin/bash
set -euo pipefail

# ----------------------------------------------------------------------
# 1. Update / download the game (Steam AppID 1169370)
# ----------------------------------------------------------------------
echo "Updating Necesse server files..."
steamcmd +login anonymous \
         +force_install_dir "${HOME}/necesse" \
         +app_update 1169370 validate \
         +quit

# Make the bundled start script executable
chmod +x "${HOME}/necesse/StartServer-nogui.sh"

# ----------------------------------------------------------------------
# 2. Create / update server.cfg from environment variables
# ----------------------------------------------------------------------
CFG_DIR="${HOME}/necesse/cfg"
mkdir -p "$CFG_DIR"
CFG_FILE="${CFG_DIR}/server.cfg"

# Helper: write a line only if the value is non-empty
write_cfg() {
  local key="$1" value="$2"
  # Remove existing line for this key (case-insensitive)
  sed -i "/^[[:space:]]*${key}[[:space:]]*=/I d" "$CFG_FILE" 2>/dev/null || true
  # Append new line
  printf "%s=%s\n" "$key" "$value" >> "$CFG_FILE"
}

# Start with a fresh file (preserve any custom lines the user added manually)
: > "$CFG_FILE"

write_cfg "world"               "$WORLD"
write_cfg "slots"               "$SLOTS"
write_cfg "owner"               "$OWNER"
write_cfg "motd"                "$MOTD"
write_cfg "password"            "$PASSWORD"
write_cfg "pause"               "$PAUSE"
write_cfg "giveclientspower"    "$GIVE_CLIENTS_POWER"
write_cfg "logging"             "$LOGGING"
write_cfg "zip"                 "$ZIP"

# ----------------------------------------------------------------------
# 3. Build the Java command line
# ----------------------------------------------------------------------
JAVA_CMD="java"
[[ -n "$JVMARGS" ]] && JAVA_CMD="${JAVA_CMD} ${JVMARGS}"

# ----------------------------------------------------------------------
# 4. Run the server
# ----------------------------------------------------------------------
exec ${JAVA_CMD} -jar "${HOME}/necesse/Server.jar" -nogui
