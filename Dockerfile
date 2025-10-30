# ---- Stage 1: SteamCMD -------------------------------------------------------
FROM steamcmd/steamcmd:alpine AS steamcmd

# ---- Stage 2: Runtime --------------------------------------------------------
FROM eclipse-temurin:17-jre AS runtime

RUN apk add --no-cache libstdc++ libgcc

COPY --from=steamcmd /usr/bin/steamcmd /usr/bin/steamcmd
COPY --from=steamcmd /usr/lib/games/steam /usr/lib/games/steam

# User + home
ENV USER=necesse HOME=/home/necesse
RUN adduser -D -h "$HOME" "$USER"

# Create full Necesse config tree
ENV GAME_DIR="$HOME/.config/Necesse"
RUN mkdir -p \
        "$GAME_DIR/cfg" \
        "$GAME_DIR/logs" \
        "$GAME_DIR/cache" \
        "$GAME_DIR/saves" \
        "$GAME_DIR/server" && \
    chown -R "$USER":"$USER" "$HOME"

WORKDIR "$HOME"
USER "$USER"

ENV JVMARGS=""

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
COPY --chmod=0755 healthcheck.sh /healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=5 \
    CMD /healthcheck.sh || exit 1

EXPOSE 14159/udp 14159/tcp
ENTRYPOINT ["/entrypoint.sh"]
