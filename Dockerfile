# ---- Stage 1: SteamCMD -------------------------------------------------------
    FROM steamcmd/steamcmd:latest AS steamcmd

    # ---- Stage 2: Runtime ---------------------------------------------------------
    FROM openjdk:17-jdk-slim AS runtime

    # Install required 32-bit libraries for Necesse/SteamCMD
    RUN apt-get update && apt-get install -y \
        lib32gcc-s1 \
        lib32stdc++6 \
        && rm -rf /var/lib/apt/lists/*

    # Copy ONLY the steamcmd binary and its runtime files
    COPY --from=steamcmd /usr/bin/steamcmd /usr/bin/steamcmd
    COPY --from=steamcmd /usr/lib/games/steam /usr/lib/games/steam

    # Create non-root user and directories
    ENV USER=necesse \
        HOME=/home/necesse

    RUN useradd -m -U ${USER} && \
        mkdir -p ${HOME}/necesse && \
        chown -R ${USER}:${USER} ${HOME}

    WORKDIR ${HOME}

    # Switch to non-root user
    USER ${USER}

    # ----------------------------------------------------------------------
    # Environment variables
    # ----------------------------------------------------------------------
    ENV WORLD=world \
        SLOTS=10 \
        OWNER="" \
        MOTD="This server is made possible by Docker!" \
        # PASSWORD="" \ # configure in entrypoint.sh instead of here
        PAUSE=0 \
        GIVE_CLIENTS_POWER=1 \
        LOGGING=1 \
        ZIP=1 \
        JVMARGS=""

    # ----------------------------------------------------------------------
    # Copy scripts
    # ----------------------------------------------------------------------
    COPY --chmod=0755 entrypoint.sh /entrypoint.sh
    COPY --chmod=0755 healthcheck.sh /healthcheck.sh

    # ----------------------------------------------------------------------
    # HEALTHCHECK
    # ----------------------------------------------------------------------
    HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=5 \
        CMD /healthcheck.sh || exit 1

    EXPOSE 14159/udp 14159/tcp

    ENTRYPOINT ["/entrypoint.sh"]
