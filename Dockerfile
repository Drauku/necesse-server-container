# ---- Stage 1: Install SteamCMD ------------------------------------------------
    FROM steamcmd/steamcmd:latest AS steamcmd

    # ---- Stage 2: Runtime ---------------------------------------------------------
    FROM openjdk:17-jdk-slim AS runtime

    # Install 32-bit libs required by the game
    RUN apt-get update && apt-get install -y \
        lib32gcc-s1 \
        && rm -rf /var/lib/apt/lists/*

    # Copy SteamCMD from the first stage
    COPY --from=steamcmd /usr/lib/games/steam /usr/lib/games/steam
    COPY --from=steamcmd /usr/bin/steamcmd   /usr/bin/steamcmd
    COPY --from=steamcmd /etc/ssl/certs     /etc/ssl/certs
    COPY --from=steamcmd /lib               /lib

    # ------------------------------------------------------------------------------
    # Non-root user
    ENV USER=necesse \
        HOME=/home/necesse
    RUN useradd -m -U ${USER} && \
        mkdir -p ${HOME}/necesse && \
        chown -R ${USER}:${USER} ${HOME}
    WORKDIR ${HOME}

    # ------------------------------------------------------------------------------
    # Environment variables (with sensible defaults)
    ENV WORLD=world \
        SLOTS=10 \
        OWNER="" \
        MOTD="This server is made possible by Docker!" \
        PASSWORD="" \
        PAUSE=0 \
        GIVE_CLIENTS_POWER=1 \
        LOGGING=1 \
        ZIP=1 \
        JVMARGS=""

    # ------------------------------------------------------------------------------
    # Helper script that:
    #   1. Updates the game via SteamCMD
    #   2. Generates / updates server.cfg from the ENV vars
    #   3. Starts the server
    COPY entrypoint.sh /entrypoint.sh
    COPY healthcheck.sh /healthcheck.sh
    RUN chmod +x /entrypoint.sh /healthcheck.sh

    # ------------------------------------------------------------------------------
    # Healthcheck – make sure the server script exists
    # HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=3 \
    #     CMD test -f ${HOME}/necesse/StartServer-nogui.sh || exit 1
    HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=5 \
    CMD /healthcheck.sh || exit 1
    # Default Necesse port (UDP + TCP)
    EXPOSE 14159/udp 14159/tcp

    # Entrypoint runs the helper script
    ENTRYPOINT ["/entrypoint.sh"]