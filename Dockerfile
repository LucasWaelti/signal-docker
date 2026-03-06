# ~80–90MB base (compressed)
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Accept build arguments for user/group IDs
ARG USER_ID=1000
ARG GROUP_ID=1000

# Setup user and install dependencies
RUN groupadd -g ${GROUP_ID} app && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} app && \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates gnupg wget apt-transport-https \
        fonts-liberation libasound2t64 libasound2-data libasound2-plugins libnss3 libxss1 libxtst6 xdg-utils \
        libatk-bridge2.0-0 libgtk-3-0 libgl1 libglx0 libegl1 \
    && rm -rf /var/lib/apt/lists/*

# Install Signal (Ref: https://signal.org/download/#)
RUN wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg; \
    cat signal-desktop-keyring.gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null; \
    wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources; \
    cat signal-desktop.sources | tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null; \
    apt-get update && apt-get install -y signal-desktop \
    && rm -rf /var/lib/apt/lists/* signal-desktop-keyring.gpg signal-desktop.sources

# Create config directory structure with correct ownership
RUN mkdir -p /home/app/.config/Signal /home/app/.cache /home/app/.local/share

# Create a consistent /etc/os-release in the image so Signal/Electron sees the container distro
RUN printf 'NAME="Ubuntu"\nVERSION="24.04 (noble)"\nID=ubuntu\nID_LIKE=debian\nPRETTY_NAME="Ubuntu 24.04 (noble)"\nVERSION_CODENAME=noble\nUBUNTU_CODENAME=noble\n' > /etc/os-release

# Add launcher wrapper and make it executable
COPY usr-local-bin-run-signal.sh /usr/local/bin/run-signal
RUN chmod +x /usr/local/bin/run-signal && chown app:app /usr/local/bin/run-signal

USER app
WORKDIR /home/app

# Replace CMD with an entrypoint wrapper that enforces env and runs Signal
ENTRYPOINT ["/usr/local/bin/run-signal"]
CMD ["--no-sandbox", "--disable-gpu", "--disable-gpu-sandbox", \
    "--disable-software-rasterizer", "--disable-dev-shm-usage", \
    "--disable-extensions", "--disable-background-timer-throttling", \
    "--disable-backgrounding-occluded-windows", "--disable-renderer-backgrounding", \
    "--disable-features=TranslateUI", "--disable-ipc-flooding-protection"]

# # Note: We bind-mount the entire /home/app directory in run.sh for full persistence
# # No VOLUME directive needed as it would create an anonymous volume and shadow the bind mount
