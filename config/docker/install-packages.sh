#!/bin/bash

# Update all packages
apt update && apt upgrade -y

# Install specific packages
PACKAGES=(
  zsh
)

# Install the packages
apt install -y "${PACKAGES[@]}"