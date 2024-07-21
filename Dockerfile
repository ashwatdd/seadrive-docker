# Use Ubuntu as the base image
FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    lsb-release \
    jq \
    curl \
    uuid-runtime \
    && rm -rf /var/lib/apt/lists/*

# Add Seafile repository
RUN wget https://linux-clients.seafile.com/seafile.asc -O /usr/share/keyrings/seafile-keyring.asc
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/seafile-keyring.asc] https://linux-clients.seafile.com/seadrive-deb/$(lsb_release -cs)/ stable main" | tee /etc/apt/sources.list.d/seadrive.list > /dev/null

# Install SeaDrive daemon
RUN apt-get update && apt-get install -y \
    seadrive-daemon \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /mnt/seadrive /root/.seadrive/

# Copy the launch script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables
ENV SEAFILE_SERVER_URL=""
ENV SEAFILE_USERNAME=""
ENV SEAFILE_PASSWORD=""
ENV SEAFILE_CLIENT_NAME=""
ENV SEAFILE_CACHE_SIZE="10GB"
ENV SEAFILE_CACHE_CLEAN_INTERVAL="10"
ENV PUID="1000"
ENV PGID="1000"

# Run the launch script
ENTRYPOINT ["/entrypoint.sh"]