# Multi-stage build: First stage for SteamCMD installation
FROM steamcmd/steamcmd:latest AS steamcmd

# Second stage: Runtime environment with OpenJDK and SteamCMD
FROM openjdk:17-jre-slim AS runtime

# Install dependencies for SteamCMD and 32-bit libs (required for Necesse)
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 \
    && rm -rf /var/lib/apt/lists/*

# Copy SteamCMD from the first stage
COPY --from=steamcmd /usr/lib/games/steam /usr/lib/games/steam
COPY --from=steamcmd /usr/bin/steamcmd /usr/bin/steamcmd
COPY --from=steamcmd /etc/ssl/certs /etc/ssl/certs
COPY --from=steamcmd /lib /lib

# Create non-root user and working directory
ENV USER=necesse \
    HOME=/home/necesse
RUN useradd -m -U ${USER} && \
    mkdir -p ${HOME}/necesse && \
    chown -R ${USER}:${USER} ${HOME}
WORKDIR ${HOME}

# Switch to non-root user
USER ${USER}

# Create update script to download/update Necesse server files
RUN echo '#!/bin/bash\n\
# Update Necesse server files\n\
steamcmd +login anonymous +force_install_dir ${HOME}/necesse +app_update 1169370 validate +quit\n\
# Make start script executable\n\
chmod +x ${HOME}/necesse/StartServer-nogui.sh' > ${HOME}/update_necesse.sh && \
    chmod +x ${HOME}/update_necesse.sh

# Healthcheck: Ensure server files are present
HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=3 \
    CMD test -f ${HOME}/necesse/StartServer-nogui.sh || exit 1

# Expose Necesse default port (UDP/TCP)
EXPOSE 14159/udp 14159/tcp

# Entry point: Update on every run, then start the server
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["${HOME}/update_necesse.sh && ${HOME}/necesse/StartServer-nogui.sh"]
