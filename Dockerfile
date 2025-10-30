# ----------------------------------------------------------------------
# Stage 1 – SteamCMD (Alpine, multi‑arch)
# ----------------------------------------------------------------------
FROM steamcmd/steamcmd:alpine AS steamcmd

# ----------------------------------------------------------------------
# Stage 2 – Runtime (Ubuntu‑based Temurin – supports amd64 + arm64)
# ----------------------------------------------------------------------
FROM eclipse-temurin:17-jre AS runtime

# Install only the runtime libraries we need (no apk‑127 error)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libstdc++6 \
        libgcc-s1 && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# Copy steamcmd binary + steam libraries
# ----------------------------------------------------------------------
COPY --from=steamcmd /usr/bin/steamcmd /usr/bin/steamcmd
COPY --from=steamcmd /usr/lib/games/steam /usr/lib/games/steam

# ----------------------------------------------------------------------
# Create non‑root user
# ----------------------------------------------------------------------
ENV USER=necesse HOME=/home/necesse
RUN useradd -m -d "$HOME" "$USER"

# ----------------------------------------------------------------------
# Necesse directories (owned by the user)
# ----------------------------------------------------------------------
ENV GAME_DIR="$HOME/.config/Necesse"
RUN mkdir -p \
        "$GAME_DIR/cfg" \
        "$GAME_DIR/logs" \
        "$GAME_DIR/cache" \
        "$GAME_DIR/saves" \
        "$GAME_DIR/server" && \
    chown -R "$USER":"$USER" "$HOME"

WORKDIR "$GAME_DIR"
USER "$USER"

# ----------------------------------------------------------------------
# Optional JVM args
# ----------------------------------------------------------------------
ENV JVMARGS=""

# ----------------------------------------------------------------------
# Scripts
# ----------------------------------------------------------------------
COPY --chmod=0755 entrypoint.sh   entrypoint.sh
COPY --chmod=0755 healthcheck.sh  healthcheck.sh

# ----------------------------------------------------------------------
# Healthcheck & expose
# ----------------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=5 \
    CMD /healthcheck.sh || exit 1

EXPOSE 14159/tcp 14159/udp

ENTRYPOINT ["./entrypoint.sh"]
