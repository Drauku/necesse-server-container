# ---- Stage 1: SteamCMD -------------------------------------------------------
    FROM steamcmd/steamcmd:alpine AS steamcmd

    # ---- Stage 2: Runtime --------------------------------------------------------
    FROM eclipse-temurin:17-jre-alpine AS runtime

    RUN apk add --no-cache libstdc++ libgcc

    COPY --from=steamcmd /usr/bin/steamcmd /usr/bin/steamcmd
    COPY --from=steamcmd /usr/lib/games/steam /usr/lib/games/steam

    # Create user with /necesse as home
    ENV USER=necesse
    RUN adduser -D -h /necesse "$USER" && \
        mkdir -p /necesse/.config/Necesse/server \
                 /necesse/.config/Necesse/cfg \
                 /necesse/.config/Necesse/logs \
                 /necesse/.config/Necesse/cache \
                 /necesse/.config/Necesse/saves && \
        chown -R "$USER":"$USER" /necesse

    WORKDIR /necesse
    USER "$USER"

    # Only JVMARGS
    ENV JVMARGS=""

    COPY --chmod=0755 entrypoint.sh /entrypoint.sh
    COPY --chmod=0755 healthcheck.sh /healthcheck.sh

    HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=5 \
        CMD /healthcheck.sh || exit 1

    EXPOSE 14159/udp 14159/tcp
    ENTRYPOINT ["/entrypoint.sh"]