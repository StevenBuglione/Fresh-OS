FROM ghcr.io/wsl-images/ubuntu:latest
LABEL authors="wsl-images"

COPY ./config /tmp/config

RUN chmod +x /tmp/config/docker/setup-nix-temp-user.sh && /tmp/config/docker/setup-nix-temp-user.sh
RUN chmod +x /tmp/config/docker/configure-wsl.sh && /tmp/config/docker/configure-wsl.sh

RUN rm -rf /tmp/config