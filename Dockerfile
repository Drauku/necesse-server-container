# ---- Stage 1: SteamCMD -------------------------------------------------------
    FROM steamcmd/steamcmd:alpine AS steamcmd

    # ---- Stage 2: Runtime --------------------------------------------------------
    FROM eclipse-temurin:17-jre-alpine AS runtime

    # Install 32-bit libs
    RUN apk add --no-cache libstdc++ libgcc

    # Copy steamcmd
    COPY --from=steamcmd /usr/bin/steamcmd /usr/bin/steamcmd
    COPY --from=steamcmd /usr/lib/games/steam /usr/lib/games/steam

    # Create user and FULL config tree
    ENV USER=necesse
    ENV HOME=/home/necesse
    ENV BASE=/home/necesse/.config/Necesse
    RUN mkdir -p "$BASE/cfg" \
                 "$BASE/logs" \
                 "$BASE/cache" \
                 "$BASE/saves" && \
        adduser -D -h "$HOME" "$USER" && \
        chown -R "$USER":"$USER" "$HOME"

    WORKDIR "$HOME"
    USER "$USER"

    # Only JVMARGS
    ENV JVMARGS=""

    # Scripts
    COPY --chmod=0755 entrypoint.sh /entrypoint.sh
    COPY --chmod=0755 healthcheck.sh /healthcheck.sh

    HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=5 \
        CMD /healthcheck.sh || exit 1

    EXPOSE 14159/udp 14159/tcp
    ENTRYPOINT ["/entrypoint.sh"]