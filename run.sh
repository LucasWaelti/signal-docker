#!/bin/bash

# Allow local docker containers to talk to your X server (reverts on reboot)
xhost +local:docker

mkdir -p ~/.signal-container/home/.config/Signal \
         ~/.signal-container/home/.cache \
         ~/.signal-container/home/.local/share
chown -R $(id -u):$(id -g) ~/.signal-container
chmod 700 ~/.signal-container/home ~/.signal-container/home/.config ~/.signal-container/home/.config/Signal 2>/dev/null || true

docker run --rm \
  --name signal \
  -e HOME=/home/app \
  -e USER=app \
  -e XDG_CONFIG_HOME=/home/app/.config \
  -e XDG_CACHE_HOME=/home/app/.cache \
  -e XDG_DATA_HOME=/home/app/.local/share \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v ~/.signal-container/home:/home/app \
  -e XDG_RUNTIME_DIR=/run/user/$(id -u) \
  -e PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native \
  -v /run/user/$(id -u)/pulse:/run/user/$(id -u)/pulse \
  --device /dev/snd --group-add audio \
  --device /dev/dri \
  signal-ubuntu24:latest
